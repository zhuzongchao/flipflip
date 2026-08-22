# FlipFlip 接盘维护路线图

> 本仓库是 [ififfy/flipflip](https://github.com/ififfy/flipflip) 的 fork。
> fork 原因：原作者更新放缓，由本仓库自行维护。
> fork 时间点：2026-08-21，master = upstream 998063c，完全同步。

## 当前状态（2026-08-21 基准）

- ✅ 依赖安装成功（Node 22 + yarn 1）
- ✅ 开发构建成功（webpack.dev）
- ✅ 应用在 Windows 上可正常启动运行

## 环境须知（重要，AI 助手必读）

1. **构建无需 legacy-provider**：webpack 5 已移除 webpack 4 的 md4 哈希兼容问题。
   VS Code 里用任务（`.vscode/tasks.json` 已配好）：`Ctrl+Shift+B`

2. **启动应用时必须清掉这两个变量**（Electron 4 内置 Node 10，
   `--openssl-legacy-provider` 参数和 `ELECTRON_RUN_AS_NODE` 都会让它崩溃）：

   ```bash
   env -u NODE_OPTIONS -u ELECTRON_RUN_AS_NODE ./node_modules/electron/dist/electron.exe ./dist/main.bundle.js
   ```

3. **远程仓库**：origin = 本 fork；upstream = 原作者仓库（保留，偶尔同步）。

## 任务清单（按优先级）

### P0 已完成
- [x] 环境搭建、构建验证、启动验证
- [x] `.vscode/tasks.json`（build / development / production / start app）

### P1 现代化改造（接力顺序，每步独立验证）

> 原则：一次只升一个东西，升完必须构建 + 启动验证通过再 commit。

- [x] **T1: webpack 4 → 5**（已完成，webpack 5 使用默认哈希，无需 legacy-provider）
  - 涉及：webpack、webpack-cli、html-webpack-plugin、css/sass/style-loader、
    ts-loader、workerize-loader（注意此库可能不兼容，需找替代）
- [x] **T2: TypeScript 4.1 → 5.x**（TypeScript 5.9.3；更新 React 17 对应声明包；`tsc --noEmit` 与开发构建均通过）
- [ ] **T3: Electron 4 → 最新稳定版**（大工程，已侦察完毕，拆解如下）

  侦察结论（2026-08-21 实测源码）：
  - `remote` 模块只有 **3 处调用、2 个文件**（比预想少一个数量级）：
    - `src/renderer/components/Meta.tsx`：`remote.getCurrentWindow().id`（两处，窗口 ID）
    - `src/renderer/components/player/Player.tsx`：
      `remote.powerSaveBlocker.start/stop`、`remote.getCurrentWindow().webContents.session.clearCache`
  - `nodeIntegration: true` 只在 `src/main/WindowManager.ts` 一处（含 `nodeIntegrationInWorker`）
  - `ipcRenderer` 标准用法（on/send），2 个文件，新版本直接兼容
  - 窗口创建只有 WindowManager.ts 一处；无 native 模块；打包用 electron-packager 15
  - webpack target：`electron-main` / `electron-renderer`，无需改

  子任务拆解（每步独立验证，通过后再下一步）：
  - [x] **T3.1 兼容模式跑通**：electron 43.4.1 + `@electron/remote`，完成类型检查、构建和启动验证
    （main 进程 initialize，渲染进程改 import 来源），WindowManager 显式加
    `sandbox: false, contextIsolation: false, nodeIntegration: true`（保持现状可跑）
  - [x] **T3.1b 修复 dialog Promise 漏网（2026-08-22 验收发现，**必须做**）**：
    `remoteCompat.ts` 的 `dialog: ... as any` 让类型检查失效，14 处 `showOpenDialog`
    老同步写法全部漏网（CacheCard/AudioEdit/AudioLibrary/Library/ScriptLibrary/
    SourceList/CaptionScriptor/GooninatorDialog/ScenePicker/actions.ts），
    后果：**所有文件选择功能全挂**（选完文件无反应）。修复见下方 T3.1b 说明
  - [ ] **T3.2 运行时回归**：CDP 深度验收 + 人工过一遍核心功能
    （建窗口、播放场景、图片加载、设置持久化）
  - [ ] **T3.3 打包验证**：electron-packager 打出 exe 并安装运行（或换 electron-builder）
  - [ ] **T3.4 安全加固（可选，不急）**：contextIsolation + preload + IPC
    替换 nodeIntegration，彻底现代化

  风险预案：
  - 新 Chromium 对 CSP/CORS 更严格，可能影响图源图片加载 → T3.2 重点观察
  - workerize-loader 的 worker 依赖 `nodeIntegrationInWorker` → sandbox:false 下应可用，出问题再单独处理
  - `webFrame.clearCache()` 若被移除，改走 IPC 调主进程 clearCache
  - **无 GPU/沙箱环境启动崩溃**（`GPU process isn't usable. Goodbye.`）：
    需 `--in-process-gpu --disable-gpu-compositing` 启动参数；已加 `app.disableHardwareAcceleration()`
    兜底（main.ts，对正常环境无影响）

### T3.1b 修复说明（Codex 必读）

**症状**：升级后 app 能开，但"添加视频/音频/图片/字幕/缓存目录/场景导入"全部无反应
（文件选择框能弹，选完文件没下文）。

**根因**：`@electron/remote` 2.x 的 `dialog.showOpenDialog` 返回 `Promise<OpenDialogReturnValue>`，
不再是 Electron 4 时代的 `string[]`。`remoteCompat.ts` 里 `dialog: ... as any` 把类型检查废了，
导致 14 处老同步写法 `const x = dialog.showOpenDialog(...)` 全部漏网——拿到的是 Promise
（永远 truthy），`if (!x) return` 拦不住，后续 `.filter`/`[0]` 全部无效。

**修复方法**（全部 14 处，见任务清单）：每处改为 async/await 或 .then 处理，从
`result.filePaths` 取路径数组：

```ts
// 老写法（坏）：
const filePath = remote.dialog.showOpenDialog(win, opts);
if (!filePath || !filePath.length) return;
use(filePath[0]);

// 新写法（对）：
const result = await remote.dialog.showOpenDialog(win, opts);
if (result.canceled || !result.filePaths.length) return;
use(result.filePaths[0]);
```

注意：调用方函数需加 `async` 关键字；有 `updateLibrary/updateScene` 等返回值的
reducer 调用，await 之后照常返回。**禁止用 `as any` 掩盖**——要把类型写对。

**验证**：`npx tsc --noEmit` 零报错 + `npx yarn build` 零报错 + 手动测一遍
"添加视频"能正常选文件并出现在列表里。

### T6: 多语种改造（i18n，2026-08-22 需求，Codex 必读）

**现状**：零 i18n 基础设施；渲染进程 372 处硬编码英文 UI 文案（86 个组件文件、
含菜单/按钮/占位符/tooltip），主进程 MainMenu.ts 仅 2 个顶层标签（File/View）。
React 17 + MUI 5。

**目标**：中英双语（默认英文，可切换中文），为后续更多语言铺路。

**技术选型（推荐）**：`react-i18next` + `i18next`（React 17 兼容性好、社区最大、
无 MUI 绑定；避免 react-intl 与 MUI 组件的互操作复杂度）。

**改造步骤（Codex 按此执行）**：

1. **基建**：装 `i18next react-i18next`；新建 `src/renderer/i18n.ts`（初始化、语言检测
   默认 en、回退 en）；新建 `src/renderer/locales/en.ts` + `zh.ts`（结构化字典）
2. **接入**：`src/renderer/index.tsx` 引入 i18n.ts；根组件包 `<I18nextProvider>`
3. **逐文件替换**（372 处，分批做，每批构建验证）：
   - JSX 文案：`Search` → `{t('search')}`，`t` 来自 `useTranslation()`
   - 类组件（无 hook）：用 `withTranslation()` HOC 或 `this.props.t`
   - 属性值：`placeholder={"Search ..."}` → `placeholder={t('searchPlaceholder')}`
   - 动态字符串（模板拼接）：整句作为 key 或用 i18next 插值 `{{name}}`
4. **主进程菜单**：MainMenu.ts 的 label 传 key，由渲染进程发 IPC 动态更新
   （或简单方案：菜单先用英文，后续再本地化）
5. **语言切换**：设置页加语言下拉框（en/zh），切换后 `i18n.changeLanguage()` +
   重渲染；持久化到 electron-store（与现有配置同机制）
6. **数据字段（不翻译）**：图源名、文件名、API 参数、错误码等保持原样

**验证**：切换中文后所有界面文案变中文、无 `key` 泄漏（页面上出现原始 key 即失败）、
`npx tsc --noEmit` + `npx yarn build` 零报错、app 启动正常。

**风险**：372 处替换工作量大（Codex 分批干）；类组件改造易漏 hook；动态字符串
拼接处需人工判断；MUI 组件的 `title/label/aria-label` 属性也要覆盖。

- [ ] **T4: React 17 → 18**（T3 之后做，收益相对小，可延后）
- [ ] **T5: 替换废弃依赖**：`request`（已废弃）、`twitter` 包等

### P2 功能维护
- [ ] 随时修 bug、加小功能，直接在分支上做
- [ ] 稳定后打 tag 发 Release（版本号从 3.2.x 往后走）

## 给 AI 助手（Codex 等）的作业模板

```
在 <分支名> 分支上：<具体任务描述>。
完成后运行构建验证：
  npx yarn build
要求：构建零报错。不要顺手升级本任务之外的依赖。
```

注意：T1 完成后，构建命令就不再需要那个环境变量，届时更新本文件。

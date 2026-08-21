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
  - [ ] **T3.1 兼容模式跑通**：electron 升到最新稳定版 + 引入 `@electron/remote`
    （main 进程 initialize，渲染进程改 import 来源），WindowManager 显式加
    `sandbox: false, contextIsolation: false, nodeIntegration: true`（保持现状可跑）
  - [ ] **T3.2 运行时回归**：CDP 深度验收 + 人工过一遍核心功能
    （建窗口、播放场景、图片加载、设置持久化）
  - [ ] **T3.3 打包验证**：electron-packager 打出 exe 并安装运行（或换 electron-builder）
  - [ ] **T3.4 安全加固（可选，不急）**：contextIsolation + preload + IPC
    替换 nodeIntegration，彻底现代化

  风险预案：
  - 新 Chromium 对 CSP/CORS 更严格，可能影响图源图片加载 → T3.2 重点观察
  - workerize-loader 的 worker 依赖 `nodeIntegrationInWorker` → sandbox:false 下应可用，出问题再单独处理
  - `webFrame.clearCache()` 若被移除，改走 IPC 调主进程 clearCache
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

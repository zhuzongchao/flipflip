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
- [ ] **T2: TypeScript 4.1 → 5.x**
- [ ] **T3: Electron 4 → 最新 LTS**（最大工程，单独分支慢慢来）
  - 已知破坏点：`remote` 模块已被移除（需改用 IPC / preload）、
    `nodeIntegration` 默认关闭、`contextIsolation` 默认开启
  - 建议路径：先跑通编译，再修运行时错误，逐个窗口验证
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

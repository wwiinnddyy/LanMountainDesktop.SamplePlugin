# LanMountainDesktop.SamplePlugin

## 中文

这是阑山桌面的独立示例插件仓库，也是当前插件市场联调与发布链路的参考项目。

### 仓库职责

- 提供可直接构建的示例插件工程
- 在仓库根目录产出 `.laapp`
- 在仓库根目录提供 `README.md`
- 通过 `LanAirApp/airappmarket/index.json` 被官方市场引用

### 发布约定

- 当前版本：`{{VERSION}}`
- 当前 Release 标签：`{{RELEASE_TAG}}`
- 当前根目录发布包：`{{ASSET_NAME}}`
- 阑山桌面插件市场会优先解析 GitHub Release 里的同名资产
- 如果 Release 未发布、资产缺失或 GitHub API 无法解析，宿主会退回到仓库根目录 `.laapp`
- 插件介绍始终读取仓库根目录 `README.md`

### CI/CD

- `pull_request` 和推送到 `main` 时执行 CI：还原、构建、打包、校验版本与产物命名
- 推送 `v*` 标签或手动触发工作流时执行发布：创建或更新 GitHub Release，并生成 `airappmarket-sync.json`
- 发布后会自动为本仓库创建 PR，同步根目录 `.laapp` 和版本文件
- 发布后也会自动为 `LanAirApp` 创建 PR，同步官方市场索引

## English

This repository is the standalone sample plugin for LanMountainDesktop and the reference project for the current plugin market release flow.

### Repository role

- provide a directly buildable sample plugin project
- generate the `.laapp` package in the repository root
- keep `README.md` in the repository root
- be referenced by `LanAirApp/airappmarket/index.json`

### Publishing contract

- Current version: `{{VERSION}}`
- Current release tag: `{{RELEASE_TAG}}`
- Current root package: `{{ASSET_NAME}}`
- the desktop market resolves the exact GitHub Release asset first
- if Release resolution fails, the host falls back to the repository root `.laapp`
- plugin details always come from the repository root `README.md`

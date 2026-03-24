# LanMountainDesktop.SamplePlugin

## 中文

这是 `LanMountainDesktop` 的官方示例插件仓库，也是官方市场聚合器消费的发布契约样板。
它只负责演示 SDK v4 用法、发布流程和示例代码，不承担宿主运行时逻辑。

### 仓库职责

- 提供可直接构建的官方示例插件
- 在仓库根目录输出 `.laapp`
- 随 GitHub Release 一起发布 `market-manifest.json`
- 作为官方市场聚合器的样板插件
- 保持 `README.md` 作为插件说明源

### v4 演示点

- 插件 API 基线：`4.0.0`
- 入口模型：`Initialize(HostBuilderContext, IServiceCollection)`
- 新组件注册：`PluginDesktopComponentOptions`
- 统一圆角入口：`IPluginAppearanceContext` 和 `PluginAppearanceSnapshot`
- 圆角预设：`PluginCornerRadiusPreset`
- 共享契约：`LanMountainDesktop.SharedContracts.SampleClock` `2.0.0`
- 宿主交互：`IPluginRuntimeContext`、`IHostApplicationLifecycle`、`IPluginMessageBus`
- 宿主扩展点：`AddPluginExport`、`AddPluginSettingsSection`

### 发布契约

- 当前版本：`{{VERSION}}`
- 当前 Release 标签：`{{RELEASE_TAG}}`
- 当前根目录包名：`{{ASSET_NAME}}`
- 发布产物：`.laapp`、`market-manifest.json`、`sha256.txt`、`md5.txt`
- GitHub Release 资产是规范的分发源
- `market-manifest.json` 是官方市场发布契约
- 仓库根目录 `README.md` 保持插件介绍来源

## English

This repository is the official sample plugin for LanMountainDesktop and the contract example consumed by the official market aggregator.
It demonstrates SDK v4 usage, the release pipeline, and sample code without hosting runtime responsibilities.

### Repository role

- provide a directly buildable official sample plugin
- generate the `.laapp` package in the repository root
- publish `market-manifest.json` alongside the GitHub Release asset
- serve as the sample plugin consumed by the official market aggregator
- keep `README.md` in the repository root as the canonical plugin introduction

### v4 demo points

- Plugin API baseline: `4.0.0`
- Entry model: `Initialize(HostBuilderContext, IServiceCollection)`
- New component registration: `PluginDesktopComponentOptions`
- Unified corner radius entry: `IPluginAppearanceContext` and `PluginAppearanceSnapshot`
- Corner radius presets: `PluginCornerRadiusPreset`
- Shared contract: `LanMountainDesktop.SharedContracts.SampleClock` `2.0.0`
- Host interaction: `IPluginRuntimeContext`, `IHostApplicationLifecycle`, `IPluginMessageBus`
- Host extension points: `AddPluginExport`, `AddPluginSettingsSection`

### Publishing contract

- Current version: `{{VERSION}}`
- Current release tag: `{{RELEASE_TAG}}`
- Current root package: `{{ASSET_NAME}}`
- Release assets: `.laapp`, `market-manifest.json`, `sha256.txt`, `md5.txt`
- The GitHub Release asset is the canonical distribution source
- `market-manifest.json` is the official market publication contract
- The repository-root `README.md` remains the canonical plugin introduction

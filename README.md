# LanMountainDesktop.SamplePlugin

## 中文

这是 `LanMountainDesktop` 的官方示例插件仓，也是当前插件市场发布链路的权威参考项目。它只负责演示插件 SDK 用法、发布契约和示例代码，不承担宿主运行时，也不再作为 SDK 镜像源。

### 仓库职责

- 提供可直接构建的官方示例插件源码
- 在仓库根目录产出 `.laapp`
- 维护仓库根目录 `README.md`
- 作为 `LanAirApp/airappmarket/index.json` 引用的官方示例插件

### v4 演示点

- 插件 API 基线：`4.0.0`
- 入口模型：`Initialize(HostBuilderContext, IServiceCollection)`
- 新组件注册方式：`PluginDesktopComponentOptions`
- 统一圆角入口：`IPluginAppearanceContext` 与 `PluginAppearanceSnapshot`
- 圆角预设：`PluginCornerRadiusPreset`
- 共享契约：`LanMountainDesktop.SharedContracts.SampleClock` `2.0.0`
- 宿主交互：`IPluginRuntimeContext`、`IHostApplicationLifecycle`、`IPluginMessageBus`
- 宿主扩展：`AddPluginExport`、`AddPluginSettingsSection`

### 发布契约

- 当前版本：`0.1.1`
- 当前 Release 标签：`v0.1.1`
- 当前根目录包名：`LanMountainDesktop.SamplePlugin.0.1.1.laapp`
- 桌面市场优先解析 GitHub Release 同名资源
- 如果 Release 解析失败，宿主回退到仓库根目录 `.laapp`
- 插件说明始终以仓库根目录 `README.md` 为准

## English

This is the official sample plugin repository for LanMountainDesktop. It serves as the authoritative reference for plugin SDK v4 usage, publishing conventions, and sample implementation details.

### Repository role

- provide a directly buildable official sample plugin
- generate the `.laapp` package in the repository root
- keep `README.md` in the repository root as the canonical plugin introduction
- serve as the sample plugin referenced by `LanAirApp/airappmarket/index.json`

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

- Current version: `0.1.1`
- Current release tag: `v0.1.1`
- Current root package: `LanMountainDesktop.SamplePlugin.0.1.1.laapp`
- the desktop market resolves the matching GitHub Release asset first
- if Release resolution fails, the host falls back to the repository-root `.laapp`
- plugin details always come from the repository-root `README.md`

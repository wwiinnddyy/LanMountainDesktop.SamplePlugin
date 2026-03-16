# LanMountainDesktop.SamplePlugin

## 中文

这是阑山桌面的官方示例插件仓库，也是当前插件市场发布链路的权威参考项目。

### 仓库职责

- 提供可直接构建的官方示例插件源码
- 在仓库根目录产出 `.laapp`
- 在仓库根目录提供 `README.md`
- 作为 `LanAirApp/airappmarket/index.json` 引用的官方示例插件项目

### 当前接口基线

- 插件 API 基线：`3.0.0`
- 入口模型：`Initialize(HostBuilderContext, IServiceCollection)`
- 共享契约：`LanMountainDesktop.SharedContracts.SampleClock` `2.0.0`

### 当前示例显式演示

- `IPluginRuntimeContext`
- `PluginHostPropertyKeys`
- `IHostApplicationLifecycle`
- `IPluginMessageBus`
- `AddPluginExport`
- `AddPluginSettingsSection`
- `AddPluginDesktopComponent`

### 发布约定

- 当前版本：`0.1.1`
- 当前 Release 标签：`v0.1.1`
- 当前根目录发布包：`LanMountainDesktop.SamplePlugin.0.1.1.laapp`
- 桌面市场优先解析 GitHub Release 同名资产
- 若 Release 解析失败，宿主回退到仓库根目录 `.laapp`
- 插件详情始终读取仓库根目录 `README.md`

## English

This repository is the official sample plugin for LanMountainDesktop and the authoritative reference project for the current plugin market release flow.

### Repository role

- provide a directly buildable official sample plugin
- generate the `.laapp` package in the repository root
- keep `README.md` in the repository root
- serve as the official sample plugin referenced by `LanAirApp/airappmarket/index.json`

### Current interface baseline

- Plugin API baseline: `3.0.0`
- Entry model: `Initialize(HostBuilderContext, IServiceCollection)`
- Shared contract: `LanMountainDesktop.SharedContracts.SampleClock` `2.0.0`

### Demonstrated host-facing capabilities

- `IPluginRuntimeContext`
- `PluginHostPropertyKeys`
- `IHostApplicationLifecycle`
- `IPluginMessageBus`
- `AddPluginExport`
- `AddPluginSettingsSection`
- `AddPluginDesktopComponent`

### Publishing contract

- Current version: `0.1.1`
- Current release tag: `v0.1.1`
- Current root package: `LanMountainDesktop.SamplePlugin.0.1.1.laapp`
- the desktop market resolves the exact GitHub Release asset first
- if Release resolution fails, the host falls back to the repository root `.laapp`
- plugin details always come from the repository root `README.md`

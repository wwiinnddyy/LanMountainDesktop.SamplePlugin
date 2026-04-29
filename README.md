# LanMountainDesktop.SamplePlugin

Official sample plugin for LanMountainDesktop SDK v5.

## Role

- Demonstrates the SDK v5 plugin entry point, settings registration, desktop components, hosted services, and shared contracts.
- Builds a `.laapp` package in the repository root.
- Publishes `market-manifest.json` for the LanAirApp market aggregator.
- Keeps this README as the canonical plugin introduction.

## SDK v5 Baseline

- Target framework: `net10.0`
- Plugin SDK: `LanMountainDesktop.PluginSdk` `5.0.0`
- Manifest file: `plugin.json`
- Package format: `.laapp`
- Runtime mode: `in-proc`
- Current version: `0.3.1`
- Current release tag: `v0.3.1`
- Current package asset: `LanMountainDesktop.SamplePlugin.0.3.1.laapp`

## Publishing Contract

Release assets should include:

- `LanMountainDesktop.SamplePlugin.0.3.1.laapp`
- `market-manifest.json`
- `sha256.txt`
- `md5.txt`

The generated market manifest contains `manifest`, `compatibility`, `repository`, `publication.packageSources`, and `capabilities`. The host prefers the tagged GitHub Release asset, then raw fallback, then a `workspace://LanMountainDesktop.SamplePlugin/...` local source for development.

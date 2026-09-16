using LanMountainDesktop.AirAppSdk;
using LanMountainDesktop.SharedContracts.SampleClock;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace LanMountainDesktop.SamplePlugin;

[AirAppEntrance]
public sealed class SamplePlugin : AirAppBase
{
    public override void Initialize(HostBuilderContext context, IServiceCollection services)
    {
        ArgumentNullException.ThrowIfNull(context);
        ArgumentNullException.ThrowIfNull(services);

        var localizer = CreateLocalizer(context);

        services.AddSingleton(provider =>
        {
            var runtimeContext = provider.GetRequiredService<IAirAppRuntimeContext>();
            Directory.CreateDirectory(runtimeContext.DataDirectory);

            return new SamplePluginRuntimeStateService(
                runtimeContext.Manifest,
                runtimeContext.AirAppDirectory,
                runtimeContext.DataDirectory,
                GetHostProperty(runtimeContext, AirAppHostPropertyKeys.HostApplicationName, "UnknownHost"),
                GetHostProperty(runtimeContext, AirAppHostPropertyKeys.HostVersion, "UnknownVersion"),
                GetHostProperty(runtimeContext, AirAppHostPropertyKeys.AirAppSdkApiVersion, "UnknownApiVersion"),
                provider.GetRequiredService<IAirAppMessageBus>(),
                AirAppLocalizer.Create(runtimeContext));
        });

        services.AddSingleton(provider =>
        {
            var runtimeContext = provider.GetRequiredService<IAirAppRuntimeContext>();
            return new SamplePluginClockService(
                runtimeContext.DataDirectory,
                provider.GetRequiredService<SamplePluginRuntimeStateService>(),
                provider.GetRequiredService<IAirAppMessageBus>(),
                AirAppLocalizer.Create(runtimeContext));
        });

        services.AddSingleton<IHostedService, SamplePluginHostedService>();
        services.AddAirAppExport<ISampleClockExport, SamplePluginClockExport>();

        services.AddAirAppSettingsSection(
            id: "status",
            titleLocalizationKey: "settings.page_title",
            configure: builder =>
            {
                builder.AddText(
                    key: "status.note",
                    titleLocalizationKey: "settings.page_title",
                    descriptionLocalizationKey: "plugin.description",
                    defaultValue: localizer.GetString(
                        "settings.section.status_hint",
                        "Use this section to verify plugin runtime status."));
            },
            descriptionLocalizationKey: "plugin.description",
            iconKey: "PuzzlePiece",
            sortOrder: 0);

        services.AddAirAppComponent<SamplePluginStatusClockWidget>(
            CreateStatusClockComponentOptions(localizer));

        services.AddAirAppComponent<SamplePluginCloseDesktopWidget>(
            CreateCloseDesktopComponentOptions(localizer));
    }

    private static AirAppLocalizer CreateLocalizer(HostBuilderContext context)
    {
        var pluginDirectory = context.Properties.TryGetValue("LanMountainDesktop.AirAppDirectory", out var directoryValue) &&
                              directoryValue is string resolvedAirAppDirectory &&
                              !string.IsNullOrWhiteSpace(resolvedAirAppDirectory)
            ? resolvedAirAppDirectory
            : AppContext.BaseDirectory;

        var properties = context.Properties
            .Where(pair => pair.Key is string)
            .ToDictionary(pair => (string)pair.Key, pair => (object?)pair.Value, StringComparer.OrdinalIgnoreCase);

        return new AirAppLocalizer(pluginDirectory, AirAppLocalizer.ResolveLanguageCode(properties));
    }

    private static string GetHostProperty(IAirAppRuntimeContext context, string key, string fallback)
    {
        return context.TryGetProperty<string>(key, out var value) && !string.IsNullOrWhiteSpace(value)
            ? value
            : fallback;
    }

    private static AirAppComponentOptions CreateStatusClockComponentOptions(AirAppLocalizer localizer)
    {
        return new AirAppComponentOptions
        {
            ComponentId = "LanMountainDesktop.SamplePlugin.StatusClock",
            DisplayName = localizer.GetString("widget.display_name", "Sample Plugin Status Clock"),
            DisplayNameLocalizationKey = "widget.display_name",
            IconKey = "PuzzlePiece",
            Category = localizer.GetString("widget.category", "Plugins"),
            MinWidthCells = 4,
            MinHeightCells = 4,
            AllowDesktopPlacement = true,
            AllowStatusBarPlacement = false,
            ResizeMode = AirAppComponentResizeMode.Proportional,
            CornerRadiusPreset = AirAppCornerRadiusPreset.Default
        };
    }

    private static AirAppComponentOptions CreateCloseDesktopComponentOptions(AirAppLocalizer localizer)
    {
        return new AirAppComponentOptions
        {
            ComponentId = "LanMountainDesktop.SamplePlugin.CloseDesktop",
            DisplayName = localizer.GetString("widget.close_desktop.display_name", "Close Desktop"),
            DisplayNameLocalizationKey = "widget.close_desktop.display_name",
            IconKey = "DismissCircle",
            Category = localizer.GetString("widget.category", "Plugins"),
            MinWidthCells = 2,
            MinHeightCells = 1,
            AllowDesktopPlacement = true,
            AllowStatusBarPlacement = false,
            ResizeMode = AirAppComponentResizeMode.Free,
            CornerRadiusPreset = AirAppCornerRadiusPreset.Default
        };
    }
}

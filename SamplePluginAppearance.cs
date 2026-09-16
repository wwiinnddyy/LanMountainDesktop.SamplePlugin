using Avalonia;
using LanMountainDesktop.AirAppSdk;

namespace LanMountainDesktop.SamplePlugin;

internal static class SamplePluginAppearance
{
    public static AirAppAppearanceSnapshot? GetAppearanceSnapshot(this AirAppComponentContext context)
    {
        return context.GetService<IAirAppAppearanceContext>()?.Snapshot;
    }

    public static CornerRadius ResolveCornerRadius(
        this AirAppAppearanceSnapshot? snapshot,
        AirAppCornerRadiusPreset preset,
        CornerRadius fallback)
    {
        return snapshot?.CornerRadiusTokens is { } tokens
            ? tokens.ToCornerRadius(preset)
            : fallback;
    }
}

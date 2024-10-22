using Godot;

public partial class CSharpTest : Node
{
    public string OperatingSystem()
    {
#if GODOT_WINDOWS
        return "Windows";
#elif GODOT_LINUXBSD
        return "Linux/*BSD";
#elif GODOT_MACOS
        return "macOS";
#elif GODOT_ANDROID
        return "Android";
#elif GODOT_IOS
        return "iOS";
#elif GODOT_WEB
        return "Web";
#elif GODOT
        return "Other";
#else
        return "Unknown";
#endif
    }

    public string PlatformType()
    {
#if GODOT_PC
        return "PC";
#elif GODOT_MOBILE
        return "Mobile";
#elif GODOT_WEB
        return "Web";
#elif GODOT
        return "Other";
#else
        return "Unknown";
#endif
    }
}

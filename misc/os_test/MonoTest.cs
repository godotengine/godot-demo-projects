using Godot;
using System;

public class MonoTest : Node
{
    public string OperatingSystem()
    {
#if GODOT_WINDOWS
        return "Windows";
#elif GODOT_LINUXBSD || GODOT_X11
        return "Linux (or BSD)";
#elif GODOT_SERVER
        return "Server (Linux or BSD)";
#elif GODOT_MACOS || GODOT_OSX
        return "macOS";
#elif GODOT_ANDROID
        return "Android";
#elif GODOT_IOS
        return "iOS";
#elif GODOT_HTML5
        return "HTML5";
#elif GODOT_HAIKU
        return "Haiku";
#elif GODOT_UWP
        return "UWP (Windows 10)";
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

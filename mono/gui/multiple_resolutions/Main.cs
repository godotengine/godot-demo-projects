// The root Control node ("Main") and AspectRatioContainer nodes are the most important
// pieces of this demo.
// Both nodes have their Layout set to Full Rect
// (with their rect spread across the whole viewport, and Anchor set to Full Rect).

using Godot;

namespace MultipleResolutions
{
    public partial class Main : Control
    {
        Vector2 baseWindowSize = new(
            (float)ProjectSettings.GetSetting("display/window/size/viewport_width"),
            (float)ProjectSettings.GetSetting("display/window/size/viewport_height"));

        // These defaults match this demo's project settings. Adjust as needed if adapting this
        // in your own project.
        Window.ContentScaleModeEnum stretchMode = Window.ContentScaleModeEnum.CanvasItems;
        Window.ContentScaleAspectEnum stretchAspect = Window.ContentScaleAspectEnum.Expand;

        float scaleFactor = 1.0f;
        float guiAspectRatio = -1.0f;
        float guiMargin = 0.0f;

        Panel panel = null;
        AspectRatioContainer arc = null;

        public override void _Ready()
        {
            // The `resized` signal will be emitted when the window size changes, as the root Control node
            // is resized whenever the window size changes. This is because the root Control node
            // uses a Full Rect anchor, so its size will always be equal to the window size.
            panel = FindChild("Panel") as Panel;
            arc = panel.FindChild("AspectRatioContainer") as AspectRatioContainer;

            Resized += this.OnResized;
            CallDeferred("UpdateContainer");
        }

        public void UpdateContainer()
        {
            // The code within this function needs to be run deferred to work around an issue with containers
            // having a 1-frame delay with updates.
            // Otherwise, `panel.size` returns a value of the previous frame, which results in incorrect
            // sizing of the inner AspectRatioContainer when using the Fit to Window setting.
            for (int i = 0; i < 2; i++)
            {
                if (Mathf.IsEqualApprox(guiAspectRatio, -1.0f))
                {
                    // Fit to Window. Tell the AspectRatioContainer to use the same aspect ratio as the window,
                    // making the AspectRatioContainer not have any visible effect.
                    arc.Ratio = panel.Size.Aspect();
                    // Apply GUI offset on the AspectRatioContainer's parent (Panel).
                    // This also makes the GUI offset apply on controls located outside the AspectRatioContainer
                    // (such as the inner side label in this demo).
                    panel.OffsetTop = guiMargin;
                    panel.OffsetBottom = -guiMargin;
                }
                else
                {
                    // Constrained aspect ratio.
                    arc.Ratio = Mathf.Min(panel.Size.Aspect(), guiAspectRatio);
                    // Adjust top and bottom offsets relative to the aspect ratio when it's constrained.
                    // This ensures that GUI offset settings behave exactly as if the window had the
                    // original aspect ratio size.
                    panel.OffsetTop = guiMargin / guiAspectRatio;
                    panel.OffsetBottom = -guiMargin / guiAspectRatio;
                }

                panel.OffsetLeft = guiMargin;
                panel.OffsetRight = -guiMargin;
            }
        }

        public void OnGuiAspectRatioItemSelected(int index)
        {
            switch (index)
            {
                case 0: // Fit to Window
                    guiAspectRatio = -1.0f;
                    break;
                case 1: // 5:4
                    guiAspectRatio = 5.0f / 4.0f;
                    break;
                case 2: // 4:3
                    guiAspectRatio = 4.0f / 3.0f;
                    break;
                case 3: // 3:2
                    guiAspectRatio = 3.0f / 2.0f;
                    break;
                case 4: // 16:10
                    guiAspectRatio = 16.0f / 10.0f;
                    break;
                case 5: // 16:9
                    guiAspectRatio = 16.0f / 9.0f;
                    break;
                case 6: // 21:9
                    guiAspectRatio = 21.0f / 9.0f;
                    break;
            }
            CallDeferred("UpdateContainer");
        }

        private void OnResized()
        {
            CallDeferred("UpdateContainer");
        }

        private void OnGuiMarginDragEnded(float valueChanged)
        {
            guiMargin = (float)GetNode<HSlider>("Panel/AspectRatioContainer/Panel/CenterContainer/Options/GUIMargin/HSlider").Value;
            GetNode<Label>("Panel/AspectRatioContainer/Panel/CenterContainer/Options/GUIMargin/Value").Text = guiMargin.ToString();
            CallDeferred("UpdateContainer");
        }

        private void OnWindowBaseSizeItemSelected(int index)
        {
            Vector2I baseWindowSize;
            switch (index)
            {
                case 0: // 648×648 (1:1)
                    baseWindowSize = new Vector2I(648, 648);
                    break;
                case 1: // 640×480 (4:3)
                    baseWindowSize = new Vector2I(640, 480);
                    break;
                case 2: // 720×480 (3:2)
                    baseWindowSize = new Vector2I(720, 480);
                    break;
                case 3: // 800×600 (4:3)
                    baseWindowSize = new Vector2I(800, 600);
                    break;
                case 4: // 1152×648 (16:9)
                    baseWindowSize = new Vector2I(1152, 648);
                    break;
                case 5: // 1280×720 (16:9)
                    baseWindowSize = new Vector2I(1280, 720);
                    break;
                case 6: // 1280×800 (16:10)
                    baseWindowSize = new Vector2I(1280, 800);
                    break;
                case 7: // 1680×720 (21:9)
                    baseWindowSize = new Vector2I(1680, 720);
                    break;
                default:
                    GD.Print("Invalid index selected");
                    return;
            }

            GetViewport().GetWindow().ContentScaleSize = baseWindowSize;
            CallDeferred("UpdateContainer");
        }

        private void OnWindowStretchModeItemSelected(int index)
        {
            stretchMode = (Window.ContentScaleModeEnum)index;
            GetViewport().GetWindow().ContentScaleMode = stretchMode;

            // Disable irrelevant options when the stretch mode is Disabled.
            GetNode<OptionButton>("Panel/AspectRatioContainer/Panel/CenterContainer/Options/WindowBaseSize/OptionButton").Disabled =
                stretchMode == Window.ContentScaleModeEnum.Disabled;
            GetNode<OptionButton>("Panel/AspectRatioContainer/Panel/CenterContainer/Options/WindowStretchAspect/OptionButton").Disabled =
                stretchMode == Window.ContentScaleModeEnum.Disabled;
        }

        private void OnWindowStretchAspectItemSelected(int index)
        {
            stretchAspect = (Window.ContentScaleAspectEnum)index;
            GetViewport().GetWindow().ContentScaleAspect = stretchAspect;
        }

        private void OnWindowScaleFactorDragEnded(float valueChanged)
        {
            scaleFactor = (float)GetNode<HSlider>("Panel/AspectRatioContainer/Panel/CenterContainer/Options/WindowScaleFactor/HSlider").Value;
            GetNode<Label>("Panel/AspectRatioContainer/Panel/CenterContainer/Options/WindowScaleFactor/Value").Text = string.Format("{0}%", scaleFactor * 100);
            GetViewport().GetWindow().ContentScaleFactor = scaleFactor;
        }

        private void OnWindowStretchScaleModeItemSelected(int index)
        {
            GetViewport().GetWindow().ContentScaleStretch = (Window.ContentScaleStretchEnum)index;
        }
    }
}

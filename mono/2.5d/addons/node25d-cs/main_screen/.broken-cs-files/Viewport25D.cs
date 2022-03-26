using Godot;

// This is identical to the GDScript version, yet it doesn't work.
[Tool]
public partial class Viewport25D : Control
{
    private int zoomLevel = 0;
    private bool isPanning = false;
    private Vector2 panCenter;
    private Vector2 viewportCenter;
    private int viewModeIndex = 0;

    // The type or namespace name 'EditorInterface' could not be found (are you missing a using directive or an assembly reference?)
    // No idea why this error shows up in VS Code. It builds fine...
    public EditorInterface editorInterface; // Set in node25d_plugin.gd
    private bool moving = false;

    private SubViewport viewport2d;
    private SubViewport viewportOverlay;
    private ButtonGroup viewModeButtonGroup;
    private Label zoomLabel;
    private PackedScene gizmo25dScene;

    public async override void _Ready()
    {
        // Give Godot a chance to fully load the scene. Should take two frames.
        await ToSignal(GetTree(), "idle_frame");
        await ToSignal(GetTree(), "idle_frame");
        var editedSceneRoot = GetTree().EditedSceneRoot;
        if (editedSceneRoot == null)
        {
            // Godot hasn't finished loading yet, so try loading the plugin again.
            //editorInterface.SetPluginEnabled("node25d", false);
            //editorInterface.SetPluginEnabled("node25d", true);
            return;
        }
        // Alright, we're loaded up. Now check if we have a valid world and assign it.
        var world2d = editedSceneRoot.GetViewport().World2d;
        if (world2d == GetViewport().World2d)
        {
            return; // This is the MainScreen25D scene opened in the editor!
        }
        viewport2d.World2d = world2d;

        // Onready vars.
        viewport2d = GetNode<SubViewport>("Viewport2D");
        viewportOverlay = GetNode<SubViewport>("ViewportOverlay");
        viewModeButtonGroup = GetParent().GetNode("TopBar").GetNode("ViewModeButtons").GetNode<Button>("45Degree").Group;
        zoomLabel = GetParent().GetNode("TopBar").GetNode("Zoom").GetNode<Label>("ZoomPercent");
        gizmo25dScene = ResourceLoader.Load<PackedScene>("res://addons/node25d/main_screen/gizmo_25d.tscn");
    }


    public override void _Process(float delta)
    {
        if (editorInterface == null) // Something's not right... bail!
        {
            return;
        }

        // View mode polling.
        var viewModeChangedThisFrame = false;
        var newViewMode = viewModeButtonGroup.GetPressedButton().GetIndex();
        if (viewModeIndex != newViewMode)
        {
            viewModeIndex = newViewMode;
            viewModeChangedThisFrame = true;
            RecursiveChangeViewMode(GetTree().EditedSceneRoot);
        }

        // Zooming.
        if (Input.IsMouseButtonPressed((int)MouseButton.WheelUp))
        {
            zoomLevel += 1;
        }
        else if (Input.IsMouseButtonPressed((int)MouseButton.WheelDown))
        {
            zoomLevel -= 1;
        }
        float zoom = GetZoomAmount();

        // SubViewport size.
        Vector2 size = GetGlobalRect().Size;
        viewport2d.Size = size;

        // SubViewport transform.
        Transform2D viewportTrans = Transform2D.Identity;
        viewportTrans.x *= zoom;
        viewportTrans.y *= zoom;
        viewportTrans.origin = viewportTrans.BasisXform(viewportCenter) + size / 2;
        viewport2d.CanvasTransform = viewportTrans;
        viewportOverlay.CanvasTransform = viewportTrans;

        // Delete unused gizmos.
        var selection = editorInterface.GetSelection().GetSelectedNodes();
        var overlayChildren = viewportOverlay.GetChildren();
        foreach (Gizmo25D overlayChild in overlayChildren)
        {
            bool contains = false;
            foreach (Node selected in selection)
            {
                if (selected == overlayChild.node25d && !viewModeChangedThisFrame)
                {
                    contains = true;
                }
            }
            if (!contains)
            {
                overlayChild.QueueFree();
            }
        }
        // Add new gizmos.
        foreach (Node sel in selection)
        {
            if (sel is Node25D selected)
            {
                var newNode = true;
                foreach (Gizmo25D overlayChild2 in overlayChildren)
                {
                    if (selected == overlayChild2.node25d)
                    {
                        newNode = false;
                    }
                }
                if (newNode)
                {
                    Gizmo25D gizmo = (Gizmo25D)gizmo25dScene.Instantiate();
                    viewportOverlay.AddChild(gizmo);
                    gizmo.node25d = selected;
                    gizmo.Initialize();
                }
            }
        }
    }

    // This only accepts input when the mouse is inside of the 2.5D viewport.
    public override void _GuiInput(InputEvent inputEvent)
    {
        if (inputEvent is InputEventMouseButton mouseButtonEvent)
        {
            if (mouseButtonEvent.IsPressed())
            {
                if ((MouseButton)mouseButtonEvent.ButtonIndex == MouseButton.WheelUp)
                {
                    zoomLevel += 1;
                    AcceptEvent();
                }
                else if ((MouseButton)mouseButtonEvent.ButtonIndex == MouseButton.WheelDown)
                {
                    zoomLevel -= 1;
                    AcceptEvent();
                }
                else if ((MouseButton)mouseButtonEvent.ButtonIndex == MouseButton.Middle)
                {
                    isPanning = true;
                    panCenter = viewportCenter - mouseButtonEvent.Position;
                    AcceptEvent();
                }
                else if ((MouseButton)mouseButtonEvent.ButtonIndex == MouseButton.Left)
                {
                    var overlayChildren2 = viewportOverlay.GetChildren();
                    foreach (Gizmo25D overlayChild in overlayChildren2)
                    {
                        overlayChild.wantsToMove = true;
                    }
                    AcceptEvent();
                }
            }
            else if ((MouseButton)mouseButtonEvent.ButtonIndex == MouseButton.Middle)
            {
                isPanning = false;
                AcceptEvent();
            }
            else if ((MouseButton)mouseButtonEvent.ButtonIndex == MouseButton.Left)
            {
                var overlayChildren3 = viewportOverlay.GetChildren();
                foreach (Gizmo25D overlayChild in overlayChildren3)
                {
                    overlayChild.wantsToMove = false;
                }
                AcceptEvent();
            }
        }
        else if (inputEvent is InputEventMouseMotion mouseEvent)
        {
            if (isPanning)
            {
                viewportCenter = panCenter + mouseEvent.Position;
                AcceptEvent();
            }
        }
    }

    public void RecursiveChangeViewMode(Node currentNode)
    {
        // TODO
        if (currentNode.HasMethod("SetViewMode"))
        {
            //currentNode.SetViewMode(viewModeIndex);
        }
        foreach (Node child in currentNode.GetChildren())
        {
            RecursiveChangeViewMode(child);
        }
    }

    private float GetZoomAmount()
    {
        float zoomAmount = Mathf.Pow(1.05476607648f, zoomLevel); // 13th root of 2
        zoomLabel.Text = Mathf.Round(zoomAmount * 1000) / 10 + "%";
        return zoomAmount;
    }

    public void OnZoomOutPressed()
    {
        zoomLevel -= 1;
    }

    public void OnZoomInPressed()
    {
        zoomLevel += 1;
    }

    public void OnZoomResetPressed()
    {
        zoomLevel = 0;
    }
}

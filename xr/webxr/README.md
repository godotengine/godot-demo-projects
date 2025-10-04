# WebXR demo

This is a minimal demo of WebXR rendering and controller support.

When exporting to the Web platform, make sure to include the WebXR Polyfill and WebXR Layers Polyfill which will fill holes in web browsers' WebXR support.
To include these polyfills, open the **Export** window and copy the following code into the `Head Include` field of the Web export preset:

```html
<script src="https://cdn.jsdelivr.net/npm/webxr-polyfill@latest/build/webxr-polyfill.min.js"></script>
<script>
var polyfill = new WebXRPolyfill();
</script>
<script src="https://cdn.jsdelivr.net/npm/webxr-layers-polyfill@latest/build/webxr-layers-polyfill.min.js"></script>
<script>
var layersPolyfill = new WebXRLayersPolyfill();
</script>
```

Language: GDScript

Renderer: Compatibility

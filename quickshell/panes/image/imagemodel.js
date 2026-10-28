// quickshell/panes/image/imagemodel.js
// What the image viewer computes, with no QML in it: the path a payload
// names, the folder around it, which files are images, and the zoom and
// pan the viewport may take. Kept pure so it can be tested headless.
.pragma library

// The extensions the folder is filtered by, so h and l step over images
// only. Qt decodes these itself, except WebP and TIFF: those need
// qtimageformats, which the Home Manager module puts on the shell's
// plugin path.
var EXTENSIONS = ["png", "jpg", "jpeg", "gif", "bmp", "svg", "ico", "webp", "tif", "tiff"];

// Played as an animation instead of drawn once.
var ANIMATED = ["gif"];

function nameFilters() {
    var out = [];
    for (var i = 0; i < EXTENSIONS.length; i++) {
        out.push("*." + EXTENSIONS[i]);
        out.push("*." + EXTENSIONS[i].toUpperCase());
    }
    return out;
}

function extension(path) {
    var name = basename(path);
    var dot = name.lastIndexOf(".");
    return dot <= 0 ? "" : name.slice(dot + 1).toLowerCase();
}

function isAnimated(path) {
    return ANIMATED.indexOf(extension(path)) >= 0;
}

// A payload path may arrive as a file:// URI (xdg-open hands some apps
// one) or with a leading ~; the viewer wants a plain absolute path.
function toPath(arg, home) {
    var p = String(arg || "").trim();
    if (p.indexOf("file://") === 0) {
        p = p.slice("file://".length);
        try {
            p = decodeURIComponent(p);
        } catch (e) {}
    }
    if (p === "~" || p.indexOf("~/") === 0)
        p = home + p.slice(1);
    return p;
}

// The URL an Image loads: each segment escaped, so a # or ? in a name is
// part of the name and not the start of a fragment or a query.
function toUrl(path) {
    if (path === "")
        return "";
    return "file://" + path.split("/").map(encodeURIComponent).join("/");
}

function dirname(path) {
    var slash = path.lastIndexOf("/");
    return slash <= 0 ? "/" : path.slice(0, slash);
}

function basename(path) {
    return path.slice(path.lastIndexOf("/") + 1);
}

// The scale that fits an image of iw×ih into vw×vh. A small image stays at
// its own size: blowing it up only shows its pixels.
function fitScale(iw, ih, vw, vh) {
    if (iw <= 0 || ih <= 0 || vw <= 0 || vh <= 0)
        return 1;
    return Math.min(1, vw / iw, vh / ih);
}

function clampZoom(zoom, max) {
    return Math.max(1, Math.min(zoom, max));
}

// How far the image may move off centre on one axis: half of what spills
// past the viewport, so an edge never comes inside it.
function clampPan(offset, shown, view) {
    var room = Math.max(0, (shown - view) / 2);
    return Math.max(-room, Math.min(offset, room));
}

// The neighbour `step` away in a folder of `count`, wrapping round.
function step(index, count, by) {
    if (count <= 0)
        return -1;
    return ((index + by) % count + count) % count;
}

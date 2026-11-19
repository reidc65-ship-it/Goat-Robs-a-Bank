#!/usr/bin/env python3
"""Build the player (goat) animation sprites from the concept sheet.

The concept sheet in design/goat_concept_sheet.png holds one drawn pose per
state (Idle, Run, Jump, Throw Horns, Hurt). This script:

  1. cuts each pose out of the sheet and removes the paper background,
  2. rigs the pose (leg pairs, tail) and generates the in-between frames,
  3. writes GameMaker sprite resources + frame PNGs,
  4. registers the new sprites in the .yyp.

Run it from the project root:

    python3 tools/build_player_animations.py

Re-running is safe: resource ids are derived from the sprite name, so the
generated .yy files and PNG names stay stable.
"""

import json
import math
import os
import re
import uuid
from collections import deque

import numpy as np
from PIL import Image

# --------------------------------------------------------------------------
# Config
# --------------------------------------------------------------------------
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SHEET = os.path.join(ROOT, "design", "goat_concept_sheet.png")
PREVIEW = os.path.join(ROOT, "design", "player_animation_preview.png")
YPP = os.path.join(ROOT, "Goat Robs a Bank.yyp")

# Poses on the sheet, in sheet pixel coordinates (left, top, right, bottom).
POSES = {
    "idle":  (11, 44, 96, 122),
    "run":   (110, 44, 200, 122),
    "jump":  (224, 17, 313, 122),
    "throw": (337, 41, 424, 122),
    "horn":  (430, 53, 508, 81),
    "hurt":  (520, 16, 614, 122),
}

CANVAS_W = CANVAS_H = 128
BASELINE = 120          # feet sit here in sprite space
ORIGIN = (64, 90)       # sprite origin; mask bottom lands at origin.y + 30
# The sheet is drawn at a larger scale than the rest of the cast. 0.8 lands
# the goat at roughly the old player size while keeping the linework readable.
SOURCE_SCALE = 0.8

# The belly line, normalised to each pose's bounding box. The legs are cut
# along this line so they can swing without tearing the torso.
BELLY = [(0.00, 0.795), (0.10, 0.833), (0.21, 0.846), (0.33, 0.846),
         (0.40, 0.821), (0.52, 0.821), (0.61, 0.808), (0.68, 0.782),
         (1.00, 0.782)]
HIP_BACK = (0.20, 0.808)
HIP_FRONT = (0.53, 0.795)
SPLIT = 0.365
TAIL_BOX = (0.00, 0.36, 0.20, 0.68)
TAIL_PIVOT = (0.15, 0.45)

FPS = {"idle": 7, "walk": 12, "run": 16, "jump": 12, "throw": 14, "hurt": 10}
FPS_HORN = 30

# Stable uuids so re-running the script doesn't churn the project.
NS = uuid.UUID("6f2c1b1e-9a55-4a7a-9d55-3f0c7d1c2a10")


def stable_id(*parts):
    return str(uuid.uuid5(NS, "/".join(parts)))


# --------------------------------------------------------------------------
# Concept sheet -> pose cutouts
# --------------------------------------------------------------------------
def bleed_edges(img, passes=4):
    """Push opaque colour into the transparent margin.

    Without this a plain resize blends the light paper colour into the
    silhouette and leaves a pale halo around the goat.
    """
    a = np.array(img)
    rgb = a[:, :, :3].astype(np.float32)
    al = a[:, :, 3]
    known = al > 0
    for _ in range(passes):
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            shifted_known = np.roll(known, (dy, dx), axis=(0, 1))
            shifted_rgb = np.roll(rgb, (dy, dx), axis=(0, 1))
            take = (~known) & shifted_known
            rgb[take] = shifted_rgb[take]
            known |= take
    # alpha is deliberately untouched: this only fills colour under the
    # transparent margin so the resize has something sensible to sample.
    return Image.fromarray(np.dstack([rgb.clip(0, 255), al]).astype(np.uint8), "RGBA")


def resize_rgba(img, factor):
    if factor == 1.0:
        return img
    img = bleed_edges(img)
    w = max(1, round(img.width * factor))
    h = max(1, round(img.height * factor))
    return img.resize((w, h), Image.LANCZOS)


def extract(box):
    """Crop one pose and knock out the paper background + drop shadow."""
    sheet = Image.open(SHEET).convert("RGBA")
    im = sheet.crop(box)
    a = np.array(im).astype(np.int16)
    bright = a[:, :, :3].max(axis=2)
    sat = a[:, :, :3].max(axis=2) - a[:, :, :3].min(axis=2)
    # Paper is bright with almost no colour; the shadow is a slightly darker
    # grey with low saturation. Both are flood filled from the border so
    # interior highlights (eyes, belly) are never touched.
    bglike = (sat <= 12) & (bright >= 185)
    h, w = bglike.shape
    trans = np.zeros((h, w), bool)
    dq = deque()
    for x in range(w):
        for y in (0, h - 1):
            if bglike[y, x]:
                trans[y, x] = True
                dq.append((y, x))
    for y in range(h):
        for x in (0, w - 1):
            if bglike[y, x] and not trans[y, x]:
                trans[y, x] = True
                dq.append((y, x))
    while dq:
        y, x = dq.popleft()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < h and 0 <= nx < w and bglike[ny, nx] and not trans[ny, nx]:
                trans[ny, nx] = True
                dq.append((ny, nx))

    alpha = np.where(trans, 0, 255).astype(np.uint8)
    # Soften the outermost anti-aliased pixels so the cutout doesn't look
    # like it was done with scissors.
    light = (bright >= 205) & (sat <= 26)
    for y in range(1, h - 1):
        for x in range(1, w - 1):
            if alpha[y, x] and light[y, x] and (
                not alpha[y - 1, x] or not alpha[y + 1, x]
                or not alpha[y, x - 1] or not alpha[y, x + 1]
            ):
                alpha[y, x] = 130

    out = a.astype(np.uint8).copy()
    out[:, :, 3] = alpha
    img = Image.fromarray(out, "RGBA")
    img = img.crop(img.getbbox())
    return resize_rgba(img, SOURCE_SCALE)


# --------------------------------------------------------------------------
# Pixel helpers
# --------------------------------------------------------------------------
def shift(img, dx=0, dy=0):
    a = np.array(img)
    out = np.zeros_like(a)
    h, w = a.shape[:2]
    x0, x1 = max(0, dx), min(w, w + dx)
    y0, y1 = max(0, dy), min(h, h + dy)
    if x1 > x0 and y1 > y0:
        out[y0:y1, x0:x1] = a[y0 - dy:y1 - dy, x0 - dx:x1 - dx]
    return Image.fromarray(out, "RGBA")


def rot(piece, angle, pivot):
    return piece.rotate(angle, resample=Image.BICUBIC, center=pivot)


def despeckle(img, min_area=10):
    """Drop tiny floating islands left behind by the leg cut."""
    a = np.array(img)
    al = a[:, :, 3] > 0
    h, w = al.shape
    seen = np.zeros_like(al)
    keep = np.zeros_like(al)
    for sy in range(h):
        for sx in range(w):
            if not al[sy, sx] or seen[sy, sx]:
                continue
            stack = [(sy, sx)]
            seen[sy, sx] = True
            comp = []
            while stack:
                y, x = stack.pop()
                comp.append((y, x))
                for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    ny, nx = y + dy, x + dx
                    if 0 <= ny < h and 0 <= nx < w and al[ny, nx] and not seen[ny, nx]:
                        seen[ny, nx] = True
                        stack.append((ny, nx))
            if len(comp) >= min_area:
                for y, x in comp:
                    keep[y, x] = True
    a[:, :, 3] = np.where(keep, a[:, :, 3], 0)
    return Image.fromarray(a, "RGBA")


def split_legs(img):
    """Return (torso, legs, contour_fn) cut along the belly outline."""
    a = np.array(img)
    h, w = a.shape[:2]
    pts = sorted((xf * w, yf * h) for xf, yf in BELLY)

    def cy(x):
        if x <= pts[0][0]:
            return pts[0][1]
        for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
            if x0 <= x <= x1:
                t = (x - x0) / max(1e-6, x1 - x0)
                return y0 + t * (y1 - y0)
        return pts[-1][1]

    def is_dark(px):
        return px[3] > 0 and px[:3].max() < 95

    cuts = []
    for x in range(w):
        c = int(round(cy(x)))
        y = min(c, h - 1)
        while y > 0 and not is_dark(a[y, x]):
            y -= 1
        cut = y + 1 if is_dark(a[y, x]) else c
        cuts.append(max(c - 4, min(c + 4, cut)))

    sm = []
    for x in range(w):
        win = sorted(cuts[max(0, x - 2):min(w, x + 3)])
        sm.append(win[len(win) // 2])

    torso = a.copy()
    legs = a.copy()
    for x in range(w):
        cut = sm[x]
        legs[:cut, x] = 0
        torso[cut:, x] = 0
    return Image.fromarray(torso, "RGBA"), Image.fromarray(legs, "RGBA"), sm


def tuck_legs(legs, cuts, rows=5):
    """Extend the leg tops upward so they slide behind the torso."""
    a = np.array(legs)
    h, w = a.shape[:2]
    out = a.copy()
    for x in range(w):
        c = cuts[x]
        if c < h:
            src = a[min(h - 1, c)]
            for k in range(1, rows + 1):
                y = c - k
                if 0 <= y < h:
                    out[y, x] = src[x]
    return Image.fromarray(out, "RGBA")


def band(piece, x0f, x1f):
    a = np.array(piece)
    w = a.shape[1]
    x0, x1 = int(x0f * w), int(x1f * w)
    a[:, :x0] = 0
    a[:, x1:] = 0
    return Image.fromarray(a, "RGBA")


# --------------------------------------------------------------------------
# Animation rig
# --------------------------------------------------------------------------
def gait(base, frames):
    """Animate a pose. Each entry: back/front angle + optional dx/dy."""
    torso, legs, cuts = split_legs(base)
    legs = tuck_legs(legs, cuts)
    w, h = base.size
    pb = (HIP_BACK[0] * w, HIP_BACK[1] * h)
    pf = (HIP_FRONT[0] * w, HIP_FRONT[1] * h)
    back = band(legs, 0.0, SPLIT)
    front = band(legs, SPLIT, 1.0)

    out = []
    for f in frames:
        rb = shift(rot(back, f.get("back", 0), pb), f.get("bdx", 0), f.get("bdy", 0))
        rf = shift(rot(front, f.get("front", 0), pf), f.get("fdx", 0), f.get("fdy", 0))
        composed = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        composed.alpha_composite(rb)
        composed.alpha_composite(rf)
        composed.alpha_composite(shift(torso, 0, f.get("udy", 0)))
        out.append(shift(composed, 0, f.get("dy", 0)))
    return out


def tail_sway(base, angle):
    a = np.array(base)
    h, w = a.shape[:2]
    x0, y0, x1, y1 = TAIL_BOX
    tail = np.zeros_like(a)
    tail[int(y0 * h):int(y1 * h), int(x0 * w):int(x1 * w)] = \
        a[int(y0 * h):int(y1 * h), int(x0 * w):int(x1 * w)]
    rotated = rot(Image.fromarray(tail, "RGBA"), angle,
                  (TAIL_PIVOT[0] * w, TAIL_PIVOT[1] * h))
    body = a.copy()
    body[int(y0 * h):int(y1 * h), int(x0 * w):int(x1 * w)] = 0
    out = Image.fromarray(body, "RGBA")
    out.alpha_composite(rotated)
    return out


def to_canvas(img):
    img = despeckle(img)
    c = Image.new("RGBA", (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    x = int(round(ORIGIN[0] - img.width / 2))
    y = int(round(BASELINE - img.height))
    c.alpha_composite(img, (x, y))
    return c


def build_animations(src):
    idle, run, jump = src["idle"], src["run"], src["jump"]
    throw, hurt = src["throw"], src["hurt"]

    # --- idle: breathing bob + tail flick ---
    idle_frames = []
    for i in range(4):
        t = i / 4 * 2 * math.pi
        f = tail_sway(idle, 7 * math.sin(t))
        idle_frames.append(to_canvas(shift(f, 0, [0, -1, -1, 0][i])))

    # --- walk: two-beat gait, short strides ---
    walk_frames = []
    for i in range(6):
        s = math.sin(i / 6 * 2 * math.pi)
        walk_frames.append(to_canvas(gait(idle, [{
            "back": 16 * s, "front": -16 * s,
            "bdx": round(4 * s), "fdx": round(-4 * s),
            "bdy": -2 if s > 0.3 else 0, "fdy": -2 if s < -0.3 else 0,
            "dy": [0, -1, -1, 0, 0, -1][i],
        }])[0]))

    # --- run: longer stride, higher lift, bigger bounce ---
    run_frames = []
    for i in range(6):
        s = math.sin(i / 6 * 2 * math.pi)
        run_frames.append(to_canvas(gait(run, [{
            "back": 24 * s, "front": -24 * s,
            "bdx": round(6 * s), "fdx": round(-6 * s),
            "bdy": -4 if s > 0.3 else 0, "fdy": -4 if s < -0.3 else 0,
            "dy": [0, -2, -2, 0, 0, -2][i],
        }])[0]))

    # --- jump: crouch, launch, tuck, reach ---
    # Crouch and launch keep the hooves planted; the apex and fall are
    # airborne, so the legs are free to tuck and reach.
    jump_frames = [
        gait(jump, [{"udy": 5}])[0],
        gait(jump, [{"udy": -2}])[0],
        gait(jump, [{"back": 12, "front": -12, "bdy": -6, "fdy": -6}])[0],
        gait(jump, [{"back": -12, "front": 12, "bdy": 1, "fdy": 1, "udy": 1}])[0],
    ]
    jump_frames = [to_canvas(f) for f in jump_frames]

    # --- throw: wind up, release, follow through, settle, idle ---
    throw_frames = [to_canvas(f) for f in (
        shift(idle, 2, 0),
        shift(throw, -1, -1),
        shift(throw, -2, 0),
        shift(throw, 0, 0),
        idle,
    )]

    # --- hurt: hit pose + a 2px knock shake ---
    hurt_frames = [to_canvas(hurt), to_canvas(shift(hurt, 2, 0))]

    return {
        "idle": idle_frames,
        "walk": walk_frames,
        "run": run_frames,
        "jump": jump_frames,
        "throw": throw_frames,
        "hurt": hurt_frames,
    }


# --------------------------------------------------------------------------
# GameMaker resource writer
# --------------------------------------------------------------------------
def sprite_yy(name, frames, fps):
    """Build a GMSprite .yy document matching GameMaker 2024/2025's format."""
    w, h = frames[0].size
    bbox = None
    for f in frames:
        b = f.getbbox()
        if not b:
            continue
        bbox = b if bbox is None else (
            min(bbox[0], b[0]), min(bbox[1], b[1]),
            max(bbox[2], b[2]), max(bbox[3], b[3]))
    if bbox is None:
        bbox = (0, 0, w, h)
    left, top, right, bottom = bbox[0], bbox[1], bbox[2] - 1, bbox[3] - 1

    frame_ids = [stable_id(name, "frame", str(i)) for i in range(len(frames))]
    layer_id = stable_id(name, "layer")

    keyframes = []
    for i, fid in enumerate(frame_ids):
        keyframes.append({
            "$Keyframe<SpriteFrameKeyframe>": "",
            "Channels": {
                "0": {
                    "$SpriteFrameKeyframe": "",
                    "Id": {"name": fid, "path": f"sprites/{name}/{name}.yy"},
                    "resourceType": "SpriteFrameKeyframe",
                    "resourceVersion": "2.0",
                }
            },
            "Disabled": False,
            "id": stable_id(name, "key", str(i)),
            "IsCreationKey": False,
            "Key": float(i),
            "Length": 1.0,
            "resourceType": "Keyframe<SpriteFrameKeyframe>",
            "resourceVersion": "2.0",
            "Stretch": False,
        })

    doc = {
        "$GMSprite": "v2",
        "%Name": name,
        "bboxMode": 0,
        "bbox_bottom": bottom,
        "bbox_left": left,
        "bbox_right": right,
        "bbox_top": top,
        "collisionKind": 1,
        "collisionTolerance": 0,
        "DynamicTexturePage": False,
        "edgeFiltering": False,
        "For3D": False,
        "frames": [
            {"$GMSpriteFrame": "v1", "%Name": fid, "name": fid,
             "resourceType": "GMSpriteFrame", "resourceVersion": "2.0"}
            for fid in frame_ids
        ],
        "gridX": 0,
        "gridY": 0,
        "height": h,
        "HTile": False,
        "layers": [
            {"$GMImageLayer": "", "%Name": layer_id, "blendMode": 0,
             "displayName": "default", "isLocked": False, "name": layer_id,
             "opacity": 100.0, "resourceType": "GMImageLayer",
             "resourceVersion": "2.0", "visible": True}
        ],
        "name": name,
        "nineSlice": None,
        "origin": 4,
        "parent": {"name": "Goat Robs a Bank", "path": "Goat Robs a Bank.yyp"},
        "preMultiplyAlpha": False,
        "resourceType": "GMSprite",
        "resourceVersion": "2.0",
        "sequence": {
            "$GMSequence": "v1",
            "%Name": name,
            "autoRecord": True,
            "backdropHeight": 768,
            "backdropImageOpacity": 0.5,
            "backdropImagePath": "",
            "backdropWidth": 1366,
            "backdropXOffset": 0.0,
            "backdropYOffset": 0.0,
            "events": {
                "$KeyframeStore<MessageEventKeyframe>": "",
                "Keyframes": [],
                "resourceType": "KeyframeStore<MessageEventKeyframe>",
                "resourceVersion": "2.0",
            },
            "eventStubScript": None,
            "eventToFunction": {},
            "length": float(len(frames)),
            "lockOrigin": False,
            "moments": {
                "$KeyframeStore<MomentsEventKeyframe>": "",
                "Keyframes": [],
                "resourceType": "KeyframeStore<MomentsEventKeyframe>",
                "resourceVersion": "2.0",
            },
            "name": name,
            "playback": 1,
            "playbackSpeed": float(fps),
            "playbackSpeedType": 0,
            "resourceType": "GMSequence",
            "resourceVersion": "2.0",
            "showBackdrop": True,
            "showBackdropImage": False,
            "timeUnits": 1,
            "tracks": [{
                "$GMSpriteFramesTrack": "",
                "builtinName": 0,
                "events": [],
                "inheritsTrackColour": True,
                "interpolation": 1,
                "isCreationTrack": False,
                "keyframes": {
                    "$KeyframeStore<SpriteFrameKeyframe>": "",
                    "Keyframes": keyframes,
                    "resourceType": "KeyframeStore<SpriteFrameKeyframe>",
                    "resourceVersion": "2.0",
                },
                "modifiers": [],
                "name": "frames",
                "resourceType": "GMSpriteFramesTrack",
                "resourceVersion": "2.0",
                "spriteId": None,
                "trackColour": 0,
                "tracks": [],
                "traits": 0,
            }],
            "visibleRange": None,
            "volume": 1.0,
            "xorigin": ORIGIN[0],
            "yorigin": ORIGIN[1],
        },
        "swatchColours": None,
        "swfPrecision": 0.5,
        "textureGroupId": {"name": "Default", "path": "texturegroups/Default"},
        "type": 0,
        "VTile": False,
        "width": w,
    }
    return doc, frame_ids, layer_id


def write_sprite(name, frames, fps):
    doc, frame_ids, layer_id = sprite_yy(name, frames, fps)
    base = os.path.join(ROOT, "sprites", name)
    os.makedirs(os.path.join(base, "layers"), exist_ok=True)
    with open(os.path.join(base, f"{name}.yy"), "w") as fh:
        json.dump(doc, fh, indent=2)
        fh.write("\n")
    for fid, img in zip(frame_ids, frames):
        png = os.path.join(base, f"{fid}.png")
        img.save(png)
        layer_dir = os.path.join(base, "layers", fid)
        os.makedirs(layer_dir, exist_ok=True)
        img.save(os.path.join(layer_dir, f"{layer_id}.png"))


def register_in_project(names):
    """Insert any missing sprite entries textually.

    A full json load/dump would reformat the whole project file, which makes
    for a noisy diff every time the script runs, so this edits the text in
    place right after the last sprite entry.
    """
    text = open(YPP).read()
    missing = [n for n in names if f'"name": "{n}"' not in text]
    if not missing:
        return
    entries = "".join(
        '    {\n'
        '      "id": {\n'
        f'        "name": "{n}",\n'
        f'        "path": "sprites/{n}/{n}.yy"\n'
        '      }\n'
        '    },\n'
        for n in sorted(missing)
    )
    anchor = text.rfind('"path": "sprites/sWolfCop/sWolfCop.yy"')
    if anchor == -1:
        raise RuntimeError("could not find the sprite block in the .yyp")
    insert_at = text.index("    {\n", anchor)
    text = text[:insert_at] + entries + text[insert_at:]
    open(YPP, "w").write(text)


def replace_horn():
    """Swap the flat white horn for the golden boomerang from the sheet."""
    src = extract(POSES["horn"])
    canvas = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    x = 32 - src.width // 2
    y = 33 - src.height // 2
    canvas.alpha_composite(src, (x, y))
    base = os.path.join(ROOT, "sprites", "Horn")
    frame = "81e58614-0861-4977-8763-cadceddb9394"
    layer = "7c9728c8-80d0-481f-affa-5a685db83752"
    canvas.save(os.path.join(base, f"{frame}.png"))
    canvas.save(os.path.join(base, "layers", frame, f"{layer}.png"))
    # keep the .yy bounding box in sync with the new art
    p = os.path.join(base, "Horn.yy")
    text = open(p).read()
    b = canvas.getbbox()
    text = re.sub(r'"bbox_bottom":\s*\d+', f'"bbox_bottom": {b[3] - 1}', text)
    text = re.sub(r'"bbox_left":\s*\d+', f'"bbox_left": {b[0]}', text)
    text = re.sub(r'"bbox_right":\s*\d+', f'"bbox_right": {b[2] - 1}', text)
    text = re.sub(r'"bbox_top":\s*\d+', f'"bbox_top": {b[1]}', text)
    open(p, "w").write(text)
    return canvas


def write_preview(anims):
    cols = max(len(f) for f in anims.values())
    rows = list(anims.values())
    sheet = Image.new("RGBA", (CANVAS_W * cols, CANVAS_H * len(rows)),
                      (246, 249, 251, 255))
    for r, frames in enumerate(rows):
        for i, frame in enumerate(frames):
            sheet.alpha_composite(frame, (i * CANVAS_W, r * CANVAS_H))
    sheet.resize((sheet.width * 2, sheet.height * 2), Image.NEAREST).save(PREVIEW)

    # Looping gif of every state, handy for eyeballing timing without
    # opening GameMaker.
    order = [("idle", 3), ("walk", 2), ("run", 2), ("jump", 1),
             ("throw", 1), ("hurt", 1)]
    gif = []
    for state, loops in order:
        for _ in range(loops):
            for frame in anims[state]:
                c = Image.new("RGBA", (CANVAS_W, CANVAS_H), (246, 249, 251, 255))
                c.alpha_composite(frame)
                gif.append(c.convert("RGB").resize(
                    (CANVAS_W * 2, CANVAS_H * 2), Image.NEAREST))
    gif[0].save(PREVIEW.replace(".png", ".gif"), save_all=True,
                append_images=gif[1:], duration=90, loop=0)


def main():
    src = {k: extract(v) for k, v in POSES.items()}
    anims = build_animations(src)
    for name, frames in anims.items():
        write_sprite(("sGoat" + name.capitalize()), frames, FPS[name])
    replace_horn()
    register_in_project(["sGoat" + n.capitalize() for n in anims])
    write_preview(anims)
    for name, frames in anims.items():
        print(f"  sGoat{name.capitalize():<6} {len(frames)} frames")


if __name__ == "__main__":
    main()

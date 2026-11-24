#!/usr/bin/env python3
"""Build the training scarecrow sprite and object used by the barn tutorial.

The scarecrow is a one-off prop for the Scout's dash lesson: it stands in
front of the barn until the player dashes through it. The art is drawn here
so it stays in the project's palette and can be regenerated.

Run from the project root:

    python3 tools/build_scarecrow.py
"""

import json
import os
import uuid

from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
YPP = os.path.join(ROOT, "Goat Robs a Bank.yyp")

W, H = 64, 96
ORIGIN = (32, 94)

OUT = (26, 18, 14, 255)
WOOD_D = (74, 48, 32, 255)
WOOD = (122, 84, 50, 255)
WOOD_L = (158, 114, 68, 255)
STRAW_D = (176, 132, 54, 255)
STRAW = (224, 182, 86, 255)
STRAW_L = (242, 212, 132, 255)
BURLAP_D = (150, 112, 68, 255)
BURLAP = (200, 162, 108, 255)
BURLAP_L = (226, 194, 146, 255)
SHIRT_D = (46, 70, 86, 255)
SHIRT = (74, 106, 124, 255)
SHIRT_L = (108, 140, 156, 255)
STITCH = (62, 42, 26, 255)

NS = uuid.UUID("6f2c1b1e-9a55-4a7a-9d55-3f0c7d1c2a10")


def stable_id(*parts):
    return str(uuid.uuid5(NS, "/".join(parts)))


def draw_scarecrow():
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    def box(x0, y0, x1, y1, fill, outline=OUT):
        d.rectangle([x0, y0, x1, y1], fill=outline)
        if x1 - x0 > 2 and y1 - y0 > 2:
            d.rectangle([x0 + 1, y0 + 1, x1 - 1, y1 - 1], fill=fill)

    def poly(points, fill):
        d.polygon(points, fill=OUT)
        cx = sum(p[0] for p in points) / len(points)
        cy = sum(p[1] for p in points) / len(points)
        inner = [(cx + (px - cx) * 0.72, cy + (py - cy) * 0.72)
                 for px, py in points]
        d.polygon(inner, fill=fill)

    # Post and crossbar, behind the body.
    box(28, 18, 36, 94, WOOD)
    d.line([(30, 22), (30, 92)], fill=WOOD_L)
    d.line([(34, 22), (34, 92)], fill=WOOD_D)
    for gy in (46, 68, 86):
        d.line([(29, gy), (35, gy)], fill=WOOD_D)

    box(8, 29, 56, 37, WOOD)
    d.line([(10, 31), (54, 31)], fill=WOOD_L)
    d.line([(10, 35), (54, 35)], fill=WOOD_D)

    # Straw bursting out behind the shoulders.
    poly([(9, 37), (2, 44), (10, 42), (3, 50), (13, 45)], STRAW)
    poly([(55, 37), (62, 44), (54, 42), (61, 50), (51, 45)], STRAW)
    poly([(19, 33), (14, 26), (22, 31), (18, 23), (26, 31)], STRAW)

    # Shirt and ragged hem.
    box(17, 34, 47, 62, SHIRT)
    d.rectangle([17, 34, 18, 38], fill=SHIRT_L)
    d.rectangle([46, 34, 47, 38], fill=SHIRT_D)
    d.polygon([(17, 55), (47, 55), (47, 62), (41, 58), (36, 63),
               (30, 58), (24, 63), (17, 59)], fill=SHIRT)
    d.line([(17, 62), (24, 63), (30, 58), (36, 63), (41, 58), (47, 62)],
           fill=OUT)
    d.line([(20, 36), (20, 55)], fill=SHIRT_L)
    d.line([(44, 36), (44, 55)], fill=SHIRT_D)

    # Sleeves and straw hands.
    box(9, 35, 19, 49, SHIRT)
    box(45, 35, 55, 49, SHIRT)
    d.line([(11, 37), (11, 47)], fill=SHIRT_L)
    d.line([(53, 37), (53, 47)], fill=SHIRT_D)
    poly([(4, 45), (11, 44), (7, 49), (13, 48), (9, 54)], STRAW)
    poly([(60, 45), (53, 44), (57, 49), (51, 48), (55, 54)], STRAW)

    # Stitched patch.
    box(34, 40, 43, 48, BURLAP)
    d.line([(36, 42), (41, 47)], fill=STITCH)
    d.line([(41, 42), (36, 47)], fill=STITCH)
    d.line([(36, 44), (41, 44)], fill=STITCH)

    # Rope belt and knot.
    box(18, 55, 46, 58, WOOD_D)
    d.line([(18, 56), (46, 56)], fill=STRAW_D)
    box(31, 54, 34, 59, WOOD_D)
    d.line([(32, 55), (32, 58)], fill=WOOD)

    # Burlap head.
    d.rounded_rectangle([23, 12, 41, 31], radius=2, fill=OUT)
    d.rounded_rectangle([24, 13, 40, 30], radius=2, fill=BURLAP)
    d.rectangle([25, 14, 39, 16], fill=BURLAP_L)
    poly([(20, 19), (15, 16), (21, 22), (14, 24), (21, 27)], STRAW)
    poly([(44, 19), (49, 16), (43, 22), (50, 24), (43, 27)], STRAW)
    box(27, 19, 29, 21, OUT)
    box(35, 19, 37, 21, OUT)
    d.line([(27, 25), (37, 25)], fill=STITCH)
    for sx in range(27, 38, 2):
        d.line([(sx, 24), (sx, 26)], fill=STITCH)
    d.line([(26, 14), (26, 28)], fill=BURLAP_D)

    # Straw hat.
    box(15, 8, 49, 12, WOOD)
    box(23, 2, 41, 8, WOOD)
    d.line([(17, 9), (47, 9)], fill=WOOD_L)
    d.line([(17, 11), (47, 11)], fill=WOOD_D)
    d.line([(25, 4), (39, 4)], fill=WOOD_L)
    d.line([(24, 6), (40, 6)], fill=STITCH)

    # Straw peeking out at the neck.
    poly([(17, 33), (22, 34), (18, 38), (24, 36)], STRAW)
    poly([(47, 33), (42, 34), (46, 38), (40, 36)], STRAW)

    return img


def sprite_yy(name, frame_id, layer_id, bbox):
    left, top, right, bottom = bbox[0], bbox[1], bbox[2] - 1, bbox[3] - 1
    return {
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
        "frames": [{
            "$GMSpriteFrame": "v1",
            "%Name": frame_id,
            "name": frame_id,
            "resourceType": "GMSpriteFrame",
            "resourceVersion": "2.0",
        }],
        "gridX": 0,
        "gridY": 0,
        "height": H,
        "HTile": False,
        "layers": [{
            "$GMImageLayer": "",
            "%Name": layer_id,
            "blendMode": 0,
            "displayName": "default",
            "isLocked": False,
            "name": layer_id,
            "opacity": 100.0,
            "resourceType": "GMImageLayer",
            "resourceVersion": "2.0",
            "visible": True,
        }],
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
            "length": 1.0,
            "lockOrigin": False,
            "moments": {
                "$KeyframeStore<MomentsEventKeyframe>": "",
                "Keyframes": [],
                "resourceType": "KeyframeStore<MomentsEventKeyframe>",
                "resourceVersion": "2.0",
            },
            "name": name,
            "playback": 1,
            "playbackSpeed": 30.0,
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
                    "Keyframes": [{
                        "$Keyframe<SpriteFrameKeyframe>": "",
                        "Channels": {
                            "0": {
                                "$SpriteFrameKeyframe": "",
                                "Id": {
                                    "name": frame_id,
                                    "path": f"sprites/{name}/{name}.yy",
                                },
                                "resourceType": "SpriteFrameKeyframe",
                                "resourceVersion": "2.0",
                            }
                        },
                        "Disabled": False,
                        "id": stable_id(name, "key"),
                        "IsCreationKey": False,
                        "Key": 0.0,
                        "Length": 1.0,
                        "resourceType": "Keyframe<SpriteFrameKeyframe>",
                        "resourceVersion": "2.0",
                        "Stretch": False,
                    }],
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
        "width": W,
    }


def object_yy():
    return {
        "$GMObject": "",
        "%Name": "oScarecrow",
        "eventList": [
            {"$GMEvent": "v1", "%Name": "", "collisionObjectId": None,
             "eventNum": 0, "eventType": 0, "isDnD": False, "name": "",
             "resourceType": "GMEvent", "resourceVersion": "2.0"},
            {"$GMEvent": "v1", "%Name": "", "collisionObjectId": None,
             "eventNum": 0, "eventType": 3, "isDnD": False, "name": "",
             "resourceType": "GMEvent", "resourceVersion": "2.0"},
            {"$GMEvent": "v1", "%Name": "", "collisionObjectId": None,
             "eventNum": 0, "eventType": 8, "isDnD": False, "name": "",
             "resourceType": "GMEvent", "resourceVersion": "2.0"},
        ],
        "managed": True,
        "name": "oScarecrow",
        "overriddenProperties": [],
        "parent": {"name": "Goat Robs a Bank", "path": "Goat Robs a Bank.yyp"},
        "parentObjectId": None,
        "persistent": False,
        "physicsAngularDamping": 0.1,
        "physicsDensity": 0.5,
        "physicsFriction": 0.2,
        "physicsGroup": 1,
        "physicsKinematic": False,
        "physicsLinearDamping": 0.1,
        "physicsObject": False,
        "physicsRestitution": 0.1,
        "physicsSensor": False,
        "physicsShape": 1,
        "physicsShapePoints": [],
        "physicsStartAwake": True,
        "properties": [],
        "resourceType": "GMObject",
        "resourceVersion": "2.0",
        "solid": False,
        "spriteId": {"name": "sScarecrow",
                     "path": "sprites/sScarecrow/sScarecrow.yy"},
        "spriteMaskId": None,
        "visible": True,
    }


def register_in_project(entries):
    text = open(YPP).read()
    missing = [e for e in entries if f'"name":"{e[0]}"' not in text]
    if not missing:
        return
    lines = "".join(
        f'    {{"id":{{"name":"{name}","path":"{path}",}},}},\n'
        for name, path in missing
    )
    marker = '\n  ],\n  "resourceType":"GMProject"'
    if marker not in text:
        raise RuntimeError("could not find the resources block in the .yyp")
    text = text.replace(marker, "\n" + lines + "  ],\n  \"resourceType\":\"GMProject\"", 1)
    open(YPP, "w").write(text)


def main():
    img = draw_scarecrow()
    frame_id = stable_id("sScarecrow", "frame")
    layer_id = stable_id("sScarecrow", "layer")

    base = os.path.join(ROOT, "sprites", "sScarecrow")
    os.makedirs(os.path.join(base, "layers", frame_id), exist_ok=True)
    img.save(os.path.join(base, f"{frame_id}.png"))
    img.save(os.path.join(base, "layers", frame_id, f"{layer_id}.png"))

    with open(os.path.join(base, "sScarecrow.yy"), "w") as fh:
        json.dump(sprite_yy("sScarecrow", frame_id, layer_id, img.getbbox()),
                  fh, indent=2)
        fh.write("\n")

    obj_dir = os.path.join(ROOT, "objects", "oScarecrow")
    os.makedirs(obj_dir, exist_ok=True)
    with open(os.path.join(obj_dir, "oScarecrow.yy"), "w") as fh:
        json.dump(object_yy(), fh, indent=2)
        fh.write("\n")

    register_in_project([
        ("sScarecrow", "sprites/sScarecrow/sScarecrow.yy"),
        ("oScarecrow", "objects/oScarecrow/oScarecrow.yy"),
    ])
    print("  sScarecrow 64x96 -> sprites/sScarecrow")
    print("  oScarecrow     -> objects/oScarecrow")


if __name__ == "__main__":
    main()

"""Generate polished, lightweight 3D-rendered PNG assets for Arqami using Blender.

Run in CI with:
  blender --background --python tool/generate_blender_assets.py

Outputs are transparent PNGs consumed by Flutter; gameplay, hit targets, curriculum,
progress and accessibility remain native Flutter code.
"""
import math
import os
import bpy
from mathutils import Vector

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
ASSETS = os.path.join(ROOT, "assets", "game")
for folder in ("backgrounds", "characters", "ui", "numbers", "rewards", "effects"):
    os.makedirs(os.path.join(ASSETS, folder), exist_ok=True)

# Reset all startup objects.
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
for datablocks in (bpy.data.materials, bpy.data.curves, bpy.data.cameras, bpy.data.lights):
    pass

def material(name, color, metallic=0.0, roughness=0.42):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*color, 1)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    return m

MAT = {
    "sky": material("Sky • powder blue", (0.40, 0.77, 0.94)),
    "grass": material("Meadow • jade", (0.20, 0.62, 0.39)),
    "grass_light": material("Meadow • mint", (0.42, 0.79, 0.51)),
    "water": material("Lagoon • turquoise", (0.10, 0.66, 0.78), 0.12),
    "gold": material("Reward • warm gold", (1.0, 0.62, 0.12), 0.55, 0.25),
    "cream": material("Warm cream", (1.0, 0.91, 0.69)),
    "coral": material("Coral", (0.97, 0.31, 0.28)),
    "purple": material("Lavender", (0.48, 0.35, 0.79)),
    "blue": material("Ocean blue", (0.14, 0.39, 0.78)),
    "ink": material("Deep teal", (0.055, 0.16, 0.22)),
    "white": material("Porcelain white", (1.0, 0.99, 0.93), 0.05, 0.22),
    "orange": material("Tangerine", (1.0, 0.39, 0.10)),
    "pink": material("Rose", (0.96, 0.43, 0.60)),
}

def smooth(obj):
    if obj.type == "MESH":
        for p in obj.data.polygons:
            p.use_smooth = True
    return obj

def uv(name, loc, scale, mat, segments=32, rings=20):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings, location=loc)
    o = bpy.context.object
    o.name = name
    o.scale = scale if isinstance(scale, tuple) else (scale, scale, scale)
    o.data.materials.append(mat)
    return smooth(o)

def cube(name, loc, scale, mat, bevel=0.12):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.object
    o.name = name
    o.dimensions = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    o.data.materials.append(mat)
    if bevel:
        mod = o.modifiers.new("Soft toy-like bevels", "BEVEL")
        mod.width = bevel
        mod.segments = 3
        o.modifiers.new("Weighted corner normals", "WEIGHTED_NORMAL")
    return o

def cone(name, loc, radius, depth, mat, vertices=32):
    bpy.ops.mesh.primitive_cone_add(vertices=vertices, radius1=radius, radius2=0, depth=depth, location=loc)
    o = bpy.context.object
    o.name = name
    o.data.materials.append(mat)
    return o

def setup_camera(target, ortho=8.5, resolution=512):
    bpy.ops.object.camera_add(location=(8, -12, 13))
    cam = bpy.context.object
    direction = Vector(target) - cam.location
    cam.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    cam.data.type = "ORTHO"
    cam.data.ortho_scale = ortho
    bpy.context.scene.camera = cam
    scene = bpy.context.scene
    # Ubuntu apt repositories may provide Blender 3.x, where EEVEE_NEXT is unavailable.\n    available_engines = {item.identifier for item in scene.render.bl_rna.properties["engine"].enum_items}\n    scene.render.engine = "BLENDER_EEVEE_NEXT" if "BLENDER_EEVEE_NEXT" in available_engines else "BLENDER_EEVEE"
    scene.render.resolution_x = resolution
    scene.render.resolution_y = resolution
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.render.film_transparent = True
    scene.world.color = (0.12, 0.12, 0.12)
    # AgX is available in newer Blender releases; use Filmic on older runners.\n    available_transforms = {item.identifier for item in scene.view_settings.bl_rna.properties["view_transform"].enum_items}\n    scene.view_settings.view_transform = "AgX" if "AgX" in available_transforms else "Filmic"
    scene.render.image_settings.color_depth = "8"
    for light in list(bpy.data.objects):
        if light.type == "LIGHT":
            bpy.data.objects.remove(light, do_unlink=True)
    bpy.ops.object.light_add(type="AREA", location=(1, -5, 11))
    key = bpy.context.object
    key.data.energy = 1500
    key.data.shape = "DISK"
    key.data.size = 8
    bpy.ops.object.light_add(type="AREA", location=(-7, 1, 5))
    fill = bpy.context.object
    fill.data.energy = 750
    fill.data.size = 7
    return scene

def render(path, target=(0, 0, 0), ortho=8.5, resolution=512):
    scene = setup_camera(target, ortho, resolution)
    scene.render.filepath = path
    bpy.ops.render.render(write_still=True)
    # Clean camera/lights before next isolated render.
    for o in list(bpy.data.objects):
        if o.type in {"CAMERA", "LIGHT"}:
            bpy.data.objects.remove(o, do_unlink=True)
    bpy.context.scene.camera = None

def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)

def tree(x, y, size=1.0, variant=0):
    uv("Rounded tree crown", (x, y, 0.9*size), (0.62*size, 0.58*size, 0.68*size),
       MAT["grass_light"] if variant % 2 else MAT["grass"])
    cube("Tree trunk", (x, y, 0.25*size), (0.20*size, 0.22*size, 0.6*size), MAT["orange"], 0.04)

# 1. Premium educational world atlas: seven visually distinct biomes on one continuous route.
# The map is a vertical progression diorama: every region has its own terrain, architecture,
# vegetation and palette while the gold route visibly connects the worlds.
clear_scene()
# Keep the atlas edge restrained: the seven biome platforms and gold route should lead the composition.
# Floating-world composition: omit the oversized continuous slab so each biome reads as its own island.

# Seven region palettes and landmark motifs. All landmarks are geometry, not flat decals.
regions = [
    (-4.0, 2.55, MAT["blue"], MAT["cream"], "counting"),
    (-2.7, 1.70, MAT["grass_light"], MAT["orange"], "tens"),
    (-1.35, 0.85, MAT["cream"], MAT["coral"], "city"),
    (0.0, 0.0, MAT["water"], MAT["gold"], "addition"),
    (1.35, -0.85, MAT["purple"], MAT["pink"], "multiplication"),
    (2.7, -1.70, MAT["blue"], MAT["cream"], "division"),
    (4.0, -2.55, MAT["purple"], MAT["gold"], "galaxy"),
]
for idx, (cx, cy, ground, accent, kind) in enumerate(regions):
    # Each world gets a raised, beveled terrain platform with a contrasting rim.
    bpy.ops.mesh.primitive_cylinder_add(vertices=64, radius=1.12, depth=0.34, location=(cx, cy, -0.02))
    platform = bpy.context.object
    platform.name = "World %02d • raised terrain" % (idx + 1)
    # Vary each island silhouette so the atlas reads as seven distinct destinations.
    island_shapes = (
        (1.10, 0.78, 1.0), (0.98, 0.88, 1.0), (1.16, 0.72, 1.0),
        (1.04, 0.86, 1.0), (0.94, 0.94, 1.0), (1.18, 0.70, 1.0),
        (1.02, 0.82, 1.0),
    )
    platform.scale = island_shapes[idx]
    platform.rotation_euler.z = math.radians((-8, 12, -15, 5, 18, -10, 9)[idx])
    platform.data.materials.append(ground)
    bevel = platform.modifiers.new("Sculpted island edge", "BEVEL")
    bevel.width = 0.14
    bevel.segments = 4
    platform.modifiers.new("Island normals", "WEIGHTED_NORMAL")
    # Layered hills give each biome a readable silhouette.
    for j in range(3):
        hx = cx + (j - 1) * 0.48
        hy = cy + (0.23 if j % 2 else -0.20)
        uv("World %02d • rolling hill" % (idx + 1), (hx, hy, 0.24),
           (0.52, 0.38, 0.22 + 0.06 * (j % 2)), MAT["grass_light"] if idx % 2 == 0 else ground, 24, 14)
    if kind == "counting":
        # Number garden: colorful numbered-looking towers and stepping stones.
        for j, h in enumerate((0.42, 0.68, 0.94, 0.56)):
            x = cx - 0.62 + j * 0.40
            cube("Counting tower", (x, cy + 0.05, 0.35 + h / 2), (0.25, 0.28, h), [MAT["coral"], MAT["gold"], MAT["blue"], MAT["pink"]][j], 0.07)
            uv("Tower cap", (x, cy + 0.05, 0.39 + h), 0.13, MAT["cream"], 16, 10)
    elif kind == "tens":
        # Ten-pillared valley gate.
        for j in range(5):
            x = cx - 0.68 + j * 0.34
            cube("Tens valley pillar", (x, cy, 0.45), (0.20, 0.28, 0.78), MAT["orange"] if j % 2 else MAT["cream"], 0.045)
        cube("Tens gate lintel", (cx, cy, 0.88), (1.65, 0.25, 0.20), MAT["gold"], 0.06)
    elif kind == "city":
        # Distinct skyline: stepped buildings, windows and a central clock tower.
        for j, (dx, h) in enumerate(((-0.62, .60), (-0.22, .90), (.22, .70), (.62, 1.10))):
            cube("Place-value city building", (cx + dx, cy, 0.30 + h / 2), (0.32, 0.34, h), MAT["coral"] if j % 2 else MAT["blue"], 0.045)
            for z in range(2):
                cube("Glowing city window", (cx + dx, cy - 0.18, 0.40 + z * 0.22), (0.09, 0.035, 0.10), MAT["gold"], 0.015)
    elif kind == "addition":
        # Arithmetic island with a stone arch and paired columns.
        for dx in (-0.48, 0.48):
            cube("Addition arch pier", (cx + dx, cy, 0.56), (0.20, 0.24, 0.88), MAT["cream"], 0.06)
        cube("Addition arch crown", (cx, cy, 1.00), (1.16, 0.24, 0.20), MAT["gold"], 0.06)
        uv("Addition jewel", (cx, cy - 0.18, 1.12), 0.20, MAT["coral"], 24, 16)
    elif kind == "multiplication":
        # Multiplication mountain with a stepped observatory.
        cone("Multiplication peak", (cx, cy, 0.60), 0.90, 1.10, MAT["pink"])
        cube("Mountain observatory", (cx, cy - 0.15, 0.86), (0.58, 0.48, 0.50), MAT["cream"], 0.08)
        cone("Observatory roof", (cx, cy - 0.15, 1.30), 0.43, 0.36, MAT["gold"])
    elif kind == "division":
        # Division aqueduct and three separated pools.
        for j in range(3):
            uv("Division pool", (cx - 0.52 + j * 0.52, cy - 0.22, 0.31), (0.23, 0.32, 0.08), MAT["water"], 24, 12)
        cube("Division aqueduct", (cx, cy + 0.28, 0.48), (1.55, 0.18, 0.18), MAT["cream"], 0.06)
        for j in range(4):
            cube("Aqueduct pier", (cx - 0.57 + j * 0.38, cy + 0.28, 0.22), (0.10, 0.20, 0.48), MAT["gold"], 0.025)
    else:
        # Galaxy biome: ringed planet, crystals and a luminous constellation.
        uv("Fraction galaxy planet", (cx, cy, 0.64), (0.40, 0.40, 0.38), MAT["pink"], 32, 20)
        bpy.ops.mesh.primitive_torus_add(major_radius=0.63, minor_radius=0.055, major_segments=48, minor_segments=12, location=(cx, cy, 0.65), rotation=(0.18, 0.22, 0.25))
        bpy.context.object.name = "Orbit ring"
        bpy.context.object.data.materials.append(MAT["gold"])
        for j in range(4):
            cone("Crystal star", (cx - 0.75 + j * 0.48, cy + 0.46, 0.50), 0.16, 0.42, MAT["cream"], 6)
    # Tiny trees/lamps create scale and a finished diorama feel.
    for side in (-1, 1):
        uv("World lantern", (cx + side * 0.88, cy - 0.18, 0.40), 0.12, accent, 20, 12)
        cube("Lantern stem", (cx + side * 0.88, cy - 0.18, 0.20), (0.055, 0.055, 0.28), MAT["ink"], 0.015)

# A continuous raised gold rail-road connects the seven themed islands.
route_points = [(-4.3, 2.50), (-3.65, 2.15), (-3.0, 1.78), (-2.35, 1.42),
                (-1.70, 1.05), (-1.05, 0.70), (-0.35, 0.22), (0.35, -0.22),
                (1.05, -0.70), (1.70, -1.05), (2.35, -1.42), (3.0, -1.78),
                (3.65, -2.15), (4.3, -2.50)]
# A continuous beveled spline sits under the stepping stones, so the journey reads as one road.
road_curve = bpy.data.curves.new("Continuous golden journey road", "CURVE")
road_curve.dimensions = "3D"
road_curve.resolution_u = 24
road_curve.bevel_depth = 0.075
road_curve.bevel_resolution = 4
road_spline = road_curve.splines.new("BEZIER")
road_spline.bezier_points.add(len(route_points) - 1)
for point, (x, y) in zip(road_spline.bezier_points, route_points):
    point.co = (x, y, 0.27)
    point.handle_left_type = "AUTO"
    point.handle_right_type = "AUTO"
road_obj = bpy.data.objects.new("Continuous golden journey road", road_curve)
bpy.context.collection.objects.link(road_obj)
road_obj.data.materials.append(MAT["gold"])
for i, (x, y) in enumerate(route_points):
    uv("Golden route stepping stone %02d" % i, (x, y, 0.35), (0.16, 0.16, 0.08), MAT["gold"], 20, 12)
    if i in (1, 3, 5, 7, 9, 11, 13):
        uv("Route checkpoint jewel", (x, y, 0.45), (0.10, 0.10, 0.06), MAT["cream"], 16, 10)

# Avoid detached frame decorations: each world should read as a self-contained island.
# Island landmarks, lanterns, crystals, and vegetation remain placed on the terrain above.

render(os.path.join(ASSETS, "backgrounds", "world_map.png"), (0,0,0.2), 10.4, 1024)

# 2. Original 3D companion mascot: friendly little owl-like number guide.
clear_scene()
uv("Mascot body", (0,0,1.0), (1.05,0.82,1.22), MAT["purple"])
uv("Left ear", (-0.67,0,1.85), (0.34,0.28,0.47), MAT["purple"])
uv("Right ear", (0.67,0,1.85), (0.34,0.28,0.47), MAT["purple"])
uv("Face", (0,-0.68,1.15), (0.79,0.24,0.77), MAT["cream"])
for x in (-0.31,0.31):
    uv("Eye white", (x,-0.91,1.39), (0.19,0.10,0.23), MAT["white"], 24, 16)
    uv("Eye pupil", (x,-1.005,1.38), (0.085,0.055,0.12), MAT["ink"], 20, 12)
uv("Beak", (0,-1.02,1.08), (0.15,0.12,0.13), MAT["gold"], 20, 12)
uv("Belly", (0,-0.71,0.68), (0.43,0.12,0.40), MAT["white"])
for x in (-0.46,0.46):
    uv("Tiny foot", (x,-0.1,0.02), (0.25,0.27,0.12), MAT["orange"])
uv("Badge", (0,-0.84,0.48), (0.18,0.08,0.18), MAT["gold"], 24, 16)
render(os.path.join(ASSETS, "characters", "companion.png"), (0,-0.15,1.0), 4.5, 512)

# 3. Level states: soft-edged dimensional medallions; preserve readable Flutter labels.
def node_asset(filename, base, emblem):
    clear_scene()
    # layered coin body with raised rim and glossy center
    bpy.ops.mesh.primitive_cylinder_add(vertices=64, radius=1.05, depth=0.26, location=(0,0,0.35))
    rim=bpy.context.object; rim.name="Raised metallic rim"; rim.data.materials.append(MAT["gold"])
    bevel=rim.modifiers.new("Rounded rim", "BEVEL"); bevel.width=0.10; bevel.segments=4
    rim.modifiers.new("Weighted normals","WEIGHTED_NORMAL")
    bpy.ops.mesh.primitive_cylinder_add(vertices=64, radius=0.88, depth=0.20, location=(0,0,0.52))
    face=bpy.context.object; face.name="Enamel face"; face.data.materials.append(base)
    bevel=face.modifiers.new("Soft enamel edge","BEVEL"); bevel.width=0.08; bevel.segments=4
    face.modifiers.new("Weighted normals","WEIGHTED_NORMAL")
    if emblem == "star":
        for i in range(5):
            a=math.pi/2+i*math.tau/5
            uv("Star point", (math.cos(a)*0.38, math.sin(a)*0.38,0.78), (0.23,0.23,0.10), MAT["cream"],20,12)
        uv("Star core",(0,0,0.80),(0.30,0.30,0.11),MAT["cream"],24,16)
    elif emblem == "lock":
        cube("Lock body",(0,0,0.80),(0.52,0.42,0.15),MAT["cream"],0.08)
        bpy.ops.mesh.primitive_torus_add(major_radius=0.22, minor_radius=0.075, major_segments=32, minor_segments=12, location=(0,0,0.86))
        bpy.context.object.data.materials.append(MAT["cream"])
    else:
        uv("Center jewel",(0,0,0.82),0.25,MAT["cream"],24,16)
    render(os.path.join(ASSETS,"ui",filename),(0,0,0.4),3.5,384)

node_asset("level_node.png", MAT["blue"], "star")
node_asset("level_node_completed.png", MAT["grass"], "star")
node_asset("level_node_locked.png", MAT["purple"], "lock")

# 4. Reward medal with a ribbon and dimensional star.
clear_scene()
bpy.ops.mesh.primitive_cylinder_add(vertices=64, radius=0.83, depth=0.22, location=(0,0,0.7))
medal=bpy.context.object; medal.data.materials.append(MAT["gold"])
bevel=medal.modifiers.new("Medal bevel","BEVEL"); bevel.width=0.08; bevel.segments=4
cube("Left ribbon",(-0.36,0,0.05),(0.38,0.28,0.9),MAT["coral"],0.08).rotation_euler[1]=-0.22
cube("Right ribbon",(0.36,0,0.05),(0.38,0.28,0.9),MAT["blue"],0.08).rotation_euler[1]=0.22
for i in range(5):
    a=math.pi/2+i*math.tau/5
    uv("Medal star point",(math.cos(a)*0.30,math.sin(a)*0.30,0.88),(0.19,0.19,0.08),MAT["cream"],20,12)
uv("Medal star center",(0,0,0.9),0.24,MAT["cream"],24,16)
render(os.path.join(ASSETS,"rewards","reward_badge.png"),(0,0,0.4),3.4,384)
# Simple transparent stars icon for existing reward UI.
clear_scene()
for i,x in enumerate((-0.95,0,0.95)):
    uv("Golden star",(x,0,0.2),(0.37,0.37,0.15),MAT["gold"],24,16)
render(os.path.join(ASSETS,"rewards","stars.png"),(0,0,0.2),3.8,384)

# 5. Sparkle burst; subtle, clean alpha edges so Flutter can animate opacity/scale.
clear_scene()
for i in range(12):
    a=i*math.tau/12
    r=0.42 if i%2 else 0.95
    uv("Celebration sparkle",(math.cos(a)*r,math.sin(a)*r,0.1),(0.12,0.12,0.08),MAT["gold"] if i%3 else MAT["cream"],16,10)
uv("Sparkle center",(0,0,0.16),0.27,MAT["cream"],24,16)
render(os.path.join(ASSETS,"effects","success.png"),(0,0,0.1),3.0,384)
render(os.path.join(ASSETS,"effects","unlock.png"),(0,0,0.1),3.0,384)

# Record generation provenance and ensure all outputs are non-empty.
outputs = [
    "backgrounds/world_map.png", "characters/companion.png",
    "ui/level_node.png", "ui/level_node_completed.png", "ui/level_node_locked.png",
    "rewards/reward_badge.png", "rewards/stars.png",
    "effects/success.png", "effects/unlock.png",
]
for rel in outputs:
    path = os.path.join(ASSETS, rel)
    if not os.path.isfile(path) or os.path.getsize(path) < 1000:
        raise RuntimeError("Blender output missing or suspiciously small: " + path)
    print("BLENDER_ASSET_OK", rel, os.path.getsize(path), "bytes")
print("ARQAMI_BLENDER_ASSETS_GENERATED", len(outputs))

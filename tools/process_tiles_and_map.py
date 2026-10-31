import os
from PIL import Image, ImageDraw

def create_tilesheet_and_map():
    # 1. Create 256x256 composite tilesheet (16x16 tiles = 256 tiles)
    sheet = Image.new('RGBA', (256, 256), (0, 0, 0, 0))

    # Load source sheets
    grass_img = Image.open('assets/images/tiles/grass.png')
    house_img = Image.open('assets/images/tiles/wooden_house.png')
    fences_img = Image.open('assets/images/tiles/fences.png')
    objects_img = Image.open('assets/images/tiles/objects.png')
    water_img = Image.open('assets/images/tiles/water.png')
    tilled_img = Image.open('assets/images/tiles/tilled_dirt.png')
    paths_img = Image.open('assets/images/tiles/paths.png')

    # Row 0: Basic Ground & Terrain Tiles
    # Tile 0 (Col 0): Transparent
    # Tile 1 (Col 1): Base Grass (Col 1, Row 1 of grass.png)
    base_grass = grass_img.crop((16, 16, 32, 32))
    sheet.paste(base_grass, (16 * 1, 0))

    # Tile 2 (Col 2): Grass with flower (Col 3, Row 0 of grass.png)
    flower_grass = grass_img.crop((48, 0, 64, 16))
    sheet.paste(flower_grass, (16 * 2, 0))

    # Tile 3 (Col 3): Grass with small pebbles
    pebble_grass = grass_img.crop((0, 0, 16, 16))
    sheet.paste(pebble_grass, (16 * 3, 0))

    # Tile 4 (Col 4): Darker grass shading
    dark_grass = grass_img.crop((48, 32, 64, 48))
    sheet.paste(dark_grass, (16 * 4, 0))

    # Tile 5 (Col 5): Dirt path center (from paths.png)
    path_center = paths_img.crop((16, 16, 32, 32))
    sheet.paste(path_center, (16 * 5, 0))

    # Tile 6 (Col 6): Dirt path edge
    path_edge = paths_img.crop((0, 16, 16, 32))
    sheet.paste(path_edge, (16 * 6, 0))

    # Tile 7 (Col 7): Tilled dirt dry (from tilled_dirt.png)
    tilled_dry = tilled_img.crop((16, 16, 32, 32))
    sheet.paste(tilled_dry, (16 * 7, 0))

    # Tile 8 (Col 8): Tilled dirt wet/watered (darker)
    tilled_wet = tilled_dry.copy()
    enhancer = ImageDraw.Draw(tilled_wet)
    # Add rich soil dampness
    tilled_wet_tint = Image.new('RGBA', (16, 16), (20, 10, 5, 60))
    tilled_wet = Image.alpha_composite(tilled_wet.convert('RGBA'), tilled_wet_tint)
    sheet.paste(tilled_wet, (16 * 8, 0))

    # Tile 9 (Col 9): Water center (from water.png)
    water_tile = water_img.crop((0, 0, 16, 16))
    sheet.paste(water_tile, (16 * 9, 0))

    # Tile 10 (Col 10): Water shoreline
    water_edge = water_img.crop((16, 0, 32, 16))
    sheet.paste(water_edge, (16 * 10, 0))

    # Tile 11 (Col 11): Wooden Fence horizontal
    fence_h = fences_img.crop((16, 0, 32, 16))
    sheet.paste(fence_h, (16 * 11, 0))

    # Tile 12 (Col 12): Wooden Fence vertical
    fence_v = fences_img.crop((0, 16, 16, 32))
    sheet.paste(fence_v, (16 * 12, 0))

    # Tile 13 (Col 13): Fence corner / post
    fence_post = fences_img.crop((0, 0, 16, 16))
    sheet.paste(fence_post, (16 * 13, 0))

    # Tile 14 (Col 14): Wooden Fence gate
    fence_gate = fences_img.crop((32, 0, 48, 16))
    sheet.paste(fence_gate, (16 * 14, 0))

    # Rows 1 to 5: Wooden House (Grandfather's cabin) - 7 cols x 5 rows = 112x80 px
    # Placed starting at (x=0, y=16) to (x=112, y=96)
    sheet.paste(house_img, (0, 16))

    # Rows 6 to 8: Nature objects (Tree, rocks, stump, crops)
    # Tree (32x48 px = 2x3 tiles) from objects.png
    tree = objects_img.crop((16, 0, 48, 48))
    sheet.paste(tree, (128, 16))

    # Stump (16x16) from objects.png
    stump = objects_img.crop((80, 0, 96, 16))
    sheet.paste(stump, (160, 16))

    # Big rock (16x16) from objects.png
    rock = objects_img.crop((96, 0, 112, 16))
    sheet.paste(rock, (176, 16))

    # Small rock (16x16)
    small_rock = objects_img.crop((112, 0, 128, 16))
    sheet.paste(small_rock, (192, 16))

    # Wild mushroom / herb (16x16)
    herb = objects_img.crop((80, 16, 96, 32))
    sheet.paste(herb, (208, 16))

    # Ancient Mystical Moonstone Totem (32x32 px = 2x2 tiles at x=128, y=64)
    # Custom pixel art for Valley Moon's signature lunar lore:
    totem = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(totem)
    # Base altar stone
    d.rectangle([4, 20, 27, 30], fill=(70, 75, 85, 255), outline=(40, 45, 55, 255))
    d.rectangle([7, 14, 24, 21], fill=(85, 92, 105, 255), outline=(50, 55, 65, 255))
    # Monolith Pillar
    d.rectangle([10, 4, 21, 15], fill=(95, 105, 125, 255), outline=(60, 70, 85, 255))
    # Glowing Moonstone Rune (Crescent moon in glowing ethereal lunar cyan/blue)
    moon_color = (130, 225, 255, 255)
    moon_glow = (70, 170, 230, 200)
    d.arc([11, 5, 20, 14], start=60, end=300, fill=moon_glow, width=2)
    d.arc([12, 6, 19, 13], start=80, end=280, fill=moon_color, width=1)
    # Moss & Ivy highlights (earthy rustic nature)
    d.point([(6, 22), (7, 23), (10, 18), (11, 16), (23, 24), (24, 25)], fill=(75, 120, 60, 255))
    # Little mystical spark
    d.point([(15, 9), (16, 10)], fill=(220, 245, 255, 255))
    sheet.paste(totem, (128, 64))

    # Save composite tilesheet
    sheet_path = 'assets/images/tiles/farm_tiles.png'
    sheet.save(sheet_path)
    print(f"Saved composite tilesheet: {sheet_path} (256x256, 16x16 grid)")

    # 2. Build TMX Map for the Grandfather's Abandoned Farm
    # Grid: 32 columns x 24 rows
    MAP_W = 32
    MAP_H = 24

    # GID Mapping in 16-column tileset (GID = row * 16 + col + 1):
    # GID 1: Blank
    # GID 2: Base Grass (Col 1, Row 0)
    # GID 3: Flower Grass (Col 2, Row 0)
    # GID 4: Pebble Grass (Col 3, Row 0)
    # GID 5: Dark Grass (Col 4, Row 0)
    # GID 6: Dirt Path Center (Col 5, Row 0)
    # GID 7: Dirt Path Edge (Col 6, Row 0)
    # GID 8: Tilled Soil Dry (Col 7, Row 0)
    # GID 9: Tilled Soil Wet (Col 8, Row 0)
    # GID 10: Water Center (Col 9, Row 0)
    # GID 11: Water Edge (Col 10, Row 0)
    # GID 12: Fence H (Col 11, Row 0)
    # GID 13: Fence V (Col 12, Row 0)
    # GID 14: Fence Post (Col 13, Row 0)
    # GID 15: Fence Gate (Col 14, Row 0)

    # House (7 cols x 5 rows starting at Row 1, Col 0):
    # House Row 0 (GIDs 17 to 23): Roof peak
    # House Row 1 (GIDs 33 to 39): Roof
    # House Row 2 (GIDs 49 to 55): Walls & Windows
    # House Row 3 (GIDs 65 to 71): Walls & Door
    # House Row 4 (GIDs 81 to 87): Porch & Foundation

    # Nature Props:
    # Tree (2 cols x 3 rows at x=128, y=16 -> Col 8, 9; Rows 1, 2, 3)
    # Tree top: GID (1 * 16 + 8 + 1) = 25, GID 26
    # Tree mid: GID (2 * 16 + 8 + 1) = 41, GID 42
    # Tree bot/trunk: GID (3 * 16 + 8 + 1) = 57, GID 58
    # Stump (Col 10, Row 1): GID (1 * 16 + 10 + 1) = 27
    # Big rock (Col 11, Row 1): GID (1 * 16 + 11 + 1) = 28
    # Small rock (Col 12, Row 1): GID (1 * 16 + 12 + 1) = 29
    # Wild herb (Col 13, Row 1): GID (1 * 16 + 13 + 1) = 30
    # Moonstone Totem (Col 8, 9; Rows 4, 5):
    # Totem top: GID (4 * 16 + 8 + 1) = 73, GID 74
    # Totem bot: GID (5 * 16 + 8 + 1) = 89, GID 90

    # Layer 1: Ground (32x24)
    ground_layer = [[2 for _ in range(MAP_W)] for _ in range(MAP_H)]

    # Add grass flowers & pebbles scattered around
    for r in range(MAP_H):
        for c in range(MAP_W):
            if (c * 7 + r * 13) % 17 == 0:
                ground_layer[r][c] = 3  # flower
            elif (c * 11 + r * 5) % 19 == 0:
                ground_layer[r][c] = 4  # pebbles

    # Dirt path leading from cabin door down to gate
    # Cabin door is at x=20, y=7. Path runs y=8..22 at x=20, and branches to x=6..20 at y=14
    for y in range(8, 23):
        ground_layer[y][20] = 6
        if y % 3 == 0:
            ground_layer[y][21] = 6
    for x in range(8, 21):
        ground_layer[14][x] = 6
        ground_layer[15][x] = 6

    # Tilled Soil Patch (Farm plot in center-left: cols 10..15, rows 9..12)
    for y in range(9, 13):
        for x in range(10, 16):
            ground_layer[y][x] = 8 if (x + y) % 3 != 0 else 9

    # Water Pond (bottom-left: cols 2..6, rows 16..20)
    for y in range(16, 21):
        for x in range(2, 7):
            ground_layer[y][x] = 10

    # Layer 2: Decorations (Cabin, trees, fences, totem, rocks)
    decor_layer = [[0 for _ in range(MAP_W)] for _ in range(MAP_H)]

    # Grandfather's Wooden Cabin (7 cols x 5 rows, placed at col 17..23, row 3..7)
    cabin_c0 = 17
    cabin_r0 = 3
    house_gids = [
        [17, 18, 19, 20, 21, 22, 23],
        [33, 34, 35, 36, 37, 38, 39],
        [49, 50, 51, 52, 53, 54, 55],
        [65, 66, 67, 68, 69, 70, 71],
        [81, 82, 83, 84, 85, 86, 87]
    ]
    for hr in range(5):
        for hc in range(7):
            decor_layer[cabin_r0 + hr][cabin_c0 + hc] = house_gids[hr][hc]

    # Moonstone Totem at col 4, row 4 (2x2)
    decor_layer[4][4] = 73
    decor_layer[4][5] = 74
    decor_layer[5][4] = 89
    decor_layer[5][5] = 90

    # Trees along Northern perimeter (Row 0..2)
    def place_tree(col, row):
        if row + 2 < MAP_H and col + 1 < MAP_W:
            decor_layer[row][col] = 25
            decor_layer[row][col+1] = 26
            decor_layer[row+1][col] = 41
            decor_layer[row+1][col+1] = 42
            decor_layer[row+2][col] = 57
            decor_layer[row+2][col+1] = 58

    for c in [1, 7, 10, 13, 25, 28]:
        place_tree(c, 0)

    # Trees along Western & Eastern perimeter
    for r in [7, 11]:
        place_tree(0, r)
        place_tree(29, r)

    # Wooden Fences: Farm boundary along bottom and sides
    # Horizontal fence row at row 22 (cols 7 to 28, with gate at col 20)
    for c in range(7, 28):
        if c == 20:
            decor_layer[22][c] = 15  # Gate
        else:
            decor_layer[22][c] = 12  # Fence H

    # Rocks, Stumps, Herbs in the abandoned field
    decor_layer[10][8] = 27   # Stump
    decor_layer[12][8] = 28   # Big rock
    decor_layer[9][16] = 29   # Small rock
    decor_layer[11][17] = 28  # Big rock
    decor_layer[13][12] = 27  # Stump
    decor_layer[17][9] = 30   # Wild herb
    decor_layer[18][12] = 30  # Wild herb
    decor_layer[6][7] = 29    # Small rock

    # Flatten layers into CSV string
    ground_csv = ',\n'.join(','.join(str(val) for val in row) for row in ground_layer)
    decor_csv = ',\n'.join(','.join(str(val) for val in row) for row in decor_layer)

    # Objects / Collisions (in pixel units: 1 tile = 16 pixels)
    # Cabin hitbox: x = 17 * 16 = 272, y = 3 * 16 = 48, width = 7 * 16 = 112, height = 4.5 * 16 = 72
    # Pond hitbox: x = 2 * 16 = 32, y = 16 * 16 = 256, width = 5 * 16 = 80, height = 5 * 16 = 80
    # Totem hitbox: x = 4 * 16 = 64, y = 4 * 16 = 64, width = 32, height = 32
    # Fence hitbox: x = 7 * 16 = 112, y = 22 * 16 = 352, width = 12 * 16 = 192 (left segment), and right segment
    # Map borders:
    # North: 0, 0, 512, 32
    # West: 0, 0, 16, 384
    # East: 496, 0, 16, 384
    # South: 0, 368, 512, 16

    tmx_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<map version="1.10" tiledversion="1.10.2" orientation="orthogonal" renderorder="right-down" width="{MAP_W}" height="{MAP_H}" tilewidth="16" tileheight="16" infinite="0" nextlayerid="5" nextobjectid="10">
 <tileset firstgid="1" name="farm_tiles" tilewidth="16" tileheight="16" tilecount="256" columns="16">
  <image source="tiles/farm_tiles.png" width="256" height="256"/>
 </tileset>
 <layer id="1" name="Ground" width="{MAP_W}" height="{MAP_H}">
  <data encoding="csv">
{ground_csv}
  </data>
 </layer>
 <layer id="2" name="Decorations" width="{MAP_W}" height="{MAP_H}">
  <data encoding="csv">
{decor_csv}
  </data>
 </layer>
 <objectgroup id="3" name="Collisions">
  <!-- Map Outer Boundaries -->
  <object id="1" name="BorderNorth" x="0" y="0" width="512" height="32"/>
  <object id="2" name="BorderWest" x="0" y="0" width="16" height="384"/>
  <object id="3" name="BorderEast" x="496" y="0" width="16" height="384"/>
  <object id="4" name="BorderSouthLeft" x="0" y="368" width="310" height="16"/>
  <object id="5" name="BorderSouthRight" x="340" y="368" width="172" height="16"/>

  <!-- Grandfather's Wooden Cabin -->
  <object id="6" name="Cabin" x="272" y="56" width="112" height="64"/>

  <!-- Freshwater Pond -->
  <object id="7" name="Pond" x="32" y="256" width="80" height="80"/>

  <!-- Ancient Moonstone Totem -->
  <object id="8" name="MoonstoneTotem" x="64" y="68" width="32" height="26"/>

  <!-- Wooden Fence Left -->
  <object id="9" name="FenceLeft" x="112" y="356" width="200" height="10"/>
  <!-- Wooden Fence Right -->
  <object id="10" name="FenceRight" x="336" y="356" width="112" height="10"/>
 </objectgroup>
 <objectgroup id="4" name="SpawnPoints">
  <object id="11" name="PlayerSpawn" x="328" y="140" width="16" height="16"/>
 </objectgroup>
</map>
"""

    tmx_path = 'assets/tiles/farm_map.tmx'
    with open(tmx_path, 'w', encoding='utf-8') as f:
        f.write(tmx_content)
    print(f"Generated Tiled Map: {tmx_path} (32x24 tiles, 512x384 px)")

if __name__ == '__main__':
    create_tilesheet_and_map()

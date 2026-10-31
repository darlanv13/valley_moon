import os
from PIL import Image

def organize_slices():
    print("Organizing clippings into assets/images/player/ and assets/images/tiles/...")

    walk_img = Image.open("assets/images/player/player_walk.png")
    actions_img = Image.open("assets/images/player/player_actions.png")
    tools_img = Image.open("assets/images/player/tools.png")

    os.makedirs("assets/images/player/slices", exist_ok=True)
    os.makedirs("assets/images/tiles/slices", exist_ok=True)

    # 1. Slices for Player Walk & Idle (4 directions: Down=0, Up=1, Left=2, Right=3)
    directions = ["down", "up", "left", "right"]
    for row, d in enumerate(directions):
        # Idle (2 frames)
        idle_sheet = walk_img.crop((0, row * 48, 96, (row + 1) * 48))
        idle_sheet.save(f"assets/images/player/slices/idle_{d}.png")

        # Walk (2 frames)
        walk_sheet = walk_img.crop((96, row * 48, 192, (row + 1) * 48))
        walk_sheet.save(f"assets/images/player/slices/walk_{d}.png")

    # 2. Slices for Actions (Axe, Hoe, Water)
    # Rows 0..3: Axe
    axe_sheet = actions_img.crop((0, 0, 96, 4 * 48))
    axe_sheet.save("assets/images/player/slices/action_axe.png")

    # Rows 4..7: Hoe
    hoe_sheet = actions_img.crop((0, 4 * 48, 96, 8 * 48))
    hoe_sheet.save("assets/images/player/slices/action_hoe.png")

    # Rows 8..11: Water
    water_sheet = actions_img.crop((0, 8 * 48, 96, 12 * 48))
    water_sheet.save("assets/images/player/slices/action_water.png")

    # Pickaxe sheet (Action strike adapted with pickaxe sound/visual)
    pickaxe_sheet = actions_img.crop((0, 0, 96, 4 * 48))
    pickaxe_sheet.save("assets/images/player/slices/action_pickaxe.png")

    # Sword slash sheet
    sword_sheet = actions_img.crop((0, 0, 96, 4 * 48))
    sword_sheet.save("assets/images/player/slices/action_sword.png")

    # 3. Slices for Tiles
    farm_tiles = Image.open("assets/images/tiles/farm_tiles.png")

    # Grandfather's Wooden Cabin (112 x 80 px at x=0, y=16)
    cabin = farm_tiles.crop((0, 16, 112, 96))
    cabin.save("assets/images/tiles/slices/cabin.png")

    # Tree (32 x 48 px at x=128, y=16)
    tree = farm_tiles.crop((128, 16, 160, 64))
    tree.save("assets/images/tiles/slices/tree.png")

    # Moonstone Totem (32 x 32 px at x=128, y=64)
    totem = farm_tiles.crop((128, 64, 160, 96))
    totem.save("assets/images/tiles/slices/moonstone_totem.png")

    # Stump, Rocks
    stump = farm_tiles.crop((160, 16, 176, 32))
    stump.save("assets/images/tiles/slices/stump.png")

    rock = farm_tiles.crop((176, 16, 192, 32))
    rock.save("assets/images/tiles/slices/rock.png")

    print("Clippings successfully organized!")

if __name__ == "__main__":
    organize_slices()


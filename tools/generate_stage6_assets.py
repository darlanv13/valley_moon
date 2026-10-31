import os
from PIL import Image, ImageDraw

os.makedirs('assets/images/cave', exist_ok=True)
os.makedirs('assets/images/monsters', exist_ok=True)
os.makedirs('assets/images/equipment', exist_ok=True)

def create_cave_tiles():
    # 128x64 tileset (16x16 tiles):
    # (0,0): Rocky Floor, (1,0): Wall Top, (2,0): Wall Face, (3,0): Ladder Down
    # (4,0): Copper Ore Rock, (5,0): Iron Ore Rock, (6,0): Silver/Gold Rock, (7,0): Lunar Crystal Rock
    # (0,1): Magma Floor, (1,1): Magma Edge, (2,1): Deep Void, (3,1): Underground Lake Water
    # (4,1): Shadow Gate Root Lock, (5,1): Gate Open Pillar, (6,1): Giant Shroom, (7,1): Geode Node
    sheet = Image.new('RGBA', (128, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(sheet)

    # (0,0): Rocky Floor (dark textured stone)
    d.rectangle([0, 0, 15, 15], fill=(42, 38, 46, 255))
    d.point([(3, 3), (9, 4), (13, 11), (4, 12), (8, 9)], fill=(60, 55, 65, 255))
    d.point([(2, 7), (11, 7), (6, 13)], fill=(30, 26, 34, 255))

    # (16,0): Wall Top
    d.rectangle([16, 0, 31, 15], fill=(32, 28, 36, 255), outline=(20, 16, 24, 255))
    d.line([(16, 15), (31, 15)], fill=(15, 12, 18, 255))

    # (32,0): Wall Face
    d.rectangle([32, 0, 47, 15], fill=(22, 18, 26, 255))
    d.line([(32, 4), (47, 4)], fill=(15, 12, 18, 255))
    d.line([(32, 10), (47, 10)], fill=(15, 12, 18, 255))
    d.point([(36, 7), (43, 13)], fill=(40, 34, 48, 255))

    # (48,0): Ladder Down (Wood / Rope rungs leading into dark hole)
    d.ellipse([49, 1, 62, 14], fill=(10, 8, 14, 255))
    d.line([(52, 2), (52, 13)], fill=(120, 80, 40, 255), width=1)
    d.line([(59, 2), (59, 13)], fill=(120, 80, 40, 255), width=1)
    for ry in [4, 7, 10]:
        d.line([(52, ry), (59, ry)], fill=(180, 130, 70, 255), width=1)

    # (64,0): Copper Ore Rock
    d.ellipse([65, 2, 78, 14], fill=(70, 65, 75, 255), outline=(45, 40, 50, 255))
    d.polygon([(68, 6), (71, 5), (70, 9)], fill=(210, 115, 60, 255))
    d.polygon([(73, 9), (76, 8), (75, 12)], fill=(210, 115, 60, 255))
    d.point([(70, 7), (75, 10)], fill=(255, 180, 130, 255)) # copper glint

    # (80,0): Iron Ore Rock
    d.ellipse([81, 2, 94, 14], fill=(70, 65, 75, 255), outline=(45, 40, 50, 255))
    d.polygon([(84, 5), (88, 4), (87, 8)], fill=(175, 180, 190, 255))
    d.polygon([(89, 8), (92, 7), (91, 11)], fill=(175, 180, 190, 255))
    d.point([(86, 6), (91, 9)], fill=(240, 245, 255, 255))

    # (96,0): Gold Ore Rock
    d.ellipse([97, 2, 110, 14], fill=(65, 60, 70, 255), outline=(40, 35, 45, 255))
    d.polygon([(100, 5), (104, 4), (103, 8)], fill=(255, 205, 40, 255))
    d.polygon([(105, 8), (108, 7), (107, 11)], fill=(255, 205, 40, 255))
    d.point([(102, 6), (107, 9)], fill=(255, 255, 200, 255))

    # (112,0): Lunar Crystal Rock (Glowing Cyan / Moonstone)
    d.ellipse([113, 2, 126, 14], fill=(50, 50, 65, 255), outline=(35, 35, 50, 255))
    d.polygon([(116, 4), (119, 1), (121, 6), (118, 9)], fill=(138, 227, 255, 255))
    d.polygon([(121, 7), (124, 4), (125, 9)], fill=(80, 185, 230, 255))
    d.point([(118, 4), (123, 6)], fill=(255, 255, 255, 255)) # crystal flare

    # Row 1 (y=16):
    # (0,16): Magma Floor
    d.rectangle([0, 16, 15, 31], fill=(180, 45, 15, 255))
    d.ellipse([2, 18, 13, 29], fill=(235, 95, 20, 255))
    d.ellipse([5, 21, 10, 26], fill=(255, 200, 50, 255))

    # (16,16): Underground Lake Water
    d.rectangle([16, 16, 31, 31], fill=(20, 35, 65, 255))
    d.line([(18, 20), (28, 20)], fill=(35, 65, 115, 255))
    d.line([(20, 25), (26, 25)], fill=(35, 65, 115, 255))
    d.point([(22, 19), (27, 24)], fill=(138, 227, 255, 200))

    # (32,16): Colossal Shadow Gate Root (Locked)
    d.rectangle([32, 16, 47, 31], fill=(25, 20, 30, 255), outline=(12, 10, 15, 255))
    # 4 Black twisted thorny roots
    d.line([(34, 16), (40, 31)], fill=(75, 20, 40, 255), width=2)
    d.line([(44, 16), (38, 31)], fill=(75, 20, 40, 255), width=2)
    d.point([(39, 23)], fill=(220, 30, 50, 255)) # Runic evil eye

    # (48,16): Shadow Gate Open (Purified Celestial Archway)
    d.rectangle([48, 16, 63, 31], fill=(15, 25, 45, 255), outline=(138, 227, 255, 255))
    d.ellipse([51, 19, 60, 28], fill=(138, 227, 255, 180))
    d.point([(55, 23)], fill=(255, 255, 255, 255))

    sheet.save('assets/images/cave/cave_tiles.png')
    print("Created cave_tiles.png")

def create_monsters():
    # 1. Mud Slime (32x16, 2 frames of 16x16: Idle & Squish)
    slime = Image.new('RGBA', (32, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(slime)
    # Frame 0: Idle
    d.ellipse([2, 4, 13, 14], fill=(140, 85, 45, 255), outline=(90, 50, 25, 255))
    d.ellipse([4, 6, 11, 12], fill=(175, 115, 65, 255))
    d.point([(5, 8), (10, 8)], fill=(255, 255, 255, 255))
    d.point([(6, 8), (11, 8)], fill=(30, 15, 10, 255))
    # Frame 1: Squish
    d.ellipse([17, 7, 30, 15], fill=(140, 85, 45, 255), outline=(90, 50, 25, 255))
    d.ellipse([19, 9, 28, 13], fill=(175, 115, 65, 255))
    d.point([(20, 10), (27, 10)], fill=(255, 255, 255, 255))
    d.point([(21, 10), (28, 10)], fill=(30, 15, 10, 255))
    slime.save('assets/images/monsters/slime.png')

    # 2. Cave Bat (32x16, 2 frames of 16x16: Wings Up & Wings Down)
    bat = Image.new('RGBA', (32, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(bat)
    # Frame 0: Wings Up
    d.ellipse([5, 5, 10, 11], fill=(50, 45, 65, 255))
    d.polygon([(1, 2), (5, 6), (3, 8)], fill=(75, 65, 95, 255))
    d.polygon([(14, 2), (10, 6), (12, 8)], fill=(75, 65, 95, 255))
    d.point([(6, 7), (9, 7)], fill=(255, 40, 60, 255)) # Glowing red eyes
    # Frame 1: Wings Down
    d.ellipse([21, 5, 26, 11], fill=(50, 45, 65, 255))
    d.polygon([(17, 10), (21, 7), (19, 13)], fill=(75, 65, 95, 255))
    d.polygon([(30, 10), (26, 7), (28, 13)], fill=(75, 65, 95, 255))
    d.point([(22, 7), (25, 7)], fill=(255, 40, 60, 255))
    bat.save('assets/images/monsters/bat.png')

    # 3. Armored Beetle (40x20, 2 frames of 20x20)
    beetle = Image.new('RGBA', (40, 20), (0, 0, 0, 0))
    d = ImageDraw.Draw(beetle)
    for i in range(2):
        ox = i * 20
        # Carapace (Hard Bronze / Obsidian shell)
        d.ellipse([ox + 3, 4, ox + 16, 16], fill=(70, 75, 85, 255), outline=(40, 45, 50, 255))
        d.ellipse([ox + 5, 5, ox + 14, 15], fill=(110, 115, 125, 255))
        # Horns / Mandibles
        d.polygon([(ox + 16, 7), (ox + 19, 6), (ox + 16, 9)], fill=(40, 45, 50, 255))
        d.polygon([(ox + 16, 11), (ox + 19, 12), (ox + 16, 13)], fill=(40, 45, 50, 255))
        # Legs
        leg_offset = 1 if i == 1 else 0
        d.line([(ox + 5, 16), (ox + 3, 19 - leg_offset)], fill=(40, 45, 50, 255), width=1)
        d.line([(ox + 10, 16), (ox + 10, 19 + leg_offset)], fill=(40, 45, 50, 255), width=1)
        d.line([(ox + 14, 16), (ox + 16, 19 - leg_offset)], fill=(40, 45, 50, 255), width=1)
        # Eyes
        d.point([(ox + 15, 8), (ox + 15, 12)], fill=(255, 180, 30, 255))
    beetle.save('assets/images/monsters/beetle.png')

    # 4. Ancestral Shadow (48x24, 2 frames of 24x24)
    shadow = Image.new('RGBA', (48, 24), (0, 0, 0, 0))
    d = ImageDraw.Draw(shadow)
    for i in range(2):
        ox = i * 24
        bob = 1 if i == 1 else 0
        # Ethereal Dark Cloak
        d.ellipse([ox + 4, 3 + bob, ox + 19, 21 + bob], fill=(25, 18, 35, 230), outline=(50, 30, 75, 255))
        d.ellipse([ox + 6, 5 + bob, ox + 17, 15 + bob], fill=(15, 10, 25, 255))
        # Glowing Spectral Eyes (Pale Violet / White)
        d.ellipse([ox + 9, 8 + bob, ox + 11, 10 + bob], fill=(180, 130, 255, 255))
        d.ellipse([ox + 13, 8 + bob, ox + 15, 10 + bob], fill=(180, 130, 255, 255))
        # Wispy smoke trails at base
        d.point([(ox + 7, 22), (ox + 11, 23), (ox + 16, 22)], fill=(120, 60, 180, 180))
    shadow.save('assets/images/monsters/shadow.png')

    # 5. Runic Golem (64x32, 2 frames of 32x32: Idle & Stomp)
    golem = Image.new('RGBA', (64, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(golem)
    for i in range(2):
        ox = i * 32
        stomp = 2 if i == 1 else 0
        # Stone Torso
        d.rounded_rectangle([ox + 7, 6 + stomp, ox + 24, 22 + stomp], radius=3, fill=(90, 85, 95, 255), outline=(55, 50, 60, 255))
        # Glowing Rune on Chest (Ancient Cyan)
        d.polygon([(ox + 15, 9 + stomp), (ox + 19, 14 + stomp), (ox + 15, 19 + stomp), (ox + 12, 14 + stomp)], fill=(138, 227, 255, 255))
        d.point([(ox + 15, 14 + stomp)], fill=(255, 255, 255, 255))
        # Heavy Stone Arms
        d.rounded_rectangle([ox + 3, 8 + stomp, ox + 7, 21 + stomp], radius=2, fill=(75, 70, 80, 255))
        d.rounded_rectangle([ox + 24, 8 + stomp, ox + 28, 21 + stomp], radius=2, fill=(75, 70, 80, 255))
        # Legs
        d.rectangle([ox + 9, 22 + stomp, ox + 13, 29], fill=(60, 55, 65, 255))
        d.rectangle([ox + 18, 22 + stomp, ox + 22, 29], fill=(60, 55, 65, 255))
        # Eyes
        d.point([(ox + 13, 7 + stomp), (ox + 18, 7 + stomp)], fill=(138, 227, 255, 255))
    golem.save('assets/images/monsters/golem.png')
    print("Created monster sprites (slime, bat, beetle, shadow, golem)")

def create_equipment():
    # Runic Magic Bolt projectile (16x16)
    bolt = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(bolt)
    d.ellipse([2, 2, 13, 13], fill=(138, 227, 255, 90))
    d.ellipse([4, 4, 11, 11], fill=(138, 227, 255, 220), outline=(255, 255, 255, 255))
    d.ellipse([6, 6, 9, 9], fill=(255, 255, 255, 255))
    bolt.save('assets/images/equipment/magic_bolt.png')

    # Slash Hit Arc (24x24)
    slash = Image.new('RGBA', (24, 24), (0, 0, 0, 0))
    d = ImageDraw.Draw(slash)
    d.arc([2, 2, 21, 21], start=210, end=350, fill=(255, 255, 255, 230), width=3)
    d.arc([4, 4, 19, 19], start=220, end=340, fill=(138, 227, 255, 200), width=1)
    slash.save('assets/images/equipment/slash_arc.png')
    print("Created equipment and effect sprites")

if __name__ == '__main__':
    create_cave_tiles()
    create_monsters()
    create_equipment()
    print("All Stage 6 assets created successfully!")

import os
from PIL import Image, ImageDraw

os.makedirs("assets/images/festivals", exist_ok=True)
os.makedirs("assets/images/boss", exist_ok=True)
os.makedirs("assets/images/ui", exist_ok=True)

# -------------------------------------------------------------
# 1. Festival Decorations Sheet (256x256)
# Slices of festival items:
# Tile (0,0, 64,64) -> Communal Cauldron with golden broth & fragrant herbs
# Tile (64,0, 64,64) -> Great Bonfire with flickering embers and wood logs
# Tile (128,0, 64,64) -> Floating Fire Boat with paper lanterns on water
# Tile (192,0, 64,64) -> Festive Bunting & Flower Arches
# Tile (0,64, 64,64) -> First Seed Spring Banner & Pig Racing Gate
# Tile (64,64, 64,64) -> Forge & Sword Tournament Arena Ring & Oak Trophy
# -------------------------------------------------------------
img_fest = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
draw_fest = ImageDraw.Draw(img_fest)

# 1.1 Communal Cauldron (64x64 at 0, 0)
# Iron tripod & cauldron
draw_fest.ellipse([10, 16, 54, 56], fill=(44, 30, 20), outline=(20, 14, 10))
draw_fest.ellipse([14, 20, 50, 36], fill=(218, 165, 32), outline=(180, 130, 20)) # Golden broth
# Stew ingredients floating
draw_fest.ellipse([20, 24, 26, 28], fill=(220, 80, 60)) # Root
draw_fest.ellipse([34, 22, 42, 28], fill=(60, 160, 80)) # Magic herb
draw_fest.ellipse([26, 28, 36, 34], fill=(255, 230, 120)) # Golden potato
# Steaming vapors
draw_fest.arc([22, 4, 32, 18], start=200, end=340, fill=(240, 240, 255, 180), width=2)
draw_fest.arc([34, 2, 44, 16], start=200, end=340, fill=(240, 240, 255, 180), width=2)
# Wooden fire below
draw_fest.line([16, 58, 48, 58], fill=(100, 60, 30), width=3)
draw_fest.polygon([(26, 58), (32, 48), (38, 58)], fill=(255, 120, 30))

# 1.2 Great Bonfire (64x64 at 64, 0)
bx = 64
# Timber stack
draw_fest.line([bx + 12, 54, bx + 52, 54], fill=(70, 45, 20), width=4)
draw_fest.line([bx + 16, 50, bx + 48, 50], fill=(90, 55, 25), width=4)
draw_fest.line([bx + 20, 46, bx + 44, 46], fill=(110, 65, 30), width=3)
# Fire flames
draw_fest.polygon([(bx + 20, 46), (bx + 32, 10), (bx + 44, 46)], fill=(240, 80, 20))
draw_fest.polygon([(bx + 24, 44), (bx + 32, 18), (bx + 40, 44)], fill=(255, 180, 40))
draw_fest.polygon([(bx + 28, 42), (bx + 32, 26), (bx + 36, 42)], fill=(255, 240, 160))
# Sparks
for sp in [(bx+24, 8), (bx+38, 6), (bx+30, 4), (bx+44, 14)]:
    draw_fest.point(sp, fill=(255, 220, 100))

# 1.3 Floating Fire Boat (64x64 at 128, 0)
fx = 128
# Dark water ripple
draw_fest.ellipse([fx + 6, 46, fx + 58, 60], fill=(20, 40, 70, 180))
# Wooden mini canoe/boat
draw_fest.polygon([(fx + 8, 44), (fx + 20, 52), (fx + 44, 52), (fx + 56, 44)], fill=(120, 80, 40), outline=(80, 50, 25))
# Paper lantern on boat
draw_fest.rectangle([fx + 24, 28, fx + 40, 44], fill=(255, 245, 210), outline=(200, 100, 40), width=2)
draw_fest.ellipse([fx + 28, 32, fx + 36, 40], fill=(255, 140, 30))
# Lantern glow
draw_fest.ellipse([fx + 20, 24, fx + 44, 48], outline=(255, 220, 120, 120), width=1)

# 1.4 Festive Bunting (64x64 at 192, 0)
gx = 192
# Swag rope
draw_fest.arc([gx + 4, 10, gx + 60, 36], start=0, end=180, fill=(80, 60, 40), width=2)
# Colorful cloth triangles
bunting_colors = [(220, 50, 50), (60, 160, 220), (240, 200, 50), (90, 190, 80), (180, 80, 200)]
for i, col in enumerate(bunting_colors):
    px = gx + 8 + i * 10
    py = 22 + (abs(i - 2) * -3)
    draw_fest.polygon([(px, py), (px + 8, py), (px + 4, py + 12)], fill=col)

# 1.5 Spring First Seed Sign & Pig Gate (64x64 at 0, 64)
# Wooden arch with leaf crest
draw_fest.rectangle([10, 74, 16, 120], fill=(90, 60, 30))
draw_fest.rectangle([48, 74, 54, 120], fill=(90, 60, 30))
draw_fest.rectangle([8, 70, 56, 82], fill=(130, 85, 45), outline=(70, 40, 20))
# Green seed crest
draw_fest.ellipse([26, 73, 38, 81], fill=(100, 200, 60))
# Ribbon
draw_fest.line([14, 94, 50, 94], fill=(255, 215, 0), width=2)

# 1.6 Tournament Arena Ring & Oak Trophy (64x64 at 64, 64)
tx = 64
# Wooden sword & shield crossed
draw_fest.ellipse([tx + 18, 76, tx + 46, 104], fill=(150, 150, 160), outline=(80, 80, 90), width=2)
draw_fest.rectangle([tx + 28, 80, tx + 36, 100], fill=(180, 120, 40))
# Crossed swords
draw_fest.line([tx + 12, 72, tx + 52, 112], fill=(210, 210, 220), width=3)
draw_fest.line([tx + 52, 72, tx + 12, 112], fill=(210, 210, 220), width=3)
# Golden wreath
draw_fest.arc([tx + 14, 72, tx + 50, 108], start=45, end=315, fill=(255, 200, 40), width=2)

img_fest.save("assets/images/festivals/festival_decorations.png")
print("Saved assets/images/festivals/festival_decorations.png")

# -------------------------------------------------------------
# 2. Corrupted Mountain Guardian (Boss - 256x64 -> 4 frames of 64x64)
# Frame 0: Phase 1 Armored Form (Thick stone bark, moss, glowing red runes)
# Frame 1: Attack Stance (Roots thrashing, eyes flaring carmine)
# Frame 2: Phase 2 Exposed Heart Core (Glowing fragile green/amber core)
# Frame 3: Purified Form (Lush green moss, white elder blossoms, peaceful)
# -------------------------------------------------------------
img_boss = Image.new("RGBA", (256, 64), (0, 0, 0, 0))
draw_boss = ImageDraw.Draw(img_boss)

for f in range(4):
    ox = f * 64

    if f == 0:
        # Armored Form
        # Big trunk body
        draw_boss.ellipse([ox + 10, 16, ox + 54, 58], fill=(60, 45, 35), outline=(35, 25, 20))
        # Stone plates
        draw_boss.polygon([(ox + 16, 24), (ox + 32, 16), (ox + 48, 24), (ox + 42, 42), (ox + 22, 42)], fill=(110, 105, 95), outline=(70, 65, 60))
        # Twisted branch horns
        draw_boss.line([ox + 18, 18, ox + 8, 4], fill=(50, 35, 25), width=3)
        draw_boss.line([ox + 46, 18, ox + 56, 4], fill=(50, 35, 25), width=3)
        draw_boss.line([ox + 10, 8, ox + 4, 12], fill=(50, 35, 25), width=2)
        draw_boss.line([ox + 54, 8, ox + 60, 12], fill=(50, 35, 25), width=2)
        # Red Corrupted Runes & Eyes
        draw_boss.ellipse([ox + 24, 28, ox + 28, 32], fill=(255, 40, 40))
        draw_boss.ellipse([ox + 36, 28, ox + 40, 32], fill=(255, 40, 40))
        draw_boss.line([ox + 22, 38, ox + 42, 38], fill=(220, 20, 20), width=2)
        draw_boss.line([ox + 32, 34, ox + 32, 46], fill=(220, 20, 20), width=2)
        # Massive root feet
        draw_boss.polygon([(ox + 12, 54), (ox + 22, 54), (ox + 8, 62)], fill=(45, 30, 20))
        draw_boss.polygon([(ox + 42, 54), (ox + 52, 54), (ox + 56, 62)], fill=(45, 30, 20))

    elif f == 1:
        # Attack Stance (Horns extended, red aura)
        draw_boss.ellipse([ox + 8, 14, ox + 56, 56], fill=(70, 45, 35), outline=(40, 25, 20))
        # Spreading root claws
        draw_boss.polygon([(ox + 6, 20), (ox + 0, 38), (ox + 14, 34)], fill=(50, 35, 25))
        draw_boss.polygon([(ox + 58, 20), (ox + 64, 38), (ox + 50, 34)], fill=(50, 35, 25))
        # Horns with fiery red tip
        draw_boss.line([ox + 18, 16, ox + 6, 2], fill=(60, 30, 25), width=4)
        draw_boss.line([ox + 46, 16, ox + 58, 2], fill=(60, 30, 25), width=4)
        draw_boss.point((ox + 6, 2), fill=(255, 60, 60))
        draw_boss.point((ox + 58, 2), fill=(255, 60, 60))
        # Glowing eye beams
        draw_boss.ellipse([ox + 22, 26, ox + 28, 32], fill=(255, 80, 80))
        draw_boss.ellipse([ox + 36, 26, ox + 42, 32], fill=(255, 80, 80))
        draw_boss.line([ox + 20, 40, ox + 44, 40], fill=(255, 50, 50), width=3)

    elif f == 2:
        # Exposed Heart Core (Carapace shattered, glowing lunar green-amber core)
        draw_boss.ellipse([ox + 10, 16, ox + 54, 58], fill=(50, 35, 25), outline=(30, 20, 15))
        # Shattered rock fragments around
        draw_boss.polygon([(ox + 14, 18), (ox + 22, 14), (ox + 20, 24)], fill=(90, 85, 80))
        draw_boss.polygon([(ox + 42, 18), (ox + 50, 14), (ox + 44, 24)], fill=(90, 85, 80))
        # Exposed beating mystical core
        draw_boss.ellipse([ox + 22, 24, ox + 42, 44], fill=(255, 210, 70), outline=(255, 255, 200), width=2)
        draw_boss.ellipse([ox + 26, 28, ox + 38, 40], fill=(120, 240, 160))
        draw_boss.ellipse([ox + 29, 31, ox + 35, 37], fill=(255, 255, 255))
        # Pulsing energy aura
        draw_boss.arc([ox + 18, 20, ox + 46, 48], start=0, end=360, fill=(180, 255, 220, 180), width=1)

    elif f == 3:
        # Purified Form (Elder Nature Guardian: lush moss, silver leaves, gentle cyan eyes)
        draw_boss.ellipse([ox + 10, 16, ox + 54, 58], fill=(75, 95, 60), outline=(45, 60, 35))
        # Green moss & white blossoms on shoulders
        draw_boss.ellipse([ox + 12, 18, ox + 26, 30], fill=(95, 140, 70))
        draw_boss.ellipse([ox + 38, 18, ox + 52, 30], fill=(95, 140, 70))
        draw_boss.ellipse([ox + 18, 14, ox + 22, 18], fill=(255, 255, 255))
        draw_boss.ellipse([ox + 42, 14, ox + 46, 18], fill=(255, 255, 255))
        # Regal branch antlers
        draw_boss.line([ox + 18, 18, ox + 10, 4], fill=(90, 70, 50), width=3)
        draw_boss.line([ox + 46, 18, ox + 54, 4], fill=(90, 70, 50), width=3)
        # Gentle glowing cyan eyes
        draw_boss.ellipse([ox + 24, 28, ox + 28, 32], fill=(140, 230, 255))
        draw_boss.ellipse([ox + 36, 28, ox + 40, 32], fill=(140, 230, 255))
        # Smile
        draw_boss.arc([ox + 26, 36, ox + 38, 44], start=20, end=160, fill=(45, 60, 35), width=2)

img_boss.save("assets/images/boss/corrupted_guardian.png")
print("Saved assets/images/boss/corrupted_guardian.png")

# -------------------------------------------------------------
# 3. Grandfather in Amber Crystal (96x48 -> 2 frames: frozen, shattered)
# -------------------------------------------------------------
img_amber = Image.new("RGBA", (96, 48), (0, 0, 0, 0))
draw_amber = ImageDraw.Draw(img_amber)

# Frame 0: Frozen Amber Crystal with Grandfather's silhouette
draw_amber.polygon([(16, 4), (32, 2), (40, 16), (36, 42), (18, 44), (8, 22)], fill=(230, 150, 40, 220), outline=(255, 200, 80))
# Inner silhouette of Grandfather (farmer hat and beard)
draw_amber.ellipse([20, 12, 28, 20], fill=(80, 50, 20, 160)) # Head
draw_amber.polygon([(16, 14), (32, 14), (24, 8)], fill=(100, 70, 30, 180)) # Straw hat
draw_amber.polygon([(18, 22), (30, 22), (28, 36), (18, 36)], fill=(50, 30, 15, 160)) # Coat
draw_amber.polygon([(20, 18), (28, 18), (24, 25)], fill=(220, 220, 220, 180)) # Beard
# Crystal facets & glints
draw_amber.line([16, 4, 24, 24], fill=(255, 230, 140, 180), width=1)
draw_amber.line([24, 24, 36, 42], fill=(255, 230, 140, 180), width=1)
draw_amber.point((30, 8), fill=(255, 255, 255))

# Frame 1: Shattered Amber & Freed Grandfather
ox = 48
# Shards on ground
draw_amber.polygon([(ox + 6, 38), (ox + 14, 44), (ox + 10, 42)], fill=(230, 150, 40))
draw_amber.polygon([(ox + 34, 40), (ox + 42, 44), (ox + 38, 36)], fill=(230, 150, 40))
# Grandfather standing, smiling and waving
draw_amber.ellipse([ox + 20, 10, ox + 28, 18], fill=(235, 195, 165)) # Face
draw_amber.polygon([(ox + 16, 12), (ox + 32, 12), (ox + 24, 6)], fill=(160, 120, 60)) # Hat
draw_amber.polygon([(ox + 20, 16), (ox + 28, 16), (ox + 24, 23)], fill=(240, 240, 240)) # Beard
draw_amber.rectangle([ox + 18, 20, ox + 30, 36], fill=(60, 90, 140)) # Blue overalls
draw_amber.line([ox + 18, 24, ox + 12, 18], fill=(235, 195, 165), width=2) # Waving hand
draw_amber.line([ox + 20, 36, ox + 20, 46], fill=(50, 40, 30), width=3) # Legs
draw_amber.line([ox + 28, 36, ox + 28, 46], fill=(50, 40, 30), width=3)

img_amber.save("assets/images/boss/grandfather_amber.png")
print("Saved assets/images/boss/grandfather_amber.png")

# -------------------------------------------------------------
# 4. Lunar Tree of Light (144x48 -> 3 stages of 48x48)
# Stage 1: Sacred Lunar Seed planted in sacred tilled soil
# Stage 2: Luminescent Sapling (Glowing silver stems, blue dew)
# Stage 3: Full Tree of Light (Golden radiant trunk, silver-blue canopy)
# -------------------------------------------------------------
img_tree = Image.new("RGBA", (144, 48), (0, 0, 0, 0))
draw_tree = ImageDraw.Draw(img_tree)

# Stage 1 (0 to 48): Sacred Seed
draw_tree.ellipse([16, 36, 32, 44], fill=(90, 60, 30)) # Sacred mound
draw_tree.ellipse([21, 34, 27, 40], fill=(140, 220, 255), outline=(255, 255, 255))
draw_tree.line([24, 30, 24, 34], fill=(180, 255, 210), width=2) # Small sprout

# Stage 2 (48 to 96): Luminescent Sapling
ox = 48
draw_tree.ellipse([ox + 14, 38, ox + 34, 44], fill=(90, 60, 30))
draw_tree.line([ox + 24, 40, ox + 24, 20], fill=(200, 230, 255), width=3)
draw_tree.arc([ox + 14, 16, ox + 34, 32], start=180, end=360, fill=(100, 210, 255), width=2)
draw_tree.ellipse([ox + 12, 14, ox + 20, 20], fill=(180, 255, 230))
draw_tree.ellipse([ox + 28, 14, ox + 36, 20], fill=(180, 255, 230))

# Stage 3 (96 to 144): Full Tree of Light
ox = 96
# Radiant Trunk
draw_tree.polygon([(ox + 20, 44), (ox + 28, 44), (ox + 26, 22), (ox + 22, 22)], fill=(210, 180, 120), outline=(255, 240, 180))
# Great Silver Canopy
draw_tree.ellipse([ox + 6, 4, ox + 42, 28], fill=(120, 210, 255, 220), outline=(220, 245, 255), width=2)
draw_tree.ellipse([ox + 12, 8, ox + 36, 24], fill=(200, 245, 255, 240))
# Lunar Stars/Blossoms
for bx, by in [(ox+14, 12), (ox+24, 8), (ox+34, 14), (ox+20, 20), (ox+28, 18)]:
    draw_tree.point((bx, by), fill=(255, 255, 255))
    draw_tree.point((bx+1, by), fill=(255, 255, 180))

img_tree.save("assets/images/boss/lunar_tree.png")
print("Saved assets/images/boss/lunar_tree.png")

# -------------------------------------------------------------
# 5. Title Screen Logo ("Valley Moon" Emblem - 280x90)
# -------------------------------------------------------------
img_logo = Image.new("RGBA", (280, 90), (0, 0, 0, 0))
draw_logo = ImageDraw.Draw(img_logo)

# Glowing full moon in background
draw_logo.ellipse([100, 4, 180, 84], fill=(255, 250, 220, 230), outline=(180, 225, 255), width=3)
draw_logo.ellipse([115, 14, 135, 34], fill=(240, 235, 200, 160)) # Moon crater
draw_logo.ellipse([145, 40, 165, 60], fill=(240, 235, 200, 160)) # Moon crater

# Rustic Wooden Plaque behind title
draw_logo.polygon([(20, 28), (260, 28), (270, 48), (260, 68), (20, 68), (10, 48)], fill=(60, 40, 20), outline=(130, 85, 45), width=3)
draw_logo.line([(24, 32), (256, 32)], fill=(90, 60, 30), width=1)
draw_logo.line([(24, 64), (256, 64)], fill=(90, 60, 30), width=1)

# Twin wheat stalks on sides
draw_logo.arc([14, 24, 36, 72], start=120, end=260, fill=(255, 215, 0), width=2)
draw_logo.arc([244, 24, 266, 72], start=280, end=60, fill=(255, 215, 0), width=2)

img_logo.save("assets/images/ui/title_logo.png")
print("Saved assets/images/ui/title_logo.png")

print("All Stage 7 visual assets generated successfully!")

import os
from PIL import Image, ImageDraw

os.makedirs("assets/images/cabin", exist_ok=True)
os.makedirs("assets/images/characters", exist_ok=True)
os.makedirs("assets/images/artisan", exist_ok=True)

# -------------------------------------------------------------------------
# 1. Cabin Interiors & House Upgrade Tileset (256x256)
# Slices:
# (0, 0, 64, 64): Rustic Wood-Fired Kitchen Stove & Stone Hearth with kettle
# (64, 0, 64, 64): Wooden Kitchen Prep Counter with cutting board, knife & garlic
# (128, 0, 64, 64): Carved Cedar Matrimonial Bed with patchwork quilt & pillows
# (192, 0, 64, 64): Wicker Baby Crib with cozy blanket and starry mobile
# (0, 64, 64, 64): Toddler Bed with colorful quilt and nightstand
# (64, 64, 64, 64): Rustic Wooden Toybox & Rocking Horse
# (128, 64, 64, 64): Oak Dining Table with 2 chairs and clay bowl
# (192, 64, 64, 64): Hearth Fireplace with stone mantel and oil lamp
# -------------------------------------------------------------------------
img_cabin = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
draw_cabin = ImageDraw.Draw(img_cabin)

# 1.1 Wood-Fired Stove & Stone Hearth (0, 0, 64, 64)
# Stone stove base
draw_cabin.rectangle([10, 20, 54, 58], fill=(90, 85, 80), outline=(50, 45, 40), width=2)
# Cast iron stovetop
draw_cabin.rectangle([8, 16, 56, 26], fill=(45, 45, 50), outline=(25, 25, 30))
# Cast iron burners
draw_cabin.ellipse([14, 18, 28, 24], fill=(30, 30, 35))
draw_cabin.ellipse([36, 18, 50, 24], fill=(30, 30, 35))
# Firebox door with glowing embers
draw_cabin.rectangle([18, 34, 46, 52], fill=(35, 35, 40), outline=(20, 20, 25))
draw_cabin.rectangle([22, 38, 42, 48], fill=(230, 90, 30))
draw_cabin.polygon([(26, 46), (32, 40), (38, 46)], fill=(255, 200, 50))
# Copper kettle on left burner
draw_cabin.rectangle([17, 8, 25, 18], fill=(190, 100, 50), outline=(130, 60, 30))
draw_cabin.line([25, 12, 29, 10], fill=(190, 100, 50), width=2) # Spout
draw_cabin.arc([15, 6, 27, 14], start=180, end=360, fill=(70, 70, 75), width=2) # Handle

# 1.2 Kitchen Prep Counter (64, 0, 64, 64)
cx = 64
# Timber counter
draw_cabin.rectangle([cx + 8, 22, cx + 56, 58], fill=(130, 85, 45), outline=(75, 45, 20), width=2)
draw_cabin.line([cx + 8, 40, cx + 56, 40], fill=(90, 55, 25), width=2)
# Handles
draw_cabin.line([cx + 20, 48, cx + 24, 48], fill=(200, 160, 60), width=2)
draw_cabin.line([cx + 40, 48, cx + 44, 48], fill=(200, 160, 60), width=2)
# Polished wooden cutting board
draw_cabin.rectangle([cx + 14, 16, cx + 36, 24], fill=(210, 165, 110), outline=(150, 105, 60))
# Red turnip & herb on board
draw_cabin.ellipse([cx + 18, 17, cx + 24, 23], fill=(210, 60, 60))
draw_cabin.line([cx + 26, 18, cx + 32, 22], fill=(60, 160, 60), width=2)
# Iron cleaver
draw_cabin.line([cx + 40, 17, cx + 48, 17], fill=(180, 180, 190), width=3)
draw_cabin.line([cx + 48, 17, cx + 52, 17], fill=(100, 60, 30), width=2)

# 1.3 Carved Matrimonial Bed (128, 0, 64, 64)
bx = 128
# Rich cedar headboard with heart/moon crest
draw_cabin.rectangle([bx + 8, 6, bx + 56, 26], fill=(110, 65, 35), outline=(65, 35, 15), width=2)
draw_cabin.ellipse([bx + 28, 10, bx + 36, 18], fill=(255, 215, 80)) # Moon crest
# Bed frame
draw_cabin.rectangle([bx + 10, 22, bx + 54, 58], fill=(140, 90, 50), outline=(75, 45, 20), width=2)
# Mattress & Quilt
draw_cabin.rectangle([bx + 14, 24, bx + 50, 54], fill=(240, 230, 210))
# Two feather pillows
draw_cabin.rectangle([bx + 16, 20, bx + 30, 28], fill=(255, 255, 250), outline=(210, 205, 195))
draw_cabin.rectangle([bx + 34, 20, bx + 48, 28], fill=(255, 255, 250), outline=(210, 205, 195))
# Patchwork Quilt (Rose and Cyan)
draw_cabin.rectangle([bx + 14, 32, bx + 50, 54], fill=(190, 75, 95), outline=(130, 40, 55))
draw_cabin.rectangle([bx + 20, 38, bx + 32, 48], fill=(85, 150, 180))
draw_cabin.rectangle([bx + 32, 38, bx + 44, 48], fill=(225, 185, 90))

# 1.4 Nursery Wicker Crib (192, 0, 64, 64)
crx = 192
# Curved wicker crib body
draw_cabin.ellipse([crx + 12, 18, crx + 52, 54], fill=(185, 140, 90), outline=(125, 90, 50), width=2)
# Slats
for s in range(crx + 18, crx + 48, 6):
    draw_cabin.line([s, 24, s, 48], fill=(130, 95, 55), width=2)
# Soft baby pillow and blanket
draw_cabin.ellipse([crx + 18, 24, crx + 30, 34], fill=(255, 255, 255))
draw_cabin.ellipse([crx + 22, 28, crx + 46, 48], fill=(120, 200, 230))
# Wooden canopy pole and stars mobile
draw_cabin.line([crx + 14, 18, crx + 14, 4], fill=(110, 75, 40), width=2)
draw_cabin.line([crx + 14, 4, crx + 32, 4], fill=(110, 75, 40), width=2)
draw_cabin.line([crx + 26, 4, crx + 26, 12], fill=(200, 200, 200), width=1)
draw_cabin.polygon([(crx + 26, 10), (crx + 28, 14), (crx + 24, 14)], fill=(255, 225, 80))

# 1.5 Toddler Bed (0, 64, 64, 64)
by = 64
draw_cabin.rectangle([14, by + 12, 50, by + 56], fill=(120, 80, 45), outline=(70, 40, 20), width=2)
draw_cabin.rectangle([18, by + 18, 46, by + 26], fill=(255, 255, 255), outline=(210, 205, 195))
draw_cabin.rectangle([18, by + 28, 46, by + 52], fill=(90, 160, 110), outline=(50, 110, 70))

# 1.6 Toybox & Rocking Horse (64, 64, 64, 64)
tyx = 64
# Toybox
draw_cabin.rectangle([tyx + 8, by + 26, tyx + 34, by + 52], fill=(175, 115, 60), outline=(100, 60, 25), width=2)
draw_cabin.polygon([(tyx + 8, by + 26), (tyx + 34, by + 26), (tyx + 30, by + 18), (tyx + 12, by + 18)], fill=(195, 135, 75))
# Plush doll peeking out
draw_cabin.ellipse([tyx + 16, by + 16, tyx + 26, by + 26], fill=(240, 190, 160))
# Wooden Rocking Horse
draw_cabin.arc([tyx + 38, by + 46, tyx + 58, by + 58], start=0, end=180, fill=(110, 70, 35), width=2) # Rocker
draw_cabin.polygon([(tyx + 44, by + 48), (tyx + 50, by + 30), (tyx + 54, by + 26), (tyx + 48, by + 26), (tyx + 42, by + 48)], fill=(150, 95, 50))

img_cabin.save("assets/images/cabin/cabin_interiors.png")
print("Saved assets/images/cabin/cabin_interiors.png")

# -------------------------------------------------------------------------
# 2. Children & Baby Sprites (128x64)
# 4 frames of 32x32:
# (0, 0, 32, 32) -> Baby crawling / sitting in swaddle (Frame A)
# (32, 0, 32, 32) -> Baby happy with arms up (Frame B)
# (64, 0, 32, 32) -> Toddler boy in brown overalls & cap
# (96, 0, 32, 32) -> Toddler girl in rustic green dress & flower
# -------------------------------------------------------------------------
img_child = Image.new("RGBA", (128, 64), (0, 0, 0, 0))
draw_child = ImageDraw.Draw(img_child)

# 2.1 Baby Swaddle Frame A (32x32 at 0, 0)
draw_child.ellipse([8, 12, 24, 28], fill=(135, 205, 235), outline=(90, 160, 190))
draw_child.ellipse([11, 6, 21, 16], fill=(255, 218, 185)) # Face
draw_child.point((14, 10), fill=(50, 40, 30)) # Left eye
draw_child.point((18, 10), fill=(50, 40, 30)) # Right eye
draw_child.arc([14, 11, 18, 14], start=0, end=180, fill=(210, 90, 90)) # Smile
draw_child.arc([13, 4, 19, 8], start=180, end=360, fill=(140, 90, 40), width=2) # Brown tuft of hair

# 2.2 Baby Happy Frame B (32x32 at 32, 0)
cx = 32
draw_child.ellipse([cx + 8, 12, cx + 24, 28], fill=(245, 170, 190), outline=(190, 120, 140))
draw_child.ellipse([cx + 11, 6, cx + 21, 16], fill=(255, 218, 185))
draw_child.point((cx + 14, 10), fill=(50, 40, 30))
draw_child.point((cx + 18, 10), fill=(50, 40, 30))
draw_child.ellipse([cx + 14, 11, cx + 18, 14], fill=(220, 80, 80)) # Open laugh
# Tiny baby hands up
draw_child.circle((cx + 6, 12), 2, fill=(255, 218, 185))
draw_child.circle((cx + 26, 12), 2, fill=(255, 218, 185))

# 2.3 Toddler Boy (32x32 at 64, 0)
bx = 64
draw_child.ellipse([bx + 11, 4, bx + 21, 14], fill=(255, 218, 185)) # Face
draw_child.rectangle([bx + 10, 3, bx + 22, 7], fill=(120, 75, 40)) # Cap
draw_child.point((bx + 14, 8), fill=(40, 35, 30))
draw_child.point((bx + 18, 8), fill=(40, 35, 30))
draw_child.arc([bx + 14, 9, bx + 18, 12], start=0, end=180, fill=(200, 80, 80))
# Overalls & shirt
draw_child.rectangle([bx + 10, 14, bx + 22, 24], fill=(70, 100, 150)) # Blue overalls
draw_child.rectangle([bx + 11, 24, bx + 15, 29], fill=(55, 80, 125)) # Left leg
draw_child.rectangle([bx + 17, 24, bx + 21, 29], fill=(55, 80, 125)) # Right leg
draw_child.rectangle([bx + 10, 28, bx + 15, 31], fill=(60, 40, 20)) # Shoes
draw_child.rectangle([bx + 17, 28, bx + 21, 31], fill=(60, 40, 20))

# 2.4 Toddler Girl (32x32 at 96, 0)
gx = 96
draw_child.ellipse([gx + 11, 4, gx + 21, 14], fill=(255, 218, 185))
# Pigtails
draw_child.ellipse([gx + 8, 4, gx + 12, 10], fill=(140, 85, 40))
draw_child.ellipse([gx + 20, 4, gx + 24, 10], fill=(140, 85, 40))
draw_child.point((gx + 9, 3), fill=(255, 105, 180)) # Pink ribbon
draw_child.point((gx + 23, 3), fill=(255, 105, 180))
draw_child.point((gx + 14, 8), fill=(40, 35, 30))
draw_child.point((gx + 18, 8), fill=(40, 35, 30))
draw_child.arc([gx + 14, 9, gx + 18, 12], start=0, end=180, fill=(200, 80, 80))
# Dress
draw_child.polygon([(gx + 13, 14), (gx + 19, 14), (gx + 24, 26), (gx + 8, 26)], fill=(80, 160, 100)) # Green dress
draw_child.rectangle([gx + 12, 26, gx + 15, 31], fill=(255, 218, 185)) # Legs
draw_child.rectangle([gx + 17, 26, gx + 20, 31], fill=(255, 218, 185))
draw_child.rectangle([gx + 11, 29, gx + 15, 31], fill=(180, 50, 70)) # Red shoes
draw_child.rectangle([gx + 17, 29, gx + 21, 31], fill=(180, 50, 70))

img_child.save("assets/images/characters/children.png")
print("Saved assets/images/characters/children.png")

# -------------------------------------------------------------------------
# 3. Rustic Artisan Machinery & Stations (192x64 -> 4 stations of 48x48)
# (0, 0, 48, 48) -> Tear de Madeira (Wooden Loom)
# (48, 0, 48, 48) -> Barril de Carvalho (Oak Aging Cask)
# (96, 0, 48, 48) -> Fornalha Rúnica (Dual Crucible Runic Furnace)
# (144, 0, 48, 48) -> Pote de Picles / Prensa de Óleo (Preserves Jar / Oil Press)
# -------------------------------------------------------------------------
img_mach = Image.new("RGBA", (192, 64), (0, 0, 0, 0))
draw_mach = ImageDraw.Draw(img_mach)

# 3.1 Wooden Loom (48x48 at 0, 8)
# Frame uprights
draw_mach.rectangle([6, 12, 10, 44], fill=(110, 70, 35), outline=(65, 35, 15))
draw_mach.rectangle([38, 12, 42, 44], fill=(110, 70, 35), outline=(65, 35, 15))
draw_mach.rectangle([6, 12, 42, 16], fill=(130, 85, 45), outline=(75, 45, 20))
draw_mach.rectangle([6, 40, 42, 44], fill=(130, 85, 45), outline=(75, 45, 20))
# Warp vertical threads
for tx in range(12, 38, 3):
    draw_mach.line([tx, 16, tx, 40], fill=(245, 240, 230), width=1)
# Shuttle & woven cloth roll
draw_mach.rectangle([12, 30, 36, 38], fill=(160, 210, 240)) # Celestial cloth
draw_mach.polygon([(16, 26), (32, 26), (30, 23), (18, 23)], fill=(200, 140, 70)) # Shuttle

# 3.2 Oak Cask / Aging Barrel (48x48 at 48, 8)
ox = 48
# Wooden Barrel stand
draw_mach.polygon([(ox + 8, 44), (ox + 14, 38), (ox + 18, 44)], fill=(80, 50, 25))
draw_mach.polygon([(ox + 30, 44), (ox + 34, 38), (ox + 40, 44)], fill=(80, 50, 25))
# Rounded barrel body
draw_mach.ellipse([ox + 10, 12, ox + 38, 42], fill=(130, 80, 40), outline=(75, 40, 15), width=2)
# Staves & Iron Hoops
draw_mach.line([ox + 12, 20, ox + 36, 20], fill=(70, 70, 75), width=2)
draw_mach.line([ox + 12, 34, ox + 36, 34], fill=(70, 70, 75), width=2)
draw_mach.line([ox + 24, 12, ox + 24, 42], fill=(95, 55, 25), width=1)
# Brass spigot & bung
draw_mach.circle((ox + 24, 27), 2, fill=(215, 175, 50))
# Bubble
draw_mach.circle((ox + 34, 10), 2, fill=(180, 220, 255))

# 3.3 Runic Furnace (48x48 at 96, 8)
fx = 96
# Stone twin forge
draw_mach.rectangle([fx + 6, 16, fx + 42, 44], fill=(85, 80, 75), outline=(45, 40, 35), width=2)
# Dual glowing crucibles
draw_mach.ellipse([fx + 10, 20, fx + 22, 36], fill=(240, 90, 20), outline=(255, 210, 50))
draw_mach.ellipse([fx + 26, 20, fx + 38, 36], fill=(40, 180, 230), outline=(150, 240, 255))
# Chimney with sparks
draw_mach.rectangle([fx + 18, 6, fx + 30, 16], fill=(65, 60, 55))
draw_mach.point((fx + 22, 4), fill=(255, 180, 40))
draw_mach.point((fx + 26, 2), fill=(100, 220, 255))
# Runic carvings on front
draw_mach.line([fx + 8, 40, fx + 18, 40], fill=(100, 220, 255), width=1)
draw_mach.line([fx + 30, 40, fx + 40, 40], fill=(255, 200, 50), width=1)

# 3.4 Preserves Jar & Oil Press (48x48 at 144, 8)
px = 144
# Stoneware ceramic jar
draw_mach.ellipse([px + 12, 18, px + 36, 42], fill=(230, 220, 200), outline=(160, 150, 130), width=2)
# Jar lid & cloth tied with twine
draw_mach.rectangle([px + 16, 14, px + 32, 20], fill=(180, 60, 60), outline=(120, 30, 30))
draw_mach.line([px + 14, 19, px + 34, 19], fill=(240, 210, 140), width=1)
# Jam label with fruit mark
draw_mach.rectangle([px + 18, 26, px + 30, 34], fill=(250, 245, 230))
draw_mach.circle((px + 24, 30), 2, fill=(160, 40, 120)) # Berry

img_mach.save("assets/images/artisan/artisan_machines.png")
print("Saved assets/images/artisan/artisan_machines.png")

# -------------------------------------------------------------------------
# 4. Artisan Goods & Cooked Dishes Sheet (128x128 -> 16 icons of 32x32)
# (0, 0): Queijo Rústico Curado (Wheel of golden artisanal cheese)
# (32, 0): Queijo Místico Dourado (Glowing cheese with starry wax)
# (64, 0): Vinho de Amora Lunar (Vintage dark glass bottle)
# (96, 0): Geleia Lunar Mística (Shimmering jar of preserve)
# (0, 32): Tecido de Nuvem Lunar (Roll of silk celestial cloth)
# (32, 32): Novelo de Fio Nobre (Spool of fine wool)
# (64, 32): Óleo de Trufa Mística (Elixir flask of fragrant oil)
# (96, 32): Liga de Bronze Rúnico (Dual-tone heavy metal bar)
# (0, 64): Amálgama Astral (Glowing star metal bar)
# (32, 64): Sopa de Nabo Caipira (Clay bowl with steaming vegetables)
# (64, 64): Pão de Trigo Dourado (Crusty golden oven loaf)
# (96, 64): Torta de Amora Lunar (Glazed lattice pie)
# (0, 96): Omelete de Âmbar (Folded herb omelette on plate)
# -------------------------------------------------------------------------
img_goods = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
draw_goods = ImageDraw.Draw(img_goods)

# 4.1 Cured Cheese (0, 0, 32, 32)
draw_goods.polygon([(6, 18), (16, 10), (26, 18), (26, 24), (6, 24)], fill=(245, 195, 60), outline=(190, 140, 30))
draw_goods.ellipse([10, 18, 14, 21], fill=(215, 165, 40)) # Hole
draw_goods.ellipse([18, 16, 22, 19], fill=(215, 165, 40))

# 4.2 Mystic Golden Cheese (32, 0, 32, 32)
draw_goods.polygon([(38, 18), (48, 10), (58, 18), (58, 24), (38, 24)], fill=(255, 220, 80), outline=(220, 160, 20))
draw_goods.circle((48, 16), 2, fill=(255, 255, 255)) # Sparkle
draw_goods.circle((42, 20), 1, fill=(100, 220, 255))

# 4.3 Lunar Wine Bottle (64, 0, 32, 32)
draw_goods.rectangle([76, 14, 84, 26], fill=(80, 20, 50), outline=(40, 10, 25))
draw_goods.rectangle([78, 6, 82, 14], fill=(70, 20, 45))
draw_goods.rectangle([78, 4, 82, 6], fill=(190, 140, 80)) # Cork
draw_goods.rectangle([77, 18, 83, 23], fill=(245, 235, 210)) # Label

# 4.4 Mystic Jam Jar (96, 0, 32, 32)
draw_goods.ellipse([102, 12, 122, 26], fill=(170, 40, 130), outline=(110, 20, 80))
draw_goods.rectangle([106, 8, 118, 14], fill=(230, 215, 180), outline=(150, 130, 90))

# 4.5 Celestial Cloth (0, 32, 32, 32)
draw_goods.ellipse([6, 42, 26, 54], fill=(160, 215, 245), outline=(100, 160, 200))
draw_goods.line([10, 44, 22, 52], fill=(255, 255, 255), width=2)

# 4.6 Wool Yarn Spool (32, 32, 32, 32)
draw_goods.ellipse([38, 40, 58, 56], fill=(235, 230, 215), outline=(180, 175, 160))
draw_goods.line([44, 42, 52, 54], fill=(200, 195, 180), width=2)
draw_goods.line([54, 52, 60, 56], fill=(235, 230, 215), width=2) # Stray thread

# 4.7 Truffle Oil Flask (64, 32, 32, 32)
draw_goods.polygon([(78, 40), (82, 40), (86, 54), (74, 54)], fill=(225, 185, 75), outline=(160, 120, 40))
draw_goods.rectangle([79, 36, 81, 40], fill=(160, 100, 50)) # Cork
draw_goods.point((80, 46), fill=(255, 245, 180))

# 4.8 Runic Bronze Ingot (96, 32, 32, 32)
draw_goods.polygon([(100, 46), (106, 38), (122, 38), (116, 46)], fill=(210, 130, 60), outline=(150, 80, 30))
draw_goods.polygon([(100, 46), (116, 46), (116, 54), (100, 54)], fill=(170, 95, 40), outline=(120, 60, 20))
draw_goods.line([106, 42, 116, 42], fill=(100, 240, 255), width=1) # Cyan rune

# 4.9 Astral Amalgam Bar (0, 64, 32, 32)
draw_goods.polygon([(4, 78), (10, 70), (26, 70), (20, 78)], fill=(245, 215, 100), outline=(180, 150, 40))
draw_goods.polygon([(4, 78), (20, 78), (20, 86), (4, 86)], fill=(205, 175, 60), outline=(150, 120, 30))
draw_goods.circle((13, 74), 2, fill=(255, 255, 255)) # Glistening star

# 4.10 Turnip Stew Bowl (32, 64, 32, 32)
draw_goods.ellipse([36, 74, 60, 88], fill=(165, 90, 50), outline=(110, 50, 25))
draw_goods.ellipse([38, 74, 58, 82], fill=(220, 160, 70)) # Stew broth
draw_goods.circle((44, 78), 2, fill=(210, 60, 60)) # Turnip
draw_goods.circle((52, 78), 2, fill=(60, 170, 70)) # Herbs

# 4.11 Golden Loaf Bread (64, 64, 32, 32)
draw_goods.ellipse([68, 72, 92, 86], fill=(215, 145, 55), outline=(150, 90, 25))
draw_goods.line([74, 75, 76, 81], fill=(255, 215, 120), width=1) # Scored crust
draw_goods.line([80, 75, 82, 81], fill=(255, 215, 120), width=1)
draw_goods.line([86, 75, 88, 81], fill=(255, 215, 120), width=1)

# 4.12 Moonberry Pie (96, 64, 32, 32)
draw_goods.ellipse([100, 72, 124, 88], fill=(200, 130, 60), outline=(140, 80, 30))
draw_goods.ellipse([102, 73, 122, 85], fill=(130, 30, 80)) # Berry filling
# Lattice crust
draw_mach.line([106, 75, 118, 83], fill=(230, 170, 90), width=2)
draw_mach.line([106, 83, 118, 75], fill=(230, 170, 90), width=2)

# 4.13 Amber Omelette (0, 96, 32, 32)
draw_goods.ellipse([4, 106, 28, 122], fill=(240, 235, 220), outline=(180, 175, 160)) # Ceramic plate
draw_goods.polygon([(8, 114), (16, 108), (24, 114), (18, 120), (10, 118)], fill=(255, 195, 40), outline=(210, 145, 20))

img_goods.save("assets/images/artisan/artisan_goods.png")
print("Saved assets/images/artisan/artisan_goods.png")

print("All Stage 8 visual assets generated successfully!")

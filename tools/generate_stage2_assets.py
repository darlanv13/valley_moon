import os
from PIL import Image, ImageDraw

def create_crops_spritesheet():
    # 5 stages: 0=Seed, 1=Sprout, 2=Growing, 3=Mature, 4=Withered
    # 5 crops:
    # 0 = Nabo Rústico (Turnip)
    # 1 = Trigo Comum (Common Wheat)
    # 2 = Raiz-Gritante (Screaming Root - Eerie Violet/Magenta)
    # 3 = Flor-de-Orvalho (Dewdrop Blossom - Bioluminescent Cyan)
    # 4 = Trigo-Dourado (Golden Moonwheat - Shimmering Gold)

    basic_plants = Image.open('assets/images/tiles/basic_plants.png') # 96x32

    crops = Image.new('RGBA', (5 * 16, 5 * 16), (0, 0, 0, 0))

    # Helper: create common withered plant (Stage 4)
    withered = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    wd = ImageDraw.Draw(withered)
    # Shriveled dried brown/grey stalks
    wd.line([(8, 14), (8, 9), (6, 7), (4, 9)], fill=(110, 95, 80, 255), width=1)
    wd.line([(8, 11), (11, 8), (13, 10)], fill=(90, 80, 70, 255), width=1)
    wd.point([(5, 10), (12, 11), (7, 13)], fill=(75, 65, 55, 255))

    # 1. Row 0: Nabo (Turnip)
    # Stage 0: Seed (from basic_plants (0, 0))
    crops.paste(basic_plants.crop((0, 0, 16, 16)), (0, 0))
    # Stage 1: Sprout (basic_plants (16, 0))
    crops.paste(basic_plants.crop((16, 0, 32, 16)), (16, 0))
    # Stage 2: Growing (basic_plants (32, 0))
    crops.paste(basic_plants.crop((32, 0, 48, 16)), (32, 0))
    # Stage 3: Mature Turnip (basic_plants (64, 0))
    crops.paste(basic_plants.crop((64, 0, 80, 16)), (48, 0))
    # Stage 4: Withered
    crops.paste(withered, (64, 0))

    # 2. Row 1: Trigo Comum (Common Wheat)
    crops.paste(basic_plants.crop((0, 16, 16, 32)), (0, 16))
    crops.paste(basic_plants.crop((16, 16, 32, 32)), (16, 16))
    crops.paste(basic_plants.crop((32, 16, 48, 32)), (32, 16))
    crops.paste(basic_plants.crop((64, 16, 80, 32)), (48, 16))
    crops.paste(withered, (64, 16))

    # 3. Row 2: Raiz-Gritante (Screaming Mandrake Root - Eerie Violet & Glowing Veins)
    # Stage 0: Purple seed
    s2 = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(s2)
    d.ellipse([6, 11, 9, 14], fill=(130, 60, 180, 255), outline=(70, 20, 100, 255))
    d.point([(7, 12)], fill=(220, 150, 255, 255))
    crops.paste(s2, (0, 32))

    # Stage 1: Sprout with eerie purple eyespots
    sp2 = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(sp2)
    d.line([(8, 14), (8, 9)], fill=(110, 50, 150, 255), width=1)
    d.ellipse([5, 6, 8, 9], fill=(80, 160, 70, 255))
    d.ellipse([8, 6, 11, 9], fill=(160, 60, 210, 255))
    d.point([(7, 7), (9, 7)], fill=(255, 100, 220, 255))
    crops.paste(sp2, (16, 32))

    # Stage 2: Growing Mandrake
    gr2 = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(gr2)
    d.ellipse([5, 8, 11, 14], fill=(150, 60, 190, 255), outline=(80, 20, 120, 255))
    d.polygon([(8, 8), (4, 4), (7, 4)], fill=(60, 150, 60, 255))
    d.polygon([(8, 8), (12, 4), (9, 4)], fill=(120, 40, 170, 255))
    d.point([(7, 10), (9, 10)], fill=(255, 180, 255, 255))
    crops.paste(gr2, (32, 32))

    # Stage 3: Mature Screaming Root (Mandrake head screaming with runic aura)
    mat2 = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(mat2)
    # Twisted root body
    d.polygon([(4, 15), (8, 6), (12, 15), (8, 14)], fill=(170, 70, 210, 255), outline=(90, 30, 120, 255))
    # Mandrake face
    d.rectangle([6, 9, 7, 10], fill=(255, 230, 255, 255)) # left eye
    d.rectangle([9, 9, 10, 10], fill=(255, 230, 255, 255)) # right eye
    d.ellipse([7, 11, 9, 13], fill=(50, 10, 70, 255)) # screaming mouth!
    # Foliage crown
    d.polygon([(8, 6), (3, 2), (6, 4)], fill=(60, 170, 70, 255))
    d.polygon([(8, 6), (13, 2), (10, 4)], fill=(60, 170, 70, 255))
    d.polygon([(8, 6), (8, 1), (9, 3)], fill=(190, 80, 240, 255))
    # Magic glow particles
    d.point([(2, 5), (13, 7), (14, 11)], fill=(230, 140, 255, 255))
    crops.paste(mat2, (48, 32))

    # Stage 4: Withered (purple tint)
    w2 = withered.copy()
    w2_tint = Image.new('RGBA', (16, 16), (100, 40, 130, 70))
    w2 = Image.alpha_composite(w2, w2_tint)
    crops.paste(w2, (64, 32))

    # 4. Row 3: Flor-de-Orvalho (Dewdrop Moon Blossom - Bioluminescent Cyan)
    # Stage 0: Cyan gem seed
    s3 = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(s3)
    d.ellipse([6, 11, 9, 14], fill=(70, 200, 230, 255), outline=(30, 100, 140, 255))
    d.point([(7, 12)], fill=(200, 250, 255, 255))
    crops.paste(s3, (0, 48))

    # Stage 1: Sprout with dew droplet
    sp3 = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(sp3)
    d.line([(8, 14), (8, 8)], fill=(60, 170, 140, 255), width=1)
    d.ellipse([5, 5, 8, 8], fill=(90, 220, 240, 255))
    d.ellipse([8, 6, 11, 9], fill=(50, 180, 150, 255))
    d.point([(6, 6)], fill=(255, 255, 255, 255))
    crops.paste(sp3, (16, 48))

    # Stage 2: Growing Moonflower bud
    gr3 = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(gr3)
    d.line([(8, 14), (8, 6)], fill=(50, 160, 120, 255), width=1)
    d.ellipse([5, 4, 11, 10], fill=(60, 210, 240, 255), outline=(30, 120, 160, 255))
    d.point([(7, 5), (8, 6)], fill=(220, 255, 255, 255))
    crops.paste(gr3, (32, 48))

    # Stage 3: Radiant Mature Dewdrop Flower
    mat3 = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(mat3)
    d.line([(8, 15), (8, 7)], fill=(40, 140, 100, 255), width=2)
    # Petals
    d.ellipse([3, 2, 7, 6], fill=(90, 230, 255, 255))
    d.ellipse([9, 2, 13, 6], fill=(90, 230, 255, 255))
    d.ellipse([3, 7, 7, 11], fill=(80, 210, 240, 255))
    d.ellipse([9, 7, 13, 11], fill=(80, 210, 240, 255))
    # Glowing lunar core with dewdrop
    d.ellipse([6, 4, 10, 8], fill=(220, 255, 255, 255), outline=(130, 240, 255, 255))
    # Shimmering drops
    d.point([(8, 11), (7, 12)], fill=(160, 240, 255, 255))
    d.point([(2, 4), (13, 8), (4, 12)], fill=(200, 255, 255, 255))
    crops.paste(mat3, (48, 48))

    # Stage 4: Withered (cyan tint)
    w3 = withered.copy()
    w3_tint = Image.new('RGBA', (16, 16), (30, 120, 140, 70))
    w3 = Image.alpha_composite(w3, w3_tint)
    crops.paste(w3, (64, 48))

    # 5. Row 4: Trigo-Dourado (Golden Moonwheat - Shimmering Gold)
    # Stage 0: Golden seed
    s4 = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(s4)
    d.ellipse([6, 11, 9, 14], fill=(230, 190, 40, 255), outline=(140, 100, 10, 255))
    d.point([(7, 12)], fill=(255, 240, 160, 255))
    crops.paste(s4, (0, 64))

    # Stage 1: Golden shoot
    sp4 = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(sp4)
    d.line([(8, 14), (8, 7)], fill=(200, 160, 30, 255), width=1)
    d.polygon([(8, 7), (6, 5), (8, 9)], fill=(240, 200, 60, 255))
    d.polygon([(8, 7), (10, 5), (8, 9)], fill=(240, 200, 60, 255))
    d.point([(7, 5), (9, 6)], fill=(255, 250, 180, 255))
    crops.paste(sp4, (16, 64))

    # Stage 2: Growing wheat stalks
    gr4 = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(gr4)
    d.line([(7, 14), (6, 4)], fill=(180, 140, 20, 255), width=1)
    d.line([(9, 14), (10, 4)], fill=(180, 140, 20, 255), width=1)
    for y in [5, 8, 11]:
        d.ellipse([4, y, 7, y+2], fill=(240, 190, 40, 255))
        d.ellipse([9, y, 12, y+2], fill=(240, 190, 40, 255))
    d.point([(5, 5), (10, 8)], fill=(255, 250, 190, 255))
    crops.paste(gr4, (32, 64))

    # Stage 3: Fully mature shimmering golden wheat sheaf
    mat4 = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(mat4)
    # Stalks tied
    d.line([(8, 15), (8, 9)], fill=(160, 110, 20, 255), width=2)
    # Heavy golden grains fan out
    d.polygon([(8, 9), (3, 3), (7, 2)], fill=(250, 210, 50, 255))
    d.polygon([(8, 9), (13, 3), (9, 2)], fill=(250, 210, 50, 255))
    d.polygon([(8, 9), (8, 1), (9, 3)], fill=(255, 230, 90, 255))
    d.polygon([(8, 9), (4, 7), (6, 6)], fill=(230, 170, 30, 255))
    d.polygon([(8, 9), (12, 7), (10, 6)], fill=(230, 170, 30, 255))
    # Sparkles
    d.point([(2, 2), (13, 2), (8, 0), (14, 8), (2, 9)], fill=(255, 255, 220, 255))
    crops.paste(mat4, (48, 64))

    # Stage 4: Withered (golden straw tint)
    w4 = withered.copy()
    w4_tint = Image.new('RGBA', (16, 16), (150, 110, 40, 60))
    w4 = Image.alpha_composite(w4, w4_tint)
    crops.paste(w4, (64, 64))

    crops.save('assets/images/tiles/crops.png')
    print('Saved assets/images/tiles/crops.png (5x5 grid of 16x16)')

def create_magic_objects():
    # 1. Espantalho Vivo (Living Scarecrow - 16x32 px)
    scarecrow = Image.new('RGBA', (16, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(scarecrow)
    # Wood pole
    d.rectangle([7, 14, 8, 30], fill=(80, 55, 30, 255), outline=(50, 35, 20, 255))
    # Crossed branch arms
    d.rectangle([1, 12, 14, 14], fill=(85, 60, 35, 255), outline=(50, 35, 20, 255))
    # Tattered burlap poncho / robe
    d.polygon([(4, 13), (12, 13), (14, 23), (11, 21), (8, 23), (5, 21), (2, 23)], fill=(120, 95, 65, 255), outline=(70, 50, 30, 255))
    # Carved wooden / burlap head
    d.ellipse([4, 4, 11, 12], fill=(135, 105, 75, 255), outline=(75, 55, 35, 255))
    # Glowing yellow/amber runic eyes & mouth (Living Scarecrow magical sentience)
    d.point([(6, 7), (9, 7)], fill=(255, 230, 60, 255))
    d.line([(6, 10), (9, 10)], fill=(255, 190, 40, 255))
    # Hat made of woven straw and raven feather
    d.polygon([(2, 5), (13, 5), (8, 0)], fill=(60, 45, 30, 255))
    d.line([(10, 2), (13, 0)], fill=(40, 40, 55, 255)) # raven feather
    # Glowing Earth Rune on chest
    d.polygon([(7, 16), (9, 16), (8, 19)], fill=(255, 215, 50, 255))
    d.point([(8, 17)], fill=(255, 255, 200, 255))
    scarecrow.save('assets/images/tiles/scarecrow.png')
    print('Saved assets/images/tiles/scarecrow.png (16x32)')

    # 2. Totem de Chuva (Rain Totem - 16x32 px)
    rain_totem = Image.new('RGBA', (16, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(rain_totem)
    # Monolith stone/wood base
    d.rectangle([3, 10, 12, 29], fill=(65, 75, 90, 255), outline=(35, 45, 55, 255))
    d.rectangle([2, 28, 13, 31], fill=(50, 60, 70, 255), outline=(30, 40, 45, 255))
    # Water Drop / Cloud carving on crest
    d.polygon([(8, 2), (4, 8), (12, 8)], fill=(60, 180, 230, 255), outline=(30, 120, 170, 255))
    d.ellipse([5, 6, 11, 10], fill=(70, 200, 245, 255))
    # Swirling Water Runes glowing in vibrant aquamarine
    d.arc([5, 13, 10, 18], start=0, end=270, fill=(80, 230, 255, 255), width=1)
    d.arc([6, 20, 11, 25], start=90, end=360, fill=(80, 230, 255, 255), width=1)
    d.point([(8, 15), (7, 22), (8, 5)], fill=(220, 255, 255, 255))
    # Moisture droplets dripping at base
    d.point([(4, 29), (11, 29), (8, 30)], fill=(90, 210, 255, 255))
    rain_totem.save('assets/images/tiles/rain_totem.png')
    print('Saved assets/images/tiles/rain_totem.png (16x32)')

if __name__ == '__main__':
    create_crops_spritesheet()
    create_magic_objects()


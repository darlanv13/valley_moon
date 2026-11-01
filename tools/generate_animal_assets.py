import os
from PIL import Image, ImageDraw

os.makedirs('assets/images/animals', exist_ok=True)

def create_chicken():
    # 4 frames of 16x16: Idle 1, Idle 2, Peck 1, Walk 1
    sheet = Image.new('RGBA', (64, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(sheet)

    for i in range(4):
        ox = i * 16
        bob = 1 if i in (1, 2) else 0
        peck = 2 if i == 2 else 0

        # Feet
        foot_color = (230, 160, 40, 255)
        d.line([(ox + 6, 14), (ox + 6, 15)], fill=foot_color)
        d.line([(ox + 9, 14), (ox + 9, 15)], fill=foot_color)

        # Body (White with warm shading)
        d.ellipse([ox + 4, 6 + bob, ox + 12, 13 + bob], fill=(245, 245, 240, 255), outline=(190, 185, 175, 255))
        # Wing
        d.ellipse([ox + 5, 8 + bob, ox + 9, 11 + bob], fill=(225, 220, 210, 255))

        # Head
        d.ellipse([ox + 8, 3 + bob + peck, ox + 13, 8 + bob + peck], fill=(255, 255, 250, 255), outline=(190, 185, 175, 255))
        # Red comb
        d.rectangle([ox + 9, 1 + bob + peck, ox + 11, 3 + bob + peck], fill=(220, 40, 40, 255))
        # Eye
        d.point([(ox + 11, 5 + bob + peck)], fill=(30, 30, 30, 255))
        # Beak
        d.polygon([(ox + 13, 5 + bob + peck), (ox + 15, 6 + bob + peck), (ox + 13, 7 + bob + peck)], fill=foot_color)
        # Red wattle
        d.rectangle([ox + 11, 7 + bob + peck, ox + 12, 8 + bob + peck], fill=(220, 40, 40, 255))

    sheet.save('assets/images/animals/chicken.png')
    print("Created chicken.png")

def create_amber_chicken():
    # Mystical Amber Chicken: Golden shimmering plumage, flame wattle, spark aura
    sheet = Image.new('RGBA', (64, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(sheet)

    for i in range(4):
        ox = i * 16
        bob = 1 if i in (1, 2) else 0
        peck = 2 if i == 2 else 0

        # Feet (Bright Brass)
        foot_color = (255, 215, 0, 255)
        d.line([(ox + 6, 14), (ox + 6, 15)], fill=foot_color)
        d.line([(ox + 9, 14), (ox + 9, 15)], fill=foot_color)

        # Mystical glow aura
        d.ellipse([ox + 2, 4 + bob, ox + 14, 14 + bob], fill=(255, 220, 100, 50))

        # Body (Golden Amber)
        d.ellipse([ox + 4, 6 + bob, ox + 12, 13 + bob], fill=(255, 195, 30, 255), outline=(200, 130, 10, 255))
        # Radiant Wing
        d.ellipse([ox + 5, 8 + bob, ox + 9, 11 + bob], fill=(255, 230, 90, 255))

        # Head
        d.ellipse([ox + 8, 3 + bob + peck, ox + 13, 8 + bob + peck], fill=(255, 210, 50, 255), outline=(200, 130, 10, 255))
        # Solar flame comb
        d.polygon([(ox + 9, 1 + bob + peck), (ox + 11, 0 + bob + peck), (ox + 12, 3 + bob + peck)], fill=(255, 90, 20, 255))
        # Radiant Eye (Ruby / Amber)
        d.point([(ox + 11, 5 + bob + peck)], fill=(180, 20, 20, 255))
        # Gold Beak
        d.polygon([(ox + 13, 5 + bob + peck), (ox + 15, 6 + bob + peck), (ox + 13, 7 + bob + peck)], fill=(255, 230, 50, 255))
        # Sacred flame spark particles
        spark_y = 3 if i % 2 == 0 else 5
        d.point([(ox + 3, spark_y), (ox + 14, 2)], fill=(255, 255, 200, 255))

    sheet.save('assets/images/animals/amber_chicken.png')
    print("Created amber_chicken.png")

def create_cow():
    # 4 frames of 32x32: Idle 1, Idle 2, Graze 1, Walk 1
    sheet = Image.new('RGBA', (128, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(sheet)

    for i in range(4):
        ox = i * 32
        bob = 1 if i in (1, 3) else 0
        graze = 3 if i == 2 else 0

        # Legs (4 hoofs)
        leg_color = (235, 235, 230, 255)
        hoof_color = (60, 55, 50, 255)
        for lx in [8, 12, 20, 24]:
            step = 1 if (i == 3 and lx in (8, 20)) else 0
            d.rectangle([ox + lx, 22 - step, ox + lx + 2, 27], fill=leg_color)
            d.rectangle([ox + lx, 28, ox + lx + 2, 29], fill=hoof_color)

        # Body (White with black dairy cow patches)
        d.rounded_rectangle([ox + 6, 10 + bob, ox + 27, 22 + bob], radius=4, fill=(245, 245, 240, 255), outline=(180, 180, 175, 255))
        # Black patches
        d.ellipse([ox + 9, 11 + bob, ox + 15, 17 + bob], fill=(45, 45, 48, 255))
        d.ellipse([ox + 18, 14 + bob, ox + 24, 20 + bob], fill=(45, 45, 48, 255))
        d.rectangle([ox + 22, 11 + bob, ox + 26, 14 + bob], fill=(45, 45, 48, 255))

        # Tail
        d.line([(ox + 6, 12 + bob), (ox + 4, 18 + bob)], fill=(245, 245, 240, 255), width=1)
        d.point([(ox + 3, 19 + bob), (ox + 4, 19 + bob)], fill=(45, 45, 48, 255))

        # Head & Snout
        d.rounded_rectangle([ox + 22, 7 + bob + graze, ox + 30, 16 + bob + graze], radius=3, fill=(245, 245, 240, 255), outline=(180, 180, 175, 255))
        # Black eye patch
        d.rectangle([ox + 24, 8 + bob + graze, ox + 27, 11 + bob + graze], fill=(45, 45, 48, 255))
        d.point([(ox + 25, 9 + bob + graze)], fill=(255, 255, 255, 255)) # Eye glint
        # Pink Snout
        d.rounded_rectangle([ox + 26, 12 + bob + graze, ox + 31, 16 + bob + graze], radius=2, fill=(255, 185, 185, 255), outline=(220, 140, 140, 255))
        d.point([(ox + 28, 14 + bob + graze), (ox + 30, 14 + bob + graze)], fill=(150, 70, 70, 255)) # Nostrils
        # Horns
        d.polygon([(ox + 23, 6 + bob + graze), (ox + 24, 3 + bob + graze), (ox + 25, 6 + bob + graze)], fill=(210, 190, 140, 255))
        d.polygon([(ox + 27, 6 + bob + graze), (ox + 28, 3 + bob + graze), (ox + 29, 6 + bob + graze)], fill=(210, 190, 140, 255))
        # Brass bell on neck
        d.rectangle([ox + 22, 16 + bob + graze, ox + 24, 18 + bob + graze], fill=(225, 180, 40, 255))

    sheet.save('assets/images/animals/cow.png')
    print("Created cow.png")

def create_moss_calf():
    # Mystical Moss Calf: Deep forest green, earth wood horns with flowers & nature buff
    sheet = Image.new('RGBA', (128, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(sheet)

    for i in range(4):
        ox = i * 32
        bob = 1 if i in (1, 3) else 0
        graze = 3 if i == 2 else 0

        # Soft green aura
        d.ellipse([ox + 4, 8 + bob, ox + 30, 26 + bob], fill=(120, 210, 130, 45))

        # Legs (Bark Brown)
        leg_color = (90, 65, 40, 255)
        hoof_color = (40, 30, 20, 255)
        for lx in [8, 12, 20, 24]:
            step = 1 if (i == 3 and lx in (8, 20)) else 0
            d.rectangle([ox + lx, 22 - step, ox + lx + 2, 27], fill=leg_color)
            d.rectangle([ox + lx, 28, ox + lx + 2, 29], fill=hoof_color)

        # Body (Deep Moss Green with clover & flower accents)
        d.rounded_rectangle([ox + 6, 10 + bob, ox + 27, 22 + bob], radius=4, fill=(65, 125, 60, 255), outline=(40, 80, 40, 255))
        # Emerald moss patches
        d.ellipse([ox + 9, 11 + bob, ox + 16, 18 + bob], fill=(105, 175, 75, 255))
        d.ellipse([ox + 18, 13 + bob, ox + 25, 20 + bob], fill=(105, 175, 75, 255))
        # Little pink forest flower on back
        d.point([(ox + 13, 11 + bob), (ox + 20, 14 + bob)], fill=(255, 170, 200, 255))
        d.point([(ox + 14, 11 + bob), (ox + 21, 14 + bob)], fill=(255, 240, 150, 255))

        # Vine Tail
        d.line([(ox + 6, 12 + bob), (ox + 3, 19 + bob)], fill=(45, 95, 45, 255), width=1)
        d.point([(ox + 2, 20 + bob), (ox + 3, 20 + bob)], fill=(120, 200, 80, 255)) # Leaf tip

        # Head & Snout
        d.rounded_rectangle([ox + 22, 7 + bob + graze, ox + 30, 16 + bob + graze], radius=3, fill=(75, 135, 65, 255), outline=(40, 80, 40, 255))
        # Wooden Horns with sprouting pink blossoms
        d.polygon([(ox + 23, 6 + bob + graze), (ox + 23, 2 + bob + graze), (ox + 25, 5 + bob + graze)], fill=(110, 75, 45, 255))
        d.polygon([(ox + 27, 5 + bob + graze), (ox + 29, 2 + bob + graze), (ox + 29, 6 + bob + graze)], fill=(110, 75, 45, 255))
        d.point([(ox + 23, 1 + bob + graze), (ox + 29, 1 + bob + graze)], fill=(255, 160, 190, 255)) # Flower buds

        # Gentle Emerald Eye
        d.point([(ox + 26, 9 + bob + graze)], fill=(180, 255, 200, 255))
        # Earthy Pink Snout
        d.rounded_rectangle([ox + 26, 12 + bob + graze, ox + 31, 16 + bob + graze], radius=2, fill=(185, 140, 130, 255), outline=(130, 90, 80, 255))
        d.point([(ox + 28, 14 + bob + graze), (ox + 30, 14 + bob + graze)], fill=(80, 45, 40, 255))
        # Golden carved runic pendant
        d.rectangle([ox + 22, 16 + bob + graze, ox + 24, 18 + bob + graze], fill=(138, 227, 255, 255))

    sheet.save('assets/images/animals/moss_calf.png')
    print("Created moss_calf.png")

def create_sheep():
    # 4 frames of 24x24: Idle 1, Idle 2, Graze 1, Walk 1
    sheet = Image.new('RGBA', (96, 24), (0, 0, 0, 0))
    d = ImageDraw.Draw(sheet)

    for i in range(4):
        ox = i * 24
        bob = 1 if i in (1, 3) else 0
        graze = 2 if i == 2 else 0

        # Dark Little Legs
        leg_color = (50, 45, 40, 255)
        for lx in [6, 9, 15, 18]:
            step = 1 if (i == 3 and lx in (6, 15)) else 0
            d.rectangle([ox + lx, 16 - step, ox + lx + 1, 21], fill=leg_color)

        # Fluffy Wool Body (Cloud bumps)
        wool_light = (250, 250, 245, 255)
        wool_shadow = (210, 210, 200, 255)
        d.ellipse([ox + 4, 6 + bob, ox + 20, 18 + bob], fill=wool_light, outline=wool_shadow)
        d.ellipse([ox + 3, 8 + bob, ox + 9, 16 + bob], fill=wool_light)
        d.ellipse([ox + 15, 8 + bob, ox + 21, 16 + bob], fill=wool_light)
        d.ellipse([ox + 8, 4 + bob, ox + 16, 10 + bob], fill=wool_light)

        # Black Face
        face_color = (45, 40, 38, 255)
        d.rounded_rectangle([ox + 16, 8 + bob + graze, ox + 22, 15 + bob + graze], radius=2, fill=face_color)
        d.point([(ox + 19, 10 + bob + graze)], fill=(255, 255, 255, 255)) # Eye glint
        # Little floppy ears
        d.rectangle([ox + 15, 7 + bob + graze, ox + 16, 9 + bob + graze], fill=face_color)
        # Wool tuft on head
        d.ellipse([ox + 17, 6 + bob + graze, ox + 21, 9 + bob + graze], fill=wool_light)

    sheet.save('assets/images/animals/sheep.png')
    print("Created sheep.png")

def create_cloud_sheep():
    # Mystical Cloud Sheep: Celeste sky blue floating fluff, starry sparks, moon crest
    sheet = Image.new('RGBA', (96, 24), (0, 0, 0, 0))
    d = ImageDraw.Draw(sheet)

    for i in range(4):
        ox = i * 24
        float_y = 1 if i in (1, 3) else 0
        graze = 2 if i == 2 else 0

        # Celestial Aura & Tiny Floating Cloud Puffs at base
        d.ellipse([ox + 2, 4 - float_y, ox + 22, 19 - float_y], fill=(180, 230, 255, 55))
        d.ellipse([ox + 5, 18 - float_y, ox + 9, 21 - float_y], fill=(220, 245, 255, 180))
        d.ellipse([ox + 14, 18 - float_y, ox + 18, 21 - float_y], fill=(220, 245, 255, 180))

        # Golden Astral Hooves
        hoof_color = (255, 225, 120, 255)
        for lx in [6, 9, 15, 18]:
            d.rectangle([ox + lx, 16 - float_y, ox + lx + 1, 19 - float_y], fill=hoof_color)

        # Celestial Sky Blue Wool
        wool_light = (205, 240, 255, 255)
        wool_shadow = (140, 195, 240, 255)
        d.ellipse([ox + 4, 5 - float_y, ox + 20, 17 - float_y], fill=wool_light, outline=wool_shadow)
        d.ellipse([ox + 3, 7 - float_y, ox + 9, 15 - float_y], fill=wool_light)
        d.ellipse([ox + 15, 7 - float_y, ox + 21, 15 - float_y], fill=wool_light)
        d.ellipse([ox + 8, 3 - float_y, ox + 16, 9 - float_y], fill=wool_light)

        # Stars in wool
        d.point([(ox + 7, 9 - float_y), (ox + 13, 12 - float_y)], fill=(255, 255, 240, 255))

        # Pearl Blue Face
        face_color = (90, 130, 180, 255)
        d.rounded_rectangle([ox + 16, 7 - float_y + graze, ox + 22, 14 - float_y + graze], radius=2, fill=face_color)
        d.point([(ox + 19, 9 - float_y + graze)], fill=(255, 255, 255, 255)) # Starlight Eye
        # Golden crescent horn
        d.arc([ox + 14, 4 - float_y + graze, ox + 18, 8 - float_y + graze], start=0, end=180, fill=(255, 220, 80, 255), width=1)
        # Cloud tuft
        d.ellipse([ox + 17, 5 - float_y + graze, ox + 21, 8 - float_y + graze], fill=wool_light)

    sheet.save('assets/images/animals/cloud_sheep.png')
    print("Created cloud_sheep.png")

def create_pig():
    # 4 frames of 24x24: Idle 1, Idle 2, Snuffle 1, Walk 1
    sheet = Image.new('RGBA', (96, 24), (0, 0, 0, 0))
    d = ImageDraw.Draw(sheet)

    for i in range(4):
        ox = i * 24
        bob = 1 if i in (1, 3) else 0
        snuffle = 2 if i == 2 else 0

        # Pink Trotters
        trot_color = (220, 140, 150, 255)
        for lx in [6, 9, 15, 18]:
            step = 1 if (i == 3 and lx in (6, 15)) else 0
            d.rectangle([ox + lx, 16 - step, ox + lx + 1, 20], fill=trot_color)

        # Plump Pink Body
        body_color = (255, 180, 195, 255)
        body_outline = (215, 135, 150, 255)
        d.ellipse([ox + 4, 7 + bob, ox + 20, 18 + bob], fill=body_color, outline=body_outline)

        # Curly Tail
        d.line([(ox + 4, 11 + bob), (ox + 2, 9 + bob)], fill=body_color, width=1)
        d.point([(ox + 2, 8 + bob), (ox + 3, 8 + bob)], fill=body_outline)

        # Pig Head & Snout
        d.rounded_rectangle([ox + 15, 8 + bob + snuffle, ox + 22, 16 + bob + snuffle], radius=3, fill=body_color, outline=body_outline)
        # Floppy ear
        d.polygon([(ox + 15, 8 + bob + snuffle), (ox + 17, 5 + bob + snuffle), (ox + 19, 8 + bob + snuffle)], fill=(235, 150, 165, 255))
        # Eye
        d.point([(ox + 18, 10 + bob + snuffle)], fill=(40, 30, 30, 255))
        # Snout (disc with nostrils)
        d.rounded_rectangle([ox + 19, 12 + bob + snuffle, ox + 23, 16 + bob + snuffle], radius=2, fill=(255, 150, 170, 255), outline=body_outline)
        d.point([(ox + 20, 14 + bob + snuffle), (ox + 22, 14 + bob + snuffle)], fill=(160, 80, 100, 255))

    sheet.save('assets/images/animals/pig.png')
    print("Created pig.png")

def create_pet():
    # 4 frames of 16x16: Idle 1, Idle 2, Wag 1, Walk 1 (Loyal rustic farm dog)
    sheet = Image.new('RGBA', (64, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(sheet)

    for i in range(4):
        ox = i * 16
        bob = 1 if i in (1, 3) else 0
        wag = 1 if i in (2, 3) else 0

        # Paws
        paw_color = (190, 130, 70, 255)
        d.rectangle([ox + 4, 13, ox + 5, 15], fill=paw_color)
        d.rectangle([ox + 10, 13, ox + 11, 15], fill=paw_color)

        # Body (Golden Brown & White patch)
        d.ellipse([ox + 3, 7 + bob, ox + 12, 14 + bob], fill=(210, 145, 75, 255), outline=(150, 95, 45, 255))
        d.ellipse([ox + 5, 9 + bob, ox + 9, 13 + bob], fill=(250, 245, 235, 255)) # Chest tuft

        # Wagging Tail
        tail_tip = (ox + 1, 6 + bob - wag)
        d.line([(ox + 3, 10 + bob), tail_tip], fill=(210, 145, 75, 255), width=1)
        d.point([tail_tip], fill=(250, 245, 235, 255))

        # Head & Floppy Ears
        d.rounded_rectangle([ox + 9, 4 + bob, ox + 15, 11 + bob], radius=2, fill=(210, 145, 75, 255), outline=(150, 95, 45, 255))
        d.rectangle([ox + 8, 5 + bob, ox + 10, 9 + bob], fill=(160, 100, 45, 255)) # Ear
        # Eye
        d.point([(ox + 12, 6 + bob)], fill=(30, 20, 15, 255))
        # Snout & Nose
        d.rectangle([ox + 13, 8 + bob, ox + 15, 10 + bob], fill=(245, 240, 230, 255))
        d.point([(ox + 15, 8 + bob)], fill=(40, 30, 25, 255)) # Black nose

    sheet.save('assets/images/animals/pet.png')
    print("Created pet.png")

def create_heart_emote():
    # 16x16 glowing red/pink heart emote
    img = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    # Glow
    d.polygon([(8, 14), (2, 8), (2, 4), (5, 2), (8, 5), (11, 2), (14, 4), (14, 8)], fill=(255, 100, 150, 90))
    # Core Heart
    d.polygon([(8, 13), (3, 8), (3, 5), (5, 3), (8, 6), (11, 3), (13, 5), (13, 8)], fill=(235, 45, 80, 255), outline=(160, 20, 50, 255))
    # Highlights
    d.point([(5, 5), (6, 5), (5, 6)], fill=(255, 200, 220, 255))

    img.save('assets/images/animals/heart_emote.png')
    print("Created heart_emote.png")

if __name__ == '__main__':
    create_chicken()
    create_amber_chicken()
    create_cow()
    create_moss_calf()
    create_sheep()
    create_cloud_sheep()
    create_pig()
    create_pet()
    create_heart_emote()
    print("All animal assets successfully generated!")


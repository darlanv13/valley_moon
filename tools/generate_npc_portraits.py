import os
from PIL import Image, ImageDraw

os.makedirs('assets/images/portraits', exist_ok=True)
os.makedirs('assets/images/characters', exist_ok=True)

# Helper to draw a framed 64x64 pixel art portrait
def make_base_portrait(bg_color=(230, 220, 195, 255)):
    img = Image.new('RGBA', (64, 64), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Background parchment
    d.rectangle([2, 2, 61, 61], fill=bg_color)
    # Dark timber frame
    d.rectangle([0, 0, 63, 63], outline=(74, 51, 25, 255), width=2)
    d.rectangle([2, 2, 61, 61], outline=(140, 105, 65, 255), width=1)
    # Corner studs
    d.point([(2, 2), (61, 2), (2, 61), (61, 61)], fill=(40, 28, 15, 255))
    return img

def generate_bento():
    # Bento: Nervous elderly mayor, spectacles, bald top with white hair, olive vest
    for expr in ['neutral', 'happy', 'surprised', 'blushing']:
        img = make_base_portrait((235, 225, 205, 255))
        d = ImageDraw.Draw(img)
        # Shoulders & Olive Coat
        d.polygon([(12, 61), (22, 42), (42, 42), (52, 61)], fill=(90, 105, 70, 255))
        d.polygon([(26, 42), (32, 54), (38, 42)], fill=(240, 235, 220, 255)) # cravat
        # Head & Ears
        d.ellipse([20, 14, 44, 42], fill=(235, 195, 160, 255))
        d.ellipse([16, 26, 21, 32], fill=(225, 180, 145, 255))
        d.ellipse([43, 26, 48, 32], fill=(225, 180, 145, 255))
        # White tufts on sides
        d.ellipse([15, 20, 23, 29], fill=(230, 230, 235, 255))
        d.ellipse([41, 20, 49, 29], fill=(230, 230, 235, 255))
        # Eyebrows
        d.line([(24, 22), (29, 21)], fill=(210, 210, 215, 255), width=2)
        d.line([(35, 21), (40, 22)], fill=(210, 210, 215, 255), width=2)
        # Spectacles (Wire rim)
        d.rectangle([23, 25, 29, 31], outline=(180, 140, 40, 255), width=1)
        d.rectangle([35, 25, 41, 31], outline=(180, 140, 40, 255), width=1)
        d.line([(29, 28), (35, 28)], fill=(180, 140, 40, 255))
        # Eyes
        if expr == 'surprised':
            d.ellipse([25, 26, 27, 30], fill=(50, 40, 30, 255))
            d.ellipse([37, 26, 39, 30], fill=(50, 40, 30, 255))
        elif expr == 'happy':
            d.arc([24, 26, 28, 30], start=180, end=360, fill=(50, 40, 30, 255), width=2)
            d.arc([36, 26, 40, 30], start=180, end=360, fill=(50, 40, 30, 255), width=2)
        else:
            d.point([(26, 28), (38, 28)], fill=(50, 40, 30, 255))

        # Big bushy white mustache
        d.ellipse([24, 33, 40, 38], fill=(230, 230, 235, 255))

        # Mouth & Expression variations
        if expr == 'happy':
            d.arc([29, 36, 35, 41], start=0, end=180, fill=(160, 60, 60, 255), width=2)
        elif expr == 'surprised':
            d.ellipse([30, 37, 34, 41], fill=(120, 40, 40, 255))
            # Sweat drop
            d.ellipse([45, 18, 48, 24], fill=(120, 200, 240, 255))
        elif expr == 'blushing':
            d.rectangle([21, 31, 25, 33], fill=(240, 140, 140, 180))
            d.rectangle([39, 31, 43, 33], fill=(240, 140, 140, 180))

        img.save(f'assets/images/portraits/bento_{expr}.png')

def generate_kael():
    # Kael: Blacksmith & Warrior (Casável), dark messy hair, cheek scar, rugged stubble, leather apron
    for expr in ['neutral', 'happy', 'surprised', 'blushing']:
        img = make_base_portrait((220, 215, 200, 255))
        d = ImageDraw.Draw(img)
        # Shoulders & Leather Smith Apron
        d.polygon([(10, 61), (22, 40), (42, 40), (54, 61)], fill=(65, 45, 30, 255))
        d.polygon([(26, 40), (32, 48), (38, 40)], fill=(210, 185, 150, 255))
        # Jaw & Neck
        d.polygon([(23, 34), (32, 44), (41, 34)], fill=(210, 165, 130, 255))
        d.ellipse([20, 14, 44, 40], fill=(225, 175, 140, 255))
        # Cheek Scar
        d.line([(37, 28), (41, 35)], fill=(180, 110, 95, 255), width=1)
        # Stubble
        d.point([(27, 37), (29, 39), (32, 41), (35, 39), (37, 37)], fill=(120, 90, 70, 180))
        # Eyes
        if expr == 'surprised':
            d.ellipse([25, 24, 28, 28], fill=(60, 45, 35, 255))
            d.ellipse([36, 24, 39, 28], fill=(60, 45, 35, 255))
        elif expr == 'happy':
            d.arc([24, 24, 28, 28], start=180, end=360, fill=(50, 35, 25, 255), width=2)
            d.arc([36, 24, 40, 28], start=180, end=360, fill=(50, 35, 25, 255), width=2)
        else:
            d.line([(24, 26), (28, 26)], fill=(50, 35, 25, 255), width=2)
            d.line([(36, 26), (40, 26)], fill=(50, 35, 25, 255), width=2)

        # Mouth
        if expr == 'happy':
            d.arc([28, 34, 36, 38], start=0, end=180, fill=(120, 50, 50, 255), width=2)
        elif expr == 'surprised':
            d.ellipse([30, 34, 34, 38], fill=(100, 40, 40, 255))
        else:
            d.line([(28, 36), (36, 36)], fill=(130, 70, 60, 255), width=1)

        # Dark messy warrior hair
        d.polygon([(18, 22), (20, 10), (32, 8), (44, 10), (46, 22), (42, 14), (32, 12), (22, 14)], fill=(45, 35, 30, 255))
        d.polygon([(26, 10), (28, 18), (30, 11)], fill=(55, 42, 35, 255))
        d.polygon([(34, 10), (36, 17), (38, 12)], fill=(55, 42, 35, 255))

        if expr == 'blushing':
            d.rectangle([22, 29, 27, 32], fill=(235, 120, 120, 160))
            d.rectangle([37, 29, 42, 32], fill=(235, 120, 120, 160))

        img.save(f'assets/images/portraits/kael_{expr}.png')

def generate_helena():
    # Helena: Mysterious swamp herbalist (Casável), dark wavy hair, violet eyes, moss shawl, herbal flower
    for expr in ['neutral', 'happy', 'surprised', 'blushing']:
        img = make_base_portrait((215, 210, 215, 255))
        d = ImageDraw.Draw(img)
        # Forest/Swamp Moss Cloak
        d.polygon([(10, 61), (20, 40), (44, 40), (54, 61)], fill=(55, 75, 60, 255))
        d.ellipse([22, 38, 42, 44], fill=(100, 60, 120, 255)) # Amethyst talisman
        # Delicate face
        d.polygon([(24, 34), (32, 43), (40, 34)], fill=(240, 205, 180, 255))
        d.ellipse([21, 15, 43, 39], fill=(245, 215, 190, 255))
        # Violet eyes
        if expr == 'happy':
            d.arc([24, 25, 28, 29], start=180, end=360, fill=(140, 70, 180, 255), width=2)
            d.arc([36, 25, 40, 29], start=180, end=360, fill=(140, 70, 180, 255), width=2)
        elif expr == 'surprised':
            d.ellipse([24, 24, 28, 29], fill=(160, 80, 210, 255))
            d.ellipse([36, 24, 40, 29], fill=(160, 80, 210, 255))
            d.point([(26, 26), (38, 26)], fill=(255, 255, 255, 255))
        else:
            d.ellipse([25, 25, 28, 28], fill=(150, 70, 200, 255))
            d.ellipse([36, 25, 39, 28], fill=(150, 70, 200, 255))
            d.point([(26, 26), (37, 26)], fill=(255, 230, 255, 255))

        # Soft lips
        if expr == 'happy':
            d.arc([29, 34, 35, 38], start=0, end=180, fill=(180, 80, 100, 255), width=2)
        elif expr == 'surprised':
            d.ellipse([30, 34, 34, 38], fill=(150, 60, 80, 255))
        else:
            d.line([(29, 36), (35, 36)], fill=(180, 80, 100, 255), width=1)

        # Long flowing raven hair with herb sprigs
        d.polygon([(16, 18), (22, 8), (32, 6), (42, 8), (48, 18), (44, 46), (40, 20), (24, 20), (20, 46)], fill=(40, 30, 45, 255))
        # Dried lunar blossom in hair
        d.ellipse([18, 16, 23, 21], fill=(140, 220, 255, 255))
        d.point([(20, 18)], fill=(255, 255, 255, 255))

        if expr == 'blushing':
            d.rectangle([22, 29, 27, 32], fill=(235, 130, 160, 180))
            d.rectangle([37, 29, 42, 32], fill=(235, 130, 160, 180))

        img.save(f'assets/images/portraits/helena_{expr}.png')

def generate_lucio():
    # Lúcio: Weathered fisherman, salt-and-pepper beard, wool beanie, navy vest
    for expr in ['neutral', 'happy', 'surprised', 'sad']:
        img = make_base_portrait((210, 220, 225, 255))
        d = ImageDraw.Draw(img)
        # Shoulders & Navy Fisher Vest
        d.polygon([(10, 61), (20, 42), (44, 42), (54, 61)], fill=(45, 60, 85, 255))
        d.polygon([(26, 42), (32, 52), (38, 42)], fill=(220, 215, 200, 255))
        # Head & Tan Face
        d.ellipse([20, 16, 44, 42], fill=(215, 165, 125, 255))
        # Wool Fisher Beanie (Dark teal)
        d.polygon([(18, 18), (22, 10), (32, 8), (42, 10), (46, 18), (46, 23), (18, 23)], fill=(40, 85, 95, 255))
        # Big salt & pepper beard
        d.polygon([(20, 32), (32, 46), (44, 32), (38, 42), (26, 42)], fill=(170, 175, 180, 255))
        d.ellipse([22, 32, 42, 44], fill=(160, 165, 170, 255))
        # Grumpy or expressive eyes
        if expr == 'happy':
            d.arc([24, 25, 28, 29], start=180, end=360, fill=(40, 35, 30, 255), width=2)
            d.arc([36, 25, 40, 29], start=180, end=360, fill=(40, 35, 30, 255), width=2)
        elif expr == 'surprised':
            d.ellipse([24, 24, 28, 29], fill=(40, 35, 30, 255))
            d.ellipse([36, 24, 40, 29], fill=(40, 35, 30, 255))
        elif expr == 'sad':
            d.line([(24, 27), (28, 25)], fill=(40, 35, 30, 255), width=2)
            d.line([(36, 25), (40, 27)], fill=(40, 35, 30, 255), width=2)
        else:
            d.line([(24, 25), (28, 26)], fill=(40, 35, 30, 255), width=2)
            d.line([(36, 26), (40, 25)], fill=(40, 35, 30, 255), width=2)

        # Pipe in mouth
        d.line([(36, 36), (44, 38)], fill=(90, 60, 35, 255), width=2)
        d.rectangle([43, 35, 47, 39], fill=(60, 40, 25, 255))
        d.point([(45, 34)], fill=(200, 200, 200, 200)) # smoke puff

        img.save(f'assets/images/portraits/lucio_{expr}.png')

def generate_iris():
    # Íris: Tavern bard (Casável), auburn braids, green feathered hat, lute neck, rosy smile
    for expr in ['neutral', 'happy', 'surprised', 'blushing']:
        img = make_base_portrait((240, 230, 215, 255))
        d = ImageDraw.Draw(img)
        # Tavern Bard Tunic (Burgundy)
        d.polygon([(10, 61), (20, 42), (44, 42), (54, 61)], fill=(120, 40, 50, 255))
        d.polygon([(26, 42), (32, 48), (38, 42)], fill=(245, 240, 230, 255))
        # Face
        d.polygon([(24, 34), (32, 43), (40, 34)], fill=(245, 215, 190, 255))
        d.ellipse([21, 16, 43, 40], fill=(250, 220, 195, 255))
        # Green Bard Cap with Peacock/Pheasant Feather
        d.polygon([(18, 18), (24, 8), (40, 8), (46, 18)], fill=(45, 110, 65, 255))
        d.line([(38, 10), (48, 2)], fill=(180, 50, 50, 255), width=2)
        # Auburn Hair & Braids
        d.ellipse([16, 22, 22, 38], fill=(170, 75, 40, 255)) # left braid
        d.ellipse([42, 22, 48, 38], fill=(170, 75, 40, 255)) # right braid
        # Eyes
        if expr == 'happy':
            d.arc([24, 25, 28, 29], start=180, end=360, fill=(70, 40, 30, 255), width=2)
            d.arc([36, 25, 40, 29], start=180, end=360, fill=(70, 40, 30, 255), width=2)
        elif expr == 'surprised':
            d.ellipse([24, 24, 28, 29], fill=(70, 40, 30, 255))
            d.ellipse([36, 24, 40, 29], fill=(70, 40, 30, 255))
        else:
            d.ellipse([25, 25, 28, 28], fill=(60, 110, 75, 255)) # emerald eyes
            d.ellipse([36, 25, 39, 28], fill=(60, 110, 75, 255))

        # Smile
        if expr == 'happy':
            d.arc([28, 32, 36, 38], start=0, end=180, fill=(180, 60, 70, 255), width=2)
        elif expr == 'surprised':
            d.ellipse([30, 33, 34, 37], fill=(160, 50, 60, 255))
        else:
            d.arc([29, 33, 35, 37], start=0, end=180, fill=(180, 60, 70, 255), width=1)

        # Rosy cheeks
        d.rectangle([21, 29, 26, 32], fill=(245, 140, 140, 180))
        d.rectangle([38, 29, 43, 32], fill=(245, 140, 140, 180))

        img.save(f'assets/images/portraits/iris_{expr}.png')

def generate_maya():
    # Maya: Mystical animal breeder (Casável), honey blonde twin braids, fur trim vest, nature charm
    for expr in ['neutral', 'happy', 'surprised', 'blushing']:
        img = make_base_portrait((230, 235, 215, 255))
        d = ImageDraw.Draw(img)
        # Fur Trim Vest (Warm Ochre)
        d.polygon([(10, 61), (20, 42), (44, 42), (54, 61)], fill=(160, 110, 50, 255))
        d.ellipse([18, 40, 46, 45], fill=(240, 230, 215, 255)) # Fur collar
        # Face
        d.polygon([(24, 34), (32, 43), (40, 34)], fill=(245, 215, 190, 255))
        d.ellipse([21, 16, 43, 40], fill=(250, 220, 195, 255))
        # Honey blonde hair
        d.polygon([(18, 20), (22, 10), (32, 8), (42, 10), (46, 20)], fill=(230, 185, 75, 255))
        d.ellipse([16, 22, 22, 38], fill=(215, 170, 65, 255)) # left braid
        d.ellipse([42, 22, 48, 38], fill=(215, 170, 65, 255)) # right braid
        # Hazel warm eyes
        if expr == 'happy':
            d.arc([24, 25, 28, 29], start=180, end=360, fill=(70, 50, 30, 255), width=2)
            d.arc([36, 25, 40, 29], start=180, end=360, fill=(70, 50, 30, 255), width=2)
        elif expr == 'surprised':
            d.ellipse([24, 24, 28, 29], fill=(80, 60, 35, 255))
            d.ellipse([36, 24, 40, 29], fill=(80, 60, 35, 255))
        else:
            d.ellipse([25, 25, 28, 28], fill=(85, 75, 40, 255))
            d.ellipse([36, 25, 39, 28], fill=(85, 75, 40, 255))

        # Smile
        if expr == 'happy':
            d.arc([28, 33, 36, 38], start=0, end=180, fill=(180, 70, 80, 255), width=2)
        elif expr == 'surprised':
            d.ellipse([30, 34, 34, 37], fill=(160, 60, 70, 255))
        else:
            d.arc([29, 34, 35, 37], start=0, end=180, fill=(180, 70, 80, 255), width=1)

        # Little nature moth/clover hair pin
        d.ellipse([43, 14, 47, 18], fill=(110, 200, 130, 255))

        if expr == 'blushing':
            d.rectangle([21, 29, 26, 32], fill=(245, 140, 140, 180))
            d.rectangle([38, 29, 43, 32], fill=(245, 140, 140, 180))

        img.save(f'assets/images/portraits/maya_{expr}.png')

if __name__ == '__main__':
    generate_bento()
    generate_kael()
    generate_helena()
    generate_lucio()
    generate_iris()
    generate_maya()
    print('All 24 NPC Portraits (64x64, 4 expressions each) generated successfully!')


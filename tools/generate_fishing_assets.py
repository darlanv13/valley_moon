import os
from PIL import Image, ImageDraw

os.makedirs('assets/images/fishing', exist_ok=True)

def create_fishes():
    # 8 fishes in a spritesheet: 192x24 (8 frames of 24x24)
    # 0: Truta do Riacho (Brook Trout - olive/copper speckled)
    # 1: Tilápia da Lagoa (Pond Tilapia - azure silver striped)
    # 2: Bagre do Píer (Pier Catfish - slate gray with whiskers)
    # 3: Enguia Noturna (Night Eel - dark indigo, yellow fin)
    # 4: [LENDÁRIO] Bagre-Fantasma (Phantom Catfish - translucent ethereal cyan glow, whisker trails)
    # 5: [LENDÁRIO] Carpa Astral (Astral Carp - celestial purple/gold, galaxy starry scales)
    # 6: [LENDÁRIO] Salmão do Luar (Moonlight Salmon - gleaming bright silver, crescent fin)
    # 7: [LENDÁRIO] Peixe-Sol Dourado (Golden Sunfish - radiant amber/sunburst, golden rays)
    sheet = Image.new('RGBA', (192, 24), (0, 0, 0, 0))
    d = ImageDraw.Draw(sheet)

    # Helper function to draw a stylized fish
    def draw_fish(ox, body_color, outline_color, fin_color, eye_color, whisker=False, glow_color=None, stars=False, sunburst=False):
        if glow_color:
            d.ellipse([ox + 2, 4, ox + 22, 20], fill=glow_color)

        # Tail Fin
        d.polygon([(ox + 3, 7), (ox + 7, 12), (ox + 3, 17)], fill=fin_color)

        # Dorsal & Ventral Fins
        d.polygon([(ox + 10, 5), (ox + 14, 5), (ox + 12, 8)], fill=fin_color)
        d.polygon([(ox + 10, 19), (ox + 14, 19), (ox + 12, 16)], fill=fin_color)

        # Main Body Ellipse
        d.ellipse([ox + 6, 7, ox + 20, 17], fill=body_color, outline=outline_color)

        # Pectoral Fin
        d.polygon([(ox + 11, 12), (ox + 14, 15), (ox + 13, 12)], fill=fin_color)

        # Eye
        d.point([(ox + 17, 10)], fill=eye_color)
        d.point([(ox + 18, 10)], fill=(255, 255, 255, 255)) # glint

        # Whiskers (for catfish / phantom catfish)
        if whisker:
            d.line([(ox + 19, 13), (ox + 23, 16)], fill=fin_color, width=1)
            d.line([(ox + 19, 14), (ox + 22, 19)], fill=fin_color, width=1)

        # Stars (for Astral Carp)
        if stars:
            d.point([(ox + 10, 10), (ox + 14, 13), (ox + 12, 11)], fill=(255, 255, 230, 255))
            d.point([(ox + 8, 12)], fill=(255, 220, 100, 255))

        # Sunburst (for Golden Sunfish)
        if sunburst:
            d.line([(ox + 13, 3), (ox + 13, 5)], fill=(255, 240, 120, 255))
            d.line([(ox + 13, 19), (ox + 13, 21)], fill=(255, 240, 120, 255))
            d.line([(ox + 21, 8), (ox + 23, 7)], fill=(255, 240, 120, 255))

    # 0: Truta do Riacho
    draw_fish(0 * 24, body_color=(120, 150, 90, 255), outline_color=(75, 95, 55, 255), fin_color=(200, 110, 60, 255), eye_color=(30, 30, 30, 255))
    d.point([(0 * 24 + 11, 10), (0 * 24 + 14, 11)], fill=(220, 60, 40, 255)) # red spots

    # 1: Tilápia da Lagoa
    draw_fish(1 * 24, body_color=(100, 170, 210, 255), outline_color=(60, 110, 145, 255), fin_color=(160, 215, 245, 255), eye_color=(20, 30, 50, 255))
    d.line([(1 * 24 + 10, 8), (1 * 24 + 10, 16)], fill=(60, 110, 145, 255)) # stripes
    d.line([(1 * 24 + 13, 8), (1 * 24 + 13, 16)], fill=(60, 110, 145, 255))

    # 2: Bagre do Píer
    draw_fish(2 * 24, body_color=(110, 115, 125, 255), outline_color=(65, 70, 80, 255), fin_color=(85, 90, 100, 255), eye_color=(25, 25, 30, 255), whisker=True)

    # 3: Enguia Noturna
    draw_fish(3 * 24, body_color=(50, 45, 80, 255), outline_color=(25, 20, 50, 255), fin_color=(240, 220, 60, 255), eye_color=(255, 240, 80, 255))

    # 4: [LENDÁRIO] Bagre-Fantasma
    draw_fish(4 * 24, body_color=(140, 230, 255, 210), outline_color=(80, 190, 240, 255), fin_color=(190, 245, 255, 230), eye_color=(255, 255, 255, 255), whisker=True, glow_color=(100, 210, 255, 75))

    # 5: [LENDÁRIO] Carpa Astral
    draw_fish(5 * 24, body_color=(120, 55, 175, 255), outline_color=(75, 25, 120, 255), fin_color=(245, 200, 70, 255), eye_color=(255, 225, 100, 255), glow_color=(180, 90, 255, 70), stars=True)

    # 6: [LENDÁRIO] Salmão do Luar
    draw_fish(6 * 24, body_color=(220, 235, 245, 255), outline_color=(140, 165, 190, 255), fin_color=(138, 227, 255, 255), eye_color=(80, 190, 255, 255), glow_color=(138, 227, 255, 80))

    # 7: [LENDÁRIO] Peixe-Sol Dourado
    draw_fish(7 * 24, body_color=(255, 195, 30, 255), outline_color=(210, 130, 10, 255), fin_color=(255, 90, 20, 255), eye_color=(190, 30, 20, 255), glow_color=(255, 220, 80, 90), sunburst=True)

    sheet.save('assets/images/fishing/fishes.png')
    print("Created fishes.png (8 fish types)")

def create_bobber():
    # 2 frames of 16x16: Idle Bobber, Bite Bobber (submerged with ripples)
    sheet = Image.new('RGBA', (32, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(sheet)

    # Frame 0: Idle on water
    # Water ripples
    d.ellipse([2, 9, 13, 14], outline=(120, 190, 230, 200), width=1)
    # Red top / White bottom bobber
    d.polygon([(7, 4), (10, 4), (11, 8), (6, 8)], fill=(225, 45, 45, 255), outline=(160, 20, 20, 255))
    d.polygon([(6, 9), (11, 9), (9, 12), (8, 12)], fill=(245, 245, 240, 255), outline=(180, 180, 175, 255))
    # Little stick antenna
    d.line([(8, 1), (8, 4)], fill=(40, 35, 30, 255), width=1)
    d.point([(8, 1)], fill=(255, 230, 50, 255))

    # Frame 1: Bite! (Submerged into water with big splash ripples & exclamation)
    ox = 16
    d.ellipse([ox + 1, 9, ox + 14, 15], outline=(150, 225, 255, 255), width=1)
    d.ellipse([ox + 3, 10, ox + 12, 14], outline=(200, 240, 255, 255), width=1)
    # Bobber tugged down
    d.polygon([(ox + 7, 7), (ox + 10, 7), (ox + 11, 10), (ox + 6, 10)], fill=(225, 45, 45, 255))
    d.polygon([(ox + 6, 11), (ox + 11, 11), (ox + 9, 13), (ox + 8, 13)], fill=(245, 245, 240, 255))
    # Exclamation mark '!' above
    d.line([(ox + 8, 0), (ox + 8, 3)], fill=(255, 230, 50, 255), width=1)
    d.point([(ox + 8, 5)], fill=(255, 230, 50, 255))

    sheet.save('assets/images/fishing/bobber.png')
    print("Created bobber.png")

def create_rod():
    # 24x24 Fishing rod
    img = Image.new('RGBA', (24, 24), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    # Bamboo/wooden pole diagonal
    d.line([(3, 20), (18, 5)], fill=(150, 100, 45, 255), width=2)
    d.line([(18, 5), (21, 2)], fill=(185, 135, 65, 255), width=1)
    # Brass fittings / guides
    for pt in [(7, 16), (12, 11), (17, 6)]:
        d.point([pt], fill=(230, 190, 70, 255))
    # Reel near handle
    d.ellipse([4, 16, 8, 20], fill=(85, 90, 95, 255), outline=(50, 55, 60, 255))
    d.point([(6, 18)], fill=(225, 185, 50, 255))
    # Silk fishing line drooping down from tip
    d.line([(21, 2), (23, 7)], fill=(230, 240, 250, 200), width=1)
    d.line([(23, 7), (22, 14)], fill=(230, 240, 250, 180), width=1)

    img.save('assets/images/fishing/rod.png')
    print("Created rod.png")

def create_water_splash():
    # 16x16 water splash ripples
    img = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Ripple circles
    d.ellipse([1, 4, 14, 12], outline=(100, 190, 240, 255), width=1)
    d.ellipse([3, 6, 12, 10], outline=(170, 230, 255, 255), width=1)
    # Water droplets flying up
    d.point([(4, 2), (11, 2), (8, 1), (3, 3), (12, 3)], fill=(210, 245, 255, 255))
    img.save('assets/images/fishing/water_splash.png')
    print("Created water_splash.png")

if __name__ == '__main__':
    create_fishes()
    create_bobber()
    create_rod()
    create_water_splash()
    print("All fishing assets successfully generated!")

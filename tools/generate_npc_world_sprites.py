from PIL import Image, ImageDraw

def generate_npc_world_sprites():
    # 6 NPCs: 0=Bento, 1=Kael, 2=Helena, 3=Lúcio, 4=Íris, 5=Maya
    # 4 columns (16x24 each): 0=Down, 1=Up, 2=Left, 3=Right
    # Sheet size: 4 cols * 16 = 64 px wide; 6 rows * 24 = 144 px high

    sheet = Image.new('RGBA', (64, 144), (0, 0, 0, 0))

    npc_palette = [
        # Bento: olive coat, white hair tuft, brown pants
        {'coat': (90, 105, 70, 255), 'hair': (230, 230, 235, 255), 'skin': (235, 195, 160, 255), 'pants': (70, 50, 35, 255)},
        # Kael: brown apron, dark hair, grey pants
        {'coat': (65, 45, 30, 255), 'hair': (45, 35, 30, 255), 'skin': (225, 175, 140, 255), 'pants': (55, 60, 65, 255)},
        # Helena: moss green shawl, raven hair, violet skirt
        {'coat': (55, 75, 60, 255), 'hair': (40, 30, 45, 255), 'skin': (245, 215, 190, 255), 'pants': (80, 45, 95, 255)},
        # Lúcio: navy vest, teal beanie, grey beard
        {'coat': (45, 60, 85, 255), 'hair': (40, 85, 95, 255), 'skin': (215, 165, 125, 255), 'pants': (50, 45, 40, 255)},
        # Íris: burgundy tunic, auburn hair, brown boots
        {'coat': (120, 40, 50, 255), 'hair': (170, 75, 40, 255), 'skin': (250, 220, 195, 255), 'pants': (60, 80, 55, 255)},
        # Maya: ochre fur vest, honey blonde hair, green skirt
        {'coat': (160, 110, 50, 255), 'hair': (230, 185, 75, 255), 'skin': (250, 220, 195, 255), 'pants': (65, 100, 60, 255)},
    ]

    for row_idx, pal in enumerate(npc_palette):
        for col_idx in range(4): # 0=Down, 1=Up, 2=Left, 3=Right
            cell = Image.new('RGBA', (16, 24), (0, 0, 0, 0))
            d = ImageDraw.Draw(cell)

            # Head (center x=8, y=8)
            d.ellipse([4, 2, 11, 9], fill=pal['skin'])
            # Hair
            if col_idx == 1: # Up (back of head)
                d.ellipse([4, 1, 11, 8], fill=pal['hair'])
            else:
                d.arc([4, 1, 11, 7], start=180, end=360, fill=pal['hair'], width=2)
                d.point([(4, 4), (11, 4)], fill=pal['hair'])

            # Eyes
            if col_idx == 0: # Down
                d.point([(6, 6), (9, 6)], fill=(40, 30, 20, 255))
            elif col_idx == 2: # Left
                d.point([(5, 6)], fill=(40, 30, 20, 255))
            elif col_idx == 3: # Right
                d.point([(10, 6)], fill=(40, 30, 20, 255))

            # Body / Tunic
            d.rectangle([5, 10, 10, 16], fill=pal['coat'])

            # Legs / Feet
            d.line([(6, 17), (6, 22)], fill=pal['pants'], width=2)
            d.line([(9, 17), (9, 22)], fill=pal['pants'], width=2)

            sheet.paste(cell, (col_idx * 16, row_idx * 24))

    sheet.save('assets/images/characters/npcs.png')
    print('Saved assets/images/characters/npcs.png (64x144, 16x24 grid)')

if __name__ == '__main__':
    generate_npc_world_sprites()


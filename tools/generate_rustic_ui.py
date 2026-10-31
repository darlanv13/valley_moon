import os
from PIL import Image, ImageDraw

def generate_rustic_ui():
    os.makedirs('assets/images/ui', exist_ok=True)

    # 1. Parchment Panel (96x96 tileable / resizable aged parchment)
    parchment = Image.new('RGBA', (96, 96), (244, 236, 216, 255))
    d = ImageDraw.Draw(parchment)
    # Timber frame
    d.rectangle([0, 0, 95, 95], outline=(74, 51, 25, 255), width=3)
    d.rectangle([3, 3, 92, 92], outline=(150, 115, 75, 255), width=1)
    # Aged stains & texture
    for (x, y) in [(12, 18), (80, 24), (20, 75), (70, 70), (45, 40)]:
        d.ellipse([x-5, y-3, x+5, y+3], fill=(230, 215, 185, 255))
    # Corner rivets / studs
    for cx in [5, 90]:
        for cy in [5, 90]:
            d.rectangle([cx-1, cy-1, cx+1, cy+1], fill=(44, 29, 15, 255))
            d.point([(cx, cy)], fill=(180, 150, 100, 255))
    parchment.save('assets/images/ui/parchment_panel.png')

    # 2. Inventory Slot Frame (32x32)
    slot = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(slot)
    # Outer dark wood
    d.rectangle([0, 0, 31, 31], fill=(50, 35, 20, 255), outline=(30, 20, 10, 255))
    # Inner parchment well
    d.rectangle([3, 3, 28, 28], fill=(215, 195, 160, 255), outline=(90, 65, 35, 255))
    # Subtle inner bevel shadow
    d.line([(3, 3), (28, 3)], fill=(160, 140, 110, 255))
    d.line([(3, 3), (3, 28)], fill=(160, 140, 110, 255))
    slot.save('assets/images/ui/slot_frame.png')

    # 3. Selected Slot Frame (32x32)
    selected_slot = slot.copy()
    d = ImageDraw.Draw(selected_slot)
    # Glowing Moonstone gold/cyan border
    d.rectangle([0, 0, 31, 31], outline=(138, 227, 255, 255), width=2)
    selected_slot.save('assets/images/ui/slot_selected.png')

    # 4. Cast Iron Alchemy Cauldron (32x32)
    cauldron = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(cauldron)
    # Tripod feet
    d.polygon([(6, 26), (4, 31), (8, 31)], fill=(40, 42, 48, 255))
    d.polygon([(26, 26), (24, 31), (28, 31)], fill=(40, 42, 48, 255))
    d.polygon([(16, 27), (14, 31), (18, 31)], fill=(30, 32, 36, 255))
    # Iron Cauldron Belly
    d.ellipse([5, 12, 27, 28], fill=(55, 58, 65, 255), outline=(30, 32, 36, 255))
    # Rim
    d.ellipse([4, 10, 28, 16], fill=(70, 74, 82, 255), outline=(35, 38, 44, 255))
    # Bubbling magical concoction (Glowing Emerald & Violet)
    d.ellipse([7, 12, 25, 15], fill=(80, 220, 120, 255))
    d.point([(11, 13), (18, 14), (21, 13)], fill=(180, 255, 200, 255))
    # Bubbles rising
    d.ellipse([9, 7, 12, 10], fill=(90, 230, 140, 200), outline=(50, 180, 100, 255))
    d.ellipse([19, 5, 23, 9], fill=(180, 110, 240, 200), outline=(130, 70, 200, 255))
    d.point([(10, 8), (20, 6)], fill=(255, 255, 255, 255))
    # Swirling rune on iron belly
    d.arc([13, 18, 19, 24], start=45, end=315, fill=(138, 227, 255, 255), width=1)
    d.point([(16, 21)], fill=(200, 245, 255, 255))
    cauldron.save('assets/images/ui/cauldron.png')

    print("Rustic UI components generated successfully!")

if __name__ == '__main__':
    generate_rustic_ui()


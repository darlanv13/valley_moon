import os
import math
from PIL import Image, ImageDraw

os.makedirs("assets/images/ui", exist_ok=True)

# -------------------------------------------------------------------------
# 1. High-Resolution Mystic Moon App Icon (512x512)
# -------------------------------------------------------------------------
icon_size = 512
img_icon = Image.new("RGBA", (icon_size, icon_size), (0, 0, 0, 0))
draw = ImageDraw.Draw(img_icon)

# Dark rustic night sky background with rounded corners
bg_color = (25, 20, 28)
draw.rounded_rectangle([0, 0, icon_size, icon_size], radius=110, fill=bg_color)

# Outer cosmic nebula glow
center = (256, 210)
for r in range(190, 80, -4):
    alpha = int(45 * (1.0 - (r - 80) / 110))
    glow_color = (130, 95, 220, alpha)
    draw.ellipse([center[0] - r, center[1] - r, center[0] + r, center[1] + r], fill=glow_color)

# Luminous Crescent Moon
moon_center = (256, 195)
moon_radius = 115
# Outer gold moon disk
draw.ellipse([moon_center[0] - moon_radius, moon_center[1] - moon_radius,
              moon_center[0] + moon_radius, moon_center[1] + moon_radius], fill=(255, 225, 110))

# Inner crescent cutout
cutout_center = (295, 175)
cutout_radius = 100
draw.ellipse([cutout_center[0] - cutout_radius, cutout_center[1] - cutout_radius,
              cutout_center[0] + cutout_radius, cutout_center[1] + cutout_radius], fill=bg_color)

# Subtle moon craters on the crescent rim
draw.ellipse([180, 230, 196, 246], fill=(235, 195, 80))
draw.ellipse([215, 265, 227, 277], fill=(235, 195, 80))
draw.ellipse([160, 165, 172, 177], fill=(235, 195, 80))

# Sparkling 4-point stars
stars = [(90, 90), (410, 100), (370, 280), (110, 310), (430, 210), (280, 70)]
for sx, sy in stars:
    draw.polygon([(sx, sy - 14), (sx + 3, sy - 3), (sx + 14, sy), (sx + 3, sy + 3),
                  (sx, sy + 14), (sx - 3, sy + 3), (sx - 14, sy), (sx - 3, sy - 3)],
                 fill=(255, 245, 180))
    draw.ellipse([sx - 2, sy - 2, sx + 2, sy + 2], fill=(255, 255, 255))

# Foreground: Silhouetted rustic pine forest hills
hills = [
    # Back hill
    (0, 390, 512, 512),
]
draw.ellipse([-50, 340, 562, 600], fill=(42, 30, 48))
draw.ellipse([50, 360, 600, 620], fill=(28, 20, 32))

# Pixelated pine trees on the hill ridge
trees = [
    (110, 330, 28, 55),
    (150, 345, 22, 45),
    (200, 335, 32, 65),
    (256, 325, 36, 75), # Center tall pine
    (312, 335, 30, 60),
    (365, 345, 24, 48),
    (410, 330, 28, 55),
]
for tx, ty, tw, th in trees:
    # Trunk
    draw.rectangle([tx - 3, ty + th - 12, tx + 3, ty + th], fill=(18, 12, 22))
    # Foliage tiers
    for tier in range(3):
        t_w = tw * (0.5 + tier * 0.25)
        t_y = ty + (tier * (th * 0.26))
        draw.polygon([(tx, t_y), (tx + t_w / 2, t_y + th * 0.38), (tx - t_w / 2, t_y + th * 0.38)],
                     fill=(14, 10, 18))

# Bottom banner label: "VALLEY MOON"
draw.rectangle([70, 430, 442, 478], fill=(55, 35, 22), outline=(180, 130, 65), width=3)
# Golden inner trim
draw.rectangle([74, 434, 438, 474], outline=(240, 195, 80), width=2)

img_icon.save("assets/images/ui/app_icon.png")
print("Saved assets/images/ui/app_icon.png (512x512)")


# -------------------------------------------------------------------------
# 2. Gamepad Button Prompts Spritesheet (256x64)
# Row 0 (0..31): Xbox Buttons: [A], [B], [X], [Y], [LB], [RB], [LT], [RT] (32x32 each)
# Row 1 (32..63): PlayStation Buttons: [Cross], [Circle], [Square], [Triangle], [L1], [R1], [L2], [R2]
# -------------------------------------------------------------------------
img_pad = Image.new("RGBA", (256, 64), (0, 0, 0, 0))
draw_p = ImageDraw.Draw(img_pad)

btn_size = 32

# 2.1 Xbox Buttons (Row 0)
# A (Green)
draw_p.ellipse([4, 4, 28, 28], fill=(35, 150, 60), outline=(20, 90, 35), width=2)
draw_p.text((12, 8), "A", fill=(255, 255, 255))

# B (Red)
draw_p.ellipse([32 + 4, 4, 32 + 28, 28], fill=(210, 45, 45), outline=(130, 20, 20), width=2)
draw_p.text((32 + 12, 8), "B", fill=(255, 255, 255))

# X (Blue)
draw_p.ellipse([64 + 4, 4, 64 + 28, 28], fill=(35, 110, 210), outline=(20, 65, 140), width=2)
draw_p.text((64 + 12, 8), "X", fill=(255, 255, 255))

# Y (Yellow)
draw_p.ellipse([96 + 4, 4, 96 + 28, 28], fill=(230, 185, 30), outline=(150, 115, 15), width=2)
draw_p.text((96 + 12, 8), "Y", fill=(30, 25, 20))

# LB
draw_p.rounded_rectangle([128 + 2, 8, 128 + 30, 24], radius=4, fill=(70, 75, 80), outline=(40, 45, 50), width=2)
draw_p.text((128 + 8, 8), "LB", fill=(255, 255, 255))

# RB
draw_p.rounded_rectangle([160 + 2, 8, 160 + 30, 24], radius=4, fill=(70, 75, 80), outline=(40, 45, 50), width=2)
draw_p.text((160 + 8, 8), "RB", fill=(255, 255, 255))

# D-Pad
draw_p.rectangle([192 + 11, 4, 192 + 21, 28], fill=(60, 60, 65), outline=(30, 30, 35))
draw_p.rectangle([192 + 4, 11, 192 + 28, 21], fill=(60, 60, 65), outline=(30, 30, 35))

# Left Stick
draw_p.ellipse([224 + 4, 4, 224 + 28, 28], fill=(50, 50, 55), outline=(25, 25, 30), width=2)
draw_p.text((224 + 10, 8), "LS", fill=(200, 200, 200))


# 2.2 PlayStation Buttons (Row 1 at y = 32)
# Cross (Blue)
draw_p.ellipse([4, 36, 28, 60], fill=(45, 50, 60), outline=(25, 30, 35), width=2)
draw_p.line([11, 43, 21, 53], fill=(85, 140, 245), width=2)
draw_p.line([21, 43, 11, 53], fill=(85, 140, 245), width=2)

# Circle (Red)
draw_p.ellipse([32 + 4, 36, 32 + 28, 60], fill=(45, 50, 60), outline=(25, 30, 35), width=2)
draw_p.ellipse([32 + 10, 42, 32 + 22, 54], outline=(235, 75, 75), width=2)

# Square (Pink)
draw_p.ellipse([64 + 4, 36, 64 + 28, 60], fill=(45, 50, 60), outline=(25, 30, 35), width=2)
draw_p.rectangle([64 + 10, 42, 64 + 22, 54], outline=(235, 120, 185), width=2)

# Triangle (Green)
draw_p.ellipse([96 + 4, 36, 96 + 28, 60], fill=(45, 50, 60), outline=(25, 30, 35), width=2)
draw_p.polygon([(96 + 16, 42), (96 + 23, 53), (96 + 9, 53)], outline=(65, 215, 135), width=2)

# L1
draw_p.rounded_rectangle([128 + 2, 40, 128 + 30, 56], radius=4, fill=(55, 60, 65), outline=(30, 35, 40), width=2)
draw_p.text((128 + 8, 40), "L1", fill=(255, 255, 255))

# R1
draw_p.rounded_rectangle([160 + 2, 40, 160 + 30, 56], radius=4, fill=(55, 60, 65), outline=(30, 35, 40), width=2)
draw_p.text((160 + 8, 40), "R1", fill=(255, 255, 255))

# D-Pad
draw_p.rectangle([192 + 11, 36, 192 + 21, 60], fill=(50, 50, 55), outline=(25, 25, 30))
draw_p.rectangle([192 + 4, 43, 192 + 28, 53], fill=(50, 50, 55), outline=(25, 25, 30))

# Right Stick
draw_p.ellipse([224 + 4, 36, 224 + 28, 60], fill=(50, 50, 55), outline=(25, 25, 30), width=2)
draw_p.text((224 + 10, 40), "RS", fill=(200, 200, 200))

img_pad.save("assets/images/ui/gamepad_buttons.png")
print("Saved assets/images/ui/gamepad_buttons.png (256x64)")


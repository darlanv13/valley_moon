import urllib.request
import os

os.makedirs("assets/audio", exist_ok=True)

# 1. Download Kenney RPG and Browserquest audio
base_kenney = "https://raw.githubusercontent.com/Boyquotes/kenney-rpg-audio-for-godot/master/addons/kenney%20rpg%20audio/"
base_bq = "https://raw.githubusercontent.com/browserquest/BrowserQuest/master/client/audio/sounds/"

downloads = {
    # Loom spinning / weaving cloth
    "loom_spin.ogg": base_kenney + "cloth_belt.ogg",
    # Carpenter hammer striking timbers
    "carpenter_hammer.ogg": base_kenney + "metal_pot_1.ogg",
    # Barrel fermentation bubbling
    "barrel_bubble.ogg": base_bq + "heal.ogg",
    # Baby giggle / chime
    "baby_giggle.ogg": base_bq + "achievement.ogg",
    # Cooking sizzle
    "cooking_sizzle.ogg": base_bq + "loot.ogg",
}

for name, url in downloads.items():
    dest = os.path.join("assets/audio", name)
    print(f"Downloading {name} from {url}...")
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req) as resp:
            content = resp.read()
            with open(dest, "wb") as f:
                f.write(content)
        print(f"Saved {dest} ({len(content)} bytes)")
    except Exception as e:
        print(f"Error downloading {name}: {e}")

print("Stage 8 Audio download script finished!")

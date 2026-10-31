import os
import io
import requests
from PIL import Image

def download(url):
    print(f"Downloading {url}...")
    headers = {'User-Agent': 'Mozilla/5.0'}
    r = requests.get(url, headers=headers)
    if r.status_code != 200:
        raise Exception(f"Failed to download {url}: {r.status_code}")
    return r.content

os.makedirs('assets/images/player', exist_ok=True)
os.makedirs('assets/images/tiles', exist_ok=True)
os.makedirs('assets/tiles', exist_ok=True)
os.makedirs('assets/audio', exist_ok=True)
os.makedirs('assets/fonts', exist_ok=True)

# 1. Download Player Sprites
player_walk_url = "https://raw.githubusercontent.com/Tian-S-Y/SproutLands/main/Sprout%20Lands%20-%20Sprites%20-%20Basic%20pack/Characters/Basic%20Charakter%20Spritesheet.png"
player_actions_url = "https://raw.githubusercontent.com/Tian-S-Y/SproutLands/main/Sprout%20Lands%20-%20Sprites%20-%20Basic%20pack/Characters/Basic%20Charakter%20Actions.png"
tools_url = "https://raw.githubusercontent.com/Tian-S-Y/SproutLands/main/Sprout%20Lands%20-%20Sprites%20-%20Basic%20pack/Characters/Tools.png"

with open("assets/images/player/player_walk.png", "wb") as f:
    f.write(download(player_walk_url))

with open("assets/images/player/player_actions.png", "wb") as f:
    f.write(download(player_actions_url))

with open("assets/images/player/tools.png", "wb") as f:
    f.write(download(tools_url))

# 2. Download Tilesets and Objects
tiles_urls = {
    "grass.png": "https://raw.githubusercontent.com/Maaack/Sprout-Lands-Tilemap/main/addons/sprout_lands_tilemap/assets/Tilesets/Grass.png",
    "wooden_house.png": "https://raw.githubusercontent.com/Maaack/Sprout-Lands-Tilemap/main/addons/sprout_lands_tilemap/assets/Tilesets/Wooden%20House.png",
    "fences.png": "https://raw.githubusercontent.com/Maaack/Sprout-Lands-Tilemap/main/addons/sprout_lands_tilemap/assets/Tilesets/Fences.png",
    "objects.png": "https://raw.githubusercontent.com/Maaack/Sprout-Lands-Tilemap/main/addons/sprout_lands_tilemap/assets/Objects/Basic%20Grass%20Biom%20things%201.png",
    "water.png": "https://raw.githubusercontent.com/Maaack/Sprout-Lands-Tilemap/main/addons/sprout_lands_tilemap/assets/Tilesets/Water.png",
    "tilled_dirt.png": "https://raw.githubusercontent.com/Maaack/Sprout-Lands-Tilemap/main/addons/sprout_lands_tilemap/assets/Tilesets/Tilled%20Dirt.png",
    "paths.png": "https://raw.githubusercontent.com/Maaack/Sprout-Lands-Tilemap/main/addons/sprout_lands_tilemap/assets/Objects/Paths.png",
}

for name, url in tiles_urls.items():
    with open(f"assets/images/tiles/{name}", "wb") as f:
        f.write(download(url))

# 3. Download UI Sheet
ui_url = "https://raw.githubusercontent.com/Maaack/Sprout-Lands-UI/main/assets/Sprite%20sheet%20for%20Basic%20Pack.png"
with open("assets/images/ui_sheet.png", "wb") as f:
    f.write(download(ui_url))

# 4. Download Audio (Kenney RPG Audio SFX + BrowserQuest Village / Forest BGM)
audio_urls = {
    "village.ogg": "https://raw.githubusercontent.com/browserquest/BrowserQuest/master/client/audio/music/village.ogg",
    "forest.ogg": "https://raw.githubusercontent.com/browserquest/BrowserQuest/master/client/audio/music/forest.ogg",
    "footstep_grass.ogg": "https://raw.githubusercontent.com/Boyquotes/kenney-rpg-audio-for-godot/master/addons/kenney%20rpg%20audio/footstep_0.ogg",
    "chop.ogg": "https://raw.githubusercontent.com/Boyquotes/kenney-rpg-audio-for-godot/master/addons/kenney%20rpg%20audio/chop.ogg",
    "tool_swing.ogg": "https://raw.githubusercontent.com/Boyquotes/kenney-rpg-audio-for-godot/master/addons/kenney%20rpg%20audio/draw_knife_1.ogg",
    "door_open.ogg": "https://raw.githubusercontent.com/Boyquotes/kenney-rpg-audio-for-godot/master/addons/kenney%20rpg%20audio/door_open_1.ogg",
    "coins.ogg": "https://raw.githubusercontent.com/Boyquotes/kenney-rpg-audio-for-godot/master/addons/kenney%20rpg%20audio/handle_coins.ogg",
}

for name, url in audio_urls.items():
    try:
        with open(f"assets/audio/{name}", "wb") as f:
            f.write(download(url))
    except Exception as e:
        print(f"Warning: Audio {name} download failed: {e}")

# 5. Download Pixel Font
font_url = "https://raw.githubusercontent.com/google/fonts/main/ofl/pressstart2p/PressStart2P-Regular.ttf"
with open("assets/fonts/PressStart2P.ttf", "wb") as f:
    f.write(download(font_url))

print("Asset download step completed successfully!")

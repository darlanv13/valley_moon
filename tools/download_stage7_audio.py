import urllib.request
import os

os.makedirs("assets/audio", exist_ok=True)

downloads = {
    "boss_battle.ogg": "https://raw.githubusercontent.com/browserquest/BrowserQuest/master/client/audio/music/boss.ogg",
    "festival.ogg": "https://raw.githubusercontent.com/browserquest/BrowserQuest/master/client/audio/music/beach.ogg",
    "purify.ogg": "https://raw.githubusercontent.com/browserquest/BrowserQuest/master/client/audio/sounds/heal.ogg",
    "boss_roar.ogg": "https://raw.githubusercontent.com/browserquest/BrowserQuest/master/client/audio/sounds/death.ogg",
    "victory_fanfare.ogg": "https://raw.githubusercontent.com/browserquest/BrowserQuest/master/client/audio/sounds/achievement.ogg",
}

for name, url in downloads.items():
    dest = os.path.join("assets/audio", name)
    print(f"Downloading {name} from {url}...")
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as resp:
        content = resp.read()
        with open(dest, "wb") as f:
            f.write(content)
    print(f"Saved {dest} ({len(content)} bytes)")

print("Stage 7 Audio assets download complete!")


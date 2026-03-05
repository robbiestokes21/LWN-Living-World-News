# [LWN] Living World News
**Version:** 1.1.0 | **Engine:** Pokemon Essentials v21.1

A dynamic regional news system that makes your Pokemon fan game world feel alive. News headlines change based on the player's progress, time of day, and story flags — displayed on bulletin boards, TVs, and through NPC gossip. Includes a **Mystery Gift** system for distributing codes to players.

---

## Features

- **Bulletin Board** — Interactive board scene players can read in Pokemon Centers or towns
- **TV Broadcasts** — Repurpose any TV event to show the current top news headline
- **NPC Gossip** — Any NPC can casually mention the latest news with a single script call
- **Progress-Based News** — News items appear and disappear based on badges, switches, or any game condition
- **Dynamic News** — Post news programmatically at runtime (e.g. when the player beats a gym)
- **Day/Night News** — Optional `time_condition:` key for time-of-day specific stories
- **"New News" Indicator** — Tracks whether the board has unread content since last visit
- **Mystery Gift** — Distribute redeemable codes to players; gifts are delivered through a Pokemon Center NPC
- **PokeNav Tab** — Adds a "NEWS" tab to Simple PokeNav (if installed)
- **TFR Integration** — If [TFR] Trainer Fame & Reputation is installed, fame milestones and gym badges are automatically broadcast as news

---

## Requirements

| Plugin | Version | Required? |
|---|---|---|
| Pokemon Essentials | v21.1 | **YES** |
| v21.1 Hotfixes | v1.0.9+ | Recommended |
| [TFR] Trainer Fame & Reputation | v1.0.0+ | Optional (for fame milestone news) |
| Simple PokeNav | any | Optional (for PokeNav NEWS tab) |
| BW Mystery Gift | any | Optional (for password entry UI in Mystery Gift NPC) |

**No other plugins are required.**

---

## Installation

1. Copy the `[LWN] Living World News` folder into your game's `Plugins/` directory.
2. Launch the game once to compile — no errors should appear.
3. Wire it to your maps using event script calls (see Event Setup below).

---

## Event Setup

### Bulletin Board Event

Place an event on a board, sign, or poster tile in your Pokemon Center or town.

**In RPG Maker XP:**
1. Double-click the tile to create a new event
2. Set **Trigger** to `Action Button`
3. Set **Priority** to `Same as characters`
4. Add a **Script** command and enter:
```
pbShowBulletinBoard
```

**Optional — "New postings!" prompt before opening:**
```
pbBulletinBoardPrompt
```
This shows a message like *"The board has new postings!"* if new news appeared since the player last visited, then opens the board automatically.

---

### TV Event

In any TV event that currently uses `pbMessage` or a standard TV script:

1. Open the event
2. Replace the existing Script command content with:
```
pbShowNewsOnTV
```

This displays the highest-priority active news headline as a TV broadcast. If no news is active, it falls back to a generic message. It also **automatically activates the Mystery Gift switch** if unredeemed codes exist — no extra setup needed.

---

### NPC Gossip Event

Any NPC can casually mention the current news. In the NPC event's Script command:

```
pbNewsGossip
```

**Filter by category (optional):**
```
pbNewsGossip(:wildlife)
pbNewsGossip(:trainer)
pbNewsGossip(:weather)
pbNewsGossip(:breaking)
pbNewsGossip(:regional)
```

The NPC says the headline of the most relevant active news item in that category. If no news matches, they say a generic idle line.

---

### Mystery Gift NPC Event

**Step 1 — Configure the switch.**
Open `000_Settings.rb` and check the `MYSTERY_GIFT_SWITCH` value (default: `200`).
Make sure that switch number is not already used for something else in your game. Change the number if needed.

**Step 2 — Add your codes.**
Open `006_MysteryGift.rb` and fill in `MYSTERY_CODES` (see Mystery Gift section below).

**Step 3 — Create the NPC event.**
1. Place an NPC event in your Pokemon Center (near the front desk works well)
2. Open the event and click **New Event Page**
3. Under **Conditions**, check **Switch** and set it to Switch 200 (or whatever you set `MYSTERY_GIFT_SWITCH` to)
4. Set **Trigger** to `Action Button`
5. Set **Graphic** to whichever NPC character sprite you want
6. Add a **Script** command and enter:
```
pbMysteryGiftNPC
```

The NPC will only appear on the map when unredeemed codes exist, and disappears automatically once all codes are redeemed.

**Step 4 — Distribute codes externally.**
Post your codes on Discord, social media, or in your GitHub releases. Players enter them at the NPC.

---

### Post News from a Map Event (Dynamic)

After a major story moment — gym clear, Elite Four defeat, etc. — post a custom news item directly from your event:

1. In your post-battle or story event, add a **Script** command:
```ruby
LivingWorldNews.post_dynamic_news(
  id:       :gym1_cleared,
  category: :trainer,
  headline: "#{$player.name} defeats the first Gym Leader!",
  body:     "Trainers across the region are talking about a new challenger " \
            "who swept through the first gym without breaking a sweat.",
  priority: 6
)
```

The news appears on all bulletin boards and TVs immediately after posting.

---

## Adding Static News Stories

Edit `001_NewsData.rb` and add entries to the `STATIC_NEWS` array:

```ruby
{
  id:        :my_news_item,          # Unique symbol — must not repeat
  category:  :wildlife,              # :breaking :wildlife :trainer :weather :regional
  headline:  "Short headline here",  # Keep under 40 characters
  body:      "Full story text...",   # 2-3 sentences
  condition: proc { $player.badges.count(true) >= 4 },  # When to show it
  priority:  3,                      # Higher = shown first (0-10)
},
```

**Condition examples:**
```ruby
condition: proc { true }                              # Always show
condition: proc { $game_switches[5] }                 # After switch 5 is ON
condition: proc { $player.badges.count(true) >= 6 }   # After 6 badges
condition: proc { $player.halloffame != [] }           # Post-game only
```

**Day/Night condition (optional, add alongside `condition:`):**
```ruby
time_condition: proc { PBDayNight.isNight?(pbGetTimeNow) },  # Nighttime only
```

---

## Mystery Gift System

### Setup
1. Open `006_MysteryGift.rb` and add your codes to `MYSTERY_CODES`:

```ruby
MYSTERY_CODES = {
  "MYCODE2025" => {
    id:       :launch_gift_2025,
    rewards:  [{ type: :items, items: [[:POKEBALL, 10], [:POTION, 5]] }],
    headline: "Special gifts sent to trainers across the region!",
    body:     "Trainers who signed up for the newsletter received a special delivery.",
    message:  "You received 10 Poke Balls and 5 Potions!",
  },
}.freeze
```

2. Follow the **Mystery Gift NPC Event** steps above.
3. Distribute codes externally — Discord, social media, GitHub releases, etc.

### Reward Types
```ruby
{ type: :items,   items: [[:POKEBALL, 10], [:POTION, 5]] }          # Give items
{ type: :pokemon, species: :PIKACHU, level: 5, shiny: false }        # Give Pokemon
{ type: :switch,  id: 50 }                                           # Turn on game switch 50
```

Each code can only be redeemed **once per save file**. Codes are case-insensitive.

---

## File Structure

```
Plugins/[LWN] Living World News/
  meta.txt             Plugin metadata
  000_Settings.rb      Colors, max items, Mystery Gift switch ID, config
  001_NewsData.rb      All your static news stories go here
  002_LWNData.rb       Save data class (persists dynamic news + redeemed codes)
  003_NewsManager.rb   Core: active news filtering, time_condition support
  004_BulletinBoard.rb Bulletin board scene UI
  005_Helpers.rb       pbShowBulletinBoard, pbShowNewsOnTV, pbNewsGossip, pbBulletinBoardPrompt
  006_MysteryGift.rb   Mystery Gift code system + pbMysteryGiftNPC
  007_PokeNavTab.rb    PokeNav "NEWS" tab registration
```

---

## Credits

Created for **Pokemon Forever**.

Built on **Pokemon Essentials v21.1** by Maruno.

**BW Mystery Gift** by KleinStudio, Richard PT, and Maruno.
Used for the password entry UI in the Mystery Gift NPC (optional — falls back to plain text input if not installed).

**[TFR] Trainer Fame & Reputation** — companion plugin for broadcasting fame milestones and gym badge news.

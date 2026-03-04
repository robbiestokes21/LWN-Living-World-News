# [LWN] Living World News
**Version:** 1.0.0 | **Engine:** Pokemon Essentials v21.1

A dynamic regional news system that makes your Pokemon fan game world feel alive. News headlines change based on the player's progress, time of day, and story flags — displayed on bulletin boards, TVs, and through NPC gossip.

---

## Features

- **Bulletin Board** — Interactive board scene players can read in Pokemon Centers or towns
- **TV Broadcasts** — Repurpose any TV event to show the current top news headline
- **NPC Gossip** — Any NPC can casually mention the latest news with a single script call
- **Progress-Based News** — News items appear and disappear based on badges, switches, or any game condition
- **Dynamic News** — Post news programmatically at runtime (e.g. when the player beats a gym)
- **Day/Night News** — Optional `time_condition:` key for time-of-day specific stories
- **"New News" Indicator** — Tracks whether the board has unread content since last visit
- **TFR Integration** — If [TFR] Trainer Fame & Reputation is installed, fame milestones are automatically broadcast as news

---

## Requirements

| Plugin | Version | Required? |
|---|---|---|
| Pokemon Essentials | v21.1 | **YES** |
| v21.1 Hotfixes | v1.0.9+ | Recommended |
| [TFR] Trainer Fame & Reputation | v1.0.0+ | Optional (for fame milestone news) |
| Simple PokeNav | any | Optional (for PokeNav tab) |

**No other plugins are required.**

---

## Installation

1. Copy the `[LWN] Living World News` folder into your game's `Plugins/` directory.
2. Launch the game once to compile — no errors should appear.
3. Wire it to your maps using event script calls (see Usage below).

---

## Usage

### Bulletin Board
Place an event on any board/sign tile. In the event's **Script** command:
```
pbShowBulletinBoard
```
To show a "New postings!" indicator first:
```
pbBulletinBoardPrompt
```

### TV
In any TV event's Script command, replace existing content with:
```
pbShowNewsOnTV
```

### NPC Gossip
In any NPC event's Script command:
```
pbNewsGossip
```
Filter by category:
```
pbNewsGossip(:wildlife)
pbNewsGossip(:trainer)
pbNewsGossip(:weather)
```

### Post News from Events (Dynamic)
From any event script:
```ruby
LivingWorldNews.post_dynamic_news(
  id:       :my_unique_id,
  category: :breaking,
  headline: "Something happened!",
  body:     "The full story goes here.",
  priority: 8
)
```

---

## Adding Your Own News Stories

Edit `[LWN] Living World News/001_NewsData.rb` and add entries to the `STATIC_NEWS` array:

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

---

## File Structure

```
Plugins/[LWN] Living World News/
  meta.txt             Plugin metadata
  000_Settings.rb      Colors, max items, line width config
  001_NewsData.rb      All your static news stories go here
  002_LWNData.rb       Save data class (persists dynamic news)
  003_NewsManager.rb   Core: active news filtering
  004_BulletinBoard.rb Bulletin board scene UI
  005_Helpers.rb       pbShowBulletinBoard, pbShowNewsOnTV, pbNewsGossip
```

---

## Credits

Created for Pokemon Forever.
Built on Pokemon Essentials v21.1 by Maruno.

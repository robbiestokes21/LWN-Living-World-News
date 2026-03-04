#===============================================================================
# [LWN] Living World News
# News item definitions — EDIT THIS FILE to add your game's news stories.
#
# FORMAT: Each news item is a Hash with these keys:
#   id:        (Symbol)  Unique identifier — must be unique across all items
#   category:  (Symbol)  :breaking, :wildlife, :trainer, :weather, :regional
#   headline:  (String)  Short title shown on the board list
#   body:      (String)  2-3 sentence detail shown when the item is selected
#   condition: (Proc)    Lambda that returns true when this item SHOULD appear.
#                        Return true always to always show it.
#   priority:  (Integer) Higher = shown first. Default 0.
#   one_time:  (Boolean) If true, consumed after being read once. Default false.
#
# TIPS:
#  - Use $game_switches[N] for story-flag conditions
#  - Use $player.badges.count(true) >= N for badge-based conditions
#  - Use $player.halloffame != [] for post-game conditions
#  - Keep headline under 40 characters for clean display
#===============================================================================
module LivingWorldNews

  # -----------------------------------------------------------------------
  # STATIC NEWS ITEMS — conditions evaluated each time the board is opened.
  # Add your own entries following this template.
  # -----------------------------------------------------------------------
  STATIC_NEWS = [

    # --- Example: Always-visible intro news ---
    {
      id:        :intro_welcome,
      category:  :regional,
      headline:  "Regional Trainer League now open!",
      body:      "Challengers from across the region are invited to test their skills " \
                 "against Gym Leaders. Registration is open at any Pokemon Center.",
      condition: proc { true },
      priority:  0,
    },

    # --- Example: Wildlife — unlocks after getting 2 badges ---
    {
      id:        :wildlife_rare_sighting,
      category:  :wildlife,
      headline:  "Rare sighting near Route 6!",
      body:      "Hikers report spotting an unusually large Absol on Route 6 at dusk. " \
                 "Rangers advise caution. Trainers with DexNav may want to investigate.",
      condition: proc { $player.badges.count(true) >= 2 },
      priority:  1,
    },

    # --- Example: Trainer news — after beating 4 gyms ---
    {
      id:        :trainer_rising_star,
      category:  :trainer,
      headline:  "New challenger making waves!",
      body:      "Gym Leaders are reporting a fierce new challenger sweeping through " \
                 "the circuit. Could this be the next regional champion in the making?",
      condition: proc { $player.badges.count(true) >= 4 },
      priority:  2,
    },

    # --- Example: Breaking news after Hall of Fame ---
    {
      id:        :hof_champ_news,
      category:  :breaking,
      headline:  "New Champion crowned!",
      body:      "History was made at the Pokemon League! A determined trainer defeated " \
                 "the Elite Four and claimed the Champion title. The region celebrates!",
      condition: proc { $player.halloffame != [] && !$player.halloffame.empty? },
      priority:  10,
    },

    # --- Example: Weather warning (links nicely with a Seasonal System) ---
    {
      id:        :weather_storm_warning,
      category:  :weather,
      headline:  "Storm warning for coastal routes",
      body:      "The Weather Institute forecasts heavy rain and strong winds along " \
                 "coastal routes this week. Trainers are advised to bring extra Repels.",
      condition: proc { $player.badges.count(true) >= 3 },
      priority:  0,
    },

    # --- Add your own news items below this line ---

  ].freeze

  # -----------------------------------------------------------------------
  # DYNAMIC NEWS — posted programmatically (e.g. from TFR fame milestones).
  # Do not edit this array directly; use LivingWorldNews.post_dynamic_news().
  # -----------------------------------------------------------------------
  # (Populated at runtime and stored in LWNSaveData)

end

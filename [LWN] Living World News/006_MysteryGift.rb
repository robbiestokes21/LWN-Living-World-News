#===============================================================================
# [LWN] Living World News — Mystery Gift System
#
# How to use:
#   1. Add codes to MYSTERY_CODES below. Distribute codes externally
#      (Discord, social media, GitHub releases, etc.)
#   2. When the player watches TV (pbShowNewsOnTV), switch MYSTERY_GIFT_SWITCH
#      is automatically turned ON if any unredeemed codes exist.
#   3. Place a Mystery Gift NPC in your Pokemon Center with appearance condition:
#      Switch MYSTERY_GIFT_SWITCH = ON
#   4. In that NPC's event script call:
#      pbMysteryGiftNPC
#===============================================================================

module LivingWorldNews

  #-----------------------------------------------------------------------------
  # Define your Mystery Gift codes here.
  #
  # "CODE" => {
  #   id:       :unique_symbol,          # Must be unique per code
  #   rewards:  [                        # Array of reward hashes
  #     { type: :items,   items: [[:POKEBALL, 10], [:POTION, 5]] },
  #     { type: :pokemon, species: :PIKACHU, level: 5, shiny: false },
  #     { type: :switch,  id: 50 },      # Turns on game switch 50
  #   ],
  #   headline: "News headline text",    # Optional — posted to LWN board
  #   body:     "Full news body text.",  # Optional — shown in news detail
  #   message:  "You received a gift!",  # Message shown when redeemed
  # }
  #
  # Example (uncomment and edit to activate):
  #
  # MYSTERY_CODES = {
  #   "FOREVER2025" => {
  #     id:       :launch_gift_2025,
  #     rewards:  [{ type: :items, items: [[:POKEBALL, 10], [:POTION, 5]] }],
  #     headline: "Special gifts sent to trainers across the region!",
  #     body:     "Trainers who signed up for the Pokemon Forever newsletter " \
  #               "received a special delivery this week.",
  #     message:  "You received 10 Poke Balls and 5 Potions!",
  #   },
  # }.freeze
  #-----------------------------------------------------------------------------
  MYSTERY_CODES = {
    "FOREVER2025" => {
      id:       :launch_gift_2025,
      rewards:  [{ type: :items, items: [[:POKEBALL, 10], [:POTION, 5]] }],
      headline: "Special gifts sent to trainers across the region!",
      body:     "Trainers who signed up for the Pokemon Forever newsletter " \
                 "received a special delivery this week.",
      message:  "You received 10 Poke Balls and 5 Potions!",
     },
  }.freeze

  #-----------------------------------------------------------------------------
  # Returns true if any codes in MYSTERY_CODES have not been redeemed yet.
  #-----------------------------------------------------------------------------
  def self.mystery_gift_available?
    return false unless defined?($LWNData) && $LWNData
    MYSTERY_CODES.any? do |_code_str, data|
      !lwn_data.redeemed_codes[data[:id]]
    end
  end

  #-----------------------------------------------------------------------------
  # Called by pbShowNewsOnTV. Sets MYSTERY_GIFT_SWITCH ON/OFF based on whether
  # unredeemed codes exist. The Mystery Gift NPC uses this switch to appear.
  #-----------------------------------------------------------------------------
  def self.check_mystery_gift_switch
    return unless defined?($game_switches) && $game_switches
    $game_switches[MYSTERY_GIFT_SWITCH] = mystery_gift_available?
  end

  #-----------------------------------------------------------------------------
  # Validate and redeem a code string entered by the player.
  # Returns :success, :already_redeemed, or :not_found.
  #-----------------------------------------------------------------------------
  def self.redeem_code(input_str)
    return :not_found unless defined?($LWNData) && $LWNData
    code_key = MYSTERY_CODES.keys.find { |k| k.casecmp(input_str.strip) == 0 }
    return :not_found unless code_key

    code_data = MYSTERY_CODES[code_key]
    code_id   = code_data[:id]
    return :already_redeemed if lwn_data.redeemed_codes[code_id]

    # Mark redeemed before giving rewards so an error mid-reward doesn't double-give
    lwn_data.redeemed_codes[code_id] = true

    # Deliver rewards
    (code_data[:rewards] || []).each do |reward|
      case reward[:type]
      when :items
        (reward[:items] || []).each do |item_sym, qty|
          $bag.add(item_sym, qty || 1)
        end
      when :pokemon
        pkmn       = Pokemon.new(reward[:species], reward[:level] || 5)
        pkmn.shiny = true if reward[:shiny]
        pbAddPokemon(pkmn)
      when :switch
        $game_switches[reward[:id]] = true if reward[:id]
      end
    end

    # Post optional news item
    if code_data[:headline]
      post_dynamic_news(
        id:       :"mystery_gift_#{code_id}",
        category: :breaking,
        headline: code_data[:headline],
        body:     code_data[:body] || "",
        priority: 8,
        one_time: false,
      )
    end

    check_mystery_gift_switch
    return :success
  end

end

#-------------------------------------------------------------------------------
# pbMysteryGiftNPC
# Call this from the Mystery Gift NPC's event Script command.
# The NPC should have appearance condition: Switch MYSTERY_GIFT_SWITCH = ON
#-------------------------------------------------------------------------------
def pbMysteryGiftNPC
  pbMessage(_INTL("Welcome! I'm the Mystery Gift delivery person.\nIf you have a special code, I have a gift for you!"))
  unless pbConfirmMessage(_INTL("Do you have a code to enter?"))
    pbMessage(_INTL("No problem! Come back when you have one.\nCodes are shared through official Pokemon Forever channels."))
    return
  end

  # Use BW Mystery Gift password UI if available, otherwise plain text entry
  input = if defined?(pbEnterPasswordFreeText)
    pbEnterPasswordFreeText("Enter your gift code:", 16)
  else
    pbEnterText("Enter your code:", 0, 16)
  end
  if input.nil? || input.strip.empty?
    pbMessage(_INTL("No code entered. Come back anytime!"))
    return
  end

  result = LivingWorldNews.redeem_code(input)
  case result
  when :success
    code_key  = LivingWorldNews::MYSTERY_CODES.keys.find { |k| k.casecmp(input.strip) == 0 }
    code_data = LivingWorldNews::MYSTERY_CODES[code_key]
    msg = code_data&.dig(:message) || "You received a special gift!"
    pbMessage(_INTL("A valid code! Wonderful!\n{1}", msg))
  when :already_redeemed
    pbMessage(_INTL("It looks like you've already redeemed that code.\nEach code can only be used once per save file."))
  when :not_found
    pbMessage(_INTL("Hmm... I don't recognize that code.\nDouble-check it and try again!"))
  end
end

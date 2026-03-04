#===============================================================================
# [LWN] Living World News
# Settings and configuration
#===============================================================================
module LivingWorldNews

  #-----------------------------------------------------------------------------
  # Maximum number of news items shown on a bulletin board at once.
  #-----------------------------------------------------------------------------
  MAX_BULLETIN_ITEMS = 5

  #-----------------------------------------------------------------------------
  # Maximum characters per news body line before wrapping.
  #-----------------------------------------------------------------------------
  BODY_LINE_WIDTH = 36

  #-----------------------------------------------------------------------------
  # Colours used in the bulletin board scene.
  #-----------------------------------------------------------------------------
  COLOR_BREAKING   = Color.new(200,  40,  40)   # Red   — breaking news
  COLOR_WILDLIFE   = Color.new( 30, 120,  50)   # Green — wildlife
  COLOR_TRAINER    = Color.new( 30,  60, 180)   # Blue  — trainer news
  COLOR_WEATHER    = Color.new( 80,  80, 200)   # Indigo — weather
  COLOR_REGIONAL   = Color.new(140,  90,  20)   # Brown — regional events
  COLOR_DEFAULT    = Color.new( 60,  60,  60)   # Dark grey — default
  COLOR_SHADOW     = Color.new(180, 180, 180)   # Shadow for all text

  #-----------------------------------------------------------------------------
  # Returns the colour for a news category symbol.
  #-----------------------------------------------------------------------------
  def self.color_for(category)
    case category
    when :breaking  then COLOR_BREAKING
    when :wildlife  then COLOR_WILDLIFE
    when :trainer   then COLOR_TRAINER
    when :weather   then COLOR_WEATHER
    when :regional  then COLOR_REGIONAL
    else                 COLOR_DEFAULT
    end
  end

  #-----------------------------------------------------------------------------
  # Category labels shown on the board.
  #-----------------------------------------------------------------------------
  CATEGORY_LABELS = {
    breaking: "[BREAKING]",
    wildlife: "[WILDLIFE]",
    trainer:  "[TRAINER]",
    weather:  "[WEATHER]",
    regional: "[REGION]",
  }.freeze

  def self.label_for(category)
    CATEGORY_LABELS[category] || "[NEWS]"
  end

end

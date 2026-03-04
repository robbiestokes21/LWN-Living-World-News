#===============================================================================
# [LWN] Living World News
# Save data class and registration
#===============================================================================

#-------------------------------------------------------------------------------
# LWNSaveData — stores dynamic/runtime news items that persist with the save.
#-------------------------------------------------------------------------------
class LWNSaveData
  # Array of Hashes: dynamic news items posted at runtime
  attr_accessor :dynamic_news    # [{ id:, category:, headline:, body:, posted_at: }]
  # Set of news IDs the player has already read (for one_time items)
  attr_accessor :read_ids        # { :SYMBOL => true }

  def initialize
    @dynamic_news = []
    @read_ids     = {}
  end

  def dynamic_news; @dynamic_news ||= []; end
  def read_ids;     @read_ids     ||= {}; end
end

SaveData.register(:lwn_save_data) do
  ensure_class :LWNSaveData
  save_value   { $LWNData }
  load_value   { |value| $LWNData = value }
  new_game_value { LWNSaveData.new }
  reset_on_new_game
end

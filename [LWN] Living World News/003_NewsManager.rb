#===============================================================================
# [LWN] Living World News
# NewsManager — filters and returns currently active news items.
#===============================================================================
module LivingWorldNews

  #-----------------------------------------------------------------------------
  # Returns an Array of active news item Hashes, sorted by priority (descending).
  # Combines static conditions-based items and dynamic runtime items.
  # Omits one_time items that have already been read.
  #-----------------------------------------------------------------------------
  def self.active_news
    result = []

    # Static items from STATIC_NEWS
    STATIC_NEWS.each do |item|
      next if item[:one_time] && lwn_data.read_ids[item[:id]]
      begin
        active = item[:condition].call
      rescue => e
        active = false
      end
      result << item if active
    end

    # Dynamic items (posted at runtime, e.g. from TFR)
    lwn_data.dynamic_news.each do |item|
      next if item[:one_time] && lwn_data.read_ids[item[:id]]
      result << item
    end

    # Sort by priority descending, then cap at MAX
    result.sort_by! { |i| -(i[:priority] || 0) }
    return result.first(MAX_BULLETIN_ITEMS)
  end

  #-----------------------------------------------------------------------------
  # Post a dynamic news item at runtime.
  # The item will persist in the save file.
  # If an item with the same id already exists it is replaced (updated).
  #-----------------------------------------------------------------------------
  def self.post_dynamic_news(id:, category:, headline:, body:, priority: 5, one_time: false)
    return unless defined?($LWNData) && $LWNData
    # Remove existing item with same id
    lwn_data.dynamic_news.reject! { |i| i[:id] == id }
    lwn_data.dynamic_news << {
      id:       id,
      category: category,
      headline: headline,
      body:     body,
      priority: priority,
      one_time: one_time,
    }
  end

  #-----------------------------------------------------------------------------
  # Mark a one_time item as read so it won't appear again.
  #-----------------------------------------------------------------------------
  def self.mark_read(item_id)
    return unless defined?($LWNData) && $LWNData
    lwn_data.read_ids[item_id] = true
  end

  #-----------------------------------------------------------------------------
  # Called by [TFR] when the player earns a new title tier.
  #-----------------------------------------------------------------------------
  def self.post_fame_milestone(title_sym, title_text)
    return unless defined?($LWNData) && $LWNData
    name = $player ? $player.name : "A trainer"
    post_dynamic_news(
      id:       :"fame_milestone_#{title_sym}",
      category: :trainer,
      headline: "#{name} earns the title: #{title_text}!",
      body:     "Word is spreading across the region — #{name} has reached the " \
                "rank of #{title_text}. Gym Leaders and trainers are talking.",
      priority: 6,
      one_time: false,
    )
  end

  #-----------------------------------------------------------------------------
  # Internal: safe accessor for $LWNData
  #-----------------------------------------------------------------------------
  def self.lwn_data
    $LWNData ||= LWNSaveData.new
  end

end

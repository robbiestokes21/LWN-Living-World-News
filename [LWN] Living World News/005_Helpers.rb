#===============================================================================
# [LWN] Living World News
# Helper methods for TVs and NPC gossip — call from event scripts.
#===============================================================================

#-------------------------------------------------------------------------------
# pbShowNewsOnTV
# Shows the top news headline as a TV broadcast message.
# Call from any event that represents a TV (e.g. in houses, Pokemon Centers).
#
# Example event script call:
#   pbShowNewsOnTV
#-------------------------------------------------------------------------------
def pbShowNewsOnTV
  items = LivingWorldNews.active_news
  if items.empty?
    pbMessage(_INTL("The TV shows nothing but static..."))
    return
  end
  top = items.first
  cat = LivingWorldNews.label_for(top[:category])
  pbMessage(_INTL("...The TV flickers on.\n" \
                  "\"{1} {2}\"\\1", cat, top[:headline]))
  # Optionally offer to hear more
  if pbConfirmMessage(_INTL("...Read the full story?"))
    pbMessage(_INTL("{1}\\1", top[:body]))
    LivingWorldNews.mark_read(top[:id]) if top[:one_time]
  end
end

#-------------------------------------------------------------------------------
# pbNewsGossip
# Makes an NPC say the most recent news headline casually.
# Pass an optional category filter to limit gossip to a specific type.
#
# Example event script calls:
#   pbNewsGossip                   # any category
#   pbNewsGossip(:wildlife)        # only wildlife news
#   pbNewsGossip(:trainer)         # only trainer news
#-------------------------------------------------------------------------------
def pbNewsGossip(category = nil)
  items = LivingWorldNews.active_news
  items = items.select { |i| i[:category] == category } if category
  if items.empty?
    pbMessage(_INTL("\"I haven't heard any interesting news lately...\""))
    return
  end
  item = items.first
  pbMessage(_INTL("\"Did you hear? {1}\"\\1", item[:headline]))
end

#-------------------------------------------------------------------------------
# pbShowAllNews
# Opens the full bulletin board directly.
# Alias of pbShowBulletinBoard — included here for discoverability.
#-------------------------------------------------------------------------------
alias pbShowAllNews pbShowBulletinBoard if !respond_to?(:pbShowAllNews)

#===============================================================================
# [LWN] Living World News — PokeNav Tab
# Adds a "NEWS" tab to Simple PokeNav (if installed).
# Opens the bulletin board from the PokeNav menu.
#===============================================================================
MenuHandlers.add(:pokenav_menu, :lwn_news_tab, {
  "name"      => proc { "NEWS" },
  "order"     => 65,
  "condition" => proc { next defined?($LWNData) && $LWNData },
  "effect"    => proc { |menu| pbShowBulletinBoard; next false },
})

#===============================================================================
# [LWN] Living World News
# Bulletin Board Scene — shown when the player interacts with a board.
# Call pbShowBulletinBoard from a map event script to open it.
#===============================================================================

class LWN_BulletinBoard_Scene
  ITEMS_PER_PAGE = LivingWorldNews::MAX_BULLETIN_ITEMS
  LINE_H         = 32
  MARGIN         = 16

  def pbStartScene
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}

    # Background overlay (semi-transparent)
    @sprites["bg"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["bg"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0, 180))

    # Board panel (white card)
    panel_w = [Graphics.width - 64, 480].min
    panel_h = Graphics.height - 64
    panel_x = (Graphics.width - panel_w) / 2
    panel_y = 32
    @panel_x = panel_x
    @panel_y = panel_y
    @panel_w = panel_w

    @sprites["panel"] = BitmapSprite.new(panel_w, panel_h, @viewport)
    bmp = @sprites["panel"].bitmap
    bmp.fill_rect(0, 0, panel_w, panel_h, Color.new(250, 245, 235))
    bmp.fill_rect(0, 0, panel_w, 6, Color.new(180, 130, 60))
    bmp.fill_rect(0, panel_h - 6, panel_w, 6, Color.new(180, 130, 60))
    @sprites["panel"].x = panel_x
    @sprites["panel"].y = panel_y

    @sprites["text"] = BitmapSprite.new(panel_w, panel_h, @viewport)
    pbSetSystemFont(@sprites["text"].bitmap)
    @sprites["text"].x = panel_x
    @sprites["text"].y = panel_y

    @selected   = 0
    @news_items = LivingWorldNews.active_news
    @state      = :list   # :list or :detail
    drawList
    pbFadeInAndShow(@sprites)
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  #-----------------------------------------------------------------------------
  # Draw the list of headlines
  #-----------------------------------------------------------------------------
  def drawList
    bmp = @sprites["text"].bitmap
    bmp.clear

    # Title bar
    pbDrawTextPositions(bmp, [
      [_INTL("REGIONAL BULLETIN BOARD"), @panel_w / 2, 14, 2,
       Color.new(100, 60, 10), Color.new(220, 180, 100)]
    ])

    if @news_items.empty?
      pbDrawTextPositions(bmp, [
        [_INTL("No news at this time."), @panel_w / 2, 80, 2,
         Color.new(100, 100, 100), Color.new(200, 200, 200)]
      ])
      return
    end

    y = 52
    @news_items.each_with_index do |item, i|
      selected  = (i == @selected)
      cat_color = LivingWorldNews.color_for(item[:category])
      cat_label = LivingWorldNews.label_for(item[:category])

      # Selection highlight
      if selected
        bmp.fill_rect(MARGIN - 4, y - 2, @panel_w - MARGIN * 2 + 8, LINE_H + 4, Color.new(220, 210, 180))
        bmp.fill_rect(MARGIN - 4, y - 2, 4, LINE_H + 4, cat_color)
      end

      # Category label
      pbDrawTextPositions(bmp, [
        [_INTL(cat_label), MARGIN + 4, y, 0, cat_color, LivingWorldNews::COLOR_SHADOW]
      ])

      # Headline
      label_w = 90
      pbDrawTextPositions(bmp, [
        [_INTL(item[:headline]), MARGIN + label_w, y, 0,
         Color.new(30, 30, 30), LivingWorldNews::COLOR_SHADOW]
      ])
      y += LINE_H + 4
    end

    # Footer hint
    pbDrawTextPositions(bmp, [
      [_INTL("A: Read  B: Close"), @panel_w / 2, @panel_w - 20, 2,
       Color.new(120, 120, 120), LivingWorldNews::COLOR_SHADOW]
    ])
  end

  #-----------------------------------------------------------------------------
  # Draw a single news item in detail view
  #-----------------------------------------------------------------------------
  def drawDetail(item)
    bmp = @sprites["text"].bitmap
    bmp.clear

    cat_color = LivingWorldNews.color_for(item[:category])
    cat_label = LivingWorldNews.label_for(item[:category])

    # Category pill
    pbDrawTextPositions(bmp, [
      [_INTL(cat_label), MARGIN, 14, 0, cat_color, LivingWorldNews::COLOR_SHADOW]
    ])

    # Headline
    pbDrawTextPositions(bmp, [
      [_INTL(item[:headline]), MARGIN, 46, 0,
       Color.new(20, 20, 20), LivingWorldNews::COLOR_SHADOW]
    ])

    # Separator line
    bmp.fill_rect(MARGIN, 76, @panel_w - MARGIN * 2, 2, Color.new(180, 160, 130))

    # Body text — word-wrap manually
    body_y = 88
    words   = item[:body].split(" ")
    line    = ""
    words.each do |word|
      test = line.empty? ? word : "#{line} #{word}"
      if test.length > LivingWorldNews::BODY_LINE_WIDTH
        pbDrawTextPositions(bmp, [
          [_INTL(line), MARGIN, body_y, 0, Color.new(50, 50, 50), LivingWorldNews::COLOR_SHADOW]
        ])
        body_y += LINE_H
        line = word
      else
        line = test
      end
    end
    unless line.empty?
      pbDrawTextPositions(bmp, [
        [_INTL(line), MARGIN, body_y, 0, Color.new(50, 50, 50), LivingWorldNews::COLOR_SHADOW]
      ])
    end

    # Footer hint
    pbDrawTextPositions(bmp, [
      [_INTL("B: Back to list"), @panel_w / 2, @panel_w - 20, 2,
       Color.new(120, 120, 120), LivingWorldNews::COLOR_SHADOW]
    ])

    # Mark one-time items as read
    LivingWorldNews.mark_read(item[:id]) if item[:one_time]
  end

  #-----------------------------------------------------------------------------
  # Main input loop
  #-----------------------------------------------------------------------------
  def pbBulletinBoard
    loop do
      Graphics.update
      Input.update
      pbUpdate

      if @state == :list
        if Input.trigger?(Input::DOWN)
          @selected = (@selected + 1) % [@news_items.size, 1].max
          pbPlayCursorSE
          drawList
        elsif Input.trigger?(Input::UP)
          @selected = (@selected - 1) % [@news_items.size, 1].max
          pbPlayCursorSE
          drawList
        elsif Input.trigger?(Input::USE) && !@news_items.empty?
          pbPlayDecisionSE
          @state = :detail
          drawDetail(@news_items[@selected])
        elsif Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          break
        end

      elsif @state == :detail
        if Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
          pbPlayCancelSE
          @state = :list
          drawList
        end
      end
    end
  end
end

#-------------------------------------------------------------------------------
# Public helper — call this from a map event script to open the board.
#
# Example event script call:
#   pbShowBulletinBoard
#-------------------------------------------------------------------------------
def pbShowBulletinBoard
  scene = LWN_BulletinBoard_Scene.new
  scene.pbStartScene
  scene.pbBulletinBoard
  scene.pbEndScene
end

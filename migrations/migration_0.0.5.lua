-- destroy the city info guy, which makes the GUI class recreate it in its new form
for _, player in pairs(game.players) do
    player.gui.top["sosciencity-city-info"].destroy()
end

if game.forces.player.technologies["clockwork-caste"].researched then
    game.forces.player.technologies["upbringing"].researched = true
end
global.technologies["upbringing"] = game.forces.player.technologies["upbringing"].researched

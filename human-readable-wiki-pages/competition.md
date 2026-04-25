# Competition for Resources

In Sosciencity there are some buildings that use natural resources, like the [entity=groundwater-pump] which uses ground water, the [entity=hunting-hut] which needs nearby forests or the [entity=fishing-hut] which needs nearby water bodies. 

There is a phenomenon I like to call 'Competition for Resources'. That means: if there are multiple of these buildings present in an area, they begin to overuse the natural resources present. They hinder each other and lower each others performance. You still get more productivity in total. But the individual building will work slower with each one sharing the area.

## Recipe Specialisation

For [entity=hunting-hut] and [entity=fishing-hut], the competition penalty is reduced when neighbouring buildings are set to **different recipes**. A neighbour hunting searching for something else only counts as 30% of a full competitor, since they are exploiting a different part of the ecosystem. Two huts targeting the same prey or the same fish species compete at full strength.

So if you want to pack several of these buildings close together, setting them to different recipes is a good way to reduce how much they slow each other down.

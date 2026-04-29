#Fear

Your city exists in a world that can turn hostile. When buildings get destroyed - whether by enemy raids, accidents, or other disasters - the news spreads through your population. Huwans are not oblivious to what's happening around them. They get scared. This is represented by the **Fear** level.


##How Fear builds up

Fear is a city-wide value. It doesn't matter which neighbourhood was hit: the whole population hears about it.

Two kinds of events raise fear:

- **A civil building is destroyed:** A moderate shock. The news is unsettling, but no one died.
- **An inhabited house is destroyed:** A larger shock. People died, and your inhabitants know it. The survivors are much more shaken.

Fear doesn't just stack up linearly. Each event pushes fear closer to a cap of **10**, but with diminishing returns - the further fear already is from zero, the smaller the next bump will be. The first raid is terrifying. The tenth feels almost expected.

This means fear can never exceed 10, no matter how many buildings are destroyed in quick succession.


##How Fear decays

Fear is not permanent. After **one nauvis day** without a new incident, it starts to fade on its own. The longer the peace holds, the faster the recovery - but getting from a high fear level back to zero still takes around 15 minutes of uninterrupted calm.

There is no active way to reduce fear faster. The only solution is to stop the destruction.


##What Fear does

High fear takes a toll on your inhabitants' **Sanity**. Each point of fear subtracts from the sanity of every house in your city.

How severely fear affects a caste depends on their **fear susceptibility**:

- **[caste=gunfire] and [caste=plasma]:** Susceptibility of 40%. Soldiers are trained to operate under fire, Medicals have seen people from the inside - fear has a vastly reduced effect on them.
- **[caste=clockwork]:** Susceptibility of 70%. Those mechanics aren't exactly the sensitive kind.
- **Most castes:** Susceptibility of 100%. Full effect.

Remember low sanity values cause a happiness penalty - so sustained fear doesn't just hurt sanity, leading to more mental health problems. It drags happiness down with it.

#Food

Food keeps your inhabitants alive and in good spirits. What they eat affects their **happiness**, **health** and **sanity**. Every caste has an eating behavior that determines which foods they include in their diet.


##Eating Behaviors

Every caste is either a minimalist, a foodie or a mixed eater. This governs which foods end up in their diet.

###Minimalist

Minimalists don't eat for pleasure. They choose foods strictly to cover their nutritional needs, preferring favored-tasting foods first, neutral foods second and disliked foods as a last resort. They stop picking foods once all nutrition tags are covered. Taste perks like appeal still apply, but they won't eat extra foods just for variety.

###Foodie

Foodies value variety over healthiness. They eat every favored and neutral food they can get - but refuse disliked foods outright. If no suitable food is available they go into food distress rather than compromise their standards.

###Mixed

Mixed eaters balance variety with nutritional coverage. They pick all their favored foods, then fill missing nutrition tags from neutral foods, and finally pull in more neutral foods until they hit their minimum variety count.


##Taste

Each caste has one taste they **favor** and one they **dislike**. The remaining tastes are neutral filler.

- Each favored-tasting food in the diet gives a happiness bonus.
- Each disliked-tasting food gives a happiness malus.
- Having at least one favored food in the diet gives a flat sanity bonus - a small comfort from eating something you enjoy.
- If the disliked taste becomes the plurality of the diet, that monotony of bad food deals a sanity malus.


##Appeal

Every food has an **appeal** value that reflects how pleasant it is to eat, independent of taste. The three highest-appeal foods in the diet each contribute to a flat happiness bonus. Adding more appealing foods is always safe - appeal never has a negative effect, and it stacks up to three foods.


##Nutrition Tags

Foods can carry one or more **nutrition tags** like *protein-rich*, *fat-rich* or *carb-rich*. A well-rounded diet covers all three.

- Each covered tag type gives a health bonus.
- Each missing tag type gives a health malus.
- How important nutritional balance is varies by caste.

When building a diet, the eating behavior tries to cover all three tags before adding purely variety-boosting foods. A single food can cover multiple tags if it carries them.


##Variety

Each caste has a **minimum food count** - the number of different foods they expect in their diet.

- Going below the minimum causes a happiness malus per missing food.
- Going above the minimum gives a small happiness bonus per extra food.
- The malus scales linearly: a shortfall of two foods costs twice as much as a shortfall of one.


##Food Distress

When no food matches the caste's normal eating behavior but some food is available, the inhabitants enter **food distress**. They fall back to whatever is on hand:

- *Minimalists* and *mixed eaters* pick the most appealing available foods.
- *Foodies* are stuck eating their disliked foods.

During food distress all taste-based happiness effects are suppressed - there's no point tracking taste when you have no choice. Instead a caste-specific **distress factor** applies a multiplicative penalty to happiness. Castes later in the progression have stricter distress factors and are less forgiving of a poorly stocked pantry.

Food distress is distinct from outright **starvation** (absolutely no food). 


##Starvation

When there is no food at all - not even something to fall back on - inhabitants starve. Starvation skips all diet effects entirely: no appeal bonus, no taste effects, no nutrition tag evaluation. Instead, two flat multipliers kick in:

- A harsh **happiness factor** halves nominal happiness.
- A harsh **health factor** halves nominal health.

The longer it goes on, the more likely inhabitants are to get sick of malnutrition diseases.

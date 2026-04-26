# Healthcare

My name is Belascef. I am a physician of the Plasma Caste, and I have been asked to explain our healthcare infrastructure to you. I will be thorough. Please pay attention.

City builders consistently underestimate disease. They focus on food, power, production - fine, those matter - but they leave the medical side of things until something goes wrong. I have seen what happens then. It is not productive.

Let's make sure that does not happen to you.


## Diseases

Huwans get sick. It is a fact of life. The categories of diseases you will encounter are:

- **General diseases** - caused by poor health. Common, usually mild.
- **Mental health conditions** - caused by poor sanity. More disruptive, slower to treat.
- **Workplace injuries and exhaustion** - working takes a toll. Every job type carries its own risk profile.
- **Birth defects** - some huwans arrive with these. Difficult to treat and they do not heal naturally.
- **Escalations** - a disease left untreated can progress into something worse. This is avoidable. Treat your sick.
- **Complications** - occasionally a treatment doesn't go cleanly and produces a secondary condition. This is rare, but worth knowing.

Some diseases resolve on their own over time. Others do not, and a small number are contagious - meaning they will spread to healthy huwans who interact with the sick. Early treatment is almost always better than waiting.

Sick huwans can still work, but at reduced capacity. They will not pull full shifts in a factory. You want them healthy.

[linked-page=data/diseases]


## The Med Bay and the Hospital

You have two main options for a treatment facility.

The **[entity=medbay]** is what you will build first. It covers a decent area, treats common diseases, and doesn't ask for much. It has one significant limitation: it works on its own. It cannot be supplemented with additional specialist facilities. For a small city or an outpost this is usually fine.

The **[entity=hospital]** is the serious option. Larger coverage, higher treatment capacity, faster throughput - and crucially, it can be extended with specialist buildings. If you are running a large population or your huwans are dealing with serious conditions, you want a hospital.

Both facilities need trained Plasma Caste workers to function. An understaffed hospital treats nobody.


## Specialist Facilities

Some diseases require more than a standard medical setup. Place these next to a hospital to unlock the relevant treatments:

- **[entity=psych-ward]** - required for mental health conditions: depression, schizophrenia, and similar.
- **[entity=intensive-care-unit]** - required for critical physical conditions.
- **[entity=gene-clinic]** - required for genetic diseases.

These do nothing next to a med bay. They only function as extensions of a full hospital.


## Medicines and the Pharmacy

Treatment costs medicine items. The hospital consumes these when it begins treating a patient - so keep your medical inventory stocked. You can store medicines directly in the hospital building.

The **[entity=pharmacy]** is an additional storage building. Place it near a hospital and that hospital will draw from its inventory as well - treating it as an extension of its own supplies. One pharmacy per hospital is usually sufficient; you can add more if your medicine variety is high and the storage is getting crowded.


## Treatment Capacity

A hospital has a fixed number of patients it can treat at the same time. When all available beds are in use, new cases in range simply wait. You can see the current occupancy by opening the hospital.

If your hospital is frequently full, you have a few options: build an additional facility, adjust which diseases you're treating, or improve throughput with better staffing and happier workers.

From the hospital interface you can also toggle **treatment permissions** per disease. This lets you exclude specific diseases from treatment - useful if you're rationing a particular medicine, or if you want to deliberately redirect certain cases.


## Blood Donations

This is a bonus, not a priority, but worth mentioning. Healthy huwans in good health will occasionally donate blood to a nearby hospital. The hospital uses some surgical supplies and one treatment slot to process the donation and produce a [item=blood-bag] for later use.

You can set a minimum number of free treatment slots that must remain available before the hospital accepts donations. I recommend setting this so that actual patients are never displaced for a blood draw.


## Outposts and Sanatoriums

Here is where most city builders eventually run into trouble. You expand your city, build an outpost a good distance away, and then realize that your main hospital does not reach that far. Building a full hospital at every outpost is expensive and logistically demanding. There is a better approach.

Any non-improvised house can be designated as a **sanatorium** - you will find the option in the house's general settings tab. A sanatorium is not a hospital. It does not treat anyone. What it does is this: it keeps itself free for patients. Healthy huwans are moved out as they arrive. Sick huwans who have been waiting too long for treatment - because no hospital has been able to reach them - will eventually make their way there on their own.

Once they are in the sanatorium, the nearby hospital treats them like any other patient in range. When they recover, they leave the sanatorium and return to normal housing - and typically find their way back to the outpost they came from.

A few things to keep in mind:

- **The sanatorium needs to be within your hospital's range.** Place it close to the hospital, not the outpost. The hospital treats whomever is inside; the sanatorium just gets them there.
- **The hospital still needs to be able to treat the disease.** A sanatorium near a hospital without a psych ward will not help your mentally ill patients - they'll need to find a different sanatorium near a hospital that has one.
- **Local healthcare still matters.** Sick huwans don't travel immediately. They wait a while first - long enough for a local med bay to step in if one is available. A med bay at your outpost will handle common cases on the spot and only send the serious ones to the sanatorium. This is the intended setup. Don't skip the outpost med bay and expect the sanatorium to do everything.

To summarize the intended layout: outpost has a med bay for routine care; main city has a hospital with all the specialist facilities; one or two houses near that hospital are marked as sanatoriums. Sick huwans who can be treated locally are treated locally. The ones who can't make the trip.

That is a functional healthcare system. Build that, keep the medicine stocked, keep your Plasma workers happy, and your city will be fine.

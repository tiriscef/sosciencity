# Housing

Every huwan needs a place to sleep. Before inhabitants can move in anywhere, you need to build houses and assign them to a caste. This page gives an overview how houses work, how comfort affects your people's happiness, and how to upgrade and manage houses efficiently.


## House Basics

Houses come in many shapes and sizes, from improvised [entity=living-container]s to spacious mansions. The key properties of a house are:

- **Rooms:** How many rooms the house has. Each caste requires a certain number of rooms per inhabitant (shown in the caste info), so a bigger house isn't always a bigger population - it depends on who moves in.
- **Max. Comfort:** The highest comfort level this house can ever reach. Different house types have different ceilings.
- **Qualities:** Fixed characteristics of the house that certain castes prefer or dislike - things like being spacious, compact, or cheap. These affect the happiness bonus inhabitants get from their home.

You can see all of these in the house's detail view by clicking on it.


## Assigning a Caste

An unoccupied house won't attract inhabitants on its own - you need to assign it to a caste first. There are several ways to do this.

### Via the Detail View

Click an empty house and go to the **Caste Chooser** tab. You'll see a button for each caste you've unlocked. The button colour tells you what to expect:

- **Normal:** The house is a good fit for this caste right now.
- **Orange:** The current comfort is below the caste's minimum, but the house *can* reach it with upgrades. Inhabitants will move in but be unhappy until you upgrade.
- **Red:** Either the house doesn't have enough rooms for even one inhabitant of this caste, or the house's max comfort is too low to ever reach the caste's minimum - even fully upgraded it won't satisfy them.

Clicking a caste button assigns the house and moves inhabitants in immediately if any are available.

You can also reassign an occupied house by using the **Kickout** button (visible in the occupied house detail view), which removes the current inhabitants and lets you pick a new caste.

### Via the Placement Panel

When you're holding a house item in your cursor, a placement panel appears in the City Info (the interface at the top of the screen). Here you can set:

- **Comfort:** The comfort level you want the house to reach after placement. The house will start at comfort 0 and automatically request furniture from your logistics network to work toward this target.
- **Caste:** Which caste to assign the house to on placement. If you have enough furniture in your inventory, it will also be used toward the first upgrade immediately.

Selecting no caste at all skips auto-assignment entirely and places the house unassigned.

These settings are saved per caste - switching the caste dropdown in the panel loads that caste's last-used target comfort.

### Via Copy-Paste (Settings Paste)

Copy a house with **Shift+Right-Click** and paste its settings onto another with **Shift+Left-Click** (the standard Factorio settings-paste shortcut). This copies the caste assignment and target comfort to the destination house and immediately attempts an upgrade using items from your inventory.

- Pasting from an occupied house to an empty one: assigns the same caste and applies the target comfort.
- Pasting between two houses of the same state: copies target comfort and attempts upgrade from your inventory - but does not change caste if the destination is already occupied.

### Via Blueprints

When you include a house in a blueprint, the blueprint captures the caste assignment, comfort level, target comfort and housing priority. When the blueprint is placed:

- The captured caste is auto-assigned when the house is built.
- The captured target comfort is applied, and the house will begin requesting furniture from the logistics network.

If a blueprint is placed in an area with existing logistics infrastructure, the upgrade process starts automatically - no manual intervention needed.


## Comfort

Comfort is a measure of how nicely furnished a house is. Every house starts empty and barren at a Comfort Level of 0 when placed. Each caste has a **minimum comfort** they'd prefer to live at. Living below that threshold doesn't prevent them from moving in - they'll take what they can get - but it does make them less happy and thus less productive.

The happiness penalty scales proportionally: a house at half the caste's minimum comfort causes roughly half the normal comfort happiness. Once you reach the minimum, the penalty disappears entirely.

You can check the minimum comfort for each caste in the caste info panel.


## Upgrading Comfort

To raise a house's comfort level, you need to furnish it with the right items - beds, bathroom furniture, carpets, curtains, and so on. Each comfort level has its own upgrade cost **per room**, so larger houses cost proportionally more to upgrade. You can look up the exact costs for each level in the recipe browser under the "Housing Upgrades" category.

Higher comfort levels are gated behind **architecture technologies**. You won't be able to upgrade past a certain level until you've researched the required tech.

When you deconstruct a house, all items that went into furnishing are refunded to you.

### Manual Upgrade

Open the house's detail view and switch to the **House Info** tab. If the next comfort level is unlocked, you'll see an upgrade button showing the cost. Clicking it consumes the required items - first from the house's own chest inventory, then from your personal inventory - and immediately raises the comfort by one level.

### Automated Upgrade via Logistics

In the same tab, you can set a **target comfort** using a stepper control. Once a target is set, the house will automatically request the furniture it needs from the logistics network. If possible, Construction Robots will deliver them. When the items arrive in the house's chest, the upgrade happens on its own. You can queue up multiple levels at once - the house will keep requesting and upgrading until it reaches the target.


## Housing Priority

In the occupied house detail view there's a **Priority** field. This controls which houses inhabitants prefer when choosing where to live. Higher priority houses fill up first. You can use the preset buttons (low, mid, high, very high) or type in a custom value.

Priority is also saved in blueprints and copied by settings-paste.

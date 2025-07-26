# pet-overflow

Game idea and the layout is created in this project in pet-overflow, the game is 2D scroller, there is one long room where you can move the camera to one and other side and interact with pets, each pet has 2 meters - satisfied, angry.

Terms:
- Game name - "To satisfy or not to that is my question"
- Room name - Pudio.
- Meters - Wrath and Satisfactions.
- Pets - Besties, Bobs.
- Objects - Jectors, Bits.

Game settings:
- 12FPS.
- 800x600 game size, 45x45 border, 700x500 room size.
- 100x100 character sprite size.
- 400x200 animation size.
- Godot v4.4.1

Starting the development and project layout:
- Put sample gifs, pngs and anything.

Gameplay:
- 2D.
- Long room from one side to other.
- Camera is specific size and you can move the camera from one side of the room to other.
- Pets are randomly spawned in the whole room starting with 1 and then moving to 2 in a random order.
- Player can die either if one pets satisfaction bar overflow or the wrath bar overflows triggering a death scene. The death scene will be a cutscene, but for starters leave it as text on screen.
- Objects that pets need to interact with will be randomly spawned with random counts every certain period, like specific minute or event, when a new pet is spawned.

Character:
- No physical body.
- Mouse has 3 states - interactable, holding creature, freehand.
- Point and click, move the camera with arrows.

Satisfaction meter:
- Linear increase.
- Slowly decreases.
- can overflow causing the player to die.

Wrath meter:
- Slow increase.
- Decrease on satisfaction.
- Can overflow causing the player to die.

Pets:
- Pets are drag and dropped onto an object or a zone like a specific room or a part of the room.
- Each pet has 1 object or zones that can satisfy it, wrong object gets the pet more angry. The satisfactory objects are always the same. Object triggers a gif animation.
- There are 5 pets for now and randomly a pet can be a nature of it can't be moved and it will anger it.
- Pets spawn at random places in the long room.
- Each pet has their own spawn rate from all of the pets, if there are 5 pets, one of them should have a lower spawn rate unless it is the last.
- Pets can move, some pets have 2 states - stand and walk, the walking is in random directions.

Objects:
- Can be move to pets if they are not of objection zone types like a shower or a bath.
- Can be movable object or zone object.
- Can interact with pets.
- Have their own spawn rate on specific times or when a pet appears.

Animations:
- Spending time with the pet is in a 400x200 animation screen where a scene is played

> v3 addition
Pets:
- Lamont the wet owl:
    - Satisfaction: Water
    - Wrath: Everything else
    - Movement: Can be moved, Stays in one place
- Concept of Time:
    - Satisfaction: Time (hour glass)
    - Wrath: Everything else
    - Movement: Can't be moved, Moves (floats) by itself
    - Sates: If angry, instead of the color it is filled with flashing images of handsigns, if happy, kitties.
    - Nature: If angry, it runs out of the camera view and is FAST!!!
- Gambling addict Pupols:
    - Satisfaction: Playing cards (card deck)
    - Wrath: Everything else, but water in particular(water glass, bath, puddles)
    - Movement: Can be moved, Hates being moved
- Julijas dators:
    - Satisfaction: Jam, wooden spoons, gameboys <3 (jam jar, wooden spoon, gameboy)
    - Wrath: Everything else, but water in particular (water glass, bath, puddles)
    - Movement: Can be moved, Stays in a single place
    - Lowest spawn rate
- Toaster:
    - Satisfaction: Toast, Walks
    - Wrath: Everything else
    - Movement: Can be moved, Stays in a single place
    - Highest spawn rate

> v3 addition
Objects:
- Jam Jar:
    - Movable
    - Spawn conditions:
        - Randomly spawns
        - Only 1 can be in the house
    - Interaction:
        - When dragging a pet to it or dragging it to a pet, it triggers an interaction
- Wooden Spoon:
    - Movable
    - Spawn conditions:
        - Randomly spawns
        - Only 1 can be in the house
    - Interaction:
        - When dragging a pet to it or dragging it to a pet, it triggers an interaction
- Bath:
    - Not movable
    - Spawn conditions:
        - Is always in the house at the start of the game
        - Only 1 can be in the house
    - Interaction:
        - When dragging a pet to it
        - Nothing happens on collision when not interacting
- Outside door:
    - Not movable
    - Spawn conditions:
        - Is always in the house at the start of the game
        - Only 1 can be in the house
    - Interaction:
        - When dragging a pet to it
        - Nothing happens on collision when not interacting
- Puddle:
    - Not movable
    - Spawn conditions:
        - Wet owl is in the room
        - Only 3 can be in the house
    - Spawn location:
        - Randomy appears where the owl has walked
    - Interaction:
        - When dragging a pet to it
        - Nothing happens on collision when not interacting
- Card deck:
    - Movable
    - Spawn conditions:
        - Randomly spawns
        - Only 1 can be in the house
    - Interaction:
        - When dragging a pet to it or dragging it to a pet, it triggers an interaction
        - When a pet walks near it, it triggers an interaction (only applicable to Pupols)
- Gameboy:
    - Movable
    - Spawn conditions:
        - Randomly spawns
        - Only 1 can be in the house
    - Interaction:
        - When dragging a pet to it or dragging it to a pet, it triggers an interaction
        - When a pet walks near it, it triggers an interaction
- Water glass:
    - Movable
    - Spawn conditions:
        - Randomly spawns
        - Only 1 can be in the house
    - Interaction:
        - When a pet walks near it, it triggers an interaction
        - When dragging a pet to it or dragging it to a pet, it triggers an interaction
- Toast:
    - Movable
    - Spawn conditions:
        - Randomly spawns
        - Only 1 can be in the house
    - Interaction:
        - When dragging a pet to it or dragging it to a pet, it triggers an interaction
        - Nothing happens on collision when not interacting
- Hour glass:
    - Movable
    - Spawn conditions:
        - Randomly spawns
        - Only 1 can be in the house
    - Interaction:
        - When dragging a pet to it or dragging it to a pet, it triggers an interaction
        - Nothing happens on collision when not interacting


Interaction nature:
- After collision, the interaction is triggered
    - If the interaction is successful, the collision is on cooldown for a certain amount of time
    - [ ] Visualize it, add a timer on top of it


> v3 addition
Game intesity:
- The more pets, the angrier they get
- The more pets, the faster they move

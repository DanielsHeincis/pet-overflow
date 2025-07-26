# pet-overflow

Game idea and the layout is created in this project in pet-overflow, the game is 2D scroller, there is one long room where you can move the camera to one and other side and interact with pets, each pet has 2 meters - satisfied, angry.

TODO:
- [ ] BUG: Gravity doesn't work when releasing objects.
- [ ] BUG: The act of drag and dropping is very laggy, can't properly pick up and let go.
- [ ] BUG: Some random blue screen blocks that are not even objects or pets keep spawning.
- [ ] BUG: If the blue stupid block is the same thing, then the unique pet spawning doesn't work.
- [ ] BUG: Moving the screen with arrows doesn't work at all.
- [ ] BUG: The owl doesn't seem to move at all, check if the right animation is played if the pet is in motion. - FIXED: Enabled autonomous movement for the wet owl.
- [ ] BUG: Object doesn't disappear after interaction.

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

Controls:
- Player can move the camera to left and right with arrow keys or WASD.
- Player can hover over an object to interact with it.
- Player can click and drag an object to interact with it.
- Player can click and drag a pet to interact with it.
- Player can click on a pet to toggle its satisfaction and wrath meters for a few seconds.

Physics:
- Objects are affected by gravity.
- Pets are affected by gravity.
- Pets can walk through objects but can collide based on the conditions.
- Pets can move by themselves.

Cutscenes:
- Death scene. Happy or Sad.
- Pet satisfaction scene.
- Pet wrath scene.
- Game finish scene.

Game finish:
- All pets are spawned.
- All objects are spawned.
- All pets are satisfied enough for one minute.
- All pets are not overangered.
- All pets are not oversatisfied.

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
- Slowly increases by time.

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

Pets:
- Lamont the wet owl:
    - Satisfaction: water_glass
    - Wrath: Everything else
    - No effect on: puddle
    - Movement: Can be moved, Stays in one place
- Concept of Time:
    - Satisfaction: hour_glass
    - Wrath: Everything else
    - Movement: Can't be moved, Moves (floats) by itself
    - Sates: If angry, instead of the color it is filled with flashing images of handsigns, if happy, kitties.
    - Nature: If angry, it runs out of the camera view and is FAST!!!
- Gambling addict Pupols:
    - Satisfaction: card_deck
    - Wrath: Everything else, but water in particular(water glass, bath, puddles)
    - Movement: Can be moved, Hates being moved
- Julijas dators:
    - Satisfaction: jam_jar, wooden_spoon, gameboy
    - Wrath: Everything else, but water in particular (water glass, bath, puddles)
    - Movement: Can be moved, Stays in a single place
    - Lowest spawn rate
- Toaster:
    - Satisfaction: toast, outside_door
    - Wrath: Everything else
    - Movement: Can be moved, Stays in a single place
    - Highest spawn rate

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

Pet movement:
- Some pets move by themselves
- Some pets can't be moved
- Some pets hate being moved
- Some pets move in random directions
- Pets only walk on ground and can only move horizontal

Interaction nature:
- After collision, the interaction is triggered
    - If the interaction is successful, the collision is on cooldown for a certain amount of time
    - [ ] Visualize it, add a timer on top of it

Game intesity:
- The more pets, the angrier they get
- The more pets, the faster they move

## Register Touch
> [!NOTE]
> Example 02 Finger Up

### Lean Touch
MAIN COMPONENT
Root Hierarchy
Let the app receive the touch input data and use it as easy data.
- Tap Threshold: 0.5
- Swipe Threshold: 50
- Reference Dpi: 200
- Gui Layers: UI

- Use Touch: On
- Use Hover: On
- Use Mouse: On
- Use Simulator: On

- Disable Mouse Emulation: On
- Record Fingers: On
    - Record Threshold: 5
    - Record Limit: 0
    
### Lean Finger Down
COMPONENT
Root Hierarchy
Detect whether a finger start touching.
- Ignore Started Over Gui: On
- Required Buttons: Everything
- Required Selectable: NONE

- On Finger (LeanFinger):
    - EMPTY

- Screen Depth: Fixed Distance
    - Camera: NONE
    - Distance: 10
- On World (LeanVector3):
    - Runtime Only; Transform.position; GameObject;

- On Screen (Vector2):
    - EMPTY
    
> [!NOTE]
> In this example it track when the finger touch the screen, it will move the GameObject Transform.position (X,Y) where the finger was at a Distance (Z) of 10.

### Lean Finger Up
COMPONENT
Root Hierarchy
Detect whether a finger leave the screen, therefore, end the touching input.
    
> [!NOTE]
> The example [Lean Finger Down](#lean-finger-down) could be used here. The unique thing that will change is how the event is trigger. When the touch start or when it ends.


## Register Tap
> [!NOTE]
> Example 07 Finger Tap

### Lean Touch
MAIN COMPONENT
Root Hierarchy
Let the app receive the touch input data and use it as easy data.
- Tap Threshold: 0.5
- Swipe Threshold: 50
- Reference Dpi: 200
- Gui Layers: UI

- Use Touch: On
- Use Hover: On
- Use Mouse: On
- Use Simulator: On

- Disable Mouse Emulation: On
- Record Fingers: On
    - Record Threshold: 5
    - Record Limit: 0
    
### Lean Finger Down
COMPONENT
Root Hierarchy
Detect whether a finger start touching.
- Ignore Started Over Gui: On
- Required Buttons: Everything
- Required Selectable: NONE

- On Finger (LeanFinger):
    - Runtime Only; Text.text; GameObject;

- Screen Depth: Fixed Distance
    - Camera: NONE
    - Distance: 10
- On World (LeanVector3):
    - EMPTY

- On Screen (Vector2):
    - EMPTY
    
### Lean Finger Tap
COMPONENT
Root Hierarchy
Detect whether a finger start touching.
- Ignore Started Over Gui: On
- Ignore Is Over Gui: Off
- Required Selectable: NONE
- Required Tap Count: 0
- Required Tap Interval: 0

- On Finger (LeanFinger):
    - EMPTY
    
- On Count (Int32):
    - Runtime Only; LeanFormatString.SetString; GameObject;

- Screen Depth: Fixed Distance
    - Camera: NONE
    - Distance: 10
- On World (LeanVector3):
    - EMPTY

- On Screen (Vector2):
    - EMPTY


## Select GameObject On Tab
> [!NOTE]
> Example 15 Tap To Select

### Lean Touch
MAIN COMPONENT
Root Hierarchy
Let the app receive the touch input data and use it as easy data.
- Tap Threshold: 0.2
- Swipe Threshold: 100
- Reference Dpi: 200
- Gui Layers: UI

- Use Touch: On
- Use Hover: On
- Use Mouse: On
- Use Simulator: On

- Disable Mouse Emulation: On
- Record Fingers: On
    - Record Threshold: 5
    - Record Limit: 0

### Tap To Select
COMPONENT
Root Hierarchy
Brain that contains all the logic. This know wheter there is a tap actions, and if the tap was on a object so it have to be selected.

#### Lean Finger Tap
SCRIPT
Detect whether a finger make a tap.
- Ignore Started Over Gui: On
- Ignore Is Over Gui: Off
- Required Selectable: NONE
- Required Tap Count: 2
- Required Tap Interval: 0

- On Finger (LeanFinger):
    - Runtime Only; LeanSelectByFinger.SelectScreenPosition; Script;
    
- On Count (Int32):
    - EMPTY

- Screen Depth: Fixed Distance
    - Camera: NONE
    - Distance: 0
- On World (LeanVector3):
    - EMPTY

- On Screen (Vector2):
    - EMPTY

#### Lean Select By Finger
SCRIPT
Logic that make the selection/deselection.
- Screen Query: Raycast
    - Camera: NONE
    - Layers: Default, TransparentFX, Water, UI
    - Search: Get Components In Parent
    - Required Tag: NONE
    
- Deselect With Fingers: Off
- Deselect With Nothing: On

- Limit: Unlimited
- Reselect: Keep Selected
    
> [!NOTE]
> To make 3 selectable at a time just change:
> - Limit: Deselect First
>   - Max Selectables: 3

### Game Objects
COMPONENT
Root Hierarchy
This compoenent is the father that contains more Selectable GameObjects

#### Square
COMPONENT
Selectectable Object

##### Lean Selectable By Finger
SCRIPT
This tell the brain script that this object is a selectable one
- Use: All Fingers
- Is Selected: Off
    - Self Selected: Off


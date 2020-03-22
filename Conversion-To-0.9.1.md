This document describes the steps necessary to convert projects with prior versions of Scenes to version 0.9.1.
Be sure to read through the Scenes documentation before proceeding.


Naming conventions:
       We'll assume that your existing project is called: "OldProjectName"
       We'll assume that your new project name is called "NewProjectName"
       We'll further assume that these projects share a common parent directory.

1. Start by cloning a new project of the current ScenesShell:
```bash
   git clone https://github.com/TheCoderMerlin/ScenesShell NewProjectName
```

2. Protect the SceneShell source files in NewProjectName:
```bash
    cd NewProjectName/Sources/ScenesShell
    rename 's/swift/swift.org/' *.swift
```

3. Copy the source files from OldProjectName to NewProjectName
```bash
    cp -r ../../../OldProjectName/Sources/ScenesShellD/*.swift .
```

4. Edit your Director file.

4A. Change the name of your Director class to ShellDirector.
    The class should inherit from Director rather than DirectorBase.
```swift
// Change from:
class Director : DirectorBase

// To:
class ShellDirector : Director 
```

4B. Remove the functions:
```swift
    override func nextScene() -> Scene?
    override func shouldSceneTerminate() -> Bool
```

    Instead, use:
```swift
    required init() {
       enqueueScene(scene:MainScene())
    }
    
    // If you later want to transition, use:
    enqueueScene(scene:NextScene()) 
    transitionToNextScene()
```

4C. Update preSetup() parameters
If you use the preSetup() method, update the signature to include canvasSize:
```swift
// Change from:
override func preSetup(canvas:Canvas)

// To:
override func preSetup(canvasSize:Size, canvas:Canvas)
```

If you used a guard or other conditional to check to ensure that canvasSize was not nil,
you may safely remove that code and use the new parameter directly.

5. Edit your Layer file(s).
5A. Update preSetup() parameters
If you use the preSetup() method, update the signature to include canvasSize:
```swift
// Change from:
override func preSetup(canvas:Canvas)

// To:
override func preSetup(canvasSize:Size, canvas:Canvas)
```

If you used a guard or other conditional to check to ensure that canvasSize was not nil,
you may safely remove that code and use the new parameter directly.


6. Edit your RenderableEntity file(s).
6A. Update setup() parameters
If you use the setup() method, update the signature to include canvasSize:
```swift
// Change from:
override func setup(canvas:Canvas)

// To:
override func setup(canvasSize:Size, canvas:Canvas)
```

6B. Remove override from init():
```swift
// Change from:
override init()

// To:
init()
```

6C. Add a super.init() with a name inside your init() constructor:
```swift
super.init(name:"Sky") 
```

If you used a guard or other conditional to check to ensure that canvasSize was not nil,
you may safely remove that code and use the new parameter directly.

6D. The class should inherit from RenderableEntity rather than RenderableEntityBase.
```swift
// Change from:
class Player : RenderableEntityBase

// To:
class Player : RenderableEntity
```

7. Update your event handling.  Note that only Scene, Layer, and RenderableEntity may accept events.
7A. Remove the "override" modifier for each handler
```swift
// Change from:
override func onKeyDown(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool)

// To:
func onKeyDown(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool)
```

7B. Declare conformance to the relevant protocol:
```swift
// Change from:
class InteractionLayer : Layer

// To:
class InteractionLayer : Layer, KeyDownHandler 
```

7C. Register your handler in setup:
```swift

```


7D. Unregister your handler in teardown:
```swift
```

7E. Remove wantsMouseEvents():
```swift
 override func wantsMouseEvents() -> MouseEventTypeSet 
```

Simply delete the entire method; it is no longer necessary.

8. Update the name of your director in Main
```swift
// Change from:
    try igis.run(painterType:Director.self)
// To:
    try igis.run(painterType:ShellDirector.self)
```    

9. Change references to owner:
9A. Change any references to owner as a Layer to 'layer'
9B. Change any references to owner as a Scene to 'scene'
9C. Change any references to owner as a Director to 'director'

As an example, in a RenderableEntity:
```swift
// Change from:
   if let owner = owner {
       owner.moveZ(of:self, to:.front)
   }
// To:
   layer.moveZ(of:self, to:.front)
```

10. Change onMouse* parameter from localLocation to globalLocation
```swift
// Change from:
func onMouseDrag(localLocation:Point, movement:Point)
// To:
func onMouseDrag(globalLocation:Point, movement:Point)
    // If the localLocation is needed:
    local(fromGlobal:globalLocation)
```
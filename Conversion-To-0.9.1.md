# Conversion To 0.9.1
This document describes the steps necessary to convert projects with prior versions of Scenes to version 0.9.1.
Be sure to read through the Scenes documentation [README](README.md) before proceeding.


## Naming conventions
* We'll assume that your existing project is called: "OldProjectName"
* We'll assume that your new project name is called "NewProjectName"
* We'll further assume that these projects share a common parent directory.

## Start by cloning a new project of the current ScenesShell
```bash
   git clone https://github.com/TheCoderMerlin/ScenesShell NewProjectName
```

## Protect the SceneShell source files in NewProjectName
```bash
    cd NewProjectName/Sources/ScenesShell
    rename 's/swift/swift.org/' *.swift
```

## Copy the source files from OldProjectName to NewProjectName
```bash
    cp -r ../../../OldProjectName/Sources/ScenesShellD/*.swift .
```

## Edit your Director file

### Change the name of your Director class to ShellDirector
    The class should inherit from Director rather than DirectorBase.
```swift
// Change from:
class Director : DirectorBase

// To:
class ShellDirector : Director 
```

### Remove the functions:
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

### Update preSetup() parameters
If you use the preSetup() method, update the signature to include canvasSize:
```swift
// Change from:
override func preSetup(canvas:Canvas)

// To:
override func preSetup(canvasSize:Size, canvas:Canvas)
```

If you used a guard or other conditional to check to ensure that canvasSize was not nil,
you may safely remove that code and use the new parameter directly.

## Edit your Layer file(s)
### Update preSetup() parameters
If you use the preSetup() method, update the signature to include canvasSize:
```swift
// Change from:
override func preSetup(canvas:Canvas)

// To:
override func preSetup(canvasSize:Size, canvas:Canvas)
```

If you used a guard or other conditional to check to ensure that canvasSize was not nil,
you may safely remove that code and use the new parameter directly.


## Edit your RenderableEntity file(s)
### Update setup() parameters
If you use the setup() method, update the signature to include canvasSize:
```swift
// Change from:
override func setup(canvas:Canvas)

// To:
override func setup(canvasSize:Size, canvas:Canvas)
```

If you used a guard or other conditional to check to ensure that canvasSize was not nil,
you may safely remove that code and use the new parameter directly.

### Remove override from init():
```swift
// Change from:
override init()

// To:
init()
```

### Add a super.init() with a name inside your init() constructor:
```swift
super.init(name:"Sky") 
```

### The class should inherit from RenderableEntity rather than RenderableEntityBase.
```swift
// Change from:
class Player : RenderableEntityBase

// To:
class Player : RenderableEntity
```

## Update your event handling.  Note that only Scene, Layer, and RenderableEntity may accept events
### Remove the "override" modifier for each handler
```swift
// Change from:
override func onKeyDown(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool)

// To:
func onKeyDown(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool)
```

### Declare conformance to the relevant protocol:
```swift
// Change from:
class InteractionLayer : Layer

// To:
class InteractionLayer : Layer, KeyDownHandler 
```

### Register your handler in setup:
```swift
override func setup(canvasSize:Size, canvas:Canvas) {
    dispatcher.registerEntityMouseDownHandler(handler:self)
    dispatcher.registerEntityMouseDragHandler(handler:self)
}
```
### Unregister your handler in teardown:
```swift
override func teardown() {
    dispatcher.unregisterEntityMouseDragHandler(handler:self)
    dispatcher.unregisterEntityMouseDownHandler(handler:self)
}
```

## Remove wantsMouseEvents():
```swift
 override func wantsMouseEvents() -> MouseEventTypeSet 
```
Simply delete the entire method; it is no longer necessary.

## Update the name of your director in Main
```swift
// Change from:
    try igis.run(painterType:Director.self)
// To:
    try igis.run(painterType:ShellDirector.self)
```    

## Change references to owner:
* Change any references to owner as a Layer to 'layer'
* Change any references to owner as a Scene to 'scene'
* Change any references to owner as a Director to 'director'

As an example, in a RenderableEntity:
```swift
// Change from:
   if let owner = owner {
       owner.moveZ(of:self, to:.front)
   }
// To:
   layer.moveZ(of:self, to:.front)
```

## Change onMouse* parameter from localLocation to globalLocation
```swift
// Change from:
func onMouseDrag(localLocation:Point, movement:Point)
// To:
func onMouseDrag(globalLocation:Point, movement:Point)
    // If the localLocation is needed:
    local(fromGlobal:globalLocation)
```

# Scenes
_Scenes_ provides a Swift object library with support for **Scene**s, **Layer**s, and **RenderableEntity**s along with an event **Dispatcher**.  _Scenes_ runs on top of IGIS.
 
## Usage

### Library
In order to use the library, use the project _ScenesShell_ as a starting point.

### Background
_Scenes_ provides a framework for quickly and easily building complex, interactive graphic applications using Igis.

#### Class Hierarchy Overview
A subclassed **Director** is responsible for transitioning from one **Scene** to another.  Each **Scene** is constructed of one or more **Layer**s.  For example, a single **Scene** may be constructed of a background **Layer**, an interaction **Layer**, and a foreground **Layer**.  **Layer**s are themselves constructed of one or more **RenderableEntity**s.  These objects are responsible for providing the rendering and (most of) the interaction for a **Layer**.

It is generally helpful to provide unique and meaninful names to these objects for easier debugging.

<img src="https://i.imgur.com/rBNo6Bk.jpg" height="400"/>

#### Event Overview
_Scenes_ provides a multitude of events to which objects can respond.  Objects that are interested in a particular event declare their conformance to the relevant protocol and then register to receive the desired event.  It's important that each such object unregister no later than their _teardown_() method.  The **Dispatcher** is responsible for maintaining registrations and raising events.

<img src="https://i.imgur.com/cUWo4hx.jpg" height="500"/>

### Director
The first action which a **Director** must take is to enqueue _at least_ one **Scene**.
```swift
/*
 This class is primarily responsible for transitioning between Scenes.
 At a minimum, it must enqueue the first Scene.
*/
class ShellDirector : Director {
    required init() {
        super.init()
        enqueueScene(scene:MainScene())
    }
}
```
The **Scene** will continue executing until the _transitionToNextScene_() method is invoked. At that point, the currently executing **Scene** will terminate and the **Director** will continue with the next enqueued **Scene**, if any.  If no such **Scene** has been enqueued, the session will terminate.  Consequently, the general means of transitioning from one **Scene** to another involves first enqueuing the next **Scene** via _enqueueScene_() followed by invoking _transitionToNextScene_().

The **Director** is also responsible for specifying the frame rate.  For most projects, 30fps is ideal.  Results will be suboptimal is the frame rate is too slow or too fast.  Some experimentation may be required for your particular application.

```swift
    override func framesPerSecond() -> Int {
        return 30
    }
```

### Scene
The **Scene** is responsbile for providing the required **Layer**s for the application.  Each **Layer** is inserted into the **Scene** using the _insert_() method.  **Layer**s (and **RenderableEntity**s) are ordered and rendering will occur in that specific order.  This enables graphic objects to consistently appear above or below other objects.  It also enables _Scenes_ to perform hit-testing to find the top-most object which intercepts a mouse event.  While a **Scene** doesn't _require_ more than one **Layer**, non-trivial **Scene**s will generally use at least three **Layer**s.  The background tends to be non-interactive and back-most, the middle tends to be interactive, and the front-most is often used for displaying data.  Other common **Layer**s involve control panels or multiple backgrounds for parallax.

```swift
/*
   This class is responsible for implementing a single Scene.
   Scenes projects require at least one Scene but may have many.
   A Scene is comprised of one or more Layers.
   Layers are generally added in the constructor.
 */
class MainScene : Scene {

    let backgroundLayer = MainBackgroundLayer()    // subclassed Layer
    let interactionLayer = MainInteractionLayer()  // subclassed Layer
    let foregroundLayer = MainForegroundLayer()    // subclassed Layer
    
    init() {
        super.init(name:"Main")
        insert(layer:backgroundLayer, at:.back)
        insert(layer:interactionLayer, at:.front)
        insert(layer:foregroundLayer, at:.front)
    }
}
```

### Layer
The **Layer** is responsbile for providing subclassed **RenderableEntity** objects.  **Layer**s are rendered from back to front, based on their current location as determined by the **Scene**.  While the **Layer** may handle any high-level events for entities, in the general case the **Layer** will simply insert the required **RenderableEntity**s into the **Layer**.  For example:

```swift
class MainBackgroundLayer : Layer {

    let background = Background() // subclassed RenderableEntity
    
    init() {
        super.init(name:"MainBackground")
        insert(entity:background, at:.back)
    }
    
}
```

**Layer**s support alpha and transforms.  The following methods may be invoked:
```swift
    // This function should only be invoked during init(), setup(), or calculate()
    public func setTransforms(transforms:[Transform]?) 

    // This function should only be invoked during init(), setup(), or calculate()
    public func setAlpha(alpha:Alpha?) 
```

### RenderableEntity
The **RenderableEntity** provides the majority of rendering and interactive functionality by overriding
the required methods and working with the **Dispatcher** to register events of interest.

In addition to the initializer, the *setup*() method may be used to setup any required parameters that require
the *Canvas*.  It's also useful for registering handlers with the dispatcher.  If so used, the _teardown_ method is available to unregister the handlers.

```swift
    // setup() is invoked exactly once,
    // either when the owning layer is first set up or,
    // if the layer has already been setup,
    // prior to the next calculate event
    // This is the appropriate location to register event handlers
    override func setup(canvasSize:Size, canvas:Canvas)

    // teardown() is invoked exactly once
    // when the scene is torndown prior to a
    // transition
    // This is the appropriate location to unregister event handlers
    override func teardown() 
```

For each render cycle, the *calculate*() method is invoked to allow objects to perform any calculations
required prior to rendering, then the *render*() method is invoked to perform the actual rendering.
Objects are calculated and rendered in back-to-front order as specified by the *Layer*.

```swift
    // calculate() is invoked prior to each render event
    override func calculate(canvasSize:Size)
    
    // render() is invoked during each render cycle
    override func render(canvas:Canvas) 
```

In order to support the EntityMouse* events, the following methods are available:
```swift
    // Must be over-ridden to return the boundingRect of the entity, in global coordinates
    override func boundingRect() -> Rect 
    
    // Must be over-ridden to return true iff the location generates a hit
    override func hitTest(globalLocation:Point) -> Bool

    // This function is invoked to determine whether or not an entity is transparent
    // to entity mouse events
    // If true, the entity will not intercept such events
    override func isMouseTransparent() -> Bool
```

**RenderableEntity**s support alpha and transforms.  The following methods may be invoked:
```swift
    // This function should only be invoked during init(), setup(), or calculate()
    public func setTransforms(transforms:[Transform]?)

    // To convert an arbitrary point (for example, globalLocation) to its actual location
    // using either specific or current transforms:
    public func applyTransforms(toPoint:Point, transforms:[Transform]? = nil) -> Point

    // To convert a series of arbitrary points to their actual location
    // using either specific or current transforms:
    public func applyTransforms(toPoints:[Point], transforms:[Transform]? = nil) -> [Point]

    // This function should only be invoked during init(), setup(), or calculate()
    public func setAlpha(alpha:Alpha?)
```

An overview of the order of method calls throughout the class hierarchy is as follows:

<img src="https://i.imgur.com/geg9BfH.jpg" height="700"/>

### Interactivity
Interactions occur through the use of events.  When an event occurs, the _dispatcher_ informs all registered objects of the event.  In order to receive an event objects must:
1. _Declare conformance_ with the desired protocol
1. _Implement_ the required functionality to conform to the protocol
1. _Register_ with the _dispatcher_ for each desired event (most often in the _setup_() method)
1. _Unregister_ with the _dispatcher_ when events are no longer desired (most often in the _teardown_() method)

The following table lists the available events for each object type:
Protocol                 | Event              | Scenes             | Layers             | Renderable Entity  | 
------------------------ | ------------------ | ------------------ | ------------------ | -----------------  |
KeyDownHandler           | onKeyDown          | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
KeyUpHandler             | onKeyUp            | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
MouseDownHandler         | onMouseDown        | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | 
MouseUpHandler           | onMouseUp          | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | 
MouseMoveHandler         | onMouseMove        | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | 
EntityMouseDownHandler   | onEntityMouseDown  | :x:                | :x:                | :heavy_check_mark: |
EntityMouseUpHandler     | onEntityMouseUp    | :x:                | :x:                | :heavy_check_mark: |
EntityMouseClickHandler  | onEntityMouseClick | :x:                | :x:                | :heavy_check_mark: |
EntityMouseDragHandler   | onEntityMouseDrag  | :x:                | :x:                | :heavy_check_mark: |
CanvasResizeHandler      | onCanvasResize     | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | 
WindowResizeHandler      | onWindowResize     | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | 

Protocol signatures:
```swift
// Key Presses
func onKeyDown(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool)
func onKeyUp(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool)

// General Mouse Events
func onMouseDown(globalLocation:Point)
func onMouseUp(globalLocation:Point)
func onMouseMove(globalLocation:Point, movement:Point)

// Entity Mouse Events (relies on hit-testing)
func onEntityMouseDown(globalLocation:Point)
func onEntityMouseUp(globalLocation:Point)
func onEntityMouseClick(globalLocation:Point)
func onEntityMouseDrag(globalLocation:Point, movement:Point)

// Re-sizing Events
func onCanvasResize(size:Size)
func onWindowResize(size:Size)
```

### Convenience Properties
In order to conveniently access other objects in the _Scenes_ hierarchy, the following convenience properties are defined:
Property   | Director           | Scenes             | Layers             | Renderable Entity  |
---------- | ------------------ | ------------------ | ------------------ | ------------------ |
dispatcher | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |  
director   | :x:                | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
scene      | :x:                | :x:                | :heavy_check_mark: | :heavy_check_mark: |
layer      | :x:                | :x:                | :x:                | :heavy_check_mark: | 

### Coordinates
All mouse events specify coordinates using the global coordinate system.  Translation between global and entity-local coordinate systems (based upon the topLeft of the entity's bounding box) using the following methods:
```swift
  public func local(fromGlobal:Point) -> Point 
  public func global(fromLocal:Point) -> Point
```

### ZOrder
ZOrder is used to indicate where in a *Scene* a *Layer* should be placed, and where in a *Layer* a **RenderableEntity** should be placed.  The _insert_() method is used to insert an object, and the _moveZ_() method is used to move an object.
```swift
// For a Scene:
    public func insert(layer:Layer, at zLocation:ZOrder<Layer>) {
        backToFrontList.insert(object:layer, at:zLocation)
    }

    public func moveZ(of layer:Layer, to zLocation:ZOrder<Layer>) {
        backToFrontList.moveZ(of:layer, to:zLocation)
    }

// For a Layer:
    // This function should only be invoked during init(), setup(), or calculate()
    public func insert(entity:RenderableEntity, at zLocation:ZOrder<RenderableEntity>) {
        backToFrontList.insert(object:entity, at:zLocation)
    }
    
    // This function should only be invoked during init(), setup(), or calculate()
    public func moveZ(of entity:RenderableEntity, to zLocation:ZOrder<RenderableEntity>) {
        backToFrontList.moveZ(of:entity, to:zLocation)
    }

```
Available ZOrders:
```swift
public enum ZOrder<T> {
    case back                   // Place (or move) the object at the back-most position
    case backward		// Place (or move) the object backward from its current position
    case behind(object:T)       // Place (or move) the object behind the specified object
    case inFrontOf(object:T)    // Place (or move) the object in front of the specified object
    case forward                // Place (or move) the object foreward from its current position
    case front	                // Place (or move) the object to the front-most position
}
```

### Rendering
For more information about rendering methods, see the documentation for [Igis](https://github.com/TheCoderMerlin/Igis).

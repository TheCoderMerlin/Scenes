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

#### Event Overview
_Scenes_ provides a multitude of events to which objects can respond.  Objects that are interested in a particular event declare their conformance to the relevant protocol and then register to receive the desired event.  It's important that each such object unregister no later than their teardown() method.  The **Dispatcher** is responsible for maintaining registrations and raising events.

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
The **Scene** will continue executing until the *transitionToNextScene()* method is invoked. At that point, the currently executing **Scene** will terminate and the **Director** will continue with the next enqueued **Scene**, if any.  If no such **Scene** has been enqueued, the session will terminate.  Consequently, the general means of transitioning from one **Scene** to another involves first enqueuing the next **Scene** via *enqueueScene()* followed by invoking *transitionToNextScene()*.

The **Director** is also responsible for specifying the frame rate.  For most projects, 30fps is ideal.  Results will be suboptimal is the frame rate is too slow or too fast.  Some experimentation may be required for your particular application.

```swift
    override func framesPerSecond() -> Int {
        return 30
    }
```

### Scene
The **Scene** is responsbile for providing the required **Layer**s for the application.  Each **Layer** is inserted into the **Scene** using the _insert()_ method.  **Layer**s (and **RenderableEntity**s) are ordered and rendering will occur in that specific order.  This enables graphic objects to consistently appear above or below other objects.  It also enables _Scenes_ to perform hit-testing to find the top-most object which intercepts a mouse event.  While a **Scene** doesn't _require_ more than one **Layer**, non-trivial **Scene**s will generally use at least three **Layer**s.  The background tends to be non-interactive and back-most, the middle tends to be interactive, and the front-most is often used for displaying data.  Other common **Layer**s involve control panels or multiple backgrounds for parallax.

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
The **Layer** is responsbile for providing subclassed **RenderableEntity** objects.  **Layer**s are rendered from back to front, based on their current location as determined by the **Scene**.  While the **Layer** may handle any high-level events for entities, in the general case the **Layer** will simply insert the required **RenerableEntity**s into the **Layer**.  For example:

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
the *Canvas*.

```swift
   // setup() is invoked exactly once,
   // either when the owning layer is first set up or,
   // if the layer has already been setup,
   // prior to the next calculate event
   override func setup(canvasSize:Size, canvas:Canvas) 

```

Then, for each render cycle, the *calculate*() method is invoked to allow objects to perform any calculations
required prior to rendering, then the *render*() method is invoked to perform the actual rendering.
Objects are calculated and rendered in back-to-front order as specified by the *Layer*.

```swift
  // calculate() is invoked prior to each render event
  override func calculate(canvasSize:Size)

  // render() is invoked during each render cycle
  override func render(canvas:Canvas) 
	    
```

**RenderableEntity**s support alpha and transforms.  The following methods may be invoked:
```swift
    // This function should only be invoked during init(), setup(), or calculate()
    public func setTransforms(transforms:[Transform]?) 


    // This function should only be invoked during init(), setup(), or calculate()
    public func setAlpha(alpha:Alpha?) 

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

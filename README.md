# Scenes

Scenes provides a Swift object library with support for renderable entities, layers, and scenes.  Scenes runs on top of
IGIS.

## Usage

### Library
Before use, build Igis and Scenes and set the LD_LIBRARY_PATH environment variable to include the library's
location.  In order to use the library, use the project ScenesShellD as a starting point.

### Background

Scenes provides a framework for quickly and easily building scenes using Igis.

A **Director**, based upon the **DirectorBase** class, informs Scenes as to the next **Scene** to be loaded.

Each **Scene** is constructed of one or more **Layer**s.  For example, a single *Scene* may be constructed of a
background *Layer*, a middle-ground *Layer*, and a foreground *Layer*.

Each **Layer** is constructed of one or more **RenderableEntityBase** objects.  These objects are responsible for
providing the rendering and interaction for the *Layer*.

### Director

The **Director** is responsible for providing the next **Scene** to be rendered.  The director accomplishes this task
with the *nextScene()* method.

```swift

    // This function should be overridden to provide the next scene object to be rendered.
    // It is invoked whenever a browser first connects and after shouldSceneTerminate() returns true.
    open func nextScene() -> Scene? {
        return nil
    }
```

Each project requires at least one *Scene*.  The *Scene* will continue executing until the *shouldSceneTerminate()*
function returns true.  At that point, the currently executing *Scene* will terminate and the *Director* will
invoke the *nextScene()* method to load the next available *Scene*, if any.

```swift
  // This function should be overridden for multi-scene presentations.
  // It is invoked after a scene completes a rendering cycle.
  open func shouldSceneTerminate() -> Bool {
      return false
  }
```

### Scene

The **Scene** is responsbile for providing the required *Layer*s for rendering and handling any high-level events
for the *Layer*s.  However, in the general case, the *Scene* will simply insert the required *Layer*s into the
Scene.  For example:

```swift
class FirstScene : Scene {
    let backgroundLayer : Layer
    let foregroundLayer : Layer

    override init() {
        let backgroundColor = Color(.purple)
	let textColor = Color(.white)
        backgroundLayer = BackgroundLayer(backgroundColor:backgroundColor, textColor:textColor)
        foregroundLayer = ForegroundLayer()
	
        super.init()

        insert(layer:backgroundLayer, at:.front)
	insert(layer:foregroundLayer, at:.front)
    }
}
```

If interactivity via the mouse is desired, the following method must be overridden:

```swift
   // This function is invoked when mouse actions occur
   // Unless the function is overridden to return the desired mouseEvents, this scene will not process mouse events
   open func wantsMouseEvents() -> MouseEventTypeSet 

```

Note that the same method, *wantsMouseEvents*() also must be overridden at the level of *both* the layer and entity.

If interactivity with the *Scene* is desired, the following methods may be overriden.
In general, however, most mouse interaction usually occurs within the
RenderableEntityBase.

```swift
    // This function is invoked immediately prior to any corresponding entity events
    // The correct wantsMouseEvents mask must be provided or the method is ignored
    open func onMouseDown(globalLocation:Point) {
    }

    // This function is invoked immediately prior to any corresponding entity events
    // The correct wantsMouseEvents mask must be provided or the method is ignored
    open func onMouseUp(globalLocation:Point) {
    }

    // This function is invoked immediately prior to any corresponding entity events
    // The correct wantsMouseEvents mask must be provided or the method is ignored
    open func onMouseMove(globalLocation:Point, movement:Point) {
    }
```

Additional methods available include:

```swift
    // This function is invoked immediately prior to setting up layers
    open func preSetup(canvas:Canvas)

    // This function is invoked immediately after setting up layers
    open func postSetup(canvas:Canvas)

    // This function is invoked immediately prior to calculating layers
    open func preCalculate(canvas:Canvas)

    // This function is invoked immediately after calculating layers
    open func postCalculate(canvas:Canvas) 

    // This function is invoked immediately prior to rendering layers
    open func preRender(canvas:Canvas) 

    // This function is invoked immediately after rendering layers
    open func postRender(canvas:Canvas)

```

### Layer

The **Layer** is responsbile for providing the required *RenderableEntityBase* objects grouped into their
respective layer.  *Layer*s are rendered from back to front, based on their current location as determined by
the *Scene*.  The *Layer* may handle any high-level events for for entities, but in the general case the *Layer*
will simply insert the required *RenerableEntityBase*s into the *Layer*.  For example:

```swift
class ForegroundLayer : Layer {
    let white : Box
    let yellow : Box

    override init() {
        white = Box(name: "White", color:Color(.white), rect:Rect(topLeft:Point(x:100, y:100), size:Size(width:100, height:100)))
        yellow = Box(name: "Yellow", color:Color(.yellow), rect:Rect(topLeft:Point(x:300, y:100), size:Size(width:100, height:100)))

        super.init()

        insert(entity:white, at:.front)
        insert(entity:yellow, at:.front)
    }
}
```

Layers support alpha and transforms.  The following methods may be invoked:
```swift
    // This function should only be invoked during init(), setup(), or calculate()
    public func setTransforms(transforms:[Transform]?) 


    // This function should only be invoked during init(), setup(), or calculate()
    public func setAlpha(alpha:Alpha?) 

```


If interactivity via the mouse is desired, the following method must be overridden:

```swift
    override func wantsMouseEvents() -> MouseEventTypeSet 

```

If interactivity with the *Layer* is desired, the following methods may be overriden.
In general, however, most mouse interaction usually occurs within the
RenderableEntityBase.

```swift
    // This function is invoked immediately prior to any corresponding entity events
    // The correct wantsMouseEvents mask must be provided or the method is ignored
    open func onMouseDown(globalLocation:Point) {
    }

    // This function is invoked immediately prior to any corresponding entity events
    // The correct wantsMouseEvents mask must be provided or the method is ignored
    open func onMouseUp(globalLocation:Point) {
    }

    // This function is invoked immediately prior to any corresponding entity events
    // The correct wantsMouseEvents mask must be provided or the method is ignored
    open func onMouseMove(globalLocation:Point, movement:Point) {
    }
```

Additional methods available include:

```swift
    // This function is invoked immediately prior to setting up layers
    open func preSetup(canvas:Canvas) 

    // This function is invoked immediately after setting up layers
    open func postSetup(canvas:Canvas) 

    // This function is invoked immediately prior to calculating layers
    open func preCalculate(canvas:Canvas) 

    // This function is invoked immediately after calculating layers
    open func postCalculate(canvas:Canvas)

    // This function is invoked immediately prior to rendering layers
    open func preRender(canvas:Canvas) 

    // This function is invoked immediately after rendering layers
    open func postRender(canvas:Canvas)
	    
```


### RenderableEntityBase

The **RenderableEntityBase** provides the majority of rendering and interactive functionality by overriding
the required methods.

In addition to the initializer, the *setup*() method may be used to setup any required parameters that require
the *Canvas*.

```swift
   // setup() is invoked exactly once,
   // either when the owning layer is first set up or,
   // if the layer has already been setup,
   // prior to the next calculate event
   open func setup(canvas:Canvas) 

```

Then, for each render cycle, the *calculate*() method is invoked to allow objects to perform any calculations
required prior to rendering, then the *render*() method is invoked to perform the actual rendering.
Objects are calculated and rendered in back-to-front order as specified by the *Layer*.

```swift
  // calculate() is invoked prior to each render event
  open func calculate(canvasSize:Size)

  // render() is invoked during each render cycle
  open func render(canvas:Canvas) 
	    
```

In order to provide correct interaction, two functions must be overridden to provide the dimensions of the
entity and indicate whether or not an object is "hit" at a particlar point:

```swift
    // Must be over-ridden to return the boundingRect of the entity, in global coordinates
    open func boundingRect() -> Rect 

    // Must be over-ridden to return true iff the location generates a hit
    open func hitTest(globalLocation:Point) -> Bool 
```

RenderableEntityBases support alpha and transforms.  The following methods may be invoked:
```swift
    // This function should only be invoked during init(), setup(), or calculate()
    public func setTransforms(transforms:[Transform]?) 


    // This function should only be invoked during init(), setup(), or calculate()
    public func setAlpha(alpha:Alpha?) 

```

If interaction with the mouse is desired, the below functions may be overridden.

```swift
   open func wantsMouseEvents() -> MouseEventTypeSet 

   open func onMouseDown(localLocation:Point)

   open func onMouseUp(localLocation:Point) 

   open func onMouseClick(localLocation:Point) 

   open func onMouseMove(globalLocation:Point, movement:Point) 

   open func onMouseDrag(localLocation:Point, movement:Point) 
	 
```

### MouseEventType

```swift
public enum MouseEventType {
    case downUp
    case click

    case move
    case drag
}
```

### ZOrder

ZOrder is used to indicate where in a *Scene* a *Layer* should be placed, and where in a *Layer* a
*RenderableEntityBase* should be placed.

```swift
public enum ZOrder<T> {
    case back
    case backward
    case behind(object:T)
    case inFrontOf(object:T)
    case forward
    case front
}
```
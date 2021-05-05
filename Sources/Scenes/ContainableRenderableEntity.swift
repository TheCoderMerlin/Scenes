/*
Scenes provides a Swift object library with support for renderable entities,
layers, and scenes.  Scenes runs on top of IGIS.
Copyright (C) 2020-2021 Tango Golf Digital, LLC
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import Igis

/// A `ContainableRenderableEntity` is used for subclassing entities which may be
/// contained in a `RenderableEntityContainer`.
/// Descendant classes must:
/// 1. Position the entity at *topLeft*
/// 2. Always use the *mostRecentSize* to determine its actual size
/// 3. The entity must provide hints to its container by calculating
///    its own size and setting *currentCalculatedSize* accordingly
/// 4. If the entity finds the *currentCalculatedSize* is nil, it must
///    recalcualte its size in *calculate()*
/// 5. Containers will resize and reposition their contained entities and
///    maintaining the *currentCalculatedSize* as the minimum size
open class ContainableRenderableEntity : RenderableEntity {
    /// The owning container, if any.
    /// This is set when this entity is inserted into a container.
    public internal(set) weak var owningContainer : RenderableEntityContainer?

    /// Creates a new `ContainableRenderableEntity` from the given paramenters:
    /// - Parameters:
    ///   - name: The unique name of the renderable entity. While it's
    ///           very useful for debugging purposes to provide a
    ///           meaningful name, it's not required.
    ///   - topLeft: The topLeft corner point for the entity.
    ///   - fixedSize: The size of this entity. If nil, the size will be
    ///           calculated.
    public init(name:String?=nil,
                topLeft:Point=Point.zero, fixedSize:Size?) {
        self.owningContainer = nil
        self.topLeft = topLeft
        self._currentCalculatedSize = fixedSize
        self.fixedSize = fixedSize
        self.previousCalculatedSize = nil

        super.init(name:name)
    }

    // *****************************************************************
    // Functions for internal use
    // *****************************************************************

    // sets the *currentCalculatedSize*.
    internal func setCurrentCalculatedSize() {
        currentCalculatedSize = calculateSize()
    }
   
    // ****************************************************************
    // API FOLLOWS
    // ****************************************************************

    /// The topLeft point of the entity
    /// When set, this entity must reposition accordingly.
    public var topLeft : Point {
        didSet {
            if oldValue != topLeft {
                topLeftChanged()
            }
        }
    }

    /// The externally specified size of the entity, overriding 
    /// the *currentCalculatedSize*.
    public var externalSize : Size? {
        didSet {
            if oldValue != externalSize {
                sizeChanged()
            }
        }
    }

    /// Used for the *currentCaclulcatedSize* if specified.
    /// If specifed, the *currentCalculatedSize* cannot be changed.
    public let fixedSize : Size?

    /// The previously calculated size, set to the *currentCalculatedSize* whenever
    /// that value is about to change to a non-nil value.
    /// This is important for stand-alone `ContainableRenderableEntity`s because
    /// they never have an *externalSize* so they'd temporarily lose their size
    /// during a recalculation. 
    public private(set) var previousCalculatedSize : Size?

    // stores *currentCalculatedSize* internally.
    private var _currentCalculatedSize : Size?
    /// Descendant classes must set this value to nil when it is necessary to
    /// recalculate the entity's size.
    /// They will then be asked to recalculate their size
    /// in the *calculatedRect()* method.
    public var currentCalculatedSize : Size? {
        get {
            return _currentCalculatedSize
        }
        set {
            // Only if fixedSize is nil do we allow changes
            guard fixedSize == nil else {
                return
            }

            // Preserve the current value (but don't overwrite the previous value with nil)
            if _currentCalculatedSize != nil {
                previousCalculatedSize = _currentCalculatedSize
            }

            // if the newValue is different, set to currentCalculated size and notify
            // owning container
            if newValue != _currentCalculatedSize {
                _currentCalculatedSize = newValue
                owningContainer?.currentCalculatedSize = nil

                // if external size is nil, notify entity that size has changed
                if externalSize == nil {
                     sizeChanged()
                }
            }
        }
    }

    /// The most recently available calculated size
    public var mostRecentCalculatedSize : Size? {
        return currentCalculatedSize ?? previousCalculatedSize
    }

    /// The most recently available size and the size that the
    /// entity MUST use.
    public var mostRecentSize : Size? {
        return externalSize ?? mostRecentCalculatedSize
    }

    /// The rect that contains this entity.
    /// The entity MUST use this rect for rendering.
    public var currentRect : Rect? {
        if let size = mostRecentSize {
            return Rect(topLeft:topLeft, size:size)
        } else {
            return nil
        }
    }

    /// Returns an array of all ancestors of this `ContainableRenderableEntity`.
    /// This includes this containers parent, as well as its grandparent,
    /// great grandparent, etc.
    public var ancestors : [RenderableEntityContainer] {
        var ancestors = [RenderableEntityContainer]()
        if let parent = owningContainer {
            ancestors.append(parent)
            ancestors.append(contentsOf:parent.ancestors)
        }

        return ancestors
    }

    // ****************************************************************
    // API FOLLOWS
    // These functions should be over-ridden by descendant classes
    // ****************************************************************

    /// Calculates a new size based unpon the contents of this entity.
    /// This will be automatically invoked and should NOT be directly
    /// called.
    open func calculateSize() -> Size? {
        return nil
    }

    /// Handles size recalculation if necessary.
    /// If overriden, invoke `super.calculate(canvasSize:canvasSize)`
    /// before adding custom logic to recalculate size if necessary.
    open override func calculate(canvasSize:Size) {
        // If we don't have a size, we calculate it here.
        if currentCalculatedSize == nil {
            setCurrentCalculatedSize()
        }
    }
        
    /// Invoked to inform an entity that its size has changed.
    /// Descendant classes should only note this change and take action
    /// later in *calculate()*.
    /// The potential change in size may be due to a new, external size or a new
    /// calculated size, either of which MAY result in an actual change in rendered
    /// size.
    open func sizeChanged() {
    }

    /// Invoked to inform an entity that its *topLeft* has changed.
    /// Descendant classes should only note this change and take action
    /// later in *calculate()*.
    open func topLeftChanged() {
    }
}

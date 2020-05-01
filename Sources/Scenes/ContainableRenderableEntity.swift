/*
Scenes provides a Swift object library with support for renderable entities,
layers, and scenes.  Scenes runs on top of IGIS.
Copyright (C) 2020 Tango Golf Digital, LLC
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
    /// The owning container, if any
    /// This is set when this entity is inserted into a container
    public internal(set) weak var owningContainer : RenderableEntityContainer? 

    // ********************************************************************************
    // API FOLLOWS
    // These functions should be over-ridden by descendant classes
    // ********************************************************************************

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
   

    // ********************************************************************************
    // API FOLLOWS
    // ********************************************************************************

    /// The topLeft point of the entity
    /// When set, this entity must reposition accordingly.
    public var topLeft : Point {
        didSet {
            topLeftChanged()
        }
    }

    /// The externally specified size of the entity, overriding 
    /// the *currentCalculatedSize*.
    public var externalSize : Size? {
        didSet {
            sizeChanged()
        }
    }

    /// The **internally** calculated size of the entity.
    /// nil if the size is not currently available.
    /// Descendant classes must set this value to nil when it is necessary to
    /// recalculate the entity's size.
    /// The descendant class should observe that *currentCalculatedSize* is nil
    /// in its *calculate()* method, and perform the required operations
    /// to calculate and set the new size.
    private var _currentCalculatedSize : Size?
    public var currentCalculatedSize : Size? {
        get {
            return _currentCalculatedSize
        }
        set {
            // Only if the fixedSize is not nil do we allow changes
            if fixedSize == nil {
                /// Preserve the current value (but don't overwrite the previous value with nil)
                if _currentCalculatedSize != nil {
                    previousCalculatedSize = _currentCalculatedSize
                }

                /// Set the newValue
                _currentCalculatedSize = newValue
                
                /// Notify our owning container
                if let owningContainer = owningContainer {
                    owningContainer.childDidSetCurrentCalculatedSize(child:self, newSize:newValue)
                }
            } 
            sizeChanged()
        }
    }

    /// The previously calculated size, set to the *currentCalculatedSize* whenever
    /// that value is about to change to a non-nil value
    /// This is important for stand-alone `ContainableRenderableEntity`s because
    /// they never have an *externalSize* so they'd temporarily lose their size
    /// during a recalculation. 
    public private(set) var previousCalculatedSize : Size?

    /// The most recently available calculated size
    public var mostRecentCalculatedSize : Size? {
        return currentCalculatedSize ?? previousCalculatedSize
    }

    /// The most recently available size and the size that the
    /// entity MUST use.
    public var mostRecentSize : Size? {
        return externalSize ?? mostRecentCalculatedSize
    }

    /// Used for the *currentCaclulcatedSize* if specified
    /// If specifed, the *currentCalculatedSize* cannot be changed
    public let fixedSize : Size?

    public init(name:String?=nil,
                topLeft:Point=Point.zero, fixedSize:Size?) {
        self.owningContainer = nil
        self.topLeft = topLeft
        self._currentCalculatedSize = fixedSize
        self.fixedSize = fixedSize
        self.previousCalculatedSize = nil

        super.init(name:name)
    }
 


}

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

/// A `RenderableEntityContainer` is used for containing zero or more
/// `ContainableRenderableEntity`s.  Because the container itself is
/// a `ContainableRenderableEntity`, building a hierarchy of such
/// containers is possible.
open class RenderableEntityContainer : ContainableRenderableEntity {
    public private(set) var children : [ContainableRenderableEntity]

    public override init(name:String?=nil,
                         topLeft:Point=Point.zero, fixedSize:Size?) {
        children = [ContainableRenderableEntity]()
        super.init(name:name, 
                   topLeft:topLeft, fixedSize:fixedSize)
    }

    // ********************************************************************************
    // Functions for internal use
    // ********************************************************************************
    
    /// Children invoke this method when they change their *currentCalculatedSize*.
    /// This method should never be invoked outside of that context.
    internal func childDidSetCurrentCalculatedSize(child:ContainableRenderableEntity, newSize:Size?) {
        // Determine if we need to recalculate our own size
        // If the child set a non-nil newSize, examine the other children
        // If all children have sizes, then we should *recalculateSize()*
        if newSize != nil {
            let childCalculatedSizeReady = children.filter { $0.currentCalculatedSize != nil }
            let shouldRecalculateSize = children.count == childCalculatedSizeReady.count
            if shouldRecalculateSize {
                currentCalculatedSize = nil
                recalculateSize()
            }
        }
    }

    // ********************************************************************************
    // API FOLLOWS
    // ********************************************************************************

    /// Inserts the specified `ContainableRenderableEntity` into this container AND
    /// into the specified `Layer` immediately above this container.
    /// The entity's owningContainer is set to this container.
    /// The entity is repositioned relative to this container
    public func insert(owningLayer:Layer, entity:ContainableRenderableEntity) {
        precondition(entity.owningContainer == nil,
                     "While attempting to insert entity into container, the entity \(entity.name) was already inserted into \(entity.owningContainer!.name)")
        entity.owningContainer = self
        children.append(entity)
        owningLayer.insert(entity:entity, at:.inFrontOf(object:self))
        entity.topLeft += topLeft
    }

    /// Provides or sets the childRect for all children 
    /// In order to get, all children must have a *currentCalculatedSize*, otherwise nil is returned.
    /// In order to set, the count of childRects must exactly match the count of children,
    /// The childRects are applied in order.
    /// NB: A get reads the *currentCaclulcatedSize*, a set writes the *externalSize*
    public var childRects : [Rect]? {
        get {
            let unreadyChildren = children.filter {$0.currentCalculatedSize == nil} 
            if unreadyChildren.count == 0 {
                return children.map { Rect(topLeft:$0.topLeft, size:$0.currentCalculatedSize!)}
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                precondition(newValue.count == children.count,
                             "While setting childRects for container \(name) \(newValue.count) childRects were specified but \(children.count) rects are required.")
                for (index, child) in children.enumerated() {
                    child.topLeft = newValue[index].topLeft
                    child.externalSize = newValue[index].size
                }
            }
        }
    }



    // ********************************************************************************
    // API FOLLOWS
    // These functions should be over-ridden by descendant classes
    // ********************************************************************************

    /// This method is invoked when all children have either calculated their size
    /// This container should then query the children and determine the size of itself.
    /// It may also optionally resize the children (setting their *specifiedSize*) and/or
    /// reposition them (setting their *topLeft*).
    /// In the case where this container relies on information which is not yet available,
    /// it's OK to simply set a flag and complete the calculation later in the *calculate()*
    /// method.
    open func recalculateSize() {
    }

    

}

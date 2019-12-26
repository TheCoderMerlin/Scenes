/*
Scenes provides a Swift object library with support for renderable entities,
layers, and scenes.  Scenes runs on top of IGIS.
Copyright (C) 2019 Tango Golf Digital, LLC
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
  
open class RenderableEntityBase {

    internal let wasSetup : Bool

    public init() {
        wasSetup = false
    }

    // setup() is invoked exactly once,
    // either when the owning layer is first set up or,
    // if the layer has already been setup,
    // prior to the next render event
    open func setup(canvas:Canvas) {
    }
    
    // calculate() is invoked prior to each render event
    open func calculate(canvasId:Int, canvasSize:Size?) {
    }
    
    // render() is invoked during each render cycle
    open func render(canvas:Canvas) {
    }

    open func boundingRect() -> Rect {
        return Rect(topLeft:Point(x:0, y:0), size:Size(width:0, height:0))
    }
    
    open func hitTest(location:Point) -> Bool  {
        return false
    }

    open func onMouseDown(location:Point) {
    }
    
    open func onMouseUp(location:Point) {
    }
    
    open func onClick(location:Point) {
    }

    open func onMouseEnter(location:Point) {
    }
    
    open func onMouseLeave(location:Point) {
    }
      
}

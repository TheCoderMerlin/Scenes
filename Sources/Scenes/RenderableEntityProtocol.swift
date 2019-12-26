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
  
protocol RenderableEntityProtocol : AnyObject {

    // setup() is invoked exactly once,
    // either when the owning layer is first set up or,
    // if the layer has already been setup,
    // prior to the next render event
    func setup(canvas:Canvas)

    // calculate() is invoked prior to each render event
    func calculate(canvasId:Int, canvasSize:Size?)

    // render() is invoked during each render cycle
    func render(canvas:Canvas)

    func boundingRect() -> Rect
    func hitTest(location:Point) -> Bool 

    func onMouseDown(location:Point)
    func onMouseUp(location:Point)
    func onClick(location:Point)

    func onMouseEnter(location:Point)
    func onMouseLeave(location:Point)
      
}

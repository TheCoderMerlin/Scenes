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

/// A type conforming to `CanvasResizeHandler` is capable of receiving
/// canvas resize events through the *onCanvasResize* method.
///
/// Before receiving events, it must be registered with the dispatcher
/// via the *registerCanvasResizeHandler* method.
/// Similarly, it should be unregistered before deinitialization
/// via the *unregisterCanvasResizeHandler* method available through
/// the dispatcher.
public protocol CanvasResizeHandler : EventHandler {
    func onCanvasResize(size:Size)
}

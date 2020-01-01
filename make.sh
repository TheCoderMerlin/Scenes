#!/bin/bash
swift build -c debug -Xswiftc -I -Xswiftc $IGIS_LIBRARY_DEBUG_PATH -Xswiftc -L -Xswiftc $IGIS_LIBRARY_DEBUG_PATH -Xswiftc -lIgis
swift build -c release -Xswiftc -I -Xswiftc $IGIS_LIBRARY_RELEASE_PATH -Xswiftc -L -Xswiftc $IGIS_LIBRARY_RELEASE_PATH -Xswiftc -lIgis

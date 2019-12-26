#!/bin/bash
if [[ -z "$LD_LIBRARY_PATH" ]]; then
    echo "Must provide LD_LIBRARY_PATH in environment" 1>&2
    exit 1
fi
if [[ -z "$IGIS_LIBRARY_PATH" ]]; then
    echo "Must provide IGIS_LIBRARY_PATH in environment" 1>&2
    exit 1
fi
echo "IGIS_LIBRARY_PATH at $IGIS_LIBRARY_PATH"
echo "LD_LIBRARY_PATH at $LD_LIBRARY_PATH"
swift build -Xswiftc -I -Xswiftc $IGIS_LIBRARY_PATH -Xswiftc -L -Xswiftc $IGIS_LIBRARY_PATH -Xswiftc -lIgis

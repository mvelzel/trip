import React, { useEffect, useMemo, useReducer, useRef } from "react";
import {
  MapContainer,
  TileLayer,
  useMapEvent,
  Marker,
  Rectangle,
  useMap,
} from "react-leaflet";

function mapReducer(state, action) {
  switch (action.type) {
    case "set-bounds":
      return { ...state, bounds: action.bounds };
  }
}

export default function MapEditor({ bounds, className, pushEvent }) {
  const [mapState, dispatch] = useReducer(mapReducer, { bounds: bounds || [] });

  useEffect(
    () => pushEvent && pushEvent("set-bounds", { bounds: mapState.bounds }),
    [mapState]
  );

  return (
    <MapContainer
      center={[52.1326, 5.2913]}
      zoom={7}
      doubleClickZoom={false}
      className={className}
    >
      <TileLayer
        attribution='&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      />
      <SetBoundZoom bounds={bounds} />
      <SetBoundCorner
        setBounds={(latlng) => {
          let bounds = mapState.bounds;
          if (bounds.length == 0) {
            bounds = [latlng];
          } else if (bounds.length == 1) {
            const size0 = bounds[0][0] + bounds[0][1];
            const size1 = latlng[0] + latlng[1];
            if (size1 > size0) {
              bounds[1] = latlng;
            } else {
              bounds[1] = bounds[0];
              bounds[0] = latlng;
            }
          }
          dispatch({ type: "set-bounds", bounds });
        }}
      />
      {mapState.bounds.map((m, i) => (
        <DraggableMarker
          key={`marker-${i}`}
          position={m}
          setPosition={(pos) => {
            let bounds = mapState.bounds;
            bounds[i] = pos;
            dispatch({ type: "set-bounds", bounds });
          }}
        />
      ))}
      {mapState.bounds.length > 1 ? (
        <Rectangle key={mapState.bounds} bounds={mapState.bounds} />
      ) : (
        <span />
      )}
    </MapContainer>
  );
}

function SetBoundCorner({ setBounds }) {
  useMapEvent("dblclick", (e) => {
    setBounds([e.latlng.lat, e.latlng.lng]);
  });

  return <span />;
}

function SetBoundZoom({ bounds }) {
  const map = useMap();

  useEffect(() => {
    if (bounds.length == 2) map.fitBounds(bounds);
  }, [bounds]);

  return <span />;
}

function DraggableMarker({ position, setPosition }) {
  const markerRef = useRef(null);

  const eventHandlers = useMemo(
    () => ({
      dragend() {
        const latlng = markerRef.current.getLatLng();
        setPosition([latlng.lat, latlng.lng]);
      },
    }),
    []
  );

  return (
    <Marker
      draggable
      position={position}
      eventHandlers={eventHandlers}
      ref={markerRef}
    />
  );
}

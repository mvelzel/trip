import React from "react";
import {
  MapContainer,
  TileLayer,
  useMapEvent,
  Marker,
  Rectangle,
  useMap,
} from "react-leaflet";
import { SetBoundZoom } from "./MapEditor";
import { ExtraMarkers } from "leaflet-extra-markers";

export default function MapOverview({ className, bounds, postLocations }) {
  console.log(postLocations)
  return (
    <MapContainer
      center={[52.1326, 5.2913]}
      zoom={7}
      zoomSnap={0.1}
      doubleClickZoom={false}
      className={className}
    >
      <TileLayer
        attribution='&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      />
      <SetBoundZoom bounds={bounds} />
      <Rectangle bounds={bounds} color="white" />
      {postLocations && postLocations.map((loc) => (
        <Marker
          key={`postloc-${loc.id}`}
          icon={generateNumberMarker(loc.post.number)}
          position={[loc.latitude, loc.longitude]}
        ></Marker>
      ))}
    </MapContainer>
  );
}

function generateNumberMarker(number) {
  return ExtraMarkers.icon({
    icon: "fa-number",
    number: number,
    markerColor: "blue",
    svg: true,
  });
}

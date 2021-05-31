import React, {useState} from "react";
import { MapContainer, TileLayer, useMapEvent } from "react-leaflet";

function AddMarkerOnClick({markers, setMarkers}) {
  const map = useMapEvent('dblclick', (e) => {
    console.log("click");
  });

  return null;
}

export default function MapEditor({ className }) {
  const [markers, setMarkers] = useState(null);

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
      <AddMarkerOnClick />
    </MapContainer>
  );
}

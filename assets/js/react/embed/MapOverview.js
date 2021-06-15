import React, { useEffect, useMemo, useState } from "react";
import {
  MapContainer,
  TileLayer,
  useMapEvent,
  Marker,
  Rectangle,
  useMap,
  Popup,
  useMapEvents,
  Tooltip,
} from "react-leaflet";
import { SetBoundZoom } from "./MapEditor";
import { ExtraMarkers } from "leaflet-extra-markers";

export default function MapOverview({
  className,
  bounds,
  postLocations,
  postStates,
  pushEvent,
  selectingPost,
}) {
  return (
    <MapContainer
      center={[52.1326, 5.2913]}
      zoom={7}
      zoomSnap={0.1}
      doubleClickZoom={false}
      className={className}
    >
      <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
      <SetBoundZoom bounds={bounds} />
      <Rectangle bounds={bounds} color="white" />
      {postLocations &&
        postLocations.map((loc) => (
          <PostMarker
            postLocation={loc}
            key={`postloc-${loc.id}`}
            postState={postStates[loc.id]}
            pushEvent={pushEvent}
            selectingPost={selectingPost}
          />
        ))}
      <MapOverlay selectingPost={selectingPost} pushEvent={pushEvent} />
    </MapContainer>
  );
}

function MapOverlay({ selectingPost, pushEvent }) {
  const map = useMap();
  const [bounds, setBounds] = useState(map.getBounds());

  const updateBounds = () => setBounds(map.getBounds());

  useMapEvents({
    moveend: updateBounds,
    load: updateBounds,
    zoomend: updateBounds,
  });

  const rectClick = useMemo(
    () => ({
      mouseup() {
        pushEvent("set-selecting", { selecting: "false" });
      },
    }),
    [pushEvent]
  );

  return (
    <>
      {selectingPost ? (
        <>
          <Rectangle
            bounds={bounds}
            color="black"
            pathOptions={{ stroke: false }}
            eventHandlers={rectClick}
          />
          <p className="absolute z-[5000] font-sans font-bold text-t-red text-red-3d text-3xl text-center w-full">
            Claim een post
          </p>
        </>
      ) : (
        <span />
      )}
    </>
  );
}

function PostMarker({ postLocation, postState, pushEvent, selectingPost }) {
  let color = "#0455BF";
  if (postLocation.post.result_type == "points") {
    if (postState.final_groups.length > 1) {
      color = "#F23054";
    } else if (postState.final_groups[0]) {
      color = "yellow";
    }
  } else if (postState.final_groups[0]) {
    color = "#F23054";
  }

  const markerClick = useMemo(
    () => ({
      mouseup() {
        if (selectingPost && postState.can_claim) {
          pushEvent("claim-post", { post_location: postLocation.id });
        }
      },
    }),
    [selectingPost, postState]
  );

  return (
    <Marker
      icon={generateNumberMarker(postLocation.post.number, color)}
      position={[postLocation.latitude, postLocation.longitude]}
      opacity={selectingPost && !postState.can_claim ? 0.5 : 1}
      eventHandlers={markerClick}
    >
      <Popup>
        <div className="flex space-y-2 py-2 flex-col">
          <p className="!m-0 font-sans text-base font-normal">
            {postLocation.post.name}
          </p>
          <p className="!m-0 font-sans text-xs font-normal">
            Huidige ronde:
            <br />
            {postState.current_groups[0]
              ? `Claim door ${stateGroupsNumber(postState.current_groups)}`
              : `Ongeclaimd`}
          </p>
          <p className="!m-0 font-sans text-xs font-normal">
            Volgende ronde:
            <br />
            {postState.next_groups[0]
              ? `Claim door ${stateGroupsNumber(postState.next_groups)}`
              : `Ongeclaimd`}
          </p>
          <p className="font-sans text-sm font-medium">
            Over 2 rondes:
            <br />
            {postState.final_groups[0]
              ? `Claim door ${stateGroupsNumber(postState.final_groups)}`
              : `Ongeclaimd`}
          </p>
          <a
            onMouseDown={() =>
              pushEvent("show-post", { post: postLocation.post.id })
            }
            className="font-sans text-sm font-medium !text-t-red text-red-3d cursor-pointer"
          >
            Post bekijken
          </a>
        </div>
      </Popup>
    </Marker>
  );
}

function stateGroupsNumber(stateGroups) {
  if (stateGroups.length > 1) {
    return `Groepen ${stateGroups[0].number}&${stateGroups[1].number}`;
  } else {
    return `Groep ${stateGroups[0].number}`;
  }
}

function generateNumberMarker(number, color) {
  return ExtraMarkers.icon({
    icon: "fa-number",
    number: number,
    markerColor: color,
    svg: true,
  });
}

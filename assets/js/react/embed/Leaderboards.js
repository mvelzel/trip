import React, { useEffect, useState } from "react";
import SwipeableViews from "react-swipeable-views";
import Dropdown from "./Dropdown";

const pages = ["total", "location", "post"];

export default function Leaderboards({
  defaultLocation,
  defaultPost,
  selectedLocation,
  selectedPost,
  groups,
  posts,
  locationGroups,
  locations,
  postResults,
  pushEvent,
  page,
}) {
  const [pageIndex, setPageIndex] = useState(0);

  useEffect(() => {
    if (page == "total") setPageIndex(0);
    else if (page == "location") setPageIndex(1);
    else if (page == "post") setPageIndex(2);
  }, [page]);

  return (
    <SwipeableViews
      index={pageIndex}
      className="h-full"
      containerStyle={{ height: "100%" }}
      onChangeIndex={(index) => {
        pushEvent("change-page", { page: pages[index] })
      }}
    >
      <div className="bg-t-darkerBlue h-full space-y-4">
        <h2
          className="w-full text-center uppercase text-white text-2xl
          font-bold font-sans tracking-wider"
        >
          Totale ranglijst
        </h2>
        <div className="flex flex-col space-y-6">
          {groups &&
            groups.map((group, i) => (
              <LeaderboardEntry
                key={`totalrank-${i}`}
                rank={i + 1}
                title={group.name}
                score={`${group.score}km`}
              />
            ))}
        </div>
      </div>
      <div className="bg-t-darkerBlue h-full space-y-4">
        <h2
          className="w-full text-center uppercase text-white text-2xl
          font-bold font-sans tracking-wider"
        >
          Locatie ranglijst
        </h2>
        {locations && defaultLocation && (
          <div className="flex flex-col px-10">
            <Dropdown
              selected={
                selectedLocation && selectedLocation != ""
                  ? selectedLocation
                  : defaultLocation
              }
              values={locations.map((l) => [l.name, l.id])}
              placeholder="Selecteer een locatie"
              phx_event="location-selected"
              pushEvent={pushEvent}
            />
          </div>
        )}
        <div className="flex flex-col space-y-6">
          {locationGroups &&
            locationGroups.map((group, i) => (
              <LeaderboardEntry
                key={`locrank-${i}`}
                rank={i + 1}
                title={group.name}
                score={`${group.score}km`}
              />
            ))}
        </div>
      </div>
      <div className="bg-t-darkerBlue h-full space-y-4">
        <h2
          className="w-full text-center uppercase text-white text-2xl
          font-bold font-sans tracking-wider"
        >
          Post ranglijst
        </h2>
        {posts && defaultPost && (
          <div className="flex flex-col px-10">
            <Dropdown
              selected={
                selectedPost && selectedPost != "" ? selectedPost : defaultPost
              }
              values={posts.map((p) => [p.name, p.id])}
              placeholder="Selecteer een post"
              phx_event="post-selected"
              pushEvent={pushEvent}
            />
          </div>
        )}
        <div className="flex flex-col space-y-6">
          {postResults &&
            postResults.map((res, i) => (
              <LeaderboardEntry
                key={`postrank-${i}`}
                rank={i + 1}
                title={res.group.name}
                score={(() => {
                  if (res.post.score_type == "points") {
                    return `${res.score}km`;
                  } else {
                    const minutes = Math.floor(res.score / 60);
                    const seconds = res.score - minutes * 60;
                    return `${
                      minutes > 0 ? minutes.toString() + "m" : ""
                    } ${seconds}s`;
                  }
                })()}
              />
            ))}
        </div>
      </div>
    </SwipeableViews>
  );
}

function LeaderboardEntry({ rank, title, score }) {
  return (
    <div className="flex flex-row items-center space-x-6 bg-t-red lead-bot py-4 px-8 w-full">
      <h3 className="font-sans text-t-green font-bold text-xl tracking-wider text-green-3d">
        #{rank}
      </h3>
      <p className="font-sans font-medium text-white text-lg">{title}</p>
      <p className="justify-self-end flex-1 text-right text-lg font-medium text-t-green">
        {score}
      </p>
    </div>
  );
}

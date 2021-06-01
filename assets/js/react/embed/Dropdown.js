import React, { useEffect, useRef, useState } from "react";

export default function Dropdown({ selected, values, pushEvent, placeholder }) {
  const [expanded, setExpanded] = useState(false);
  const [useTop, setUseTop] = useState(false);

  const valuesRef = useRef(null);

  function determineUseTop() {
    const bound = valuesRef.current.getBoundingClientRect()
    let clearance = 28 + 16;
    if (useTop)
      clearance += bound.height + 16 + 12;
    console.log(bound);
    if (!expanded) {
      const newUseTop = bound.bottom + clearance >= window.innerHeight;
      setUseTop(newUseTop);
    }
    else {
      setUseTop(useTop);
    }
  }

  useEffect(() => {
    determineUseTop();
  }, [valuesRef])

  window.addEventListener('resize', () => {
    determineUseTop();
  });

  return (
    <div className="relative w-full">
      <div
        className={`flex flex-row items-center justify-between t-input w-full`}
        onClick={() => {
          determineUseTop();
          setExpanded(!expanded);
        }}
      >
        <p>{placeholder}</p>
        <i className="fas fa-chevron-down"></i>
      </div>
      <div
        className={`flex absolute flex-col w-full top-auto dropdown-transition
        ${expanded ? ("mt-1 opacity-1 z-[8000]") :
            ("opacity-0 z-[-10] " + (useTop ? "mt-6" : "-mt-6"))}
        ${useTop ? ("transform translate-y-[calc(-100%-3rem)]") : ""}
        rounded-lg bg-white t-input divide-y divide-tr-red border`}
        ref={valuesRef}
      >
        {values &&
          values.map(([val, id]) => (
            <div key={id} className="py-2 hover:font-medium">
              {val}
            </div>
          ))}
      </div>
    </div>
  );
}

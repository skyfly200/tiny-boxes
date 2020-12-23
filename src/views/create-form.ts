export const sections: Array<object> = [
  {
    title: "Shapes",
    rand: true,
    options: [
      {
        label: "Count",
        key: "shapes",
        type: "slider",
        range: {
          min: 1,
          max: 30,
        },
      },
      {
        label: "Hatching Mod",
        key: "hatching",
        type: "slider",
        range: {
          min: 0,
          max: 30,
        },
      },
      {
        label: "Width",
        key: "width",
        type: "range-slider",
        range: {
          min: 1,
          max: 500,
        },
      },
      {
        label: "Height",
        key: "height",
        type: "range-slider",
        range: {
          min: 1,
          max: 500,
        },
      },
    ],
  },
  {
    title: "Placement",
    rand: true,
    options: [
      {
        label: "X Spread",
        key: "x",
        type: "slider",
        range: {
          min: 1,
          max: 600,
        },
      },
      {
        label: "Y Spread",
        key: "y",
        type: "slider",
        range: {
          min: 1,
          max: 600,
        },
      },
      {
        label: "Columns",
        key: "xSeg",
        type: "slider",
        rand: {
          min: 1,
          max: 8,
        },
        range: {
          min: 1,
          max: 8,
        },
      },
      {
        label: "Rows",
        key: "ySeg",
        type: "slider",
        rand: {
          min: 1,
          max: 8,
        },
        range: {
          min: 1,
          max: 8,
        },
      },
    ],
  },{
    title: "Color",
    rand: true,
    options: [
      {
        label: "Scheme",
        key: "scheme",
        type: "slider",
        range: {
          min: 0,
          max: 9,
        },
      },
      {
        label: "Root Hue",
        key: "hue",
        type: "slider",
        range: {
          min: 0,
          max: 360,
        },
      },
      {
        label: "Saturation",
        key: "saturation",
        type: "slider",
        range: {
          min: 0,
          max: 100,
        },
      },
      {
        label: "Lightness",
        key: "lightness",
        type: "range-slider",
        range: {
          min: 0,
          max: 100,
        },
      },
      {
        label: "Shades",
        key: "shades",
        type: "slider",
        range: {
          min: 0,
          max: 8,
        },
      },
    ],
  },
  {
    title: "Mirror",
    rand: true,
    options: [
      {
        label: "A",
        key: "mirrorA",
        type: "switch",
        hide: "mirrorAdv",
        randWeight: 0.5,
      },
      {
        label: "B",
        key: "mirrorB",
        type: "switch",
        hide: "mirrorAdv",
        randWeight: 0.5,
      },
      {
        label: "C",
        key: "mirrorC",
        type: "switch",
        hide: "mirrorAdv",
        randWeight: 0.5,
      },
      {
        label: "Advanced",
        key: "mirrorAdv",
        type: "switch",
        rand: false,
      },
      {
        label: "Position 1",
        key: "mirrorPos1",
        type: "slider",
        show: "mirrorAdv",
        step: 25,
        range: {
          min: 0,
          max: 2400,
        },
      },
      {
        label: "Position 2",
        key: "mirrorPos2",
        type: "slider",
        show: "mirrorAdv",
        step: 25,
        range: {
          min: 0,
          max: 2400,
        },
      },
      {
        label: "Position 3",
        key: "mirrorPos3",
        type: "slider",
        show: "mirrorAdv",
        step: 25,
        range: {
          min: 0,
          max: 2400,
        },
      },
      {
        label: "Scale %",
        key: "scale",
        type: "slider",
        show: "mirrorAdv",
        rand: false,
        step: 100,
        range: {
          min: 100,
          max: 800,
        },
      },
    ],
  },
];

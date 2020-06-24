export const sections: Array<object> = [
  {
    title: "Counts",
    rand: true,
    options: [
      {
        label: "Colors",
        key: "colors",
        type: "slider",
        rand: {
          min: 1,
          max: 50,
        },
        range: {
          min: 1,
          max: 100,
        },
      },
      {
        label: "Shapes",
        key: "shapes",
        type: "slider",
        rand: {
          min: 1,
          max: 55,
        },
        range: {
          min: 1,
          max: 70,
        },
      },
    ],
  },
  {
    title: "Size",
    rand: true,
    options: [
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
    title: "Position",
    rand: true,
    options: [
      {
        label: "X Spread",
        key: "x",
        type: "slider",
        range: {
          min: 1,
          max: 500,
        },
      },
      {
        label: "Y Spread",
        key: "y",
        type: "slider",
        range: {
          min: 1,
          max: 500,
        },
      },
      {
        label: "Columns",
        key: "xSeg",
        type: "slider",
        rand: {
          min: 1,
          max: 20,
        },
        range: {
          min: 1,
          max: 50,
        },
      },
      {
        label: "Rows",
        key: "ySeg",
        type: "slider",
        rand: {
          min: 1,
          max: 20,
        },
        range: {
          min: 1,
          max: 50,
        },
      },
    ],
  },
  {
    title: "Mirror",
    options: [
      {
        label: "Level 1",
        key: "mirror1",
        type: "switch",
      },
      {
        label: "Position 1",
        key: "mirrorPos1",
        type: "slider",
        hide: "mirror1",
        step: 25,
        range: {
          min: 0,
          max: 3400,
        },
      },
      {
        label: "Level 2",
        key: "mirror2",
        type: "switch",
      },
      {
        label: "Position 2",
        key: "mirrorPos2",
        type: "slider",
        hide: "mirror2",
        step: 25,
        range: {
          min: 0,
          max: 3400,
        },
      },
      {
        label: "Level 3",
        key: "mirror3",
        type: "switch",
      },
      {
        label: "Position 3",
        key: "mirrorPos3",
        type: "slider",
        hide: "mirror3",
        step: 25,
        range: {
          min: 0,
          max: 3400,
        },
      },
    ],
  },
  {
    title: "Advanced",
    options: [
      {
        label: "RNG Seed",
        key: "seed",
        type: "slider",
        range: {
          min: 0,
          max: 2 ** 53,
        },
      },
      {
        label: "Hatching Mod",
        key: "hatchMod",
        type: "slider",
        range: {
          min: 0,
          max: 1000,
        },
      },
      {
        label: "Scale %",
        key: "scale",
        type: "slider",
        step: 10,
        range: {
          min: 10,
          max: 1000,
        },
      },
    ],
  },
];

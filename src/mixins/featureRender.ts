import {
  preserve,
  nucleusPortion,
  featureSizes,
} from "./renderSettings";
import { contrastingColor } from "./colorUtils";

const tao = 2 * Math.PI;

function randomRadialPlotter(
  radius: number,
  nucleus: boolean,
  buffer: number,
  segments: number,
  rand: any,
) {
    const angle = rand(segments);
    // mask inner portion for nucleus
    const inner = nucleus ? nucleusPortion * radius + buffer / radius : buffer / radius;
    // randomly place in band from inner to preserve portion
    const range = nucleus ? preserve - nucleusPortion : preserve - buffer / radius;
    const exp = 10000;
    const scale =
      inner + radius * range * (1 - (rand(exp) * rand(exp)) / (exp ** 2));
    const p = (tao * angle) / segments;
    return [Math.sin(p), -Math.cos(p)].map(c => Math.round(c * scale));
};

function drawMitochndria(
  draw: any,
  feature: any,
  center: Array<number>,
  size: number,
  type: string,
  nucleus: boolean,
  rand: any
) {
  const mitoPattern = (baseColor: string) =>
    draw.pattern(10, 10, (add: any) => {
      add.rect(10, 10).fill(baseColor);
      add
        .rect(10, 2)
        .move(5, 5)
        .fill(contrastingColor(baseColor));
      add
        .rect(7, 2)
        .move(0, 0)
        .fill(contrastingColor(baseColor));
    });
  const radius = size / 2;
  const [w, h] = featureSizes[type];
  for (let i = 0; i < feature.count; i++) {
    const location = randomRadialPlotter(radius, nucleus, h, 90, rand); // radius, buffer, segments, random
    draw
      .ellipse(w, h)
      .fill(mitoPattern(feature.color))
      .move(center[0] + 20 + location[0], center[1] + 20 + location[1])
      .transform({ rotate: rand(359) })
      .stroke("none");
  }
};


function drawGolgi(
  draw: any,
  feature: any,
  center: Array<number>,
  size: number,
  type: string,
  nucleus: boolean,
  rand: any
) {
  for (let i = 0; i < feature.count; i++) {
    draw
      .ellipse(30, 8)
      .fill(feature.color)
      .move(center[0] + 70 + (i % 6) * 5, center[1] + 50 + (i % 3) * 8)
      .transform({ rotate: 165 })
      .stroke("none");
  }
};

function drawEndo(
  draw: any,
  feature: any,
  center: Array<number>,
  size: number,
  type: string,
  nucleus: boolean,
  rand: any
) {
  // endoplasmic reticulum
  const layers = [
    { path: "10 70", dashes: "5,3,9" },
    { path: "0 80", dashes: "3,9,7" },
    { path: "-5 85", dashes: "2,7,5" }
  ];
  const endoStroke = {
    width: 3,
    color: feature.color, // find endo entry with largest count and use that color
    linecap: "round",
    linejoin: "round",
    dasharray: ""
  };
  const erScale = (1 / 55) * size;
  for (let i = 0; i < feature.count >> 2; i++) {
    endoStroke.dasharray = layers[i].dashes;
    const angle = 35 + 5 * i;
    const layerPath = `M ${layers[i].path} A ${angle} ${angle} -45 0 1 70 50`;
    const ER = draw.path(layerPath);
    ER.move(center[0] - erScale * (i + 1), center[1] - erScale * (i + 1))
      .stroke(endoStroke)
      .fill("none");
  }
};

function drawNucleus(
  draw: any,
  size: number,
  center: Array<number>,
  colors: {
    nucleusColor: string,
    wallColor: string,
  },
) {
  draw
    .ellipse(size, size)
    .fill(colors.nucleusColor)
    .move(...center)
    .stroke({
      width: 2,
      color: colors.wallColor,
      linecap: "round",
      linejoin: "round"
    });
};

function defaultRenderer(
  draw: any,
  feature: any,
  center: Array<number>,
  size: number,
  type: string,
  nucleus: boolean,
  rand: any
) {
  const radius = size / 2;
  const [w, h] = featureSizes[type];
  for (let i = 0; i < feature.count; i++) {
    const location = randomRadialPlotter(radius, nucleus, h, 90, rand); // radius, buffer, segments, random
    draw
      .ellipse(w, h)
      .fill(feature.color)
      .move(center[0] + 20 + location[0], center[1] + 20 + location[1])
      .transform({ rotate: rand(359) })
      .stroke("none");
  }
};

function defaultRendererSquare(
  draw: any,
  feature: any,
  center: Array<number>,
  size: number,
  type: string,
  nucleus: boolean,
  rand: any
) {
  const radius = size / 2;
  const [w, h] = featureSizes[type];
  for (let i = 0; i < feature.count; i++) {
    const location = randomRadialPlotter(radius, nucleus, h, 90, rand); // radius, buffer, segments, random
    draw
      .rect(w, h)
      .fill(feature.color)
      .move(center[0] + 20 + location[0], center[1] + 20 + location[1])
      .transform({ rotate: rand(359) })
      .stroke("none");
  }
};

const featureRenderers: any = {
  nucleus: drawNucleus,
  endo: drawEndo,
  golgi: drawGolgi,
  mitochondria: drawMitochndria,
  chloroplasts: defaultRenderer,
  vacuoles: defaultRenderer,
  ribosomes: defaultRenderer,
  microtubules: defaultRenderer,
  vesicles: defaultRenderer,
  lysosomes: defaultRenderer,
  lipid: defaultRenderer,
  crystals: defaultRenderer,
  magnetosomes: defaultRenderer,
  carboxysomes: defaultRenderer,
  chromatophores: defaultRenderer,
  logic: defaultRendererSquare,
  rf: defaultRenderer,
  memory: defaultRendererSquare,
  pv: defaultRendererSquare,
  balasts: defaultRenderer,
  mam: defaultRenderer,
  buses: defaultRenderer,
  bundles: defaultRenderer,
  anode: defaultRendererSquare,
  cathode: defaultRendererSquare,
  charger: defaultRendererSquare,
  fuse: defaultRendererSquare,
  separator: defaultRendererSquare,
  electrolyte: defaultRenderer,
  wire: defaultRendererSquare,
  electrons: defaultRenderer
};

export default featureRenderers;
// Cell Renderer Functions
// draw a cell tokens SVG art from its genetic information
// Authored by Skyler Fly-Wilson 2020
import { SVG, Pattern } from "@svgdotjs/svg.js";
import {
  preserve,
  nucleusPortion,
  features,
  cytoplasmOpacity,
  families,
} from "./renderSettings";
import featureRenderers from "./featureRender";
import { intToColor } from "./colorUtils";
import { svgPath } from "./polyToCurve";
import randomSeed from "random-seed";

//const randomSeed = require("random-seed");

const tao = 2 * Math.PI;

const cellRender: any = {
  methods: {
    drawCell(
      data: any,
      waveform: Array<number>,
      level: number,
      size: number,
      margin: number,
      target: string
    ) {
      // init draw with a dom taret and size
      const draw = SVG()
        .addTo(target)
        .size(size + margin * 2, size + margin * 2);

      // render cell body
      const shape = this.drawBody(draw, waveform, level, size, data, margin);

      // find cell range and center
      const [[minX, maxX], [minY, maxY]] = this.wallRange(shape);
      const dimensions = [maxX - minX, maxY - minY];
      const nucleusSize = nucleusPortion * size;
      const center = dimensions.map(
        (d: number) => (d - nucleusSize + (size - d)) / 2 + margin
      );

      // draw nucleus
      const colors = {
        nucleusColor: intToColor(data.nucleusColor),
        wallColor: intToColor(data.wallColor)
      };
      if (!data.nucleusHidden)
        featureRenderers["nucleus"](draw, nucleusSize, center, colors);

      // seed rng with wave shape
      const seed = data.wallWave;
      const rand = randomSeed.create(seed);

      // render features
      for (let i = 0; i < 8; i++) {
        const feature = {
          category: data.featureCategories[i],
          family: data.featureFamilies[i],
          count: data.featureCounts[i] as number,
          color: intToColor(data.featureColors[i])
        };
        const type = this.getFeatureType(feature.category, feature.family).key;
        // check feature is dominant if type is solo
        const thisFeature = features.filter(f => f.key === type)[0];
        const dominant = [...Array(8).keys()].reduce(
          (acc: boolean, index: number) =>
            acc &&
            (data.featureCategories[index] !== feature.category ||
              parseInt(data.featureCounts[index]) <= feature.count),
          true
        );
        if (!thisFeature.solo || dominant)
          // call feature renderer function
          featureRenderers[type](
            draw,
            feature,
            center,
            size,
            type,
            !data.nucleusHidden,
            rand
          );
      }
    },

    getFeatureType(i: number, f: number): any {
      return features[families[f].features[i]];
    },

    getFeatureFamily(i: number): any {
      return families[i];
    },

    countList(list: Array<any>) {
      // count and sort by family with most features
      return list.reduce((count: any, f: string) => {
        count[parseInt(f)] ? count[parseInt(f)]++ : (count[parseInt(f)] = 1);
        return count;
      }, {});
    },

    sortObject(counts: any) {
      return Object.keys(counts).sort((a, b) => counts[b] - counts[a]);
    },

    sortFamilies(families: Array<Array<number>>) {
      const counts = this.countList(families);
      const sorted = this.sortObject(counts).map(i => [i, counts[i]]);
      return sorted;
    },

    drawBody(
      draw: any,
      waveform: Array<number>,
      count: number,
      size: number,
      data: any,
      margin: number
    ) {
      // plot shape from wave
      const shape = this.plotShape(size, waveform, count);

      const [[minX, maxX], [minY, maxY]] = this.wallRange(shape);
      const w = maxX - minX;
      const h = maxY - minY;

      // count and sort families
      const sorted = this.sortFamilies(data.featureFamilies);

      // calculate gradient
      const gradient = draw.gradient("radial", function(add: any) {
        let a = 0;
        for (const i of sorted) {
          a += i[1];
          add.stop({
            offset: a / 9 + (data.nucleusHidden ? 0 : nucleusPortion),
            color: families[parseInt(i[0])].color,
            opacity: cytoplasmOpacity
          });
        }
      });

      // body - draw cell wall and fill
      const body = data.wallRound
        ? draw.path(svgPath(shape))
        : draw.polygon(shape);
      body
        .move(margin + (size - w) / 2, margin + (size - h) / 2)
        .fill(gradient)
        .stroke({
          width: 3,
          color: intToColor(data.wallColor),
          linecap: "round",
          linejoin: "round"
        });

      return shape;
    },

    wallRange(shape: Array<Array<number>>) {
      return shape.reduce(
        function(result: Array<Array<number>>, cords: Array<number>) {
          const [x, y] = cords;
          const [lX, lY] = result;
          return [
            [lX[0] < x ? lX[0] : x, lX[1] > x ? lX[1] : x],
            [lY[0] < y ? lY[0] : y, lY[1] > y ? lY[1] : y]
          ];
        },
        [
          [0, 0],
          [0, 0]
        ]
      );
    },

    // function parameters ( size, wave, repeat, mod )
    // returns an array of points for a polygon
    plotShape(size: number, wave: Array<number>, repeat: number) {
      const radius = size / 2;
      const segments = repeat * wave.length;
      const points = [];
      for (let i = 0; i <= segments; i++)
        points[i] = this.radialWavePlotter(
          i + ((segments / repeat) % segments),
          radius,
          wave,
          segments
        );
      return points;
    },

    radialWavePlotter(
      i: number,
      radius: number,
      wave: Array<number>,
      segments: number
    ) {
      const scale =
        radius * preserve + radius * (1 - preserve) * wave[i % wave.length];
      const x = Math.round(Math.sin((tao * i) / segments) * scale);
      const y = Math.round(Math.cos((tao * i) / segments) * scale * -1);
      return [x, y];
    },

    mergeWaves(waves: Array<Array<number>>, bitDepthMax: number) {
      const waveLengths = waves.map(w => w.length);
      const lcm = this.lcmNumbers(waveLengths); // least common multiple of the length of the wave arrays
      const compoundWave: Array<number> = [];
      for (let i = 0; i < lcm; i++) {
        compoundWave[i] = 0;
        for (const wave of waves) {
          const j = Math.floor(i / (lcm / wave.length));
          compoundWave[i] += wave[j] / (bitDepthMax - 1);
        }
      }
      return compoundWave;
    },

    lcmNumbers(inputArray: Array<number>): number {
      if (toString.call(inputArray) !== "[object Array]") return -1;
      let r1 = 0,
        r2 = 0;
      const l = inputArray.length;
      for (let i = 0; i < l; i++) {
        r1 = inputArray[i] % inputArray[i + 1];
        if (r1 === 0) {
          inputArray[i + 1] =
            (inputArray[i] * inputArray[i + 1]) / inputArray[i + 1];
        } else {
          r2 = inputArray[i + 1] % r1;
          if (r2 === 0) {
            inputArray[i + 1] = (inputArray[i] * inputArray[i + 1]) / r1;
          } else {
            inputArray[i + 1] = (inputArray[i] * inputArray[i + 1]) / r2;
          }
        }
      }
      return inputArray[l - 1];
    },
    
    intToColor: intToColor,
  }
};

export default cellRender;

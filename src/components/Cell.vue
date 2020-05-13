<template lang="pug">
  .shape(:class="[shapeID]")
</template>

<script>
import Vue from "vue";
import cellUtils from "@/mixins/cellUtils";
import cellRender from "@/mixins/cellRender";

export default Vue.extend({
  name: "Cell",
  mixins: [cellUtils, cellRender],
  props: ["id", "data"],
  computed: {
    shapeID() {
      return "shape-" + this.id;
    },
    wave() {
      const bitDepthMax = 2 ** 5;
      //return this.mergeWaves(this.features.body.waves.map(i => this.waves[i]), bitDepthMax);
      const i = this.data.wallWave % this.waves.length;
      return this.waves[i].map(
        s => s / (bitDepthMax - 1)
      );
    },
  },
  data: () => ({
    size: 300,
    margin: 10,
    waves: [
      [31, 31, 31],
      [31, 31, 31, 31],
      [31, 31, 31, 31, 31],
      [31, 31, 31, 31, 31, 31, 31],
      [31, 0, 31, 0],
      [31, 0, 0, 0, 31, 0, 0, 0],
      [31, 23, 15, 7, 3, 0, 3, 7, 15, 23],
      [0, 7, 15, 23, 31, 23, 15, 7],
      [0, 3, 7, 15, 23, 31, 0],
      [31, 22, 14, 8, 16, 7, 16, 4, 32, 8, 22, 29],
      [15, 19, 23, 27, 31, 27, 23, 19, 15, 11, 7, 3, 0, 3, 7, 11],
      [31, 31, 0, 0, 31, 31, 0, 0],
      [15, 0, 15, 31],
      [0, 31, 0, 15],
      [0, 31, 0, 15, 0, 7],
      [0, 0, 31, 0],
    ],
  }),
  async mounted() {
    this.drawCell(
      this.data,
      this.wave,
      this.level(this.data.mass),
      this.size,
      this.margin,
      "." + this.shapeID,
    );
  }
});
</script>

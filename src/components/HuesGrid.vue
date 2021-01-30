<template lang="pug">
    .hues-grid(v-if="color !== undefined && schemeH(scheme) !== undefined")
      svg(:width="(2.2*(schemeH(scheme).length)) + 'em'" height="2.2em")
        g(v-for="h,i of schemeH(scheme)")
          rect(:x="2.2*i+'em'" y="0" width="2.2em" height="2.2em"
            :style="'fill: hsl('+(parseInt(color.hue)+h)+','+color.saturation+'%,'+(color.luminosity/2)+'%)'")
</template>

<script lang="ts">
import Vue from "vue";

export default Vue.extend({
  name: "HuesGrid",
  props: ["color", "scheme"],
  
  methods: {
    schemeH(i: number) {
      const schemes = [
          [0, 30, 330], // analogous
          [0, 120, 240], // triadic
          [0, 180], // complimentary
          [0, 60, 180, 240], // tetradic
          [0, 30, 180, 330], // analogous and complimentary
          [0, 150, 210], // split complimentary
          [0, 150, 180, 210], // complimentary and analogous
          [0, 30, 60, 90], // series
          [0, 90, 180, 270], // square
          [0], // mono
          [0], // random
      ];
      return schemes[i];
    },
  }
});
</script>

<style lang="sass" scoped>
.colors-grid
  padding: 1rem
  svg g
    width: 100%
</style>
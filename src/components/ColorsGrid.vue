<template lang="pug">
    .colors-grid
      svg(:width="(2.2*(parseInt(shades))) + 'em'" :height="(2.2*(schemeH(scheme).length)) + 'em'")
        g(v-for="h,i of schemeH(scheme)")
          rect(v-for="s in parseInt(shades)" :x="2.2*(s-1)+'em'" :y="2.2*i+'em'" width="2.2em" height="2.2em"
            :style="'fill: hsl('+(parseInt(color[0])+h)+','+color[1]+'%,'+calcShade(s)+'%)'")
</template>

<script lang="ts">
import Vue from "vue";

export default Vue.extend({
  name: "ColorsGrid",
  props: ["color", "contrast", "shades", "scheme"],
  
  methods: {
    calcShade(s: number): any {
      return (this.shades == 0) ?
        parseInt(this.color[2]) :
        parseInt(this.color[2]) - (this.contrast / this.shades * (this.shades - s));
    },
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
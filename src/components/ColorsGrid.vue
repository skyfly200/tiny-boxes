<template lang="pug">
    .colors-grid
        svg(:width="(3*(parseInt(palette[5])+1)) + 'em'" :height="(3*(scheme(palette[4]).length)) + 'em'")
            g(v-for="h,i of scheme(palette[4])")
                rect(v-for="s in parseInt(palette[5])+1" :x="3*(s-1)+'em'" :y="3*i+'em'" width="3em" height="3em"
                    :style="'fill: hsl('+(parseInt(palette[0])+h)+','+palette[1]+'%,'+calcShade(s-1)+'%)'")
</template>

<script lang="ts">
import Vue from "vue";

export default Vue.extend({
  name: "ColorsGrid",
  props: ["palette"],
  
  methods: {
    calcShade(s: number): any {
      const palette = this.palette;
      if (palette[5] == 0) return parseInt(palette[3]);
      const range = palette[3] - palette[2];
      return parseInt(palette[2]) + (range / palette[5] * s);
    },
    scheme(i: number) {
      const schemes = [
            [0], // mono
            [0, 180], // complimentary
            [0, 30, 330], // analogous
            [0, 30, 60, 90], // series
            [0, 150, 210], // split complimentary
            [0, 120, 240], // triadic
            [0, 150, 180, 210], // complimentary and analogous
            [0, 30, 180, 330], // analogous and complimentary
            [0, 90, 180, 270], // square
            [0, 60, 180, 240] // tetradic
        ];
      return schemes[i];
    },
  }
});
</script>

<style lang="sass" scoped>
.colors-grid
  padding: 1rem
  border: 1px solid #ccc
  border-radius: 0.5rem
  svg g
    width: 100%
</style>
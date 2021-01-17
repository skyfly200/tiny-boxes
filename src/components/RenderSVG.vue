// add to start of doc
// <?xml version="1.0" encoding="UTF-8" ?>
// <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"
//   "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<template lang="pug">
    svg(xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
        width="100%" height="100%" viewBox="0 0 2400 2400" style="stroke-width:0;background-color:#121212")
        defs
            symbol#shapes
                rect(v-for="r in rects" :x="r.x" :y="r.y" :width="r.width" :height="r.width"
                    transform-origin="600 600" :style="toStyle(r.color)")
                    animateTransform(attributeName="transform" attributeType="XML" type="rotate"
                        dur="10s" values="0;90;90;360;360" keyTimes="0;0.2;0.4;0.9;1" calcMode="spline"
                        keySplines="0.5 0 0.75 1;0.5 0 0.75 1;0.5 0 0.75 1;0.5 0 0.75 1" repeatCount="indefinite")
        symbol#quad3
            symbol#quad2
                symbol#quad1
                    symbol#quad0
                        g
                            use(xlink:href="#shapes")
                    g
                        use(xlink:href="#quad0")
                    g(transform="scale(-1 1) translate(-600 0)")
                        use(xlink:href="#quad0")
                    g(transform="scale(1 -1) translate(0 -600)")
                        use(xlink:href="#quad0")
                    g(transform="scale(-1 -1) translate(-600 -600)")
                        use(xlink:href="#quad0")
                g
                    use(xlink:href="#quad1")
                g(transform="scale(-1 1) translate(-1200 0)")
                    use(xlink:href="#quad1")
                g(transform="scale(1 -1) translate(0 -1200)")
                    use(xlink:href="#quad1")
                g(transform="scale(-1 -1) translate(-1200 -1200)")
                    use(xlink:href="#quad1")
            g
                use(xlink:href="#quad2")
            g(transform="scale(-1 1) translate(-2400 0)")
                use(xlink:href="#quad2")
            g(transform="scale(1 -1) translate(0 -2400)")
                use(xlink:href="#quad2")
            g(transform="scale(-1 -1) translate(-2400 -2400)")
                use(xlink:href="#quad2")
        g(transform="scale(1 1)")
            use(xlink:href="#quad3")
</template>

<script lang="ts">
import Vue from "vue";

export default Vue.extend({
  name: "RenderSVG",
  methods: {
      toStyle(c: any) {
          return 'fill:hsl('+c.h+','+c.s+'%,'+c.l+'%)';
      }
  },
  data: () => ({
      rects: [
          {
              x: 447, y: 487, width: 27, height: 731,
              color: { h: 342, s: 80, l: 44 },
          },
          {
              x: 547, y: 487, width: 27, height: 731,
              color: { h: 222, s: 80, l: 44 },
          },
          {
              x: 747, y: 487, width: 27, height: 731,
              color: { h: 102, s: 80, l: 44 },
          },
          {
              x: 247, y: 487, width: 27, height: 731,
              color: { h: 222, s: 80, l: 55 },
          },
          {
              x: 247, y: 487, width: 27, height: 731,
              color: { h: 102, s: 80, l: 66 },
          },
      ],
  }),
});
</script>

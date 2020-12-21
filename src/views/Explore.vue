<template lang="pug">
  .token-explorer
    v-container(fluid)
      v-row
        v-col.heading(align="center")
          h1.title Hundreds of googols of possibilities!
          p Scroll to explore. Click to customize.
      v-data-iterator(:items="tokens" :items-per-page="parseInt(itemsPerPage)")
          template(v-slot:default="{ items, isExpanded, expand }")
            v-row
              v-col(v-for="t of items" :key="'token-col-'+t.index" align="center" xl="1" lg="2" md="3" sm="4" xs="6")
                v-card.token-permutation(@click="gotoMint(t.values)" :key="'token-card-'+t.index" tile)
                  Token(:id="t.id" :data="t.art")
</template>

<script lang="ts">
import Vue from "vue";
import { mapGetters, mapState } from "vuex";
import { sections } from "./create-form";
import Token from "@/components/Token.vue";
import { log } from 'console';

export default Vue.extend({
  name: "Explore",
  components: { Token },
  computed: {
    ...mapState({
        animationTitles: 'animationTitles',
        schemeTitles: 'schemeTitles',
    }),
    ...mapGetters(["currentAccount"]),
  },
  mounted: async function() {
    const t = this as any;
    await this.$store.dispatch("initialize");
    t.loadFormDefaults();
  },
  methods: {
    randomize: function() {
      const t = this as any;
      const randomSettings: any = {};
      for (const s of t.sections) {
        if (s.rand) {
          for (const o of s.options) {
            if (o.rand !== false && !t.values[o.hide] && t.values[o.show] !== false) {
              const range = o.rand ? o.rand : o.range;
              switch (o.type) {
                case "switch":
                  randomSettings[o.key] = Math.random() > (o.randWeight ? o.randWeight : 0.5);
                  break;
                case "range-slider":
                  randomSettings[o.key] = [range, range].map((r) => t.between(r)).sort();
                  break;
                default:
                  randomSettings[o.key] = t.between(range);
                  break;
              }
            }
          }
        }
      }
      Object.assign(t.values, randomSettings);
      return randomSettings;
    },
    gotoMint(values: any) {
      this.$router.push({ path: "/create", query: values });
    },
    loadFormDefaults: function() {
      const t = this as any;
      // set values to default
      Object.assign(t.values, t.defaults);
      t.loadTokens();
    },
    between: function(range: any) {
      return Math.floor(
        Math.random() * (range.max - range.min + 1) + range.min
      );
    },
    loadTokens: async function() {
      this.loading = true;
      for (let t=0;t<this.count;t++) {
        this.randomize();
        this.loadToken().then( result => {
          this.$set(this.tokens, t, {
            art: result,
            values: JSON.parse(JSON.stringify(this.values)),
            index: t,
          });
        });
      }
      this.loading = false;
    },
    assemblePalette: function() {
      const v = (this as any).values;
      v.lightness = v.lightness.sort((a: any,b: any) => a - b);
      return [
        v.hue,
        v.saturation,
        v.lightness[0],
        v.lightness[1],
        v.scheme,
        v.shades
      ];
    },
    assembleDials: function() {
      const t = this as any;
      const v = t.values;
      v.width = v.width.sort((a: any,b: any) => a - b);
      v.height = v.height.sort((a: any,b: any) => a - b);
      return [
        v.x,
        v.y,
        v.xSeg,
        v.ySeg,
        v.width[0],
        v.width[1],
        v.height[0],
        v.height[1],
        v.hatching,
        v.mirrorAdv ? v.mirrorPos1 : (v.mirrorA ? t.defaults.mirrorPos1 : 0),
        v.mirrorAdv ? v.mirrorPos2 : (v.mirrorB ? t.defaults.mirrorPos2 : 0),
        v.mirrorAdv ? v.mirrorPos3 : (v.mirrorC ? t.defaults.mirrorPos3 : 0),
        v.mirrorAdv ? v.scale : (!v.mirrorC ? (!v.mirrorB ? 400 : 200) : 100),
      ];
    },
    loadToken: function() {
      return new Promise((resolve, reject) => {
        const t = this as any;
        const v = {...t.values, palette: t.assemblePalette(), dials: t.assembleDials()};
        this.$store.state.contracts.tinyboxes.methods
          .tokenTest(v.seed.toString(), v.shapes, v.palette, v.dials, v.animation, v.animate)
          .call()
          .then((result: any) => {
            t.data = result;
            resolve(result);
          })
          .catch((err: any) => {
            console.log('Error Prone Inputs: ', v);
            console.error(err);
            reject(err);
          });
      })
    },
  },
  data: function() {
    return {
      loading: true,
      count: 100,
      tokens: [] as any,
      values: {} as any,
      itemsPerPage: 100,
      defaults: {
        seed: Date.now(),
        shapes: 11,
        x: 200,
        y: 200,
        xSeg: 2,
        ySeg: 2,
        width: [200, 300],
        height: [200, 300],
        hatching: 0,
        mirrorAdv: false,
        mirrorA: true,
        mirrorB: true,
        mirrorC: true,
        mirrorPos1: 600,
        mirrorPos2: 1200,
        mirrorPos3: 2400,
        scale: 100,
        hue: Date.now() % 360,
        saturation: 80,
        lightness: [30,70],
        shades: 3,
        scheme: 0,
        animate: false,
        animation: 9,
      },
      sections: sections,
    };
  },
});
</script>

<style lang="sass">
.token-graphic
  padding: 0 !important
.container
  padding-left: 0
  padding-right: 0
  .row
    margin-right: 0
    @media(max-width: 700px)
      margin: 0
</style>

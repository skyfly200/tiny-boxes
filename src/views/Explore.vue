<template lang="pug">
  .token-explorer
    v-container(fluid)
      v-row
        v-col.heading(align="center")
          .title Explore All The Boxy Variety
          p Hundreds of googols of possibilities
          p Iterating the {{ attribute }} value
          v-select(:items="attributes")
      v-data-iterator(:items="tokens" :items-per-page="parseInt(itemsPerPage)")
          template(v-slot:default="{ items, isExpanded, expand }")
            v-row(no-gutters)
              v-col(v-for="t of items" :key="'token-col-'+t.mod" align="center" xl="1" lg="2" md="3" sm="4" xs="6")
                v-card.token-permutation(:key="'token-card-'+t.mod" tile)
                  Token(:id="t.id" :data="t.art")
                  v-card-text.title {{ t.mod }}
                  v-card-actions
                    v-btn(@click="gotoMint(t.values)") Mint
</template>

<script lang="ts">
import Vue from "vue";
import { mapGetters, mapState } from "vuex";
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
    ...mapGetters(["currentAccount", "itemsPerPage"]),
  },
  mounted: async function() {
    const t = this as any;
    await this.$store.dispatch("initialize");
    t.loadFormDefaults();
  },
  methods: {
    gotoMint(values: any) {
      this.$router.push({ path: "/create", query: values });
    },
    assemblePalette: function(v: any) {
      return [
        v.hue,
        v.saturation,
        v.lightness[0],
        v.lightness[1],
        v.scheme,
        v.shades
      ];
    },
    assembleDials: function(v: any) {
      const t = this as any;
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
        const mod: any = {};
        mod[this.attribute] = t;
        Object.assign(this.values, mod);
        this.$set(this.tokens, t, {
          art: await this.loadToken(this.values),
          values: this.values,
          mod: t,
        });
      }
      this.loading = false;
    },
    loadToken: function(v: any) {
      return new Promise((resolve, reject) => {
        const t = this as any;
        const palette = t.assemblePalette(v);
        const dials = t.assembleDials(v);
        this.$store.state.contracts.tinyboxes.methods
          .tokenTest(v.seed.toString(), v.shapes, palette, dials, v.animation, v.animate)
          .call()
          .then((result: any) => {
            t.data = result;
            resolve(result);
          })
          .catch((err: any) => {
            console.log('Error With Inputs: ', v.seed.toString(), v.shapes, palette, dials, v.animation, v.animate);
            console.error(err);
            reject(err);
          });
      })
    },
  },
  data: function() {
    return {
      loading: true,
      attribute: "scheme",
      attributes: [
        "seed",
        "shapes",
        "x",
        "y",
        "hatching",
        "shades",
        "scheme",
        "animation",
      ],
      count: 10,
      tokens: [] as any,
      values: {} as any,
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

<template lang="pug">
  .token-explorer
    v-container(fluid)
      v-row
        v-col.heading(align="center")
          h1.title Hundreds of googols of possibilities!
          p Scroll to explore. Click to customize.
      v-data-iterator(:items="tokens" :items-per-page="parseInt(itemsPerPage)" hide-default-footer)
          template(v-slot:default="{ items, isExpanded, expand }")
            v-row
              v-col(v-for="(t,i) of items" align="center" xl="1" lg="2" md="3" sm="4" xs="6")
                v-card.token-permutation(@click="gotoMint(t.values)" tile)
                  Token(:id="i" :data="t.art")
          template(v-slot:footer)
            v-row
              v-col(align="center" cols="12")
                v-btn(@click="more") Load More
</template>

<script lang="ts">
import Vue from "vue";
import { mapGetters, mapState } from "vuex";
import { sections } from "./create-form";
import Token from "@/components/Token.vue";
import { log } from 'console';
import { start } from "repl";

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
    getSupply: function() {
      return this.$store.state.contracts.tinyboxes.methods.totalSupply().call();
    },
    getPrice: function() {
      return this.$store.state.contracts.tinyboxes.methods.currentPrice().call();
    },
    lookupLimit: async function() {
      (this as any).limit = await this.$store.state.contracts.tinyboxes.methods.TOKEN_LIMIT().call();
    },
    loadStatus: async function() {
      const t = this as any;
      const idLookup = t.getSupply();
      const priceLookup = t.getPrice();
      t.id = await idLookup;
      t.price = await priceLookup;
    },
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

      this.$router.push({ path: "/create", query: this.buildQuery(values) });
    },
    buildQuery(values: any) {
      const t = this as any;
      const v = values;
      // condense keys and values for shorter URL encoding
      const out: any = {
        r: v.seed,
        s: [v.shapes, v.hatching].join("-"), // shapes - count, hatching
        d: [v.width.join("~"), v.height.join("~")].join("-"), // dimensions ranges
        p: [v.spread, (v.rows * 16) + v.cols].join("-"), // positioning - spread, grid
        c: [v.hue, v.saturation, v.lightness, v.contrast].join("-"), // color - hue, saturation, lightness, contrast
      };
      return out;
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
    more: async function() {
      this.loading = true;
      const start = this.tokens.length;
      for (let t=start;t<(this.count+start);t++) {
        this.randomize();
        this.loadToken().then( result => {
          this.$set(this.tokens, t, {
            art: result,
            values: JSON.parse(JSON.stringify(this.values)),
          });
        });
      }
      this.itemsPerPage = this.itemsPerPage * 2;
      this.loading = false;
    },
    loadTokens: async function() {
      this.loading = true;
      await this.loadStatus();
      for (let t=0;t<this.count;t++) {
        this.randomize();
        this.$set(this.tokens, t, {
          art: await this.loadToken(),
          values: JSON.parse(JSON.stringify(this.values)),
        });
      }
      this.loading = false;
    },
    assemblePalette: function() {
      const v = (this as any).values;
      return [
        v.hue,
        v.saturation,
        v.lightness,
        v.contrast <= v.lightness ? v.contrast : v.lightness
      ];
    },
    assembleDials: function() {
      const t = this as any;
      const v = t.values;
      v.width = v.width.sort((a: any,b: any) => a - b);
      v.height = v.height.sort((a: any,b: any) => a - b);
      return {
        spacing: [ v.spread, (v.rows * 16) + v.cols ],
        size: [ ...v.width, ...v.height ],
      };
    },
    loadToken: function() {
      return new Promise((resolve, reject) => {
        const t = this as any;
        const v = {...t.values, ...t.assembleDials(), color: t.assemblePalette()};
        this.$store.state.contracts.tinyboxes.methods
          .tokenPreview(v.seed.toString(), v.shapes, v.hatching, v.color, v.size, v.spacing, v.traits, v.animate, t.id)
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
      id: 0,
      loading: true,
      count: 60,
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
        hue: Date.now() % 360,
        saturation: 80,
        lightness: [30,70],
        animate: false,
        traits: [0,0,8,0,5],
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

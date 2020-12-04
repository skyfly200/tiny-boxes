<template lang="pug">
  .token-explorer
    v-container(fluid)
      v-row(flex)
        .title Explore The Boxy Variety
        v-col(align="center" cols="12" md="5" offset-md="1")
          v-card(max-height="90vh").token-preview
            v-card-title.token-stats
              p Put Stats Here
            v-divider
            v-card-text.token-graphic
              v-fade-transition(mode="out-in")
                v-skeleton-loader(v-if="loading" tile type="image")
                Token(v-else :id="0" :data="data")
            v-card-actions
              v-btn(@click="") Actions!
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
    ...mapGetters(["currentAccount"]),
  },
  mounted: async function() {
    const t = this as any;
    await this.$store.dispatch("initialize");
    t.loadFormDefaults();
  },
  methods: {
    formatHash(account: string) {
      return "0x" + account.slice(2, 6) + "...." + account.slice(-4);
    },
    update: async function() {
      const t = this as any;
      this.$router.push({ path: "/explore", query: t.values })
      if (t.form.valid) return t.loadToken();
    },
    assemblePalette: function() {
      const v = (this as any).values;
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
    getPrice: function() {
      return this.$store.state.contracts.tinyboxes.methods
        .currentPrice()
        .call();
    },
    loadFormDefaults: function() {
      const t = this as any;
      // set values to default
      Object.assign(t.values, t.defaults);
      // overwrite with any url query params
      Object.assign(t.values, t.$route.query);
      t.update();
    },
    randomizeForm: function() {
      const t = this as any;
      t.randomizeAll();
      t.update()
        .catch((err: any) => {
          console.error("Invalid Box Options - Call Reverted: ", err)
          console.log("Retrying Randomize")
          t.randomizeForm()
        });
    },
    randomizeSection: function(section: number) {
      const t = this as any;
      t.randomize(section);
      t.update()
        .catch((err: any) => {
          console.error("Invalid Box Options - Call Reverted: ", err)
          console.log("Retrying Randomize")
          t.randomizeForm()
        });
    },
    randomize: function(section: number) {
      const t = this as any;
      const randomSettings: any = {};
      const s = t.sections[section];
      if (s.rand)
        for (const o of s.options) {
          if (o.rand !== false && !t.values[o.hide] && t.values[o.show] !== false) {
            const range = o.rand ? o.rand : o.range;
            switch (o.type) {
              case "switch":
                randomSettings[o.key] = Math.random() > (o.randWeight ? o.randWeight : 0.5);
                break;
              case "range-slider":
                randomSettings[o.key] = [range, range]
                  .map((r) => t.between(r))
                  .sort();
                break;
              default:
                randomSettings[o.key] = t.between(range);
                break;
            }
          }
        }
      Object.assign(t.values, randomSettings);
    },
    randomizeAll: function() {
      const t = this as any;
      const randomSettings: any = {};
      for (const s of t.sections)
        if (s.rand)
          for (const o of s.options) {
            if (o.rand !== false && !t.values[o.hide] && t.values[o.show] !== false) {
              const range = o.rand ? o.rand : o.range;
              switch (o.type) {
                case "switch":
                  randomSettings[o.key] = Math.random() > (o.randWeight ? o.randWeight : 0.5);
                  break;
                case "range-slider":
                  randomSettings[o.key] = [range, range]
                    .map((r) => t.between(r))
                    .sort();
                  break;
                default:
                  randomSettings[o.key] = t.between(range);
                  break;
              }
            }
          }
      Object.assign(t.values, randomSettings);
    },
    between: function(range: any) {
      return Math.floor(
        Math.random() * (range.max - range.min + 1) + range.min
      );
    },
    loadToken: function() {
      return new Promise((resolve, reject) => {
        const t = this as any;
        t.loading = true;
        const v = t.values;
        const palette = t.assemblePalette();
        const dials = t.assembleDials();
        console.log(v)
        this.$store.state.contracts.tinyboxes.methods
          .tokenTest(v.seed.toString(), v.shapes, palette, dials, v.animation, v.animate)
          .call()
          .then((result: any) => {
            t.data = result;
            t.loading = false;
            resolve(result);
          })
          .catch((err: any) => {
            console.log('Error Prone Inputs: ', v.seed.toString(), v.shapes, palette, dials, v.animation, v.animate);
            console.error(err);
            reject(err);
          });
      })
    },
  },
  data: function() {
    return {
      loading: true,
      data: null as object | null,
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
.v-chip__content
  span
    color: #FFF !important
.content
  margin-top: 35vh
.id
  font-size: 2rem
.token-loading
  padding-top: 40hv
.token-graphic
  padding: 0 !important
.token-preview .token
  height: 60vh
.sold-out
  margin-top: 1rem
.form-buttons, .price-tag
  display: flex
.v-expansion-panel-header .rand-btn
  flex: 0 0 auto !important
  margin-right: 10px
.theme--dark.v-input
  margin: 0 15px
  width: 100%
  input, textarea
    color: #121212
    background-color: #121212
    border: none
.v-input.switch
  width: auto
.section-title
  color: #fff
.section-content .v-expansion-panel-content__wrap
  display: flex
  flex-wrap: wrap
.dialog .v-card__text
  padding: 0
  .message
    margin: 1rem
.dialog-error .v-card__text,  .v-alert
  margin: 1rem
.container
  padding-left: 0
  padding-right: 0
  .row
    margin-right: 0
    @media(max-width: 700px)
      margin: 0
.v-dialog
  box-shadow: none !important
</style>

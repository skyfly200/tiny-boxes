<template lang="pug">
    v-form(v-model="form.valid").create-form
        .form-buttons
            v-spacer
            v-tooltip(bottom)
            template(v-slot:activator="{ on }")
                v-btn(@click.stop="reset" v-on="on" icon).share-btn
                v-icon mdi-close
            span Reset
            v-tooltip(bottom)
            template(v-slot:activator="{ on }")
                v-btn(@click="undo" v-on="on" icon).share-btn
                v-icon mdi-undo
            span Undo
            v-tooltip(bottom)
            template(v-slot:activator="{ on }")
                v-btn(@click="redo" v-on="on" icon).share-btn
                v-icon mdi-redo
            span Redo
            v-tooltip(bottom)
            template(v-slot:activator="{ on }")
                v-btn(@click.stop="randomizeSection('all')" v-on="on" icon).rand-btn
                v-icon mdi-dice-multiple
            span Randomize
            v-spacer
            v-tooltip(bottom)
            template(v-slot:activator="{ on }")
                v-btn(@click.stop="overlay = 'share'" v-on="on" icon).share-btn
                v-icon mdi-share
            span Share
        br
        v-expansion-panels(v-model="form.section" popout tile)
            v-expansion-panel.section(v-for="section,s of active" :key="section.title" ripple)
            v-expansion-panel-header(color="secondary").section-title
                span {{ section.title }}
                v-spacer
                v-tooltip(left).rand-section
                template(v-slot:activator="{ on }")
                    v-btn(v-if="section.rand" @click.stop="randomizeSection(s);form.section = s" v-on="on" icon).rand-btn
                    v-icon mdi-dice-multiple
                span Randomize
            v-expansion-panel-content.section-content
                template(v-for="option of section.options")
                template(v-if="!option.show || values[option.show] && !option.hide || (values[option.hide]) == false")
                    template(v-if="option.type === 'slider'")
                    v-slider(v-model="values[option.key]" @change="changed" thumb-label required 
                        persistent-hint :hint='option.key === "scheme" ? schemeTitles[values[option.key]] : (option.key === "animation" ? animationTitles[values[option.key]] : "")'
                        :label="option.label" :step="option.step" :min="option.range.min" :max="option.range.max")
                        template(v-slot:append)
                            v-text-field(v-model="values[option.key]" @change="changed" hide-details single-line type="number" style="width: 60px").slider-text-field
                    v-range-slider(v-else-if="option.type === 'range-slider'" v-model="values[option.key]" @change="changed" thumb-label required
                    :step="option.step" :label="option.label" :min="option.range.min" :max="option.range.max")
                        template(v-slot:prepend)
                        v-text-field(v-model="values[option.key][0]" @change="changed" hide-details single-line type="number" style="width: 60px").slider-text-field
                        template(v-slot:append)
                        v-text-field(v-model="values[option.key][1]" @change="changed" hide-details single-line type="number" style="width: 60px").slider-text-field
                    v-switch(v-else-if="option.type === 'switch'" v-model="values[option.key]" @change="changed" :label="option.label").switch
                    v-text-field(v-else v-model="values[option.key]" @change="changed" :label="option.label" required outlined type="number")
</template>

<script lang="ts">
import Vue from "vue";
import { log } from 'console';
import { mapGetters, mapState } from "vuex";
import { sections } from "../views/create-form"; // move to this dir once done swapping this comp in
import Share from "@/components/Share.vue";

export default Vue.extend({
  name: "CreateForm",
  components: { Share },
  data: function() {
    return {
      form: {
        section: 0,
        valid: true,
      },
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
      sections: sections,
    };
  },
  computed: {
    paramsSet: function() {
      return Object.keys(this.$route.query).length > 0
    },
    active: function() {
      return (this as any).sections.map((s: any) => {
        s.options.filter((o: any) => !o.hide || (this as any).values[o.hide]);
        return s;
      });
    },
    ...mapState({
        animationTitles: 'animationTitles',
        schemeTitles: 'schemeTitles',
    }),
    ...mapGetters(["currentAccount", "wrongNetwork"]),
  },
  mounted: async function() {
    const t = this as any;
    await this.$store.dispatch("initialize");
    if (!this.wrongNetwork) {
      t.loadFormDefaults();
      if (t.paramsSet) t.loadParams();
      else t.updateParams();
      t.loadToken();
      t.listenForTokens();
      t.listenForMyTokens();
    }
  },
  methods: {
    randomizeSection: function(section: number | string) {
      const t = this as any;
      t.randomize(section);
      t.loadToken()
        .then((art: any) => {
          if (art) t.updateParams();
        })
        .catch((err: any) => {
          console.error("Invalid Box Options - Call Reverted: ", err)
          console.log("Retrying Randomize...")
          t.randomizeSection(section)
        });
    },
    randomize: function(section: number | string) {
      const t = this as any;
      const randomSettings: any = {};
      for (const s of (section === "all") ? t.sections : [t.sections[section]]) {
        if (s.rand) {
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
        }
      }
      Object.assign(t.values, randomSettings);
    },
    between: function(range: any) {
      return Math.floor(
        Math.random() * (range.max - range.min + 1) + range.min
      );
    },
    formatHash(account: string) {
      return "0x" + account.slice(2, 6) + "...." + account.slice(-4);
    },
    undo() {
      const t = this as any;
      history.back()
      t.loadParams();
      t.loadToken();
    },
    redo() {
      const t = this as any;
      history.forward()
      t.loadParams();
      t.loadToken();
    },
    changed: async function() {
      const t = this as any;
      t.updateParams();
      t.loadToken();
    },
    loadStatus: async function() {
      const t = this as any;
      t.id = await this.$store.state.contracts.tinyboxes.methods.totalSupply().call();
      t.price = await t.getPrice();
    },
    lookupLimit: async function() {
      (this as any).limit = await this.$store.state.contracts.tinyboxes.methods.TOKEN_LIMIT().call();
    },
    getPrice: function() {
      return this.$store.state.contracts.tinyboxes.methods
        .currentPrice()
        .call();
    },
    reset() {
      const t = this as any;
      t.loadFormDefaults();
      t.changed();
    },
    loadFormDefaults: function() {
      const t = this as any;
      // set values to default
      Object.assign(t.values, t.defaults);
    },
    loadParams() {
      const t = this as any;
      // overwrite with any url query params
      const query = t.parseQuery(t.$route.query);
      Object.assign(t.values, query);
    },
    updateParams() {
      const t = this as any;
      if (t.$route.query === {}) this.$router.replace({ path: "/create", query: t.values });
      else this.$router.push({ path: "/create", query: t.values });
    },
    parseQuery(query: any) {
      const out: any = {};
      // check true, false, array, string, number
      for (const [i,q] of Object.entries(query)) {
        out[i] = q === "true" ? true : 
          ( q === "false" ? false : 
            ( Array.isArray(q) ? (q as any).map((v: any) => parseInt(v)) :
              ( ( i === "seed" || isNaN(parseInt(q as any)) ) ? q : parseInt(q as any) ) ) );
      }
      return out;
    },
  },
});
</script>

<style lang="sass">
.form-buttons
  display: flex
.v-expansion-panel-header .rand-btn
  flex: 0 0 auto !important
  margin-right: 10px
.theme--dark.v-input
  margin: 0 15px
  width: auto
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
.container
  padding-left: 0
  padding-right: 0
  .row
    margin-right: 0
    @media(max-width: 700px)
      margin: 0
</style>

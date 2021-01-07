<template lang="pug">
  .token-creator
    v-dialog(:value="dialog" transition="fade" :persistent="inProgress" @click:outside="overlay=''" width="500")
      Share.dialog-share(v-if="overlay === 'share'" key="share")
      v-card.dialog-verify(v-else-if="overlay === 'verify'" key="verify")
        v-card-title Submit The Transaction
        v-card-text
          .message
            h3 Mint Token {{ "#" + id }} for {{ priceInETH }} 
              v-icon mdi-ethereum
      v-card.dialog-confirm(v-else-if="overlay === 'confirm'" key="confirm")
        v-card-title Minting
        v-card-text
          .message                      
            .d-flex
              h3 Hash: {{ formatHash(minted.txHash) }}
              v-spacer
              v-tooltip(top)
                template(v-slot:activator='{ on }')
                  a(:href="'https://rinkeby.etherscan.io/tx/' + minted.txHash" v-on='on' target="new")
                    v-icon mdi-open-in-new
                span View on Etherscan
            h3 Pending
          v-progress-linear(indeterminate)
      v-card.dialog-ready(v-else-if="overlay === 'ready'" key="ready")
        v-skeleton-loader(:value="!minted.art" type="image")
          Token(:id="minted.id+'-preview'" :data="minted.art")
        v-card-title.text-center You Minted Token {{ "#" + minted.id }}
        v-card-actions
          v-btn(:to="'/token/' + minted.id" color="primary") View Token
          v-spacer
          v-btn(@click="overlay = ''; loadToken()" color="success") Mint Another
      v-card.dialog-error(v-else-if="overlay === 'error'" key="error")
        v-card-title Transaction Error
        v-card-text
          v-alert(type="error" border="left") An error occured while atempting to mint your token
        v-card-actions
          v-btn(@click="mintToken" color="success") Try Again
          v-spacer
          v-btn(@click="overlay = ''; loadToken()" color="error") Cancel
    v-container(fluid)
      v-row(flex)
        v-col(align="center" cols="12" md="5" offset-md="1")
          v-card(max-height="90vh").token-preview
            v-card-title.token-stats(align="center")
              v-skeleton-loader(v-if="id === null" type="card-heading" width="20vw")
              span(v-else) TinyBox {{ "#" + id }} Preview
            v-card-text.token-graphic
              v-fade-transition(mode="out-in")
                v-skeleton-loader(v-if="loading" tile type="image")
                Token(v-else :id="id" :data="data")
            v-card-actions
              v-skeleton-loader(v-if="price === ''" type="card-heading" width="100%")
              template(v-else)
                .price-tag
                  h2 {{ priceInETH }}
                  v-icon(large) mdi-ethereum
                v-spacer
                v-btn(@click="mintToken" :disabled="!form.valid || soldOut || loading" large color="primary") Mint
          v-alert(v-if="!loading && !form.valid" type="error" prominent outlined border="left").invalid-options Invalid Box Options!
          v-alert(v-if="!loading && soldOut" type="warning" prominent outlined border="left").sold-out
            p All boxes have sold, minting is disabled.
            p Try the secondary market
            v-btn(href="//opensea.io" target="new" color="warning" outlined) Browse OpenSea
        v-col(align="center" cols="12" md="5")
          h1 Create a TinyBox
          v-form(v-model="form.valid").create-form
            .form-buttons
              TooltipIconBtn(icon="mdi-seed" tip="New Seed" @click="reseed" bottom).reseed-btn
              v-spacer
              TooltipIconBtn(icon="mdi-close" tip="Reset" @click="reset" bottom).reset-btn
              TooltipIconBtn(icon="mdi-undo" tip="Undo" @click="undo" bottom).undo-btn
              TooltipIconBtn(icon="mdi-redo" tip="Redo" @click="redo" bottom).redo-btn
              TooltipIconBtn(icon="mdi-dice-multiple" tip="Randomize" @click="randomizeSection('all')" bottom).randomize-btn
              v-spacer
              TooltipIconBtn(icon="mdi-share" tip="Share" @click="overlay = 'share'" bottom).share-btn
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
                      v-range-slider(v-else-if="option.type === 'range-slider'" v-model="values[option.key]" @change="changed" thumb-label required
                        :step="option.step" :label="option.label" :min="option.range.min" :max="option.range.max")
                      v-switch(v-else-if="option.type === 'switch'" v-model="values[option.key]" @change="changed" :label="option.label").switch
                      v-text-field(v-else v-model="values[option.key]" @change="changed" :label="option.label" required outlined type="number")
</template>

<script lang="ts">
import Vue from "vue";
import { log } from 'console';
import { mapGetters, mapState } from "vuex";
import { sections } from "./create-form";
import Token from "@/components/Token.vue";
import Share from "@/components/Share.vue";
import TooltipIconBtn from "@/components/TooltipIconBtn.vue";
import { rejects } from "assert";

export default Vue.extend({
  name: "Create",
  components: { Token, Share, TooltipIconBtn },
  data: function() {
    return {
      id: null as number | null,
      loading: true,
      overlay: "",
      data: null as object | null,
      price: "",
      tx: {},
      gasEstimate: null,
      limit: null as number | null,
      retryCount: 0,
      form: {
        section: 0,
        valid: true,
      },
      minted: {} as any,
      values: {} as any,
      defaults: {
        seed: Date.now(),
        shapes: 11,
        hatching: 0,
        width: [100, 200],
        height: [100, 200],
        spread: 50,
        rows: 2,
        cols: 2,
        hue: Date.now() % 360,
        saturation: 80,
        lightness: 70,
        contrast: 40,
        animate: false,
        traits: [0,0,9,0],
      },
      sections: sections,
    };
  },
  computed: {
    paramsSet: function() {
      return Object.keys(this.$route.query).length > 0
    },
    priceInETH: function() {
      return this.$store.state.web3.utils.fromWei((this as any).price);
    },
    active: function() {
      return (this as any).sections.map((s: any) => {
        s.options.filter((o: any) => !o.hide || (this as any).values[o.hide]);
        return s;
      });
    },
    dialog: {
      get: function () {
        return (this as any).overlay !== "";
      },
      set: function (newValue) {
        console.log(newValue);
        (this as any).overlay = "";
      }
    },
    inProgress: function() {
      return (
        (this as any).overlay === "confirm" || (this as any).overlay === "wait"
      );
    },
    soldOut: function() {
      return parseInt((this as any).id) >= parseInt((this as any).limit);
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
      t.lookupLimit();
      t.loadFormDefaults();
      if (t.paramsSet) t.loadParams();
      else t.updateParams();
      t.loadToken();
      t.listenForTokens();
      t.listenForMyTokens();
    }
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
    changed: async function() {
      const t = this as any;
      if (t.values.hatching > t.values.shapes) t.values.hatching = t.values.shapes;
      t.updateParams();
      t.loadToken();
    },
    randomizeSection: function(section: number | string) {
      const t = this as any;
      t.randomize(section);
      if (t.values.hatching > t.values.shapes) t.values.hatching = t.values.shapes;
      t.updateParams();
      t.loadToken()
        .then((art: any) => {
          if (art) {
            t.updateParams();
            t.retryCount = 0
          }
        })
        .catch((err: any) => {
          console.error("Invalid Box Options - Call Reverted: ", err)
          if (t.retryCount < 3) {
            console.log("Retrying Randomize...")
            t.retryCount++
            t.randomizeSection(section)
          }
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
    reset() {
      const t = this as any;
      t.loadFormDefaults();
      t.changed();
    },
    reseed() {
      const t = this as any;
      t.values.seed = Date.now();
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
      const query = t.parseQuery(t.unpackQuery(t.$route.query));
      Object.assign(t.values, query);
      if (t.values.hatching > t.values.shapes) t.values.hatching = t.values.shapes;
    },
    updateParams() {
      const t = this as any;
      const q = t.buildQuery();
      if (t.$route.query === {}) this.$router.replace({ path: "/create", query: q });
      else this.$router.push({ path: "/create", query: q });
    },
    buildQuery() {
      const t = this as any;
      const v = t.values;
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
    unpackQuery(q: any) {
      const t = this as any;
      // unpack keys and values from shorter URL encoding
      q.s = q.s.split("-");
      q.d = q.d.split("-");
      q.p = q.p.split("-");
      q.c = q.c.split("-");
      const out: any = {
        seed: q.r,
        shapes: q.s[0],
        hatching: q.s[1],
        width: q.d[0].split("~"),
        height:q.d[1].split("~"),
        spread: q.p[0],
        rows: (q.p[1] / 16),
        cols: (q.p[1] % 16),
        hue: q.c[0],
        saturation: q.c[1],
        lightness:q.c[2],
        contrast: q.c[3],
      };
      return out;
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
    loadToken: async function() {
      const t = this as any;
      if (!t.form.valid) { console.log("Invalid Form Values"); return; }
      t.loading = true;
      await t.loadStatus()
      const v = {...t.values, ...t.assembleDials(), color: t.assemblePalette(), settings: [5, 0, 0]};
      console.log(v);
      this.$store.state.contracts.tinyboxes.methods
        .tokenPreview(v.seed.toString(), v.shapes, v.hatching, v.color, v.size, v.spacing, v.traits, v.settings, t.id)
        .call()
        .then((result: any) => {
          t.data = result;
          t.loading = false;
        })
        .catch((err: any) => {
          console.log('Error Prone Inputs: ', v);
          console.error(err);
        });
    },
    mintToken: async function() {
      const t = this as any;
      const v = {...t.values, ...t.assembleDials(), color: t.assemblePalette()};
      t.price = await t.getPrice();
      t.tx = {
        from: this.currentAccount,
        to: this.$store.state.tinyboxesAddress,
        value: t.price,
        data: this.$store.state.contracts.tinyboxes.methods
          .buyFor(v.seed.toString(), v.shapes, v.hatching, v.color, v.size, v.spacing, this.currentAccount)
          .encodeABI(),
      };
      //t.gasEstimate = await t.$store.state.web3.eth.estimateGas(t.tx);
      t.minted = {};
      t.overlay = "verify";
      t.$store.state.web3.eth.sendTransaction(t.tx,
        async (err: any, txHash: string) => {
          const t = this as any;
          if (err) t.overlay = err.code === 4001 ? "" : "error";
          else {
            t.minted.txHash = txHash;
            t.overlay =  "confirm";
          }
        }
      );
    },
    listenForMyTokens: function() {
      this.$store.state.web3.eth
        .subscribe("logs", {
          address: this.$store.state.tinyboxesAddress,
          topics: [
            "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
            "0x0000000000000000000000000000000000000000000000000000000000000000",
            "0x000000000000000000000000" + this.currentAccount.slice(2),
          ],
        })
        .on("data", async (log: any) => {
          const t = this as any;
          t.minted.id = parseInt(log.topics[3], 16);
          t.minted.art = await t.$store.state.contracts.tinyboxes.methods.tokenArt(t.minted.id, 5, 0, 1).call();
          t.overlay = "ready";
        });
    },
    listenForTokens: function() {
      this.$store.state.web3.eth
        .subscribe("logs", {
          address: this.$store.state.tinyboxesAddress,
          topics: [
            "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
            "0x0000000000000000000000000000000000000000000000000000000000000000",
          ],
        })
        .on("data", (log: any) => {
          (this as any).loadToken();
        });
    },
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
.sold-out
  margin-top: 1rem
.form-buttons, .price-tag
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
.dialog .v-card__text
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

<template lang="pug">
  .token-creator
    v-dialog(:value="dialog" transition="fade" :persistent="inProgress")
      v-container(fluid)
        v-row
          v-col(md="4" sm="6" xs="12" offset-md="4" offset-sm="3")
            v-card.dialog
              v-fade-transition(appear group)
                .dialog-verify(v-if="overlay === 'verify'" key="verify")
                  v-card-title Submit The Transaction
                  v-card-text
                    .message
                      h3 Mint Token {{ "#" + id }} for {{ priceInETH }} 
                        v-icon mdi-ethereum
                .dialog-confirm(v-if="overlay === 'confirm'" key="confirm")
                  v-card-title Awaiting TX Confirmations
                  v-card-text
                    .message
                      h3 {{ confirmations }} Confirmations
                      h3 Hash: {{ formatHash(minted.txHash) }}
                      v-tooltip(top)
                        template(v-slot:activator='{ on }')
                          v-btn(:href="'https://rinkeby.etherscan.io/tx/' + minted.txHash" v-on='on' target="new")
                            v-icon mdi-open-in-new
                        span View on Etherscan
                    v-progress-linear(:value="confirmations / confirmationsRequired * 100")
                .dialog-wait(v-else-if="overlay === 'wait'" key="wait")
                  v-card-title Waiting For VRF Fullfillment
                  v-card-text
                    .message
                      h3 Please Wait...
                    v-progress-linear(indeterminate)
                .dialog-ready(v-else-if="overlay === 'ready'" key="ready")
                  v-skeleton-loader(:value="!minted.art" type="image")
                    Token(:id="minted.id" :data="data")
                  v-card-title Yay! You Minted Token {{ "#" + minted.id }}
                  v-card-actions
                    v-btn(:to="'/token/' + minted.id") View Token
                    v-spacer
                    v-btn(@click="overlay = ''; loadToken()") Mint Another
                .dialog-error(v-else-if="overlay === 'error'" key="error")
                  v-card-title Transaction Error
                  v-card-text
                    v-alert(type="error" border="left") An error occured while minting your token
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
              span(v-else) TinyBox {{ "#" + id }}
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
                v-btn(@click="mintToken" :disabled="!form.valid || soldOut || loading") Mint
          v-alert(v-if="!loading && soldOut" type="warning" prominent outlined border="left").sold-out
            p All boxes have sold, minting is disabled.
            p Try the secondary market
            v-btn(href="//opensea.io" target="new" color="warning" outlined) Browse OpenSea
        v-col(align="center" cols="12" md="5")
          h1 Create a TinyBox
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
                  v-btn(@click="copyPath" v-on="on" icon).share-btn
                    v-icon mdi-share
                span Share
            br
            v-expansion-panels(v-model="form.section" popout tile)
              v-expansion-panel.section(v-for="section,s of active" :key="section.title" ripple)
                v-expansion-panel-header(color="#3F51B5").section-title
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
import { mapGetters, mapState } from "vuex";
import { sections } from "./create-form";
import Token from "@/components/Token.vue";
import { log } from 'console';

export default Vue.extend({
  name: "Create",
  components: { Token },
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
    dialog: function() {
      return (this as any).overlay !== "";
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
    ...mapGetters(["currentAccount"]),
  },
  mounted: async function() {
    const t = this as any;
    await this.$store.dispatch("initialize");
    t.lookupLimit();
    t.loadFormDefaults();
    if (t.paramsSet) t.loadParams();
    else t.setParams();
    t.loadToken();
    t.listenForTokens();
    t.listenForMyTokens();
  },
  methods: {
    randomizeSection: function(section: number | string) {
      const t = this as any;
      t.randomize(section);
      t.loadToken()
        .then((art: any) => {
          if (art) t.setParams();
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
    copyPath() {
      console.log(this.$route.fullPath);
    },
    changed: async function() {
      const t = this as any;
      t.setParams();
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
    setParams() {
      this.$router.push({ path: "/create", query: (this as any).values });
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
        if (!t.form.valid) reject("Invalid Form Values");
        t.loading = true;
        t.loadStatus()
        const v = {...t.values, palette: t.assemblePalette(), dials: t.assembleDials()};
        this.$store.state.contracts.tinyboxes.methods
          .tokenTest(v.seed.toString(), v.shapes, v.palette, v.dials, v.animation, v.animate)
          .call()
          .then((result: any) => {
            t.data = result;
            t.loading = false;
            resolve(result);
          })
          .catch((err: any) => {
            console.log('Error Prone Inputs: ', v);
            console.error(err);
            reject(err);
          });
      })
    },
    mintToken: async function() {
      const t = this as any;
      const v = {...t.values, palette: t.assemblePalette(), dials: t.assembleDials()};
      t.price = await t.getPrice();
      t.minted = {};
      t.overlay = "verify";
      t.$store.state.web3.eth.sendTransaction(
        {
          from: this.currentAccount,
          to: this.$store.state.tinyboxesAddress,
          value: t.price,
          data: this.$store.state.contracts.tinyboxes.methods
            .buy(v.seed.toString(), v.shapes, v.palette, v.dials)
            .encodeABI(),
        },
        async (err: any, txHash: string) => {
          const t = this as any;
          t.minted.txHash = txHash;
          t.overlay = err ? "error" : "confirm";
          t.checkConfirmations(txHash);
        }
      );
    },
    async checkConfirmations(txHash: string) {
      const t = this as any;
      t.confirmations = await t.getConfirmations(txHash);
      if (t.confirmations >= t.confirmationsRequired) {
        if (t.overlay === 'ready') return;
        t.overlay = "wait";
      }
      else setTimeout(await t.checkConfirmations(txHash), 5000);
    },
    async getConfirmations(txHash: string) {
      try {
        // Get transaction details
        const trx = await this.$store.state.web3.eth.getTransaction(txHash)
        // When transaction is unconfirmed, its block number is null
        return trx.blockNumber === null ? 0 : (await this.$store.state.web3.eth.getBlockNumber()) - trx.blockNumber
      }
      catch (error) {
        console.log(txHash, error)
      }
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
          t.minted.art = await t.$store.state.contracts.tinyboxes.methods
            .tokenArt(t.minted.id, true)
            .call();
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
  data: function() {
    return {
      id: null as number | null,
      loading: true,
      overlay: "",
      data: null as object | null,
      price: "",
      confirmations: 0,
      confirmationsRequired: 2,
      limit: null as number | null,
      form: {
        section: 0,
        valid: true,
      },
      minted: {} as any,
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

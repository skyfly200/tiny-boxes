<template lang="pug">
  .token-creator
    v-dialog(:value="dialog" transition="fade" :persistent="inProgress" @click:outside="overlay=''" width="500")
      Share.dialog-share(v-if="overlay === 'share'" key="share")
      v-card.dialog-verify(v-else-if="overlay === 'verify'" key="verify")
        v-card-title Submit The Transaction
        v-card-text
          .message
            h3 Mint for {{ priceInETH }}
              v-icon mdi-ethereum
            h3 To {{ recipient }}
      v-card.dialog-recipient(v-else-if="overlay === 'recipient'" key="recipient")
        v-card-title Set Token Recipient
        v-card-text
          .message                      
            v-text-field(v-model="recipient")
        v-card-actions
          v-btn(@click="recipient = currentAccount; overlay = ''") Cancel
          v-spacer
          v-btn(@click="mintToken") Mint
      v-card.dialog-confirm(v-else-if="overlay === 'confirm'" key="confirm")
        v-card-title Minting
        v-card-text
          .message                      
            .d-flex
              h3 Hash: {{ formatHash(minted.txHash) }}
              v-spacer
              v-tooltip(top)
                template(v-slot:activator='{ on }')
                  a(:href="'https://etherscan.io/tx/' + minted.txHash" v-on='on' target="new")
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
        v-col(align="center" cols="12" sm="10" md="5" offset-sm="1")
          v-card.token-preview
            v-card-title.token-stats(align="center")
              v-skeleton-loader(v-if="id === null" type="card-heading" width="20vw")
              span(v-else) Preview Your TinyBox
            v-card-subtitle
              v-skeleton-loader(v-if="id === null" type="card-heading" width="20vw")
              template(v-else)
                span Phase: {{ phase + 1 }}
                v-spacer
                span Color Scheme: {{ schemeTitles[phase] }}
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
                h3(v-if="paused") Minting Paused
                vac(v-else-if="countdown" :end-time="pauseEndTime")
                  template(v-slot:process="{ timeObj }")
                    span {{ `${timeObj.h}:${timeObj.m}:${timeObj.s}` }} to phase {{ Math.floor(id / phaseLen) + 1 }}
                template(v-else)
                  TooltipIconBtn(icon="mdi-forward" tip="Forward Mint" @click="overlay='recipient'" bottom).forward-btn
                  v-btn(@click="mintToken" :disabled="!form.valid || soldOut || loading" large color="primary")
                    v-icon.mr-2 mdi-creation
                    span Mint {{ ((id % phaseLen) + 1) + "/" + phaseLen }}
          v-alert(v-if="!loading && !form.valid" type="error" prominent outlined border="left").invalid-options Invalid Box Options!
          v-alert(v-if="!loading && soldOut" type="warning" prominent outlined border="left").sold-out
            p All boxes have sold, minting is disabled.
            p Try the secondary market
            v-btn(href="//opensea.io" target="new" color="warning" outlined) Browse OpenSea
          .explore-link.mt-4
            p Need some inspiration?
            v-btn(to="/explore" color="secondary") Explore The Possibilities
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
                  template(v-if="section.title === 'Color'")
                    HuesGrid(:color="values.color" :scheme="phase").ma-2
                    ColorPicker(v-bind="values.color" variant="persistent" @change="setHue").picker.ma-2
                    v-slider(v-if="phase === 10" v-model="values.hueSeed" @change="changed" thumb-label required label="Hue Seed" min="0" max="182")
                    v-slider(v-model="values.color.saturation" @change="changed" thumb-label required label="Saturation" min="20" max="100")
                    v-slider(v-model="values.color.luminosity" @change="changed" thumb-label required label="Lightness" min="0" max="100")
                  template(v-else-if="section.title === 'Shapes'")
                    v-slider(v-model="values.shapes" @change="changed" thumb-label required label="Count" min="1" max="30")
                    v-slider(v-model="values.hatching" @change="changed" thumb-label required label="Hatching" min="0" :max="values.shapes")
                    v-range-slider(v-model="values.width" @change="changed" thumb-label required label="Width" step="1" min="1" max="255")
                    v-range-slider(v-model="values.height" @change="changed" thumb-label required label="Height" step="1" min="1" max="255")
                  template(v-else-if="section.title === 'Placement'")
                    v-slider(v-model="values.spread" @change="changed" thumb-label required label="Spread" min="0" max="100")
                    v-slider(v-model="values.rows" @change="changed" thumb-label required label="Rows" min="1" max="16")
                    v-slider(v-model="values.cols" @change="changed" thumb-label required label="Columns" min="1" max="16")
                  template(v-else-if="section.title === 'Mirroring'")
                    v-slider(v-model="values.m1" @change="changed" thumb-label required label="Level 1" min="0" max="3")
                    v-slider(v-model="values.m2" @change="changed" thumb-label required label="Level 2" min="0" max="3")
                    v-slider(v-model="values.m3" @change="changed" thumb-label required label="Level 3" min="0" max="3")
                      
</template>

<script lang="ts">
import Vue from "vue";
import { log } from 'console';
import { mapGetters, mapState } from "vuex";
import { sections } from "./create-form";
import Token from "@/components/Token.vue";
import Share from "@/components/Share.vue";
import TooltipIconBtn from "@/components/TooltipIconBtn.vue";
import ColorPicker from '@radial-color-picker/vue-color-picker';
import HuesGrid from '@/components/HuesGrid.vue';
import { rejects } from "assert";

export default Vue.extend({
  name: "Create",
  components: { Token, Share, TooltipIconBtn, ColorPicker, HuesGrid },
  data: function() {
    return {
      usersReferal: null as number | null,
      max256: 115792089237316195423570985008687907853269984665640564039457584007913129639936n,
      id: null as number | null,
      loading: true,
      paused: false,
      countdown: false,
      pauseEndTime: null,
      currentBlock: null,
      currentBlockTimestamp: null,
      blockStart: new Date(),
      blockSubscription: null,
      overlay: "",
      data: null as object | null,
      price: "",
      recipient: null,
      tx: {},
      limit: null as number | null,
      form: {
        section: 0,
        valid: true,
      },
      minted: {} as any,
      values: {
        color: {} as any
      } as any,
      defaults: {
        seed: Date.now(),
        shapes: 11,
        hatching: 0,
        width: [100, 200],
        height: [100, 200],
        spread: 50,
        rows: 2,
        cols: 2,
        color: {
          hue: Date.now() % 360,
          saturation: 80,
          luminosity: 70
        },
        hueSeed: 0,
        animate: false,
        m1: 3,
        m2: 3,
        m3: 3,
        traits: [0,0,7,0],
      },
      sections: sections,
    };
  },
  computed: {
    phaseLen() {
      return (this as any).limit / 11;
    },
    phase() {
      return Math.floor((this as any).id / (this as any).phaseLen);
    },
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
  created: async function() {
    const t = this as any;
    t.loadFormDefaults();
  },
  mounted: async function() {
    const t = this as any;
    await this.$store.dispatch("initialize");
    if (!this.wrongNetwork) {
      t.recipient = t.currentAccount;
      await t.lookupCurrentBlock();
      t.currentBlockTimestamp = new Date().getTime() * 1000;
      const balance = await t.lookupBalance();
      if (balance > 0) {
        t.usersReferal = await t.lookupUsersToken(0);
        t.usersReferal = t.usersReferal < 2222 ? t.usersReferal : (BigInt(t.usersReferal) - t.max256).toString(10);
      } else t.usersReferal = "10000";
      t.lookupLimit();
      if (t.paramsSet) t.loadParams();
      else t.updateParams();
      t.loadToken();
      t.listenForTokens();
      t.listenForMyTokens();
    }
  },
  methods: {
    getSupply: function() {
      return this.$store.state.contracts.tinyboxes.methods._tokenIds().call();
    },
    getPrice: function() {
      return this.$store.state.contracts.tinyboxes.methods.price().call();
    },
    lookupLimit: async function() {
      (this as any).limit = await this.$store.state.contracts.tinyboxes.methods.TOKEN_LIMIT().call();
    },
    lookupBalance: function() {
      return (this as any).$store.state.contracts.tinyboxes.methods.balanceOf((this as any).currentAccount).call();
    },
    lookupUsersToken(i: any) {
      return (this as any).$store.state.contracts.tinyboxes.methods.tokenOfOwnerByIndex((this as any).currentAccount, i).call();
    },
    lookupPause: async function() {
      return (this as any).paused = await this.$store.state.contracts.tinyboxes.methods.paused().call();
    },
    lookupBlockStart: async function() {
      return (this as any).blockStart = await this.$store.state.contracts.tinyboxes.methods.blockStart().call();
    },
    async lookupCurrentBlock() {
      (this as any).currentBlock =  await this.$store.state.web3.eth.getBlockNumber();
    },
    loadStatus: async function() {
      const t = this as any;
      const idLookup = t.getSupply();
      const priceLookup = t.getPrice();
      t.id = await idLookup;
      t.price = await priceLookup;
      t.values.traits[1] = t.id == 0 ? 0 : Math.floor(t.id / (t.limit / 10)); // auto update scheme preview
      t.checkForCountdown();
      t.listenForBlocks();
    },
    async checkForCountdown() {
      const t = this as any;
      await t.lookupBlockStart();
      await t.lookupPause();
      t.countdown = t.currentBlock <= t.blockStart;
      if (t.countdown) {
        const timeLeft = (t.blockStart - t.currentBlock) * 13350;
        t.pauseEndTime = new Date().getTime() + timeLeft; //t.currentBlockTimestamp
      }
      return t.countdown;
    },
    setHue: function(hue: any) {
      (this as any).values.color.hue = parseInt(hue);
      (this as any).changed();
    },
    changed: async function() {
      const t = this as any;
      if (t.values.hatching > t.values.shapes) t.values.hatching = t.values.shapes;
      if (!t.deepEqual(t.$route.query, t.buildQuery())) { // check the values have changed
        t.updateParams();
        t.loadToken();
      }
    },
    randomizeSection: function(section: number | string) {
      const t = this as any;
      t.randomize(section);
      t.changed();
    },
    randomize: function(section: number | string) {
      const t = this as any;
      const randomSettings: any = {};
      if (section === "all" || section === 0) randomSettings.color = {
        hue: t.between({ min: 0, max: 359 }),
        saturation: t.between({ min: 20, max: 100 }),
        luminosity: t.between({ min: 30, max: 100 })
      };
      for (const s of (section === "all") ? t.sections : [t.sections[section]]) {
        if (s.rand) {
          for (const o of s.options) {
            if (o.rand !== false && !t.values[o.hide] && t.values[o.show] !== false) {
              const range = o.rand ? o.rand : o.range;
              switch (o.type) {
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
      return Math.floor( Math.random() * (range.max - range.min + 1) + range.min );
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
      Object.assign(t.values, t.defaults); // set values to default
    },
    loadParams() {
      const t = this as any;
      // overwrite with any url query params
      const query = t.parseQuery(t.unpackQuery(t.$route.query));
      Object.assign(t.values, query);
      if (t.values.hatching > t.values.shapes) t.values.hatching = t.values.shapes;
    },
    async updateParams() {
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
        i: v.referal ? v.referal : t.usersReferal,
        r: v.seed,
        h: v.hueSeed,
        s: [v.shapes, v.hatching].join("-"), // shapes - count, hatching
        d: [v.width.join("~"), v.height.join("~")].join("-"), // dimensions ranges
        p: [v.spread, (v.rows * 16) + v.cols].join("-"), // positioning - spread, grid
        c: [v.color.hue, v.color.saturation, v.color.luminosity].join("-"), // color - hue, saturation, luminosity
        m: [v.m1, v.m2, v.m3].join("-") // mirroring levels
      };
      return out;
    },
    unpackQuery(q: any) {
      const t = this as any;
      // unpack keys and values from shorter URL encoding
      const s = q.s.split("-");
      const d = q.d.split("-");
      const p = q.p.split("-");
      const c = q.c.split("-");
      const m = q.m.split("-");
      const out: any = {
        referal: q.i,
        seed: q.r,
        hueSeed: q.h,
        shapes: s[0],
        hatching: s[1],
        width: d[0].split("~"),
        height:d[1].split("~"),
        spread: p[0],
        rows: (p[1] / 16),
        cols: (p[1] % 16),
        color: {
          hue: c[0],
          saturation: c[1],
          luminosity: c[2],
        },
        m1: m[0],
        m2: m[1],
        m3: m[2],
      };
      return out;
    },
    parseQuery(query: any) {
      const out: any = {};
      // check true, false, array, string, number
      for (const [i,q] of Object.entries(query)) {
        out[i] =
          ( Array.isArray(q) ? (q as any).map((v: any) => parseInt(v)) :
            ( ( i === "seed" || isNaN(parseInt(q as any)) ) ? q : parseInt(q as any) ) );
      }
      return out;
    },
    assemblePalette: function() {
      const t = this as any;
      const v = (this as any).values;
      return [
        t.phase === 10 ? (v.color.hue + (v.hueSeed * 360)) : v.color.hue,
        v.color.saturation,
        v.color.luminosity
      ];
    },
    assembleDials: function() {
      const t = this as any;
      const v = t.values;
      v.width = v.width.sort((a: any,b: any) => a - b);
      v.height = v.height.sort((a: any,b: any) => a - b);
      return {
        spacing: [ v.spread, ((v.rows-1) * 16) + v.cols-1 ],
        size: [ ...v.width, ...v.height ],
        mirroring: v.m1 + (v.m2 * 4) + (v.m3 * 16)
      };
    },
    loadToken: async function() {
      const t = this as any;
      if (!t.form.valid) { console.log("Invalid Form Values"); return; }
      t.loading = true;
      await t.loadStatus()
      const v = {...t.values, ...t.assembleDials(), palette: t.assemblePalette(), settings: [0, 10, 0]};
      const traits = [ 0, t.phase, 7, 0 ]; // v.color.luminosity
      this.$store.state.contracts.tinyboxes.methods
        .renderPreview(v.seed.toString(), v.palette, [v.shapes, v.hatching], v.size, v.spacing, v.mirroring, v.settings, traits, '')
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
      const v = {...t.values, ...t.assembleDials(), palette: t.assemblePalette()};
      t.price = await t.getPrice();
      t.tx = {
        from: this.currentAccount,
        to: this.$store.state.tinyboxesAddress,
        value: t.price,
        data: this.$store.state.contracts.tinyboxes.methods
          .create(v.seed.toString(), [v.shapes, v.hatching], v.palette, v.size, v.spacing, v.mirroring, t.recipient, t.usersReferal)
          .encodeABI(),
      };
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
          t.recipient = t.currentAccount;
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
          t.minted.art = await t.$store.state.contracts.tinyboxes.methods.tokenArt(t.minted.id, 0, 0, 1, '').call();
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
    listenForBlocks: function() {
      const t = this as any;
      t.blockSubscription = t.$store.state.web3.eth
        .subscribe("newBlockHeaders", function(error: any, result: any){
            if (!error) {
                //console.log(result);
                return;
            }
            console.error(error);
        })
        .on("data", async function(blockHeader: any){
          t.currentBlock = blockHeader.number;
          t.currentBlockTimestamp = blockHeader.timestamp * 1000;
          t.checkForCountdown();
        })
        .on("error", console.error);
    },
    unsubscribeBlocks: function() {
        // unsubscribes the subscription
        (this as any).blockSubscription.unsubscribe(function(error: any, success: any){
            if (success) {
                console.log('Successfully unsubscribed blocks listener');
            }
        });
    },
    deepEqual(object1: any, object2: any) {
      const t = this as any;
      const keys1 = Object.keys(object1);
      const keys2 = Object.keys(object2);

      if (keys1.length !== keys2.length) {
        return false;
      }

      for (const key of keys1) {
        const val1 = object1[key];
        const val2 = object2[key];
        const areObjects = t.isObject(val1) && t.isObject(val2);
        if (
          areObjects && !t.deepEqual(val1, val2) ||
          !areObjects && val1 !== val2
        ) {
          return false;
        }
      }

      return true;
    },
    isObject(object: any) {
      return object != null && typeof object === 'object';
    },
  },
});
</script>

<style lang="sass">
@import '~@radial-color-picker/vue-color-picker/dist/vue-color-picker.min.css'
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

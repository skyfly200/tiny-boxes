<template lang="pug">
  .token-creator
    v-dialog(:value="dialog" transition="fade" :persistent="inProgress")
      v-container(fluid)
        v-row
          v-col(md="4" sm="6" xs="12" offset-md="4" offset-sm="3")
            v-card.dialog
              v-fade-transition(appear group)
                .dialog-confirm(v-if="overlay === 'confirm'" key="confirm")
                  v-card-title Confirming Transaction
                  v-card-text
                    .message
                      h3 Mint Token {{ "#" + id }} for {{ priceInETH }} 
                        v-icon mdi-ethereum
                    v-progress-linear(indeterminate)
                .dialog-wait(v-else-if="overlay === 'wait'" key="wait")
                  v-card-title Transaction Pending
                  v-card-text
                    .message
                      h3 Please Wait...
                    v-progress-linear(indeterminate)
                .dialog-ready(v-else-if="overlay === 'ready'" key="ready")
                  v-skeleton-loader(:value="!minted.art" type="image")
                    Token(:id="minted.id" :data="data")
                  v-card-title Yay! You Minted Token {{ "#" + minted.id }}
                  v-card-text
                    .message
                      h3 Transaction Completed
                        v-tooltip(top)
                          template(v-slot:activator='{ on }')
                            span(:href="'https://rinkeby.etherscan.io/tx/' + minted.txHash" v-on='on' target="new") &nbsp;
                              v-icon mdi-open-in-new
                          span View on Etherscan
                  v-card-actions
                    v-btn(:to="'/token/' + minted.id") View Token
                    v-spacer
                    v-btn(@click="overlay = ''; loadFormDefaults(); update()") Mint Another
                .dialog-error(v-else-if="overlay === 'error'" key="error")
                  v-card-title Transaction Error
                  v-card-text
                    v-alert(type="error" border="left") An error occured while minting your token
                  v-card-actions
                    v-btn(@click="mintToken" color="success") Try Again
                    v-spacer
                    v-btn(@click="overlay = ''; update()" color="error") Cancel
    v-container(fluid)
      v-row(flex)
        v-col(align="center" cols="12" md="5" offset-md="1")
          v-card(max-height="90vh").token-preview
            v-card-title.token-stats
              v-skeleton-loader(v-if="id === null" type="card-heading" width="20vw")
              h1(v-else) Token {{ "#" + id }}
            v-divider
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
              v-btn(@click="loadFormDefaults") Reset
              v-spacer
              v-btn(@click="randomizeForm") Randomize
            br
            v-expansion-panels(v-model="form.section" accordion flat tile)
              v-expansion-panel.section(v-for="section of active" :key="section.title" ripple)
                v-expansion-panel-header(color="#3F51B5").section-title {{ section.title }}
                v-expansion-panel-content.section-content
                  template(v-for="option of section.options")
                    template(v-if="!option.hide || values[option.hide]")
                      v-slider(v-if="option.type === 'slider'" v-model="values[option.key]" @change="update" thumb-label required
                        :label="option.label" :step="option.step" :min="option.range.min" :max="option.range.max")
                          template(v-slot:append)
                            v-text-field(v-model="values[option.key]" @change="update" hide-details single-line type="number" style="width: 60px").slider-text-field
                      v-range-slider(v-else-if="option.type === 'range-slider'" v-model="values[option.key]" @change="update" thumb-label required
                        :step="option.step" :label="option.label" :min="option.range.min" :max="option.range.max")
                          template(v-slot:prepend)
                            v-text-field(v-model="values[option.key][0]" @change="update" hide-details single-line type="number" style="width: 60px").slider-text-field
                          template(v-slot:append)
                            v-text-field(v-model="values[option.key][1]" @change="update" hide-details single-line type="number" style="width: 60px").slider-text-field
                      v-switch(v-else-if="option.type === 'switch'" v-model="values[option.key]" @change="update" :label="option.label").switch
                      v-text-field(v-else v-model="values[option.key]" @change="update" :label="option.label" required outlined type="number")
</template>

<script lang="ts">
import Vue from "vue";
import { mapGetters } from "vuex";
import { tinyboxesAddress } from "../tinyboxes-contract";
import { sections } from "./create-form";
import Token from "@/components/Token.vue";

export default Vue.extend({
  name: "Create",
  components: { Token },
  computed: {
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
      return (this as any).id >= (this as any).limit;
    },
    ...mapGetters(["currentAccount"])
  },
  mounted: async function() {
    const t = this as any;
    await this.$store.dispatch("initialize");
    t.limit = await t.lookupLimit();
    t.loadFormDefaults();
    t.listenForTokens();
    t.listenForMyTokens();
  },
  methods: {
    update: async function() {
      const t = this as any;
      if (t.form.valid) t.loadToken();
    },
    loadStatus: async function() {
      const t = this as any;
      t.id = await t.lookupSupply();
      t.price = await t.getPrice();
    },
    lookupSupply: function() {
      return this.$store.state.contracts.tinyboxes.methods.totalSupply().call();
    },
    lookupLimit: function() {
      return this.$store.state.contracts.tinyboxes.methods.TOKEN_LIMIT().call();
    },
    getPrice: function() {
      return this.$store.state.contracts.tinyboxes.methods
        .currentPrice()
        .call();
    },
    loadFormDefaults: function() {
      const t = this as any;
      Object.assign(t.values, t.defaults);
      t.update();
    },
    randomizeForm: function() {
      const t = this as any;
      const randomSettings: any = {};
      for (const s of t.sections)
        if (s.rand)
          for (const o of s.options) {
            const range = o.rand ? o.rand : o.range;
            switch (o.type) {
              case "switch":
                randomSettings[o.key] = Math.random() > 0.5;
                break;
              case "range-slider":
                randomSettings[o.key] = [range, range]
                  .map(r => t.between(r))
                  .sort();
                break;
              default:
                randomSettings[o.key] = t.between(range);
                break;
            }
          }
      Object.assign(t.values, randomSettings);
      t.update();
    },
    between: function(range: any) {
      return Math.floor(
        Math.random() * (range.max - range.min + 1) + range.min
      );
    },
    loadToken: async function() {
      const t = this as any;
      t.loading = true;
      await t.loadStatus();
      const v = t.values;
      const counts = [v.colors, v.shapes];
      const dials = [
        v.x,
        v.y,
        v.xSeg,
        v.ySeg,
        v.width[0],
        v.width[1],
        v.height[0],
        v.height[1],
        v.hatching,
        v.mirrorPos1,
        v.mirrorPos2,
        v.mirrorPos3,
        v.scale
      ];
      const switches = [v.mirror1, v.mirror2, v.mirror3];
      t.data = await this.$store.state.contracts.tinyboxes.methods
        .perpetualRenderer(t.id, v.seed.toString(), counts, dials, switches)
        .call()
        .catch((err: any) => {
          console.error(err, t.id, v.seed);
        });
      t.loading = false;
    },
    mintToken: async function() {
      const t = this as any;
      const v = t.values;
      const counts = [v.colors, v.shapes];
      const dials = [
        v.x,
        v.y,
        v.xSeg,
        v.ySeg,
        v.width[0],
        v.width[1],
        v.height[0],
        v.height[1],
        v.hatching,
        v.mirrorPos1,
        v.mirrorPos2,
        v.mirrorPos3,
        v.scale
      ];
      const switches = [v.mirror1, v.mirror2, v.mirror3];
      t.price = await t.getPrice();
      t.minted = {};
      t.overlay = "confirm";
      t.$store.state.web3.eth.sendTransaction(
        {
          from: this.currentAccount,
          to: tinyboxesAddress,
          value: t.price,
          data: this.$store.state.contracts.tinyboxes.methods
            .createBox(v.seed.toString(), counts, dials, switches)
            .encodeABI()
        },
        (err: any, txHash: string) => {
          const t = this as any;
          t.minted.txHash = txHash;
          t.overlay = err ? "error" : "wait";
        }
      );
    },
    listenForMyTokens: function() {
      this.$store.state.web3.eth
        .subscribe("logs", {
          address: tinyboxesAddress,
          topics: [
            "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
            "0x0000000000000000000000000000000000000000000000000000000000000000",
            "0x000000000000000000000000" + this.currentAccount.slice(2)
          ]
        })
        .on("data", async (log: any) => {
          const t = this as any;
          t.minted.id = parseInt(log.topics[3], 16);
          t.minted.art = await t.$store.state.contracts.tinyboxes.methods
            .tokenArt(t.minted.id)
            .call();
          t.overlay = "ready";
        });
    },
    listenForTokens: function() {
      this.$store.state.web3.eth
        .subscribe("logs", {
          address: tinyboxesAddress,
          topics: [
            "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
            "0x0000000000000000000000000000000000000000000000000000000000000000"
          ]
        })
        .on("data", (log: any) => {
          (this as any).update();
        });
    }
  },
  data: function() {
    return {
      id: null as number | null,
      loading: true,
      overlay: "",
      data: null as null | object,
      price: "",
      limit: null as any,
      form: {
        section: 0,
        valid: true
      },
      minted: {} as any,
      values: {} as any,
      defaults: {
        seed: 1234,
        colors: 7,
        shapes: 11,
        x: 200,
        y: 200,
        xSeg: 2,
        ySeg: 2,
        width: [200, 300],
        height: [200, 300],
        hatching: 0,
        mirror1: true,
        mirror2: true,
        mirror3: true,
        mirrorPos1: 750,
        mirrorPos2: 1300,
        mirrorPos3: 2600,
        scale: 100
      },
      sections: sections
    };
  }
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

<template lang="pug">
  .token-page
    v-container(fluid)
      v-row
        v-col(align="center").token-title
          h1.title TinyBox {{ formatedID }}
      v-row(v-if="loading")
        v-col(align="center").token-loading
            v-progress-circular(indeterminate size="75" color="primary")
            h1 Fetching Token
      v-row(v-else-if="!exists")
        v-col(align="center").token-missing
          h1 Invalid Token ID
      template(v-else)
        v-row(no-gutters)
          v-col(cols="12" md="4")
            .palette
              .scheme
                span Scheme
                h2 {{ data.tokenData.color.saturation === 0 ? "Grayscale" : schemeTitles[data.tokenData.scheme] }}
              ColorsGrid(v-bind="palette")
            .stats
              .root-color.stat
                span.stat-value {{ data.tokenData.color[0] + '°,' + data.tokenData.color[1] + '%,' + data.tokenData.color[2] + '%' }} 
                .stat-title Root Color
              .contrast.stat
                span.stat-value {{ data.tokenData.contrast + '%' }}
                .stat-title Contrast
              .shades.stat
                span.stat-value {{ parseInt(data.tokenData.shades) }}
                .stat-title Shades
              .mirror-a.stat
                span.stat-value {{ data.tokenData.mirroring % 4 }},{{ Math.floor(data.tokenData.mirroring / 4) % 4 }},{{ Math.floor(data.tokenData.mirroring / 16) % 4 }}
                .stat-title Mirroring
              .le.stat(v-if="isLE")
                span.stat-value
                  v-icon(large) mdi-crystal-ball
                .stat-title Limited Edition
          v-col(cols="12" md="4")
            v-card
              Token(v-if="animate" :id="id+'A'" :data="data.animation" key="anim").token-graphic
              Token(v-else :id="id" :data="data.art" key="static").token-graphic
              v-card-actions
                v-tooltip(right)
                  template(v-slot:activator='{ on }')
                    v-btn(icon large v-on='on' @click="animate = !animate" v-bind:class="[animate ? 'on' : 'off']").animate-toggle
                      v-icon mdi-animation
                  span Toggle Animation
                v-spacer
                .anim-title
                  .caption Animation
                  h3 {{ animationTitles[data.tokenData.animation] }}
          v-col(cols="12" md="4")
            .stats
              .shapeCount.stat
                span.stat-value {{ data.tokenData.shapes }}
                .stat-title Shapes
              .hatching.stat
                span.stat-value {{ data.tokenData.hatching }}
                .stat-title Hatching
            .stats
              .width.stat
                span.stat-value {{ data.tokenData.size[0] + '-' + data.tokenData.size[1] }}
                .stat-title Width
              .height.stat
                span.stat-value {{ data.tokenData.size[2] + '-' + data.tokenData.size[3] }}
                .stat-title Height
            .stats
              .spread-x.stat
                span.stat-value {{ data.tokenData.spacing[0] + "%" }}
                .stat-title Spread
              .rows.stat
                span.stat-value {{ Math.floor(data.tokenData.spacing[1] / 16) + 1 }}
                .stat-title Rows
              .columns.stat
                span.stat-value {{ Math.floor(data.tokenData.spacing[1] % 16) + 1 }}
                .stat-title Columns
            .copy-btn.d-flex
              v-btn.my-4(height="3rem" width="160px" color="secondary" @click="gotoMint") Copy Options
        v-row
          v-col(cols="12")
            v-card
              v-card-title(align="center") TinyBox Number {{ formatedID + "'s" }} Story
              v-card-text
                .box-story(align="center")
                  p TinyBox number {{ formatedID }} was created at {{ (new Date(data.block.timestamp * 1000)).toLocaleTimeString() }} on {{ (new Date(data.block.timestamp * 1000)).toLocaleDateString() }}
                  p by&nbsp;
                    a(:href="'https://etherscan.io/address/' + data.tx.from" target="_blank") {{ data.tx.from }}
                  p &nbsp;in TX&nbsp;
                    a(:href="'https://etherscan.io/tx/' + data.creation.transactionHash" target="_blank") {{ data.creation.transactionHash }}
                  p &nbsp;of block number {{ data.block.number }}
                  p Its current owner is&nbsp;
                    a(:href="'https://etherscan.io/address/' + owner" target="_blank") {{ owner }}
                  a(:href="openseaTokenURL + id" title="View on OpenSea" target="_blank")
                    img(style="width:160px; border-radius:0px; box-shadow: 0px 1px 6px rgba(0, 0, 0, 0.25);" src="https://storage.googleapis.com/opensea-static/opensea-brand/listed-button-blue.png" alt="Listed on OpenSea badge")
        v-row(v-if="ownerOf")
          v-col(cols="12")
            v-sheet
              v-expansion-panels(v-model="settingsPane" tile)
                v-expansion-panel(expand ripple)
                    v-expansion-panel-header Render Settings
                    v-expansion-panel-content
                      v-container(no-gutters max-width="100%").render-settings
                        v-row
                          v-col(cols="12" align="center")
                            p Set default render settings for your token on the contract
                        v-row
                          v-col(cols="12" md="8").settings
                            v-slider(v-model="settings.bkg" :disabled="settings.transparent" label="Background" thumb-label min="0" max="100")
                            v-slider(v-model="settings.duration" label="Duration" thumb-label min="1" max="255")
                          v-col(cols="12" md="3" offset-md="1")
                            v-switch(v-model="settings.transparent"  label="Transparent Bkg")
                            v-switch(v-model="settings.animate"  label="Animate")
                        v-row
                          v-col(cols="12")
                            .d-flex
                              v-btn.mr-5(v-if="false") Preview
                              v-btn(v-if="false") Download
                              v-spacer
                              template(v-if="changedSettings")
                                v-btn.mr-5(color="success" @click="saveSettings") Save
                                v-btn(@click="resetSettings") Reset
</template>

<script lang="ts">
import Vue from "vue";
import { mapGetters, mapState } from "vuex";
import Token from "@/components/Token.vue";
import ColorsGrid from "@/components/ColorsGrid.vue";
import { log } from 'util';

export default Vue.extend({
  name: "TokenPage",
  components: { Token, ColorsGrid },
  computed: {
    id(): string {
      return this.$route.params.id.toString();
    },
    palette() {
      return {
        color: this.data.tokenData.color,
        contrast: this.data.tokenData.contrast,
        shades: this.data.tokenData.shades,
        scheme: this.data.tokenData.scheme,
      };
    },
    ownerOf(): boolean {
      return this.currentAccount === (this as any).owner;
    },
    changedSettings() {
      return this.data.settings !== undefined &&
        (parseInt(this.data.settings.bkg) !== (this.settings.transparent ? 101 : this.settings.bkg) ||
        parseInt(this.data.settings.duration) !== this.settings.duration ||
        parseInt(this.data.settings.options) !== (this.settings.animate ? 1 : 0));
    },
    randomness(): string {
      return this.data.tokenData == undefined ? "" : BigInt(this.data.tokenData.randomness).toString(16);
    },
    ...mapState({
        animationTitles: 'animationTitles',
        schemeTitles: 'schemeTitles',
        openseaTokenURL: 'openseaTokenURL',
    }),
    ...mapGetters(["currentAccount"]),
  },
  mounted: async function() {
    await this.$store.dispatch("initialize");
    const t = this as any;
    await t.loadSettings();
    t.isLE = await t.checkLE();
    const leID = (BigInt(t.id) - t.max256 ).toString();
    t.formatedID = t.isLE ? leID : t.id;
    t.$store.state.contracts.tinyboxes.methods.ownerOf(t.id).call()
      .then( (owner: any) => {
        t.owner = owner;
        t.exists = owner > 0;
        t.loadToken();
      })
      .catch( () => {
        t.loading = false;
      });
  },
  methods: {
    async checkLE() {
      return this.$store.state.contracts.tinyboxes.methods.isTokenLE((this as any).id).call();
    },
    async loadSettings() {
      const t = this as any;
      const settings =  await t.$store.state.contracts.tinyboxes.methods.readSettings(t.id).call();
      t.data.settings = settings;
      t.settings = {
        bkg: settings.bkg === "101" ? 0 : settings.bkg,
        duration: settings.duration,
        transparent: settings.bkg === "101",
        animate: settings.options % 2 === 1,
      };
    },
    async saveSettings() {
      const t = this as any;
      const settings = [
        t.settings.transparent ? 101 : t.settings.bkg,
        t.settings.duration,
        t.settings.animate ? 1 : 0
      ];
      t.settingsTX = {
        from: this.currentAccount,
        to: this.$store.state.tinyboxesAddress,
        data: this.$store.state.contracts.tinyboxes.methods
          .changeSettings(t.id, settings)
          .encodeABI(),
      };
      t.$store.state.web3.eth.sendTransaction(t.settingsTX,
        async (err: any, txHash: string) => {
          const t = this as any;
          if (err) t.overlay = err.code === 4001 ? "" : "error";
          else {
            t.txHash = txHash;
            t.loadSettings();
            // push auto metadata refresh on OpenSea
            const refeshEndpoint  = 'https://api.opensea.io/asset/' + this.$store.state.tinyboxesAddress + '/' + this.id + '/?force_update=true';
            await t.$http.get(refeshEndpoint);
          }
        }
      );
    },
    resetSettings() {
      const t = this as any;
      const settings = t.data.settings;
      t.settings = {
        bkg: settings.bkg === "101" ? 0 : settings.bkg,
        duration: settings.duration,
        transparent: settings.bkg === "101",
        animate: settings.options % 2 === 1,
      };
    },
    formatHash(account: string) {
      return "0x" + account.slice(2, 6) + "...." + account.slice(-4);
    },
    formatTopic(account: string) {
      return "0x" + account.slice(26, 30) + "...." + account.slice(-4);
    },
    formatTopicLong(account: string) {
      return "0x" + account.slice(-40);
    },
    gotoMint() {
      const d = this.data.tokenData;
      const values = { ...this.data.tokenData, id: this.id, seed: Date.now(), m1: d.mirroring % 4, m2: (d.mirroring / 4 % 4), m3: (d.mirroring / 16 % 4) };
      this.$router.push({ path: "/create", query: (this as any).buildQuery(values) });
    },
    buildQuery(v: any) {
      const t = this as any;
      // condense keys and values for shorter URL encoding
      const out: any = {
        i: v.id,
        r: v.seed,
        s: [v.shapes, v.hatching].join("-"), // shapes - count, hatching
        d: [[v.size[0], v.size[1]].join("~"), [v.size[2], v.size[3]].join("~")].join("-"), // dimensions ranges
        p: v.spacing.join("-"), // positioning - spread, grid
        c: v.color.join("-"), // color - hue, saturation, luminosity
        m: [v.m1, v.m2, v.m3].join("-") // mirroring levels
      };
      return out;
    },
    loadToken: async function() {
      const t = this as any;
      const cached = this.$store.state.cachedTokens[t.id];
      if (cached && typeof cached === "object") {
        this.data = cached;
        this.loading = false;
      } else {
        // load all token data
        const creationPromise = t.lookupMinting();
        const animationPromise = this.$store.state.contracts.tinyboxes.methods.tokenArt(this.id, this.settings.bkg, this.settings.duration, 1, '').call();
        const artPromise = this.$store.state.contracts.tinyboxes.methods.tokenArt(this.id, this.settings.bkg, this.settings.duration, 0, '').call();
        const tokenDataPromise = this.$store.state.contracts.tinyboxes.methods.tokenData(this.id).call();
        this.data.creation = await creationPromise;
        this.data.tx = await this.$store.state.web3.eth.getTransaction(this.data.creation.transactionHash);
        this.data.block = await this.$store.state.web3.eth.getBlock(this.data.creation.blockNumber);
        this.data.animation = await animationPromise;
        this.data.art = await artPromise;
        this.data.tokenData = await tokenDataPromise;
        // cache token data and end loading
        this.$store.commit("setToken", this.data);
        this.loading = false;
      }
    },
    lookupMinting: function() {
      return new Promise((resolve, reject) => {
        this.$store.state.web3.eth
          .subscribe("logs", {
            address: this.$store.state.tinyboxesAddress,
            fromBlock: 0,
            topics: [
              "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
              "0x0000000000000000000000000000000000000000000000000000000000000000",
              null,
              "0x" + BigInt(this.id as number).toString(16).padStart(64, "0"),
            ],
          })
          .on("data", resolve)
          .on("error", reject);
      });
    },
  },
  data: () => ({
    loading: true,
    exists: false,
    animate: true,
    settingsPane: false,
    isLE: false,
    formatedID: '',
    max256: 115792089237316195423570985008687907853269984665640564039457584007913129639936n,
    settings: {
      bkg: 0,
      duration: 10,
      transparent: true,
      animate: true,
    },
    owner: "",
    data: {} as any,
    settingsTX: null,
    txHash: null,
  }),
});
</script>

<style lang="sass">
.v-chip__content
  span
    color: #FFF !important
.content
  margin-top: 35vh
.copy-btn
  margin-top: 3rem
  justify-content: space-around
.id
  font-size: 2rem
.render-settings
  max-width: 100%
.token-loading
  padding-top: 40vh
.on
  border-style: inset
.token-graphic
  max-height: 90vh
.token-stats
  padding: 1rem
  display: flex
  flex-direction: row,
  justify-content: space-between
.stat
  text-align: -webkit-center
  margin: 0.2rem
  padding: 1rem
  border: 1px solid #ccc
  border-radius: 0.5rem
  width: min-content
  height: min-content
.stat-value
  font-weight: 200
  font-size: 2rem
  margin: 1rem
.stat-title
  margin: 0.5rem 0 -0.5rem 0
  line-height: normal
  display: block
.palette
  display: flex
  flex-direction: column
  align-items: center
.box-story
  font-size: 1.2rem
  line-height: 2rem
.v-card
  margin: 1rem
.timestamp-date
  margin: 1rem
.timestamp-time
  width: max-content
.randomness-chunks, .timestamp .stat-value
  display: flex
  flex-wrap: wrap
  justify-content: center
  width: min-content
  span
    margin: 0.3rem
.stats
  display: flex
  flex-wrap: wrap
  justify-content: space-around
.v-card__text
  width: auto !important
.feature
  margin: 5px
  .v-chip
    border: 1px solid rgba(255,255,255,0.3) !important
    text-shadow: 0px 1px 5px #000000
</style>

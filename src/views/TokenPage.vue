<template lang="pug">
  .token-page
    v-container(fluid)
      v-row
        v-col(align="center").token-title
          h1.title TinyBox {{ id }}
      v-row(v-if="loading")
        v-col(align="center").token-loading
            v-progress-circular(indeterminate size="75" color="primary")
            h1 Fetching Token
      v-row(v-else-if="!exists")
        v-col(align="center").token-missing
          h1 Invalid Token ID
      v-row(v-else no-gutters)
        v-col(cols="12" md="4")
          .palette
            .scheme
              span Scheme
              h2 {{ schemeTitles[data.tokenData.scheme] }}
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
              span.stat-value {{ Math.floor(data.tokenData.mirroring / 16) % 4 }},{{ Math.floor(data.tokenData.mirroring / 4) % 4 }},{{ data.tokenData.mirroring % 4 }}
              .stat-title Mirroring
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
              span.stat-value {{ data.tokenData.spacing[0] }}
              .stat-title Spread
            .rows.stat
              span.stat-value {{ Math.floor(data.tokenData.spacing[1] / 16) }}
              .stat-title Rows
            .columns.stat
              span.stat-value {{ Math.floor(data.tokenData.spacing[1] % 16) }}
              .stat-title Columns
      v-row
        v-col(cols="12")
          v-card
            v-card-title(align="center") Minting Info
            v-card-text
              .stats.minting-stats
                .buttons.d-flex
                  v-btn.my-4(height="3rem" color="secondary" @click="gotoMint") Copy Options
                  a(:href="openseaTokenURL + id" title="View on OpenSea" target="_blank")
                    img(style="width:160px; border-radius:0px; box-shadow: 0px 1px 6px rgba(0, 0, 0, 0.25);" src="https://storage.googleapis.com/opensea-static/opensea-brand/listed-button-blue.png" alt="Listed on OpenSea badge")
                .timestamp.stat(v-if="data.block !== undefined")
                  .stat-value
                    span.timestamp-time {{ (new Date(data.block.timestamp)).toLocaleTimeString() }}
                    span.timestamp-date {{ (new Date(data.block.timestamp)).toLocaleDateString() }}
                  .stat-title Minted Timestamp
                .minter.stat(v-if="data.creation !== undefined && data.creation.topics.length > 0")
                  .stat-value
                    v-tooltip(top)
                        template(v-slot:activator='{ on }')
                          span(v-on='on') {{ formatTopic(data.creation.topics[2]) }}
                        span {{ formatTopicLong(data.creation.topics[2]) }}
                  .stat-title Creator
                .tx-hash.stat(v-if="data.creation !== undefined")
                  .stat-value
                    v-tooltip(top)
                      template(v-slot:activator='{ on }')
                        a(v-on='on' :href="'https://rinkeby.etherscan.io/tx/' + data.creation.transactionHash" target="_blank") {{ formatHash(data.creation.transactionHash) }}
                      span View on Etherscan
                  .stat-title TX Hash
      v-row(v-if="ownerOf")
        v-col(cols="12")
          v-sheet
            v-expansion-panels(v-model="settings" tile)
              v-expansion-panel(expand ripple)
                  v-expansion-panel-header
                    .hi(align="center") Render Settings
                  v-expansion-panel-content
                    v-container(no-gutters)
                      v-row
                        v-col(cols="12" align="center")
                          p Set default render settings for your token
                      v-row
                        v-col(cols="12" md="8")
                          .settings
                            v-slider(label="Background" thumb-label min="0" max="100")
                            v-slider(label="Duration" thumb-label min="1" max="255")
                        v-col(cols="12" md="4")
                          v-switch( label="Transparent Bkg")
                          v-switch( label="Animate")
                      v-row
                        v-col(cols="12")
                          .d-flex
                            v-btn Download SVG
                            v-spacer
                            v-btn(color="success") Save
                            v-btn(color="warning") Reset
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
    id(): number {
      return parseInt(this.$route.params.id);
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
    t.$store.state.contracts.tinyboxes.methods.ownerOf(t.id).call()
    .then( (owner: any) => {
      t.owner = owner;
      t.exists = owner > 0;    
      t.loadToken();
      t.loadSettings();
    })
    .catch( () => {
      t.loading = false;
    });
  },
  methods: {
    async loadSettings() {
      const t = this as any;
      if (t.ownerOf) console.log(await t.$store.state.contracts.tinyboxes.methods.readSettings(t.id).call());
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
      const values = { ...this.data.tokenData, seed: Date.now(), m1: d.mirroring % 4, m2: (d.mirroring / 4 % 4), m3: (d.mirroring / 16 % 4) };
      this.$router.push({ path: "/create", query: (this as any).buildQuery(values) });
    },
    buildQuery(v: any) {
      const t = this as any;
      // condense keys and values for shorter URL encoding
      const out: any = {
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
        const animationPromise = this.$store.state.contracts.tinyboxes.methods.tokenArt(this.id, 5, 0, 1).call();
        const artPromise = this.$store.state.contracts.tinyboxes.methods.tokenArt(this.id, 5, 0, 0).call();
        const tokenDataPromise = this.$store.state.contracts.tinyboxes.methods.tokenData(this.id).call();
        this.data.creation = await creationPromise;
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
              "0x" + (this.id as number).toString(16).padStart(64, "0"),
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
    settings: false,
    owner: "",
    data: {} as any,
  }),
});
</script>

<style lang="sass">
.v-chip__content
  span
    color: #FFF !important
.content
  margin-top: 35vh
.buttons
  flex-direction: column
.id
  font-size: 2rem
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

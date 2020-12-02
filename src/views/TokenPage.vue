<template lang="pug">
  .token-page
    v-container(fluid)
      v-row
        v-col(align="center").token-title
          h1.title Token {{ id }}
      v-row(v-if="loading")
        v-col(align="center").token-loading
            v-progress-circular(indeterminate size="75" color="primary")
            h1 Fetching Token {{ "#" + id }}
      v-row(v-else no-gutters)
        v-col(cols="12" md="6" lg="5" offset-lg="1")
          v-card
            Token(:id="id" :data="animate ? data.animation : data.art").token-graphic
            v-card-actions
              v-tooltip(right)
                template(v-slot:activator='{ on }')
                  v-btn(icon large v-on='on' @click="animate = !animate" v-bind:class="[animate ? 'on' : 'off']").animate-toggle
                    v-icon mdi-animation
                span Toggle Animation
              v-spacer
              a(href="https://opensea.io/" title="View on OpenSea" target="_blank")
                img(style="width:160px; border-radius:0px; box-shadow: 0px 1px 6px rgba(0, 0, 0, 0.25);" src="https://storage.googleapis.com/opensea-static/opensea-brand/listed-button-blue.png" alt="Listed on OpenSea badge")
            v-card-text 
              h2 Minting Info
              .minting-stats
                .timestamp.stat
                  .stat-value
                    span.timestamp-time {{ (new Date(data.block.timestamp)).toLocaleTimeString() }}
                    span.timestamp-date {{ (new Date(data.block.timestamp)).toLocaleDateString() }}
                  .stat-title Minted Timestamp
                .price.stat
                  .stat-value
                    v-icon mdi-ethereum
                    span {{ priceInETH }}
                  .stat-title Minted Price
                .minter.stat
                  .stat-value
                    v-tooltip(top)
                        template(v-slot:activator='{ on }')
                          span(v-on='on') {{ formatTopic(data.creation.topics[2]) }}
                        span {{ formatTopicLong(data.creation.topics[2]) }}
                  .stat-title Creator
                .tx-hash.stat
                  .stat-value
                    v-tooltip(top)
                      template(v-slot:activator='{ on }')
                        a(v-on='on' :href="'https://rinkeby.etherscan.io/tx/' + data.creation.transactionHash") {{ formatHash(data.creation.transactionHash) }}
                      span View on Etherscan
                  .stat-title TX Hash
              .randomness.stat
                  .stat-value
                    .randomness-chunks
                      template(v-for="chunk in randomness.match(/.{1,16}/g)")
                        span.randomness-chunk {{ chunk }}
                  .stat-title Randomness
        v-col(cols="12" md="6" lg="5")
          v-card
            v-card-title(align="center")
              h2 Token Stats
            v-card-text
              .stats
                h2 Shapes
                .shapes
                  .shapeCount.stat
                    span.stat-value {{ data.tokenData.shapes }}
                    .stat-title Shapes
                  .hatching.stat
                    span.stat-value {{ data.tokenData.hatching }}
                    .stat-title Hatching Mod
                  .width.stat
                    span.stat-value {{ data.tokenData.size[0] + '-' + data.tokenData.size[1] }}
                    .stat-title Width
                  .height.stat
                    span.stat-value {{ data.tokenData.size[2] + '-' + data.tokenData.size[3] }}
                    .stat-title Height
                h2 Placement
                .position
                  .spread-x.stat
                    span.stat-value {{ data.tokenData.spacing[0] }}
                    .stat-title Spread X
                  .spread-y.stat
                    span.stat-value {{ data.tokenData.spacing[1] }}
                    .stat-title Spread Y
                  .rows.stat
                    span.stat-value {{ data.tokenData.spacing[2] }}
                    .stat-title Rows
                  .columns.stat
                    span.stat-value {{ data.tokenData.spacing[3] }}
                    .stat-title Columns
                h2 Colors
                .colors
                  .colors-grid
                    svg(:width="(3*(parseInt(data.tokenData.palette[5])+1)) + 'em'" :height="(3*(scheme(data.tokenData.palette[4]).length)) + 'em'")
                      g(v-for="h,i of scheme(data.tokenData.palette[4])")
                        rect(v-for="s in parseInt(data.tokenData.palette[5])+1" :x="3*(s-1)+'em'" :y="3*i+'em'" width="3em" height="3em"
                          :style="'fill: hsl('+(parseInt(data.tokenData.palette[0])+h)+','+data.tokenData.palette[1]+'%,'+calcShade(s-1)+'%)'")
                  .colors-info
                    .hue.stat
                      span.stat-value {{ data.tokenData.palette[0] + '°' }} 
                      .stat-title Root Hue
                    .saturation.stat
                      span.stat-value {{ data.tokenData.palette[1] + '%' }}
                      .stat-title Saturation
                    .lightness.stat
                      span.stat-value {{ data.tokenData.palette[2] + '-' + data.tokenData.palette[3] + '%' }}
                      .stat-title Lightness
                    .shades.stat
                      span.stat-value {{ data.tokenData.palette[5] }}
                      .stat-title Shades
                    .scheme.stat
                      span.stat-value {{ "" + data.tokenData.palette[4] + ' - ' + schemeTitles[data.tokenData.palette[4]] }}
                      .stat-title Scheme
                h2 Mirroring
                .mirroring
                  .mirror-a.stat
                    span.stat-value {{ data.tokenData.mirrorPositions[0] }}
                    .stat-title A
                  .mirror-b.stat
                    span.stat-value {{ data.tokenData.mirrorPositions[1] }}
                    .stat-title B
                  .mirror-c.stat
                    span.stat-value {{ data.tokenData.mirrorPositions[2] }}
                    .stat-title C
                  .scale.stat
                    span.stat-value {{ data.tokenData.scale + "%" }}
                    .stat-title Scale
                h2 Animation
                .advanced
                  .animation.stat
                    span.stat-value {{ "#" + data.tokenData.animation }}
                    .stat-title ID
                  .animation-title.stat
                    span.stat-value {{ animationTitles[data.tokenData.animation] }}
                    .stat-title Title
</template>

<script lang="ts">
import Vue from "vue";
import { mapGetters, mapState } from "vuex";
import Token from "@/components/Token.vue";
import { log } from 'util';

export default Vue.extend({
  name: "TokenPage",
  components: { Token },
  computed: {
    priceInETH: function() {
      return this.$store.state.web3.utils.fromWei((this as any).data.price.toString());
    },
    id(): number {
      return parseInt(this.$route.params.id);
    },
    randomness(): string {
      return BigInt(this.data.tokenData.randomness).toString(16);
    },
    ...mapState({
        animationTitles: 'animationTitles',
        schemeTitles: 'schemeTitles',
    }),
    ...mapGetters(["currentAccount"]),
  },
  mounted: async function() {
    await this.$store.dispatch("initialize");
    await (this as any).loadToken();
  },
  methods: {
    calcShade(s: number) {
      const range = this.data.tokenData.palette[3] - this.data.tokenData.palette[2];
      const step = (range / this.data.tokenData.palette[5]);
      const shade = parseInt(this.data.tokenData.palette[3]) - (step * s);
      return shade;
    },
    scheme(i: number) {
      const schemes = [
            [0], // mono
            [0, 180], // complimentary
            [0, 30, 330], // analogous
            [0, 30, 60, 90], // series
            [0, 150, 210], // split complimentary
            [0, 120, 240], // triadic
            [0, 150, 180, 210], // complimentary and analogous
            [0, 30, 180, 330], // analogous and complimentary
            [0, 90, 180, 270], // square
            [0, 60, 180, 240] // tetradic
        ];
      return schemes[i];
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
    loadToken: async function() {
      const t = this as any;
      const cached = this.$store.state.cachedTokens[t.id];
      if (cached && typeof cached === "object") {
        this.data = cached;
        this.loading = false;
      } else {
        // load all token data
        this.data.creation = (await t.lookupMinting()) as any;
        this.data.animation = await this.$store.state.contracts.tinyboxes.methods
          .tokenArt(this.id, true)
          .call();
        this.data.art = await this.$store.state.contracts.tinyboxes.methods
          .tokenArt(this.id, false)
          .call();
        this.data.tokenData = await this.$store.state.contracts.tinyboxes.methods
          .tokenData(this.id)
          .call();
        this.data.price = await this.$store.state.contracts.tinyboxes.methods.priceAt(
          this.id
        ).call();
        this.data.block = await this.$store.state.web3.eth.getBlock(
          this.data.creation.blockNumber
        );

        // cache token data and end loading
        this.$store.commit("setToken", { id: this.id, data: this.data });
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
    animate: true,
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
.id
  font-size: 2rem
.token-loading
  padding-top: 40vh
.on
  border-style: inset
.token-stats
  padding: 1rem
  display: flex
  flex-direction: row,
  justify-content: space-between
.stat
  text-align: -webkit-center
  margin-top: 1rem
.stat-value
  font-weight: 200
  font-size: 2rem
  padding: 0.5rem 1rem
  border: 1px solid #ccc
  border-radius: 0.5rem
.stat-title
  margin: 1rem 0
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
.colors-grid svg g
  width: 100%
.colors-info
  display: flex
  flex-wrap: wrap
  justify-content: space-around
.shapes, .position, .mirroring, .advanced, .minting-stats, .colors
  display: flex
  flex-wrap: wrap
  justify-content: space-around
  p
    margin-top: 0
.v-card__text
  width: auto !important
.feature
  margin: 5px
  .v-chip
    border: 1px solid rgba(255,255,255,0.3) !important
    text-shadow: 0px 1px 5px #000000
</style>

<template lang="pug">
  .token-page
    v-container(fluid)
      v-row(v-if="loading")
        v-col(align="center").token-loading
            v-progress-circular(indeterminate size="75" color="primary")
            h1 Fetching Token {{ "#" + id }}
      v-row(v-else no-gutters)
        v-col(cols="12" md="6" lg="5" offset-lg="1")
          v-card
            v-card-title(align="center")
              h2 Token {{ id }}
            Token(:id="id" :data="data.art").token-graphic
            v-card-text.creation
              h2(align="center") Minted
              .minting-stats
                p At {{ (new Date(data.block.timestamp)).toLocaleTimeString() }} On {{ (new Date(data.block.timestamp)).toLocaleDateString() }}
                p In Block # {{ data.creation.blockNumber }}
                p For {{ priceInETH }} 
                  v-icon mdi-ethereum
              .minting-stats
                p By Address 
                  a(:href="'https://rinkeby.etherscan.io/address/' + data.creation.address") {{ formatHash(data.creation.address) }}
                p With TX 
                  a(:href="'https://rinkeby.etherscan.io/tx/' + data.creation.transactionHash") {{ formatHash(data.creation.transactionHash) }}
        v-col(cols="12" md="6" lg="5")
          v-card.token-properties
            v-card-title(align="center")
              h2 Stats
            v-card-text
              .stats
                h3 Counts
                .counts
                  p {{ data.counts[0] }} Colors
                  p {{ data.counts[1] }} Shapes
                h3 Size
                .size
                  p Width: {{ data.dials[4] }} to {{ data.dials[5] }}
                  p Height: {{ data.dials[6] }} to {{ data.dials[7] }}
                h3 Position
                .position
                  p Spread: {{ data.dials[0] }} X {{ data.dials[1] }} Y
                  p {{ data.dials[2] }} Rows
                  p {{ data.dials[3] }} Columns
                h3 Advanced
                .advanced
                  p Seed: {{ data.seed }}
                  p Hatching Mod: {{ data.dials[8] }}
                  p {{ data.dials[12] + "%" }} Scale
                h3 Mirroring
                .mirroring
                  p {{ data.dials[9] }}
                    v-icon {{ data.switches[0] ? "mdi-checkbox-marked-outline" : "mdi-checkbox-blank-outline" }}
                  p {{ data.dials[10] }}
                    v-icon {{ data.switches[1] ? "mdi-checkbox-marked-outline" : "mdi-checkbox-blank-outline" }}
                  p {{ data.dials[11] }}
                    v-icon {{ data.switches[2] ? "mdi-checkbox-marked-outline" : "mdi-checkbox-blank-outline" }}
            v-card-actions.opensea
              v-spacer
              v-btn(large target="_blank" color="primary" href="//opensea.io") View on OpenSea
    
</template>

<script lang="ts">
import Vue from "vue";
import { mapGetters } from "vuex";
import Token from "@/components/Token.vue";
import { tinyboxesAddress } from "../tinyboxes-contract";

export default Vue.extend({
  name: "TokenPage",
  components: { Token },
  computed: {
    priceInETH: function() {
      return this.$store.state.web3.utils.fromWei((this as any).data.price);
    },
    id(): number {
      return parseInt(this.$route.params.id);
    },
    ...mapGetters(["currentAccount"])
  },
  mounted: async function() {
    await this.$store.dispatch("initialize");
    await (this as any).loadToken();
  },
  methods: {
    formatHash(account: string) {
      return "0x" + account.slice(2, 6) + "...." + account.slice(-4);
    },
    loadToken: async function() {
      const t = this as any;
      const cached = this.$store.state.cachedTokens[t.id];
      if (cached) {
        this.data = cached;
        this.loading = false;
      } else {
        // load all token data
        this.data.creation = (await t.lookupMinting()) as any;
        this.data.art = await this.$store.state.contracts.tinyboxes.methods
          .tokenArt(this.id)
          .call();
        this.data.seed = await this.$store.state.contracts.tinyboxes.methods
          .tokenSeed(this.id)
          .call();
        this.data.price = await this.$store.state.contracts.tinyboxes.methods
          .priceAt(this.id)
          .call();
        this.data.counts = await this.$store.state.contracts.tinyboxes.methods
          .tokenCounts(this.id)
          .call();
        this.data.dials = await this.$store.state.contracts.tinyboxes.methods
          .tokenDials(this.id)
          .call();
        this.data.switches = await this.$store.state.contracts.tinyboxes.methods
          .tokenSwitches(this.id)
          .call();
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
            address: tinyboxesAddress,
            fromBlock: 0,
            topics: [
              "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
              "0x0000000000000000000000000000000000000000000000000000000000000000",
              null,
              "0x" + (this.id as number).toString(16).padStart(64, "0")
            ]
          })
          .on("data", resolve)
          .on("error", reject);
      });
    }
  },
  data: () => ({
    loading: true,
    data: {} as any
  })
});
</script>

<style lang="sass" scoped>
.v-chip__content
  span
    color: #FFF !important
.content
  margin-top: 35vh
.id
  font-size: 2rem
.token-loading
  padding-top: 40vh
.token-properties
  padding: 1rem
.token-stats
  padding: 1rem
  display: flex
  flex-direction: row,
  justify-content: space-between
.v-card 
  margin: 1rem
.mirroring, .advanced, .counts, .position, .size, .minting-stats
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

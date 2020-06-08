<template lang="pug">
  .token-page
    v-container
      v-row(v-if="loading")
        v-col(align="center").token-loading
            v-progress-circular(indeterminate size="75" color="primary")
            h1 Fetching Token {{ "#" + id }}
      v-row(v-else)
        v-col(align="center")
          v-card
            .token-stats
              h1 Token {{ id }}
            v-divider
            .token-graphic
              Token(:id="id" :data="data.art")
        v-col
          v-sheet.token-properties
            h1 Token Properties
            .creation
              p Created By: {{ data.creation.address }}
              p With Tx:
              a(:href="'https://rinkeby.etherscan.io/tx/' + data.creation.transactionHash")
                span {{ data.creation.transactionHash }}
                v-icon mdi-open-in-new
              p In Block: {{ data.creation.blockNumber }}
            .counts
            .dials
            .switches
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
    id(): number {
      return parseInt(this.$route.params.id);
    },
    ...mapGetters(["currentAccount"])
  },
  mounted: async function() {
    await this.$store.dispatch("initialize");
    await this.loadToken();
  },
  methods: {
    loadToken: async function() {
      const cached = this.$store.state.cachedTokens[this.id];
      if (cached) {
        this.data = cached;
        this.loading = false;
      } else {
        // load all token data
        this.data.creation = (await this.lookupMinting()) as any;
        this.data.art = await this.$store.state.contracts.tinyboxes.methods
          .tokenArt(this.id)
          .call();
        this.data.counts = await this.$store.state.contracts.tinyboxes.methods
          .tokenCounts(this.id)
          .call();

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
              "0x" + this.id.toString(16).padStart(64, "0")
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
  margin: 1rem 0
.token-stats
  padding: 1rem
  display: flex
  flex-direction: row,
  justify-content: space-between
.features
  margin: 2vh 1vw
  display: flex
  flex-wrap: wrap
.feature
  margin: 5px
  .v-chip
    border: 1px solid rgba(255,255,255,0.3) !important
    text-shadow: 0px 1px 5px #000000
</style>

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
              Token(:id="id" :data="data")
        v-col
          v-sheet.token-properties
            h1 Token Properties
            .property(v-for="p in properties" :key="p.title")
              h4 {{ p.title }}
              span {{ p.value }}
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
    loadToken: function() {
      const cached = this.$store.state.cachedTokens[this.id];
      if (cached) {
        this.data = cached;
        this.loading = false;
      } else {
        this.$store.state.contracts.tinyboxes.methods
          .tokenArt(this.id)
          .call()
          .then((result: any) => {
            this.$store.commit("setToken", { id: this.id, data: result });
            this.data = result;
            this.loading = false;
          })
          .catch((err: any) => {
            console.error(err);
          });
      }
      this.$store.state.contracts.tinyboxes.methods
        .tokenCounts(this.id)
        .call()
        .then((result: any) => {
          const colors: any = { title: "Color Counts: ", value: result[0] };
          this.properties.push(colors as never);
          const shapes: any = { title: "Shape Counts: ", value: result[1] };
          this.properties.push(shapes as never);
        })
        .catch((err: any) => {
          console.error(err);
        });
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
        .on("data", (log: any) => {
          const t = this as any;
          const creator = log.topics[2];
          const newProp: any = { title: "Creator", value: creator };
          this.properties.push(newProp as never);
        });
    }
  },
  data: () => ({
    loading: true,
    data: {} as object,
    properties: []
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

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
          h1 Token Info
            h4 Owner: 0x27af......0cb0
            h4 Minted: 
            h4 Last Transfered:
          h1 Token Properties
            .token-properties
              v-sheet.property(v-for="p in properties" :key="p.title")
                h2 {{ p.value }}
                h4 {{ p.title }}
          h1 OpenSea
            v-btn(large target="_blank" href="//opensea.io") View on OpenSea
    
</template>

<script lang="ts">
import Vue from "vue";
import { mapGetters } from "vuex";
import Token from "@/components/Token.vue";

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
          .ownerOf(this.id)
          .call()
          .then((result: any) => {
            this.$store.commit("setToken", { id: this.id, data: result });
            this.data = result;
            this.loading = false;
          })
          .catch( (err: any) => {
            console.error(err);
          });
      }
    }
  },
  data: () => ({
    loading: true,
    data: {} as object,
    properties: [
      {
        title: "Shape Count",
        value: 11
      },
      {
        title: "Color Count",
        value: 21
      }
    ]
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
.token-stats
  padding: 1rem
  display: flex
  flex-direction: row
  justify-content: space-between
.token-properties
  padding: 0 1rem 1rem 1rem
.features
  margin: 2hv 1vw
  display: flex
  flex-wrap: wrap
.feature
  margin: 5px
  .v-chip
    border: 1px solid rgba(255,255,255,0.3) !important
    text-shadow: 0px 1px 5px #000000
</style>

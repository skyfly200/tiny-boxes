<template lang="pug">
  .token-creator
    v-container
      v-row
        v-col(align="center")
          v-card
            v-card-title.token-stats
              h1 Token {{ "#" + id }}
            v-divider
            v-card-text.token-graphic
              Token(:id="id" :data="data")
            v-card-actions
              v-btn(@click="loadToken") Preview
              v-spacer
              v-btn(@click="") Mint
        v-col
          h1 Create a TinyBox
          v-form(v-model="valid").create-form
            v-text-field(v-model="seed" outlined label="RNG Seed" required)
            h3 Counts
            .counts
              v-slider(v-model="counts[0]" thumb-label label="Color Count" required)
              v-slider(v-model="counts[1]" thumb-label label="Shape Count" required)
            .dials
              h3 Position
              .position
                v-text-field(v-model="dials[0]" outlined label="X Position" required)
                v-text-field(v-model="dials[1]" outlined label="Y Position" required)
              h3 Size
              v-slider(v-model="dials[2]" thumb-label label="Width" required)
              v-slider(v-model="dials[4]" thumb-label label="Height" required)
              h3 Variation
              v-slider(v-model="dials[3]" thumb-label label="Width Variation" required)
              v-slider(v-model="dials[5]" thumb-label label="Height Variation" required)
              h3 Other
              v-slider(v-model="dials[6]" thumb-label label="Density" required)
    
</template>

<script lang="ts">
import Vue from "vue";
import { mapGetters } from "vuex";
import Token from "@/components/Token.vue";

export default Vue.extend({
  name: "Create",
  components: { Token },
  computed: {
    ...mapGetters(["currentAccount"])
  },
  mounted: async function() {
    await this.$store.dispatch("initialize");
    await this.loadToken();
  },
  methods: {
    getNext: function() {
      this.$store.state.contracts.tinyboxes.methods.totalSupply().call()
        .then((total: number) => {
          this.id = total;
          this.id++
        });
    },
    loadToken: async function() {
      await this.getNext();
      this.$store.state.contracts.tinyboxes.methods.perpetualRender(this.id, this.seed, this.counts, this.dials)
        .call()
        .then((result: any) => {
          this.data = result;
          this.loading = false;
        })
        .catch( (err: any) => {
          console.error(err);
        });
    }
  },
  data: () => ({
    loading: true,
    data: null as (null | object),
    valid: true,
    id: 0,
    seed: 1234567890,
    counts: [7,11],
    dials: [200,200,200,200,200,200,7]
  })
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
  .position
    display: flex
    .v-input
      margin: 0 15px !important
  .theme--dark.v-input
    margin: 0 15px
    input, textarea
      color: #121212
      background-color: #121212
      border: none
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

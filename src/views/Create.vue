<template lang="pug">
  .token-creator
    v-container
      v-row
        v-col(align="center")
          v-card
            .token-stats
              h1 Token {{ id }}
            v-divider
            .token-graphic
              Token(:id="id" :data="data")
        v-col
          h1 Create a TinyBox
          v-form(v-model="valid").create-form
            v-text-field(v-model="seed" outlined label="Seed" required)
            h3 Counts
            .counts
              v-text-field(v-model="counts[0]" outlined label="Color Count" required)
              v-text-field(v-model="counts[1]" outlined label="Shape Count" required)
            h3 Dials
            .dials
              v-text-field(v-model="dials[0]" outlined label="X Position" required)
              v-text-field(v-model="dials[1]" outlined label="Y Position" required)
              v-text-field(v-model="dials[2]" outlined label="Width" required)
              v-text-field(v-model="dials[3]" outlined label="Width Variation" required)
              v-text-field(v-model="dials[4]" outlined label="Height" required)
              v-text-field(v-model="dials[5]" outlined label="Height Variation" required)
              v-text-field(v-model="dials[6]" outlined label="Density" required)
            .form-buttons
              v-btn(@click="loadToken") Preview
              v-spacer
              v-btn(@click="") Mint
    
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
    padding-top: 40vh
  .theme--dark.v-input input, .theme--dark.v-input textarea
    color: #121212
    background-color: #121212
    border: none
  .form-buttons
    display: flex
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

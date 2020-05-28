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
              v-btn(@click="mintToken") Mint
        v-col
          h1 Create a TinyBox
          v-form(v-model="valid").create-form
            .section(v-for="section of sections" :key="section.title")
              h3 {{ section.title }}
              v-slider(v-for="option of section.options" v-model="values[option.key]" thumb-label :label="option.label" required :min="option.min" :max="option.max")
                template(v-slot:append)
                  v-text-field(v-model="values[option.key]" hide-details single-line type="number" style="width: 60px")
    
</template>

<script lang="ts">
import Vue from "vue";
import { mapGetters } from "vuex";
import { tinyboxesAddress } from "../tinyboxes-contract";
import Token from "@/components/Token.vue";

export default Vue.extend({
  name: "Create",
  components: { Token },
  computed: {
    ...mapGetters(["currentAccount"])
  },
  mounted: async function() {
    await this.$store.dispatch("initialize");
    await this.getNext();
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
      const v = this.values;
      const counts = [v.colors, v.shapes];
      const dials = [v.x, v.y, v.width, v.widthVariance, v.height, v.heightVariance, v.density, v.mirror1, v.mirror2, v.mirror3];
      this.$store.state.contracts.tinyboxes.methods.perpetualRender(this.id, v.seed, counts, dials)
        .call()
        .then((result: any) => {
          this.data = result;
          this.loading = false;
        })
        .catch( (err: any) => {
          console.error(err);
        });
    },
    mintToken: async function() {
      const v = this.values;
      const counts = [v.colors, v.shapes];
      const dials = [v.x, v.y, v.width, v.widthVariance, v.height, v.heightVariance, v.density, v.mirror1, v.mirror2, v.mirror3];
      // TODO: look up dynamic price here and use for tx
      this.$store.state.web3.eth.sendTransaction({
        from: this.currentAccount,
        to: tinyboxesAddress,
        value: this.$store.state.web3.utils.toWei("300", "finney"),
        data: this.$store.state.contracts.tinyboxes.methods
          .createBoxes(v.seed, counts, dials)
          .encodeABI()
      });
      // TODO: redirect to detyails page on new token transmited event
      //this.listenForTokens();
    }
  },
  data: function() {
    return {
      loading: true,
      data: null as (null | object),
      valid: true,
      id: 0,
      values: {
        seed: 1234,
        colors: 7,
        shapes: 11,
        x: 200,
        y: 200,
        width: 200,
        height: 200,
        widthVariance: 200,
        heightVariance: 200,
        mirror1: 1300,
        mirror2: 2200,
        mirror3: 2400,
        density: 7
      },
      sections: [
        {
          title: "RNG",
          options: [
            {
              label: "Seed",
              key: "seed",
              type: "",
              min: 0,
              max: 6800
            }
          ]
        },
        {
          title: "Counts",
          options: [
            {
              label: "Colors",
              key: "colors",
              type: "number",
              min: 1,
              max: 100
            },
            {
              label: "Shapes",
              key: "shapes",
              type: "number",
              min: 1,
              max: 77
            }
          ]
        },
        {
          title: "Position",
          options: [
            {
              label: "X",
              key: "x",
              type: "number",
              min: 0,
              max: 500
            },
            {
              label: "Y",
              key: "y",
              type: "number",
              min: 0,
              max: 500
            }
          ]
        },
        {
          title: "Size",
          options: [
            {
              label: "Width",
              key: "width",
              type: "number",
              min: 1,
              max: 500
            },
            {
              label: "Height",
              key: "height",
              type: "number",
              min: 1,
              max: 500
            }
          ]
        },
        {
          title: "Variance",
          options: [
            {
              label: "Width",
              key: "widthVariance",
              type: "number",
              min: 0,
              max: 500
            },
            {
              label: "Height",
              key: "heightVariance",
              type: "number",
              min: 0,
              max: 500
            }
          ]
        },
        {
          title: "Mirror",
          options: [
            {
              label: "Mirror 1",
              key: "mirror1",
              type: "number",
              min: 0,
              max: 5000
            },
            {
              label: "Mirror 2",
              key: "mirror2",
              type: "number",
              min: 0,
              max: 5000
            },
            {
              label: "Mirror 3",
              key: "mirror3",
              type: "number",
              min: 0,
              max: 5000
            }
          ]
        },
        {
          title: "Other",
          options: [
            {
              label: "Density",
              key: "density",
              type: "number",
              min: 1,
              max: 25
            }
          ]
        }
      ]
    }
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

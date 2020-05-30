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
              v-fade-transition(mode="out-in")
                v-skeleton-loader(v-if="loading" tile type="image")
                Token(v-else :id="id" :data="data")
            v-card-actions
              h2 {{ priceInETH }}
                v-icon(large) mdi-ethereum
              v-spacer
              v-btn(@click="mintToken" :disabled="!valid") Mint
        v-col
          h1 Create your TinyBox
          v-form(v-model="valid").create-form
            .form-buttons
              v-btn(@click="update()" :disabled="!valid") Preview 
              v-spacer
              v-btn(@click="loadFormDefaults(); update()") Reset
            .section(v-for="section of active" :key="section.title")
              h3 {{ section.title }}
              template(v-for="option of section.options")
                template(v-if="!option.hide || values[option.hide]")
                  v-slider(v-if="option.type === 'slider'" v-model="values[option.key]" @change="update" :step="option.step" thumb-label :label="option.label" dense required :min="option.min" :max="option.max")
                    template(v-slot:append)
                      v-text-field(v-model="values[option.key]" @change="update" hide-details single-line type="number" style="width: 60px").slider-text-field
                  v-range-slider(v-else-if="option.type === 'range-slider'" v-model="values[option.key]" @change="update" :step="option.step" thumb-label :label="option.label" dense required :min="option.min" :max="option.max")
                    template(v-slot:prepend)
                      v-text-field(v-model="values[option.key][0]" @change="update" hide-details single-line type="number" style="width: 60px").slider-text-field
                    template(v-slot:append)
                      v-text-field(v-model="values[option.key][1]" @change="update" hide-details single-line type="number" style="width: 60px").slider-text-field
                  v-switch(v-else-if="option.type === 'switch'" v-model="values[option.key]" @change="update" :label="option.label")
                  v-text-field(v-else v-model="values[option.key]" @change="update" :label="option.label" required outlined type="number")
</template>

<script lang="ts">
import Vue from 'vue'
import { mapGetters } from 'vuex'
import { tinyboxesAddress } from '../tinyboxes-contract'
import Token from '@/components/Token.vue'

export default Vue.extend({
  name: 'Create',
  components: { Token },
  computed: {
    priceInETH: function () {
      return this.$store.state.web3.utils.fromWei(this.price)
    },
    active: function () {
      return this.sections.map((s: any) => {
        s.options.filter((o: any) => !o.hide || this.values[o.hide])
        return s
      })
    },
    ...mapGetters(['currentAccount']),
  },
  mounted: async function () {
    this.loadFormDefaults()
    await this.$store.dispatch('initialize')
    this.updater = setInterval(this.updateStatus, 15000)
  },
  destroyed: function () {
    clearInterval(this.updater)
  },
  methods: {
    update(): function() {
      this.updateStatus();
      if(this.valid) this.loadToken();
    },
    updateStatus: async function () {
      await this.getNext()
      await this.getPrice()
    },
    getNext: function () {
      new Promise((resolve, reject) => {
        this.$store.state.contracts.tinyboxes.methods
          .totalSupply()
          .call()
          .then((total: number) => {
            this.id = total
            this.id++
            resolve()
          })
      })
    },
    getPrice: function () {
      new Promise((resolve, reject) => {
        this.$store.state.contracts.tinyboxes.methods
          .currentPrice()
          .call()
          .then((price: number) => {
            this.price = price
          })
      })
    },
    loadFormDefaults: function () {
      Object.assign(this.values, this.defaults)
    },
    loadToken: async function () {
      this.loading = true
      await this.getNext()
      const v = this.values
      const counts = [v.colors, v.shapes]
      const dials = [
        v.x,
        v.y,
        v.xSeg,
        v.ySeg,
        v.width[1],
        v.width[1],
        v.height[0],
        v.height[1],
        v.hatching,
        v.mirrorPos1,
        v.mirrorPos2,
        v.mirrorPos3,
        v.scale * 100,
      ]
      const switches = [v.mirror1, v.mirror2, v.mirror3]
      this.$store.state.contracts.tinyboxes.methods
        .perpetualRenderer(this.id, v.seed, counts, dials, switches)
        .call()
        .then((result: any) => {
          this.data = result
          this.loading = false
        })
        .catch((err: any) => {
          console.error(err)
        })
    },
    mintToken: async function () {
      const v = this.values
      const counts = [v.colors, v.shapes]
      const dials = [
        v.x,
        v.y,
        v.xSeg,
        v.ySeg,
        v.width[1],
        v.width[1],
        v.height[0],
        v.height[1],
        v.hatching,
        v.mirrorPos1,
        v.mirrorPos2,
        v.mirrorPos3,
        v.scale * 100,
      ]
      const switches = [v.mirror1, v.mirror2, v.mirror3]
      await this.updateStatus() // return promise here
      this.$store.state.web3.eth.sendTransaction({
        from: this.currentAccount,
        to: tinyboxesAddress,
        value: this.price,
        data: this.$store.state.contracts.tinyboxes.methods
          .createBox(v.seed, counts, dials, switches)
          .encodeABI(),
      })
      // TODO: redirect to details page on new token transmited event
      //this.listenForTokens();
    },
  },
  data: function () {
    return {
      loading: true,
      data: null as null | object,
      updater: null as any,
      valid: true,
      id: 0,
      price: '160000000000000000',
      values: {} as any,
      defaults: {
        seed: 1234,
        colors: 7,
        shapes: 11,
        x: 200,
        y: 200,
        xSeg: 2,
        ySeg: 2,
        width: [200, 200],
        height: [200, 200],
        hatching: 0,
        mirror1: true,
        mirror2: true,
        mirror3: true,
        mirrorPos1: 1300,
        mirrorPos2: 2200,
        mirrorPos3: 2400,
        scale: 1,
      },
      sections: [
        {
          title: 'RNG',
          options: [
            {
              label: 'Seed',
              key: 'seed',
              type: 'slider',
              min: 0,
              max: 6800,
            },
          ],
        },
        {
          title: 'Counts',
          options: [
            {
              label: 'Colors',
              key: 'colors',
              type: 'slider',
              min: 1,
              max: 100,
            },
            {
              label: 'Shapes',
              key: 'shapes',
              type: 'slider',
              min: 1,
              max: 77,
            },
          ],
        },
        {
          title: 'Position',
          options: [
            {
              label: 'X',
              key: 'x',
              type: 'slider',
              min: 0,
              max: 500,
            },
            {
              label: 'Y',
              key: 'y',
              type: 'slider',
              min: 0,
              max: 500,
            },
            {
              label: 'Columns',
              key: 'xSeg',
              type: 'slider',
              min: 1,
              max: 50,
            },
            {
              label: 'Rows',
              key: 'ySeg',
              type: 'slider',
              min: 1,
              max: 50,
            },
          ],
        },
        {
          title: 'Size',
          options: [
            {
              label: 'Width',
              key: 'width',
              type: 'range-slider',
              min: 1,
              max: 500,
            },
            {
              label: 'Height',
              key: 'height',
              type: 'range-slider',
              min: 1,
              max: 500,
            },
          ],
        },
        {
          title: 'Mirroring',
          options: [
            {
              label: 'Mirror 1',
              key: 'mirror1',
              type: 'switch',
            },
            {
              label: 'Mirror 1 Position',
              key: 'mirrorPos1',
              type: 'slider',
              hide: 'mirror1',
              min: 0,
              max: 4000,
            },
            {
              label: 'Mirror 2',
              key: 'mirror2',
              type: 'switch',
            },
            {
              label: 'Mirror 2 Position',
              key: 'mirrorPos2',
              type: 'slider',
              hide: 'mirror2',
              min: 0,
              max: 4000,
            },
            {
              label: 'Mirror 3',
              key: 'mirror3',
              type: 'switch',
            },
            {
              label: 'Mirror 3 Position',
              key: 'mirrorPos3',
              type: 'slider',
              hide: 'mirror3',
              min: 0,
              max: 4000,
            },
          ],
        },
        {
          title: 'Scale',
          options: [
            {
              label: 'Master',
              key: 'scale',
              type: 'slider',
              step: 0.1,
              min: 0.1,
              max: 10.0,
            },
          ],
        },
        {
          title: 'Hatching',
          options: [
            {
              label: 'Amount',
              key: 'hatchMod',
              type: 'slider',
              min: 0,
              max: 100,
            },
          ],
        },
      ],
    }
  },
})
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
.token-graphic
  padding: 0 !important
.form-buttons
  display: flex
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

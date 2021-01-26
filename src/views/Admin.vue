<template lang="pug">
  .admin
    v-container(fluid)
      v-row
        v-col(align="center").token-title
          h1.title TinyBoxes Admin Panel
      v-row
        v-col(cols="12")
          v-toolbar
            span Phase: {{ phase }}
            v-spacer
            span Phase Length: {{ phaseLen }}
            v-spacer
            span Created This Phase: {{ tokenCount % phaseLen }}
            v-spacer
            span Total Created: {{ tokenCount }}
            v-spacer
          v-progress-linear(:indeterminate="false" value="50" striped height="1rem" color="secondary")
          v-progress-linear(:indeterminate="false" value="10" striped height="1rem" color="accent")
      v-row(no-gutters)
        v-col(cols="12" md="4")
          v-card
            v-card-title Countdown
            v-card-text
              p Curent Block: {{  }}
              p Block Start: {{ blockStart }}
              p Aproximate Start Time: {{  }}
              v-divider
              p Set the countdown blockstart
              v-input(label="Block")
              v-input(label="Time")
              v-btn Set
          v-card
            v-card-title Un/Pause Minting
            v-card-text
              p Curent State: {{ paused ? "Paused" : "Unpaused" }}
            v-card-actions
              v-btn(icon)
                v-icon(large) {{ paused ? 'mdi-play' : 'mdi-pause' }}
          v-card
            v-card-title Metadata
            v-card-text
              p Contract URI:
              span
                a(:href="contractURI") {{ contractURI }}
              v-input(label="Contract URI")
              p Base URI:
              span
                a(:href="baseURI") {{ baseURI }}
              v-input(label="Base URI")
              v-divider
              p Token URI
              v-input(label="Token ID")
              p URI: {{  }}
              v-input(label="Token URI")
            v-card-actions
              v-btn Reset
              v-spacer
              v-btn Save
        v-col(cols="12" md="8")
          v-card
            v-card-title LE Minter
            v-card-text
              p Mint a Limited Edition Token
              p {{ leCount }} of 100 Limited Editions Minted
              v-input(label="Recipient")
              v-btn Mint
            v-progress-linear(:indeterminate="false" value="10" striped height="1rem")
          v-card
            v-card-title Randomizer
            v-card-text
              p Set the Randomizer Contract
              .d-flex
                v-btn Test
                p.ml-5 Randomness: {{  }}
              p Block: {{  }}
              v-divider
              v-input(label="Randomizer")
              v-btn Update
          v-card
            v-card-title Renderer
            v-card-text
              p Set the Renderer Contract
              v-input(label="Randomizer")
              v-btn Test
              v-btn Update
</template>

<script lang="ts">
import Vue from "vue";
import { mapGetters, mapState } from "vuex";
import { log } from 'util';

export default Vue.extend({
  name: "Admin",
  computed: {
    ...mapGetters(["currentAccount"]),
  },
  mounted: async function() {
    await this.$store.dispatch("initialize");
    const t = this as any;
    t.lookupSupply();
    t.lookupLimit();
    t.lookupPause();
    t.lookupBlockStart();
    t.lookupLE();
    t.lookupTokens();
    t.lookupPhase();
    t.lookupPhaseLen();
    t.lookupContractURI();
    t.lookupBaseURI();
  },
  methods: {
    lookupContractURI: async function() {
      (this as any).contractURI = await this.$store.state.contracts.tinyboxes.methods.contractURI().call();
    },
    lookupBaseURI: async function() {
      (this as any).baseURI = await this.$store.state.contracts.tinyboxes.methods.baseURI().call();
    },
    lookupSupply: async function() {
      (this as any).supply = await this.$store.state.contracts.tinyboxes.methods.totalSupply().call();
    },
    lookupLE: async function() {
      (this as any).leCount = await this.$store.state.contracts.tinyboxes.methods._tokenPromoIds().call();
    },
    lookupTokens: async function() {
      (this as any).tokenCount = await this.$store.state.contracts.tinyboxes.methods._tokenIds().call();
    },
    lookupLimit: async function() {
      (this as any).limit = await this.$store.state.contracts.tinyboxes.methods.TOKEN_LIMIT().call();
    },
    lookupPhase: async function() {
      (this as any).phase = await this.$store.state.contracts.tinyboxes.methods.currentPhase().call();
    },
    lookupPhaseLen: async function() {
      (this as any).phaseLen = await this.$store.state.contracts.tinyboxes.methods.phaseLen().call();
    },
    lookupPause: async function() {
      (this as any).paused = await this.$store.state.contracts.tinyboxes.methods.paused().call();
    },
    lookupBlockStart: async function() {
      (this as any).blockStart = await this.$store.state.contracts.tinyboxes.methods.blockStart().call();
    },
  },
  data: () => ({
    loading: true,
    paused: false,
    pauseEndTime: new Date(),
    blockStart: null as number | null,
    blockSubscription: null,
    supply: null as number | null,
    limit: null as number | null,
    leCount: null as number | null,
    tokenCount: null as number | null,
    phase: null as number | null,
    phaseLen: null as number | null,
    baseURI: '',
    contractURI: '',

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
.render-settings
  max-width: 100%
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
.box-story
  font-size: 1.2rem
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

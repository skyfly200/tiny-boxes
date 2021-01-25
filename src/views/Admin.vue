<template lang="pug">
  .admin
    v-container(fluid)
      v-row
        v-col(align="center").token-title
          h1.title TinyBoxes Admin Panel
      v-row
        v-col(cols="12")
          v-toolbar
            v-toolbar-title Phase: {{  }}
            v-spacer
            span Created This Phase: {{  }}
            v-spacer
            span Total Created: {{  }}
            v-spacer
          v-progress-linear(indeterminate="false" value="50" striped height="1rem" color="secondary")
          v-progress-linear(indeterminate="false" value="10" striped height="1rem" color="accent")
      v-row(no-gutters)
        v-col(cols="12" md="4")
          v-card
            v-card-title Start Countdown
            v-card-text
              p Set the countdown blockstart
          v-card
            v-card-title Un/Pause Minting
            v-card-text
              p Curent State: {{  }}
            v-card-actions
              v-btn(icon)
                v-icon(large) mdi-pause
          v-card
            v-card-title Metadata
            v-card-text
              p Contract URI: {{  }}
              v-input(label="Contract URI")
              p Base: {{  }}
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
              p {{  }} of 100 Limited Editions Minted
              v-input(label="Recipient")
              v-btn Mint
            v-progress-linear(indeterminate="false" value="10" striped height="1rem")
          v-card
            v-card-title Randomizer
            v-card-text
              p Set the Randomizer Contract
              p Current Contract: {{  }}
              .d-flex
                v-btn Test
                p.ml-5 Randomness: {{  }}
              p Block: {{  }}
              v-divider
              v-input(label="Randomizer")
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
  },
  methods: {
  },
  data: () => ({
    loading: true
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

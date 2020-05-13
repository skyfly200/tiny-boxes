<template lang="pug">
  v-container.guide
    v-row(cols=6).landing
      v-col(align="center").content
        h1 Guide
        h2 Index panel to left
        h3 content pane to right
        h3 {{ topic }}
    v-card
      v-toolbar(flat='' color='primary' dark='')
        v-toolbar-title How To Play:
      v-tabs(vertical='')
        v-tab
          v-icon(left='') mdi-biohazard
          | Minting
        v-tab
          v-icon(left='') mdi-call-merge
          | Merging
        v-tab
          v-icon(left='') mdi-call-split
          | Dividing
        v-tab
          v-icon(left='') mdi-menu
          | Levels
        v-tab
          v-icon(left='') mdi-dice-6
          | Get Rekt?
        v-tab-item
          v-card(flat='')
            v-card-text
              .text--primary
                | Mint new cells directly from the contract at a cost of .008 per
                | cell.
                br
                | Cell art is procedurally generated using the random values
                |                 assigned during minting.
                br
                | The visual complexity of the cell
                |                 depends in part on the total mass of the cell.
                br
                | Cells are
                |                 minted with a mass of 8.
                br
                | Any cell with a mass of 8 or less
                |                 is a level 1 cell.
                br
                | The mass threshold for each level is
                |                 twice the previous level.
        v-tab-item
          v-card(flat='')
            v-card-text
              .text--primary
                | A player may merge any two cells they own into a new cell.
                br
                | The genetics of the merged cell are sampled from the input
                |                 cells based on their proportion of the total mass being
                |                 combined.
                br
                | E.G. A cell with a mass of 8 has a small chance
                |                 of influencing the genetic outcome when merging with a cell with
                |                 a mass of 100.
                br
                | When merging cells, the resulting mass can
                |                 vary greatly. The table below describes the probability of
                |                 different mass altering outcomes.
                br
        v-tab-item
          v-card(flat='')
            v-card-text
              .text--primary
                | A player may divide any cell they own into two cells of smaller
                | mass with identical genetics.
                br
                | The distribution of mass between these divided cells will
                |                 range from 50-50 to 70-30 at most.
                br
                | The total mass of the
                |                 resulting cells is equal to the mass of the parent cell.
                br
        v-tab-item
          v-card(flat='')
            table
              thead
                tr
                  th.text-left Level
                  th.text-left Mass
              tbody
                tr(v-for='item in masslevels' :key='item.level')
                  td {{ item.level }}
                  td {{ item.mass }}
        v-tab-item
          v-card(flat='')
            table
              thead
                tr
                  th.text-left Merge Result
                  th.text-left Probability
                  th.text-left Loss(% of Cell Mass)
                  th.text-left Gain(% of Mass Pool)
              tbody
                tr(v-for='item in rekt' :key='item.mergeresult')
                  td {{ item.mergeresult }}
                  td {{ item.probability }}
                  td {{ item.loss }}
                  td {{ item.gain }}

    
</template>

<script lang="ts">
import Vue from "vue";

export default Vue.extend({
  name: "Guide",
  computed: {
    topic() {
      return this.$route.params.topic;
    }
  },
  data: () => ({
    masslevels: [
      {
        level: 1,
        mass: 8
      },
      {
        level: 2,
        mass: 16
      },
      {
        level: 3,
        mass: 32
      },
      {
        level: 4,
        mass: 64
      },
      {
        level: 5,
        mass: 128
      },
      {
        level: 6,
        mass: 256
      },
      {
        level: 7,
        mass: 512
      },
      {
        level: 8,
        mass: 1024
      },
      {
        level: 9,
        mass: 2048
      },
      {
        level: 10,
        mass: 4096
      }
    ],
    rekt: [
      {
        mergeresult: "Boost",
        probability: "3%",
        loss: 0,
        gain: "1% * Level"
      },
      {
        mergeresult: "Kinda Boost",
        probability: "7%",
        loss: 0,
        gain: ".3% * Level"
      },
      {
        mergeresult: "Barely Boost",
        probability: "25%",
        loss: 0,
        gain: ".1% * Level"
      },
      {
        mergeresult: "Neutral",
        probability: "30%",
        loss: 0,
        gain: 0
      },
      {
        mergeresult: "Barely Rekt",
        probability: "25%",
        loss: "5%",
        gain: 0
      },
      {
        mergeresult: "Kinda Rekt",
        probability: "7%",
        loss: "10%",
        gain: 0
      },
      {
        mergeresult: "Rekt",
        probability: "2%",
        loss: "30%",
        gain: 0
      },
      {
        mergeresult: "Fukt",
        probability: "1%",
        loss: "99%",
        gain: 0
      }
    ]
  })
});
</script>

<style lang="sass" scoped>
</style>

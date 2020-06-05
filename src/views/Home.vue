<template lang="pug">
  .home
    v-container(fluid)
      v-row(cols=6).landing
        v-col(align="center")
          h1.title TinyBoxes
          h3 Boxes Upon Boxes
          h3 Art is stored on chain!
          .call-to-action
            v-btn.btn(color="primary" large to="/list") Play Now
            v-btn.btn(color="tertiary" large to="/about") Learn More
</template>

<script>
import Vue from "vue";

export default {
  name: "Home",
  data: () => ({
    data: {
      mass: "1854",
      wallWave: "13",
      wallRound: true,
      wallColor: "76379945",
      nucleusHidden: false,
      nucleusColor: "120900",
      featureCategories: ["0", "1", "2", "3", "4", "5", "6", "7"],
      featureFamilies: ["1", "1", "1", "1", "1", "3", "3", "3"],
      featureCounts: ["14", "9", "5", "3", "2", "11", "13", "14"],
      featureColors: [
        "176130",
        "15004091",
        "9558604",
        "13202218",
        "579032",
        "16426533",
        "14842158",
        "568390"
      ]
    }
  })
};
</script>

<style lang="sass" scoped>
.particles
  position: fixed
  height: 100vh
  width: 100vw
  .landing
    padding-top: 10vh
    min-height: 100vh
  @media(max-width: 700px)
    .landing
      padding-top: 0
  .details
    height: 50vh
    .details-card
      margin: 2rem
      padding: 2rem
  .container
    padding: 0
  .cell
    margin-top: 3vh
  .title
    font-size: 4rem
  .call-to-action
    margin-top: 5vh
    color: #121212
    .btn
      margin: 15px
</style>

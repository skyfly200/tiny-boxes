<template lang="pug">
  .home
    v-container(fluid)
      v-row(cols=6).landing
        v-col(align="center")
          v-img(src="/img/logo.png" min-width="20vw" max-height="50vh")
          h1.title TinyBoxes
          h3 Boxes Upon Boxes
          h3 Fully on chain, animated NFTs
          v-btn.btn(color="primary" large to="/about") Learn More
      v-row(cols=6)
        v-col(align="center")
          v-card
            v-card-text
              h1.title On Chain Generative Art
              h3 The Immutible Decentralized Perpetual Renderer 
              h3 That means art thats accesible forever and fully owned by you
            v-card-actions.call-to-action
                #mc_embed_signup
                  form#mc-embedded-subscribe-form.validate(action='https://shop.us17.list-manage.com/subscribe/post?u=81d0c7a7aabdc5c89bc737456&id=e8ca8b83a1' method='post' name='mc-embedded-subscribe-form' target='_blank' novalidate='')
                    #mc_embed_signup_scroll
                      label(for='mce-EMAIL') Subscribe to be the first to know when we launch!
                      input#mce-EMAIL.email(type='email' value='' name='EMAIL' placeholder='email address' required='')
                      // real people should not fill this in and expect good things - do not remove this or risk form bot signups
                      div(style='position: absolute; left: -5000px;' aria-hidden='true')
                        input(type='text' name='b_81d0c7a7aabdc5c89bc737456_e8ca8b83a1' tabindex='-1' value='')
                      .clear
                        input#mc-embedded-subscribe.button(type='submit' value='Subscribe' name='subscribe')

              v-btn.btn(color="primary" large to="/guide") The Perpetual Renderer
      v-row(cols=6)
        v-col(align="center")
          v-card
            v-card-text
              h1.title Creative Options + Mystery
              h3 Tweak the sliders, explore the posibilities
              h3 You never know what you will get, thanks to a dash of RNG on minting
            v-card-actions.call-to-action
              v-btn.btn(color="primary" large to="/guide") Create a Box
      v-row(cols=6)
        v-col(align="center")
          v-card
            v-card-text
              h1.title Chainlink VRF
              h3 Using the latest secure RNG solution from Chainlink
              h3 Assuring your tokens are minted fairly with truly random values
            v-card-actions.call-to-action
              v-btn.btn(color="primary" large to="/guide") Chainlink VRF
      v-row(cols=6)
        v-col(align="center")
          v-card
            v-card-text
              h1.title Accepting LINK
              h3 Our contract directly accepts LINK token to mint TinyBoxes
              h3 A first for NFT projects
            v-card-actions.call-to-action
              v-btn.btn(color="primary" large to="/guide") Mint with LINK
      v-row(cols=6)
        v-col(align="center")
          v-card
            v-card-text
              h1.title OpenSea Secondary Market
              h3 Ready for OpenSea integration
              h3 Featuring animations
            v-card-actions.call-to-action
              v-btn.btn(color="primary" large to="/guide") OpenSea
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
        "568390",
      ],
    },
  }),
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
    align: center
    margin-top: 5vh
    color: #121212
    .btn
      margin: 15px
</style>

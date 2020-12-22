<template lang="pug">
  .home
    v-container(fluid)
      v-row.landing-logo
        v-col(align="center" cols=12)
          v-img.logo(src="/img/logo.svg")
      v-row.landing-text
        v-col(sm=6 xs=12 offset-sm=3 align="center")
          h1.font-weight-bold Boxes Upon Boxes
          h3.text--secondary Animated On-Chain Generative Art NFTs
          .social-links.ma-4
            v-btn(v-if="false" icon large href="" target="_blank")
              v-icon mdi-discord
            v-btn(icon large href="https://twitter.com/tinyboxeseth" target="_blank")
              v-icon mdi-twitter
            v-btn(icon large href="https://medium.com/@nonfungibleteam" target="_blank")
              v-icon mdi-typewriter
      v-row
        v-col(md=8 sm=10 xs=12 offset-md=2 offset-sm=1)
          v-container(fluid)
            v-row
              v-col(v-for="c of cards" align="center" cols=6)
                v-card(height="14rem")
                  v-card-text
                    h1.title {{ c.title }}
                    h3.font-weight-thin {{ c.lines[0] }}
                    h3.font-weight-thin {{ c.lines[1] }}
      v-row
        v-col(md=6 sm=8 xs=12 offset-md=3 offset-sm=2)
          v-card#mc_embed_signup
            v-form#mc-embedded-subscribe-form.validate(action='https://shop.us17.list-manage.com/subscribe/post?u=81d0c7a7aabdc5c89bc737456&id=e8ca8b83a1' method='post' name='mc-embedded-subscribe-form' target='_blank' novalidate='')
              .title Subscribe to our mailing list!
              v-card-subtitle Be the first to know when we launch
              #mc_embed_signup_scroll
                v-text-field#mce-EMAIL.email(type='email' value='' name='EMAIL' placeholder='email address' required='')
                // real people should not fill this in and expect good things - do not remove this or risk form bot signups
                div(style='position: absolute; left: -5000px;' aria-hidden='true')
                  input(type='text' name='b_81d0c7a7aabdc5c89bc737456_e8ca8b83a1' tabindex='-1' value='')
                .clear
                  v-btn(type='submit' name='subscribe' color="green") Subscribe
    v-footer.text-center &copy; NonFungibleTeam 2020
</template>

<script>
import Vue from "vue";

export default {
  name: "Home",
  data: () => ({
    cards: [
      {
        title: "Vast Posibilities",
        lines: [
          "A State of the Art Collaborative On-Chain Generative Algorithm",
          "Choose from hundreds of googols of possible outcomes"
        ]
      },
      {
        title: "Art Thats Forever",
        lines: [
          "The Immutible & Decentralized Perpetual Renderer",
          "That means art thats accesible forever and fully owned by you"
        ]
      },{
        title: "Animations",
        lines: [
          "Animation straight from the on chain renderer",
          "Static and animated versions of each token art"
        ]
      },{
        title: "Creativity + Suprise",
        lines: [
          "Tweak the sliders, explore the posibilities",
          "You never know what you will get, thanks to a dash of RNG on minting"
        ]
      },{
        title: "Chainlink VRF",
        lines: [
          "Using Chainlinks latest secure RNG solution VRF",
          "Assuring tokens are minted fairly with verifiable random values"
        ]
      },{
        title: "Accepting LINK",
        lines: [
          "Purchase TinyBoxes with Chainlinks token LINK",
          "A first for NFT projects"
        ]
      },
    ]
  })
};
</script>

<style lang="sass" scoped>
.landing-logo
  margin: 10vh 0
.logo
  width: 80vh
.v-card__text
  height: 100%
  display: flex
  flex-direction: column
  justify-content: center
.landing-text
  margin: 20vh 0
#mc_embed_signup
  margin: 20vh 0
  #mc_embed_signup_scroll
    margin: 0 1rem
</style>

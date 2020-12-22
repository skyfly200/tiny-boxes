<template lang="pug">
  .home
    v-container(fluid)
      v-row.landing-logo
        v-col(align="center" cols=12)
          v-img(src="/img/logo.png" min-width="250px" max-width="400px")
      v-row.landing-text
        v-col(sm=6 xs=12 offset-sm=3 align="center")
          h1 Boxes Upon Boxes
          h1 Animated On-Chain Generative Art NFTs
      v-row
        v-col(md=8 sm=10 xs=12 offset-md=2 offset-sm=1)
          v-container(fluid)
            v-row
              v-col(align="center" cols=6)
                v-card(height="10rem")
                  v-card-text
                    h1.title Vast Generative Posibilities
                    h3 An Advanced Generative On-Chain Algorithm
                    h3 Hundreds of googols of possible outcomes
              v-col(align="center" cols=6)
                v-card(height="10rem")
                  v-card-text
                    h1.title Art Thats Forever
                    h3 The Immutible & Decentralized Perpetual Renderer 
                    h3 That means art thats accesible forever and fully owned by you
              v-col(align="center" cols=6)
                v-card(height="10rem")
                  v-card-text
                    h1.title Animations
                    h3 Animation effects built into the on chain renderer
                    h3 Static and animated art on chain and saved to IPFS
              v-col(align="center" cols=6)
                v-card(height="10rem")
                  v-card-text
                    h1.title Creative Options + Mystery
                    h3 Tweak the sliders, explore the posibilities
                    h3 You never know what you will get, thanks to a dash of RNG on minting
              v-col(align="center" cols=6)
                v-card(height="10rem")
                  v-card-text
                    h1.title Chainlink VRF
                    h3 Using the latest secure RNG solution from Chainlink
                    h3 Assuring your tokens are minted fairly with truly random values
              v-col(align="center" cols=6)
                v-card(height="10rem")
                  v-card-text
                    h1.title Accepting LINK
                    h3 Buy TinyBoxes in LINK token
                    h3 A first for NFT projects
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
    v-footer.text-center &copy; TinyBoxes 2020
</template>

<script>
import Vue from "vue";

export default {
  name: "Home",
  data: () => ({
    data: {
    }
  })
};
</script>

<style lang="sass" scoped>
.landing-logo
  margin: 20vh 0
.landing-text
  margin: 20vh 0
#mc_embed_signup
  margin: 20vh 0
  #mc_embed_signup_scroll
    margin: 0 1rem
</style>

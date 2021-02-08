<template lang="pug">
  .home
    v-container(fluid)
      v-row.landing-logo
        v-col(align="center" cols=12)
          v-img.logo(src="/img/logo.svg" aspect-ratio="1/1")
      v-row.landing-text.section(min-height="30vh")
        v-col(sm=6 xs=12 offset-sm=3 align="center")
          h1.font-weight-bold Boxes Upon Boxes
          h2.text--secondary Animated Generative Art NFTs
          h2.text--secondary On-Chain Artwork & Metadata
          h3.text--secondary Create One of 2222 Unique Art Pieces
          br
          v-divider(width="50%")
          .social-links.ma-4
            v-btn(icon large href="https://opensea.io/collection/tinyboxes" target="_blank")
              v-icon $custom
            v-btn(icon large href="https://discord.gg/2wWANVfCuE" target="_blank")
              v-icon mdi-discord
            v-btn(icon large href="https://twitter.com/tinyboxeseth" target="_blank")
              v-icon mdi-twitter
            v-btn(icon large href="https://medium.com/@nonfungibleteam" target="_blank")
              v-icon mdi-typewriter
            v-btn(icon large href="#mc_embed_signup")
              v-icon mdi-email
      v-row.section
        v-col(sm=6 xs=12 style="background-color: #444").pa-7
          .d-flex.flex-column.justify-space-between.on-chain(align="center")
            h1 100% On-Chain
            br
            h1 Animated
            br
            h1 SVG Artwork
            .d-flex.justify-center.my-5
              v-btn(href="/docs" target="_blank" large color="secondary" width="8rem")
                v-icon.mr-3 mdi-book-open-page-variant
                span.mr-2 Learn
        v-col(sm=6 xs=12 style="background-color: #666").pa-7
          .d-flex.flex-column.justify-space-between.proto-gen(align="center")
            h1 Proto-Generative
            h1 = 
            h1 Custom
            h1 +
            h1 Random
            .d-flex.justify-center.my-5
              v-btn(to="/create" large color="primary" width="8rem")
                v-icon.mr-3 mdi-creation
                span.mr-2 Create
      v-row.section.intro
        v-col.intro-image(md=3 sm=4 cols=12 offset-sm=1)
          .sample-art.d-flex
            v-img(contain src="/img/sample.svg" aspect-ratio="1/1" min-height="280px")
        v-col.intro-blurb.d-flex(md=6 sm=6 cols=12)
          .intro-text.d-flex.flex-column.justify-center
            h1 About Tinyboxes
            v-divider
            p A scattering of randomized rectangles brought to life through color, mirroring and animation.
            p TinyBoxes is a first of its kind Animated Proto-Generative NFT, rendered down to SVG art 100% on-chain. With customizable options, randomized traits and dynamic render settings, TinyBoxes pushes the bounds of whats possible with NFTs. Our contract has been meticulously optimized to save you gas. We used bit packing to squeeze each tokens data into just 256 bits.
            p TinyBoxes will be released in 11 phases. Phases will be differentiated by there own unique color schemes. As one phase ends, minting is paused, and a countdown to the next phase begins. The countdown length increases by 6 hours each phase.
        v-col.project-stats.d-flex(md=1 cols=12)
          .stats.d-flex
            br
            .stat
              h3 0.1
                v-icon mdi-ethereum
              p Per
            .stat
              h3 11
              p Phases
            .stat
              h3 202
              p Each
            .stat
              h3 2222
              p Total
            v-divider(:vertical="!$vuetify.breakpoint.md && !$vuetify.breakpoint.lg  && !$vuetify.breakpoint.xl").mb-4
            .stat
              h3 +100
              p Limited Editions
      v-row.pb-6.section
        v-col(lg=4 md=6 cols=12 style="background-color: #444").pa-7
          .d-flex.flex-column.justify-space-between.referral(align="center")
            h1 Referrals
            h3 10-15% on each sale referred by your tokens
            h3 Earn by sharing or when someone copies one of your tokens options
            br
            .d-flex.justify-center.my-5
              v-btn(href="/docs/dapp" target="_blank" large color="primary" width="8rem")
                v-icon.mr-3 mdi-link-variant
                span.mr-2 More
        v-col(lg=4 md=6 cols=12 style="background-color: #666").pa-7
          .d-flex.flex-column.justify-space-between.le-tokens(align="center")
            h1 Limited Editions
            h3 Design exactly what you want
            h3 Exclusive Distribution of 100 Max
            H3 Redeem Whenever
            .d-flex.justify-center.my-5
              v-btn(to="/le" large color="secondary" width="8rem")
                v-icon.mr-3 mdi-crystal-ball
                span.mr-2 Redeem
        v-col(lg=4 cols=12 style="background-color: #555").pa-7
          .d-flex.flex-column.justify-space-between.prizes(align="center")
            h1 Prizes
            h3 Giving back to our community is imporant
            h3 Join our Discord to hear about the latest promotions
            br
            .d-flex.justify-center.my-5
              v-btn(large href="https://discord.gg/2wWANVfCuE" target="_blank" color="primary" width="8rem")
                v-icon.mr-3 mdi-discord
                span.mr-2 Join
      v-row.source
        v-col(md=6 sm=12 align="center").d-flex.flex-column.justify-center
          .fancy-header(align="center")
            h1 Contract
            v-divider(width="150rem")
          br
          a(href="https://etherscan.io/address/0x46f9a4522666d2476a5f5cd51ea3e0b5800e7f98" target="_blank")
            h3 {{ $store.state.tinyboxesAddress }}
          h3 Verified on Etherscan
        v-col(md=6 sm=12 align="center").d-flex.flex-column.justify-center
          .fancy-header(align="center")
            h1 Source Code
            v-divider(width="180rem")
          br
          v-icon(large) mdi-github
          a(href="https://github.com/skyfly200/tiny-boxes" target="_blank")
            h3 MIT Licensed on GitHub
      v-row.section
        v-col(md=6 sm=8 xs=12 offset-md=3 offset-sm=2).d-flex.justify-center
          v-card#mc_embed_signup.pb-3(max-width="1440px")
            v-form#mc-embedded-subscribe-form.validate(action='https://shop.us17.list-manage.com/subscribe/post?u=81d0c7a7aabdc5c89bc737456&id=e8ca8b83a1' method='post' name='mc-embedded-subscribe-form' target='_blank' novalidate='')
              v-card-title.font-weight-medium.subscribe-title Subscribe to our mailing list!
              v-card-subtitle Stay up to the date on the latest happenings with TinyBoxes
              #mc_embed_signup_scroll
                v-text-field#mce-EMAIL.email(type='email' value='' name='EMAIL' placeholder='email' required='')
                // real people should not fill this in and expect good things - do not remove this or risk form bot signups
                div(style='position: absolute; left: -5000px;' aria-hidden='true')
                  input(type='text' name='b_81d0c7a7aabdc5c89bc737456_e8ca8b83a1' tabindex='-1' value='')
                .clear
                  v-btn(type='submit' large name='subscribe' color="secondary") Subscribe
      v-row.pb-8.pt-5.mb-8.nfteam.section
        v-col(md=6 sm=8 xs=12 offset-md=3 offset-sm=2 align="center")
          h1 NonFungibleTeam
          v-divider(width="330rem")
          h3 Striving to push the boundaries of NFTs
          br
          v-btn(href="https://nonfungible.team/" target="_blank") More Projects
    v-footer
      v-container.pa-0
        v-row
          v-col.pa-0(align="center")
            .text-center.font-weight-thin.text--secondary &copy; NonFungibleTeam 2021
</template>

<script lang="ts">
import Vue from "vue";
import { mapGetters, mapState } from "vuex";
import Token from "@/components/Token.vue";
import ColorsGrid from "@/components/ColorsGrid.vue";

export default {
  name: "Home",
  components: { Token, ColorsGrid },
  mounted: async function() {
    const t = this as any;
    await t.$store.dispatch("initialize");
  },
  data: () => ({
    cards: [
      {
        lines: [
          "Vast Posibilities",
          "A State of the Art Collaborative On-Chain Generative Algorithm",
          "Choose from hundreds of googols of possible outcomes",
          "Art Thats Forever",
          "The Immutible & Decentralized Perpetual Renderer",
          "That means art thats accesible forever and fully owned by you",
          "Animations",
          "Animation straight from the on chain renderer",
          "Static and animated versions of each token art",
          "Creativity + Suprise",
          "Tweak the sliders, explore the posibilities",
          "You never know what you will get, thanks to a dash of RNG on minting"
        ]
      }
    ]
  }),
  computed: {
    ...mapState({
        animationTitles: 'animationTitles',
        schemeTitles: 'schemeTitles',
        openseaTokenURL: 'openseaTokenURL',
    }),
    ...mapGetters(["currentAccount"]),
  },
  methods: {}
};
</script>

<style lang="sass" scoped>
.landing-logo
  margin: 2vh 0 0 0
  .logo
    width: 50vh
    height: 50vh
    @media (max-width: 600px)
      width: 90vw
      height: 90vw
.on-chain, .proto-gen, .sample-art, .referral, .le-tokens, .prizes
  height: 100%
.sample-art svg, .logo svg
  transform: translateZ(0)
.dark-text
  color: #000
.intro, .source
  min-height: 90vh
.stats
  flex-direction: column
  justify-content: center
  @media (max-width: 900px)
    flex-direction: row
    justify-content: space-between
    width: 100%
    align-items: center
.stat
  Text-align: center
.intro-text
  @media (max-width: 600px)
    width: 100%
    align-items: center
.nfteam
  min-height: 50vh
.v-card__text
  display: flex
  flex-direction: column
  justify-content: space-around
  height: 10rem
  padding-top: 0
.card
  height: 14em
.card-title
  justify-content: center
  padding-bottom: 8px
.landing-text
  margin: 0 0 2vh 0
.action-btn
  width: 7em
  font-size: 1.2rem
#mc_embed_signup
  margin: 0 0 20vh 0
  .subscribe-title
    justify-content: center
  #mc_embed_signup_scroll
    margin: 0 1rem
</style>

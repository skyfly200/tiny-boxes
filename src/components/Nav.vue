<template lang="pug">
  .nav
    v-navigation-drawer(app right temporary v-model="drawer")
      v-list(nav dense)
        template(v-if="web3Status === 'active'")
          .mobile-link
            v-list-item(two-line)
              Gravatar.gravatar.gravatar-mobile(:size="50" :email="currentAccount")
              v-list-item-content 
                h4.account-label Active Account
                span.address {{ currentAccount !== '' ? formatAccount(currentAccount) : "loading" }}
          v-divider
        .mobile-link(v-for="l,i in links" :key="i")
          v-list-item(v-if="l.type === 'page'" :to="l.path" link)
            v-list-item-icon
              v-icon {{ l.icon }}
            v-list-item-content {{ l.text }}
          v-list-item(v-else-if="l.type === 'link'" :href="l.path" target="_blank" link)
            v-list-item-icon
              v-icon {{ l.icon }}
            v-list-item-content {{ l.text }}
        
    v-app-bar(app color="primary" dark)
      router-link(to="/")
        v-img.logo.mt-2(src="/img/logo.png" width="55" height="55")
      v-spacer
      .link(v-for="l in barLinks")
        v-btn(v-if="l.type === 'page'" :to="l.path" text)
          span.mr-2 {{ l.text }}
        v-btn(v-else-if="l.mobileIcon" :to="l.path" icon)
          v-icon {{ l.icon }}
        v-btn(v-else-if="l.type === 'link'" :href="l.path" target="_blank" icon)
          v-icon {{ l.icon }}
      v-tooltip(v-if="web3Status === 'active'" bottom)
        template(v-slot:activator="{ on }")
          Gravatar.gravatar.gravatar-desktop(v-on="on" :size="40" :email="currentAccount")
        h4.account-label Active Account
        span.address.address-tooltip {{ currentAccount !== '' ? formatAccount(currentAccount) : "loading" }}
      v-btn(@click="drawer = !drawer" text).mobile-menu-btn
        v-icon mdi-menu
    v-dialog(v-model="wrongNetworkFlag" width="300")
      v-card.pa-4(align="center")
        v-icon(large color="warning") mdi-alert
        p Wrong network.
        p Please connect to {{ targetNetwork }}.
        
</template>

<script>
import Vue from "vue";
import { mapGetters, mapState } from "vuex";
import Gravatar from "vue-gravatar";

Vue.component("v-gravatar", Gravatar);

export default {
  components: { Gravatar },
  methods: {
    formatAccount(account) {
      return "0x" + account.slice(2, 6) + "...." + account.slice(-4);
    },
  },
  mounted: async function() {
    await this.$store.dispatch("initialize");
    this.wrongNetworkFlag = this.wrongNetwork;
  },
  data: () => ({
    drawer: false,
    wrongNetworkFlag: false,
    links: [
      {
        type: "page",
        bar: true,
        icon: "mdi-plus-box",
        text: "Create",
        path: "/create"
      },
      {
        type: "page",
        bar: true,
        icon: "mdi-view-grid",
        text: "Gallery",
        path: "/list"
      },
      {
        type: "page",
        bar: false,
        icon: "mdi-dice-multiple",
        text: "Explore",
        path: "/explore"
      },
      {
        type: "link",
        mobileIcon: true,
        bar: true,
        icon: "mdi-crystal-ball",
        text: "Limited Edition",
        path: "/le"
      },
      {
        type: "link",
        bar: true,
        icon: "mdi-book-open-page-variant",
        text: "Docs",
        path: "/docs"
      },
      {
        type: "link",
        bar: true,
        icon: "mdi-discord",
        text: "Discord",
        path: "https://discord.gg/2wWANVfCuE"
      },
      {
        type: "link",
        bar: false,
        icon: "mdi-twitter",
        text: "Twitter",
        path: "https://twitter.com/tinyboxeseth"
      },
      {
        type: "link",
        bar: false,
        icon: "mdi-typewriter",
        text: "Blog",
        path: "https://medium.com/@nonfungibleteam"
      },
    ]
  }),
  computed: {
    barLinks() {
      return this.links.filter( (l) => l.bar );
    },
    ...mapGetters(["currentAccount", "web3Status", "wrongNetwork"]),
    ...mapState(["network", "targetNetwork"]),
  }
};
</script>

<style lang="sass">
.logo
  margin: 0 4px 8px 0
.account-label, .address-tooltip
  margin: 0 0
.title
  font-family: "Pangolin"
  font-size: 2rem
  color: #ffffff
  text-decoration: none
.gravatar
  margin-top: -7px
  border-radius: 50%
.gravatar-mobile
  margin-right: 10px
.mobile-menu-btn
  display: none !important
@media(max-width: 700px)
  .mobile-menu-btn
    display: block !important
  .link, .gravatar-desktop
    display: none !important
</style>

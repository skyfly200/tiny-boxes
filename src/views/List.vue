<template lang="pug">
  .list
    v-btn(to="/create" color="secondary" fab bottom left fixed large)
        v-icon(large) mdi-plus-box
    v-container(fluid)
      v-data-iterator(:items="loadedTokens" :page.sync="page" @update:page="setPage"
        :loading="loading" :items-per-page.sync="itemsPerPageSelector")
        template(v-slot:header)
          v-toolbar
            v-text-field(
              v-if="false"
              v-model="search"
              clearable
              flat
              solo-inverted
              hide-details
              prepend-inner-icon="mdi-magnify"
              label="Search")
            v-spacer
            v-tooltip(v-if="web3Status === 'active'" bottom)
                template(v-slot:activator="{ on }")
                  v-btn(large icon v-on="on" @click="owned = !owned" :depressed="owned" color="purple")
                    v-icon {{ owned ? "mdi-arrow-all" : "mdi-treasure-chest"}}
                span {{ owned ? "All Boxes" : "Your Boxes" }}
        template(v-slot:loading)
          v-row
            v-col(align="center").tokens-loading
              v-progress-circular(indeterminate size="75" color="primary")
              h1 Fetching Tokens
              h3 Please Wait...
        template(v-slot:default="{ items, isExpanded, expand }")
          v-row
            v-col(v-for="t of items" :key="'token-col-'+t.id" align="center" xl="1" lg="2" md="3" sm="4" xs="6")
              v-card.token(:to="'/token/' + t.id" tile)
                Token(:id="t.id" :data="t.art")
                v-card-text.title {{ t.id }}
        template(v-slot:no-data)
          v-row.get-started
            v-col(cols="12")
              v-card(align="center").get-started-card
                p {{ owned ? "You dont have any tokens yet!" : "No tokens have been minted yet" }}
                v-btn(v-if="!soldOut" to="/create" outlined color="secondary") Create
                span(v-if="tokens !== {} && !soldOut && owned") &nbsp;or&nbsp;
                v-btn(v-if="tokens !== {} && owned" :to="openseaStoreURL" outlined color="secondary") Buy
</template>

<script lang="ts">
import { mapGetters, mapState } from "vuex";
import Token from "@/components/Token.vue";

export default {
  name: "List",
  components: { Token },
  data: () => ({
    owned: false,
    page: 1,
    itemsPerPageSelector: 20,
    count: null,
    userCount: null,
    supply: null,
    limit: null,
    loading: true,
    soldOut: false,
    tokens: {} as any,
    values: {} as any,
  }),
  computed: {
    loadedTokens() {
      return Object.keys(this.tokens)
        .sort( (a,b) => parseInt(a) - parseInt(b))
        .map( t => this.tokens[t] )
        .filter( t => (this.owned ? t.owner === this.currentAccount : true) );
    },
    ...mapGetters(["currentAccount", "web3Status", "itemsPerPage"]),
    ...mapState(["openseaStoreURL"]),
  },
  mounted: async function() {
    await this.$store.dispatch("initialize");
    //this.page = this.$route.params.page ? parseInt(this.$route.params.page) : 1;
    this.limit = await this.lookupLimit();
    this.supply = await this.lookupSupply();
    this.userCount = await this.lookupBalance();
    this.soldOut = this.supply === this.limit;
    this.page = parseInt(this.$route.params.page, 10);
    this.loadTokens();
  },
  methods: {
    setPage(e: any) {
      console.log(e)
      this.$router.push({ params: {page: e} })
    },
    lookupArt: function(id: any, animate: any) {
      return this.$store.state.contracts.tinyboxes.methods.tokenArt(id, animate).call();
    },
    lookupOwner: function(id: any) {
      return this.$store.state.contracts.tinyboxes.methods.ownerOf(id).call();
    },
    lookupSupply: function() {
      return this.$store.state.contracts.tinyboxes.methods.totalSupply().call();
    },
    lookupBalance: function() {
      return this.$store.state.contracts.tinyboxes.methods.balanceOf(this.currentAccount).call();
    },
    lookupUsersToken(i: any) {
      return this.$store.state.contracts.tinyboxes.methods.tokenOfOwnerByIndex(this.currentAccount, i).call();
    },
    lookupLimit: function() {
      return this.$store.state.contracts.tinyboxes.methods.TOKEN_LIMIT().call();
    },
    loadTokens: async function() {
      this.tokens = {};
      this.count = this.owned ? this.userCount : this.supply;
      for (let i = 0; i < this.count; i++) this.loadToken(i);
    },
    loadToken: async function(tokenID: any) {
      const artPromise = this.lookupArt(tokenID, false);
      const ownerPromise = this.lookupOwner(tokenID);
      const art = await artPromise;
      const owner = await ownerPromise;
      this.$set(this.tokens, tokenID, {
        id: tokenID,
        art: art,
        owner: owner,
      });
      this.loading = false;
    },
    listenForTokens: function() {
      const tokenSubscription = this.$store.state.web3.eth
        .subscribe("logs", {
          address: this.$store.state.tinyboxesAddress,
          topics: [
            "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
            "0x0000000000000000000000000000000000000000000000000000000000000000"
          ]
        })
        .on(
          "data",
          async function(log: any) {
            const id = parseInt(log.topics[3], 16);
            // lookup new supply and check if sold out
            this.supply = await this.lookupSupply();
            this.soldOut = this.supply === this.limit;
            // rerender token list
            if (!this.owned) this.loadToken(id);
          }.bind(this)
        )
        .on("error", function(log: any) {
          this.listenForTokens();
        });
    }
  }
};
</script>

<style lang="sass" scoped>
.tokens-loading
  padding-top: 40vh
.get-started
  justify-content: center
  margin-top: 20vh
.get-started-card
  display: flex
  flex-direction: column
  padding: 2rem
.page-items
  margin-top: 1rem
  .theme--dark.v-input input
    color: #222 !important
.container
  padding: 0
.stats-bar
  display: flex
  justify-content: space-between
  padding: 0 1rem
.merge-btns
  display: flex
  justify-content: space-around
.v-dialog > .v-card > .tx-preview-form
  padding: 0 !important
  .form-content
    padding: 1rem
</style>

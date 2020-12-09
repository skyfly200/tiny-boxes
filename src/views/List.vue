<template lang="pug">
  .list
    v-btn(to="/create" color="#3F51B5" fab bottom left fixed large)
        v-icon(large) mdi-plus-box
    v-container(fluid)
      v-row(v-if="loading")
        v-col(align="center").tokens-loading
          v-progress-circular(indeterminate size="75" color="primary")
          h1 Fetching Tokens
          h3 Please Wait...
      template(v-else)
        v-data-iterator(:items="tokens" :items-per-page="itemsPerPageSelector")
          template(v-slot:header)
            v-toolbar
              v-spacer
              v-btn-toggle(v-model="ownerOnly" mandatory @change="changeUserOnly")
                v-btn(large depressed color="blue" :value="false")
                  v-icon mdi-earth
                v-btn(large depressed color="blue" :value="true")
                  v-icon mdi-account
          template(v-slot:default="{ items, isExpanded, expand }")
            v-row(no-gutters)
              v-col(v-for="t of items" :key="'token-col-'+t.id" align="center" xl="1" lg="2" md="3" sm="4" xs="6")
                v-card.token(:to="'/token/' + t.id" tile)
                  Token(:id="t.id" :data="t.art")
                  v-card-text.title {{ t.id }}
          v-col(v-if="count === 0").get-started
            v-card(align="center").get-started-card
              p {{ ownerOnly ? "You dont have any tokens yet!" : "No tokens have been minted yet" }}
              v-btn(v-if="tokens !== {} && !soldOut" to="/create" outlined color="secondary") Mint
              span(v-if="tokens !== {} && !soldOut && ownerOnly") &nbsp;or&nbsp;
              v-btn(v-if="ownerOnly" to="opensea.io" outlined color="secondary") Buy
</template>

<script>
import { mapGetters } from "vuex";
import Token from "@/components/Token.vue";

export default {
  name: "List",
  components: { Token },
  data: () => ({
    page: 1,
    itemsPerPageSelector: 10,
    count: null,
    supply: null,
    limit: null,
    ownerOnly: true,
    loading: true,
    soldOut: false,
    tokens: []
  }),
  computed: {
    pages() {
      return Math.floor(
        (this.ownerOnly ? this.count : this.supply) / this.itemsPerPageSelector + 1
      );
    },
    pageTokens() {
      const items = parseInt(this.itemsPerPageSelector);
      const start = (this.page - 1) * items;
      let end = start + items + 1;
      if (end > this.supply) end = parseInt(this.supply);
      const idList = Object.keys(this.tokens).filter(i => i>=start && i<=end);
      return idList.map( id => ({ id: id, data: this.tokens[id]}) );
    },
    ...mapGetters(["currentAccount", "itemsPerPage"])
  },
  mounted: async function() {
    await this.$store.dispatch("initialize");
    this.page = this.$route.params.page ? parseInt(this.$route.params.page) : 1;
    this.loadTokens();
    this.limit = await this.lookupLimit();
    this.supply = await this.lookupSupply();
    this.soldOut = this.supply === this.limit;
    this.loading = false;
  },
  methods: {
    changeUserOnly() {
      this.page = 0;
      this.loadTokens();
    },
    lookupToken: function(id, animate) {
      return this.$store.state.contracts.tinyboxes.methods.tokenArt(id, animate).call();
    },
    lookupSupply: function() {
      return this.$store.state.contracts.tinyboxes.methods.totalSupply().call();
    },
    lookupBalance: function() {
      return this.$store.state.contracts.tinyboxes.methods.balanceOf(this.currentAccount).call();
    },
    lookupUsersToken(i) {
      return this.$store.state.contracts.tinyboxes.methods.tokenOfOwnerByIndex(this.currentAccount, i).call();
    },
    lookupLimit: function() {
      return this.$store.state.contracts.tinyboxes.methods.TOKEN_LIMIT().call();
    },
    loadTokens: async function() {
      this.tokens = [];
      if (this.page > this.pages) this.page = this.pages; // clamp page value in range
      this.count = this.ownerOnly ? await this.lookupBalance() : await this.lookupSupply();
      const start = (this.page - 1) * this.itemsPerPageSelector;
      for (let i = start; i - start < this.itemsPerPageSelector && i < this.count; i++) {
        const id = this.ownerOnly ? await this.lookupUsersToken(i) : i;
        this.loadToken(id);
      }
    },
    async loadToken(tokenID) {
      this.$set(this.tokens, tokenID, {
        id: tokenID,
        art: await this.lookupToken(tokenID, false),
      });
    },
    listenForTokens: function() {
      const tokenSubscription = this.$store.state.web3.eth
        .subscribe("logs", {
          address: this.$store.state.tinyboxesAddress,
          topics: [
            "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
            "0x0000000000000000000000000000000000000000000000000000000000000000",
            "0x000000000000000000000000" + this.currentAccount.slice(2)
          ]
        })
        .on(
          "data",
          async function(log) {
            const id = parseInt(log.topics[3], 16);
            // lookup new supply and check if sold out
            this.supply = await this.lookupSupply();
            this.soldOut = this.supply === this.limit;
            // rerender token list
            this.loadToken(id);
          }.bind(this)
        )
        .on("error", function(log) {
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

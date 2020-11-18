<template lang="pug">
  .list
    v-btn(to="/create" color="#3F51B5" fab bottom right fixed large)
        v-icon(large) mdi-plus-box
    v-container(fluid)
      v-row(v-if="loading")
        v-col(align="center").tokens-loading
          v-progress-circular(indeterminate size="75" color="primary")
          h1 Fetching Tokens
          h3 Please Wait...
      template(v-else)
        v-row(v-if="pages > 1")
          v-col(align="center")
            v-pagination(v-model="page" circle @input="loadTokens" :length="pages")
        v-row(no-gutters)
          v-col(v-for="i in pageTokens" :key="i + '-token'" align="center" xl="1" lg="2" md="3" sm="4" xs="6")
            v-card.token(:to="'/token/' + i" tile)
              v-skeleton-loader(v-if="!tokensLoaded[i]" transition-group="fade-transition" height="16.666vw" type="image")
              Token(v-else :id="i" :data="tokens[i]")
              v-card-text.title {{ i }}
          v-col(v-if="count === 0").get-started
            v-card(align="center").get-started-card
              p {{ ownerOnly ? "You dont have any tokens yet!" : "No tokens have been minted yet" }}
              v-btn(v-if="tokens !== {} && !soldOut" to="/create" outlined color="secondary") Mint
              span(v-if="tokens !== {} && !soldOut && ownerOnly") &nbsp;or&nbsp;
              v-btn(v-if="ownerOnly" to="opensea.io" outlined color="secondary") Buy
        v-row(v-if="pages > 1")
          v-col(align="center" md="2" offset-sm="5" xs="4" offset-xs="4")
            v-pagination(v-model="page" circle @click="loadTokens" :length="pages")
            v-combobox.page-items(v-model="itemsPerPageSelector" @change="selectItemsPerPage" dense hint="Tokens per page" label="Tokens per page" menu-props="top" :items='["12","18","24","36","48","96"]')
</template>

<script>
import { tinyboxesAddress } from "../tinyboxes-contract";
import { mapGetters } from "vuex";
import Token from "@/components/Token.vue";

export default {
  name: "List",
  components: { Token },
  data: () => ({
    page: 1,
    itemsPerPageSelector: 12,
    count: null,
    supply: null,
    limit: null,
    ownerOnly: false,
    loading: true,
    soldOut: false,
    tokenIDs: [],
    tokensLoaded: {},
    tokens: {}
  }),
  computed: {
    pages() {
      return Math.floor(
        (this.ownerOnly ? this.count : this.supply) / this.itemsPerPage + 1
      );
    },
    pageTokens() {
      const start = (this.page - 1) * this.itemsPerPage;
      const end = start + this.itemsPerPage + 1;
      return this.tokenIDs.slice(start, end > this.supply ? this.supply : end);
    },
    ...mapGetters(["currentAccount", "itemsPerPage"])
  },
  mounted: async function() {
    await this.$store.dispatch("initialize");
    this.itemsPerPageSelector = this.itemsPerPage;
    // TODO: check if page param is within range
    this.page = this.$route.params.page ? parseInt(this.$route.params.page) : 1;
    this.loadTokens();
    this.limit = await this.lookupLimit();
    this.supply = await this.lookupSupply();
    this.soldOut = this.supply === this.limit;
  },
  methods: {
    selectItemsPerPage() {
      this.$store.commit("setItemsPerPage", this.itemsPerPageSelector);
      this.loadTokens();
    },
    lookupToken: function(id, animate) {
      return this.$store.state.contracts.tinyboxes.methods.tokenArt(id, animate).call();
    },
    lookupSupply: function() {
      return this.$store.state.contracts.tinyboxes.methods.totalSupply().call();
    },
    lookupLimit: function() {
      return this.$store.state.contracts.tinyboxes.methods.TOKEN_LIMIT().call();
    },
    loadTokens: async function() {
      this.tokens = {};
      this.tokenIDs = [];
      if (this.page > this.pages) this.page = this.pages;
      if (this.ownerOnly) {
        // load only tokens that you own
        this.count = await this.$store.state.contracts.tinyboxes.methods
          .balanceOf(this.currentAccount)
          .call();
        this.$store.commit("setCount", this.count);
      }
      const max = this.ownerOnly ? this.count : await this.lookupSupply();
      const start = (this.page - 1) * this.itemsPerPage;
      for (let i = start; i - start < this.itemsPerPage && i < max; i++) {
        if (this.ownerOnly)
          this.$store.state.contracts.tinyboxes.methods
            .tokenOfOwnerByIndex(this.currentAccount, i)
            .call()
            .then(id => {
              this.loadToken(id);
              this.$set(this.tokenIDs, i, id);
            });
        else {
          this.loadToken(i);
          this.$set(this.tokenIDs, i, i);
        }
      }
    },
    loadToken(tokenID) {
      const data = this.$store.state.cachedTokens[tokenID];
      this.lookupToken(tokenID, false).then(result => {
        this.$set(this.tokens, tokenID, data && data.art ? data.art : result);
        this.$set(this.tokensLoaded, tokenID, true);
        this.loading = false;
      });
    },
    listenForTokens: function() {
      const tokenSubscription = this.$store.state.web3.eth
        .subscribe("logs", {
          address: tinyboxesAddress,
          topics: [
            "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
            "0x0000000000000000000000000000000000000000000000000000000000000000",
            "0x000000000000000000000000" + this.currentAccount.slice(2)
          ]
        })
        .on(
          "data",
          async function(log) {
            const index = parseInt(log.topics[3], 16);
            this.tokens[index] = await this.lookupToken(index, false);
            // lookup new supply and check if sold out
            this.supply = await this.lookupSupply();
            this.soldOut = this.supply === this.limit;
            // rerender token list
            this.loadTokens();
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

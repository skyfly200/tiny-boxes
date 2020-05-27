<template lang="pug">
  .collection
    v-app-bar(v-if="tokens !== {} && !soldOut" absolute collapse dense)
      v-btn(to="/create") Create
    v-container
      v-row(v-if="loading")
        v-col(align="center").tokens-loading
          v-progress-circular(indeterminate size="75" color="primary")
          h1 Fetching Tokens
          h3 Please Wait...
      template(v-else)
        v-row
          v-col(align="center")
            v-pagination(v-model="page" circle @input="loadTokens" :length="pages")
        v-row(no-gutters)
          v-col(v-for="i in pageTokens" :key="i + '-token'" align="center" xl="3" lg="4" md="6" sm="12")
            v-card.token
              v-card-title 
                span {{ "#" + i }}
              v-card-text.token-wrapper
                  Token(:id="i" :data="tokens[i]")
              v-divider
              v-card-actions
                v-btn(:to="'/token/' + i") View
          v-col(v-if="count === 0").get-started
            v-card(align="center").get-started-card
              p You dont have any tokens yet!
              v-btn(outlined color="secondary") Mint
              span &nbsp;or&nbsp;
              v-btn(outlined color="secondary") Buy
              p one to get started
        v-row(justify="center")
          v-col(align="center" md="2" offset-sm="5" xs="4" offset-xs="4")
            v-pagination(v-model="page" circle @click="loadTokens" :length="pages")
            v-combobox.page-items(v-model="itemsPerPageSelector" @change="selectItemsPerPage" dense hint="Tokens per page" label="Tokens per page" menu-props="top" :items='["12","18","24","36","48","96"]')
    v-dialog(v-model="dialog" persistent max-width="600px" @keydown.enter="tx.send(); dialog = false" @keydown.esc="dialog = false" @keydown.delete="dialog = false")
      v-card.tx-preview
        v-card-title {{ tx.title }}
        v-card-subtitle Transaction Preview
        v-card-text.tx-preview-form
          p {{ tx.message }}
          h3 Fee: {{ tx.fee }} Eth
          h3 Current Account: {{ currentAccount }}
        v-card-actions
          v-btn(class="mt-6" text color="success" @click="tx.send(); dialog = false") Submit
          v-spacer
          v-btn(class="mt-6" text color="error" @click="dialog = false") Cancel
</template>

<script>
import { tinyboxesAddress } from "../tinyboxes-contract";
import { mapGetters } from "vuex";
import Token from "@/components/Token.vue";

export default {
  name: "Collection",
  components: { Token },
  data: () => ({
    page: 1,
    dialog: false,
    tx: {},
    itemsPerPageSelector: 12,
    count: null,
    limit: null,
    ownerOnly: false,
    loading: true,
    tokenIDs: [],
    tokensLoading: {},
    tokens: {}
  }),
  computed: {
    selecting() {
      return this.merge[0] !== null;
    },
    pages() {
      return Math.floor(this.count / this.itemsPerPage + 1);
    },
    soldOut() {
      return this.lookupSupply() < this.limit;
    },
    pageTokens() {
      const start = (this.page - 1) * this.itemsPerPage;
      return this.tokenIDs.slice(start + 1, start + this.itemsPerPage + 1);
    },
    ...mapGetters(["currentAccount", "itemsPerPage"])
  },
  mounted: async function() {
    await this.$store.dispatch("initialize");
    this.itemsPerPageSelector = this.itemsPerPage;
    // check if page param is within range
    this.page = this.$route.params.page ? parseInt(this.$route.params.page) : 1;
    await this.loadTokens();
    this.limit = this.lookupLimit();
  },
  methods: {
    selectItemsPerPage() {
      this.$store.commit("setItemsPerPage", this.itemsPerPageSelector);
      this.loadTokens();
    },
    lookupToken: function(id) {
      return this.$store.state.contracts.tinyboxes.methods.tokenArt(id).call();
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
      if (this.ownerOnly) { // load only tokens that you own
        this.count = await this.$store.state.contracts.tinyboxes.methods
          .balanceOf(this.currentAccount)
          .call();
        this.$store.commit("setCount", this.count);
        const start = (this.page - 1) * this.itemsPerPage;
        for (let i = 0; i < this.itemsPerPage && start + i < this.count; i++) {
          const index = start + i;
          const tokenID = await this.$store.state.contracts.tinyboxes.methods
            .tokenOfOwnerByIndex(this.currentAccount, index)
            .call();
          this.$set(this.tokenIDs, index, tokenID);
          this.$set(this.tokensLoading, tokenID, true);
          this.loading = false;
          const data = this.$store.state.cachedTokens[tokenID];
          if (data) {
            this.$set(this.tokens, tokenID, data);
            this.$set(this.tokensLoading, tokenID, false);
          } else {
            this.lookupToken(tokenID).then(resp => {
              this.$store.commit("setToken", { id: tokenID, data: resp });
              this.$set(this.tokens, tokenID, resp);
              this.$set(this.tokensLoading, tokenID, false);
            });
          }
        }
      } else { // load all
        const start = (this.page - 1) * this.itemsPerPage;
        this.lookupSupply().then((supply) => {
          for (let i = 0; i < this.itemsPerPage && start + i < supply; i++) {
            const tokenID = start + i + 1;
            this.$set(this.tokenIDs, tokenID, tokenID);
            this.$set(this.tokensLoading, tokenID, true);
            this.loading = false;
            const data = this.$store.state.cachedTokens[tokenID];
            if (data) {
              this.$set(this.tokens, tokenID, data);
              this.$set(this.tokensLoading, tokenID, false);
            } else {
              this.lookupToken(tokenID).then(resp => {
                this.$store.commit("setToken", { id: tokenID, data: resp });
                this.$set(this.tokens, tokenID, resp);
                this.$set(this.tokensLoading, tokenID, false);
              });
            }
          }
        });
      }
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
          function(log) {
            const index = parseInt(log.topics[3], 16);
            this.lookupToken(index).then(resp => (this.tokens[index] = resp));
            this.loadTokens();
          }.bind(this)
        )
        .on("error", function(log) {
          this.listenForTokens();
        });
    },
    previewTX(type) {
      const types = {
        mint: {
          title: "Mint",
          message: "Mint a new TinyBox token",
          fee: 0.3,
          send: this.mintToken
        },
      };
      this.tx = types[type];
      this.dialog = true;
    },
  }
};
</script>

<style lang="sass" scoped>
.token
  margin: 1rem
.token-wrapper
  padding: 0
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
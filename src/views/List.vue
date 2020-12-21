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
        v-data-iterator(:items="tokens" :page="page" :items-per-page="itemsPerPageSelector")
          template(v-slot:header)
            v-toolbar
              v-spacer
              v-btn-toggle(v-if="web3Status === 'active'" v-model="mode" mandatory @change="changeMode")
                v-tooltip(bottom)
                    template(v-slot:activator="{ on }")
                      v-btn(large v-on="on" :depressed="mode === 'all'" color="blue" value="all")
                        v-icon mdi-earth
                    span All Boxes
                v-tooltip(bottom)
                    template(v-slot:activator="{ on }")
                      v-btn(large v-on="on" :depressed="mode === 'owned'" color="purple" value="owned")
                        v-icon mdi-account
                    span Your Boxes
          template(v-slot:default="{ items, isExpanded, expand }")
            v-row
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

<script lang="ts">
import { mapGetters } from "vuex";
import Token from "@/components/Token.vue";

export default {
  name: "List",
  components: { Token },
  data: () => ({
    mode: "",
    itemsPerPageSelector: 20,
    count: null,
    userCount: null,
    supply: null,
    limit: null,
    loading: true,
    soldOut: false,
    tokens: [] as any,
    values: {} as any,
  }),
  computed: {
    page: {
      get() {
        return parseInt(this.$route.params.page);
      },
      set(page: number) {
        this.$route.params.page = page.toString;
      }
    },
    ownerOnly() {
      return this.mode === "owned";
    },
    ...mapGetters(["currentAccount", "web3Status", "itemsPerPage"])
  },
  mounted: async function() {
    this.loading = true;
    await this.$store.dispatch("initialize");
    //this.page = this.$route.params.page ? parseInt(this.$route.params.page) : 1;
    this.limit = await this.lookupLimit();
    this.supply = await this.lookupSupply();
    this.userCount = await this.lookupBalance();
    this.soldOut = this.supply === this.limit;
    this.loadTokens();
  },
  methods: {
    changeMode() {
      this.loadTokens();
    },
    lookupToken: function(id: any, animate: any) {
      return this.$store.state.contracts.tinyboxes.methods.tokenArt(id, animate).call();
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
      this.tokens = [];
      this.count = this.ownerOnly ? this.userCount : this.supply;
      this.loading = false;
      for (let i = 0; i < this.count; i++) {
        this.ownerOnly ?
          this.lookupUsersToken(i).then( (result: any) => this.loadToken(result, i)) :
          this.loadToken(i);
      }
    },
    loadToken(tokenID: any, index: any) {
      this.lookupToken(tokenID, false).then( (result: any) => {
        this.$set(this.tokens, this.ownerOnly ? index : tokenID, {
          id: tokenID,
          art: result,
        });
      });
    },
    listenForMyTokens: function() {
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
          async function(log: any) {
            const id = parseInt(log.topics[3], 16);
            // lookup new user balance
            this.userCount = await this.lookupBalance();
            // rerender token list
            if (this.ownerOnly) this.loadToken(id);
          }.bind(this)
        )
        .on("error", function(log: any) {
          this.listenForTokens();
        });
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
            if (!this.ownerOnly) this.loadToken(id);
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

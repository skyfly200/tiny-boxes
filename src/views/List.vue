<template lang="pug">
  .list
    v-btn(to="/create" color="secondary" fab bottom left fixed large)
        v-icon(large) mdi-plus-box
    v-container(fluid)
      v-data-iterator(:items="loadedTokens" :page.sync="page" @update:page="setPage" :sort-desc="sortDesc"
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
            v-tooltip(v-if="false && web3Status === 'active'" bottom)
                template(v-slot:activator="{ on }")
                  v-btn(large icon v-on="on" @click="sortDesc = !sortDesc" :depressed="sortDesc" color="purple")
                    v-icon {{ sortDesc ? "mdi-sort-numeric-ascending" : "mdi-sort-numeric-descending"}}
                span {{ sortDesc ? "Ascending" : "Descending" }}
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
                Token(:id="t.id" :data="t.art" cached="true")
                v-card-text.title {{ t.title }}
        template(v-slot:no-data)
          v-row.get-started
            v-col(cols="12")
              v-card(align="center").get-started-card
                p {{ "No tokens could be loaded" }}
                v-btn(v-if="!soldOut" to="/create" outlined color="secondary") Create
                span(v-if="tokens !== {} && !soldOut") &nbsp;or&nbsp;
                v-btn(v-if="tokens !== {}" :to="openseaStoreURL" outlined color="secondary") Buy
</template>

<script lang="ts">
import { mapGetters, mapState } from "vuex";
import Token from "@/components/Token.vue";

const t = this as any;

export default {
  name: "List",
  components: { Token },
  data: () => ({
    itemsPerPageArray: [4, 8, 12],
    search: '',
    filter: {},
    sortDesc: false,
    bkg: 0,
    page: 0,
    itemsPerPageSelector: 20,
    max256: 115792089237316195423570985008687907853269984665640564039457584007913129639936n,
    count: null,
    userCount: null,
    supply: null,
    limit: null,
    loading: true,
    soldOut: false,
    tokens: {
      0: {},
    } as any,
    values: {} as any,
  }),
  computed: {
    loadedTokens() {
      const t = this as any;
      return Object.keys(t.tokens)
        .sort( (a,b) => parseInt(a) - parseInt(b))
        .map( i => t.tokens[i] );
    },
    ...mapGetters(["currentAccount", "web3Status", "itemsPerPage"]),
    ...mapState(["openseaStoreURL"]),
  },
  mounted: async function() {
    const t = this as any;
    await t.$store.dispatch("initialize");
    t.limit = 2222; // await t.lookupLimit();
    t.supply = 1421; // await t.lookupSupply();
    t.soldOut = t.supply === t.limit;
    //t.page = t.$route.params.page ? parseInt(this.$route.params.page) : 1;
    t.page = parseInt(t.$route.params.page, 10);
    t.loadTokens();
  },
  methods: {
    setPage(e: any) {
      (this as any).$router.push({ params: {page: e} })
    },
    lookupArt: function(id: any) {
      return (this as any).$store.state.contracts.tinyboxes.methods.tokenArt(id, (this as any).bkg, 10, 0, '').call();
    },
    lookupSupply: function() {
      return (this as any).$store.state.contracts.tinyboxes.methods.totalSupply().call();
    },
    lookupTokenByIndex(i: any) {
      return (this as any).$store.state.contracts.tinyboxes.methods.tokenByIndex(i).call();
    },
    lookupLimit: function() {
      return (this as any).$store.state.contracts.tinyboxes.methods.TOKEN_LIMIT().call();
    },
    loadTokens: async function() {
      const t = this as any;
      t.tokens = {};
      t.count = t.supply;
      const delay = async (ms: any) => await new Promise(resolve => setTimeout(resolve, ms));
      for (let i = 0; i < t.count; i++) {
        const id = await t.lookupTokenByIndex(i);
        t.loadToken(id);
        delay(1000);
      }
    },
    loadToken: async function(tokenID: any) {
      const t = this as any;
      const artPromise = ""; //t.lookupArt(tokenID);
      const art = ''; //await artPromise;
      t.$set(t.tokens, tokenID, {
        id: tokenID,
        title: tokenID > 100000 ? (BigInt(tokenID) - t.max256).toString() : tokenID,
        art: art,
      });
      t.loading = false;
    },
    listenForTokens: function() {
      const t = this as any;
      const tokenSubscription = t.$store.state.web3.eth
        .subscribe("logs", {
          address: t.$store.state.tinyboxesAddress,
          topics: [
            "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
            "0x0000000000000000000000000000000000000000000000000000000000000000"
          ]
        })
        .on(
          "data",
          async function(log: any) {
            const id = BigInt(log.topics[3]);
            // lookup new supply and check if sold out
            t.supply = await t.lookupSupply();
            t.soldOut = t.supply === t.limit;
            // rerender token list
            t.loadToken(id);
          }.bind(t)
        )
        .on("error", function(log: any) {
          t.listenForTokens();
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

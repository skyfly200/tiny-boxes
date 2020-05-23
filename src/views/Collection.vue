<template lang="pug">
  .collection
    v-app-bar(v-if="cells !== {}" absolute collapse dense)
      v-btn(@click="previewTX('mint')") Mint
    v-container
      v-row(v-if="loading")
        v-col(align="center").tokens-loading
          v-progress-circular(indeterminate size="75" color="primary")
          h1 Fetching Tokens
          h3 Please Wait...
      template(v-else)
        v-row
          v-col(align="center")
            v-pagination(v-model="page" circle @input="loadCells" :length="pages")
        v-row(no-gutters)
          v-col(v-for="i in pageCells" :key="i + '-' + cells[i].mass" align="center" xl="3" lg="4" md="6" sm="12")
            v-card.token(:class="{ 'selected-token': (merge[0] === i || merge[1] === i) }")
              v-card-title 
                span {{ "#" + i }}
              v-card-text.token-wrapper
                  Token(:id="0" :data="{}")
              v-divider
              v-card-actions
                v-btn(:to="'/cell/' + i") View
          v-col(v-if="count === 0").get-started
            v-card(align="center").get-started-card
              p You dont have any tokens yet!
              v-btn(outlined color="secondary") Mint
              span &nbsp;or&nbsp;
              v-btn(outlined color="secondary") Buy
              p one to get started
        v-row(justify="center")
          v-col(align="center" md="2" offset-sm="5" xs="4" offset-xs="4")
            v-pagination(v-model="page" circle @click="loadCells" :length="pages")
            v-combobox.page-items(v-model="itemsPerPage" @change="selectItemsPerPage" dense hint="Cells per page" label="Tokens per page" menu-props="top" :items='["12","18","24","36","48","96"]')
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
import { cellAddress } from "../cell-contract";
import { mapGetters } from "vuex";
import Token from "@/components/Token.vue";

export default {
  name: "Collection",
  components: { Token },
  data: () => ({
    page: 1,
    itemsPerPage: 12, // this.$store.itemsPerPage
    dialog: false,
    tx: {},
    mergeCompare: false,
    merge: [null, null],
    divide: null,
    count: null,
    loading: true,
    cellIDs: [],
    cellsLoading: {},
    cells: {}
  }),
  computed: {
    selecting() {
      return this.merge[0] !== null;
    },
    pages() {
      return Math.floor(this.count / this.itemsPerPage + 1);
    },
    pageCells() {
      const start = (this.page - 1) * this.itemsPerPage;
      return this.cellIDs.slice(start, start + this.itemsPerPage);
    },
    ...mapGetters(["currentAccount", "itemsPerPage"])
  },
  mounted: async function() {
    await this.$store.dispatch("initialize");
    this.itemsPerPage = this.$store.itemsPerPage;
    // check if page param is within range
    this.page = this.$route.params.page ? parseInt(this.$route.params.page) : 1;
    await this.loadCells();
  },
  methods: {
    selectItemsPerPage() {
      this.$store.commit("setItemsPerPage", this.itemsPerPage);
      this.loadCells();
    },
    lookupCell: function(id) {
      return this.$store.state.contracts.cell.methods.get(id).call();
    },
    loadCells: async function() {
      this.cells = {};
      this.cellIDs = [];
      this.count = await this.$store.state.contracts.cell.methods
        .balanceOf(this.currentAccount)
        .call();
      this.$store.commit("setCount", this.count);
      if (this.page > this.pages) this.page = this.pages;
      const start = (this.page - 1) * this.itemsPerPage;
      for (let i = 0; i < this.itemsPerPage && start + i < this.count; i++) {
        const index = start + i;
        const cellID = await this.$store.state.contracts.cell.methods
          .tokenOfOwnerByIndex(this.currentAccount, index)
          .call();
        this.$set(this.cellIDs, index, cellID);
        this.$set(this.cellsLoading, cellID, true);
        this.loading = false;
        const data = this.$store.state.cachedCells[cellID];
        if (data) {
          this.$set(this.cells, cellID, data);
          this.$set(this.cellsLoading, cellID, false);
        } else {
          this.lookupCell(cellID).then(resp => {
            this.$store.commit("setCell", { id: cellID, data: resp });
            this.$set(this.cells, cellID, resp);
            this.$set(this.cellsLoading, cellID, false);
          });
        }
      }
    },
    listenForCells: function() {
      const cellsSubscription = this.$store.state.web3.eth
        .subscribe("logs", {
          address: cellAddress,
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
            this.lookupCell(index).then(resp => (this.cells[index] = resp));
            this.loadCells();
          }.bind(this)
        )
        .on("error", function(log) {
          this.listenForCells();
        });
    },
    previewTX(type) {
      const types = {
        mint: {
          title: "Mint Cell",
          message: "Mint a new CELL token",
          fee: 0.008,
          send: this.mintCell
        },
        merge: {
          title: "Merge Cells",
          message: `Merge CELL tokens ${this.merge[0]} and ${this.merge[1]}`,
          fee: 0.002,
          send: this.mergeCells
        },
        divide: {
          title: "Divide Cell",
          message: `Divide CELL token ${this.divide}`,
          fee: 0.002,
          send: this.divideCell
        }
      };
      this.tx = types[type];
      this.dialog = true;
    },
    mintCell: function() {
      this.$store.state.web3.eth.sendTransaction({
        from: this.currentAccount,
        to: cellAddress,
        value: this.$store.state.web3.utils.toWei("8", "finney"),
        data: this.$store.state.contracts.cell.methods
          .mint(699823429231)
          .encodeABI()
      });
      this.listenForCells();
    }
  }
};
</script>

<style lang="sass" scoped>
.token
  margin: 1rem
.token-wrapper
  padding: 0
.selected-token
  border: solid #ffc107 2px
  box-shadow: 0 0 20px 0 rgba(255,255,255,0.2)
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
<template lang="pug">
  .collection
    v-app-bar(v-if="cells !== {}" absolute collapse dense)
      v-btn(@click="previewTX('mint')") Mint
    v-container
      v-row(v-if="loading")
        v-col(align="center").cells-loading
          v-progress-circular(indeterminate size="75" color="primary")
          h1 Fetching Your Cells
          h3 Please Wait...
      template(v-else)
        v-row
          v-col(align="center")
            v-pagination(v-model="page" circle @input="loadCells" :length="pages")
        v-row(no-gutters)
          v-col(v-for="i in pageCells" :key="i + '-' + cells[i].mass" align="center" xl="3" lg="4" md="6" sm="12")
            v-card.cell(:class="{ 'selected-cell': (merge[0] === i || merge[1] === i) }")
              v-card-title 
                span {{ "#" + i }}
                v-spacer 
                v-skeleton-loader(v-if="cellsLoading[i]" transition-group="fade-transition" height="50" type="avatar")
                Level(v-else :mass="cells[i].mass")
              v-card-text.cell-wrapper
                v-skeleton-loader(:loading="cellsLoading[i]" transition-group="fade-transition" height="320" type="image")
                  Cell(:id="i" :data="cells[i]")
              v-divider
              v-card-actions
                v-btn(:to="'/cell/' + i") View
                v-spacer
                v-btn(v-if="!merge[0]" :disabled="i === merge[0]" color="primary" @click="setMerge(0, i)")
                  v-icon mdi-call-merge
                  span Merge
                v-btn(v-else-if="i === merge[0]" color="warning" @click="clearMerge") Cancel
                v-btn(v-else color="success" @click="setMerge(1, i)") Select
                v-btn(color="primary" @click="divide = i; previewTX('divide')")
                  v-icon mdi-call-split
                  span Divide
          v-col(v-if="count === 0").get-started
            v-card(align="center").get-started-card
              p You dont have any cells yet!
              v-btn(outlined color="secondary") Mint
              span &nbsp;or&nbsp;
              v-btn(outlined color="secondary") Buy
              p one to get started
        v-row(justify="center")
          v-col(align="center" md="2" offset-sm="5" xs="4" offset-xs="4")
            v-pagination(v-model="page" circle @click="loadCells" :length="pages")
            v-combobox.page-items(v-model="itemsPerPage" @change="selectCellsPerPage" dense hint="Cells per page" label="Cells per page" menu-props="top" :items='["12","18","24","36","48","96"]')
    v-bottom-sheet(v-model="mergeCompare" inset persistent @keydown.enter="previewTX('merge'); mergeCompare = false" @keydown.esc="clearMerge()" @keydown.delete="clearMerge()")
      v-sheet(v-if="mergeCompare" align="center" height="430px")
        v-container
          v-row
            template(v-for="i in merge")
              v-col(:key="i")
                .stats-bar
                  span {{ "#" + i }}
                  .mass
                    span {{ cells[i].mass }}
                    v-icon(large) mdi-atom
                  Level(:mass="cells[i].mass")
                Cell(:id="'merge' + i" :data="cells[i]")
              v-divider(v-if="i === merge[0]" vertical)
        .merge-btns
          v-btn(class="mt-6" text color="success" @click="previewTX('merge'); mergeCompare = false") Merge
          v-btn(class="mt-6" text color="error" @click="clearMerge()") Cancel
    v-dialog(v-model="dialog" persistent max-width="600px" @keydown.enter="tx.send(); dialog = false" @keydown.esc="clearMerge(); dialog = false" @keydown.delete="clearMerge(); dialog = false")
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
          v-btn(class="mt-6" text color="error" @click="clearMerge(); dialog = false") Cancel
</template>

<script>
import Cell from "@/components/Cell.vue";
import Level from "@/components/Level.vue";
import { cellAddress, cellABI } from "../cell-contract";
import { mapGetters } from "vuex";

import cellUtils from "@/mixins/cellUtils";

export default {
  name: "Collection",
  mixins: [cellUtils],
  components: { Cell, Level },
  data: () => ({
    page: 1,
    itemsPerPage: 12, // this.$store.cellsPerPage
    dialog: false,
    tx: {},
    mergeCompare: false,
    merge: [null, null],
    divide: null,
    count: null,
    loading: true,
    cellIDs: [],
    cellsLoading: {},
    cells: {},
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
      return this.cellIDs.slice(start, (start + this.itemsPerPage));
    },
    ...mapGetters(['currentAccount', 'cellsPerPage']),
  },
  mounted: async function() {
    await this.$store.dispatch('initialize');
    this.itemsPerPage = this.cellsPerPage;
    // check if page param is within range
    this.page = this.$route.params.page ? parseInt(this.$route.params.page) : 1;
    await this.loadCells();
  },
  methods: {
    selectCellsPerPage() {
      this.$store.commit('setCellsPerPage', this.itemsPerPage);
      this.loadCells();
    },
    clearMerge() {
      this.mergeCompare = false;
      this.merge = [null, null];
    },
    setMerge(x, i) {
      this.merge[x] = i;
      this.mergeCompare = this.merge[0] && this.merge[1];
    },
    lookupCell: function(id) {
      return this.$store.state.contracts.cell.methods.get(id).call();
    },
    loadCells: async function() {
      this.cells = {};
      this.cellIDs = [];
      this.clearMerge();
      this.count = await this.$store.state.contracts.cell.methods.balanceOf(this.currentAccount).call();
      this.$store.commit('setCount', this.count);
      if (this.page > this.pages) this.page = this.pages;
      const start = (this.page - 1) * this.itemsPerPage;
      for (let i = 0; i < this.itemsPerPage && (start + i) < this.count; i++) {
        const index = start + i;
        const cellID = await this.$store.state.contracts.cell.methods.tokenOfOwnerByIndex(this.currentAccount, index).call();
        this.$set(this.cellIDs, index, cellID);
        this.$set(this.cellsLoading, cellID, true);
        this.loading = false;
        const data = this.$store.state.cachedCells[cellID];
        if (data) {
          this.$set(this.cells, cellID, data);
          this.$set(this.cellsLoading, cellID, false);
        } else {
          this.lookupCell(cellID).then((resp) => {
            this.$store.commit('setCell', {id: cellID, data: resp});
            this.$set(this.cells, cellID, resp);
            this.$set(this.cellsLoading, cellID, false);
          });
        }
      }
    },
    listenForCells: function() {
      const cellsSubscription = this.$store.state.web3.eth.subscribe('logs', {
          address: cellAddress,
          topics: [
            '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef', 
            '0x0000000000000000000000000000000000000000000000000000000000000000',
            '0x000000000000000000000000' + this.currentAccount.slice(2)
          ],
      })
      .on("data", function(log){
        const index = parseInt(log.topics[3], 16)
        this.lookupCell(index).then((resp) => this.cells[index] = resp);
        this.loadCells();
      }.bind(this))
      .on("error", function(log){
        this.listenForCells();
      });
    },
    previewTX(type) {
      const types = {
        mint: {
          title: "Mint Cell",
          message: "Mint a new CELL token",
          fee: 0.008,
          send: this.mintCell,
        },
        merge: {
          title: "Merge Cells",
          message: `Merge CELL tokens ${this.merge[0]} and ${this.merge[1]}`,
          fee: 0.002,
          send: this.mergeCells,
        },
        divide: {
          title: "Divide Cell",
          message: `Divide CELL token ${this.divide}`,
          fee: 0.002,
          send: this.divideCell,
        },
      };
      this.tx = types[type];
      this.dialog = true;
    },
    mintCell: function() {
      this.$store.state.web3.eth.sendTransaction(
        {
          from: this.currentAccount,
          to: cellAddress,
          value: this.$store.state.web3.utils.toWei("8", "finney"),
          data: this.$store.state.contracts.cell.methods
            .mint(699823429231)
            .encodeABI()
        }
      );
      this.listenForCells()
    },
    divideCell: function() {
      this.$store.state.web3.eth.sendTransaction(
        {
          from: this.currentAccount,
          to: cellAddress,
          value: this.$store.state.web3.utils.toWei("2", "finney"),
          data: this.$store.state.contracts.cell.methods
            .split(this.divide)
            .encodeABI()
        }
      ).then((err, result) => {
        this.loadCells();
      });
      this.divide = null;
      this.listenForCells()
    },
    mergeCells: function() {
      this.$store.state.web3.eth.sendTransaction(
        {
          from: this.currentAccount,
          to: cellAddress,
          value: this.$store.state.web3.utils.toWei("2", "finney"),
          data: this.$store.state.contracts.cell.methods
            .merge(this.merge[0], this.merge[1])
            .encodeABI()
        }
      ).then((err, result) => {
        this.$delete(this.cells, this.merge[0]);
        this.$delete(this.cells, this.merge[1]);
        this.loadCells();
      });
      this.clearMerge();
      this.listenForCells()
    },
  },
};
</script>

<style lang="sass" scoped>
.cell
  margin: 1rem
.cell-wrapper
  padding: 0
.selected-cell
  border: solid #ffc107 2px
  box-shadow: 0 0 20px 0 rgba(255,255,255,0.2)
.cells-loading
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
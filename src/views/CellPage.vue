<template lang="pug">
  .cell-page
    v-container
      v-row(v-if="loading")
        v-col(align="center").cell-loading
            v-progress-circular(indeterminate size="75" color="primary")
            h1 Fetching Cell {{ "#" + id }}
      v-row(v-else)
        v-col(align="center")
          v-card
            .cell-stats
              span.id {{ "#" + id }}
              .mass
                span {{ data.mass }}
                v-icon(large) mdi-atom
              Level(:mass="data.mass")
            v-divider
            .cell-graphic
              Cell(:id="id" :data="data")
            v-divider
            .cell-info
              .ribbons
                v-chip(outlined color="secondary" v-if="founder")
                  v-icon(left) mdi-compass-rose
                  span Founder {{ parseInt(id) + 1 }} / 100
                v-chip(outlined color="secondary" v-if="mythical")
                  v-icon(left) mdi-crystal-ball
                  span Mythical
                v-chip(outlined color="secondary" v-if="cyborg")
                  v-icon(left) mdi-chip
                  span Cyborg
                v-chip(outlined color="secondary" v-if="pure")
                  v-icon(left) mdi-dna
                  span Pure
                v-chip(outlined color="secondary" v-if="complete")
                  v-icon(left) mdi-asterisk
                  span Complete
        v-col
          h1 Families
          GChart(type="PieChart" :data="familyChart" :options="familyChartOptions")

          h1 Features
          .features
            .feature
              v-chip(:color="intToColor(data.wallColor)" label) 
                span Cell Wall Shape # {{ data.wallWave % walls }} {{ data.wallRound ? "Rounded" : "" }}
            .feature(v-if="!data.nucleusHidden")
              v-chip(:color="intToColor(data.nucleusColor)" label) 
                span Nucleus
            .feature(v-for="f,i in data.featureCategories" :key="i")
              v-chip(:color="intToColor(data.featureColors[i])" label) 
                v-avatar
                  .count(left) {{ data.featureCounts[i] }}
                span {{ getFeatureFamily(data.featureFamilies[i]).title }} {{ getFeatureType(f, data.featureFamilies[i]).title }}
    
</template>

<script lang="ts">
import Vue from "vue";
import { mapGetters } from "vuex";
import { GChart } from 'vue-google-charts';
import Cell from "@/components/Cell.vue";
import Level from "@/components/Level.vue";
import { cellAddress, cellABI } from "@/cell-contract";
import cellUtils from "@/mixins/cellUtils";
import cellRender from "@/mixins/cellRender";

export default Vue.extend({
  name: "CellPage",
  mixins: [cellUtils, cellRender],
  components: { Cell, Level, GChart },
  computed: {
    id(): number {
      return parseInt(this.$route.params.id);
    },
    familyChart(): any {
      const sorted = (this as any).sortFamilies(this.data.featureFamilies);
      const titled = sorted.map((i: Array<any>) => [(this as any).getFeatureFamily(i[0]).title, i[1]]);
      return [this.familyChartHeader, ...titled];
    },
    familyChartOptions(): any {
      const sorted = (this as any).sortFamilies(this.data.featureFamilies);
      const slices = sorted.map((i: Array<any>) => ({ color: (this as any).getFeatureFamily(i[0]).color }));
      const options = { ...this.chartOptions, slices: slices };
      return options;
    },
    founder(): boolean {
      return this.id < this.founders;
    },
    mythical(): boolean {
      // first cell to unlock a new family
      return false;
    },
    cyborg(): boolean {
      // cells with natural and artificial features
      const natural = [0,1,2,3];
      const artificial = [4,5];
      return natural.reduce((acc,i) => acc || this.data.featureFamilies.includes(i.toString()), false )
        && artificial.reduce((acc,i) => acc || this.data.featureFamilies.includes(i.toString()), false );
    },
    pure(): boolean {
      return this.data.featureFamilies.reduce((acc: boolean, i: number) => acc && ( i === this.data.featureFamilies[0] ) );
    },
    complete(): boolean {
      // has all manditory features for the family
      return false;
    },
    ...mapGetters(['currentAccount']),
  },
  mounted: async function() {
    await this.$store.dispatch('initialize');
    await this.loadCell();
  },
  methods: {
    loadCell: function() {
      const cached = this.$store.state.cachedCells[this.id];
      if (cached) {
        this.data = cached;
        this.loading = false;
      } else {
        this.$store.state.contracts.cell.methods.get(this.id).call()
          .then((result: any) => {
            this.$store.commit('setCell', {id: this.id, data: result});
            this.data = result;
            this.loading = false;
          })
          // .catch( (err: any) => {
          //   console.error(err);
          // });
      }
    },
  },
  data: () => ({
    founders: 100,
    walls: 11,
    loading: true,
    data: {} as any,
    familyChartHeader: ['Family', 'Features'],
    chartOptions: {
      backgroundColor: "#121212",
      pieHole: 0.55,
      legend: {
        textStyle: {color: '#ffffff', fontSize: 16},
        position: 'labeled',
        maxLines: 8,
      },
      pieSliceText: 'none',
    },
  })
});
</script>

<style lang="sass" scoped>
.v-chip__content
  span
    color: #FFF !important
.content
  margin-top: 35vh
.id
  font-size: 2rem
.cell-loading
  padding-top: 40vh
.cell-stats
  padding: 1rem
  display: flex
  flex-direction: row
  justify-content: space-between
.cell-info
  padding: 0 1rem 1rem 1rem
.features
  margin: 2hv 1vw
  display: flex
  flex-wrap: wrap
.feature
  margin: 5px
  .v-chip
    border: 1px solid rgba(255,255,255,0.3) !important
    text-shadow: 0px 1px 5px #000000
</style>

<template lang="pug">
  .admin
    v-container(fluid)
      v-row
        v-col(align="center").token-title
          h1.title Admin Panel
      v-row
        v-col(cols="12")
          h1 Minting
          v-sparkline( :value="sales" auto-line-width auto-draw)
        v-col(cols="12")
          v-toolbar
            span Phase: {{ phase }} - {{ schemeTitles[phase] }}
            v-spacer
            span Phase Length: {{ phaseLen }}
            v-spacer
            span Created This Phase: {{ tokenCount === null ? '' : tokenCount % phaseLen }}
            v-spacer
            span Percent Sold: {{ ((tokenCount % phaseLen) / phaseLen * 100).toFixed(1) + "%" }} | {{ (tokenCount / 2222 * 100).toFixed(1) + "%" }}
            v-spacer
            span Total Created: {{ tokenCount }}
            v-spacer
          v-progress-linear(:indeterminate="false" :value="(tokenCount % phaseLen) / phaseLen * 100" striped height="1rem" color="secondary")
          v-progress-linear(:indeterminate="false" :value="tokenCount / limit * 100" striped height="1rem" color="accent")
      v-row(no-gutters)
        v-col(cols="12" md="4")
          v-card
            v-card-title Countdown
            v-card-text
              p Curent Block: {{ currentBlock }}
              p Mined At: {{ currentBlockTimestamp | dateTime }}
              br
              p Start Block: {{ blockStart }}
              p Aprox. Time (Local): {{ pauseEndTime | dateTime }}
              p Aprox. Time (UTC): {{ pauseEndTimeUTC | dateTime }}
              p Countdown: 
              vac(:end-time="(pauseEndTimestamp === null ? Date() : pauseEndTimestamp)")
                template(v-slot:process="{ timeObj }")
                  span {{ `${timeObj.m}:${timeObj.s}` }}
              v-divider.my-3
              p Set the countdown blockstart
              v-dialog(ref="dateDialog" v-model="datePicker" :return-value.sync="startDate" width="290px")
                template(v-slot:activator="{ on, attrs }")
                  v-text-field(v-model="startDate" label="Start Date" prepend-icon="mdi-calendar" readonly v-bind="attrs" v-on="on")
                v-date-picker(v-model="startDate" :min="new Date().toISOString().substr(0, 10)")
                  v-btn(text color="primary" @click="datePicker = false") Cancel
                  v-btn(text color="primary" @click="$refs.dateDialog.save(startDate)") Ok
              v-dialog(ref="timeDialog" v-model="timePicker" :return-value.sync="startTime" width="290px")
                template(v-slot:activator="{ on, attrs }")
                  v-text-field(v-model="startTime" label="Start Time" prepend-icon="mdi-clock" readonly v-bind="attrs" v-on="on")
                v-time-picker(v-model="startTime" :min="new Date().toISOString().substr(11)")
                  v-btn(text color="primary" @click="timePicker = false") Cancel
                  v-btn(text color="primary" @click="$refs.timeDialog.save(startTime)") Ok
              v-text-field(v-model="startBlock" @change="syncDateTimeToBlock" label="Block")
              v-btn(@click="setCountdown") Set
          v-card
            v-card-title Un/Pause Minting
            v-card-text
              p Curent State: {{ paused ? "Paused" : "Unpaused" }}
            v-card-actions
              v-btn(icon @click="setPause(!paused)")
                v-icon(large) {{ paused ? 'mdi-play' : 'mdi-pause' }}
          v-card
            v-card-title Metadata
            v-card-text
              p Contract URI:
              span
                a(:href="contractURI") {{ contractURI }}
              v-text-field(label="Contract URI")
              p Base URI:
              span
                a(:href="baseURI") {{ baseURI }}
              v-text-field(label="Base URI")
          v-card
            v-card-title Token Metadata
            v-card-text
              v-divider.my-3
              p Token ID
              v-text-field(v-model="tokenID" label="Token ID")
              v-btn Check
              p URI: {{  }}
              v-btn(@click="refreshTokenMetadata(tokenID)") Refresh
              v-divider
              p Set the Tokens URI
              v-text-field(label="Token URI")
            v-card-actions
              v-spacer
              v-btn Reset
              v-btn Save
        v-col(cols="12" md="8")
          v-card
            v-card-title LE Minter
            v-card-text
              p Mint a Limited Edition Token
              p {{ leCount }} of 100 Limited Editions Minted
              v-text-field(label="Recipient" v-model="leRecipient")
              v-btn(@click="mintLE") Mint
            v-progress-linear(:indeterminate="false" :value="leCount" striped height="1rem")
          v-card
            v-card-title Randomizer
            v-card-text
              .d-flex
                v-btn Test Randomizer
                p.ml-5 Randomness: {{  }}
              v-divider.my-3
              p Set the Randomizer Contract
              v-text-field(label="Randomizer")
              v-btn Update
          v-card
            v-card-title Renderer
            v-card-text
              p Set the Renderer Contract
              v-text-field(label="Randomizer")
            v-card-actions
              v-btn Test
              v-spacer
              v-btn Update
</template>

<script lang="ts">
import Vue from "vue";
import { mapGetters, mapState } from "vuex";
import dayjs from 'dayjs'
import utc from 'dayjs/plugin/utc';
import isBetween from 'dayjs/plugin/isBetween';

export default Vue.extend({
  name: "Admin",
  computed: {
    ...mapState({
        animationTitles: 'animationTitles',
        schemeTitles: 'schemeTitles',
    }),
    ...mapGetters(["currentAccount"]),
  },
  mounted: async function() {
    await this.$store.dispatch("initialize");
    const t = this as any;
    dayjs.extend(utc)
    dayjs.extend(isBetween)
    t.currentBlock = t.currentBlock = await t.$store.state.web3.eth.getBlockNumber();;
    t.currentBlockTimestamp = new Date().getTime() * 1000;
    t.loadStats();
    t.lookupPhaseLen();
    t.lookupContractURI();
    t.lookupBaseURI();
    t.listenForBlocks();
    //t.lookupSales();
  },
  beforeDestroy: function() {
    (this as any).unsubscribeBlocks();
  },
  filters: {
    dateTime: function (timestamp: any) {
      return !timestamp ? '' : (dayjs as any)(timestamp).format("h:mm:ss A DD/MM/YYYY");
    },
  },
  methods: {
    mintLE: async function(){
      const t = this as any;
      if (t.leRecipient !== '') {
        t.$store.state.web3.eth.sendTransaction({
          from: t.currentAccount,
          to: t.$store.state.tinyboxesAddress,
          data: t.$store.state.contracts.tinyboxes.methods
            .mintLE(this.leRecipient)
            .encodeABI(),
        },
          async (err: any, txHash: string) => {
            const t = this as any;
            if (err) t.overlay = err.code === 4001 ? "" : "error";
            t.leRecipient = '';
          }
        );
      }
    },
    setPause: async function(state: boolean){
      const t = this as any;
      t.$store.state.web3.eth.sendTransaction({
        from: t.currentAccount,
        to: t.$store.state.tinyboxesAddress,
        data: t.$store.state.contracts.tinyboxes.methods
          .setPause(state)
          .encodeABI(),
      },
        async (err: any, txHash: string) => {
          const t = this as any;
          if (err) t.overlay = err.code === 4001 ? "" : "error";
          t.leRecipient = '';
          t.lookupPause();
        }
      );
    },
    setCountdown: async function(){
      const t = this as any;
      t.$store.state.web3.eth.sendTransaction({
        from: t.currentAccount,
        to: t.$store.state.tinyboxesAddress,
        data: t.$store.state.contracts.tinyboxes.methods
          .startCountdown(t.startBlock)
          .encodeABI(),
      },
        async (err: any, txHash: string) => {
          const t = this as any;
          if (err) t.overlay = err.code === 4001 ? "" : "error";
          t.leRecipient = '';
          t.lookupBlockStart();
        }
      );
    },
    syncBlockToDateTime() {
      const t = this as any;
      //t.startBlock = t.startDate + t.startTime;
    },
    syncDateTimeToBlock() {
      const t = this as any;
      // const blockDifference = t.startBlock - t.currentBlock;
      // const timeDifference = blockDifference * t.avgBlockTime;
      // t.startDate = timeDifference;
      // t.startTime = timeDifference;
    },
    loadStats() {
      const t = this as any;
      t.lookupSupply();
      t.lookupLimit();
      t.lookupPause();
      t.lookupBlockStart();
      t.lookupLE();
      t.lookupTokens();
      t.lookupPhase();
      t.loadCountdown();
    },
    loadCountdown() {
      const t = this as any;
      t.timeLeft = (t.blockStart - t.currentBlock) * 13350;
      t.pauseEndTimestamp = new Date(t.currentBlockTimestamp).getTime() + t.timeLeft;
      t.pauseEndTime = dayjs(t.currentBlockTimestamp).add(t.timeLeft, 'ms');
      t.pauseEndTimeUTC = dayjs(t.currentBlockTimestamp).add(t.timeLeft, 'ms');
    },
    lookupContractURI: async function() {
      (this as any).contractURI = await this.$store.state.contracts.tinyboxes.methods.contractURI().call();
    },
    lookupBaseURI: async function() {
      (this as any).baseURI = await this.$store.state.contracts.tinyboxes.methods.baseURI().call();
    },
    lookupSupply: async function() {
      (this as any).supply = await this.$store.state.contracts.tinyboxes.methods.totalSupply().call();
    },
    lookupLE: async function() {
      (this as any).leCount = await this.$store.state.contracts.tinyboxes.methods._tokenPromoIds().call();
    },
    lookupTokens: async function() {
      (this as any).tokenCount = await this.$store.state.contracts.tinyboxes.methods._tokenIds().call();
    },
    lookupLimit: async function() {
      (this as any).limit = await this.$store.state.contracts.tinyboxes.methods.TOKEN_LIMIT().call();
    },
    lookupPhase: async function() {
      (this as any).phase = await this.$store.state.contracts.tinyboxes.methods.currentPhase().call();
    },
    lookupPhaseLen: async function() {
      (this as any).phaseLen = await this.$store.state.contracts.tinyboxes.methods.phaseLen().call();
    },
    lookupPause: async function() {
      (this as any).paused = await this.$store.state.contracts.tinyboxes.methods.paused().call();
    },
    lookupBlockStart: async function() {
      (this as any).blockStart = await this.$store.state.contracts.tinyboxes.methods.blockStart().call();
    },
    async refreshTokenMetadata(id: string) {
      const refeshEndpoint  = 'https://api.opensea.io/asset/' + this.$store.state.tinyboxesAddress + '/' + id + '/?force_update=true';
      return await (this as any).$http.get(refeshEndpoint);
    },
    async lookupSales() {
      const t = this as any;
      t.transfers = await t.$http.get(
        "https://api.opensea.io/api/v1/events?asset_contract_address=" +
        t.$store.state.tinyboxesAddress +
        "&event_type=transfer&only_opensea=false&offset=0&limit=250"
      );
      const mints = t.transfers.data.asset_events.filter( (e: any) => e.from_account.address === "0x0000000000000000000000000000000000000000");
      const buys = mints.filter( (e: any) => {
        console.log(e.asset.token_id, e.asset.token_id < 2222)
        return e.asset.token_id < 2222
      });
      console.log(buys);
      // bin by hour / date created from launch time
      const hoursSinceLaunch = dayjs(t.saleStarted).diff(new Date(), 'hour');
      console.log(hoursSinceLaunch)
      for (let h=0; h < hoursSinceLaunch; h++) {
        const range = [
          dayjs(t.saleStarted).add(h, "hour"),
          dayjs(t.saleStarted).add(h+1, "hour")
        ];
        const count = buys.filter( (e: any) => {
          return dayjs(e.created_date).isBetween(range[0], range[1]);
        }).length;
        t.sales.push(count);
      }
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
            console.log(id);
          }.bind(t)
        )
        .on("error", function(log: any) {
          console.error(log)
        });
    },
    listenForBlocks: function() {
      const t = this as any;
      t.blockSubscription = t.$store.state.web3.eth
        .subscribe("newBlockHeaders", function(error: any, result: any){
            if (!error) {
                //console.log(result);
                return;
            }
            console.error(error);
        })
        .on("data", async function(blockHeader: any) {
          t.currentBlock = blockHeader.number;
          t.currentBlockTimestamp = blockHeader.timestamp * 1000;
          t.loadStats();
        })
        .on("error", console.error);
    },
    unsubscribeBlocks: function() {
        // unsubscribes the subscription
        (this as any).blockSubscription.unsubscribe(function(error: any, success: any){
            if (success) {
                console.log('Successfully unsubscribed blocks listener');
            }
        });
    },
  },
  data: () => ({
    loading: true,
    paused: false,
    avgBlockTime: 15000,
    datePicker: false,
    timePicker: false,
    sales: [],
    transfers: [],
    saleStarted: new Date("2021-01-30T18:42:37.780772"),
    startBlock: null as number | null,
    startDate: null as number | null,
    startTime: null as number | null,
    currentBlock: null as number | null,
    currentBlockTimestamp: null as number | null,
    timeLeft: null as number | null,
    pauseEndTime: null as any,
    pauseEndTimeUTC: null as any,
    pauseEndTimestamp: null as number | null,
    blockStart: null as number | null,
    blockSubscription: null,
    supply: null as number | null,
    limit: null as number | null,
    leCount: null as number | null,
    tokenCount: null as number | null,
    phase: null as number | null,
    phaseLen: null as number | null,
    tokenID: "",
    baseURI: '',
    contractURI: '',
    leRecipient: '',
  }),
});
</script>

<style lang="sass">
.v-chip__content
  span
    color: #FFF !important
.content
  margin-top: 35vh
.buttons
  flex-direction: column
.id
  font-size: 2rem
.render-settings
  max-width: 100%
.token-loading
  padding-top: 40vh
.on
  border-style: inset
.token-graphic
  max-height: 90vh
.token-stats
  padding: 1rem
  display: flex
  flex-direction: row,
  justify-content: space-between
.stat
  text-align: -webkit-center
  margin: 0.2rem
  padding: 1rem
  border: 1px solid #ccc
  border-radius: 0.5rem
  width: min-content
  height: min-content
.stat-value
  font-weight: 200
  font-size: 2rem
  margin: 1rem
.stat-title
  margin: 0.5rem 0 -0.5rem 0
  line-height: normal
  display: block
.palette
  display: flex
  flex-direction: column
  align-items: center
.box-story
  font-size: 1.2rem
.v-card
  margin: 1rem
.timestamp-date
  margin: 1rem
.timestamp-time
  width: max-content
.randomness-chunks, .timestamp .stat-value
  display: flex
  flex-wrap: wrap
  justify-content: center
  width: min-content
  span
    margin: 0.3rem
.stats
  display: flex
  flex-wrap: wrap
  justify-content: space-around
.v-card__text
  width: auto !important
.feature
  margin: 5px
  .v-chip
    border: 1px solid rgba(255,255,255,0.3) !important
    text-shadow: 0px 1px 5px #000000
</style>

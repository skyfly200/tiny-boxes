import Vue from "vue";
import Vuex from "vuex";
import Web3 from "web3";
import VuexPersist from "vuex-persist";

//import TinyBoxes from 'Contracts/TinyBoxes.sol'
import { tinyboxesAddress, tinyboxesABI } from "@/tinyboxes-contract";

Vue.use(Vuex);

const vuexLocalStorage = new VuexPersist({
  key: "tinyboxes",
  storage: window.localStorage,
  reducer: (state: any) => ({
    count: state.count,
    itemsPerPage: state.itemsPerPage,
    tokenIDs: state.tokenIDs,
    cachedTokens: state.cachedCells,
  }),
});

const store = new Vuex.Store({
  plugins: [vuexLocalStorage.plugin],
  state: {
    currentAccount: "",
    web3Status: "loading",
    web3: null,
    count: null,
    itemsPerPage: 12,
    tokenIDs: { null: null },
    cachedTokens: { null: null },
    contracts: { null: null },
  },
  mutations: {
    setCount(state, count) {
      state.count = count;
    },
    setItemsPerPage(state, n) {
      state.itemsPerPage = n;
    },
    setToken(state, payload) {
      const id: keyof typeof state.cachedTokens = payload.id;
      state.cachedTokens[id] = payload.data;
    },
    setContract(state, payload) {
      const id: keyof typeof state.contracts = payload.id;
      state.contracts[id] = payload.contract;
    },
    setWeb3(state, instance) {
      state.web3 = instance;
    },
    setWeb3Status(state, status) {
      state.web3Status = status;
    },
    setAccount(state, address) {
      state.currentAccount = address;
    },
  },
  actions: {
    async initialize(context) {
      await context.dispatch("loadWeb3");
      await context.dispatch("loadAccount");
      await context.dispatch("registerContracts");
    },
    loadWeb3(context) {
      return new Promise((resolve, reject) => {
        if ((window as any).ethereum) {
          context.commit("setWeb3", new Web3((window as any).ethereum));
          try {
            // Request account access if needed
            (window as any).ethereum.enable().then(() => {
              context.commit("setWeb3Status", "active");
              resolve();
            });
          } catch (error) {
            context.commit("setWeb3Status", "denied");
            resolve();
          }
        } else if ((window as any).web3) {
          // Legacy dapp browsers...
          context.commit(
            "setWeb3",
            new Web3((window as any).web3.currentProvider)
          );
          context.commit("setWeb3Status", "active");
          resolve();
        } else {
          // Non-dapp browsers...
          context.commit("setWeb3Status", "inactive");
          resolve();
        }
      });
    },
    loadAccount(context) {
      return new Promise((resolve, reject) => {
        const web3: any = context.state.web3;
        if (web3 !== null) {
          web3.eth.getAccounts((err: any, resp: any) => {
            if (err) reject(err);
            else {
              context.commit("setAccount", resp[0]);
              resolve(resp[0]);
            }
          });
        } else reject();
      });
    },
    registerContracts(context) {
      return new Promise((resolve, reject) => {
        const web3: any = context.state.web3;
        if (web3 !== null) {
          context.commit("setContract", {
            id: "tinyboxes",
            contract: new web3.eth.Contract(tinyboxesABI, tinyboxesAddress),
          });
          resolve();
        } else reject();
      });
    },
  },
  getters: {
    itemsPerPage: (state) => {
      return state.itemsPerPage;
    },
    currentAccount: (state) => {
      return state.currentAccount;
    },
    web3Status: (state) => {
      return state.web3Status;
    },
  },
});

export default store;

import Vue from "vue";
import Vuex from "vuex";
import Web3 from "web3";
import VuexPersist from "vuex-persist";

import { cellAddress, cellABI } from "@/cell-contract.ts";

Vue.use(Vuex);

const vuexLocalStorage = new VuexPersist({
  key: "microverse",
  storage: window.localStorage,
  reducer: (state: any) => ({
    count: state.count,
    cellsPerPage: state.cellsPerPage,
    cellIDs: state.cellIDs,
    cachedCells: state.cachedCells,
  })
});

const store = new Vuex.Store({
  plugins: [vuexLocalStorage.plugin],
  state: {
    currentAccount: "",
    web3Status: "loading",
    web3: null,
    count: null,
    cellsPerPage: 12,
    cellIDs: {},
    cachedCells: {},
    contracts: {
      cells: null
    }
  },
  mutations: {
    setCount(state, count) {
      state.count = count;
    },
    setCellsPerPage(state, n) {
      state.cellsPerPage = n;
    },
    setCellID(state, payload) {
      state.cellIDs[payload.index] = payload.id;
    },
    setCell(state, payload) {
      state.cachedCells[payload.id] = payload.data;
    },
    setContract(state, payload) {
      state.contracts[payload.id] = payload.contract;
    },
    setWeb3(state, instance) {
      state.web3 = instance;
    },
    setWeb3Status(state, status) {
      state.web3Status = status;
    },
    setAccount(state, address) {
      state.currentAccount = address;
    }
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
          context.commit("setWeb3", new Web3((window as any).web3.currentProvider));
          context.commit("setWeb3Status", "active");
          resolve();
        } else {
          // Non-dapp browsers...
          context.commit("setWeb3Status", "inactive");
          resolve();
        }
      });
    },
    registerContracts(context) {
      return new Promise((resolve, reject) => {
        context.commit("setContract", {
          id: "cell",
          contract: new context.state.web3.eth.Contract(cellABI, cellAddress)
        });
        resolve();
      });
    },
    loadAccount(context) {
      return new Promise((resolve, reject) => {
        context.state.web3.eth.getAccounts((err: any, resp: any) => {
          if (err) reject(err);
          else {
            context.commit("setAccount", resp[0]);
            resolve(resp[0]);
          }
        });
      });
    },
  },
  getters: {
    cellsPerPage: state => {
      return state.cellsPerPage;
    },
    currentAccount: state => {
      return state.currentAccount;
    },
    web3Status: state => {
      return state.web3Status;
    }
  }
});

export default store;

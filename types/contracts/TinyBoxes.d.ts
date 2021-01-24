/* Generated by ts-generator ver. 0.0.8 */
/* tslint:disable */

import BN from "bn.js";
import { Contract, ContractOptions } from "web3-eth-contract";
import { EventLog } from "web3-core";
import { EventEmitter } from "events";
import { ContractEvent, Callback, TransactionObject, BlockType } from "./types";

interface EventOptions {
  filter?: object;
  fromBlock?: BlockType;
  topics?: string[];
}

export class TinyBoxes extends Contract {
  constructor(
    jsonInterface: any[],
    address?: string,
    options?: ContractOptions
  );
  clone(): TinyBoxes;
  methods: {
    ADMIN_ROLE(): TransactionObject<string>;

    ANIMATION_COUNT(): TransactionObject<string>;

    DEFAULT_ADMIN_ROLE(): TransactionObject<string>;

    SCHEME_COUNT(): TransactionObject<string>;

    TOKEN_LIMIT(): TransactionObject<string>;

    _tokenIds(): TransactionObject<string>;

    _tokenPromoIds(): TransactionObject<string>;

    approve(to: string, tokenId: number | string): TransactionObject<void>;

    avgBlockTime(): TransactionObject<string>;

    balanceOf(owner: string): TransactionObject<string>;

    baseURI(): TransactionObject<string>;

    blockStart(): TransactionObject<string>;

    changeSettings(
      id: number | string,
      settings: (number | string)[]
    ): TransactionObject<void>;

    contractURI(): TransactionObject<string>;

    create(
      _seed: string,
      shapes: number | string,
      hatching: number | string,
      color: (number | string)[],
      size: (number | string)[],
      spacing: (number | string)[],
      mirroring: number | string,
      recipient: string,
      referalID: number | string
    ): TransactionObject<string>;

    currentPhase(): TransactionObject<string>;

    getApproved(tokenId: number | string): TransactionObject<string>;

    getRoleAdmin(role: string | number[]): TransactionObject<string>;

    getRoleMember(
      role: string | number[],
      index: number | string
    ): TransactionObject<string>;

    getRoleMemberCount(role: string | number[]): TransactionObject<string>;

    grantRole(
      role: string | number[],
      account: string
    ): TransactionObject<void>;

    hasRole(
      role: string | number[],
      account: string
    ): TransactionObject<boolean>;

    isApprovedForAll(
      owner: string,
      operator: string
    ): TransactionObject<boolean>;

    isTokenLE(id: number | string): TransactionObject<boolean>;

    mintLE(recipient: string): TransactionObject<void>;

    name(): TransactionObject<string>;

    ownerOf(tokenId: number | string): TransactionObject<string>;

    paused(): TransactionObject<boolean>;

    phaseCountdown(): TransactionObject<string>;

    phaseCountdownTime(): TransactionObject<string>;

    phaseLen(): TransactionObject<string>;

    price(): TransactionObject<string>;

    readSettings(
      id: number | string
    ): TransactionObject<{
      bkg: string;
      duration: string;
      options: string;
      0: string;
      1: string;
      2: string;
    }>;

    redeemLE(
      seed: number | string,
      shapes: number | string,
      hatching: number | string,
      color: (number | string)[],
      size: (number | string)[],
      spacing: (number | string)[],
      mirroring: number | string,
      id: number | string
    ): TransactionObject<void>;

    referalNewPercent(): TransactionObject<string>;

    referalPercent(): TransactionObject<string>;

    renounceRole(
      role: string | number[],
      account: string
    ): TransactionObject<void>;

    revokeRole(
      role: string | number[],
      account: string
    ): TransactionObject<void>;

    safeTransferFrom(
      from: string,
      to: string,
      tokenId: number | string
    ): TransactionObject<void>;

    setApprovalForAll(
      operator: string,
      approved: boolean
    ): TransactionObject<void>;

    setBaseURI(_uri: string): TransactionObject<void>;

    setContractURI(_uri: string): TransactionObject<void>;

    setPause(state: boolean): TransactionObject<void>;

    setRandom(rand: string): TransactionObject<void>;

    setTokenURI(_id: number | string, _uri: string): TransactionObject<void>;

    startCountdown(startBlock: number | string): TransactionObject<void>;

    supportsInterface(
      interfaceId: string | number[]
    ): TransactionObject<boolean>;

    symbol(): TransactionObject<string>;

    testRandom(): TransactionObject<string>;

    tokenByIndex(index: number | string): TransactionObject<string>;

    tokenData(
      _id: number | string
    ): TransactionObject<{
      randomness: string;
      animation: string;
      shapes: string;
      hatching: string;
      size: string[];
      spacing: string[];
      mirroring: string;
      color: string[];
      contrast: string;
      shades: string;
      scheme: string;
      0: string;
      1: string;
      2: string;
      3: string;
      4: string[];
      5: string[];
      6: string;
      7: string[];
      8: string;
      9: string;
      10: string;
    }>;

    tokenOfOwnerByIndex(
      owner: string,
      index: number | string
    ): TransactionObject<string>;

    tokenPreview(
      seed: string,
      color: (number | string)[],
      shapes: (number | string)[],
      size: (number | string)[],
      spacing: (number | string)[],
      mirroring: number | string,
      settings: (number | string)[],
      traits: (number | string)[],
      slot: string
    ): TransactionObject<string>;

    tokenURI(tokenId: number | string): TransactionObject<string>;

    totalSupply(): TransactionObject<string>;

    transferFrom(
      from: string,
      to: string,
      tokenId: number | string
    ): TransactionObject<void>;

    trueID(id: number | string): TransactionObject<string>;

    unredeemed(id: number | string): TransactionObject<boolean>;

    validateParams(
      shapes: number | string,
      hatching: number | string,
      color: (number | string)[],
      size: (number | string)[],
      position: (number | string)[],
      exclusive: boolean
    ): TransactionObject<void>;
  };
  events: {
    Approval: ContractEvent<{
      owner: string;
      approved: string;
      tokenId: string;
      0: string;
      1: string;
      2: string;
    }>;
    ApprovalForAll: ContractEvent<{
      owner: string;
      operator: string;
      approved: boolean;
      0: string;
      1: string;
      2: boolean;
    }>;
    LECreated: ContractEvent<string>;
    RoleAdminChanged: ContractEvent<{
      role: string;
      previousAdminRole: string;
      newAdminRole: string;
      0: string;
      1: string;
      2: string;
    }>;
    RoleGranted: ContractEvent<{
      role: string;
      account: string;
      sender: string;
      0: string;
      1: string;
      2: string;
    }>;
    RoleRevoked: ContractEvent<{
      role: string;
      account: string;
      sender: string;
      0: string;
      1: string;
      2: string;
    }>;
    SettingsChanged: ContractEvent<string[]>;
    Transfer: ContractEvent<{
      from: string;
      to: string;
      tokenId: string;
      0: string;
      1: string;
      2: string;
    }>;
    allEvents: (
      options?: EventOptions,
      cb?: Callback<EventLog>
    ) => EventEmitter;
  };
}

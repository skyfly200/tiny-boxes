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

export class Colors extends Contract {
  constructor(
    jsonInterface: any[],
    address?: string,
    options?: ContractOptions
  );
  clone(): Colors;
  methods: {
    _parseBkg(bkg: number | string): TransactionObject<string>;

    calcShade(
      lightness: number | string,
      shades: number | string,
      contrast: number | string,
      shade: number | string
    ): TransactionObject<string>;

    lookupColor(
      scheme: number | string,
      hue: number | string,
      saturation: number | string,
      lightness: number | string,
      shades: number | string,
      contrast: number | string,
      shade: number | string,
      hueIndex: number | string
    ): TransactionObject<{
      hue: string;
      saturation: string;
      lightness: string;
    }>;

    toString(color: {
      hue: number | string;
      saturation: number | string;
      lightness: number | string;
    }): TransactionObject<string>;
  };
  events: {
    allEvents: (
      options?: EventOptions,
      cb?: Callback<EventLog>
    ) => EventEmitter;
  };
}

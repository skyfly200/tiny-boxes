//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.4;

import "@openzeppelin/contracts/utils/Strings.sol";

import "./Utils.sol";
import "./StringUtilsLib.sol";

library XML {
    using Utils for *;
    using Strings for *;

    /**
     * @dev render a tag
     * @param tag name of tag
     * @param slot nested content
     * @return tag string
     */
    function _tag(string memory tag, string memory slot) internal pure returns (string memory) {
        return string(abi.encodePacked(
            "<", tag,
            bytes(slot).length == 0 ?
                "/>" :
                string(abi.encodePacked(">",slot,"</", tag, ">"))
        ));
    }

    /**
     * @dev render a tag with attributes
     * @param tag name of tag
     * @param slot nested content
     * @param attr attributes array for tag
     * @return tag string
     */
    function _tag(string memory tag, string memory slot, string[2][] memory attr) internal pure returns (string memory) {
        string memory attrString = "";
        for (uint i=0; i < attr.length; i++) attrString = string(abi.encodePacked(attrString,' ',attr[0][i],'="',attr[1][i],'"'));
        return string(abi.encodePacked(
            "<", tag,attrString,
            bytes(slot).length == 0 ?
                "/>" :
                string(abi.encodePacked(">",slot,"</", tag, ">"))
        ));
    }
}

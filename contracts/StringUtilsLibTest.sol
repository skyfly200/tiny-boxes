//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;

import "./libraries/StringUtilsLib.sol";

contract LibTest {
    using StringUtilsLib for *;

    /**
    * @dev render the header of the SVG markup
    * @return header string
    */
    function test() public pure returns (string memory) {
        // string memory xmlVersion = '<?xml version="1.0" encoding="UTF-8"?>\n';
        // string memory doctype = '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">\n';
        // string memory openingTag = '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="100%" height="100%" viewBox="0 0 2600 2600" style="stroke-width:0; background-color:#121212;">\n\n';
        string memory symbols = '<symbol id="quad3">\n<symbol id="quad2">\n<symbol id="quad1">\n<symbol id="quad0">\n\n';

        // StringUtilsLib.slice[] memory parts;
        // parts[0] = xmlVersion.toSlice();
        // parts[1] = doctype.toSlice();
        // parts[2] = openingTag.toSlice();
        // parts[3] = symbols.toSlice();
        //return ('').toSlice().join(parts);
        return symbols.toSlice().toString();
    }
}
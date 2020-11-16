//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.4;

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/SignedSafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "../structs/Decimal.sol";
import "../structs/Shape.sol";
import "../structs/TinyBox.sol";
import "../structs/HSL.sol";

import "./SVGBuffer.sol";
import "./Random.sol";
import "./Utils.sol";
import "./Decimal.sol";
import "./Colors.sol";
import "./StringUtilsLib.sol";
import "../structs/Decimal.sol";

library SVG {
    using Math for uint256;
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using StringUtilsLib for *;
    using SVGBuffer for bytes;
    using Random for bytes32[];
    using DecimalUtils for *;
    using Utils for *;
    using Colors for *;
    using Strings for *;

    /**
     * @dev render a rectangle SVG tag
     * @param shape object
     */
    function _rect(Shape memory shape) internal view returns (string memory) {
        return string(abi.encodePacked(
            '<rect x="',
            shape.position[0].toString(),
            '" y="',
            shape.position[1].toString(),
            '" width="',
            shape.size[0].toString(),
            '" height="',
            shape.size[1].toString(),
            '" style="fill:',
            shape.color.toString(),
            '"/>'
        ));
    }

    /**
     * @dev render a rectangle SVG tag
     * @param shape object
     */
    function _rect(Shape memory shape, string memory slot) internal view returns (string memory) {
        return string(abi.encodePacked(
            '<rect x="',
            shape.position[0].toString(),
            '" y="',
            shape.position[1].toString(),
            '" width="',
            shape.size[0].toString(),
            '" height="',
            shape.size[1].toString(),
            '" style="fill:',
            shape.color.toString(),
            '">',
            slot,
            '</rect>'
        ));
    }

    /**
     * @dev render an animate SVG tag
     */
    function _animate(string memory attribute, string memory values, string memory duration) internal pure returns (string memory) {
        return string(abi.encodePacked('<animate attributeName="', attribute, '" values="', values, '" dur="', duration, '" repeatCount="indefinite" />'));
    }

    /**
     * @dev render an animate SVG tag with calcMode discrete (no interpolation)
     */
    function _animateDiscrete(string memory attribute, string memory values, string memory duration) internal pure returns (string memory) {
        return string(abi.encodePacked('<animate attributeName="', attribute, '" values="', values, '" dur="', duration, '" calcMode="discrete" repeatCount="indefinite" />'));
    }

    /**
     * @dev render a animateTransform SVG tag
     */
    function _animateTransform(string memory attribute, string memory typeVal, string memory values, string memory duration) internal pure returns (string memory) {
        return string(abi.encodePacked('<animateTransform attributeName="', attribute, '" attributeType="XML" type="', typeVal, '" values="', values, '" dur="', duration, '" repeatCount="indefinite" />'));
    }

    /**
     * @dev render a animateTransform SVG tag
     */
    function _animateTransform(string memory attribute, string memory typeVal, string memory values, string memory keyTimes, string memory duration) internal pure returns (string memory) {
        return string(abi.encodePacked('<animateTransform attributeName="', attribute, '" attributeType="XML" type="', typeVal, '" values="', values, '" keyTimes="', keyTimes, '" dur="', duration, '" repeatCount="indefinite" />'));
    }

    /**
     * @dev render a animateTransform SVG tag
     */
    function _animateTransformSpline(string memory attribute, string memory typeVal, string memory values, string memory keySplines, string memory keyTimes, string memory duration) internal pure returns (string memory) {
        return string(abi.encodePacked('<animateTransform attributeName="', attribute, '" attributeType="XML" type="', typeVal, '" calcMode="spline" values="', values, '" keySplines="', keySplines, '" keyTimes="', keyTimes, '" dur="', duration, '" repeatCount="indefinite" />'));
    }

    /**
     * @dev render an g SVG tag
     */
    function _g(string memory slot) internal pure returns (string memory) {
        return string(abi.encodePacked('<g>', slot,'</g>'));
    }

    /**
     * @dev render an g SVG tag
     */
    function _g(string memory transformValues, string memory slot) internal pure returns (string memory) {
        return string(abi.encodePacked('<g transform="', transformValues,  '">', slot,'</g>'));
    }

    /**
     * @dev render an use SVG tag link
     */
    function _use(string memory id) internal pure returns (string memory) {
        return string(abi.encodePacked('<use xlink:href="#', id,'"/>'));
    }
    
    /**
     * @dev render the header of the SVG markup
     * @return header string
     */
    function _generateHeader() internal pure returns (string memory) {
        string memory xmlVersion = '<?xml version="1.0" encoding="UTF-8"?>';
        string memory doctype = '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">';
        string memory openingTag = '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="100%" height="100%" viewBox="0 0 2400 2400" style="stroke-width:0;background-color:#121212">';

        return string(abi.encodePacked(xmlVersion, doctype, openingTag));
    }

    /**
     * @dev render the header of the SVG markup
     * @return header string
     */
    function _generateBody(TinyBox memory box) internal pure returns (string memory) {
        string memory metadataTag = '<metadata>';
        string memory metadataEndTag = '</metadata>';
        string memory animationTag = '<animation>';
        string memory animationEndTag = '</animation>';
        string memory symbols = '<symbol id="quad3"><symbol id="quad2"><symbol id="quad1"><symbol id="quad0">';

        return string(abi.encodePacked(metadataTag, animationTag, uint256(box.animation).toString(), animationEndTag, metadataEndTag, symbols));
    }

    /**
     * @dev render the footer string for mirring effects
     * @param switches for each mirroring stage
     * @param mirrorPositions for generator settings
     * @param scale for each mirroring stage
     * @return footer string
     */
    function _generateFooter(
        bool[3] memory switches,
        int16[3] memory mirrorPositions,
        Decimal memory scale
    ) internal view returns (string memory) {
        bytes memory buffer = new bytes(8192);
        string[3] memory scales = ['-1 1', '-1 -1', '1 -1'];
        for (uint256 s = 0; s < 4; s++) {
            // loop through nested mirroring effects
            buffer.append('</symbol>');
            string memory id = string(abi.encodePacked('quad', s.toString()));
            if ( s < 3 ) {
                if (!switches[s]) {
                    // turn off this level of mirroring
                    buffer.append(string(abi.encodePacked(
                        _g(_use(id))
                    )));
                } else {
                    buffer.append(_g(_use(id)));
                    for (uint8 i = 0; i < 3; i++) {
                        // loop through transforms
                        string memory value = string(abi.encodePacked('-', mirrorPositions[s].toString()));
                        string memory x = (i > 1) ? '0' : value;
                        string memory y = (i < 1) ? '0' : value;
                        string memory transform = string(abi.encodePacked(
                            'scale(', scales[i], ') translate(', x, ' ', y, ')'
                        ));
                        buffer.append(_g(transform, _use(id)));
                    }
                }
            } else {
                // add final scaling
                string memory scaleStr = scale.toString();
                string memory transform = string(abi.encodePacked(
                    'scale(', scaleStr, ' ', scaleStr, ')'
                ));
                buffer.append(_g(transform, _use(id)));
            }
        }
        return buffer.toString();
    }

    /**
     * @dev select the animation
     * @param box object to base animation around
     * @param shapeIndex index of the shape to animate
     * @return mod struct of modulator values
     */
    function _generateAnimation(
        TinyBox memory box,
        Shape memory shape,
        uint256 shapeIndex
    ) internal view returns (string memory) {
        // select animation based on animation id
        uint256 animation = box.animation;
        if (animation == 0) {
            // Rounding corners
            return _animate("rx","0;100;0","10s");
        } else if (animation == 1) {
            // grow n shrink
            return _animateTransform(
                "transform",
                "scale",
                "1 1 ; 1.5 1.5 ; 1 1 ; 0.5 0.5 ; 1 1",
                "0 ; 0.25 ; 0.5 ; 0.75 ; 1",
                "10s"
            );
        } else if (animation == 2) {
            // squash n stretch
            uint256 div = 7;
            string[2] memory vals;
            for (uint256 i = 0; i < 2; i++) {
                uint256 size = uint256(shape.size[i]);
                string memory avg = size.toString();
                string memory min = size.sub(size.div(div)).toString();
                string memory max = size.add(size.div(div)).toString();
                vals[i] = string(abi.encodePacked(
                    avg, ";", (i==0) ? min : max, ";", avg, ";", (i==0) ? max : min, ";", avg
                ));
            }
            return string(abi.encodePacked(
                _animate("width",vals[0],"10s"),
                _animate("height",vals[1],"10s")
            ));
        } else if (animation == 3) {
            // skew X
            return _animateTransform(
                "transform",
                "skewX",
                "0 ; 50 ; 0",
                "10s"
            );
        } else if (animation == 4) {
            // skew Y
            return _animateTransform(
                "transform",
                "skewY",
                "0 ; 50 ; 0",
                "10s"
            );
        } else if (animation == 5) {
            // snap spin
            return _animateTransformSpline(
                "transform",
                "rotate",
                "0 200 200 ; 90 200 200 ; 90 200 200 ; 360 200 200 ; 360 200 200",
                "0.5 0 0.75 1 ; 0.5 0 0.5 1 ; 0.5 0 0.75 1 ; 0.5 0 0.5 1",
                "0 ; 0.2 ; 0.4 ; 0.9 ; 1",
                "10s"
            );
        } else if (animation == 6) {
            // snap spin
            return _animateTransformSpline(
                "transform",
                "rotate",
                "0 200 200 ; 180 200 200 ; 180 200 200 ; 360 200 200 ; 360 200 200",
                "0.5 0 0.75 1 ; 0.5 0 0.5 1 ; 0.5 0 0.75 1 ; 0.5 0 0.5 1",
                "0 ; 0.4 ; 0.6 ; 0.9 ; 1",
                "10s"
            );
        } else if (animation == 7) {
            // snap spin
            return _animateTransformSpline(
                "transform",
                "rotate",
                "0 200 200 ; 270 200 200 ; 270 200 200 ; 360 200 200 ; 360 200 200",
                "0.5 0 0.75 1 ; 0.5 0 0.5 1 ; 0.5 0 0.75 1 ; 0.5 0 0.5 1",
                "0 ; 0.6 ; 0.8 ; 0.9 ; 1",
                "10s"
            );
        } else if (animation == 8) {
            // snap spin
            return _animateTransformSpline(
                "transform",
                "rotate",
                "0 200 200 ; 90 200 200 ; 90 200 200 ; 180 200 200 ; 180 200 200 ; 270 200 200 ; 270 200 200 ; 360 200 200 ; 360 200 200",
                "0.5 0 0.75 1 ; 0.5 0 0.5 1 ; 0.5 0 0.5 1 ; 0.5 0 0.5 1 ; 0.5 0 0.5 1 ; 0.5 0 0.5 1 ; 0.5 0 0.75 1 ; 0.5 0 0.5 1",
                "0 ; 0.125 ; 0.25 ; 0.375 ; 0.5 ; 0.625 ; 0.8 ; 0.925 ; 1",
                "10s"
            );
        } else if (animation == 9) {
            // spread
            uint256 spread = uint256(300).div(uint256(box.shapes));
            string memory angle = shapeIndex.add(1).mul(spread).toString();
            string memory values = string(abi.encodePacked("0 200 200 ; ",  angle, " 200 200 ; ",  angle, " 200 200 ; 360 200 200 ; 360 200 200"));
            return _animateTransformSpline( "transform", "rotate", values, "0.5 0 0.75 1 ; 0.5 0 0.5 1 ; 0.5 0 0.75 1 ; 0.5 0 0.5 1", "0;0.5;0.6;0.9;1", "10s" );
        } else if (animation == 10) {
            // spread w time
            uint256 spread = uint256(300).div(uint256(box.shapes));
            string memory angle = shapeIndex.add(1).mul(spread).toString();
            string memory values = string(abi.encodePacked("0 200 200 ; ",  angle, " 200 200 ; ",  angle, " 200 200 ; 360 200 200"));
            uint256 timeShift = uint256(100).add(uint256(box.shapes).sub(shapeIndex).mul(uint256(700).div(uint256(box.shapes))));
            string memory times = string(abi.encodePacked("0;0.", timeShift.toString(), ";0.9;1"));
            return _animateTransformSpline( "transform", "rotate", values, "0.5 0 0.75 1 ; 0.5 0 0.5 1 ; 0.5 0 0.75 1 ", times, "10s" );
        } else if (animation == 11) {
            // glide
            int256 amp = 20;
            int256 posX = shape.position[0];
            int256 posY = shape.position[1];
            string memory avg = string(abi.encodePacked(posX.toString(), " ", posY.toString()));
            string memory max = string(abi.encodePacked(posX.add(amp).toString(), " ", posY.add(amp).toString()));
            string memory min = string(abi.encodePacked(posX.sub(amp).toString(), " ", posY.sub(amp).toString()));
            string memory values = string(abi.encodePacked( avg, ";", min, ";", avg, ";", max, ";", avg ));
            return _animateTransform("transform","translate",values,"10s");
        } else if (animation == 12) {
            // Uniform Speed Spin
            return _animateTransform(
                "transform",
                "rotate",
                "0 60 70 ; 360 60 70",
                "0 ; 1",
                "10s"
            );
        } else if (animation == 13) {
            // 2 Speed Spin
            return _animateTransform(
                "transform",
                "rotate",
                "0 60 70 ; 90 60 70 ; 270 60 70 ; 360 60 70",
                "0 ; 0.1 ; 0.9 ; 1",
                "10s"
            );
        } else if (animation == 14) {
            // indexed speed
            return _animateTransform(
                "transform",
                "rotate",
                "0 60 70 ; 360 60 70",
                "0  ; 1",
                string(abi.encodePacked(uint256(10000).div(shapeIndex + 1).toString(),"ms"))
            );
        } else if (animation == 15) {
            // jitter
            int256[2] memory amp = [int256(10), int256(10)]; // randomize amps for each shape?
            string[2] memory vals;
            for (uint256 i = 0; i < 2; i++) {
                int256 pos = shape.position[i];
                string memory min = pos.sub(amp[i]).toString();
                string memory max = pos.add(amp[i]).toString();
                vals[i] = string(abi.encodePacked(
                    (i==0) ? min : max, ";", (i==0) ? max : min
                ));
            }
            return string(abi.encodePacked(
                _animateDiscrete("x",vals[0],"1s"),
                _animateDiscrete("y",vals[1],"2s")
            ));
        } else if (animation == 16) {
            // giggle
            int256 amp = 5;
            string[2] memory vals;
            for (uint256 i = 0; i < 2; i++) {
                int256 pos = shape.position[i];
                string memory min = pos.sub(amp).toString();
                string memory max = pos.add(amp).toString();
                vals[i] = string(abi.encodePacked(
                    (i==0) ? min : max, ";", (i==0) ? max : min, ";", (i==0) ? min : max
                ));
            }
            return string(abi.encodePacked(
                _animate("x",vals[0],"200ms"),
                _animate("y",vals[1],"200ms")
            ));
        } else if (animation == 16) {
            // jolt
            int256 amp = 5;
            string[2] memory vals;
            for (uint256 i = 0; i < 2; i++) {
                int256 pos = shape.position[i];
                string memory min = pos.sub(amp).toString();
                string memory max = pos.add(amp).toString();
                vals[i] = string(abi.encodePacked(
                    (i==0) ? min : max, ";", (i==0) ? max : min
                ));
            }
            return string(abi.encodePacked(
                _animate("x",vals[0],"200ms"),
                _animate("y",vals[1],"200ms")
            ));
        } else if (animation == 17 ) {
            // drop (shake first?)
            string memory values = string(abi.encodePacked(
                shape.position[0].toString()," ",shape.position[1].toString()," ; ",
                shape.position[0].toString()," ",shape.position[1].sub(500).toString()
            ));
            return _animateTransformSpline(
                "transform",
                "translate",
                values,
                "0.2 0 0.5 1 ; 0.5 0 0.5 1",
                "0 ; 1",
                "10s"
            );
        }
    }
}

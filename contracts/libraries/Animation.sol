// SPDX-License-Identifier: MIT
pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/SignedSafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "../structs/Decimal.sol";
import "../structs/Shape.sol";
import "../structs/TinyBox.sol";

import "./Utils.sol";
import "./Decimal.sol";

library Animation {
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using DecimalUtils for *;
    using Utils for *;
    using Strings for *;

    /**
     * @dev render an animate SVG tag
     */
    function _animate(string memory attribute, string memory duration, string memory values, string memory attr) internal pure returns (string memory) {
        return _animate(attribute, duration, values, '', attr);
    }

    /**
     * @dev render an animate SVG tag
     */
    function _animate(string memory attribute, string memory duration, string memory values, string memory calcMode, string memory attr) internal pure returns (string memory) {
        return string(abi.encodePacked('<animate attributeName="', attribute, '" values="', values, '" dur="', duration,
        bytes(calcMode).length == 0 ? '' : string(abi.encodePacked('" calcMode="',calcMode)),
        '" ',attr,'/>'));
    }

    /**
     * @dev render an animate SVG tag with keyTimes and keySplines
     */
    function _animate(string memory attribute, string memory duration, string memory values, string memory keyTimes, string memory keySplines, string memory attr) internal pure returns (string memory) {
        return string(abi.encodePacked('<animate attributeName="', attribute, '" values="', values, '" dur="', duration,
        '" keyTimes="',keyTimes,'" keySplines="',keySplines,
        '" calcMode="spline" ',attr,'/>'));
    }

    /**
     * @dev render an animateTransform SVG tag with keyTimes and keySplines
     */
    function _animateTransform(string memory typeVal, string memory duration, string memory values, string memory keyTimes, string memory keySplines, string memory attr, bool add) internal pure returns (string memory) {
        return string(abi.encodePacked('<animateTransform attributeName="transform" attributeType="XML" type="', typeVal,'" dur="', duration, '" values="', values,
            bytes(keyTimes).length == 0 ? '' : string(abi.encodePacked('" keyTimes="', keyTimes)),
            bytes(keySplines).length == 0 ? '' : string(abi.encodePacked('" calcMode="spline" keySplines="', keySplines)),
            add ? '" additive="sum' : '',
        '" ',attr,'/>'));
    }

    /**
     * @dev render an animateTransform SVG tag with keyTimes
     */
    function _animateTransform(string memory typeVal, string memory duration, string memory values, string memory keyTimes, string memory attr, bool add) internal pure returns (string memory) {
        return _animateTransform(typeVal, duration, values, keyTimes, '', attr, add);
    }

    /**
     * @dev render an animateTransform SVG tag
     */
    function _animateTransform(string memory typeVal, string memory duration, string memory values, string memory attr, bool add) internal pure returns (string memory) {
        return _animateTransform(typeVal, duration, values, '', '', attr, add);
    }

    /**
     * @dev render an animateTransform SVG tag with keyTimes
     */
    function _animateTransform(string memory typeVal, string memory duration, string memory values, string memory keyTimes, string memory keySplines, string memory attr) internal pure returns (string memory) {
        return _animateTransform(typeVal, duration, values, keyTimes, keySplines, attr, false);
    }

    /**
     * @dev render an animateTransform SVG tag with keyTimes
     */
    function _animateTransform(string memory typeVal, string memory duration, string memory values, string memory keyTimes, string memory attr) internal pure returns (string memory) {
        return _animateTransform(typeVal, duration, values, keyTimes, '', attr, false);
    }

    /**
     * @dev render an animateTransform SVG tag
     */
    function _animateTransform(string memory typeVal, string memory duration, string memory values, string memory attr) internal pure returns (string memory) {
        return _animateTransform(typeVal, duration, values, '', '', attr, false);
    }

    // /**
    //  * @dev creata a keyTimes string, based on a range and division count
    //  */
    // function generateTimes() internal pure returns (string memory times) {}

    /**
     * @dev creata a keySplines string, with a bezier curve for each value transition
     */
    function generateSplines(uint8 transitions, uint8 curve) internal pure returns (string memory curves) {
        string[2] memory bezierCurves = [
            ".5 0 .75 1", // ease in and out fast
            ".4 0 .6 1" // ease in fast + soft
        ];
        for (uint8 i=0; i < transitions; i++)
            curves = string(abi.encodePacked(curves, i>0 ? ";" : "", bezierCurves[curve]));
    }

    /**
     * @dev calculate attributes for an animation tag based of the animation mode
     */
    function _calcAttributes(uint256 mode) internal pure returns (string memory) {
        uint8[3] memory counts = [1,2,25];
        string memory repeat = string(abi.encodePacked(
            'repeatCount="',
            mode <= 4 ? 'indefinite' : uint256(counts[mode-5]).toString(),
            '" '
        ));
        string memory begin = mode <= 1 ? '' : string(abi.encodePacked(
            'begin="target.',
            mode == 2 ? 'mouseenter ' : mode == 3 ? 'dblclick' : 'click',
            '" '
        ));
        string memory end = mode == 2 ? 'end="target.mouseleave" ' :
            mode == 3 ? 'end="target.click" ' : '';
        return string(abi.encodePacked(repeat, begin, end));
        // 0 - 000    '',
        // 1 - 001    'repeatCount="indefinite" ',
        // 2 - 010    'repeatCount="indefinite" begin="target.mouseenter" ',
        // 4 - 100    'repeatCount="indefinite" begin="target.dblclick" end="target.click" ',
        // 3 - 011    'repeatCount="indefinite" begin="target.click" ',
        // 5 - 101    'repeatCount="1" begin="target.click" ',
        // 6 - 110    'repeatCount="2" begin="target.click" ',
        // 7 - 111    'repeatCount="25" begin="target.click" '
    }

    /**
     * @dev select the animation
     * @param box object to base animation around
     * @param shapeIndex index of the shape to animate
     * @return mod struct of modulator values
     */
    function _generateAnimation(
        TinyBox calldata box,
        uint8 animation,
        Shape calldata shape,
        uint256 shapeIndex
    ) external pure returns (string memory) {
        string memory duration = string(abi.encodePacked(uint256(box.duration > 0 ? box.duration : 10).toString(),"s"));
        string memory attr = _calcAttributes(box.options%8);
        // select animation based on animation id
        if (animation == 0) {
            // snap spin 90
            return _animateTransform(
                "rotate", duration, "0;90;90;360;360", "0;.2;.3;.9;1", generateSplines(4,0), attr
            );
        } else if (animation == 1) {
            // snap spin 180
            return _animateTransform(
                "rotate", duration, "0;180;180;360;360", "0;.4;.5;.9;1", generateSplines(4,0), attr
            );
        } else if (animation == 2) {
            // snap spin 270
            return _animateTransform(
                "rotate", duration, "0;270;270;360;360", "0;.6;.7;.9;1", generateSplines(4,0), attr
            );
        } else if (animation == 3) {
            // snap spin tri
            return _animateTransform(
                "rotate", duration, "0;120;120;240;240;360;360", "0;.166;.333;.5;.666;.833;1",
                generateSplines(6,0), attr
            );
        } else if (animation == 4) {
            // snap spin quad
            return _animateTransform(
                "rotate", duration, "0;90;90;180;180;270;270;360;360", "0;.125;.25;.375;.5;.625;.8;.925;1",
                generateSplines(8,0), attr
            );
        } else if (animation == 5) {
            // snap spin tetra
            return _animateTransform(
                "rotate", duration, "0;72;72;144;144;216;216;278;278;360;360", "0;.1;.2;.3;.4;.5;.6;.7;.8;.9;1",
                generateSplines(10,0), attr
            );
        } else if (animation == 6) {
            // Uniform Speed Spin
            return _animateTransform( "rotate", duration, "0;360", "0;1", attr );
        } else if (animation == 7) {
            // 2 Speed Spin
            return _animateTransform( "rotate", duration, "0;90;270;360", "0;.1;.9;1", attr );
        } else if (animation == 8) {
            // indexed speed
            return _animateTransform(
                "rotate",
                string(abi.encodePacked(uint256(((1000*(box.duration > 0 ? box.duration : 10)) / box.shapes) * (shapeIndex + 1) ).toString(),"ms")),
                "0;360",
                "0;1",
                attr
            );
        } else if (animation == 9) {
            // spread
            uint256 spread = uint256(300).div(uint256(box.shapes));
            string memory angle = shapeIndex.add(1).mul(spread).toString();
            string memory values = string(abi.encodePacked("0;",  angle, ";",  angle, ";360;360"));
            return _animateTransform( "rotate", duration, values, "0;.5;.6;.9;1", generateSplines(4,0), attr );
        } else if (animation == 10) {
            // spread w time
            string memory angle = shapeIndex.add(1).mul(uint256(300).div(uint256(box.shapes))).toString();
            uint256 timeShift = uint256(900).sub(uint256(box.shapes).sub(shapeIndex).mul(uint256(800).div(uint256(box.shapes))));
            string memory times = string(abi.encodePacked("0;.",timeShift.toString(),";.9;1"));
            return _animateTransform( "rotate", duration, string(abi.encodePacked("0;",angle,";",angle,";360")), times, generateSplines(3,0), attr );
        } else if (animation == 11) {
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
                _animate("x",string(abi.encodePacked(uint256(box.duration > 0 ? box.duration : 10).div(10).toString(),"s")),vals[0],"discrete", attr),
                _animate("y",string(abi.encodePacked(uint256(box.duration > 0 ? box.duration : 10).div(5).toString(),"s")),vals[1],"discrete", attr)
            ));
        } else if (animation == 12) {
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
                _animate("x", string(abi.encodePacked(uint256(box.duration > 0 ? box.duration : 10).mul(20).toString(),"ms")),vals[0], attr),
                _animate("y", string(abi.encodePacked(uint256(box.duration > 0 ? box.duration : 10).mul(20).toString(),"ms")),vals[1], attr)
            ));
        } else if (animation == 13) {
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
                _animate("x", string(abi.encodePacked(uint256(box.duration > 0 ? box.duration : 10).mul(25).toString(),"ms")),vals[0], attr),
                _animate("y", string(abi.encodePacked(uint256(box.duration > 0 ? box.duration : 10).mul(25).toString(),"ms")),vals[1], attr)
            ));
        } else if (animation == 14) {
            // grow n shrink
            return _animateTransform( "scale", duration, "1 1;1.5 1.5;1 1;.5 .5;1 1", "0;.25;.5;.75;1", attr );
        } else if (animation == 15) {
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
                _animate("width",duration,vals[0], attr),
                _animate("height",duration,vals[1], attr)
            ));
        } else if (animation == 16) {
            // Rounding corners
            return _animate("rx",duration,"0;100;0", attr);
        } else if (animation == 17) {
            // glide
            int256 amp = 20;
            string memory max = int256(0).add(amp).toString();
            string memory min = int256(0).sub(amp).toString();
            string memory values = string(abi.encodePacked( "0 0;", min, " ", min, ";0 0;", max, " ", max, ";0 0" ));
            return _animateTransform("translate",duration,values, attr);
        } else if (animation == 18) {
            // Wave
            string memory values = string(abi.encodePacked("1 1;1 1;1.5 1.5;1 1;1 1"));
            int256 div = int256(10000).div(int256(box.shapes + 1));
            int256 peak = int256(10000).sub(div.mul(int256(shapeIndex).add(1)));
            string memory mid = peak.toDecimal(4).toString();
            string memory start = peak.sub(div).toDecimal(4).toString();
            string memory end = peak.add(div).toDecimal(4).toString();
            string memory times = string(abi.encodePacked("0;", start, ";", mid, ";", end, ";1")); 
            return _animateTransform( "scale", duration, values, times, generateSplines(4,0), attr );
        } else if (animation == 19) {
            // Phased Fade
            uint256 fadeOut = uint256(box.shapes).sub(shapeIndex).mul(uint256(400).div(uint256(box.shapes)));
            uint256 fadeIn = uint256(900).sub(uint256(box.shapes).sub(shapeIndex).mul(uint256(400).div(uint256(box.shapes))));
            string memory times = string(abi.encodePacked("0;.", fadeOut.toString(), ";.", fadeIn.toString(), ";1"));
            return _animate("opacity", duration, "1;0;0;1", times, generateSplines(3,0), attr );
        } else if (animation == 20) {
            // Skew X
            return _animateTransform( "skewX", duration, "0;50;-50;0", attr );
        } else if (animation == 21) {
            // Skew Y
            return _animateTransform( "skewY", duration, "0;50;-50;0", attr );
        } else if (animation == 22) {
            // Stretch - (bounce skewX w/ ease-in-out)
            return _animateTransform(
                "skewX", string(abi.encodePacked(uint256(box.duration > 0 ? box.duration : 10).div(2).toString(),"s")), "0;-64;32;-16;8;-4;2;-1;.5;0;0", "0;.1;.2;.3;.4;.5;.6;.7;.8;.9;1", generateSplines(10,0), attr
            );
        } else if (animation == 23) {
            // Jello - (bounce skewX w/ ease-in)
            return _animateTransform(
                "skewX", duration, "0;16;-12;8;-4;2;-1;.5;-.25;0;0", "0;.1;.2;.3;.4;.5;.6;.7;.8;.9;1", generateSplines(10,1), attr
            );
        }
    }
}

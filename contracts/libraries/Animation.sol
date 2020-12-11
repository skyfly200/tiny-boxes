//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.4;

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
    function _animate(string memory attribute, string memory duration, string memory values) internal pure returns (string memory) {
        return _animate(attribute, duration, values, '');
    }

    /**
     * @dev render an animate SVG tag
     */
    function _animate(string memory attribute, string memory duration, string memory values, string memory calcMode) internal pure returns (string memory) {
        return string(abi.encodePacked('<animate attributeName="', attribute, '" values="', values, '" dur="', duration,
        bytes(calcMode).length == 0 ? '' : string(abi.encodePacked('" calcMode="',calcMode)),
        '" repeatCount="indefinite" />'));
    }

    /**
     * @dev render an animate SVG tag with keyTimes and keySplines
     */
    function _animate(string memory attribute, string memory duration, string memory values, string memory keyTimes, string memory keySplines) internal pure returns (string memory) {
        return string(abi.encodePacked('<animate attributeName="', attribute, '" values="', values, '" dur="', duration,
        '" keyTimes="',keyTimes,'" keySplines="',keySplines,
        '" calcMode="spline" repeatCount="indefinite" />'));
    }

    /**
     * @dev render an animateTransform SVG tag with keyTimes and keySplines
     */
    function _animateTransform(string memory typeVal, string memory duration, string memory values, string memory keyTimes, string memory keySplines) internal pure returns (string memory) {
        return string(abi.encodePacked('<animateTransform attributeName="transform" attributeType="XML" type="', typeVal,'" dur="', duration, '" values="', values,
            bytes(keyTimes).length == 0 ? '' : string(abi.encodePacked('" keyTimes="', keyTimes)),
            bytes(keySplines).length == 0 ? '' : string(abi.encodePacked('" calcMode="spline" keySplines="', keySplines)),
        '" repeatCount="indefinite" />'));
    }

    /**
     * @dev render an animateTransform SVG tag with keyTimes
     */
    function _animateTransform(string memory typeVal, string memory duration, string memory values, string memory keyTimes) internal pure returns (string memory) {
        return _animateTransform(typeVal, duration, values, keyTimes, '');
    }

    /**
     * @dev render an animateTransform SVG tag
     */
    function _animateTransform(string memory typeVal, string memory duration, string memory values) internal pure returns (string memory) {
        return _animateTransform(typeVal, duration, values, '', '');
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
            "0.5 0 0.75 1", // ease in and out fast
            ".6 0 .4 1" // ease in fast + soft
        ];
        for (uint8 i=0; i < transitions; i++)
            curves = string(abi.encodePacked(curves, i>0 ? ";" : "", bezierCurves[curve]));
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
            // snap spin 90
            return _animateTransform(
                "rotate", "10s",
                "0;90;90;360;360",
                "0;0.2;0.4;0.9;1",
                generateSplines(4,0)
            );
        } else if (animation == 1) {
            // snap spin 180
            return _animateTransform(
                "rotate", "10s",
                "0;180;180;360;360",
                "0;0.4;0.6;0.9;1",
                generateSplines(4,0)
            );
        } else if (animation == 2) {
            // snap spin 270
            return _animateTransform(
                "rotate", "10s", "0;270;270;360;360", "0;0.6;0.8;0.9;1",
                generateSplines(4,0)
            );
        } else if (animation == 3) {
            // snap spin tri
            return _animateTransform(
                "rotate", "10s", "0;120;120;240;240;360;360", "0;0.166;0.333;0.5;0.666;0.833;1",
                generateSplines(6,0)
            );
        } else if (animation == 4) {
            // snap spin quad
            return _animateTransform(
                "rotate", "10s", "0;90;90;180;180;270;270;360;360", "0;0.125;0.25;0.375;0.5;0.625;0.8;0.925;1",
                generateSplines(8,0)
            );
        } else if (animation == 5) {
            // snap spin tetra
            return _animateTransform(
                "rotate", "10s", "0;72;72;144;144;216;216;278;278;360;360", "0;0.1;0.2;0.3;0.4;0.5;0.6;0.7;0.8;0.9;1",
                generateSplines(10,0)
            );
        } else if (animation == 6) {
            // Uniform Speed Spin
            return _animateTransform( "rotate", "10s", "0;360", "0;1" );
        } else if (animation == 7) {
            // 2 Speed Spin
            return _animateTransform( "rotate", "10s", "0;90;270;360", "0;0.1;0.9;1" );
        } else if (animation == 8) {
            // indexed speed
            return _animateTransform(
                "rotate",
                string(abi.encodePacked(uint256((10000 / box.shapes) * (shapeIndex + 1) ).toString(),"ms")),
                "0;360",
                "0;1"
            );
        } else if (animation == 9) {
            // spread
            uint256 spread = uint256(300).div(uint256(box.shapes));
            string memory angle = shapeIndex.add(1).mul(spread).toString();
            string memory values = string(abi.encodePacked("0;",  angle, ";",  angle, ";360;360"));
            return _animateTransform( "rotate", "10s", values, "0;0.5;0.6;0.9;1", generateSplines(4,0) );
        } else if (animation == 10) {
            // spread w time
            uint256 spread = uint256(300).div(uint256(box.shapes));
            string memory angle = shapeIndex.add(1).mul(spread).toString();
            string memory values = string(abi.encodePacked("0;",  angle, ";",  angle, ";360"));
            uint256 timeShift = uint256(100).add(uint256(box.shapes).sub(shapeIndex).mul(uint256(700).div(uint256(box.shapes))));
            string memory times = string(abi.encodePacked("0;0.", timeShift.toString(), ";0.9;1"));
            return _animateTransform( "rotate", "10s", values, times, generateSplines(3,0) );
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
                _animate("x","1s",vals[0],"discrete"),
                _animate("y","2s",vals[1],"discrete")
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
                _animate("x","200ms",vals[0]),
                _animate("y","200ms",vals[1])
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
                _animate("x","250ms",vals[0]),
                _animate("y","250ms",vals[1])
            ));
        } else if (animation == 14) {
            // grow n shrink
            return _animateTransform( "scale", "10s", "1 1;1.5 1.5;1 1;0.5 0.5;1 1", "0;0.25;0.5;0.75;1" );
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
                _animate("width","10s",vals[0]),
                _animate("height","10s",vals[1])
            ));
        } else if (animation == 16) {
            // Rounding corners
            return _animate("rx","10s","0;100;0");
        } else if (animation == 17) {
            // glide
            int256 amp = 20;
            int256 posX = shape.position[0];
            int256 posY = shape.position[1];
            string memory avg = string(abi.encodePacked(posX.toString(), " ", posY.toString()));
            string memory max = string(abi.encodePacked(posX.add(amp).toString(), " ", posY.add(amp).toString()));
            string memory min = string(abi.encodePacked(posX.sub(amp).toString(), " ", posY.sub(amp).toString()));
            string memory values = string(abi.encodePacked( avg, ";", min, ";", avg, ";", max, ";", avg ));
            return _animateTransform("translate","10s",values);
        } else if (animation == 18) {
            // Wave
            string memory values = string(abi.encodePacked("1 1;1 1;1.5 1.5;1 1;1 1"));
            // TODO: generate decimal values and convetr to strings
            // start min 0, end max 1
            uint256 length = 10; // percent of the animation length for each wave pulse
            uint256 peak = uint256(100).add(uint256(box.shapes).sub(shapeIndex).mul(uint256(700).div(uint256(box.shapes))));
            string memory start = peak.sub(length).toString();
            string memory end = peak.add(length).toString();
            string memory times = string(abi.encodePacked("0;", start, ";", peak.toString(), ";", end, ";1")); 
            return _animateTransform( "scale", "10s", values, times, generateSplines(4,0) );
        } else if (animation == 19) {
            // Phased Fade
            uint256 fadeOut = uint256(100).add(uint256(box.shapes).sub(shapeIndex).mul(uint256(700).div(uint256(box.shapes))));
            uint256 fadeIn = uint256(900).sub(uint256(box.shapes).sub(shapeIndex).mul(uint256(700).div(uint256(box.shapes))));
            string memory times = string(abi.encodePacked("0;0.", fadeOut.toString(), ";0.", fadeIn.toString(), ";1"));
            return _animate("opacity", "10s", "1;0;0;1", times, generateSplines(3,0) );
        } else if (animation == 20) {
            // Skew X
            return _animateTransform( "skewX", "10s", "0;50;-50;0" );
        } else if (animation == 21) {
            // Skew Y
            return _animateTransform( "skewY", "10s", "0;50;-50;0" );
        } else if (animation == 22) {
            // Stretch - (bounce skewX w/ ease-in-out)
            return _animateTransform(
                "skewX", "5s", "0;-64;32;-16;8;-4;2;-1;.5;0;0", "0;.1;.2;.3;.4;.5;.6;.7;.8;.9;1", generateSplines(10,0)
            );
        } else if (animation == 23) {
            // Jello - (bounce skewX w/ ease-in)
            return _animateTransform(
                "skewX", "10s", "0;16;-12;8;-4;2;-1;.5;-.25;0;0", "0;.1;.2;.3;.4;.5;.6;.7;.8;.9;1", generateSplines(10,1)
            );
        } else if (animation == 24) {
            // Alternate Skew X - alternate skew every other left / right
            return _animateTransform( "skewX", "10s", shapeIndex%2==0 ? "0;50;-50;0" : "0;-50;50;0" );
        } else if (animation == 25) {
            // Alternate Skew Y - alternate skew every other up / down
            return _animateTransform( "skewY", "10s", shapeIndex%2==0 ? "0;50;-50;0" : "0;-50;50;0" );
        
        }
    }
}

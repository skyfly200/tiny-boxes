//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

// needed for upgradability
//import "@openzeppelin/upgrades/contracts/Initializable.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./Buffer.sol";
import "./Random.sol";

contract TinyBoxes is ERC721 {
    //using SafeMath for uint256;

    uint256 public constant TOKEN_LIMIT = 1024;
    uint256 public constant ARTIST_PRINTS = 0;
    int256 public constant ANIMATION_COUNT = 1;
    address public creator;
    address payable artmuseum = 0x027Fb48bC4e3999DCF88690aEbEBCC3D1748A0Eb; //lolz

    string header = '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">\n<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="100%" height="100%" viewBox="0 0 2600 2600" style="stroke-width:0; background-color:#121212;">\n\n<symbol id="upperleftquad4">\n<symbol id="upperleftquad3">\n<symbol id="upperleftquad2">\n<symbol id="upperleftquad">\n\n';
    string[3] scales = ["-1 1", "-1 -1", "1 -1"];
    string[7] template = [
        "\n<g>",
        '\n<g transform="scale(',
        ") translate(",
        ')">',
        '\n<use xlink:href="#upperleftquad',
        '"/>\n</g>',
        "\n</symbol>"
    ];

    struct TinyBox {
        uint256 seed;
        uint8 animation;
        uint8 shapes;
        uint8 colors;
        uint16 hatching;
        uint16 scale;
        int16[3] mirrorPositions;
        uint16[4] size;
        uint16[4] spacing;
        bool[3] mirrors;
    }

    struct Shape {
        uint256 color;
        uint256[2] size;
        int256[2] position;
    }

    mapping(uint256 => TinyBox) internal boxes;

    /**
     * @dev Contract constructor.
     */
    constructor() public ERC721("TinyBoxes", "[#][#]") {
        creator = msg.sender;
    }

    /**
     * @dev generate a color
     * @param pool randomn numbers
     * @param _id of token to render
     * @return color value
     */
    function _generateColor(bytes32[] memory pool, uint256 _id)
        internal
        pure
        returns (uint256)
    {
        uint256 red = uint256(Random.uniform(pool, 0x000012, 0x0000ff));
        uint256 green = uint256(Random.uniform(pool, 0x000012, 0x0000ff) * 256);
        uint256 blue = uint256(
            Random.uniform(pool, 0x000012, 0x0000ff) * 65536
        );
        uint256 colorscheme = uint256(Random.uniform(pool, 0, 99));

        if (_id == 0) {
            return 0x000000; // all black
        } else if (_id > 73 && _id < 80) {
            return uint256(0xffffff); // all white
        } else if (colorscheme < 7) {
            return blue;
        } else if (colorscheme < 14) {
            return green;
        } else if (colorscheme < 21) {
            return red;
        } else if (colorscheme < 35) {
            return green + blue;
        } else if (colorscheme < 49) {
            return red + blue;
        } else if (colorscheme < 63) {
            return red + green;
        } else if (colorscheme < 66) {
            uint256 brightness = uint256(
                Random.uniform(pool, 0x000022, 0x0000ee)
            ); // random greys
            return (brightness * 65536) + (brightness * 256) + brightness;
        } else {
            return blue;
        }
    }

    /**
     * @dev generate a shape
     * @param pool randomn numbers
     * @param spacing for shapes
     * @param size of shapes
     * @param hatch mode on
     * @return positions of shape
     */
    function _generateShape(
        bytes32[] memory pool,
        uint16[4] memory spacing,
        uint16[4] memory size,
        bool hatch
    )
        internal
        pure
        returns (int256[2] memory positions, uint256[2] memory dimensions)
    {
        positions = [
            Random.uniform(pool, -(int256(spacing[0])), int256(spacing[0])) +
                ((Random.uniform(pool, 0, int256(spacing[2]) - 1) * 800) /
                    int256(spacing[2])),
            Random.uniform(pool, -(int256(spacing[1])), int256(spacing[1])) +
                ((Random.uniform(pool, 0, int256(spacing[3]) - 1) * 800) /
                    int256(spacing[3]))
        ];
        if (hatch) {
            uint256 horizontal = uint256(Random.uniform(pool, 0, 1));
            // 		size[0] = uint(Random.uniform(pool, dials[4], dials[5])) + horizontal * uint(dials[6]);
            //      size[1] = uint(dials[6]) + uint(dials[5])  - size[0] + uint256(Random.uniform(pool, dials[7], dials[4]));
            uint256 width = uint256(Random.uniform(pool, 25, 40)) +
                uint256(700 * horizontal);
            dimensions = [
                width,
                uint256(Random.uniform(pool, 10, 25)) + uint256(740 - width)
            ];
        } else
            dimensions = [
                uint256(Random.uniform(pool, int256(size[0]), int256(size[1]))),
                uint256(Random.uniform(pool, int256(size[2]), int256(size[3])))
            ];
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
        uint16 scale
    ) internal view returns (string memory footer) {
        bytes memory buffer = new bytes(8192);

        for (uint8 s = 0; s < 3; s++) {
            // loop through mirroring effects
            Buffer.append(buffer, template[6]);

            if (!switches[s]) {
                // turn off this level of mirroring
                // add a scale transform
                Buffer.append(buffer, template[0]);
                // denote what quad the transform should be used for
                Buffer.append(buffer, template[4]);
                if (s > 0)
                    Buffer.append(buffer, Strings.toString(uint256(s + 1)));
                Buffer.append(buffer, template[5]);
            } else {
                string memory value = Strings.toString(
                    uint256(mirrorPositions[s])
                );
                for (uint8 i = 0; i < 4; i++) {
                    // loop through transforms
                    if (i == 0) Buffer.append(buffer, template[0]);
                    else {
                        Buffer.append(buffer, template[1]);
                        Buffer.append(buffer, scales[i - 1]);
                        Buffer.append(buffer, template[2]);
                        if (i <= 2) Buffer.append(buffer, "-");
                        Buffer.append(buffer, i <= 2 ? value : "0");
                        Buffer.append(buffer, " ");
                        if (i >= 2) Buffer.append(buffer, "-");
                        Buffer.append(buffer, i >= 2 ? value : "0");
                        Buffer.append(buffer, template[3]);
                    }
                    // denote what quad the transformsshould be used for
                    Buffer.append(buffer, template[4]);
                    if (s > 0)
                        Buffer.append(buffer, Strings.toString(uint256(s + 1)));
                    Buffer.append(buffer, template[5]);
                }
            }
        }
        // add final scaling
        string memory scaleWhole = Strings.toString(uint256(scale).div(100));
        string memory scaleDecimals = Strings.toString(uint256(scale).mod(100));
        Buffer.append(buffer, template[6]);
        Buffer.append(buffer, template[1]);
        Buffer.append(buffer, scaleWhole);
        Buffer.append(buffer, ".");
        Buffer.append(buffer, scaleDecimals);
        Buffer.append(buffer, " ");
        Buffer.append(buffer, scaleWhole);
        Buffer.append(buffer, ".");
        Buffer.append(buffer, scaleDecimals);
        Buffer.append(buffer, template[3]);
        Buffer.append(buffer, template[4]);
        Buffer.append(buffer, "4");
        Buffer.append(buffer, template[5]);

        Buffer.append(buffer, "\n</svg>"); // add closing svg tag
        return Buffer.toString(buffer);
    }

    /**
     * @dev render a token's art
     * @param _id of token
     * @param box TinyBox data structure
     * @param frame number to render
     * @return the SVG graphiccs of the token
     */
    function perpetualRenderer(
        uint256 _id,
        TinyBox memory box,
        uint256 frame
    ) public view returns (string memory) {
        // initialize an empty buffer
        bytes memory buffer = new bytes(8192);

        // write the document header to the SVG buffer
        Buffer.append(buffer, header);

        // initilize RNG with the specified seed and blocks 0 through 1
        bytes32[] memory pool = Random.init(0, 1, box.seed);

        // set animation modifiers to default
        uint256 colorShift = 0;
        uint256 hatchShift = 0;
        uint256 stackShift = 0;
        uint256[4] memory spacingShift = 0;
        uint256[4] memory sizeRangeShift = 0;
        uint256[2] memory positionShift = 0;
        uint256[2] memory sizeShift = 0;
        uint256[3] memory mirrorShift = [0, 0, 0];

        // modulate the animation modifiers based on frames and animation id
        if (box.animation == 0) {
            colorShift = frame;
        } else if (box.animation == 1) {
            hatchMod = frame;
        } else if (box.animation == 2) {
            stackShift = frame;
        } else if (box.animation == 3) {
            mirrorShift[0] = frame;
        }

        // generate colors
        uint256[] memory colorValues = new uint256[](box.colors);
        for (uint256 i = 0; i < box.colors; i++)
            colorValues[i] = _generateColor(pool, _id);

        // generate shapes
        Shape[box.shapes] memory shapes;
        for (uint256 i = 0; i < box.shapes; i++) {
            // hatching mod. 1 in hybrid shapes will be hatching type
            // offset hatching mod start by hatchMod
            bool hatched = (box.hatching > 0 &&
                i.add(hatchShift).mod(box.hatching) == 0);
            // modulate shape generator input parameters
            for (uint256 j = 0; j < 4; j++) {
                box.spacing[j] = box.spacing[j].add(spacingShift[j]);
                box.size[j] = box.size[j].add(sizeRangeShift[j]);
            }
            // generate a shapes position and size using box parameters
            (
                int256[2] memory position,
                uint256[2] memory size
            ) = _generateShape(pool, box.spacing, box.size, hatched);
            // modulate the shape position and size
            position[0] = position[0].add(positionShift[0]);
            position[1] = position[1].add(positionShift[1]);
            size[0] = size[0].add(sizeShift[0]);
            size[1] = size[1].add(sizeShift[1]);
            // pick a random color from the generated colors list
            int256 randomColorSelection = Random.uniform(
                pool,
                0,
                int256(uint256(box.shapes).sub(1))
            );
            // modulate colors by colorShift
            uint256 color = colorValues[uint256(randomColorSelection)
                .add(colorShift)
                .mod(box.shapes)];
            // create a new shape and add it to the shapes list
            shapes.push(Shape(position, size, color));
        }

        // add shapes
        for (uint256 i = 0; i < box.shapes; i++) {
            Shape shape = shapes[i.add(stackShift).mod(box.shapes)];
            // add a rectangle with given position, size and color to the SVG markup
            Buffer.rect(buffer, shape.position, shape.size, shape.color);
        }

        // modulate mirroring and scaling transforms
        box.mirrorPositions[0] = box.mirrorPositions[0].add(mirrorShift[0]);
        box.mirrorPositions[1] = box.mirrorPositions[1].add(mirrorShift[1]);
        box.mirrorPositions[2] = box.mirrorPositions[2].add(mirrorShift[2]);

        // generate the footer with mirroring and scale transforms
        Buffer.append(
            buffer,
            _generateFooter(box.mirrors, box.mirrorPositions, box.scale)
        );

        // return an SVG file as string
        return Buffer.toString(buffer);
    }

    /**
     * @dev Create a new TinyBox Token
     * @param _seed of token
     * @param counts of token colors & shapes
     * @param dials of token renderer
     * @param mirrors active boolean of token
     */
    function createBox(
        string calldata _seed,
        uint8[2] calldata counts,
        int16[13] calldata dials,
        bool[3] calldata mirrors
    ) external payable {
        require(
            msg.sender != address(0),
            "token recipient man not be the zero address"
        );
        require(
            totalSupply() < TOKEN_LIMIT,
            "ART SALE IS OVER. Tinyboxes are now only available on the secondary market."
        );

        if (totalSupply() < ARTIST_PRINTS) {
            require(
                msg.sender == address(creator),
                "Only the creator can mint the alpha token. Wait your turn FFS"
            );
        } else {
            uint256 amount = currentPrice();
            require(msg.value >= amount, "insuficient payment"); // return if they dont pay enough
            if (msg.value > amount) msg.sender.transfer(msg.value - amount); // give change if they over pay
            artmuseum.transfer(amount); // send the payment amount to the artmuseum account
        }

        // convert seed from string to uint
        uint256 seed = Random.stringToUint(_seed);

        // initilized RNG with the seed and blocks 0 through 1
        bytes32[] memory pool = Random.init(0, 1, seed);

        uint256 id = totalSupply();

        // TODO - generate animation with RNG weighted non uniformly for varying rarity
        // maybe use log base 2 of a number in a range 2 to the animation counts
        boxes[id] = TinyBox({
            seed: seed,
            animation: uint8(Random.uniform(pool, 0, ANIMATION_COUNT - 1)),
            shapes: counts[1],
            colors: counts[0],
            spacing: [
                uint16(dials[0]),
                uint16(dials[1]),
                uint16(dials[2]),
                uint16(dials[3])
            ],
            size: [
                uint16(dials[4]),
                uint16(dials[5]),
                uint16(dials[6]),
                uint16(dials[7])
            ],
            hatching: uint16(dials[8]),
            mirrorPositions: [dials[9], dials[10], dials[11]],
            scale: uint16(dials[12]),
            mirrors: mirrors
        });

        _safeMint(msg.sender, id);
    }

    /**
     * @dev Get the current price of a token
     * @return price in wei of a token currently
     */
    function currentPrice() public view returns (uint256 price) {
        price = priceAt(totalSupply());
    }

    /**
     * @dev Get the price of a specific token id
     * @param _id of the token
     * @return price in wei of that token
     */
    function priceAt(uint256 _id) public pure returns (uint256 price) {
        uint256 tokeninflation = (_id / 2) * 1000000000000000; // add .001 eth inflation per token
        price = tokeninflation + 160000000000000000; // in wei, starting price .16 eth, ending price .2 eth
    }

    /**
     * @dev Lookup the seed
     * @param _id for which we want the seed
     * @return seed value of _id.
     */
    function tokenSeed(uint256 _id) external view returns (uint256) {
        return boxes[_id].seed;
    }

    /**
     * @dev Lookup the animation
     * @param _id for which we want the animation
     * @return animation value of _id.
     */
    function tokenAnimation(uint256 _id) external view returns (uint256) {
        return boxes[_id].animation;
    }

    /**
     * @dev Lookup all token data in one call
     * @param _id for which we want token data
     * @return seed of token
     * @return animation of token
     * @return colors of token
     * @return shapes of token
     * @return hatching of token
     * @return size of token
     * @return spacing of token
     * @return mirrorPositions of token
     * @return mirrors of token
     * @return scale of token
     */
    function tokenData(uint256 _id)
        external
        view
        returns (
            uint256 seed,
            uint8 animation,
            uint8 colors,
            uint8 shapes,
            uint16 hatching,
            uint16[4] memory size,
            uint16[4] memory spacing,
            int16[3] memory mirrorPositions,
            bool[3] memory mirrors,
            uint16 scale
        )
    {
        TinyBox memory box = boxes[_id];
        seed = box.seed;
        animation = box.animation;
        colors = box.colors;
        shapes = box.shapes;
        hatching = box.hatching;
        size = box.size;
        spacing = box.spacing;
        mirrorPositions = box.mirrorPositions;
        mirrors = box.mirrors;
        scale = box.scale;
    }

    /**
     * @dev Generate the token SVG art preview for given parameters
     * @param _seed for renderer RNG
     * @param counts for colors and shapes
     * @param dials for perpetual renderer
     * @param mirrors switches
     * @return preview SVG art
     */
    function tokenPreview(
        uint256 _id,
        string memory _seed,
        uint8[2] memory counts,
        int16[13] memory dials,
        bool[3] memory mirrors
    ) public view returns (string memory) {
        TinyBox memory box = TinyBox({
            seed: Random.stringToUint(_seed),
            animation: 0,
            shapes: counts[1],
            colors: counts[0],
            spacing: [
                uint16(dials[0]),
                uint16(dials[1]),
                uint16(dials[2]),
                uint16(dials[3])
            ],
            size: [
                uint16(dials[4]),
                uint16(dials[5]),
                uint16(dials[6]),
                uint16(dials[7])
            ],
            hatching: uint16(dials[8]),
            mirrorPositions: [dials[9], dials[10], dials[11]],
            scale: uint16(dials[12]),
            mirrors: mirrors
        });
        return perpetualRenderer(_id, box, 0);
    }

    /**
     * @dev Generate the token SVG art of a specified frame
     * @param _id for which we want art
     * @param _frame for which we want art
     * @return animated SVG art of token _id at _frame.
     */
    function tokenFrame(uint256 _id, uint256 _frame)
        public
        view
        returns (string memory)
    {
        TinyBox memory box = boxes[_id];
        return perpetualRenderer(_id, box, _frame);
    }

    /**
     * @dev Generate the static token SVG art
     * @param _id for which we want art
     * @return URI of _id.
     */
    function tokenArt(uint256 _id) external view returns (string memory) {
        // render frame 0 of the token animation
        return tokenFrame(_id, 0);
    }
}

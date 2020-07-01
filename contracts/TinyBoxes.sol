//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

// needed for upgradability
//import "@openzeppelin/upgrades/contracts/Initializable.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./TinyBoxesRenderer.sol";

// Chainlink VRF Base
import "./chainlink/VRFConsumerBase.sol";

contract TinyBoxes is ERC721, VRFConsumerBase, TinyBoxesRenderer {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    uint256 public constant TOKEN_LIMIT = 1024;
    uint256 public constant ARTIST_PRINTS = 0;
    int256 public constant ANIMATION_COUNT = 1;
    address public animator;
    address public creator;
    address payable artmuseum = 0x027Fb48bC4e3999DCF88690aEbEBCC3D1748A0Eb; //lolz

    // Chainlink VRF Stuff
    address constant VRF_COORDINATOR = 0xc1031337fe8E75Cf25CAe9828F3BF734d83732e4; // Rinkeby
    address constant LINK_TOKEN_ADDRESS = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709; // Rinkeby
    //address public constant LINK_TOKEN_ADDRESS = 0x514910771af9ca656af840dff83e8264ecf986ca; // Mainnet
    bytes32 constant KEY_HASH = 0xcad496b9d0416369213648a32b4975fff8707f05dfb43603961b58f3ac6617a7; // Rinkeby details
    uint256 constant fee = 10**18;

    struct Request {
        address creator;
        uint256 id;
    }

    mapping(uint256 => TinyBox) internal boxes;
    mapping(bytes32 => Request) internal requests;

    /**
     * @dev Contract constructor.
     * @notice Constructor inherits VRFConsumerBase
     */
    constructor(address _animator)
        public
        ERC721("TinyBoxes", "[#][#]")
        VRFConsumerBase(VRF_COORDINATOR, LINK_TOKEN_ADDRESS)
    {
        creator = msg.sender;
        animator = _animator;
        LINK = LinkTokenInterface(LINK_TOKEN_ADDRESS);
    }

    /**
     * @notice Modifier to only allow randomness fulfillment by the VRFCoordinator contract
     */
    modifier onlyVRFCoordinator {
        require(
            msg.sender == VRF_COORDINATOR,
            "Fulfillment only allowed by VRFCoordinator"
        );
        _;
    }

    /**
     * @notice Modifier to only allow URI updates by the Animator address
     */
    modifier onlyAnimator {
        require(msg.sender == animator, "URI update only allowed by Animator");
        _;
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

        // ensure we have enough LINK token in the contract to pay for VRF
        require(
            LINK.balanceOf(address(this)) > fee,
            "Not enough LINK for a VRF request"
        );

        // convert user seed from string to uint
        uint256 seed = Random.stringToUint(_seed);

        // Hash user seed and blockhash for VRFSeed
        uint256 seedVRF = uint256(
            keccak256(abi.encode(seed, blockhash(block.number)))
        );
        // send VRF request
        bytes32 _requestId = requestRandomness(KEY_HASH, fee, seedVRF);

        // map requestId to next token id and owner
        requests[_requestId] = Request(msg.sender, _tokenIds.current());

        // register the new box data
        boxes[_tokenIds.current()] = TinyBox({
            seed: seed,
            randomness: 0,
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

        // increment the id counter
        _tokenIds.increment();

        return _requestId;
    }

    /**
     * @notice Callback function used by VRF Coordinator
     * @dev Important! Add a modifier to only allow this function to be called by the VRFCoordinator
     * @dev This is where you do something with randomness!
     * @dev The VRF Coordinator will only send this function verified responses.
     * @dev The VRF Coordinator will not pass randomness that could not be verified.
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        external
        override
        onlyVRFCoordinator
    {
        // need to move minting here with saved data from a request
        Request memory creation = requests[requestId];

        // initilized RNG with the provided varifiable randomness and blocks 0 through 1
        bytes32[] memory pool = Random.init(0, 1, randomness);

        // TODO - generate animation with RNG weighted non uniformly for varying rarity
        // maybe use log base 2 of a number in a range 2 to the animation counts
        uint8 animation = uint8(Random.uniform(pool, 0, ANIMATION_COUNT - 1));

        // update box data relying on randomness
        boxes[creation.id].randomness = randomness;
        boxes[creation.id].animation = animation;

        // mint the token to the creator
        _safeMint(creation.creator, creation.id);
    }

    /**
     * @dev Update the token URI field
     * @dev Only the animator role can call this
     */
    function updateURI(uint256 _id, string calldata _uri)
        external
        onlyAnimator
    {
        _setTokenURI(_id, _uri);
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
            randomness: Random.stringToUint(_seed),
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
        return Buffer.toString(perpetualRenderer(_id, box, 0));
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
        return Buffer.toString(perpetualRenderer(_id, box, _frame));
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

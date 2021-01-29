## `TinyBoxes`






### `constructor()` (public)



Contract constructor.

### `_generateColor(bytes32[] pool, uint256 _id) → uint256` (internal)



generate a color


### `_generateShape(bytes32[] pool, int256[13] dials, bool hatch) → int256[2] positions, uint256[2] size` (internal)



generate a shape


### `_generateFooter(bool[3] switches, int256[4] mirrorDials) → string footer` (internal)



render the footer string for mirring effects


### `perpetualRenderer(uint256 _id, string seed, uint256[2] counts, int256[13] dials, bool[3] switches) → string` (public)



render a token's art


### `createBox(string seed, uint256[2] counts, int256[13] dials, bool[3] switches)` (external)



Create a new TinyBox Token


### `currentPrice() → uint256 price` (public)



Get the current price of a token


### `priceAt(uint256 _id) → uint256 price` (public)



Get the price of a specific token id


### `tokenCreator(uint256 _id) → address` (external)



Lookup the creator


### `tokenSeed(uint256 _id) → uint256` (external)



Lookup the seed


### `tokenCounts(uint256 _id) → uint256[]` (external)



Lookup the counts


### `tokenDials(uint256 _id) → int256[]` (external)



Lookup the dials


### `tokenSwitches(uint256 _id) → bool[]` (external)



Lookup the switches


### `tokenArt(uint256 _id) → string` (external)



Generate the token SVG art




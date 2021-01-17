# Contract
## Perpetual Renderer - SVG output
All the magic happens here, each box is stitched together from its options and randomness bytes

Out pops an SVG graphic

### tokenPreview
Allows you to preview the resulting art of various options and random outcomes

### tokenArt
Renders the art for an existing token.

overloaded call with settings allows for rendering of non default settings

## Settings
Dynamic settings for rendering each token.

Settings may be updated by a token owner or operator (ie. approvedFor) by calling the changeSettings method on the contract (UI feature for this coming soon)

These settings are used when rendering the tokens art on the DAPP and for the Metadata API. Allowing you to update how your token appears on secondary markets and wallets.

### Background
The lightness of the background color from black at 0 to white at 100, 101 is transparent.

### Duration
Defaults to 10. Set higher to slow and lengthen animations, lower to speed up and shorten.

If set to 0 uses the default

### Options
An 8 bit set of boolean flags, the first of witch sets if animation is active or not

## Contract Code
Here is the auto generated docs for the contract source code

[Contract Auto Docs](./TinyBoxes)

We will have the verified contract source up on ether scan shortly
# Contract
## Perpetual Renderer - SVG output
This is where the magic happens! Each box is stitched together from the options you selected and randomness bytes…

And out pops an SVG graphic!

Here are the methods driving this process.
The magic demystified

### tokenPreview
Allows you to preview the resulting art from various options and random outcomes

### tokenArt
Renders the art for an existing token.

Overloaded call with added settings args allows for rendering with custom configurations

## Settings
These are the dynamic settings for rendering each token.

Settings may be updated by a token owner or operator (ie. approvedFor) by calling the changeSettings method on the contract (UI feature for this coming soon)

These settings are used when rendering the tokens art on the DAPP and for the Metadata API, allowing you to update how your token appears on secondary markets and wallets.

### Background
The background color of the token art. An RGB value in hexadecimal format.

### Duration
Defaults to 10. Set higher to slow and lengthen animations, lower to speed up and shorten.

(If set to 0, your TinyBox renders using the defaults)

### Options
An 8-bit set of boolean flags, the first of which controls whether animation is active or not

## Contract Code
Here is the auto generated docs for the contract source code

[Contract Auto Docs](./TinyBoxes)

View the Verified contract on Etherscan

[TinyBoxes Contract](https://etherscan.io/address/0x46f9a4522666d2476a5f5cd51ea3e0b5800e7f98#code)
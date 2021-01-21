// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  // If this script is run directly using `node` you may want to call compile 
  // manually to make sure everything is compiled
  // await hre.run('compile');


  const randomizer = "0x02F597BFdB0291FE0789CA123D0dD9A2babfE845";

  // We get the contract to deploy
  const TinyBoxes = await hre.ethers.getContractFactory("TinyBoxes",{
        libraries: {
            TinyBoxesRenderer: "0x863b06aD8826B7b7bbA5096210d0Ff67715acD5a",
        }
    });
  const tinyboxes = await TinyBoxes.deploy(randomizer);

  await tinyboxes.deployed();

  console.log("TinyBoxes deployed to:", tinyboxes.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
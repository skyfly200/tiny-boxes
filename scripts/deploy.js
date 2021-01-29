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

  // deploy the Animation lib
  const Animation = await hre.ethers.getContractFactory("Animation",{
      libraries: {
          FixidityLib: "0x34cFa7d44a6698E68FB067e3C48ebB831873E534",
          Utils: "0xA87158c03e304d88C93D2a9B8AE2046e8EaB29b9"
      }
    });
  const animation = await Animation.deploy();

  await animation.deployed();

  console.log("Animation deployed to:", animation.address);

  // deploy the Renderer lib
  const TinyBoxesRenderer = await hre.ethers.getContractFactory("TinyBoxesRenderer",{
        libraries: {
            Colors: "0x0B37DC0Adc2948f3689dfB8200F3419424360d85",
            Utils: "0xA87158c03e304d88C93D2a9B8AE2046e8EaB29b9"
        }
    });
  const tinyboxesrenderer = await TinyBoxesRenderer.deploy(animation.address);

  await tinyboxesrenderer.deployed();

  console.log("TinyBoxesRenderer deployed to:", tinyboxesrenderer.address);

  // deploy random stub
  const RandomStub = await hre.ethers.getContractFactory("RandomStub");
  const randomstub = await RandomStub.deploy();

  await randomstub.deployed();

  console.log("RandomStub deployed to:", randomstub.address);

  // deploy the main contract
  const TinyBoxes = await hre.ethers.getContractFactory("TinyBoxes");
  const tinyboxes = await TinyBoxes.deploy(randomstub.address, tinyboxesrenderer.address);

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
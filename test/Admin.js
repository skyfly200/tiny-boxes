const { expect } = require("chai");

describe("Testing TinyBoxes Admin Methods", function() {
    let tinyboxes;
    let owner;
    let addr1;
    let addr2;
    let addrs;
    let price = 1;

    before(async function () {
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
        // deploy the Animation lib
        const Animation = await hre.ethers.getContractFactory("Animation",{
            libraries: {
                FixidityLib: "0x34cFa7d44a6698E68FB067e3C48ebB831873E534",
                Utils: "0xA87158c03e304d88C93D2a9B8AE2046e8EaB29b9"
            }
        });
        const animation = await Animation.deploy();
        await animation.deployed();
        // deploy the Renderer lib
        const TinyBoxesRenderer = await hre.ethers.getContractFactory("TinyBoxesRenderer",{
            libraries: {
                Colors: "0x0B37DC0Adc2948f3689dfB8200F3419424360d85",
                Utils: "0xA87158c03e304d88C93D2a9B8AE2046e8EaB29b9"
            }
        });
        const tinyboxesrenderer = await TinyBoxesRenderer.deploy(animation.address);
        await tinyboxesrenderer.deployed();
        // deploy a random stub
        const RandomStub = await hre.ethers.getContractFactory("RandomStub");
        const randomstub = await RandomStub.deploy();
        await randomstub.deployed();
        // deploy the main contract
        const TinyBoxes = await hre.ethers.getContractFactory("TinyBoxes");
        tinyboxes = await TinyBoxes.deploy(randomstub.address, tinyboxesrenderer.address);
        await tinyboxes.deployed();
    });

    it("Can Set Block Timer in the Future", async function() {
        const nextBlock = await ethers.provider.getBlockNumber() + 2;
        console.log("Countdown to ", nextBlock);
        await tinyboxes.startCountdown(nextBlock);
        expect(await tinyboxes.blockStart()).to.equal(nextBlock);
    });

    it("Can't Set Block Timer as the Current Block", async function() {
        const current = await ethers.provider.getBlockNumber();
        await expect(tinyboxes.startCountdown(current)).to.be.reverted;
    });

    it("Can't Set Block Timer in the Past", async function() {
        const current = await ethers.provider.getBlockNumber() - 10;
        await expect(tinyboxes.startCountdown(current)).to.be.reverted;
    });
    
    it("Can Pause", async function() {
        await tinyboxes.setPause(true);
        expect(await tinyboxes.paused()).to.equal(true);
    });

    it("Can Unpause", async function() {
        await tinyboxes.setPause(false);
        expect(await tinyboxes.paused()).to.equal(false);
    });

    it("Can get Randomness bytes", async function() {
        const rand = await tinyboxes.testRandom();
        console.log(rand);
        expect(rand).to.be.a("string");
    });

    it("Can set a new randomizer", async function() {
        // deploy a new random stub
        const RandomStub = await hre.ethers.getContractFactory("RandomStub");
        const randomstub = await RandomStub.deploy();
        await randomstub.deployed();
        await tinyboxes.setRandom(randomstub.address);
        const rand = await tinyboxes.testRandom();
        console.log(rand);
        expect(rand).to.be.a("string");
    });

    it("Can Set Contract ABI", async function() {
        await tinyboxes.setContractURI("test");
        expect(await tinyboxes.contractURI()).to.equal("test");
    });

    it("Can Set Base ABI", async function() {
        await tinyboxes.setBaseURI("test/");
        expect(await tinyboxes.baseURI()).to.equal("test/");
    });

    it("Can Set Token ABI", async function() {
        await tinyboxes.create(1111, 30, 5, [100,50,70], [100,100,100,100], [50,50], 63, addr1.address, 10000, {value:price});
        await tinyboxes.setTokenURI(0,0);
        expect(await tinyboxes.tokenURI(0)).to.equal("test/0");
    });
});



const { expect } = require("chai");

describe("Testing TinyBoxes Settings Methods", function() {
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
        // unpasue and mint a token for testing
        await tinyboxes.setPause(false);
        await tinyboxes.create(1111, 30, 5, [100,50,70], [100,100,100,100], [50,50], 63, owner.address, 10000, {value:price});
    });

    it("Can read a tokens settings", async function() {
        const settings = await tinyboxes.readSettings(0);
        expect(settings.bkg).to.equal(0);
        expect(settings.duration).to.equal(10);
        expect(settings.options).to.equal(1);
    });

    it("A tokens owner can set its settings", async function() {
        await expect(tinyboxes.changeSettings(0, [10,5,7]))
            .to.emit(tinyboxes, 'SettingsChanged')
            .withArgs([10,5,7]);
        const settings = await tinyboxes.readSettings(0);
        expect(settings.bkg).to.equal(10);
        expect(settings.duration).to.equal(5);
        expect(settings.options).to.equal(7);
    });

    it("Only a tokens owner can set its settings", async function() {
        await expect(tinyboxes.connect(addr2).changeSettings(0, [10,5,7]))
            .to.be.reverted;
    });

});
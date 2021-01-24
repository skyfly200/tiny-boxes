const { expect } = require("chai");

describe("Testing TinyBoxes Render Methods", function() {
    let tinyboxes;
    let tinyboxesrenderer;
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
        // deploy the Renderer contract
        const TinyBoxesRenderer = await hre.ethers.getContractFactory("TinyBoxesRenderer",{
            libraries: {
                Animation: animation.address,
                Colors: "0x482061da021C0C562892065Cb208A2370160AB31",
                Utils: "0xA87158c03e304d88C93D2a9B8AE2046e8EaB29b9"
            }
        });
        tinyboxesrenderer = await TinyBoxesRenderer.deploy();
        await tinyboxesrenderer.deployed();
        // deploy random stub
        const RandomStub = await hre.ethers.getContractFactory("RandomStub");
        const randomstub = await RandomStub.deploy();
        await randomstub.deployed();
        // deploy the main contract
        const TinyBoxes = await hre.ethers.getContractFactory("TinyBoxes");
        tinyboxes = await TinyBoxes.deploy(randomstub.address);
        await tinyboxes.deployed();
        await tinyboxes.setPause(false);
        await tinyboxes.create(1111, 30, 5, [100,50,70], [100,100,100,100], [50,50], 63, addr1.address, 10000, {value:price});
    });

    it("Can render a token preview", async function() {
        const art = await tinyboxesrenderer.tokenPreview(1111, [100,50,70], [30,5], [100,100,100,100], [50,50], 63, [50,10,1], [0,10,7,70], '');
        expect(art).to.be.a('string');
    });

    // it("Can render a tokens art", async function() {
    //     const art = await tinyboxes.tokenArt(0);
    //     expect(art).to.be.a('string');
    // });

    // it("Can render a tokens art with settings + slot", async function() {
    //     const art = await tinyboxes.tokenArt(0, 0, 2, 1, '');
    //     expect(art).to.be.a('string');
    // });

    it("Can lookup a tokens data", async function() {
        const data = await tinyboxes.tokenData(0);
        expect(data.shapes).to.equal(30);
        expect(data.hatching).to.equal(5);
        expect(data.mirroring).to.equal(63);
    });
});


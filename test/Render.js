const { expect } = require("chai");

describe("Testing TinyBoxes", function() {
    let tinyboxes;
    let owner;
    let addr1;
    let addr2;
    let addrs;

     // `beforeEach` will run before each test, re-deploying the contract every
    // time. It receives a callback, which can be async.
    beforeEach(async function () {
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
        // deploy random stub
        const RandomStub = await hre.ethers.getContractFactory("RandomStub");
        const randomstub = await RandomStub.deploy();
        await randomstub.deployed();
        // deploy the main contract
        const TinyBoxes = await hre.ethers.getContractFactory("TinyBoxes");
        tinyboxes = await TinyBoxes.deploy(randomstub.address, tinyboxesrenderer.address);
        await tinyboxes.deployed();
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

    describe("TinyBoxes Rendering", function() {
        it("Method tokenPreview should return a SVG string", async function() {
            const art = await tinyboxes.tokenPreview(1111, [100,50,70], [30,5], [100,100,100,100], [50,50], 63, [50,10,1], [0,10,7,70], '');
            expect(art).to.be.a('string');
        });
    });

    describe("TinyBoxes Minting", function() {
        beforeEach(async function () {
            await tinyboxes.setPause(false);
        });

        it("Can create a TinyBox", async function() {
            await tinyboxes.create(1111, 30, 5, [100,50,70], [100,100,100,100], [50,50], 63, addr1.address, 10000, {value:1});
            expect(await tinyboxes.balanceOf(addr1.address)).to.equal(1);
        });

        it("Can create a TinyBox to another account", async function() {
            await tinyboxes.create(1111, 30, 5, [100,50,70], [100,100,100,100], [50,50], 63, addr2.address, 10000, {value:1});
            expect(await tinyboxes.balanceOf(addr2.address)).to.equal(1);
        });

        it("Token totalSupply is correctly tallied", async function() {
            expect(await tinyboxes.totalSupply()).to.equal(2);
        });
    });
    
    describe("TinyBoxes Limited Editions System Tests", function() {
        beforeEach(async function () {
            await tinyboxes.setPause(false);
        });

        it("Can Mint a Promo token", async function() {
            await tinyboxes.mintPromo(addr1.address);
            expect(await tinyboxes.balanceOf(addr1.address)).to.equal(1);
        });

        // test redeeming the token
        // it("Can Mint a Promo token", async function() {
        //     await tinyboxes.mintPromo(addr1.address);
        //     expect(await tinyboxes.balanceOf(addr1.address)).to.equal(1);
        // });
    });
});


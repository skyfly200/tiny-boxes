const { expect } = require("chai");

describe("Testing TinyBoxes Sale Methods", function() {
    let tinyboxes;
    let owner;
    let addr1;
    let addr2;
    let addrs;
    let price;

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
        // deploy random stub
        const RandomStub = await hre.ethers.getContractFactory("RandomStub");
        const randomstub = await RandomStub.deploy();
        await randomstub.deployed();
        // deploy the main contract
        const TinyBoxes = await hre.ethers.getContractFactory("TinyBoxes");
        tinyboxes = await TinyBoxes.deploy(randomstub.address, tinyboxesrenderer.address);
        await tinyboxes.deployed();
    });

    it("Can lookup the mint price", async function() {
        price = await tinyboxes.price();
        console.log("Price: ", parseInt(price._hex.slice(2), 16), " wei");
        expect(price._isBigNumber);
    });

    it("Create reverts when paused", async function() {
        await expect(
            tinyboxes.create(1111, 30, 5, [100,50,70], [100,100,100,100], [50,50], 63, addr1.address, 10000, {value:price})
        ).to.be.reverted;
    });

    it("Can Unpause", async function() {
        await tinyboxes.setPause(false);
        expect(await tinyboxes.paused()).to.equal(false);
    });

    it("Can create a TinyBox", async function() {
        await expect(
            tinyboxes.create(1111, 30, 5, [100,50,70], [100,100,100,100], [50,50], 63, addr1.address, 10000, {value:price})
        ).to.emit(tinyboxes, 'Transfer');
        expect(await tinyboxes.balanceOf(addr1.address)).to.equal(1);
    });

    it("Can create a TinyBox to another account", async function() {
        await tinyboxes.create(1111, 30, 5, [100,50,70], [100,100,100,100], [50,50], 63, addr2.address, 10000, {value:price});
        expect(await tinyboxes.balanceOf(addr2.address)).to.equal(1);
    });

    it("Token totalSupply is correctly tallied", async function() {
        expect(await tinyboxes.totalSupply()).to.equal(2);
    });

    it("Can lookup token counter", async function() {
        expect(await tinyboxes._tokenIds()).to.equal(2);
    });

    it("Can mint through a phase", async function() {
        for (let i=0; i<8; i++)
            await tinyboxes.create(1111, 30, 5, [100,50,70], [100,100,100,100], [50,50], 63, addr2.address, 10000, {value:price});
        expect(await tinyboxes.currentPhase()).to.equal(1);
    });

    it("Create fails when in countdown", async function() {
        await expect(
            tinyboxes.create(1111, 30, 5, [100,50,70], [100,100,100,100], [50,50], 63, addr2.address, 10000, {value:price})
        ).to.be.reverted;
    });

    it("Can mint through next phase after block timer expires", async function() {
        let current, start;
        do {
            current = await ethers.provider.getBlockNumber();
            start = parseInt((await tinyboxes.blockStart())._hex.slice(2), 16);
            await tinyboxes.setContractURI("test"); // cause test chain blocks to advance
        }
        while (current < start)
        for (let j=0; j<10; j++)
            await tinyboxes.create(1111, 30, 5, [100,50,70], [100,100,100,100], [50,50], 63, addr2.address, 10000, {value:price});
        expect(await tinyboxes.currentPhase()).to.equal(2);
    });

    it("Can mint through all 11 phases", async function() {
        for (let i=3; i<=11; i++) {
            let current, start;
            do {
                start = parseInt((await tinyboxes.blockStart())._hex.slice(2), 16);
                current = await ethers.provider.getBlockNumber();
                if (start - current > 2) await tinyboxes.startCountdown(current + 2); // cause test chain blocks to advance + shorten wait
                else await tinyboxes.setContractURI("test"); // just advance the local networks block
            }
            while (current < start)
            for (let j=0; j<10; j++)
                tinyboxes.create(1111, 30, 5, [100,50,70], [100,100,100,100], [50,50], 63, addr2.address, 10000, {value:price});
            expect(await tinyboxes.currentPhase()).to.equal(i);
        }
    });

    it("Create reverts when sold out", async function() {
        await expect(
            tinyboxes.create(1111, 30, 5, [100,50,70], [100,100,100,100], [50,50], 63, addr2.address, 10000, {value:price})
        ).to.be.reverted;
    });
});


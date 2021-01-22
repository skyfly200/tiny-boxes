const { expect } = require("chai");

describe("Testing TinyBoxes Promo Methods", function() {
    let tinyboxes;
    let owner;
    let addr1;
    let addr2;
    let addrs;
    let promoID = BigInt((2**256)) - 1n;

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

    it("Only admin can mint promo tokens", async function() {
        await expect(tinyboxes.connect(addr2).mintPromo(addr2.address)).to.be.reverted;
    });

    it("Admin can mint promo tokens", async function() {
        await expect(tinyboxes.mintPromo(owner.address)).to.emit(tinyboxes, 'Transfer');
        expect(await tinyboxes.balanceOf(owner.address)).to.equal(1);
    });

    it("Check the new promo token is shown as unredeemed", async function() {
        expect(await tinyboxes.unredeemed(promoID)).to.equal(true);
    });

    it("Can lookup promo token counter", async function() {
        expect(await tinyboxes._tokenPromoIds()).to.equal(1);
    });

    it("Can check a token id is a Limited Edition", async function() {
        expect(await tinyboxes.isTokenLE(promoID)).to.equal(true);
    });

    it("Can check a token id is not a Limited Edition", async function() {
        expect(await tinyboxes.isTokenLE(0)).to.equal(false);
    });

    it("Only a promo tokens owner can redeem", async function() {
        await expect(
            tinyboxes.connect(addr1).createLE(1111, 30, 5, [100,50,70], [100,100,100,100], [50,50], 63, promoID)
        ).to.be.reverted;
    });

    it("Can't redeem when paused", async function() {
        await expect(
            tinyboxes.createLE(1111, 30, 5, [100,50,70], [100,100,100,100], [50,50], 63, BigInt(2**256) - 1n)
        ).to.be.reverted;
    });

    it("Can redeem a promo token", async function() {
        await tinyboxes.setPause(false);
        await expect(
            tinyboxes.createLE(1111, 30, 5, [100,50,70], [100,100,100,100], [50,50], 63, BigInt(2**256) - 1n)
        ).to.emit(tinyboxes, 'LECreated');
    });

    it("Check the token is shown as redeemed", async function() {
        expect(await tinyboxes.unredeemed(promoID)).to.equal(false);
    });

    it("Can't redeem a promo token twice", async function() {
        await expect(
            tinyboxes.createLE(1111, 30, 5, [100,50,70], [100,100,100,100], [50,50], 63, BigInt(2**256) - 1n)
        ).to.be.reverted;
    });

    it("Can't redeem a normal token", async function() {
        await expect(
            tinyboxes.createLE(1111, 30, 5, [100,50,70], [100,100,100,100], [50,50], 63, 0)
        ).to.be.reverted;
    });

    it("Can mint up to promos max", async function() {
        for (let i=0; i<99; i++)
            await expect(tinyboxes.mintPromo(owner.address)).to.emit(tinyboxes, 'Transfer');
    });

    it("Can't mint past promos max", async function() {
        await expect(tinyboxes.mintPromo(owner.address)).to.be.reverted;
    });
});


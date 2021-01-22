const { expect } = require("chai");

describe("Testing TinyBoxes", function() {
    let tinyboxes;
    let owner;
    let addr1;
    let addr2;
    let addrs;

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
        await tinyboxes.setPause(false);
    });

    it("Admin can mint promo tokens", async function() {
        await tinyboxes.mintPromo(addr1.address);
        expect(await tinyboxes.balanceOf(addr1.address)).to.equal(1);
    });

    it("Can lookup promo token counter", async function() {
        expect(await tinyboxes._tokenPromoIds()).to.equal(1);
    });

    it("normal users can't mint promo tokens", async function() {
        await tinyboxes.connect(addr2).mintPromo(addr2.address);
        expect(await tinyboxes.balanceOf(addr2.address)).to.equal(0);
    });

    // test redeeming the token
    // it("Can Mint a Promo token", async function() {
    //     await tinyboxes.mintPromo(addr1.address);
    //     expect(await tinyboxes.balanceOf(addr1.address)).to.equal(1);
    // });

    // only owner can redeem

    // cant redeem twice

    // cant redeem a normal token
});


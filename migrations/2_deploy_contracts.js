var TinyBoxes = artifacts.require('TinyBoxes')

module.exports = function (deployer) {
  // deployment steps
  deployer.deploy(TinyBoxes)
}

var CertVerify = artifacts.require("./CertVerify.sol");

module.exports = function(deployer) {
  deployer.deploy(CertVerify);
};

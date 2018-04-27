const CodexTitle = artifacts.require('./CodexTitle.sol');
const TokenProxy = artifacts.require('./TokenProxy.sol');

module.exports = async function (deployer, network) {
  deployer.then(async function () {
    let tokenURIPrefix;

    switch (network) {
    case 'ganache':
      tokenURIPrefix = 'http://localhost:3001/token';
      break;

    default:
      throw new Error('No tokenURIPrefix defined for this network');
    }

    const tokenProxy = await TokenProxy.deployed();
    const codexTitle = CodexTitle.at(tokenProxy.address);

    console.log('Setting the tokenURIPrefix to:', tokenURIPrefix);

    codexTitle.setTokenURIPrefix(tokenURIPrefix);
  }).catch((error) => {
    console.log(error);
  });
};

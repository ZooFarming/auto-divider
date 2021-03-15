const AutoDividerDelegate = artifacts.require('AutoDividerDelegate');
const ZooKeeperProxy = artifacts.require('ZooKeeperProxy');

module.exports = async function (deployer) {
  let proxyAdmin = '0x5560af0f46d00fcea88627a9df7a4798b1b10961';
  let admin = '0x4cf0a877e906dead748a41ae7da8c220e4247d9e';

  await deployer.deploy(AutoDividerDelegate);

  let autoDividerDelegate = await AutoDividerDelegate.deployed();

  await deployer.deploy(ZooKeeperProxy, autoDividerDelegate.address, proxyAdmin, '0x');

  let autodivider = await AutoDividerDelegate.at((await ZooKeeperProxy.deployed()).address);

  await autodivider.initialize(admin);

  console.log('autodivider', autodivider.address);
};

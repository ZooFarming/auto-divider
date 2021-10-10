const AutoDividerDelegate = artifacts.require('AutoDividerDelegate');
const ZooManagerDelegate = artifacts.require('ZooManagerDelegate');
const ZooKeeperProxy = artifacts.require('ZooKeeperProxy');

module.exports = async function (deployer) {
  let proxyAdmin = '0x60ff3a6420418Be41A1942b75a9C2486bb45E2AF';
  let admin = '0xb87A39c5D3f5C53395Ba11b5058655A4A8AC82a5';

  await deployer.deploy(AutoDividerDelegate);

  let autoDividerDelegate = await AutoDividerDelegate.deployed();
  await deployer.deploy(ZooKeeperProxy, autoDividerDelegate.address, proxyAdmin, '0x');
  let autodivider = await AutoDividerDelegate.at((await ZooKeeperProxy.deployed()).address);
  await autodivider.initialize(admin);

  await deployer.deploy(ZooManagerDelegate);
  let zooManagerDelegate1 = await ZooManagerDelegate.deployed();
  await deployer.deploy(ZooKeeperProxy, zooManagerDelegate1.address, proxyAdmin, '0x');
  let zooManager1 = await ZooManagerDelegate.at((await ZooKeeperProxy.deployed()).address);
  await zooManager1.initialize(admin);

  await deployer.deploy(ZooManagerDelegate);
  let zooManagerDelegate2 = await ZooManagerDelegate.deployed();
  await deployer.deploy(ZooKeeperProxy, zooManagerDelegate2.address, proxyAdmin, '0x');
  let zooManager2 = await ZooManagerDelegate.at((await ZooKeeperProxy.deployed()).address);
  await zooManager2.initialize(admin);

  await deployer.deploy(ZooManagerDelegate);
  let zooManagerDelegate3 = await ZooManagerDelegate.deployed();
  await deployer.deploy(ZooKeeperProxy, zooManagerDelegate3.address, proxyAdmin, '0x');
  let zooManager3 = await ZooManagerDelegate.at((await ZooKeeperProxy.deployed()).address);
  await zooManager3.initialize(admin);

  console.log('autodivider', autodivider.address);
  console.log('zooManager1', zooManager1.address);
  console.log('zooManager2', zooManager2.address);
  console.log('zooManager3', zooManager3.address);
};

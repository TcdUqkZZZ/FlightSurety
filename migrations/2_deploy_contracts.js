const FlightSuretyApp = artifacts.require("FlightSuretyApp");
const FlightSuretyData = artifacts.require("FlightSuretyData");
const FlightSuretyGovernance = artifacts.require("FlightSuretyGovernance");
const FlightSuretyWalletFactory = artifacts.require("FlightSuretyWalletFactory");
const fs = require('fs');

module.exports = async function(deployer) {

    await deployer.deploy(FlightSuretyApp)

    let firstAirline = '0xD9F53988199c82B29B67e4172302B455a8C4B834';
    let walletFactory = await deployer.deploy(FlightSuretyWalletFactory);
    await deployer.deploy(FlightSuretyData);
     await deployer.deploy(FlightSuretyGovernance);
    let dataContract = await FlightSuretyData.deployed();
    await dataContract.authorizeCaller(FlightSuretyApp.address);
    await walletFactory.authorizeCaller(FlightSuretyApp.address);
    let appContract = await FlightSuretyApp.deployed();
    await appContract.init(FlightSuretyData.address, FlightSuretyGovernance.address, walletFactory.address, firstAirline);

                    let config = {
                        localhost: {
                            url: 'http://localhost:7545',
                            dataAddress: FlightSuretyData.address,
                            appAddress: FlightSuretyApp.address
                        }
                    }

                    fs.writeFileSync(__dirname + '/../src/dapp/config.json',JSON.stringify(config, null, '\t'), 'utf-8');
                    fs.writeFileSync(__dirname + '/../src/server/config.json',JSON.stringify(config, null, '\t'), 'utf-8');

                }
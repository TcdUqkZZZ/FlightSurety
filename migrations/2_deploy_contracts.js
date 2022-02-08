const FlightSuretyApp = artifacts.require("FlightSuretyApp");
const FlightSuretyData = artifacts.require("FlightSuretyData");
const FlightSuretyGovernance = artifacts.require("FlightSuretyGovernance");
const FlightSuretyAirlineWallet = artifacts.require("FlightSuretyAirlineWallet");
const fs = require('fs');

module.exports = async function(deployer) {

    let firstAirline = '0xD9F53988199c82B29B67e4172302B455a8C4B834';
    let firstWallet = await deployer.deploy(FlightSuretyAirlineWallet, firstAirline);
    let dataContract = await deployer.deploy(FlightSuretyData, firstAirline, FlightSuretyAirlineWallet.address);
    let governanceContract = await deployer.deploy(FlightSuretyGovernance);
    await deployer.deploy(FlightSuretyApp, dataContract.address, governanceContract.address);

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
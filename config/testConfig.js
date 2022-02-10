
var FlightSuretyApp = artifacts.require("FlightSuretyApp");
var FlightSuretyData = artifacts.require("FlightSuretyData");
var FlightSuretyGovernance = artifacts.require("FlightSuretyGovernance");
var FlightSuretyWalletFactory = artifacts.require("FlightSuretyWalletFactory");
var BigNumber = require('bignumber.js');

var Config = async function(accounts) {
    
    // These test addresses are useful when you need to add
    // multiple users in test scripts
    let testAddresses = [
        "0xe1338ce5ac4fe0a7ce5ca422542ccbd811a267d0",
        "0x4d578b45d3d7899704186e537b01bf9d4cf772f7",
        "0x1abf10b40736f01702af96e756d2193a38a7368e",
        "0x6302037d1cdf13c0044b188afe2d72c55958d2f3",
        "0x283b5c9f196786c5a0903ba37169efe310fe588e",
        "0x95b1fc20169b16fab17b42881e90789b98c653d9",
        "0x8c4a3bf5f0a0ba53292b2e26645d46448ac5db87",
        "0xdd19b15e5f0d4b78da563ef2220e4c626a9a4450",
        "0x3c5615f005abff4698d0df8f671f1ddedaef000e"
    ];


    let owner = accounts[0];
    let firstAirline = accounts[1];
    let walletFactory = await FlightSuretyWalletFactory.new();
    let flightSuretyData = await FlightSuretyData.new();
    let flightSuretyGovernance = await FlightSuretyGovernance.new();
    let flightSuretyApp = await FlightSuretyApp.new();



    
    return {
        owner: owner,
        firstAirline: firstAirline,
        weiMultiple: (new BigNumber(10)).pow(18),
        testAddresses: testAddresses,
        flightSuretyData: flightSuretyData,
        flightSuretyApp: flightSuretyApp,
        flightSuretyGovernance : flightSuretyGovernance,
        walletFactory : walletFactory
    }
}

module.exports = {
    Config: Config
};
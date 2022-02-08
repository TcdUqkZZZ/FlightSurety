
var FlightSuretyApp = artifacts.require("FlightSuretyApp");
var FlightSuretyData = artifacts.require("FlightSuretyData");
var FlightSuretyGovernance = artifacts.require("FlightSuretyGovernance");
var FlightSuretyAirlineWallet = artifacts.require("FlightSuretyAirlineWallet");
var BigNumber = require('bignumber.js');

var Config = async function(accounts) {
    
    // These test addresses are useful when you need to add
    // multiple users in test scripts
    let testAddresses = [
        "0x32eD122e8d39363eE81f9546c74D9b3B7417e077",
        "0xD9F53988199c82B29B67e4172302B455a8C4B834",
        "0xA297A54bb0510dcb0B973bAdB98A2417819A233e",
        "0xCffe2A1BBD83cb9D883247F0A84121D3088cE017",
        "0xD229dDD948ba40620D22CeAD679a96F6bcd45b6F",
        "0x293BC7b20217d806664Ac6cBfa9Cc24b03104Fb2",
        "0x575529611bCFdE3311179248197911Aa5e9f68a6",
        "0xb4260A21B18B78F6F17E7c505d77c852Ba04361C",
        "0x66B992e89D94ffA51e90811bd27543e22dF4638a"
    ];


    let owner = accounts[0];
    let firstAirline = accounts[1];
    let firstWallet = await FlightSuretyAirlineWallet.new(firstAirline);
    let flightSuretyData = await FlightSuretyData.new(firstAirline, FlightSuretyAirlineWallet.address);
    let flightSuretyGovernance = await FlightSuretyGovernance.new();
    let flightSuretyApp = await FlightSuretyApp.new(flightSuretyData.address, flightSuretyGovernance.address);


    
    return {
        owner: owner,
        firstAirline: firstAirline,
        weiMultiple: (new BigNumber(10)).pow(18),
        testAddresses: testAddresses,
        flightSuretyData: flightSuretyData,
        flightSuretyApp: flightSuretyApp,
        flightSuretyGovernance : flightSuretyGovernance
    }
}

module.exports = {
    Config: Config
};
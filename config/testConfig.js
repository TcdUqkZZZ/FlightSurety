
var FlightSuretyApp = artifacts.require("FlightSuretyApp");
var FlightSuretyData = artifacts.require("FlightSuretyData");
var FlightSuretyGovernance = artifacts.require("FlightSuretyGovernance");
var FlightSuretyAirlineWallet = artifacts.require("FlightSuretyAirlineWallet");
var BigNumber = require('bignumber.js');

var Config = async function(accounts) {
    
    // These test addresses are useful when you need to add
    // multiple users in test scripts
    let testAddresses = [
        "0x48A855CFEc3372F398C7618d37dc2563C280BE44",
        "0x96f63275648fB5646B623dD80A32eA7EaB0cf795",
        "0xD7F91C285784C75485596990dda5800b882142c5",
        "0x68F18c5d1EfDEC4e850BF97434Ed9683Ad5cB522",
        "0x9B7b53b4688C7dA232B9963DAb20854B55FA762d",
        "0x6cBFd36C22d56E61FA579E75b12B2C2f9684b1D3",
        "0x67e120e73D07f3997c3dDaeC67CdbCFDeb56f469",
        "0xBD8AF5FeD49435F78D9fc0F0b9d55A12565107d2",
        "0x303e1bF1d9E6ac5Ec1dCf0d67a3D42b897EDE7DB"
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
import FlightSuretyApp from '../../build/contracts/FlightSuretyApp.json';
import Config from './config.json';
import Web3 from 'web3';
import express from 'express';

const ORACLE_COUNT = 20

let oracles = [];
let indexes = new Map();


const STATUS_CODE_UNKNOWN = 0;
const STATUS_CODE_ON_TIME = 10;
const STATUS_CODE_LATE_AIRLINE = 20;
const STATUS_CODE_LATE_WEATHER = 30;
const STATUS_CODE_LATE_TECHNICAL = 40;
const STATUS_CODE_LATE_OTHER = 50;


let config = Config['localhost'];
let web3 = new Web3(new Web3.providers.WebsocketProvider(config.url.replace('http', 'ws')));
web3.eth.defaultAccount = web3.eth.accounts[0];
let flightSuretyApp = new web3.eth.Contract(FlightSuretyApp.abi, config.appAddress);


flightSuretyApp.events.OracleRequest({
    fromBlock: 0
  }, function (error, event) {
    if (error) console.log(error)
    console.log(event)
});

const app = express();
app.get('/api', (req, res) => {
    res.send({
      message: 'An API for use with your Dapp!'
    })
})

const getOracles = async () => {
  let accs = await web3.eth.getAccounts();

  let oracleAccs = accs.slice(7, 7+ORACLE_COUNT);

  return oracleAccs;

}

const startOracles = async(oracles) => {

  let registrationFee = await flightSuretyApp.methods.REGISTRATION_FEE.call().call();
  
  for (const oracle of oracles) {
    await flightSuretyApp.methods.registerOracle.send({
      "from": oracle,
      "value": registrationFee
    })

    let thisIndexes = flightSuretyApp.getMyIndexes({from: oracle});
    indexes.set(oracle, thisIndexes);

  }
  

}

const submitOracleResponses = async(flight, airline, statusCode, oracles) => {
  for(const oracle of oracles) {
    await flightSuretyApp.methods.submitOracleResponse.call(
      indexes.get(oracle)[0],
      airline,
      flight,
      Date.now(),
      statusCode
    )
  }
}



  startOracles(getOracles).then(
 web3.eth.subscribe('OracleRequest', {
   address: config.appAddress
 }, async(res, err) => {
   if (!err){
   airline = res.airline
   flight = res.flight
   statusCode = () => {
     statusCodes = [
      STATUS_CODE_UNKNOWN,
      STATUS_CODE_ON_TIME,
      STATUS_CODE_LATE_AIRLINE,
      STATUS_CODE_LATE_OTHER,
      STATUS_CODE_LATE_TECHNICAL,
      STATUS_CODE_LATE_WEATHER
     ]
     return statusCodes[Math.floor(Math.random() * statusCodes.length)];
   }

   await submitOracleResponses(flight, airline, statusCode(), oracles.length);
 }
 else console.error(error);
}))



export default app;



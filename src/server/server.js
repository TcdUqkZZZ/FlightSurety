import FlightSuretyApp from '../../build/contracts/FlightSuretyApp.json';
import Config from './config.json';
import Web3 from 'web3';
import express from 'express';
import 'regenerator-runtime/runtime';


const ORACLE_COUNT = 20

let oracles = [];
let indexes = new Map();

const STATUS_CODE_UNKNOWN = 0
const STATUS_CODE_ON_TIME = 10
const STATUS_CODE_LATE_AIRLINE = 20
const STATUS_CODE_LATE_OTHER = 30
const STATUS_CODE_LATE_TECHNICAL = 40
const STATUS_CODE_LATE_WEATHER = 50

const statusCodes = [
  STATUS_CODE_UNKNOWN,
  STATUS_CODE_ON_TIME ,
  STATUS_CODE_LATE_AIRLINE ,
  STATUS_CODE_LATE_OTHER ,
  STATUS_CODE_LATE_TECHNICAL ,
  STATUS_CODE_LATE_WEATHER
 ]



let config = Config['localhost'];
let web3 = new Web3(new Web3.providers.WebsocketProvider(config.url.replace('http', 'ws').replace('localhost', '127.0.0.1')));
web3.eth.defaultAccount = web3.eth.accounts[0];
let flightSuretyApp = new web3.eth.Contract(FlightSuretyApp.abi, config.appAddress);



const app = express();
app.get('/api', (req, res) => {
    res.send({
      message: 'An API for use with your Dapp!'
    })
})

async function getOracles() {
  let accs = await web3.eth.getAccounts();
  console.log(accs)
  let oracleAccs = accs.slice(7, 7+ORACLE_COUNT);
  console.log(oracleAccs)
  console.log('oracle array acquired');
  oracles = oracleAccs
  return oracleAccs


}

async function startOracles(oracles){

  let registrationFee = web3.utils.toWei('1');
  for(const oracle of oracles) {
     await 
      flightSuretyApp.methods.registerOracle().send({
      from: oracle,
      value: registrationFee,
      gas: 6721975,
      price: 20000000000
    })

    flightSuretyApp.once('OracleRegistered', (err, event) => {
      console.log(`oracle ${event.returnValues.oracle} registered`)
    })

    // `oracle ${oracle} registered`    
} 
}


 async function getIndices() {
  for (const oracle of oracles) {
    try {
      let thisIndices = await flightSuretyApp.methods.getMyIndexes().call({from: oracle});
      indexes.set(oracle, thisIndices);
      console.log(`set indices ${thisIndices} for oracle ${oracle}`)
    }
    catch (error) {
      console.log(error)
    }
  }

}

async function submitOracleResponses(flight, airline, statusCode, oracles, index){
  for (const oracle of oracles) {
    if (indexes.get(oracle).includes(index))
    try{
    await flightSuretyApp.methods.submitOracleResponse.send(
      // get random index
      indexes.get(oracle)[Math.floor(Math.random()*3)],
      airline,
      flight,
      Date.now(),
      statusCode,
      {
      from: oracle,
      gas: 6721975,
      price: 20000000000
      }
    )


    }
    catch(error) {
      console.log(error)
    }
  }
}


getOracles()
.then(async oracles => { await
     startOracles(oracles)
})
.then( async() =>{ await
  getIndices()
}
)
.then( () => { flightSuretyApp.events.OracleRequest(
  async (event) => {
    airline = event.airline
    flight = event.flight
    index = event.index
    // return random status code
    let statusCode = statusCodes[Math.floor(Math.random() * statusCodes.length)];   
  
    await submitOracleResponses(flight, airline, statusCode, oracles, index).call();
  })
})
.catch(error => {
  return console.error(error);
})


console.log('belandi ragassi')


 





export default app;



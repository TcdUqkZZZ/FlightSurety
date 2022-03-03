
import DOM from './dom';
import Contract from './contract';
import './flightsurety.css';


(async() => {

    let result = null;

    let contract = new Contract('localhost', () => {

        // Read transaction
        contract.isOperational((error, result) => {
            console.log(error,result);
            display('Operational Status', 'Check if contract is operational', [ { label: 'Operational Status', error: error, value: result} ]);
        });

        DOM.elid('register-flight').addEventListener('click', () => {
            let  flightNo = Dom.elid('flight-number').value;
            contract.registerFlight(flightNo);
        })
    

        // User-submitted transaction
        DOM.elid('submit-oracle').addEventListener('click', () => {
            let flight = DOM.elid('flight-number').value;
            // Write transaction
            contract.fetchFlightStatus(flight, (error, result) => {
                display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp} ]);
            });
        });

        DOM.elid('buy-insurance').addEventListener('click', () => {
            let flight = DOM.elid('flight-number').value;
            let amount = DOM.elid('amount').value;

            contract.buy(flight, amount, (err,res) => {
                display('Insurance', 'Bought', [{label: `Insured flight ${flight} for ${amount}`}]);
            });
        });

        /*
        DOM.elid('get-payout').addEventListener('click', () => {
            let flight = DOM.elid('flight-number').value;
            let payout = contract.payout(flight) 
                if (payout) {
                    
                    display('Payout', 'awarded', [{label = `Cashed ${payout} in insurance payour for flight ${flight}`}])
                }
            } )
         
*/
      
    });
    

});


function display(title, description, results) {
    let displayDiv = DOM.elid("display-wrapper");
    let section = DOM.section();
    section.appendChild(DOM.h2(title));
    section.appendChild(DOM.h5(description));
    results.map((result) => {
        let row = section.appendChild(DOM.div({className:'row'}));
        row.appendChild(DOM.div({className: 'col-sm-4 field'}, result.label));
        row.appendChild(DOM.div({className: 'col-sm-8 field-value'}, result.error ? String(result.error) : String(result.value)));
        section.appendChild(row);
    })
    displayDiv.append(section);

    function showFlight(flight, airlineName) {
        var showCase = DOM.elid('flight-showcase');
        let section = DOM.section();
        section.appendChild(DOM.h2(flight));
        section.appendChild(DOM.h4(airlineName));
    }

}


window.addEventListener("load", async function() {
    if (window.ethereum) {
      // use MetaMask's provider
      console.log('ethereum ok')
      App.web3 = new Web3(window.ethereum);
      await window.ethereum.enable(); // get permission to access accounts
    }
  }
  );








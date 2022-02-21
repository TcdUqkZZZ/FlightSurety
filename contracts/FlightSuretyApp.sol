pragma solidity >0.8.0;
import "./FlightSuretyData.sol";
import "./FlightSuretyGovernance.sol";
import "./FlightSuretyWallet.sol";
//solidity >0.8.x integrates safe math

/************************************************** */
/* FlightSurety Smart Contract                      */
/************************************************** */
contract FlightSuretyApp {
     // Allow SafeMath functions to be called for all uint256 types (similar to "prototype" in Javascript)

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    FlightSuretyData private dataContract;
    FlightSuretyGovernance private governanceContract;
    FlightSuretyWalletFactory private walletFactory;
    // Flight status codees
    uint8 private constant STATUS_CODE_UNKNOWN = 0;
    uint8 private constant STATUS_CODE_ON_TIME = 10;
    uint8 private constant STATUS_CODE_LATE_AIRLINE = 20;
    uint8 private constant STATUS_CODE_LATE_WEATHER = 30;
    uint8 private constant STATUS_CODE_LATE_TECHNICAL = 40;
    uint8 private constant STATUS_CODE_LATE_OTHER = 50;
    bool  private initialized = false;

    // Fees
    uint private constant USER_REGISTRATION_FEE = 2 gwei;
    uint private constant INSURANCE_FEE = 1 gwei;
    address private contractOwner;          // Account used to deploy contract

    struct Flight {
        bool isRegistered;
        uint8 statusCode;
        uint256 updatedTimestamp;        
        address airline;
    }
    mapping(bytes32 => Flight) private flights;


    event log();
    event changedDataContract( address newAddress);
    event changedGovernanceContract( address newAddress);
    event changedWalletContract( address newAddress);
    event insuranceBought(address user, uint amount, bytes32 flightKey, address airline);
 
    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in 
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational() 
    {
         // Modify to call data contract's status
        require(true, "Contract is currently not operational");  
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    /********************************************************************************************/
    /*                                       CONSTRUCTOR                                        */
    /********************************************************************************************/

    /**
    * @dev Contract constructor
    *
    */
    constructor
                                (
                                ) 
                                 
    {
        contractOwner = msg.sender;
      
    }

    function init(address _dataContract,
                    address _governanceContract,
                    address _walletFactory,
                    address firstAirlineAddress
                                )  public requireContractOwner

    {require(!initialized);
        setDataContract(_dataContract);
        setGovernanceContract(_governanceContract);
        setWalletFactory(_walletFactory);
        initialized = true;
        dataContract.init(firstAirlineAddress,
         walletFactory.createAirlineWallet(firstAirlineAddress));
        }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    function isOperational() 
                            public 
                            view 
                            returns(bool) 
    {
        return dataContract.isOperational();  // Modify to call data contract's status
    }

    function setOperatingStatus(bool mode) public returns(bool,uint){
        require (dataContract.isRegisteredAirline(msg.sender) 
        || contractOwner == msg.sender, "Unauthorized");
        governanceContract.voteChangeOperationalState(msg.sender);

        (bool result, uint256 votes)  = governanceContract
        .getResult(dataContract
        .getCounter());

        if (result) {
            dataContract.setOperatingStatus(mode);
        }
        return (result, votes);

    }

    function setDataContract(address _dataContract) public requireContractOwner{

        dataContract = FlightSuretyData(payable(_dataContract));
        emit changedDataContract(_dataContract);
    }

    function setGovernanceContract(address _governanceContract) public requireContractOwner{
        governanceContract = FlightSuretyGovernance(_governanceContract);
        emit changedGovernanceContract(_governanceContract);
    }

    function setWalletFactory(address _walletFactory) public requireContractOwner {
        walletFactory = FlightSuretyWalletFactory(_walletFactory);
        emit changedWalletContract(_walletFactory);
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

  
   /**
    * @dev Add an airline to the registration queue
    *
    */   
    function registerAirline
                            (  address airline 
                            )
                            external
                            returns(bool success, uint256 _votes)
    {   require((!dataContract.isRegisteredAirline(airline) 
    && dataContract.isRegisteredAirline(msg.sender) 
    && dataContract.getAirlineWallet(msg.sender).getBalance() >= 10 ether)
    || msg.sender == contractOwner );
        emit log();
        //casts vote on governance contract, then checks result
        governanceContract.vote(airline, msg.sender);
        (bool result, uint256 votes)  = governanceContract
        .getResult(dataContract
        .getCounter());
        if (result){
            //if vote passed, register new airline with corresponding wallet in data contract
            airlineWallet wallet = walletFactory.createAirlineWallet(msg.sender);        
            dataContract.addAirline(airline, wallet);
        }
        return (result, votes);
    }
 

   /**
    * @dev Register a future flight for insuring.
    *
    */  
    function registerFlight
                                (string memory _flight
                                )
                                external
                                returns(bytes32)
                                
    {
        //check that msg.sender is registered airline with more than 10 funds deposited
        myWallet wallet = dataContract.getAirlineWallet(msg.sender);
        require(dataContract.isRegisteredAirline(msg.sender) &&
                wallet.getBalance() >= 10); 
        bytes32 key = getFlightKey(msg.sender, _flight , block.timestamp);
        Flight memory flight = flights[key];
        flight.isRegistered = true;
        flight.statusCode = STATUS_CODE_UNKNOWN;
        flight.updatedTimestamp = block.timestamp;
        flight.airline = msg.sender;
        flights[key] = flight;
        return key;
    }

    function _getFlightKey(uint256 flightNo) private pure returns(bytes32){
        return keccak256(abi.encode(flightNo));
    }
    
   /**
    * @dev Called after oracle has updated flight status
    *
    */  
    function processFlightStatus
                                (
                                    address airline,
                                    string memory _flight,
                                    uint256 timestamp,
                                    uint8 statusCode
                                )
                                internal
                                
    {
        bytes32 key = getFlightKey(airline, _flight, timestamp);
        Flight storage flight = flights[key];
        require(flight.isRegistered);

        flight.statusCode = statusCode;
        flight.updatedTimestamp = timestamp;
        flights[key] = flight;

    }

    /**
    * @dev Register new user 
    */
    function registerUser() external payable{
        require(!dataContract.isRegisteredUser(msg.sender), "user already registered");
        require(msg.value > USER_REGISTRATION_FEE);
        userWallet wallet = walletFactory.createUserWallet(msg.sender);
        wallet.deposit(msg.value - USER_REGISTRATION_FEE);
        dataContract.addUser(msg.sender, wallet);
        _fundDataContract(msg.value - USER_REGISTRATION_FEE);
    }


       /**
    * @dev Buy insurance for a flight
    *
    */   
    function buy
                            (bytes32 flightKey)
                            external
                            payable
    {
            require(dataContract.isRegisteredUser(msg.sender), "user not registered");
            require((1 ether >= msg.value) && (msg.value > INSURANCE_FEE));

            userWallet wallet = dataContract.getUserWallet(msg.sender);
            wallet.deposit(msg.value - INSURANCE_FEE);
            wallet.insure(msg.value - INSURANCE_FEE, flightKey);
            Flight memory flight = flights[flightKey];
            address airline = flight.airline;
            dataContract
            .getAirlineWallet(airline)
            .addInsuree(msg.sender, flightKey);

            _fundDataContract(msg.value - INSURANCE_FEE);
            emit insuranceBought(msg.sender, msg.value, flightKey, airline);
    }

    /**
    *  @dev Credits payouts to insurees
    */
    function creditInsurees
                                (bytes32 flightKey
                                )
                                external        
    { 
        Flight memory flight = flights[flightKey];
        require(flight.statusCode == STATUS_CODE_LATE_AIRLINE);
        address airline = flight.airline;
        airlineWallet Awallet = dataContract.getAirlineWallet(airline);        
        address[] memory insurees = Awallet.getInsurees(flightKey);
        uint256 paidOut = 0;
        for(uint i=0; i< insurees.length; i++){
            userWallet Uwallet = dataContract.getUserWallet(insurees[i]);

            uint256 amount  = Uwallet.getInsuredFlight(flightKey) / 2 * 3;
            
            Uwallet.deposit(amount);
            paidOut += amount;
            Uwallet.clear(flightKey);

        }
        Awallet.withdraw(paidOut);
        Awallet.clear(flightKey);
    }

    function payOut() external {
        dataContract.pay(msg.sender);
    }
    

    function _fundDataContract(uint256 amount) private{
                address dataAddress = address(dataContract);
        payable(dataAddress).transfer(amount);

    }


    // Generate a request for oracles to fetch flight information
    function fetchFlightStatus
                        (
                            address airline,
                            string memory flight,
                            uint256 timestamp                            
                        )
                        external
    {
        uint8 index = getRandomIndex(msg.sender);

        // Generate a unique key for storing the request
        bytes32 key = keccak256(abi.encodePacked(index, airline, flight, timestamp));
        oracleResponses[key].requester = msg.sender;
        oracleResponses[key].isOpen = true;
        emit OracleRequest(index, airline, flight, timestamp);
    } 


// region ORACLE MANAGEMENT

    // Incremented to add pseudo-randomness at various points
    uint8 private nonce = 0;    

    // Fee to be paid when registering oracle
    uint256 public constant REGISTRATION_FEE = 1 ether;

    // Number of oracles that must respond for valid status
    uint256 private constant MIN_RESPONSES = 3;


    struct Oracle {
        bool isRegistered;
        uint8[3] indexes;        
    }

    // Track all registered oracles
    mapping(address => Oracle) private oracles;

    // Model for responses from oracles
    struct ResponseInfo {
        address requester;                              // Account that requested status
        bool isOpen;                                    // If open, oracle responses are accepted
        mapping(uint8 => address[]) responses;          // Mapping key is the status code reported
                                                        // This lets us group responses and identify
                                                        // the response that majority of the oracles
    }

    // Track all oracle responses
    // Key = hash(index, flight, timestamp)
    mapping(bytes32 => ResponseInfo) private oracleResponses;

    // Event fired each time an oracle submits a response
    event FlightStatusInfo(address airline, string flight, uint256 timestamp, uint8 status);

    event OracleReport(address airline, string flight, uint256 timestamp, uint8 status);
    event OracleRegistered(address oracle);
    // Event fired when flight status request is submitted
    // Oracles track this and if they have a matching index
    // they fetch data and submit a response
    event OracleRequest(uint8 index, address airline, string flight, uint256 timestamp);


    // Register an oracle with the contract
    function registerOracle
                            (
                            )
                            external
                            payable
    {
        // Require registration fee
        require(msg.value >= REGISTRATION_FEE, "Registration fee is required");

        uint8[3] memory indexes = generateIndexes(msg.sender);
        Oracle storage thisOracle = oracles[msg.sender];

        thisOracle.isRegistered = true;
        thisOracle.indexes = indexes;

        oracles[msg.sender] = thisOracle;
        
        emit OracleRegistered(msg.sender);


    }

    function getMyIndexes
                            (
                            )
                            view
                            external
                            returns(uint8[3] memory)
    {
        require(oracles[msg.sender].isRegistered, "Not registered as an oracle");

        return oracles[msg.sender].indexes;
    }




    // Called by oracle when a response is available to an outstanding request
    // For the response to be accepted, there must be a pending request that is open
    // and matches one of the three Indexes randomly assigned to the oracle at the
    // time of registration (i.e. uninvited oracles are not welcome)
    function submitOracleResponse
                        (
                            uint8 index,
                            address airline,
                            string memory flight,
                            uint256 timestamp,
                            uint8 statusCode
                        )
                        external
    {
        require((oracles[msg.sender].indexes[0] == index) 
        || (oracles[msg.sender].indexes[1] == index) 
        || (oracles[msg.sender].indexes[2] == index), "Index does not match oracle request");


        bytes32 key = keccak256(abi.encodePacked(index, airline, flight, timestamp)); 
        require(oracleResponses[key].isOpen, "Flight or timestamp do not match oracle request");

        oracleResponses[key].responses[statusCode].push(msg.sender);

        // Information isn't considered verified until at least MIN_RESPONSES
        // oracles respond with the *** same *** information
        emit OracleReport(airline, flight, timestamp, statusCode);
        if (oracleResponses[key].responses[statusCode].length >= MIN_RESPONSES) {

            emit FlightStatusInfo(airline, flight, timestamp, statusCode);

            // Handle flight status as appropriate
            processFlightStatus(airline, flight, timestamp, statusCode);
        }
    }


    function getFlightKey
                        (
                            address airline,
                            string memory flight,
                            uint256 timestamp
                        )
                        pure
                        internal
                        returns(bytes32) 
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    // Returns array of three non-duplicating integers from 0-9
    function generateIndexes
                            (                       
                                address account         
                            )
                            internal
                            returns(uint8[3] memory)
    {
        uint8[3] memory indexes;
        indexes[0] = getRandomIndex(account);
        
        indexes[1] = indexes[0];
        while(indexes[1] == indexes[0]) {
            indexes[1] = getRandomIndex(account);
        }

        indexes[2] = indexes[1];
        while((indexes[2] == indexes[0]) || (indexes[2] == indexes[1])) {
            indexes[2] = getRandomIndex(account);
        }

        return indexes;
    }

    // Returns array of three non-duplicating integers from 0-9
    function getRandomIndex
                            (
                                address account
                            )
                            internal
                            returns (uint8)
    {
        uint8 maxValue = 10;

        // Pseudo random number...the incrementing nonce adds variation
        uint8 random = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - nonce++), account))) % maxValue);

        if (nonce > 250) {
            nonce = 0;  // Can only fetch blockhashes for last 256 blocks so we adapt
        }

        return random;
    }

// endregion

}   

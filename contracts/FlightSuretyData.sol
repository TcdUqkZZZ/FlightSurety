pragma solidity >= 0.8.0;

interface myWallet {
    function deposit(uint256) external;
    function getBalance() external view returns(uint256);
    function clear(bytes32) external;
}
interface userWallet is myWallet{
    function insure(uint256,bytes32) external;
    function getInsuredFlight(bytes32) external view returns (uint256);
}
interface airlineWallet is myWallet {
    function addInsuree(address,bytes32) external;
    function getInsurees(bytes32) external view returns (address[] memory);
    function withdraw(uint256) external;
}



contract FlightSuretyData {
    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner = address(0);                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false
    uint256 airlineCounter;
    mapping (address => bool) registeredAirlines;
    mapping (address => bool) registeredUsers;
    mapping (address => airlineWallet) airlineWallets;
    mapping (address => userWallet) userWallets;
    bool initialized = false;
    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/


    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor
                                (
                                ) 
                                 
    {
        contractOwner = msg.sender;

    }

    function init(address firstAirline, airlineWallet firstAirlineWallet) external requireContractOwner {
        require(!initialized);
        addAirline(firstAirline, firstAirlineWallet);
        initialized = true;
    }




    function getCounter() public view returns (uint256) {
        return airlineCounter;
    }
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
        require(operational, "Contract is currently not operational");
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
    
    modifier requireRegisteredUser(address user) {
        require(registeredUsers[user] == true, "not a registered user");
        _;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */      
    function isOperational() 
                            public 
                            view 
                            returns(bool) 
    {
        return operational;
    }

    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */    
    function setOperatingStatus
                            (
                                bool mode
                            ) 
                            external
                            requireContractOwner 
    {
        operational = mode;
    }

    function isRegisteredAirline(address a) external view returns (bool) {
        return registeredAirlines[a];
    }
    function getAirlineWallet(address a) external view returns (airlineWallet){
        return airlineWallets[a];
    }

    function isRegisteredUser(address a) external view returns(bool) {
        return registeredUsers[a];
    }
    function getUserWallet(address a) external view returns (userWallet) {
        return userWallets[a];
    }




    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/


    function addAirline(address airline, airlineWallet wallet) public requireContractOwner 
    requireIsOperational{
        registeredAirlines[airline] = true;
        airlineWallets[airline] = wallet;
        airlineCounter++;
    }

    function addUser(address user, userWallet wallet) public requireContractOwner 
    requireIsOperational{
        registeredUsers[user] = true;
        userWallets[user] = wallet;
    } 

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
    */
    function pay
                            (address user
                            )
                            external
                            requireContractOwner
                            requireRegisteredUser(user)
                            requireIsOperational
    {
        payable(user).transfer(userWallets[user].getBalance());
    }


    function fund   
                            (   
                            )
                            public
                            payable
                            requireIsOperational
    {
    }

    function authorizeCaller(address caller) public{
        require(msg.sender == contractOwner,  "unauthorized");
        contractOwner = caller;
    }

    /**
    * @dev receive function for funding smart contract.
    *
    */
    receive (     )      
                            external 
                            payable 
    {
        fund();
    }


    

}


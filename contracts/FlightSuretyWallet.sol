pragma solidity >= 0.8.0;
import "./FlightSuretyData.sol";
contract FlightSuretyAirlineWallet is airlineWallet{
    address owner;
    uint256 private balance = 0;
   mapping(bytes32 => address[]) insurees;

    constructor(address _owner) {
        owner = _owner;
    }

        modifier ownerOnly(){
        require (msg.sender == owner);
        _;
    }

    function deposit(uint256 amount) internal{
        balance += amount;
    }

    function getBalance() external view returns(uint256){
        return balance;
    }
    function addInsuree(address insurer, bytes32 flightKey) external{
        insurees[flightKey].push(insurer);
    }

    function getInsurees(bytes32 flightKey) external view returns (address[] memory){
        return insurees[flightKey];
    }

    function clear(bytes32 flightKey) external {
        insurees[flightKey] = new address[](50);
    }

    function withdraw(uint256 amount) external {
        balance -= amount;
    }

    receive() external payable ownerOnly {
        deposit(msg.value);
    }
    
}

contract FlightSuretyUserWallet is userWallet {
    address owner;
    address controller;
    uint256 private balance = 0;
    mapping(bytes32 => uint256) insuredFlights;

    modifier ownerOnly(){
        require (msg.sender == owner);
        _;
    }

    modifier controllerOnly(){
        require (msg.sender == controller);
        _;
    }

    constructor(address _owner) {
        controller = msg.sender;
        owner = _owner;
    }

    function deposit(uint256 amount) internal {
        balance += amount;
    }

    function getBalance() external view returns(uint256){
        return balance;
    }

    function insure(uint256 amount, bytes32 flightKey) external controllerOnly{
        require(balance>=amount, "not enough balance in account");
        balance -= amount;
        insuredFlights[flightKey] += amount;
    }

    function getInsuredFlight(bytes32 flightKey) external view returns (uint256){
        return insuredFlights[flightKey];
    }

    function clear(bytes32 flightKey) external controllerOnly{
        insuredFlights[flightKey] = 0;
    }

        receive() external payable ownerOnly {
        deposit(msg.value);
    }

}

    contract FlightSuretyWalletFactory {
        event userWalletCreated(address user);
        event airlineWalletCreated(address airline);
        mapping(address => airlineWallet) airlineWallets;
        mapping(address => userWallet) userWallets;

        address owner = address(0);

        function authorizeCaller(address newOwner) external{
            require (owner == address(0) || owner == msg.sender);

            owner = newOwner;
        }

        modifier ownerOnly() {
            require (msg.sender == owner);
            _;
        }

        function createUserWallet(address user) external ownerOnly returns (userWallet){
            userWallet wallet = new FlightSuretyUserWallet(user);
            userWallets[user] = wallet;
            emit userWalletCreated(user);
            return wallet ;
        }

        function createAirlineWallet(address airline) external  ownerOnly returns (airlineWallet){
            airlineWallet wallet = new FlightSuretyAirlineWallet(airline);
            airlineWallets[airline] = wallet;
            emit airlineWalletCreated(airline);
            return wallet;
        }

        function getUserWallet(address user) external view returns (userWallet){
            userWallet wallet = userWallets[user];
            return wallet;
        }

        function getAirlineWallet(address airline) external view returns (airlineWallet ){
            airlineWallet wallet = airlineWallets[airline];

            return wallet;
    
    }
    }

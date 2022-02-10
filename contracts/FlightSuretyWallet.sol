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

    function deposit(uint256 amount) external {
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

    function deposit(uint256 amount) external {
        balance += amount;
    }

    function getBalance() external view returns(uint256){
        return balance;
    }

    function insure(uint256 amount, bytes32 flightKey) external controllerOnly{
        require(balance>=amount, "not enough balance");
        balance -= amount;
        insuredFlights[flightKey] += amount;
    }

    function getInsuredFlight(bytes32 flightKey) external view returns (uint256){
        return insuredFlights[flightKey];
    }

    function clear(bytes32 flightKey) external {
        insuredFlights[flightKey] = 0;
    }

}

    contract FlightSuretyWalletFactory {
        event userWalletCreated(address user);
        event airlineWalletCreated(address airline);
        mapping(address => airlineWallet) airlineWallets;
        mapping(address => userWallet) userWallets;

        function createUserWallet(address user) external returns (userWallet){
            userWallet wallet = new FlightSuretyUserWallet(user);
            userWallets[user] = wallet;
            emit userWalletCreated(user);
            return wallet;
        }

        function createAirlineWallet(address airline) external returns (airlineWallet){
            airlineWallet wallet = new FlightSuretyAirlineWallet(airline);
            airlineWallets[airline] = wallet;
            emit airlineWalletCreated(airline);
            return wallet;
        }

        function getUserWallet(address user) external view returns (userWallet){
            return userWallets[user];
        }

        function getAirlineWallet(address airline) external view returns (airlineWallet) {
            return airlineWallets[airline];
        }
    }


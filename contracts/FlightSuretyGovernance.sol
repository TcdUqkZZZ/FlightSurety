pragma solidity >= 0.8.0;
contract FlightSuretyGovernance {
    address private contractOwner;
    bool private voteInProgress = false;
    address private currentlyVettedairline;
    mapping(address => bool) alreadyVoted;
    address[] voters = new address[](0);
    uint constant MIN_GOV_PERCENT = 50;


    modifier  noDoubleVoting(address voter){
        require(!alreadyVoted[voter]);
        _;
    }

    modifier flushing() {
        _;
        _flush();
    }


    constructor(){
        contractOwner = msg.sender;
    }

    event voteCast(address airline, address voter);
    event votePassed(address airline);

    function vote(address airline, address voter) external noDoubleVoting(voter){
        if(voteInProgress){
            require(airline == currentlyVettedairline, "currently voting on different airline");
            } else {
                _initVote(airline);
            }
        alreadyVoted[voter] = true;
        voters.push(voter);
        emit voteCast(airline, voter);
    } 

    function getResult(uint256 totalairlines) external returns(bool success, uint256 votes){
        if (totalairlines <= 4){
            _passVote(1);
        }
        else if  (voters.length >= (totalairlines * MIN_GOV_PERCENT)/100) {
            emit votePassed(currentlyVettedairline);
            return _passVote(voters.length);
        }
        else return (false, voters.length);
    }

    function _flush() private {
        for (uint i = 0; i < voters.length; i++){
            alreadyVoted[voters[i]] = false;           
        }
        voters = new address[](0);
        voteInProgress = false;
    }

    function _initVote(address airline) private {
         voteInProgress = true;
                currentlyVettedairline = airline;
    }

    function _passVote(uint256 _voters) 
    private flushing
    returns (bool success, uint256 num) {

        return (true, _voters);
    }

    function voteChangeOperationalState(address voter) external noDoubleVoting(voter){
        if (voteInProgress) revert();
        else {
            voteInProgress = true;
            currentlyVettedairline = address(0);
            voters.push(voter);
            emit voteCast(address(0), voter);
        }

    }



}
pragma solidity >= 0.8.0;
contract FlightSuretyGovernance {
    address private contractOwner;
    bool private voteInProgress = false;
    // target can be an airline address for voting airlines in, or address(0) for voting to change operational status.
    address private currentTarget;
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

    modifier ownerOnly() {
        require(msg.sender == contractOwner);
        _;
    }


    constructor(){
        contractOwner = msg.sender;
    }

    event voteCast(address airline, address voter);
    event votePassed(address airline);

    function vote(address target, address voter) external noDoubleVoting(voter) ownerOnly{
        if(voteInProgress){
            require(target == currentTarget, "currently voting on different airline");
            } else {
                _initVote(target);
            }
        alreadyVoted[voter] = true;
        voters.push(voter);
        emit voteCast(target, voter);
    } 

    function getResult(uint256 totalairlines) external returns(bool success, uint256 votes){
        if (totalairlines <= 4){
            _passVote(1);
        }
        else if  (voters.length >= (totalairlines * MIN_GOV_PERCENT)/100) {
            emit votePassed(currentTarget);
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
                currentTarget = airline;
    }

    function _passVote(uint256 _voters) 
    private flushing
    returns (bool success, uint256 num) {

        return (true, _voters);
    }

    function voteChangeOperationalState(address voter) external noDoubleVoting(voter) ownerOnly{
        if (voteInProgress) revert();
        else {
            voteInProgress = true;
            currentTarget = address(0);
            voters.push(voter);
            emit voteCast(address(0), voter);
        }

    }

    function changeOwner(address newOwner) external ownerOnly{
        contractOwner = newOwner;
    }



}
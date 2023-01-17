// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/* Import the Counters contract from the OpenZeppelin library, 
   which provides a counter utility for keeping track of various types of IDs. */
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";

contract Voting {

    /* This line uses the Counters contract from the imported library 
       and specifies that the Counter type should be used. */
    using Counters for Counters.Counter;

    Counters.Counter public _voterID; // Counter for voter ID.
    Counters.Counter public _candidateID; // Counter for candidate ID.

    address public votingOrganizer; // Address of the voting organizer.


    // This block defines a struct for a candidate, which includes their ID, voteCount, and address.
    struct Candidate {
        uint256 candidateID;
        uint256 voteCount;
        address _address;
    }

    // Event for when a candidate is created, which includes their ID, vote count, and address.
    event CandidateCreate (
        uint256 indexed candidateID,
        uint256 voteCount,
        address indexed _address
    );

    // Array to store the addresses of all the candidates.
    address[] public candidateAddress;

    // Mapping to store all the candidate structs, with the address of the candidate as the key.
    mapping(address => Candidate) public candidates;



    // Struct for a voter.
    struct Voter {
        uint256 voter_voterID; // Their ID.
        address voter_address; // Their address.
        uint256 voter_allowed; // Whether or not they are allowed to vote.
        bool voter_voted; // Whether or not they have voted.
        uint256 voter_vote; // Their vote.
    }

    // Event for when a voter is created.
    event VoterCreated (
        uint256 voter_voterID, // Their ID.
        address voter_address, // Their address.
        uint256 voter_allowed, // Whether or not they are allowed to vote.
        bool voter_voted, // Whether or not they have voted.
        uint256 voter_vote // Their vote.
    );

    // Array to store the addresses of all the voters who have voted.
    address[] public votedVoters;

    // Array to store the addresses of all the voters
    address[] public votersAddress;

    // Mapping to store all the Voter structs, with the address of the voter as the key.
    mapping(address => Voter) public voters;

    uint256 public startTime;
    uint256 public endTime;


    // Sets the votingOrganizer variable to the address of the contract creator (msg.sender).
    constructor() {
        votingOrganizer = msg.sender;
        startTime = uint256(block.timestamp + 1 hours); // 1 hour after contract deployment
        endTime = uint256(block.timestamp + 2 days); // 2 days after contract deployment.
    }

    // Function to change the votingOrganizer.
    function setNewOrganizer(address _newOrganizer) public {
        require(msg.sender == votingOrganizer, "You are not the votingOrganizer");
        votingOrganizer = _newOrganizer;
    }

    // Function to add candidates.
    function setCandidate(address _address) public {
        require(votingOrganizer == msg.sender, "Only the votingOrganizer can create candidates");

        _candidateID.increment(); // Increments the candidate ID counter by 1.

        // Assigns the current value of the candidate ID counter to a variable named idNumber.
        uint256 idNumber = _candidateID.current();

        /*Create a storage reference to the Candidate struct in the candidates mapping 
        that corresponds to the input address _address. */
        Candidate storage candidate = candidates[_address];

        candidate.candidateID = idNumber; // Set the candidate's ID.
        candidate.voteCount = 0; // Set the vote count.
        candidate._address = _address; // Set the address.

        // Add the candidate's address to the candidateAddress array.
        candidateAddress.push(_address);

        /* Emits the CandidateCreate event with the candidate's ID, 
        vote count, and address as the indexed arguments. */
        emit CandidateCreate(
            idNumber,
            candidate.voteCount,
            _address
        );
    }


    // This function returns the candidateAddress array.
    function getCandidate() public view returns (address[] memory) {
          return candidateAddress;
    }


    // This function returns the length of the candidateAddress array.
    function getCandidateLenght() public view returns(uint256) {
        return candidateAddress.length;
    }


    /* This function takes in an address as an input and returns the candidate's ID, 
    vote count, and address from the candidates mapping. */
    function getCandidateData(address _address) public view returns (uint256, uint256, address) {
        return (
            candidates[_address].candidateID,
            candidates[_address].voteCount,
            candidates[_address]._address
        );
    }


    // Create a new voter by the voting organizer.
    function createVoters(address _address) public {
        require(votingOrganizer == msg.sender, "Only organizer can create voter");

        _voterID.increment(); // Increments the voterID counter by 1.

        // Assigns the current value of the voterID counter to a variable named idNumber.
        uint256 idNumber = _voterID.current();

        /* This line creates a storage reference to the voter struct in the voters mapping 
           that corresponds to the input address _address. */
        Voter storage voter = voters[_address];

        /* Checks that the voter_allowed variable of that voter struct is equal to 0. If the voter_allowed
           variable of that voter struct is not equal to 0, the function will revert. */
        require(voter.voter_allowed == 0, "This voter has already been granted the right to vote");
    
        /* The next 5 lines set the voter's allowed status, address, ID, initial vote,
           and voting status to the corresponding variables. */
        voter.voter_allowed = 1;
        voter.voter_address = _address;
        voter.voter_voterID = idNumber;
        voter.voter_vote = 1000; // Is the default vote value, it's not used and you can change it as you need.
        voter.voter_voted = false;

        // Adds the voter's address to the votersAddress array.
        votersAddress.push(_address);

        /* Emits the VoterCreated event with the voter's ID, address, 
           allowed status, voting status, and vote as the arguments. */
        emit VoterCreated (
            idNumber, // Voter's ID.
            _address, // Address.
            voter.voter_allowed, // Allowed status.
            voter.voter_voted, // Voting status.
            voter.voter_vote // Vote.
        );

    }

    
    // Function that allows a voter to cast a vote for a candidate.
    function vote(address _candidateAddress, uint256 _candidateVoteId) external {
        // Check if the current time is within the voting period
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Voting period has not started or has ended");
        
        /* This creates a storage reference to the voter struct in the voters mapping that 
       corresponds to the address of the person calling the function (msg.sender). */
        Voter storage voter = voters[msg.sender];

        require(!voter.voter_voted, "You have already voted");
        require(voter.voter_allowed != 0, "You have no right to vote");

        voter.voter_voted = true; // Set the voter's voting status and vote to true.
        voter.voter_vote = _candidateVoteId; // Set the input candidateVoteId.

        votedVoters.push(msg.sender); //  Adds the address of the voter to the votedVoters array.

        /* Increments the voteCount of the candidate with the address _candidateAddress 
           by the voter's allowed value (1). */
        candidates[_candidateAddress].voteCount += voter.voter_allowed;
    }


    // This function returns the length of the votersAddress array.
    function getVoterLength() public view returns(uint256) {
        return votersAddress.length;
    }


    /* This function takes in an address as an input and returns the voter's ID, address, 
       allowed status, and voting status from the voters mapping. */
    function getVoterData (address _address) public view returns (uint256, address, uint256, bool) {
        return (
            voters[_address].voter_voterID,
            voters[_address].voter_address,
            voters[_address].voter_allowed,
            voters[_address].voter_voted
        );
    }


    // This function returns the votedVoters array.
    function getVotedVoterList() public view returns (address[] memory) {
        return votedVoters;
    }


    // This function returns the votersAddress array.
    function getVoterList() public view returns(address[] memory){
        return votersAddress;
    }


    // Returns the address of the winner.
    function getWinner() public view returns(address){

        // Declare variables to store the winner's address and max votes.
        address winner;
        uint256 maxVotes = 0;
        // Loop through the candidateAddress array.
        for (uint i = 0; i < candidateAddress.length; i++ ) {
            // Get the current candidate's address
            address candidate = candidateAddress[i];
            // Compare the current candidate's vote count to the max votes.
            if (candidates[candidate].voteCount > maxVotes) {
             // Update the max votes and winner's address.
                maxVotes = candidates[candidate].voteCount;
                winner = candidate;
            }
        }
        // Return the winner's address
        return winner;
    }

    // This function set the start time and end time for voting (_endTime in seconds).
    function restartTime(uint256 _endTime) public {
        require(msg.sender == votingOrganizer, "Only the organizer can restart the time");
        require(block.timestamp > endTime, "The voting period is not over yet");
        startTime = block.timestamp;
        endTime = block.timestamp + _endTime;
    }

    // Function to check how much time is left to vote.
    function timeRemaining() public view returns (uint256) {
        uint256 remainingTime = endTime - block.timestamp;
        require(remainingTime > 0, "Voting period is over.");
        return remainingTime;
    }


    // Function to restart the contract.
    function restartContract() public {
        require(msg.sender == votingOrganizer, "Only the organizer can restart the contract");
        require(block.timestamp > endTime, "The previous voting is not over yet");
        // Reset the voter and candidate ID counters.
        _voterID.reset();
        _candidateID.reset();
        // Clear the votersAddress and candidateAddress arrays.
        delete votersAddress;
        delete candidateAddress;
        // Reset the state of all voters and candidates.
        uint i = 0;
        while(i < votersAddress.length) {
            address voter = votersAddress[i];
            delete voters[voter];
            i++;
        }
        i = 0;
        while(i < candidateAddress.length) {
            address candidate = candidateAddress[i];
            delete candidates[candidate];
            i++;
        }
        // Clear the votedVoters array.
        delete votedVoters;
    }
}

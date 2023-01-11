// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Lottery {

    address public owner;

    // Array of Ethereum addresses of players who have entered the lottery.
    address payable[] public players;

    // The cost in wei required to enter the lottery.
    uint public entryCost;

    // Timestamp of when the lottery will end.
    uint public deadline;

    // The current lottery total amount.
    uint public currentAmount;

    event AllTimeWinners(address winner);


    constructor() {
        owner = msg.sender;
        entryCost = 10000000000000000; // 0.1 ether
        deadline = block.timestamp + (3 days); // 3 days from now
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    // Function that changes the owner.
    function transferOwnership(address _to) public onlyOwner {
        owner = _to;
    }

    // Function to participate in the lottery.
    function enter() public payable {
        require(msg.value >= entryCost, "Please enter the correct amount of entry cost.");
        require(block.timestamp < deadline, "The deadline for entering the lottery has passed.");
        players.push(payable(msg.sender));
        currentAmount += msg.value;
    }

    // Function to choose the winner.
    function pickWinner() public onlyOwner {
        require(block.timestamp > deadline, "The lottery is not over yet.");
        uint index = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % players.length;
        address payable winner = players[index];
        winner.transfer(address(this).balance);

        emit AllTimeWinners(winner);
    }

    // Change the enteryCost required to enter the lottery.
    function changeCost(uint newCost) public onlyOwner {
        require(block.timestamp > deadline, "The lottery is not over yet.");
        entryCost = newCost;
    }

    // Function to check if the contract is ended.
    function isEnded() public view returns (bool) {
        return block.timestamp > deadline;
    }

    // Returns the total number of players that have entered in the current lottery.
    function totalPlayers() public view returns(uint) {
        return players.length;
    }

    // Restart the lottery after the previous one has ended.
    function restartLottery(uint durationInDays) public onlyOwner {
        require(block.timestamp > deadline, "The previous lottery is not over yet");
        deadline = block.timestamp + (durationInDays * 86400); // 86400 is seconds in a day.
        players = new address payable[](0);
        currentAmount = 0;
    }

        // Receive function
    receive() external payable {}

    // Fallback function
    fallback () external payable {}

}

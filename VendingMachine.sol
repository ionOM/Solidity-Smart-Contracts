// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract TheOwner {

    address public owner;  // The address of the owner of the contract.
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function that changes the owner.
    function transferOwnership(address _to) public onlyOwner {
        newOwner = _to;
  }
    // To be completed the ownership transfer, this function must be called by newOwner.
    function acceptOwnership() public {
        require(msg.sender == newOwner, "You are not the newOwner");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract VendingMachine is TheOwner {

    // The price of the product in wei.
    uint256 public price;

    // The number of products available for sale.
    uint256 public inventory;

    // A boolean variable to store the pause state of the contract.
    bool public paused;

    // Event that is emitted when a product is purchased.
    event ProductPurchased(uint256 indexed quantity, uint256 totalPrice);


    // Add the quantity of the product and the price.
    constructor(uint256 _price, uint256 _inventory) {
        price = _price;
        inventory = _inventory;
    }

    // Function to purchase a product.
    function purchaseProduct() public payable {
        require(paused == false, "The contract is paused, try later please.");
        require(msg.value >= price, "Insufficient payment.");
        require(inventory > 0, "Out of stock.");
        inventory--;
        emit ProductPurchased(1, msg.value);
    }


    // Let the owner restock the vending machine.
    function restock(uint _amount) public onlyOwner {
        inventory += _amount;
    }

    // Function that allows the owner of the contract to update the price of the product.
    function updatePrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    // Function to get the contract's current balance.
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // Function that allows the owner of the contract to withdraw any accumulated funds.
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // Function to pause the contract. Can only be called by the owner.
    function pause() public onlyOwner {
        paused = true;
    }

    // Function to unpause the contract. Can only be called by the owner.
    function unpause() public onlyOwner {
        paused = false;
    }

    // Function to check if the contract is paused.
    function isPaused() public view returns (bool) {
        return paused;
    }

    // Receive function
    receive() external payable {}

    // Fallback function
    fallback () external payable {}

}

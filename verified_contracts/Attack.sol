pragma solidity ^0.4.24;


contract Attack {
    constructor(address to) public payable {
        require(to.call.value(msg.value)());
    }
}
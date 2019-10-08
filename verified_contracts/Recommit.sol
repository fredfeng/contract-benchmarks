pragma solidity 0.4.25;

contract Recommitable {
    function recommit(uint id) public;
}

contract Recommit {
    
    function recommitAll(address pack, uint[] ids) public {
        for (uint i = 0; i < ids.length; i++) {
            Recommitable(pack).recommit(i);
        }   
    }
}
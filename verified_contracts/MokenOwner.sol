pragma solidity 0.4.24;
pragma experimental "v0.5.0";
/******************************************************************************\
* Author: Nick Mudge, <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="cea0a7ada58ea3a1a5aba0bde0a7a1">[email protected]</a>&#13;
* Mokens&#13;
* Copyright (c) 2018&#13;
/******************************************************************************/&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
//Storage contracts&#13;
////////////&#13;
//Some delegate contracts are listed with storage contracts they inherit.&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
//Mokens&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
contract Storage0 {&#13;
    // funcId =&gt; delegate contract&#13;
    mapping(bytes4 =&gt; address) internal delegates;&#13;
}&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
//MokenUpdates&#13;
//MokenOwner&#13;
//QueryMokenDelegates&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
contract Storage1 is Storage0 {&#13;
    address internal contractOwner;&#13;
    bytes[] internal funcSignatures;&#13;
    // signature =&gt; index+1&#13;
    mapping(bytes =&gt; uint256) internal funcSignatureToIndex;&#13;
}&#13;
&#13;
contract MokenOwner is Storage1 {&#13;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);&#13;
&#13;
    function owner() external view returns (address) {&#13;
        return contractOwner;&#13;
    }&#13;
&#13;
    function transferOwnership(address _newOwner) external {&#13;
        require(msg.sender == contractOwner, "Must own Mokens contract.");&#13;
        require(_newOwner != address(0), "_newOwner cannot be 0 address.");&#13;
        emit OwnershipTransferred(contractOwner, _newOwner);&#13;
        contractOwner = _newOwner;&#13;
    }&#13;
&#13;
    function withdraw(address _sendTo, uint256 _amount) external {&#13;
        require(msg.sender == contractOwner, "Must own Mokens contract.");&#13;
        address mokensContract = address(this);&#13;
        require(_amount &lt;= mokensContract.balance, "Amount is greater than balance.");&#13;
        _sendTo.transfer(_amount);&#13;
    }&#13;
}
pragma solidity ^0.4.18;

/* ==================================================================== */
/* Copyright (c) 2018 The Priate Conquest Project.  All rights reserved.
/* 
/* https://www.pirateconquest.com One of the world's slg games of blockchain 
/*  
/* authors <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ea988b838493aa86839c8f999e8b98c4898587">[email protected]</a>/<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="054f6a6b6b7c2b437045696c7360767164772b666a68">[email protected]</a>&#13;
/*                 &#13;
/* ==================================================================== */&#13;
&#13;
contract KittyInterface {&#13;
  function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens);&#13;
  function ownerOf(uint256 _tokenId) external view returns (address owner);&#13;
  function balanceOf(address _owner) public view returns (uint256 count);&#13;
}&#13;
&#13;
interface KittyTokenInterface {&#13;
  function transferFrom(address _from, address _to, uint256 _tokenId) external;&#13;
  function setTokenPrice(uint256 _tokenId, uint256 _price) external;&#13;
  function CreateKittyToken(address _owner,uint256 _price, uint32 _kittyId) public;&#13;
}&#13;
&#13;
contract CaptainKitties {&#13;
  address owner;&#13;
  //event &#13;
  event CreateKitty(uint _count,address _owner);&#13;
&#13;
  KittyInterface kittyContract;&#13;
  KittyTokenInterface kittyToken;&#13;
  /// @dev Trust contract&#13;
  mapping (address =&gt; bool) actionContracts;&#13;
  mapping (address =&gt; uint256) kittyToCount;&#13;
  mapping (address =&gt; bool) kittyGetOrNot;&#13;
 &#13;
&#13;
  function CaptainKitties() public {&#13;
    owner = msg.sender;&#13;
  }  &#13;
  modifier onlyOwner() {&#13;
    require(msg.sender == owner);&#13;
    _;&#13;
  }&#13;
  &#13;
  function setKittyContractAddress(address _address) external onlyOwner {&#13;
    kittyContract = KittyInterface(_address);&#13;
  }&#13;
&#13;
  function setKittyTokenAddress(address _address) external onlyOwner {&#13;
    kittyToken = KittyTokenInterface(_address);&#13;
  }&#13;
&#13;
  function createKitties() external payable {&#13;
    uint256 kittycount = kittyContract.balanceOf(msg.sender);&#13;
    require(kittyGetOrNot[msg.sender] == false);&#13;
    if (kittycount&gt;=9) {&#13;
      kittycount=9;&#13;
    }&#13;
    if (kittycount&gt;0 &amp;&amp; kittyToCount[msg.sender]==0) {&#13;
      kittyToCount[msg.sender] = kittycount;&#13;
      kittyGetOrNot[msg.sender] = true;&#13;
      for (uint i=0;i&lt;kittycount;i++) {&#13;
        kittyToken.CreateKittyToken(msg.sender,0, 1);&#13;
      }&#13;
      //event&#13;
      CreateKitty(kittycount,msg.sender);&#13;
    }&#13;
  }&#13;
&#13;
  function getKitties() external view returns(uint256 kittycnt,uint256 captaincnt,bool bGetOrNot) {&#13;
    kittycnt = kittyContract.balanceOf(msg.sender);&#13;
    captaincnt = kittyToCount[msg.sender];&#13;
    bGetOrNot = kittyGetOrNot[msg.sender];&#13;
  }&#13;
&#13;
  function getKittyGetOrNot(address _addr) external view returns (bool) {&#13;
    return kittyGetOrNot[_addr];&#13;
  }&#13;
&#13;
  function getKittyCount(address _addr) external view returns (uint256) {&#13;
    return kittyToCount[_addr];&#13;
  }&#13;
&#13;
  function birthKitty() external {&#13;
  }&#13;
&#13;
}
/* ==================================================================== */
/* Copyright (c) 2018 The ether.online Project.  All rights reserved.
/* 
/* https://ether.online  The first RPG game of blockchain 
/*  
/* authors <span class="__cf_email__" data-cfemail="7f0d161c14170a110b1a0d510c171a113f18121e1613511c1012">[email protected]</span>   &#13;
/*         <span class="__cf_email__" data-cfemail="394a5c4a4c575d50575e795e54585055175a5654">[email protected]</span>            &#13;
/* ==================================================================== */&#13;
&#13;
pragma solidity ^0.4.20;&#13;
&#13;
contract AccessAdmin {&#13;
    bool public isPaused = false;&#13;
    address public addrAdmin;  &#13;
&#13;
    event AdminTransferred(address indexed preAdmin, address indexed newAdmin);&#13;
&#13;
    function AccessAdmin() public {&#13;
        addrAdmin = msg.sender;&#13;
    }  &#13;
&#13;
&#13;
    modifier onlyAdmin() {&#13;
        require(msg.sender == addrAdmin);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier whenNotPaused() {&#13;
        require(!isPaused);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier whenPaused {&#13;
        require(isPaused);&#13;
        _;&#13;
    }&#13;
&#13;
    function setAdmin(address _newAdmin) external onlyAdmin {&#13;
        require(_newAdmin != address(0));&#13;
        AdminTransferred(addrAdmin, _newAdmin);&#13;
        addrAdmin = _newAdmin;&#13;
    }&#13;
&#13;
    function doPause() external onlyAdmin whenNotPaused {&#13;
        isPaused = true;&#13;
    }&#13;
&#13;
    function doUnpause() external onlyAdmin whenPaused {&#13;
        isPaused = false;&#13;
    }&#13;
}&#13;
&#13;
contract AccessService is AccessAdmin {&#13;
    address public addrService;&#13;
    address public addrFinance;&#13;
&#13;
    modifier onlyService() {&#13;
        require(msg.sender == addrService);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyFinance() {&#13;
        require(msg.sender == addrFinance);&#13;
        _;&#13;
    }&#13;
&#13;
    function setService(address _newService) external {&#13;
        require(msg.sender == addrService || msg.sender == addrAdmin);&#13;
        require(_newService != address(0));&#13;
        addrService = _newService;&#13;
    }&#13;
&#13;
    function setFinance(address _newFinance) external {&#13;
        require(msg.sender == addrFinance || msg.sender == addrAdmin);&#13;
        require(_newFinance != address(0));&#13;
        addrFinance = _newFinance;&#13;
    }&#13;
&#13;
    function withdraw(address _target, uint256 _amount) &#13;
        external &#13;
    {&#13;
        require(msg.sender == addrFinance || msg.sender == addrAdmin);&#13;
        require(_amount &gt; 0);&#13;
        address receiver = _target == address(0) ? addrFinance : _target;&#13;
        uint256 balance = this.balance;&#13;
        if (_amount &lt; balance) {&#13;
            receiver.transfer(_amount);&#13;
        } else {&#13;
            receiver.transfer(this.balance);&#13;
        }      &#13;
    }&#13;
}&#13;
&#13;
/**&#13;
 * @title SafeMath&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
library SafeMath {&#13;
    /**&#13;
    * @dev Multiplies two numbers, throws on overflow.&#13;
    */&#13;
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        if (a == 0) {&#13;
            return 0;&#13;
        }&#13;
        uint256 c = a * b;&#13;
        assert(c / a == b);&#13;
        return c;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Integer division of two numbers, truncating the quotient.&#13;
    */&#13;
    function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
        uint256 c = a / b;&#13;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
        return c;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).&#13;
    */&#13;
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        assert(b &lt;= a);&#13;
        return a - b;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Adds two numbers, throws on overflow.&#13;
    */&#13;
    function add(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        uint256 c = a + b;&#13;
        assert(c &gt;= a);&#13;
        return c;&#13;
    }&#13;
}&#13;
&#13;
contract ArenaPool is AccessService {&#13;
    using SafeMath for uint256;&#13;
&#13;
    event SendArenaSuccesss(uint64 flag, uint256 oldBalance, uint256 sendVal);&#13;
    event ArenaTimeClear(uint256 newVal);&#13;
    uint64 public nextArenaTime;&#13;
    uint256 maxArenaOneDay = 30;&#13;
&#13;
    function ArenaPool() public {&#13;
        addrAdmin = msg.sender;&#13;
        addrService = msg.sender;&#13;
        addrFinance = msg.sender;&#13;
    }&#13;
&#13;
    function() external payable {&#13;
&#13;
    }&#13;
&#13;
    function getBalance() external view returns(uint256) {&#13;
        return this.balance;&#13;
    }&#13;
&#13;
    function clearNextArenaTime() external onlyService {&#13;
        nextArenaTime = 0;&#13;
        ArenaTimeClear(0);&#13;
    }&#13;
&#13;
    function setMaxArenaOneDay(uint256 val) external onlyAdmin {&#13;
        require(val &gt; 0 &amp;&amp; val &lt; 100);&#13;
        require(val != maxArenaOneDay);&#13;
        maxArenaOneDay = val;&#13;
    }&#13;
&#13;
    function sendArena(address[] winners, uint256[] amounts, uint64 _flag) &#13;
        external &#13;
        onlyService &#13;
        whenNotPaused&#13;
    {&#13;
        uint64 tmNow = uint64(block.timestamp);&#13;
        uint256 length = winners.length;&#13;
        require(length == amounts.length);&#13;
        require(length &lt;= 100);&#13;
&#13;
        uint256 sum = 0;&#13;
        for (uint32 i = 0; i &lt; length; ++i) {&#13;
            sum = sum.add(amounts[i]);&#13;
        }&#13;
        uint256 balance = this.balance;&#13;
        require((sum.mul(100).div(balance)) &lt;= maxArenaOneDay);&#13;
&#13;
        address addrZero = address(0);&#13;
        for (uint32 j = 0; j &lt; length; ++j) {&#13;
            if (winners[j] != addrZero) {&#13;
                winners[j].transfer(amounts[j]);&#13;
            }&#13;
        }&#13;
        nextArenaTime = tmNow + 21600;&#13;
        SendArenaSuccesss(_flag, balance, sum);&#13;
    }&#13;
}
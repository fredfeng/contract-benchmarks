pragma solidity ^0.4.18;


/**
 * @title Global Mobile Industry Service Ecosystem Chain 
 * @dev Developed By Jack 5/14 2018 
 * @dev contact:<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="244e45474f0a4f4b41644349454d480a474b49">[email protected]</a>&#13;
 */&#13;
&#13;
library SafeMath {&#13;
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        if (a == 0) {&#13;
            return 0;&#13;
        }&#13;
        uint256 c = a * b;&#13;
        assert(c / a == b);&#13;
        return c;&#13;
    }&#13;
&#13;
    function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        uint256 c = a / b;&#13;
        return c;&#13;
    }&#13;
&#13;
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        assert(b &lt;= a);&#13;
        return a - b;&#13;
    }&#13;
&#13;
    function add(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        uint256 c = a + b;&#13;
        assert(c &gt;= a);&#13;
        return c;&#13;
    }&#13;
}&#13;
&#13;
contract Ownable {&#13;
    address public owner;&#13;
&#13;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);&#13;
    function Ownable() public {&#13;
        owner = msg.sender;&#13;
    }&#13;
&#13;
    modifier onlyOwner() {&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
&#13;
    function isOwner() internal view returns(bool success) {&#13;
        if (msg.sender == owner) return true;&#13;
        return false;&#13;
    }&#13;
&#13;
    function transferOwnership(address newOwner) onlyOwner public {&#13;
        require(newOwner != address(0));&#13;
        OwnershipTransferred(owner, newOwner);&#13;
        owner = newOwner;&#13;
    }&#13;
}&#13;
&#13;
/**&#13;
 * @title ERC20Basic&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/179&#13;
 */&#13;
contract ERC20Basic {&#13;
    uint256 public totalSupply;&#13;
    function balanceOf(address who) public view returns (uint256);&#13;
    function transfer(address to, uint256 value) public returns (bool);&#13;
    event Transfer(address indexed from, address indexed to, uint256 value);&#13;
}&#13;
&#13;
/**&#13;
 * @title ERC20 interface&#13;
 * @dev https://github.com/ethereum/EIPs/issues/20&#13;
 */&#13;
contract ERC20 is ERC20Basic {&#13;
    function allowance(address owner, address spender) public view returns (uint256);&#13;
    function transferFrom(address from, address to, uint256 value) public returns (bool);&#13;
    function approve(address spender, uint256 value) public returns (bool);&#13;
    event Approval(address indexed owner, address indexed spender, uint256 value);&#13;
}&#13;
&#13;
/**&#13;
 * @title Basic token&#13;
 * @dev Basic version of StandardToken, with no allowances.&#13;
 */&#13;
contract BasicToken is ERC20Basic {&#13;
    using SafeMath for uint256;&#13;
&#13;
    mapping(address =&gt; uint256) balances;&#13;
&#13;
    function transfer(address _to, uint256 _value) public returns (bool) {&#13;
        require(_to != address(0));&#13;
        require(_value &lt;= balances[msg.sender]);&#13;
        balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
        balances[_to] = balances[_to].add(_value);&#13;
        Transfer(msg.sender, _to, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    function balanceOf(address _owner) public view returns (uint256 balance) {&#13;
        return balances[_owner];&#13;
    }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Standard ERC20 token&#13;
 * @dev Implementation of the basic standard token.&#13;
 */&#13;
contract StandardToken is ERC20, BasicToken {&#13;
&#13;
    mapping (address =&gt; mapping (address =&gt; uint256)) internal allowed;&#13;
&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {&#13;
        require(_to != address(0));&#13;
        require(_value &lt;= balances[_from]);&#13;
        require(_value &lt;= allowed[_from][msg.sender]);&#13;
&#13;
        balances[_from] = balances[_from].sub(_value);&#13;
        balances[_to] = balances[_to].add(_value);&#13;
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
        Transfer(_from, _to, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    function approve(address _spender, uint256 _value) public returns (bool) {&#13;
        allowed[msg.sender][_spender] = _value;&#13;
        Approval(msg.sender, _spender, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    function allowance(address _owner, address _spender) public view returns (uint256) {&#13;
        return allowed[_owner][_spender];&#13;
    }&#13;
&#13;
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {&#13;
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);&#13;
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
        return true;&#13;
    }&#13;
&#13;
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {&#13;
        uint oldValue = allowed[msg.sender][_spender];&#13;
        if (_subtractedValue &gt; oldValue) {&#13;
            allowed[msg.sender][_spender] = 0;&#13;
        } else {&#13;
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);&#13;
        }&#13;
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
        return true;&#13;
    }&#13;
}&#13;
&#13;
contract MSCE is Ownable, StandardToken {&#13;
    using SafeMath for uint256;&#13;
&#13;
    uint8 public constant TOKEN_DECIMALS = 18;&#13;
&#13;
    string public name = "Mobile Ecosystem"; &#13;
    string public symbol = "MSCE";&#13;
    uint8 public decimals = TOKEN_DECIMALS;&#13;
&#13;
&#13;
    uint256 public totalSupply = 500000000 *(10**uint256(TOKEN_DECIMALS)); &#13;
    uint256 public soldSupply = 0; &#13;
    uint256 public sellSupply = 0; &#13;
    uint256 public buySupply = 0; &#13;
    bool public stopSell = true;&#13;
    bool public stopBuy = true;&#13;
&#13;
    uint256 public crowdsaleStartTime = block.timestamp;&#13;
    uint256 public crowdsaleEndTime = block.timestamp;&#13;
&#13;
    uint256 public crowdsaleTotal = 0;&#13;
&#13;
&#13;
    uint256 public buyExchangeRate = 10000;   &#13;
    uint256 public sellExchangeRate = 60000;  &#13;
    address public ethFundDeposit;  &#13;
&#13;
&#13;
    bool public allowTransfers = true; &#13;
&#13;
&#13;
    mapping (address =&gt; bool) public frozenAccount;&#13;
&#13;
    bool public enableInternalLock = true; &#13;
    mapping (address =&gt; bool) public internalLockAccount;&#13;
&#13;
    mapping (address =&gt; uint256) public releaseLockAccount;&#13;
&#13;
&#13;
    event FrozenFunds(address target, bool frozen);&#13;
    event IncreaseSoldSaleSupply(uint256 _value);&#13;
    event DecreaseSoldSaleSupply(uint256 _value);&#13;
&#13;
    function MSCE() public {&#13;
&#13;
&#13;
        balances[msg.sender] = totalSupply;             &#13;
&#13;
        ethFundDeposit = msg.sender;                      &#13;
        allowTransfers = false;&#13;
    }&#13;
&#13;
    function _isUserInternalLock() internal view returns (bool) {&#13;
&#13;
        return getAccountLockState(msg.sender);&#13;
&#13;
    }&#13;
&#13;
    function increaseSoldSaleSupply (uint256 _value) onlyOwner public {&#13;
        require (_value + soldSupply &lt; totalSupply);&#13;
        soldSupply = soldSupply.add(_value);&#13;
        IncreaseSoldSaleSupply(_value);&#13;
    }&#13;
&#13;
    function decreaseSoldSaleSupply (uint256 _value) onlyOwner public {&#13;
        require (soldSupply - _value &gt; 0);&#13;
        soldSupply = soldSupply.sub(_value);&#13;
        DecreaseSoldSaleSupply(_value);&#13;
    }&#13;
&#13;
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {&#13;
        balances[target] = balances[target].add(mintedAmount);&#13;
        totalSupply = totalSupply.add(mintedAmount);&#13;
        Transfer(0, this, mintedAmount);&#13;
        Transfer(this, target, mintedAmount);&#13;
    }&#13;
&#13;
    function destroyToken(address target, uint256 amount) onlyOwner public {&#13;
        balances[target] = balances[target].sub(amount);&#13;
        totalSupply = totalSupply.sub(amount);&#13;
        Transfer(target, this, amount);&#13;
        Transfer(this, 0, amount);&#13;
    }&#13;
&#13;
&#13;
    function freezeAccount(address target, bool freeze) onlyOwner public {&#13;
        frozenAccount[target] = freeze;&#13;
        FrozenFunds(target, freeze);&#13;
    }&#13;
&#13;
&#13;
    function setEthFundDeposit(address _ethFundDeposit) onlyOwner public {&#13;
        require(_ethFundDeposit != address(0));&#13;
        ethFundDeposit = _ethFundDeposit;&#13;
    }&#13;
&#13;
    function transferETH() onlyOwner public {&#13;
        require(ethFundDeposit != address(0));&#13;
        require(this.balance != 0);&#13;
        require(ethFundDeposit.send(this.balance));&#13;
    }&#13;
&#13;
&#13;
    function setExchangeRate(uint256 _sellExchangeRate, uint256 _buyExchangeRate) onlyOwner public {&#13;
        sellExchangeRate = _sellExchangeRate;&#13;
        buyExchangeRate = _buyExchangeRate;&#13;
    }&#13;
&#13;
    function setName(string _name) onlyOwner public {&#13;
        name = _name;&#13;
    }&#13;
&#13;
    function setSymbol(string _symbol) onlyOwner public {&#13;
        symbol = _symbol;&#13;
    }&#13;
&#13;
    function setAllowTransfers(bool _allowTransfers) onlyOwner public {&#13;
        allowTransfers = _allowTransfers;&#13;
    }&#13;
&#13;
    function transferFromAdmin(address _from, address _to, uint256 _value) onlyOwner public returns (bool) {&#13;
        require(_to != address(0));&#13;
        require(_value &lt;= balances[_from]);&#13;
&#13;
        balances[_from] = balances[_from].sub(_value);&#13;
        balances[_to] = balances[_to].add(_value);&#13;
        Transfer(_from, _to, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    function setEnableInternalLock(bool _isEnable) onlyOwner public {&#13;
        enableInternalLock = _isEnable;&#13;
    }&#13;
&#13;
    function lockInternalAccount(address _target, bool _lock, uint256 _releaseTime) onlyOwner public {&#13;
        require(_target != address(0));&#13;
&#13;
        internalLockAccount[_target] = _lock;&#13;
        releaseLockAccount[_target] = _releaseTime;&#13;
&#13;
    }&#13;
&#13;
    function getAccountUnlockTime(address _target) public view returns(uint256) {&#13;
&#13;
        return releaseLockAccount[_target];&#13;
&#13;
    }&#13;
    function getAccountLockState(address _target) public view returns(bool) {&#13;
        if(enableInternalLock &amp;&amp; internalLockAccount[_target]){&#13;
            if((releaseLockAccount[_target] &gt; 0)&amp;&amp;(releaseLockAccount[_target]&lt;block.timestamp)){       &#13;
                return false;&#13;
            }          &#13;
            return true;&#13;
        }&#13;
        return false;&#13;
&#13;
    }&#13;
&#13;
    function internalSellTokenFromAdmin(address _to, uint256 _value, bool _lock, uint256 _releaseTime) onlyOwner public returns (bool) {&#13;
        require(_to != address(0));&#13;
        require(_value &lt;= balances[owner]);&#13;
&#13;
        balances[owner] = balances[owner].sub(_value);&#13;
        balances[_to] = balances[_to].add(_value);&#13;
        soldSupply = soldSupply.add(_value);&#13;
        sellSupply = sellSupply.add(_value);&#13;
&#13;
        Transfer(owner, _to, _value);&#13;
        &#13;
        lockInternalAccount(_to, _lock, _releaseTime);&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    /***************************************************/&#13;
    /*              BASE Functions                     */&#13;
    /***************************************************/&#13;
&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {&#13;
        if (!isOwner()) {&#13;
            require (allowTransfers);&#13;
            require(!frozenAccount[_from]);                                         &#13;
            require(!frozenAccount[_to]);                                        &#13;
            require(!_isUserInternalLock());                                       &#13;
        }&#13;
        return super.transferFrom(_from, _to, _value);&#13;
    }&#13;
&#13;
    function transfer(address _to, uint256 _value) public returns (bool) {&#13;
        if (!isOwner()) {&#13;
            require (allowTransfers);&#13;
            require(!frozenAccount[msg.sender]);                                       &#13;
            require(!frozenAccount[_to]);                                             &#13;
            require(!_isUserInternalLock());                                           &#13;
        }&#13;
        return super.transfer(_to, _value);&#13;
    }&#13;
&#13;
    function () internal payable{&#13;
&#13;
        uint256 currentTime = block.timestamp;&#13;
        require((currentTime&gt;crowdsaleStartTime)&amp;&amp;(currentTime&lt;crowdsaleEndTime));&#13;
        require(crowdsaleTotal&gt;0);&#13;
&#13;
        require(buy());&#13;
&#13;
        crowdsaleTotal = crowdsaleTotal.sub(msg.value.mul(buyExchangeRate));&#13;
&#13;
    }&#13;
&#13;
    function buy() payable public returns (bool){&#13;
&#13;
&#13;
        uint256 amount = msg.value.mul(buyExchangeRate);&#13;
&#13;
        require(!stopBuy);&#13;
        require(amount &lt;= balances[owner]);&#13;
&#13;
        balances[owner] = balances[owner].sub(amount);&#13;
        balances[msg.sender] = balances[msg.sender].add(amount);&#13;
&#13;
        soldSupply = soldSupply.add(amount);&#13;
        buySupply = buySupply.add(amount);&#13;
&#13;
        Transfer(owner, msg.sender, amount);&#13;
        return true;&#13;
    }&#13;
&#13;
    function sell(uint256 amount) public {&#13;
        uint256 ethAmount = amount.div(sellExchangeRate);&#13;
        require(!stopSell);&#13;
        require(this.balance &gt;= ethAmount);      &#13;
        require(ethAmount &gt;= 1);      &#13;
&#13;
        require(balances[msg.sender] &gt;= amount);                 &#13;
        require(balances[owner] + amount &gt; balances[owner]);       &#13;
        require(!frozenAccount[msg.sender]);                       &#13;
        require(!_isUserInternalLock());                                          &#13;
&#13;
        balances[owner] = balances[owner].add(amount);&#13;
        balances[msg.sender] = balances[msg.sender].sub(amount);&#13;
&#13;
        soldSupply = soldSupply.sub(amount);&#13;
        sellSupply = sellSupply.add(amount);&#13;
&#13;
        Transfer(msg.sender, owner, amount);&#13;
&#13;
        msg.sender.transfer(ethAmount); &#13;
    }&#13;
&#13;
    function setCrowdsaleStartTime(uint256 _crowdsaleStartTime) onlyOwner public {&#13;
        crowdsaleStartTime = _crowdsaleStartTime;&#13;
    }&#13;
&#13;
    function setCrowdsaleEndTime(uint256 _crowdsaleEndTime) onlyOwner public {&#13;
        crowdsaleEndTime = _crowdsaleEndTime;&#13;
    }&#13;
   &#13;
&#13;
    function setCrowdsaleTotal(uint256 _crowdsaleTotal) onlyOwner public {&#13;
        crowdsaleTotal = _crowdsaleTotal;&#13;
    }&#13;
}
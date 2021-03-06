pragma solidity ^0.4.12;

//======  OpenZeppelin libraray =====

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/** 
 * @title Contracts that should not own Contracts
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="4634232b25290674">[email protected]</a>π.com&gt;&#13;
 * @dev Should contracts (anything Ownable) end up being owned by this contract, it allows the owner&#13;
 * of this contract to reclaim ownership of the contracts.&#13;
 */&#13;
contract HasNoContracts is Ownable {&#13;
&#13;
  /**&#13;
   * @dev Reclaim ownership of Ownable contracts&#13;
   * @param contractAddr The address of the Ownable to be reclaimed.&#13;
   */&#13;
  function reclaimContract(address contractAddr) external onlyOwner {&#13;
    Ownable contractInst = Ownable(contractAddr);&#13;
    contractInst.transferOwnership(owner);&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title Contracts that should be able to recover tokens&#13;
 * @author SylTi&#13;
 * @dev This allow a contract to recover any ERC20 token received in a contract by transfering the balance to the contract owner.&#13;
 * This will prevent any accidental loss of tokens.&#13;
 */&#13;
contract CanReclaimToken is Ownable {&#13;
  using SafeERC20 for ERC20Basic;&#13;
&#13;
  /**&#13;
   * @dev Reclaim all ERC20Basic compatible tokens&#13;
   * @param token ERC20Basic The address of the token contract&#13;
   */&#13;
  function reclaimToken(ERC20Basic token) external onlyOwner {&#13;
    uint256 balance = token.balanceOf(this);&#13;
    token.safeTransfer(owner, balance);&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Contracts that should not own Tokens&#13;
 * @author Remco Bloemen &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="3644535b55597604">[email protected]</a>π.com&gt;&#13;
 * @dev This blocks incoming ERC23 tokens to prevent accidental loss of tokens.&#13;
 * Should tokens (any ERC20Basic compatible) end up in the contract, it allows the&#13;
 * owner to reclaim the tokens.&#13;
 */&#13;
contract HasNoTokens is CanReclaimToken {&#13;
&#13;
 /**&#13;
  * @dev Reject all ERC23 compatible tokens&#13;
  * param from_ address The address that is transferring the tokens&#13;
  * param value_ uint256 the amount of the specified token&#13;
  * param data_ Bytes The data passed from the caller.&#13;
  */&#13;
  function tokenFallback(address /*from_*/, uint256 /*value_*/, bytes /*data_*/) external {&#13;
    revert();&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Basic token&#13;
 * @dev Basic version of StandardToken, with no allowances. &#13;
 */&#13;
contract BasicToken is ERC20Basic {&#13;
  using SafeMath for uint256;&#13;
&#13;
  mapping(address =&gt; uint256) balances;&#13;
&#13;
  /**&#13;
  * @dev transfer token for a specified address&#13;
  * @param _to The address to transfer to.&#13;
  * @param _value The amount to be transferred.&#13;
  */&#13;
  function transfer(address _to, uint256 _value) returns (bool) {&#13;
    require(_to != address(0));&#13;
&#13;
    // SafeMath.sub will throw if there is not enough balance.&#13;
    balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    Transfer(msg.sender, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Gets the balance of the specified address.&#13;
  * @param _owner The address to query the the balance of. &#13;
  * @return An uint256 representing the amount owned by the passed address.&#13;
  */&#13;
  function balanceOf(address _owner) constant returns (uint256 balance) {&#13;
    return balances[_owner];&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Standard ERC20 token&#13;
 *&#13;
 * @dev Implementation of the basic standard token.&#13;
 * @dev https://github.com/ethereum/EIPs/issues/20&#13;
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol&#13;
 */&#13;
contract StandardToken is ERC20, BasicToken {&#13;
&#13;
  mapping (address =&gt; mapping (address =&gt; uint256)) allowed;&#13;
&#13;
&#13;
  /**&#13;
   * @dev Transfer tokens from one address to another&#13;
   * @param _from address The address which you want to send tokens from&#13;
   * @param _to address The address which you want to transfer to&#13;
   * @param _value uint256 the amount of tokens to be transferred&#13;
   */&#13;
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {&#13;
    require(_to != address(0));&#13;
&#13;
    var _allowance = allowed[_from][msg.sender];&#13;
&#13;
    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met&#13;
    // require (_value &lt;= _allowance);&#13;
&#13;
    balances[_from] = balances[_from].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    allowed[_from][msg.sender] = _allowance.sub(_value);&#13;
    Transfer(_from, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _value The amount of tokens to be spent.&#13;
   */&#13;
  function approve(address _spender, uint256 _value) returns (bool) {&#13;
&#13;
    // To change the approve amount you first have to reduce the addresses`&#13;
    //  allowance to zero by calling `approve(_spender, 0)` if it is not&#13;
    //  already 0 to mitigate the race condition described here:&#13;
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729&#13;
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));&#13;
&#13;
    allowed[msg.sender][_spender] = _value;&#13;
    Approval(msg.sender, _spender, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to check the amount of tokens that an owner allowed to a spender.&#13;
   * @param _owner address The address which owns the funds.&#13;
   * @param _spender address The address which will spend the funds.&#13;
   * @return A uint256 specifying the amount of tokens still available for the spender.&#13;
   */&#13;
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {&#13;
    return allowed[_owner][_spender];&#13;
  }&#13;
  &#13;
  /**&#13;
   * approve should be called when allowed[_spender] == 0. To increment&#13;
   * allowed value is better to use this function to avoid 2 calls (and wait until &#13;
   * the first transaction is mined)&#13;
   * From MonolithDAO Token.sol&#13;
   */&#13;
  function increaseApproval (address _spender, uint _addedValue) &#13;
    returns (bool success) {&#13;
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);&#13;
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
    return true;&#13;
  }&#13;
&#13;
  function decreaseApproval (address _spender, uint _subtractedValue) &#13;
    returns (bool success) {&#13;
    uint oldValue = allowed[msg.sender][_spender];&#13;
    if (_subtractedValue &gt; oldValue) {&#13;
      allowed[msg.sender][_spender] = 0;&#13;
    } else {&#13;
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);&#13;
    }&#13;
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
    return true;&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Mintable token&#13;
 * @dev Simple ERC20 Token example, with mintable token creation&#13;
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120&#13;
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol&#13;
 */&#13;
&#13;
contract MintableToken is StandardToken, Ownable {&#13;
  event Mint(address indexed to, uint256 amount);&#13;
  event MintFinished();&#13;
&#13;
  bool public mintingFinished = false;&#13;
&#13;
&#13;
  modifier canMint() {&#13;
    require(!mintingFinished);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to mint tokens&#13;
   * @param _to The address that will receive the minted tokens.&#13;
   * @param _amount The amount of tokens to mint.&#13;
   * @return A boolean that indicates if the operation was successful.&#13;
   */&#13;
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {&#13;
    totalSupply = totalSupply.add(_amount);&#13;
    balances[_to] = balances[_to].add(_amount);&#13;
    Mint(_to, _amount);&#13;
    Transfer(0x0, _to, _amount);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to stop minting new tokens.&#13;
   * @return True if the operation was successful.&#13;
   */&#13;
  function finishMinting() onlyOwner returns (bool) {&#13;
    mintingFinished = true;&#13;
    MintFinished();&#13;
    return true;&#13;
  }&#13;
}&#13;
&#13;
//======  MatreXa =====&#13;
&#13;
contract BurnableToken is StandardToken {&#13;
    using SafeMath for uint256;&#13;
&#13;
    event Burn(address indexed from, uint256 amount);&#13;
    event BurnRewardIncreased(address indexed from, uint256 value);&#13;
&#13;
    /**&#13;
    * @dev Sending ether to contract increases burning reward &#13;
    */&#13;
    function() payable {&#13;
        if(msg.value &gt; 0){&#13;
            BurnRewardIncreased(msg.sender, msg.value);    &#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Calculates how much ether one will receive in reward for burning tokens&#13;
     * @param _amount of tokens to be burned&#13;
     */&#13;
    function burnReward(uint256 _amount) public constant returns(uint256){&#13;
        return this.balance.mul(_amount).div(totalSupply);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Burns tokens and send reward&#13;
    * This is internal function because it DOES NOT check &#13;
    * if _from has allowance to burn tokens.&#13;
    * It is intended to be used in transfer() and transferFrom() which do this check.&#13;
    * @param _from The address which you want to burn tokens from&#13;
    * @param _amount of tokens to be burned&#13;
    */&#13;
    function burn(address _from, uint256 _amount) internal returns(bool){&#13;
        require(balances[_from] &gt;= _amount);&#13;
        &#13;
        uint256 reward = burnReward(_amount);&#13;
        assert(this.balance - reward &gt; 0);&#13;
&#13;
        balances[_from] = balances[_from].sub(_amount);&#13;
        totalSupply = totalSupply.sub(_amount);&#13;
        //assert(totalSupply &gt;= 0); //Check is not needed because totalSupply.sub(value) will already throw if this condition is not met&#13;
        &#13;
        _from.transfer(reward);&#13;
        Burn(_from, _amount);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Transfers or burns tokens&#13;
    * Burns tokens transferred to this contract itself or to zero address&#13;
    * @param _to The address to transfer to or token contract address to burn.&#13;
    * @param _value The amount to be transferred.&#13;
    */&#13;
    function transfer(address _to, uint256 _value) returns (bool) {&#13;
        if( (_to == address(this)) || (_to == 0) ){&#13;
            return burn(msg.sender, _value);&#13;
        }else{&#13;
            return super.transfer(_to, _value);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Transfer tokens from one address to another &#13;
    * or burns them if _to is this contract or zero address&#13;
    * @param _from address The address which you want to send tokens from&#13;
    * @param _to address The address which you want to transfer to&#13;
    * @param _value uint256 the amout of tokens to be transfered&#13;
    */&#13;
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {&#13;
        if( (_to == address(this)) || (_to == 0) ){&#13;
            var _allowance = allowed[_from][msg.sender];&#13;
            //require (_value &lt;= _allowance); //Check is not needed because _allowance.sub(_value) will already throw if this condition is not met&#13;
            allowed[_from][msg.sender] = _allowance.sub(_value);&#13;
            return burn(_from, _value);&#13;
        }else{&#13;
            return super.transferFrom(_from, _to, _value);&#13;
        }&#13;
    }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title MatreXa Token&#13;
 */&#13;
contract MatreXaToken is BurnableToken, MintableToken, HasNoContracts, HasNoTokens { //MintableToken is StandardToken, Ownable&#13;
    using SafeMath for uint256;&#13;
&#13;
    string public name = "MatreXa";&#13;
    string public symbol = "MTRX";&#13;
    uint256 public decimals = 18;&#13;
&#13;
    uint256 public allowTransferTimestamp = 0;&#13;
&#13;
    modifier canTransfer() {&#13;
        require(mintingFinished);&#13;
        require(now &gt; allowTransferTimestamp);&#13;
        _;&#13;
    }&#13;
&#13;
    function setAllowTransferTimestamp(uint256 _allowTransferTimestamp) onlyOwner {&#13;
        require(allowTransferTimestamp == 0);&#13;
        allowTransferTimestamp = _allowTransferTimestamp;&#13;
    }&#13;
    &#13;
    function transfer(address _to, uint256 _value) canTransfer returns (bool) {&#13;
        BurnableToken.transfer(_to, _value);&#13;
    }&#13;
&#13;
    function transferFrom(address _from, address _to, uint256 _value) canTransfer returns (bool) {&#13;
        BurnableToken.transferFrom(_from, _to, _value);&#13;
    }&#13;
&#13;
}
pragma solidity ^0.4.18;

/** 
 * DENTIX GLOBAL LIMITED
 * https://dentix.io
 */

// ==== Open Zeppelin library ===

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
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
  function Ownable() public {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title Contracts that should not own Contracts
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="e5978088868aa5d7">[email protected]</span>π.com&gt;&#13;
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
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.&#13;
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
 * @author Remco Bloemen &lt;<span class="__cf_email__" data-cfemail="3a485f5759557a08">[email protected]</span>π.com&gt;&#13;
 * @dev This blocks incoming ERC23 tokens to prevent accidental loss of tokens.&#13;
 * Should tokens (any ERC20Basic compatible) end up in the contract, it allows the&#13;
 * owner to reclaim the tokens.&#13;
 */&#13;
contract HasNoTokens is CanReclaimToken {&#13;
&#13;
 /**&#13;
  * @dev Reject all ERC23 compatible tokens&#13;
  * @param from_ address The address that is transferring the tokens&#13;
  * @param value_ uint256 the amount of the specified token&#13;
  * @param data_ Bytes The data passed from the caller.&#13;
  */&#13;
  function tokenFallback(address from_, uint256 value_, bytes data_) pure external {&#13;
    from_;&#13;
    value_;&#13;
    data_;&#13;
    revert();&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Destructible&#13;
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.&#13;
 */&#13;
contract Destructible is Ownable {&#13;
&#13;
  function Destructible() public payable { }&#13;
&#13;
  /**&#13;
   * @dev Transfers the current balance to the owner and terminates the contract.&#13;
   */&#13;
  function destroy() onlyOwner public {&#13;
    selfdestruct(owner);&#13;
  }&#13;
&#13;
  function destroyAndSend(address _recipient) onlyOwner public {&#13;
    selfdestruct(_recipient);&#13;
  }&#13;
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
  /**&#13;
  * @dev transfer token for a specified address&#13;
  * @param _to The address to transfer to.&#13;
  * @param _value The amount to be transferred.&#13;
  */&#13;
  function transfer(address _to, uint256 _value) public returns (bool) {&#13;
    require(_to != address(0));&#13;
    require(_value &lt;= balances[msg.sender]);&#13;
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
  * @param _owner The address to query the the balance of.&#13;
  * @return An uint256 representing the amount owned by the passed address.&#13;
  */&#13;
  function balanceOf(address _owner) public view returns (uint256 balance) {&#13;
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
  mapping (address =&gt; mapping (address =&gt; uint256)) internal allowed;&#13;
&#13;
&#13;
  /**&#13;
   * @dev Transfer tokens from one address to another&#13;
   * @param _from address The address which you want to send tokens from&#13;
   * @param _to address The address which you want to transfer to&#13;
   * @param _value uint256 the amount of tokens to be transferred&#13;
   */&#13;
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
  /**&#13;
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.&#13;
   *&#13;
   * Beware that changing an allowance with this method brings the risk that someone may use both the old&#13;
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this&#13;
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:&#13;
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _value The amount of tokens to be spent.&#13;
   */&#13;
  function approve(address _spender, uint256 _value) public returns (bool) {&#13;
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
  function allowance(address _owner, address _spender) public view returns (uint256) {&#13;
    return allowed[_owner][_spender];&#13;
  }&#13;
&#13;
  /**&#13;
   * approve should be called when allowed[_spender] == 0. To increment&#13;
   * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * the first transaction is mined)&#13;
   * From MonolithDAO Token.sol&#13;
   */&#13;
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
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {&#13;
    totalSupply = totalSupply.add(_amount);&#13;
    balances[_to] = balances[_to].add(_amount);&#13;
    Mint(_to, _amount);&#13;
    Transfer(address(0), _to, _amount);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to stop minting new tokens.&#13;
   * @return True if the operation was successful.&#13;
   */&#13;
  function finishMinting() onlyOwner canMint public returns (bool) {&#13;
    mintingFinished = true;&#13;
    MintFinished();&#13;
    return true;&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title TokenVesting&#13;
 * @dev A token holder contract that can release its token balance gradually like a&#13;
 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the&#13;
 * owner.&#13;
 */&#13;
contract TokenVesting is Ownable {&#13;
  using SafeMath for uint256;&#13;
  using SafeERC20 for ERC20Basic;&#13;
&#13;
  event Released(uint256 amount);&#13;
  event Revoked();&#13;
&#13;
  // beneficiary of tokens after they are released&#13;
  address public beneficiary;&#13;
&#13;
  uint256 public cliff;&#13;
  uint256 public start;&#13;
  uint256 public duration;&#13;
&#13;
  bool public revocable;&#13;
&#13;
  mapping (address =&gt; uint256) public released;&#13;
  mapping (address =&gt; bool) public revoked;&#13;
&#13;
  /**&#13;
   * @dev Creates a vesting contract that vests its balance of any ERC20 token to the&#13;
   * _beneficiary, gradually in a linear fashion until _start + _duration. By then all&#13;
   * of the balance will have vested.&#13;
   * @param _beneficiary address of the beneficiary to whom vested tokens are transferred&#13;
   * @param _cliff duration in seconds of the cliff in which tokens will begin to vest&#13;
   * @param _duration duration in seconds of the period in which the tokens will vest&#13;
   * @param _revocable whether the vesting is revocable or not&#13;
   */&#13;
  function TokenVesting(address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, bool _revocable) public {&#13;
    require(_beneficiary != address(0));&#13;
    require(_cliff &lt;= _duration);&#13;
&#13;
    beneficiary = _beneficiary;&#13;
    revocable = _revocable;&#13;
    duration = _duration;&#13;
    cliff = _start.add(_cliff);&#13;
    start = _start;&#13;
  }&#13;
&#13;
  /**&#13;
   * @notice Transfers vested tokens to beneficiary.&#13;
   * @param token ERC20 token which is being vested&#13;
   */&#13;
  function release(ERC20Basic token) public {&#13;
    uint256 unreleased = releasableAmount(token);&#13;
&#13;
    require(unreleased &gt; 0);&#13;
&#13;
    released[token] = released[token].add(unreleased);&#13;
&#13;
    token.safeTransfer(beneficiary, unreleased);&#13;
&#13;
    Released(unreleased);&#13;
  }&#13;
&#13;
  /**&#13;
   * @notice Allows the owner to revoke the vesting. Tokens already vested&#13;
   * remain in the contract, the rest are returned to the owner.&#13;
   * @param token ERC20 token which is being vested&#13;
   */&#13;
  function revoke(ERC20Basic token) public onlyOwner {&#13;
    require(revocable);&#13;
    require(!revoked[token]);&#13;
&#13;
    uint256 balance = token.balanceOf(this);&#13;
&#13;
    uint256 unreleased = releasableAmount(token);&#13;
    uint256 refund = balance.sub(unreleased);&#13;
&#13;
    revoked[token] = true;&#13;
&#13;
    token.safeTransfer(owner, refund);&#13;
&#13;
    Revoked();&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Calculates the amount that has already vested but hasn't been released yet.&#13;
   * @param token ERC20 token which is being vested&#13;
   */&#13;
  function releasableAmount(ERC20Basic token) public view returns (uint256) {&#13;
    return vestedAmount(token).sub(released[token]);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Calculates the amount that has already vested.&#13;
   * @param token ERC20 token which is being vested&#13;
   */&#13;
  function vestedAmount(ERC20Basic token) public view returns (uint256) {&#13;
    uint256 currentBalance = token.balanceOf(this);&#13;
    uint256 totalBalance = currentBalance.add(released[token]);&#13;
&#13;
    if (now &lt; cliff) {&#13;
      return 0;&#13;
    } else if (now &gt;= start.add(duration) || revoked[token]) {&#13;
      return totalBalance;&#13;
    } else {&#13;
      return totalBalance.mul(now.sub(start)).div(duration);&#13;
    }&#13;
  }&#13;
}&#13;
&#13;
&#13;
// ==== AALM Contracts ===&#13;
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
    function() public payable {&#13;
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
        Transfer(_from, address(0), _amount);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Transfers or burns tokens&#13;
    * Burns tokens transferred to this contract itself or to zero address&#13;
    * @param _to The address to transfer to or token contract address to burn.&#13;
    * @param _value The amount to be transferred.&#13;
    */&#13;
    function transfer(address _to, uint256 _value) public returns (bool) {&#13;
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
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {&#13;
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
contract DNTXToken is BurnableToken, MintableToken, HasNoContracts, HasNoTokens {&#13;
    string public symbol = 'DNTX';&#13;
    string public name = 'Dentix';&#13;
    uint8 public constant decimals = 18;&#13;
&#13;
    address founder;    //founder address to allow him transfer tokens while minting&#13;
    function init(address _founder) onlyOwner public{&#13;
        founder = _founder;&#13;
    }&#13;
&#13;
    /**&#13;
     * Allow transfer only after crowdsale finished&#13;
     */&#13;
    modifier canTransfer() {&#13;
        require(mintingFinished || msg.sender == founder);&#13;
        _;&#13;
    }&#13;
    &#13;
    function transfer(address _to, uint256 _value) canTransfer public returns (bool) {&#13;
        return BurnableToken.transfer(_to, _value);&#13;
    }&#13;
&#13;
    function transferFrom(address _from, address _to, uint256 _value) canTransfer public returns (bool) {&#13;
        return BurnableToken.transferFrom(_from, _to, _value);&#13;
    }&#13;
}&#13;
&#13;
contract DNTXCrowdsale is Ownable, Destructible {&#13;
    using SafeMath for uint256;&#13;
    &#13;
    uint8 private constant PERCENT_DIVIDER = 100;              &#13;
&#13;
    event SpecialMint(address beneficiary, uint256 amount, string description);&#13;
&#13;
    enum State { NotStarted, PreICO, ICO, Finished }&#13;
    State public state;         //Current contract state                     &#13;
&#13;
    struct ICOBonus {&#13;
        uint32 expire;       //timestamp of date when this bonus expires (purshases before this time will use the bonus)&#13;
        uint8 percent;&#13;
    }&#13;
    ICOBonus[] public icoBonuses;    //Array of ICO bonuses&#13;
&#13;
    uint256 public baseRate;           //how many DNTX one will get for 1 ETH during main sale without bonus&#13;
    uint8   public preICOBonusPercent; //Pre-ICO bonus percent&#13;
    uint32  public icoStartTimestamp;  //timestamp of ICO start&#13;
    uint32  public icoEndTimestamp;    //timestamp of ICO end&#13;
    uint256 public icoGoal;            //How much ether we need to collect to assume ICO is successfull&#13;
    uint256 public hardCap;            //Max amount possibly collected&#13;
&#13;
    DNTXToken public token;                                 &#13;
&#13;
    uint256 public icoCollected;&#13;
    uint256 public totalCollected;&#13;
    mapping(address =&gt; uint256) public icoContributions; //amount of ether received from an investor during ICO&#13;
&#13;
    function DNTXCrowdsale() public{&#13;
        state = State.NotStarted;&#13;
        token = new DNTXToken();&#13;
        token.init(owner);&#13;
    }   &#13;
&#13;
    function() public payable {&#13;
        require(msg.value &gt; 0);&#13;
        require(isOpen());&#13;
&#13;
        totalCollected = totalCollected.add(msg.value);&#13;
        if(state == State.ICO){&#13;
            require(totalCollected &lt;= hardCap);&#13;
            icoCollected = icoCollected.add(msg.value);&#13;
            icoContributions[msg.sender] = icoContributions[msg.sender].add(msg.value);&#13;
        }&#13;
&#13;
        uint256 rate = currentRate();&#13;
        assert(rate &gt; 0);&#13;
&#13;
        uint256 amount = rate.mul(msg.value);&#13;
        assert(token.mint(msg.sender, amount));&#13;
    }&#13;
&#13;
    function mintTokens(address beneficiary, uint256 amount, string description) onlyOwner public {&#13;
        assert(token.mint(beneficiary, amount));&#13;
        SpecialMint(beneficiary, amount, description);&#13;
    }&#13;
&#13;
&#13;
    function isOpen() view public returns(bool){&#13;
        if(baseRate == 0) return false;&#13;
        if(state == State.NotStarted || state == State.Finished) return false;&#13;
        if(state == State.PreICO) return true;&#13;
        if(state == State.ICO){&#13;
            if(totalCollected &gt;= hardCap) return false;&#13;
            return (icoStartTimestamp &lt;= now) &amp;&amp; (now &lt;= icoEndTimestamp);&#13;
        }&#13;
    }&#13;
    function currentRate() view public returns(uint256){&#13;
        if(state == State.PreICO) {&#13;
            return baseRate.add( baseRate.mul(preICOBonusPercent).div(PERCENT_DIVIDER) );&#13;
        }else if(state == State.ICO){&#13;
            for(uint8 i=0; i &lt; icoBonuses.length; i++){&#13;
                ICOBonus storage b = icoBonuses[i];&#13;
                if(now &lt;= b.expire){&#13;
                    return baseRate.add( baseRate.mul(b.percent).div(PERCENT_DIVIDER) );&#13;
                }&#13;
            }&#13;
            return baseRate;&#13;
        }else{&#13;
            return 0;&#13;
        }&#13;
    }&#13;
&#13;
    function setBaseRate(uint256 rate) onlyOwner public {&#13;
        require(state != State.ICO &amp;&amp; state != State.Finished);&#13;
        baseRate = rate;&#13;
    }&#13;
    function setPreICOBonus(uint8 percent) onlyOwner public {&#13;
        preICOBonusPercent = percent;&#13;
    }&#13;
    function setupAndStartPreICO(uint256 rate, uint8 percent) onlyOwner external {&#13;
        setBaseRate(rate);&#13;
        setPreICOBonus(percent);&#13;
        startPreICO();&#13;
    }&#13;
&#13;
    function setupICO(uint32 startTimestamp, uint32 endTimestamp, uint256 goal, uint256 cap, uint32[] expires, uint8[] percents) onlyOwner external {&#13;
        require(state != State.ICO &amp;&amp; state != State.Finished);&#13;
        icoStartTimestamp = startTimestamp;&#13;
        icoEndTimestamp = endTimestamp;&#13;
        icoGoal = goal;&#13;
        hardCap = cap;&#13;
&#13;
        require(expires.length == percents.length);&#13;
        uint32 prevExpire;&#13;
        for(uint8 i=0;  i &lt; expires.length; i++){&#13;
            require(prevExpire &lt; expires[i]);&#13;
            icoBonuses.push(ICOBonus({expire:expires[i], percent:percents[i]}));&#13;
            prevExpire = expires[i];&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Start PreICO stage&#13;
    */&#13;
    function startPreICO() onlyOwner public {&#13;
        require(state == State.NotStarted);&#13;
        require(baseRate != 0);&#13;
        state = State.PreICO;&#13;
    }&#13;
    /**&#13;
    * @notice Finish PreICO stage and start ICO (after time comes)&#13;
    */&#13;
    function finishPreICO() onlyOwner external {&#13;
        require(state == State.PreICO);&#13;
        require(icoStartTimestamp != 0 &amp;&amp; icoEndTimestamp != 0);&#13;
        state = State.ICO;&#13;
    }&#13;
    /**&#13;
    * @notice Close crowdsale, finish minting (allowing token transfers), transfers token ownership to the founder&#13;
    */&#13;
    function finalizeCrowdsale() onlyOwner external {&#13;
        state = State.Finished;&#13;
        token.finishMinting();&#13;
        token.transferOwnership(owner);&#13;
        if(icoCollected &gt;= icoGoal &amp;&amp; this.balance &gt; 0) {&#13;
            claimEther();&#13;
        }&#13;
    }&#13;
    /**&#13;
    * @notice Claim collected ether without closing crowdsale&#13;
    */&#13;
    function claimEther() onlyOwner public {&#13;
        require(state == State.PreICO || icoCollected &gt;= icoGoal);&#13;
        require(this.balance &gt; 0);&#13;
        owner.transfer(this.balance);&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Sends all contributed ether back if minimum cap is not reached by the end of crowdsale&#13;
    */&#13;
    function refund() public returns(bool){&#13;
        return refundTo(msg.sender);&#13;
    }&#13;
    function refundTo(address beneficiary) public returns(bool) {&#13;
        require(icoCollected &lt; icoGoal);&#13;
        require(icoContributions[beneficiary] &gt; 0);&#13;
        require( (state == State.Finished) || (state == State.ICO &amp;&amp; (now &gt; icoEndTimestamp)) );&#13;
&#13;
        uint256 _refund = icoContributions[beneficiary];&#13;
        icoContributions[beneficiary] = 0;&#13;
        beneficiary.transfer(_refund);&#13;
        return true;&#13;
    }&#13;
&#13;
}
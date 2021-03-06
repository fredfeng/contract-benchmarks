pragma solidity ^0.4.18;

// File: zeppelin-solidity/contracts/math/SafeMath.sol

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

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: zeppelin-solidity/contracts/token/ERC20Basic.sol

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

// File: zeppelin-solidity/contracts/token/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

// File: zeppelin-solidity/contracts/token/ERC20.sol

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

// File: zeppelin-solidity/contracts/token/StandardToken.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: zeppelin-solidity/contracts/token/MintableToken.sol

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

// File: contracts/Crowdsale.sol

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.

 * this contract is slightly modified from original zeppelin version to 
 * enable testing mode and not forward to fundraiser address on every payment
 */
contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  MintableToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  address public wallet;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != address(0));

    token = createTokenContract();
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }

  // fallback function can be used to buy tokens
  function () external payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }

}

// File: contracts/CappedCrowdsale.sol

/**
 * @title CappedCrowdsale
 * @dev Extension of Crowdsale with a max amount of funds raised

 * this contract was kept the same as the original zeppelin version
 * only change was to inheriet the modified crowdsale instead of the
 * original one
 */
contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  function CappedCrowdsale(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal view returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}

// File: zeppelin-solidity/contracts/lifecycle/TokenDestructible.sol

/**
 * @title TokenDestructible:
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="3240575f515d7200">[email protected]</span>π.com&gt;&#13;
 * @dev Base contract that can be destroyed by owner. All funds in contract including&#13;
 * listed tokens will be sent to the owner.&#13;
 */&#13;
contract TokenDestructible is Ownable {&#13;
&#13;
  function TokenDestructible() public payable { }&#13;
&#13;
  /**&#13;
   * @notice Terminate contract and refund to owner&#13;
   * @param tokens List of addresses of ERC20 or ERC20Basic token contracts to&#13;
   refund.&#13;
   * @notice The called token contracts could try to re-enter this contract. Only&#13;
   supply token contracts you trust.&#13;
   */&#13;
  function destroy(address[] tokens) onlyOwner public {&#13;
&#13;
    // Transfer tokens to owner&#13;
    for(uint256 i = 0; i &lt; tokens.length; i++) {&#13;
      ERC20Basic token = ERC20Basic(tokens[i]);&#13;
      uint256 balance = token.balanceOf(this);&#13;
      token.transfer(owner, balance);&#13;
    }&#13;
&#13;
    // Transfer Eth to owner and terminate contract&#13;
    selfdestruct(owner);&#13;
  }&#13;
}&#13;
&#13;
// File: contracts/SpecialRatedCrowdsale.sol&#13;
&#13;
/**&#13;
 * SpecialRatedCrowdsale contract&#13;
&#13;
 * donors putting in more than a certain number of ethers will receive a special rate&#13;
 */&#13;
contract SpecialRatedCrowdsale is Crowdsale, TokenDestructible {&#13;
  mapping(address =&gt; uint) addressToSpecialRates;&#13;
&#13;
  function SpecialRatedCrowdsale() { }&#13;
&#13;
  function addToSpecialRatesMapping(address _address, uint specialRate) onlyOwner public {&#13;
    addressToSpecialRates[_address] = specialRate;&#13;
  }&#13;
&#13;
  function removeFromSpecialRatesMapping(address _address) onlyOwner public {&#13;
    delete addressToSpecialRates[_address];&#13;
  }&#13;
&#13;
  function querySpecialRateForAddress(address _address) onlyOwner public returns(uint) {&#13;
    return addressToSpecialRates[_address];&#13;
  }&#13;
&#13;
  function buyTokens(address beneficiary) public payable {&#13;
    if (addressToSpecialRates[beneficiary] != 0) {&#13;
      rate = addressToSpecialRates[beneficiary];&#13;
    }&#13;
&#13;
    super.buyTokens(beneficiary);&#13;
  }&#13;
}&#13;
&#13;
// File: contracts/ERC223ReceivingContract.sol&#13;
&#13;
/**&#13;
 * @title Contract that will work with ERC223 tokens.&#13;
**/&#13;
 &#13;
contract ERC223ReceivingContract { &#13;
&#13;
  /**&#13;
    * @dev Standard ERC223 function that will handle incoming token transfers.&#13;
    *&#13;
    * @param _from  Token sender address.&#13;
    * @param _value Amount of tokens.&#13;
    * @param _data  Transaction metadata.&#13;
  */&#13;
  function tokenFallback(address _from, uint _value, bytes _data);&#13;
&#13;
}&#13;
&#13;
// File: contracts/ERC223.sol&#13;
&#13;
contract ERC223 is BasicToken {&#13;
&#13;
  function transfer(address _to, uint _value, bytes _data) public returns (bool) {&#13;
    super.transfer(_to, _value);&#13;
&#13;
    // Standard function transfer similar to ERC20 transfer with no _data .&#13;
    // Added due to backwards compatibility reasons .&#13;
    uint codeLength;&#13;
&#13;
    assembly {&#13;
      // Retrieve the size of the code on target address, this needs assembly .&#13;
      codeLength := extcodesize(_to)&#13;
    }&#13;
    if (codeLength &gt; 0) {&#13;
      ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);&#13;
      receiver.tokenFallback(msg.sender, _value, _data);&#13;
    }&#13;
    Transfer(msg.sender, _to, _value, _data);&#13;
  }&#13;
&#13;
  function transfer(address _to, uint _value) public returns (bool) {&#13;
    super.transfer(_to, _value);&#13;
&#13;
    // Standard function transfer similar to ERC20 transfer with no _data .&#13;
    // Added due to backwards compatibility reasons .&#13;
    uint codeLength;&#13;
    bytes memory empty;&#13;
&#13;
    assembly {&#13;
      // Retrieve the size of the code on target address, this needs assembly .&#13;
      codeLength := extcodesize(_to)&#13;
    }&#13;
    if (codeLength &gt; 0) {&#13;
      ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);&#13;
      receiver.tokenFallback(msg.sender, _value, empty);&#13;
    }&#13;
    Transfer(msg.sender, _to, _value, empty);&#13;
  }&#13;
&#13;
  event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);&#13;
}&#13;
&#13;
// File: zeppelin-solidity/contracts/token/CappedToken.sol&#13;
&#13;
/**&#13;
 * @title Capped token&#13;
 * @dev Mintable token with a token cap.&#13;
 */&#13;
&#13;
contract CappedToken is MintableToken {&#13;
&#13;
  uint256 public cap;&#13;
&#13;
  function CappedToken(uint256 _cap) public {&#13;
    require(_cap &gt; 0);&#13;
    cap = _cap;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to mint tokens&#13;
   * @param _to The address that will receive the minted tokens.&#13;
   * @param _amount The amount of tokens to mint.&#13;
   * @return A boolean that indicates if the operation was successful.&#13;
   */&#13;
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {&#13;
    require(totalSupply.add(_amount) &lt;= cap);&#13;
&#13;
    return super.mint(_to, _amount);&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: zeppelin-solidity/contracts/lifecycle/Pausable.sol&#13;
&#13;
/**&#13;
 * @title Pausable&#13;
 * @dev Base contract which allows children to implement an emergency stop mechanism.&#13;
 */&#13;
contract Pausable is Ownable {&#13;
  event Pause();&#13;
  event Unpause();&#13;
&#13;
  bool public paused = false;&#13;
&#13;
&#13;
  /**&#13;
   * @dev Modifier to make a function callable only when the contract is not paused.&#13;
   */&#13;
  modifier whenNotPaused() {&#13;
    require(!paused);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Modifier to make a function callable only when the contract is paused.&#13;
   */&#13;
  modifier whenPaused() {&#13;
    require(paused);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev called by the owner to pause, triggers stopped state&#13;
   */&#13;
  function pause() onlyOwner whenNotPaused public {&#13;
    paused = true;&#13;
    Pause();&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev called by the owner to unpause, returns to normal state&#13;
   */&#13;
  function unpause() onlyOwner whenPaused public {&#13;
    paused = false;&#13;
    Unpause();&#13;
  }&#13;
}&#13;
&#13;
// File: zeppelin-solidity/contracts/token/PausableToken.sol&#13;
&#13;
/**&#13;
 * @title Pausable token&#13;
 *&#13;
 * @dev StandardToken modified with pausable transfers.&#13;
 **/&#13;
&#13;
contract PausableToken is StandardToken, Pausable {&#13;
&#13;
  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {&#13;
    return super.transfer(_to, _value);&#13;
  }&#13;
&#13;
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {&#13;
    return super.transferFrom(_from, _to, _value);&#13;
  }&#13;
&#13;
  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {&#13;
    return super.approve(_spender, _value);&#13;
  }&#13;
&#13;
  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {&#13;
    return super.increaseApproval(_spender, _addedValue);&#13;
  }&#13;
&#13;
  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {&#13;
    return super.decreaseApproval(_spender, _subtractedValue);&#13;
  }&#13;
}&#13;
&#13;
// File: contracts/YoloToken.sol&#13;
&#13;
/** @title YoloToken - Token for the UltraYOLO lottery protocol&#13;
  * @author UltraYOLO&#13;
&#13;
  The totalSupply for YOLO token will be 4 Billion&#13;
**/&#13;
&#13;
contract YoloToken is CappedToken, PausableToken, ERC223 {&#13;
&#13;
  string public constant name     = "Yolo";&#13;
  string public constant symbol   = "YOLO";&#13;
  uint   public constant decimals = 18;&#13;
&#13;
  function YoloToken(uint256 _totalSupply) CappedToken(_totalSupply) {&#13;
    paused = true;&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: contracts/YoloTokenPresaleRound2.sol&#13;
&#13;
/**&#13;
 * @title YoloTokenPresaleRound2&#13;
 * @author UltraYOLO&#13;
 &#13;
 * Based on widely-adopted OpenZepplin project&#13;
 * A total of 200,000,000 YOLO tokens will be sold during presale at a discount rate of 25%&#13;
 * Supporters who purchase more than 10 ETH worth of YOLO token will have a discount of 35%&#13;
 * Total supply of presale + presale_round_2 + mainsale will be 2,000,000,000&#13;
*/&#13;
contract YoloTokenPresaleRound2 is SpecialRatedCrowdsale, CappedCrowdsale, Pausable {&#13;
  using SafeMath for uint256;&#13;
&#13;
  uint256 public rateTierHigher;&#13;
  uint256 public rateTierNormal;&#13;
&#13;
  function YoloTokenPresaleRound2 (uint256 _cap, uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet,&#13;
  	address _tokenAddress) &#13;
  CappedCrowdsale(_cap)&#13;
  Crowdsale(_startTime, _endTime, _rate, _wallet)&#13;
  {&#13;
    token = YoloToken(_tokenAddress);&#13;
    rateTierHigher = _rate.mul(27).div(20);&#13;
    rateTierNormal = _rate.mul(5).div(4);&#13;
  }&#13;
&#13;
  function () external payable {&#13;
    buyTokens(msg.sender);&#13;
  }&#13;
&#13;
  function buyTokens(address beneficiary) public payable {&#13;
    require(validPurchase());&#13;
    if (msg.value &gt;= 10 ether) {&#13;
      rate = rateTierHigher;&#13;
    } else {&#13;
      rate = rateTierNormal;&#13;
    }&#13;
    super.buyTokens(beneficiary);&#13;
  }&#13;
&#13;
  function validPurchase() internal view returns (bool) {&#13;
    return super.validPurchase() &amp;&amp; !paused;&#13;
  }&#13;
&#13;
  function setCap(uint256 _cap) onlyOwner public {&#13;
    cap = _cap;&#13;
  }&#13;
&#13;
  function setStartTime(uint256 _startTime) onlyOwner public {&#13;
    startTime = _startTime;&#13;
  }&#13;
&#13;
  function setEndTime(uint256 _endTime) onlyOwner public {&#13;
    endTime = _endTime;&#13;
  }&#13;
&#13;
  function setRate(uint256 _rate) onlyOwner public {&#13;
    rate = _rate;&#13;
    rateTierHigher = _rate.mul(27).div(20);&#13;
    rateTierNormal = _rate.mul(5).div(4);&#13;
  }&#13;
&#13;
  function setWallet(address _wallet) onlyOwner public {&#13;
    wallet = _wallet;&#13;
  }&#13;
&#13;
  function withdrawFunds(uint256 amount) onlyOwner public {&#13;
    wallet.transfer(amount);&#13;
  }&#13;
&#13;
  function resetTokenOwnership() onlyOwner public {&#13;
    token.transferOwnership(owner);&#13;
  }&#13;
&#13;
}
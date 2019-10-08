/**
 * @title TEND token
 * @version 2.0
 * @author Validity Labs AG <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ef86818980af998e83868b869b96838e8d9cc1809d88">[email protected]</a>&gt;&#13;
 *&#13;
 * The TTA tokens are issued as participation certificates and represent&#13;
 * uncertificated securities within the meaning of article 973c Swiss CO. The&#13;
 * issuance of the TTA tokens has been governed by a prospectus issued by&#13;
 * Tend Technologies AG.&#13;
 *&#13;
 * TTA tokens are only recognized and transferable in undivided units.&#13;
 *&#13;
 * The holder of a TTA token must prove his possessorship to be recognized by&#13;
 * the issuer as being entitled to the rights arising out of the respective&#13;
 * participation certificate; he/she waives any rights if he/she is not in a&#13;
 * position to prove him/her being the holder of the respective token.&#13;
 *&#13;
 * Similarly, only the person who proves him/her being the holder of the TTA&#13;
 * Token is entitled to transfer title and ownership on the token to another&#13;
 * person. Both the transferor and the transferee agree and accept hereby&#13;
 * explicitly that the tokens are transferred digitally, i.e. in a form-free&#13;
 * manner. However, if any regulators, courts or similar would require written&#13;
 * confirmation of a transfer of the transferable uncertificated securities&#13;
 * from one investor to another investor, such investors will provide written&#13;
 * evidence of such transfer.&#13;
 */&#13;
pragma solidity ^0.4.24;&#13;
&#13;
/**&#13;
 * @title Ownable&#13;
 * @dev The Ownable contract has an owner address, and provides basic authorization control&#13;
 * functions, this simplifies the implementation of "user permissions".&#13;
 */&#13;
contract Ownable {&#13;
  address public owner;&#13;
&#13;
&#13;
  event OwnershipRenounced(address indexed previousOwner);&#13;
  event OwnershipTransferred(&#13;
    address indexed previousOwner,&#13;
    address indexed newOwner&#13;
  );&#13;
&#13;
&#13;
  /**&#13;
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender&#13;
   * account.&#13;
   */&#13;
  constructor() public {&#13;
    owner = msg.sender;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Throws if called by any account other than the owner.&#13;
   */&#13;
  modifier onlyOwner() {&#13;
    require(msg.sender == owner);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows the current owner to relinquish control of the contract.&#13;
   */&#13;
  function renounceOwnership() public onlyOwner {&#13;
    emit OwnershipRenounced(owner);&#13;
    owner = address(0);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows the current owner to transfer control of the contract to a newOwner.&#13;
   * @param _newOwner The address to transfer ownership to.&#13;
   */&#13;
  function transferOwnership(address _newOwner) public onlyOwner {&#13;
    _transferOwnership(_newOwner);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Transfers control of the contract to a newOwner.&#13;
   * @param _newOwner The address to transfer ownership to.&#13;
   */&#13;
  function _transferOwnership(address _newOwner) internal {&#13;
    require(_newOwner != address(0));&#13;
    emit OwnershipTransferred(owner, _newOwner);&#13;
    owner = _newOwner;&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title SafeMath&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
library SafeMath {&#13;
&#13;
  /**&#13;
  * @dev Multiplies two numbers, throws on overflow.&#13;
  */&#13;
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {&#13;
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the&#13;
    // benefit is lost if 'b' is also tested.&#13;
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522&#13;
    if (a == 0) {&#13;
      return 0;&#13;
    }&#13;
&#13;
    c = a * b;&#13;
    assert(c / a == b);&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Integer division of two numbers, truncating the quotient.&#13;
  */&#13;
  function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    // uint256 c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
    return a / b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).&#13;
  */&#13;
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Adds two numbers, throws on overflow.&#13;
  */&#13;
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {&#13;
    c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title ERC20Basic&#13;
 * @dev Simpler version of ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/179&#13;
 */&#13;
contract ERC20Basic {&#13;
  function totalSupply() public view returns (uint256);&#13;
  function balanceOf(address who) public view returns (uint256);&#13;
  function transfer(address to, uint256 value) public returns (bool);&#13;
  event Transfer(address indexed from, address indexed to, uint256 value);&#13;
}&#13;
&#13;
/**&#13;
 * @title ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/20&#13;
 */&#13;
contract ERC20 is ERC20Basic {&#13;
  function allowance(address owner, address spender)&#13;
    public view returns (uint256);&#13;
&#13;
  function transferFrom(address from, address to, uint256 value)&#13;
    public returns (bool);&#13;
&#13;
  function approve(address spender, uint256 value) public returns (bool);&#13;
  event Approval(&#13;
    address indexed owner,&#13;
    address indexed spender,&#13;
    uint256 value&#13;
  );&#13;
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
  uint256 totalSupply_;&#13;
&#13;
  /**&#13;
  * @dev total number of tokens in existence&#13;
  */&#13;
  function totalSupply() public view returns (uint256) {&#13;
    return totalSupply_;&#13;
  }&#13;
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
    balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    emit Transfer(msg.sender, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Gets the balance of the specified address.&#13;
  * @param _owner The address to query the the balance of.&#13;
  * @return An uint256 representing the amount owned by the passed address.&#13;
  */&#13;
  function balanceOf(address _owner) public view returns (uint256) {&#13;
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
  function transferFrom(&#13;
    address _from,&#13;
    address _to,&#13;
    uint256 _value&#13;
  )&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
    require(_to != address(0));&#13;
    require(_value &lt;= balances[_from]);&#13;
    require(_value &lt;= allowed[_from][msg.sender]);&#13;
&#13;
    balances[_from] = balances[_from].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
    emit Transfer(_from, _to, _value);&#13;
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
    emit Approval(msg.sender, _spender, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to check the amount of tokens that an owner allowed to a spender.&#13;
   * @param _owner address The address which owns the funds.&#13;
   * @param _spender address The address which will spend the funds.&#13;
   * @return A uint256 specifying the amount of tokens still available for the spender.&#13;
   */&#13;
  function allowance(&#13;
    address _owner,&#13;
    address _spender&#13;
   )&#13;
    public&#13;
    view&#13;
    returns (uint256)&#13;
  {&#13;
    return allowed[_owner][_spender];&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Increase the amount of tokens that an owner allowed to a spender.&#13;
   *&#13;
   * approve should be called when allowed[_spender] == 0. To increment&#13;
   * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * the first transaction is mined)&#13;
   * From MonolithDAO Token.sol&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _addedValue The amount of tokens to increase the allowance by.&#13;
   */&#13;
  function increaseApproval(&#13;
    address _spender,&#13;
    uint _addedValue&#13;
  )&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
    allowed[msg.sender][_spender] = (&#13;
      allowed[msg.sender][_spender].add(_addedValue));&#13;
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Decrease the amount of tokens that an owner allowed to a spender.&#13;
   *&#13;
   * approve should be called when allowed[_spender] == 0. To decrement&#13;
   * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * the first transaction is mined)&#13;
   * From MonolithDAO Token.sol&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _subtractedValue The amount of tokens to decrease the allowance by.&#13;
   */&#13;
  function decreaseApproval(&#13;
    address _spender,&#13;
    uint _subtractedValue&#13;
  )&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
    uint oldValue = allowed[msg.sender][_spender];&#13;
    if (_subtractedValue &gt; oldValue) {&#13;
      allowed[msg.sender][_spender] = 0;&#13;
    } else {&#13;
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);&#13;
    }&#13;
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
    return true;&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Mintable token&#13;
 * @dev Simple ERC20 Token example, with mintable token creation&#13;
 * @dev Issue: * https://github.com/OpenZeppelin/openzeppelin-solidity/issues/120&#13;
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol&#13;
 */&#13;
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
  modifier hasMintPermission() {&#13;
    require(msg.sender == owner);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to mint tokens&#13;
   * @param _to The address that will receive the minted tokens.&#13;
   * @param _amount The amount of tokens to mint.&#13;
   * @return A boolean that indicates if the operation was successful.&#13;
   */&#13;
  function mint(&#13;
    address _to,&#13;
    uint256 _amount&#13;
  )&#13;
    hasMintPermission&#13;
    canMint&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
    totalSupply_ = totalSupply_.add(_amount);&#13;
    balances[_to] = balances[_to].add(_amount);&#13;
    emit Mint(_to, _amount);&#13;
    emit Transfer(address(0), _to, _amount);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to stop minting new tokens.&#13;
   * @return True if the operation was successful.&#13;
   */&#13;
  function finishMinting() onlyOwner canMint public returns (bool) {&#13;
    mintingFinished = true;&#13;
    emit MintFinished();&#13;
    return true;&#13;
  }&#13;
}&#13;
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
    emit Pause();&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev called by the owner to unpause, returns to normal state&#13;
   */&#13;
  function unpause() onlyOwner whenPaused public {&#13;
    paused = false;&#13;
    emit Unpause();&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title Pausable token&#13;
 * @dev StandardToken modified with pausable transfers.&#13;
 **/&#13;
contract PausableToken is StandardToken, Pausable {&#13;
&#13;
  function transfer(&#13;
    address _to,&#13;
    uint256 _value&#13;
  )&#13;
    public&#13;
    whenNotPaused&#13;
    returns (bool)&#13;
  {&#13;
    return super.transfer(_to, _value);&#13;
  }&#13;
&#13;
  function transferFrom(&#13;
    address _from,&#13;
    address _to,&#13;
    uint256 _value&#13;
  )&#13;
    public&#13;
    whenNotPaused&#13;
    returns (bool)&#13;
  {&#13;
    return super.transferFrom(_from, _to, _value);&#13;
  }&#13;
&#13;
  function approve(&#13;
    address _spender,&#13;
    uint256 _value&#13;
  )&#13;
    public&#13;
    whenNotPaused&#13;
    returns (bool)&#13;
  {&#13;
    return super.approve(_spender, _value);&#13;
  }&#13;
&#13;
  function increaseApproval(&#13;
    address _spender,&#13;
    uint _addedValue&#13;
  )&#13;
    public&#13;
    whenNotPaused&#13;
    returns (bool success)&#13;
  {&#13;
    return super.increaseApproval(_spender, _addedValue);&#13;
  }&#13;
&#13;
  function decreaseApproval(&#13;
    address _spender,&#13;
    uint _subtractedValue&#13;
  )&#13;
    public&#13;
    whenNotPaused&#13;
    returns (bool success)&#13;
  {&#13;
    return super.decreaseApproval(_spender, _subtractedValue);&#13;
  }&#13;
}&#13;
&#13;
contract DividendToken is StandardToken, Ownable {&#13;
    using SafeMath for uint256;&#13;
&#13;
    // time before dividendEndTime during which dividend cannot be claimed by token holders&#13;
    // instead the unclaimed dividend can be claimed by treasury in that time span&#13;
    uint256 public claimTimeout = 20 days;&#13;
&#13;
    uint256 public dividendCycleTime = 350 days;&#13;
&#13;
    uint256 public currentDividend;&#13;
&#13;
    mapping(address =&gt; uint256) unclaimedDividend;&#13;
&#13;
    // tracks when the dividend balance has been updated last time&#13;
    mapping(address =&gt; uint256) public lastUpdate;&#13;
&#13;
    uint256 public lastDividendIncreaseDate;&#13;
&#13;
    // allow payment of dividend only by special treasury account (treasury can be set and altered by owner,&#13;
    // multiple treasurer accounts are possible&#13;
    mapping(address =&gt; bool) public isTreasurer;&#13;
&#13;
    uint256 public dividendEndTime = 0;&#13;
&#13;
    event Payin(address _owner, uint256 _value, uint256 _endTime);&#13;
&#13;
    event Payout(address _tokenHolder, uint256 _value);&#13;
&#13;
    event Reclaimed(uint256 remainingBalance, uint256 _endTime, uint256 _now);&#13;
&#13;
    event ChangedTreasurer(address treasurer, bool active);&#13;
&#13;
    /**&#13;
     * @dev Deploy the DividendToken contract and set the owner of the contract&#13;
     */&#13;
    constructor() public {&#13;
        isTreasurer[owner] = true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Request payout dividend (claim) (requested by tokenHolder -&gt; pull)&#13;
     * dividends that have not been claimed within 330 days expire and cannot be claimed anymore by the token holder.&#13;
     */&#13;
    function claimDividend() public returns (bool) {&#13;
        // unclaimed dividend fractions should expire after 330 days and the owner can reclaim that fraction&#13;
        require(dividendEndTime &gt; 0);&#13;
        require(dividendEndTime.sub(claimTimeout) &gt; block.timestamp);&#13;
&#13;
        updateDividend(msg.sender);&#13;
&#13;
        uint256 payment = unclaimedDividend[msg.sender];&#13;
        unclaimedDividend[msg.sender] = 0;&#13;
&#13;
        msg.sender.transfer(payment);&#13;
&#13;
        // Trigger payout event&#13;
        emit Payout(msg.sender, payment);&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Transfer dividend (fraction) to new token holder&#13;
     * @param _from address The address of the old token holder&#13;
     * @param _to address The address of the new token holder&#13;
     * @param _value uint256 Number of tokens to transfer&#13;
     */&#13;
    function transferDividend(address _from, address _to, uint256 _value) internal {&#13;
        updateDividend(_from);&#13;
        updateDividend(_to);&#13;
&#13;
        uint256 transAmount = unclaimedDividend[_from].mul(_value).div(balanceOf(_from));&#13;
&#13;
        unclaimedDividend[_from] = unclaimedDividend[_from].sub(transAmount);&#13;
        unclaimedDividend[_to] = unclaimedDividend[_to].add(transAmount);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Update the dividend of hodler&#13;
     * @param _hodler address The Address of the hodler&#13;
     */&#13;
    function updateDividend(address _hodler) internal {&#13;
        // last update in previous period -&gt; reset claimable dividend&#13;
        if (lastUpdate[_hodler] &lt; lastDividendIncreaseDate) {&#13;
            unclaimedDividend[_hodler] = calcDividend(_hodler, totalSupply_);&#13;
            lastUpdate[_hodler] = block.timestamp;&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Get claimable dividend for the hodler&#13;
     * @param _hodler address The Address of the hodler&#13;
     */&#13;
    function getClaimableDividend(address _hodler) public constant returns (uint256 claimableDividend) {&#13;
        if (lastUpdate[_hodler] &lt; lastDividendIncreaseDate) {&#13;
            return calcDividend(_hodler, totalSupply_);&#13;
        } else {&#13;
            return (unclaimedDividend[_hodler]);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Overrides transfer method from BasicToken&#13;
     * transfer token for a specified address&#13;
     * @param _to address The address to transfer to.&#13;
     * @param _value uint256 The amount to be transferred.&#13;
     */&#13;
    function transfer(address _to, uint256 _value) public returns (bool) {&#13;
        transferDividend(msg.sender, _to, _value);&#13;
&#13;
        // Return from inherited transfer method&#13;
        return super.transfer(_to, _value);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Transfer tokens from one address to another&#13;
     * @param _from address The address which you want to send tokens from&#13;
     * @param _to address The address which you want to transfer to&#13;
     * @param _value uint256 the amount of tokens to be transferred&#13;
     */&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {&#13;
        // Prevent dividend to be claimed twice&#13;
        transferDividend(_from, _to, _value);&#13;
&#13;
        // Return from inherited transferFrom method&#13;
        return super.transferFrom(_from, _to, _value);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Set / alter treasurer "account". This can be done from owner only&#13;
     * @param _treasurer address Address of the treasurer to create/alter&#13;
     * @param _active bool Flag that shows if the treasurer account is active&#13;
     */&#13;
    function setTreasurer(address _treasurer, bool _active) public onlyOwner {&#13;
        isTreasurer[_treasurer] = _active;&#13;
        emit ChangedTreasurer(_treasurer, _active);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Request unclaimed ETH, payback to beneficiary (owner) wallet&#13;
     * dividend payment is possible every 330 days at the earliest - can be later, this allows for some flexibility,&#13;
     * e.g. board meeting had to happen a bit earlier this year than previous year.&#13;
     */&#13;
    function requestUnclaimed() public onlyOwner {&#13;
        // Send remaining ETH to beneficiary (back to owner) if dividend round is over&#13;
        require(block.timestamp &gt;= dividendEndTime.sub(claimTimeout));&#13;
&#13;
        msg.sender.transfer(address(this).balance);&#13;
&#13;
        emit Reclaimed(address(this).balance, dividendEndTime, block.timestamp);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev ETH Payin for Treasurer&#13;
     * Only owner or treasurer can do a payin for all token holder.&#13;
     * Owner / treasurer can also increase dividend by calling fallback function multiple times.&#13;
     */&#13;
    function() public payable {&#13;
        require(isTreasurer[msg.sender]);&#13;
        require(dividendEndTime &lt; block.timestamp);&#13;
&#13;
        // pay back unclaimed dividend that might not have been claimed by owner yet&#13;
        if (address(this).balance &gt; msg.value) {&#13;
            uint256 payout = address(this).balance.sub(msg.value);&#13;
            owner.transfer(payout);&#13;
            emit Reclaimed(payout, dividendEndTime, block.timestamp);&#13;
        }&#13;
&#13;
        currentDividend = address(this).balance;&#13;
&#13;
        // No active dividend cycle found, initialize new round&#13;
        dividendEndTime = block.timestamp.add(dividendCycleTime);&#13;
&#13;
        // Trigger payin event&#13;
        emit Payin(msg.sender, msg.value, dividendEndTime);&#13;
&#13;
        lastDividendIncreaseDate = block.timestamp;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev calculate the dividend&#13;
     * @param _hodler address&#13;
     * @param _totalSupply uint256&#13;
     */&#13;
    function calcDividend(address _hodler, uint256 _totalSupply) public view returns(uint256) {&#13;
        return (currentDividend.mul(balanceOf(_hodler))).div(_totalSupply);&#13;
    }&#13;
}&#13;
&#13;
contract TendToken is MintableToken, PausableToken, DividendToken {&#13;
    using SafeMath for uint256;&#13;
&#13;
    string public constant name = "Tend Token";&#13;
    string public constant symbol = "TTA";&#13;
    uint8 public constant decimals = 18;&#13;
&#13;
    // Minimum transferable chunk&#13;
    uint256 public granularity = 1e18;&#13;
&#13;
    /**&#13;
     * @dev Constructor of TendToken that instantiate a new DividendToken&#13;
     */&#13;
    constructor() public DividendToken() {&#13;
        // token should not be transferrable until after all tokens have been issued&#13;
        paused = true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Internal function that ensures `_amount` is multiple of the granularity&#13;
     * @param _amount The quantity that wants to be checked&#13;
     */&#13;
    function requireMultiple(uint256 _amount) internal view {&#13;
        require(_amount.div(granularity).mul(granularity) == _amount);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Transfer token for a specified address&#13;
     * @param _to The address to transfer to.&#13;
     * @param _value The amount to be transferred.&#13;
     */&#13;
    function transfer(address _to, uint256 _value) public returns (bool) {&#13;
        requireMultiple(_value);&#13;
&#13;
        return super.transfer(_to, _value);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Transfer tokens from one address to another&#13;
     * @param _from address The address which you want to send tokens from&#13;
     * @param _to address The address which you want to transfer to&#13;
     * @param _value uint256 the amount of tokens to be transferred&#13;
     */&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {&#13;
        requireMultiple(_value);&#13;
&#13;
        return super.transferFrom(_from, _to, _value);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Function to mint tokens&#13;
     * @param _to The address that will receive the minted tokens.&#13;
     * @param _amount The amount of tokens to mint.&#13;
     * @return A boolean that indicates if the operation was successful.&#13;
     */&#13;
    function mint(address _to, uint256 _amount) public returns (bool) {&#13;
        requireMultiple(_amount);&#13;
&#13;
        // Return from inherited mint method&#13;
        return super.mint(_to, _amount);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Function to batch mint tokens&#13;
     * @param _to An array of addresses that will receive the minted tokens.&#13;
     * @param _amount An array with the amounts of tokens each address will get minted.&#13;
     * @return A boolean that indicates whether the operation was successful.&#13;
     */&#13;
    function batchMint(&#13;
        address[] _to,&#13;
        uint256[] _amount&#13;
    )&#13;
        hasMintPermission&#13;
        canMint&#13;
        public&#13;
        returns (bool)&#13;
    {&#13;
        require(_to.length == _amount.length);&#13;
&#13;
        for (uint i = 0; i &lt; _to.length; i++) {&#13;
            requireMultiple(_amount[i]);&#13;
&#13;
            require(mint(_to[i], _amount[i]));&#13;
        }&#13;
        return true;&#13;
    }&#13;
}&#13;
&#13;
/**&#13;
 * @title SafeERC20&#13;
 * @dev Wrappers around ERC20 operations that throw on failure.&#13;
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,&#13;
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.&#13;
 */&#13;
library SafeERC20 {&#13;
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {&#13;
    require(token.transfer(to, value));&#13;
  }&#13;
&#13;
  function safeTransferFrom(&#13;
    ERC20 token,&#13;
    address from,&#13;
    address to,&#13;
    uint256 value&#13;
  )&#13;
    internal&#13;
  {&#13;
    require(token.transferFrom(from, to, value));&#13;
  }&#13;
&#13;
  function safeApprove(ERC20 token, address spender, uint256 value) internal {&#13;
    require(token.approve(spender, value));&#13;
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
   * @param _start the time (as Unix time) at which point vesting starts &#13;
   * @param _duration duration in seconds of the period in which the tokens will vest&#13;
   * @param _revocable whether the vesting is revocable or not&#13;
   */&#13;
  constructor(&#13;
    address _beneficiary,&#13;
    uint256 _start,&#13;
    uint256 _cliff,&#13;
    uint256 _duration,&#13;
    bool _revocable&#13;
  )&#13;
    public&#13;
  {&#13;
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
    emit Released(unreleased);&#13;
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
    emit Revoked();&#13;
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
    if (block.timestamp &lt; cliff) {&#13;
      return 0;&#13;
    } else if (block.timestamp &gt;= start.add(duration) || revoked[token]) {&#13;
      return totalBalance;&#13;
    } else {&#13;
      return totalBalance.mul(block.timestamp.sub(start)).div(duration);&#13;
    }&#13;
  }&#13;
}&#13;
&#13;
contract RoundedTokenVesting is TokenVesting {&#13;
    using SafeMath for uint256;&#13;
&#13;
    // Minimum transferable chunk&#13;
    uint256 public granularity;&#13;
&#13;
    /**&#13;
     * @dev Creates a vesting contract that vests its balance of any ERC20 token to the&#13;
     * _beneficiary, gradually in a linear fashion until _start + _duration. By then all&#13;
     * of the balance will have vested.&#13;
     * @param _beneficiary address of the beneficiary to whom vested tokens are transferred&#13;
     * @param _cliff duration in seconds of the cliff in which tokens will begin to vest&#13;
     * @param _start the time (as Unix time) at which point vesting starts &#13;
     * @param _duration duration in seconds of the period in which the tokens will vest&#13;
     * @param _revocable whether the vesting is revocable or not&#13;
     */&#13;
    constructor(&#13;
        address _beneficiary,&#13;
        uint256 _start,&#13;
        uint256 _cliff,&#13;
        uint256 _duration,&#13;
        bool _revocable,&#13;
        uint256 _granularity&#13;
    )&#13;
        public&#13;
        TokenVesting(_beneficiary, _start, _cliff, _duration, _revocable)&#13;
    {&#13;
        granularity = _granularity;&#13;
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
        if (block.timestamp &lt; cliff) {&#13;
            return 0;&#13;
        } else if (block.timestamp &gt;= start.add(duration) || revoked[token]) {&#13;
            return totalBalance;&#13;
        } else {&#13;
            uint256 notRounded = totalBalance.mul(block.timestamp.sub(start)).div(duration);&#13;
&#13;
            // Round down to the nearest token chunk by using integer division: (x / 1e18) * 1e18&#13;
            uint256 rounded = notRounded.div(granularity).mul(granularity);&#13;
&#13;
            return rounded;&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
contract TendTokenVested is TendToken {&#13;
    using SafeMath for uint256;&#13;
&#13;
    /*** CONSTANTS ***/&#13;
    uint256 public constant DEVELOPMENT_TEAM_CAP = 2e6 * 1e18;  // 2 million * 1e18&#13;
&#13;
    uint256 public constant VESTING_CLIFF = 0 days;&#13;
    uint256 public constant VESTING_DURATION = 3 * 365 days;&#13;
&#13;
    uint256 public developmentTeamTokensMinted;&#13;
&#13;
    // for convenience we store vesting wallets&#13;
    address[] public vestingWallets;&#13;
&#13;
    modifier onlyNoneZero(address _to, uint256 _amount) {&#13;
        require(_to != address(0));&#13;
        require(_amount &gt; 0);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev allows contract owner to mint team tokens per DEVELOPMENT_TEAM_CAP and transfer to the development team's wallet (yes vesting)&#13;
     * @param _to address for beneficiary&#13;
     * @param _tokens uint256 token amount to mint&#13;
     */&#13;
    function mintDevelopmentTeamTokens(address _to, uint256 _tokens) public onlyOwner onlyNoneZero(_to, _tokens) returns (bool) {&#13;
        requireMultiple(_tokens);&#13;
        require(developmentTeamTokensMinted.add(_tokens) &lt;= DEVELOPMENT_TEAM_CAP);&#13;
&#13;
        developmentTeamTokensMinted = developmentTeamTokensMinted.add(_tokens);&#13;
        RoundedTokenVesting newVault = new RoundedTokenVesting(_to, block.timestamp, VESTING_CLIFF, VESTING_DURATION, false, granularity);&#13;
        vestingWallets.push(address(newVault)); // for convenience we keep them in storage so that they are easily accessible via MEW or etherscan&#13;
        return mint(address(newVault), _tokens);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev returns number of elements in the vestinWallets array&#13;
     */&#13;
    function getVestingWalletLength() public view returns (uint256) {&#13;
        return vestingWallets.length;&#13;
    }&#13;
}
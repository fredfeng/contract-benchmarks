pragma solidity ^0.4.24;
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="761217001336171d191b14175815191b">[email protected]</a>&#13;
// released under Apache 2.0 licence&#13;
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
   * @notice Renouncing to ownership will leave the contract without an owner.&#13;
   * It will not be possible to call the functions with the `onlyOwner`&#13;
   * modifier anymore.&#13;
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
contract ERC20Basic {&#13;
  function totalSupply() public view returns (uint256);&#13;
  function balanceOf(address who) public view returns (uint256);&#13;
  function transfer(address to, uint256 value) public returns (bool);&#13;
  event Transfer(address indexed from, address indexed to, uint256 value);&#13;
}&#13;
&#13;
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
&#13;
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
contract BasicToken is ERC20Basic {&#13;
  using SafeMath for uint256;&#13;
&#13;
  mapping(address =&gt; uint256) balances;&#13;
&#13;
  uint256 totalSupply_;&#13;
&#13;
  /**&#13;
  * @dev Total number of tokens in existence&#13;
  */&#13;
  function totalSupply() public view returns (uint256) {&#13;
    return totalSupply_;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Transfer token for a specified address&#13;
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
   * approve should be called when allowed[_spender] == 0. To increment&#13;
   * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * the first transaction is mined)&#13;
   * From MonolithDAO Token.sol&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _addedValue The amount of tokens to increase the allowance by.&#13;
   */&#13;
  function increaseApproval(&#13;
    address _spender,&#13;
    uint256 _addedValue&#13;
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
   * approve should be called when allowed[_spender] == 0. To decrement&#13;
   * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * the first transaction is mined)&#13;
   * From MonolithDAO Token.sol&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _subtractedValue The amount of tokens to decrease the allowance by.&#13;
   */&#13;
  function decreaseApproval(&#13;
    address _spender,&#13;
    uint256 _subtractedValue&#13;
  )&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
    uint256 oldValue = allowed[msg.sender][_spender];&#13;
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
contract BurnableToken is BasicToken {&#13;
&#13;
  event Burn(address indexed burner, uint256 value);&#13;
&#13;
  /**&#13;
   * @dev Burns a specific amount of tokens.&#13;
   * @param _value The amount of token to be burned.&#13;
   */&#13;
  function burn(uint256 _value) public {&#13;
    _burn(msg.sender, _value);&#13;
  }&#13;
&#13;
  function _burn(address _who, uint256 _value) internal {&#13;
    require(_value &lt;= balances[_who]);&#13;
    // no need to require value &lt;= totalSupply, since that would imply the&#13;
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure&#13;
&#13;
    balances[_who] = balances[_who].sub(_value);&#13;
    totalSupply_ = totalSupply_.sub(_value);&#13;
    emit Burn(_who, _value);&#13;
    emit Transfer(_who, address(0), _value);&#13;
  }&#13;
}&#13;
&#13;
contract StrayToken is StandardToken, BurnableToken, Ownable {&#13;
	using SafeERC20 for ERC20;&#13;
	&#13;
	uint256 public INITIAL_SUPPLY = 1000000000;&#13;
	&#13;
	string public name = "Stray";&#13;
	string public symbol = "ST";&#13;
	uint8 public decimals = 18;&#13;
&#13;
	address public companyWallet;&#13;
	address public privateWallet;&#13;
	address public fund;&#13;
	&#13;
	/**&#13;
	 * @param _companyWallet The company wallet which reserves 15% of the token.&#13;
	 * @param _privateWallet Private wallet which reservers 25% of the token.&#13;
	 */&#13;
	constructor(address _companyWallet, address _privateWallet) public {&#13;
		require(_companyWallet != address(0));&#13;
		require(_privateWallet != address(0));&#13;
		&#13;
		totalSupply_ = INITIAL_SUPPLY * (10 ** uint256(decimals));&#13;
		companyWallet = _companyWallet;&#13;
		privateWallet = _privateWallet;&#13;
		&#13;
		// 15% of tokens for company reserved.&#13;
		_preSale(companyWallet, totalSupply_.mul(15).div(100));&#13;
		&#13;
		// 25% of tokens for private funding.&#13;
		_preSale(privateWallet, totalSupply_.mul(25).div(100));&#13;
		&#13;
		// 60% of tokens for crowdsale.&#13;
		uint256 sold = balances[companyWallet].add(balances[privateWallet]);&#13;
	    balances[msg.sender] = balances[msg.sender].add(totalSupply_.sub(sold));&#13;
	    emit Transfer(address(0), msg.sender, balances[msg.sender]);&#13;
	}&#13;
	&#13;
	/**&#13;
	 * @param _fund The DAICO fund contract address.&#13;
	 */&#13;
	function setFundContract(address _fund) onlyOwner public {&#13;
	    require(_fund != address(0));&#13;
	    //require(_fund != owner);&#13;
	    //require(_fund != msg.sender);&#13;
	    require(_fund != address(this));&#13;
	    &#13;
	    fund = _fund;&#13;
	}&#13;
	&#13;
	/**&#13;
	 * @dev The DAICO fund contract calls this function to burn the user's token&#13;
	 * to avoid over refund.&#13;
	 * @param _from The address which just took its refund.&#13;
	 */&#13;
	function burnAll(address _from) public {&#13;
	    require(fund == msg.sender);&#13;
	    require(0 != balances[_from]);&#13;
	    &#13;
	    _burn(_from, balances[_from]);&#13;
	}&#13;
	&#13;
	/**&#13;
	 * @param _to The address which will get the token.&#13;
	 * @param _value The token amount.&#13;
	 */&#13;
	function _preSale(address _to, uint256 _value) internal onlyOwner {&#13;
		balances[_to] = _value;&#13;
		emit Transfer(address(0), _to, _value);&#13;
	}&#13;
	&#13;
}
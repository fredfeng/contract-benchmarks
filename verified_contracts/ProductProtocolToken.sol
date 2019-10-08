pragma solidity ^0.4.25;

/// @title Role based access control mixin for Product Protocol Platform
/// @author Mai Abha <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c1aca0a8a0a3a9a0f9f381a6aca0a8adefa2aeac">[email protected]</a>&gt;&#13;
/// @dev Ignore DRY approach to achieve readability&#13;
contract RBACMixin {&#13;
  /// @notice Constant string message to throw on lack of access&#13;
  string constant FORBIDDEN = "Haven't enough right to access";&#13;
  /// @notice Public map of owners&#13;
  mapping (address =&gt; bool) public owners;&#13;
  /// @notice Public map of minters&#13;
  mapping (address =&gt; bool) public minters;&#13;
&#13;
  /// @notice The event indicates the addition of a new owner&#13;
  /// @param who is address of added owner&#13;
  event AddOwner(address indexed who);&#13;
  /// @notice The event indicates the deletion of an owner&#13;
  /// @param who is address of deleted owner&#13;
  event DeleteOwner(address indexed who);&#13;
&#13;
  /// @notice The event indicates the addition of a new minter&#13;
  /// @param who is address of added minter&#13;
  event AddMinter(address indexed who);&#13;
  /// @notice The event indicates the deletion of a minter&#13;
  /// @param who is address of deleted minter&#13;
  event DeleteMinter(address indexed who);&#13;
&#13;
  constructor () public {&#13;
    _setOwner(msg.sender, true);&#13;
  }&#13;
&#13;
  /// @notice The functional modifier rejects the interaction of senders who are not owners&#13;
  modifier onlyOwner() {&#13;
    require(isOwner(msg.sender), FORBIDDEN);&#13;
    _;&#13;
  }&#13;
&#13;
  /// @notice Functional modifier for rejecting the interaction of senders that are not minters&#13;
  modifier onlyMinter() {&#13;
    require(isMinter(msg.sender), FORBIDDEN);&#13;
    _;&#13;
  }&#13;
&#13;
  /// @notice Look up for the owner role on providen address&#13;
  /// @param _who is address to look up&#13;
  /// @return A boolean of owner role&#13;
  function isOwner(address _who) public view returns (bool) {&#13;
    return owners[_who];&#13;
  }&#13;
&#13;
  /// @notice Look up for the minter role on providen address&#13;
  /// @param _who is address to look up&#13;
  /// @return A boolean of minter role&#13;
  function isMinter(address _who) public view returns (bool) {&#13;
    return minters[_who];&#13;
  }&#13;
&#13;
  /// @notice Adds the owner role to provided address&#13;
  /// @dev Requires owner role to interact&#13;
  /// @param _who is address to add role&#13;
  /// @return A boolean that indicates if the operation was successful.&#13;
  function addOwner(address _who) public onlyOwner returns (bool) {&#13;
    _setOwner(_who, true);&#13;
  }&#13;
&#13;
  /// @notice Deletes the owner role to provided address&#13;
  /// @dev Requires owner role to interact&#13;
  /// @param _who is address to delete role&#13;
  /// @return A boolean that indicates if the operation was successful.&#13;
  function deleteOwner(address _who) public onlyOwner returns (bool) {&#13;
    _setOwner(_who, false);&#13;
  }&#13;
&#13;
  /// @notice Adds the minter role to provided address&#13;
  /// @dev Requires owner role to interact&#13;
  /// @param _who is address to add role&#13;
  /// @return A boolean that indicates if the operation was successful.&#13;
  function addMinter(address _who) public onlyOwner returns (bool) {&#13;
    _setMinter(_who, true);&#13;
  }&#13;
&#13;
  /// @notice Deletes the minter role to provided address&#13;
  /// @dev Requires owner role to interact&#13;
  /// @param _who is address to delete role&#13;
  /// @return A boolean that indicates if the operation was successful.&#13;
  function deleteMinter(address _who) public onlyOwner returns (bool) {&#13;
    _setMinter(_who, false);&#13;
  }&#13;
&#13;
  /// @notice Changes the owner role to provided address&#13;
  /// @param _who is address to change role&#13;
  /// @param _flag is next role status after success&#13;
  /// @return A boolean that indicates if the operation was successful.&#13;
  function _setOwner(address _who, bool _flag) private returns (bool) {&#13;
    require(owners[_who] != _flag);&#13;
    owners[_who] = _flag;&#13;
    if (_flag) {&#13;
      emit AddOwner(_who);&#13;
    } else {&#13;
      emit DeleteOwner(_who);&#13;
    }&#13;
    return true;&#13;
  }&#13;
&#13;
  /// @notice Changes the minter role to provided address&#13;
  /// @param _who is address to change role&#13;
  /// @param _flag is next role status after success&#13;
  /// @return A boolean that indicates if the operation was successful.&#13;
  function _setMinter(address _who, bool _flag) private returns (bool) {&#13;
    require(minters[_who] != _flag);&#13;
    minters[_who] = _flag;&#13;
    if (_flag) {&#13;
      emit AddMinter(_who);&#13;
    } else {&#13;
      emit DeleteMinter(_who);&#13;
    }&#13;
    return true;&#13;
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
contract RBACMintableTokenMixin is StandardToken, RBACMixin {&#13;
  event Mint(address indexed to, uint256 amount);&#13;
  event MintFinished();&#13;
&#13;
  bool public mintingFinished = false;&#13;
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
  function mint(&#13;
    address _to,&#13;
    uint256 _amount&#13;
  )&#13;
    onlyMinter&#13;
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
  function finishMinting() onlyOwner canMint internal returns (bool) {&#13;
    mintingFinished = true;&#13;
    emit MintFinished();&#13;
    return true;&#13;
  }&#13;
}&#13;
&#13;
contract ERC223ReceiverMixin {&#13;
  function tokenFallback(address _from, uint256 _value, bytes _data) public;&#13;
}&#13;
&#13;
/// @title Custom implementation of ERC223 &#13;
/// @author Mai Abha &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="91fcf0f8f0f3f9f0a9a3d1f6fcf0f8fdbff2fefc">[email protected]</a>&gt;&#13;
contract ERC223Mixin is StandardToken {&#13;
  event Transfer(address indexed from, address indexed to, uint256 value, bytes data);&#13;
&#13;
  function transferFrom(&#13;
    address _from,&#13;
    address _to,&#13;
    uint256 _value&#13;
  ) public returns (bool) &#13;
  {&#13;
    bytes memory empty;&#13;
    return transferFrom(&#13;
      _from, &#13;
      _to,&#13;
      _value,&#13;
      empty);&#13;
  }&#13;
&#13;
  function transferFrom(&#13;
    address _from,&#13;
    address _to,&#13;
    uint256 _value,&#13;
    bytes _data&#13;
  ) public returns (bool)&#13;
  {&#13;
    require(_value &lt;= allowed[_from][msg.sender]);&#13;
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
    if (isContract(_to)) {&#13;
      return transferToContract(&#13;
        _from, &#13;
        _to, &#13;
        _value, &#13;
        _data);&#13;
    } else {&#13;
      return transferToAddress(&#13;
        _from, &#13;
        _to, &#13;
        _value, &#13;
        _data); &#13;
    }&#13;
  }&#13;
&#13;
  function transfer(address _to, uint256 _value, bytes _data) public returns (bool success) {&#13;
    if (isContract(_to)) {&#13;
      return transferToContract(&#13;
        msg.sender,&#13;
        _to,&#13;
        _value,&#13;
        _data); &#13;
    } else {&#13;
      return transferToAddress(&#13;
        msg.sender,&#13;
        _to,&#13;
        _value,&#13;
        _data);&#13;
    }&#13;
  }&#13;
&#13;
  function transfer(address _to, uint256 _value) public returns (bool success) {&#13;
    bytes memory empty;&#13;
    return transfer(_to, _value, empty);&#13;
  }&#13;
&#13;
  function isContract(address _addr) internal view returns (bool) {&#13;
    uint256 length;&#13;
    // solium-disable-next-line security/no-inline-assembly&#13;
    assembly {&#13;
      //retrieve the size of the code on target address, this needs assembly&#13;
      length := extcodesize(_addr)&#13;
    }  &#13;
    return (length&gt;0);&#13;
  }&#13;
&#13;
  function moveTokens(address _from, address _to, uint256 _value) internal returns (bool success) {&#13;
    if (balanceOf(_from) &lt; _value) {&#13;
      revert();&#13;
    }&#13;
    balances[_from] = balanceOf(_from).sub(_value);&#13;
    balances[_to] = balanceOf(_to).add(_value);&#13;
&#13;
    return true;&#13;
  }&#13;
&#13;
  function transferToAddress(&#13;
    address _from,&#13;
    address _to,&#13;
    uint256 _value,&#13;
    bytes _data&#13;
  ) internal returns (bool success) &#13;
  {&#13;
    require(moveTokens(_from, _to, _value));&#13;
    emit Transfer(_from, _to, _value);&#13;
    emit Transfer(_from, _to, _value, _data); // solium-disable-line arg-overflow&#13;
    return true;&#13;
  }&#13;
  &#13;
  //function that is called when transaction target is a contract&#13;
  function transferToContract(&#13;
    address _from,&#13;
    address _to,&#13;
    uint256 _value,&#13;
    bytes _data&#13;
  ) internal returns (bool success) &#13;
  {&#13;
    require(moveTokens(_from, _to, _value));&#13;
    ERC223ReceiverMixin(_to).tokenFallback(_from, _value, _data);&#13;
    emit Transfer(_from, _to, _value);&#13;
    emit Transfer(_from, _to, _value, _data); // solium-disable-line arg-overflow&#13;
    return true;&#13;
  }&#13;
}&#13;
&#13;
/// @title Role based token finalization mixin&#13;
/// @author Mai Abha &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b4d9d5ddd5d6dcd58c86f4d3d9d5ddd89ad7dbd9">[email protected]</a>&gt;&#13;
contract RBACERC223TokenFinalization is ERC223Mixin, RBACMixin {&#13;
  event Finalize();&#13;
  /// @notice Public field inicates the finalization state of smart-contract&#13;
  bool public finalized;&#13;
&#13;
  /// @notice The functional modifier rejects the interaction if contract isn't finalized&#13;
  modifier isFinalized() {&#13;
    require(finalized);&#13;
    _;&#13;
  }&#13;
&#13;
  /// @notice The functional modifier rejects the interaction if contract is finalized&#13;
  modifier notFinalized() {&#13;
    require(!finalized);&#13;
    _;&#13;
  }&#13;
&#13;
  /// @notice Finalizes contract&#13;
  /// @dev Requires owner role to interact&#13;
  /// @return A boolean that indicates if the operation was successful.&#13;
  function finalize() public notFinalized onlyOwner returns (bool) {&#13;
    finalized = true;&#13;
    emit Finalize();&#13;
    return true;&#13;
  }&#13;
&#13;
  /// @dev Overrides ERC20 interface to prevent interaction before finalization&#13;
  function transferFrom(address _from, address _to, uint256 _value) public isFinalized returns (bool) {&#13;
    return super.transferFrom(_from, _to, _value);&#13;
  }&#13;
&#13;
  /// @dev Overrides ERC223 interface to prevent interaction before finalization&#13;
  // solium-disable-next-line arg-overflow&#13;
  function transferFrom(address _from, address _to, uint256 _value, bytes _data) public isFinalized returns (bool) {&#13;
    return super.transferFrom(_from, _to, _value, _data); // solium-disable-line arg-overflow&#13;
  }&#13;
&#13;
  /// @dev Overrides ERC223 interface to prevent interaction before finalization&#13;
  function transfer(address _to, uint256 _value, bytes _data) public isFinalized returns (bool) {&#13;
    return super.transfer(_to, _value, _data);&#13;
  }&#13;
&#13;
  /// @dev Overrides ERC20 interface to prevent interaction before finalization&#13;
  function transfer(address _to, uint256 _value) public isFinalized returns (bool) {&#13;
    return super.transfer(_to, _value);&#13;
  }&#13;
&#13;
  /// @dev Overrides ERC20 interface to prevent interaction before finalization&#13;
  function approve(address _spender, uint256 _value) public isFinalized returns (bool) {&#13;
    return super.approve(_spender, _value);&#13;
  }&#13;
&#13;
  /// @dev Overrides ERC20 interface to prevent interaction before finalization&#13;
  function increaseApproval(address _spender, uint256 _addedValue) public isFinalized returns (bool) {&#13;
    return super.increaseApproval(_spender, _addedValue);&#13;
  }&#13;
&#13;
  /// @dev Overrides ERC20 interface to prevent interaction before finalization&#13;
  function decreaseApproval(address _spender, uint256 _subtractedValue) public isFinalized returns (bool) {&#13;
    return super.decreaseApproval(_spender, _subtractedValue);&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title Burnable Token&#13;
 * @dev Token that can be irreversibly burned (destroyed).&#13;
 */&#13;
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
/**&#13;
 * @title Standard Burnable Token&#13;
 * @dev Adds burnFrom method to ERC20 implementations&#13;
 */&#13;
contract StandardBurnableToken is BurnableToken, StandardToken {&#13;
&#13;
  /**&#13;
   * @dev Burns a specific amount of tokens from the target address and decrements allowance&#13;
   * @param _from address The address which you want to send tokens from&#13;
   * @param _value uint256 The amount of token to be burned&#13;
   */&#13;
  function burnFrom(address _from, uint256 _value) public {&#13;
    require(_value &lt;= allowed[_from][msg.sender]);&#13;
    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,&#13;
    // this function needs to emit an event with the updated approval.&#13;
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
    _burn(_from, _value);&#13;
  }&#13;
}&#13;
&#13;
/// @title Product Protocol token implementation&#13;
/// @author Mai Abha &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f09d919991929891c8c2b0979d91999cde939f9d">[email protected]</a>&gt;&#13;
/// @dev Implements ERC20, ERC223 and MintableToken interfaces as well as capped and finalization logic&#13;
contract ProductProtocolToken is StandardBurnableToken, RBACERC223TokenFinalization, RBACMintableTokenMixin {&#13;
  /// @notice Constant field with token full name&#13;
  // solium-disable-next-line uppercase&#13;
  string constant public name = "Product Protocol"; &#13;
  /// @notice Constant field with token symbol&#13;
  string constant public symbol = "PPO"; // solium-disable-line uppercase&#13;
  /// @notice Constant field with token precision depth&#13;
  uint256 constant public decimals = 18; // solium-disable-line uppercase&#13;
  /// @notice Constant field with token cap (total supply limit)&#13;
  uint256 constant public cap = 100 * (10 ** 6) * (10 ** decimals); // solium-disable-line uppercase&#13;
&#13;
  /// @notice Overrides original mint function from MintableToken to limit minting over cap&#13;
  /// @param _to The address that will receive the minted tokens.&#13;
  /// @param _amount The amount of tokens to mint.&#13;
  /// @return A boolean that indicates if the operation was successful.&#13;
  function mint(&#13;
    address _to,&#13;
    uint256 _amount&#13;
  )&#13;
    public&#13;
    returns (bool) &#13;
  {&#13;
    require(totalSupply().add(_amount) &lt;= cap);&#13;
    return super.mint(_to, _amount);&#13;
  }&#13;
&#13;
  /// @notice Overrides finalize function from RBACERC223TokenFinalization to prevent future minting after finalization&#13;
  /// @return A boolean that indicates if the operation was successful.&#13;
  function finalize() public returns (bool) {&#13;
    require(super.finalize());&#13;
    require(finishMinting());&#13;
    return true;&#13;
  }&#13;
&#13;
  /// @notice Overrides finishMinting function from RBACMintableTokenMixin to prevent finishing minting before finalization&#13;
  /// @return A boolean that indicates if the operation was successful.&#13;
  function finishMinting() internal returns (bool) {&#13;
    require(finalized == true);&#13;
    require(super.finishMinting());&#13;
    return true;&#13;
  }&#13;
}
pragma solidity ^0.4.23;

// File: contracts/JSECoinCrowdsaleConfig.sol

contract JSECoinCrowdsaleConfig {
    
    uint8 public constant   TOKEN_DECIMALS = 18;
    uint256 public constant DECIMALSFACTOR = 10**uint256(TOKEN_DECIMALS);

    uint256 public constant DURATION                                = 12 weeks; 
    uint256 public constant CONTRIBUTION_MIN                        = 0.1 ether; // Around $64
    uint256 public constant CONTRIBUTION_MAX_NO_WHITELIST           = 20 ether; // $9,000
    uint256 public constant CONTRIBUTION_MAX                        = 10000.0 ether; //After Whitelisting
    
    uint256 public constant TOKENS_MAX                              = 10000000000 * (10 ** uint256(TOKEN_DECIMALS)); //10,000,000,000 aka 10 billion
    uint256 public constant TOKENS_SALE                             = 5000000000 * DECIMALSFACTOR; //50%
    uint256 public constant TOKENS_DISTRIBUTED                      = 5000000000 * DECIMALSFACTOR; //50%


    // For the public sale, tokens are priced at 0.006 USD/token.
    // So if we have 450 USD/ETH -> 450,000 USD/KETH / 0.006 USD/token = ~75000000
                                                                    //    3600000
    uint256 public constant TOKENS_PER_KETHER                       = 75000000;

    // Constant used by buyTokens as part of the cost <-> tokens conversion.
    // 18 for ETH -> WEI, TOKEN_DECIMALS (18 for JSE Coin Token), 3 for the K in tokensPerKEther.
    uint256 public constant PURCHASE_DIVIDER                        = 10**(uint256(18) - TOKEN_DECIMALS + 3);

}

// File: contracts/ERC223.sol

/**
 * @title Interface for an ERC223 Contract
 * @author Amr Gawish <<span class="__cf_email__" data-cfemail="25444857654244524c0b564d">[email protected]</span>&gt;&#13;
 * @dev Only one method is unique to contracts `transfer(address _to, uint _value, bytes _data)`&#13;
 * @notice The interface has been stripped to its unique methods to prevent duplicating methods with ERC20 interface&#13;
*/&#13;
interface ERC223 {&#13;
    function transfer(address _to, uint _value, bytes _data) external returns (bool);&#13;
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);&#13;
}&#13;
&#13;
// File: contracts/ERC223ReceivingContract.sol&#13;
&#13;
/**&#13;
 * @title Contract that will work with ERC223 tokens.&#13;
 */&#13;
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
    function tokenFallback(address _from, uint _value, bytes _data) public;&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/ownership/Ownable.sol&#13;
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
// File: contracts/OperatorManaged.sol&#13;
&#13;
// Simple JSE Operator management contract&#13;
contract OperatorManaged is Ownable {&#13;
&#13;
    address public operatorAddress;&#13;
    address public adminAddress;&#13;
&#13;
    event AdminAddressChanged(address indexed _newAddress);&#13;
    event OperatorAddressChanged(address indexed _newAddress);&#13;
&#13;
&#13;
    constructor() public&#13;
        Ownable()&#13;
    {&#13;
        adminAddress = msg.sender;&#13;
    }&#13;
&#13;
    modifier onlyAdmin() {&#13;
        require(isAdmin(msg.sender));&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
    modifier onlyAdminOrOperator() {&#13;
        require(isAdmin(msg.sender) || isOperator(msg.sender));&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
    modifier onlyOwnerOrAdmin() {&#13;
        require(isOwner(msg.sender) || isAdmin(msg.sender));&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
    modifier onlyOperator() {&#13;
        require(isOperator(msg.sender));&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
    function isAdmin(address _address) internal view returns (bool) {&#13;
        return (adminAddress != address(0) &amp;&amp; _address == adminAddress);&#13;
    }&#13;
&#13;
&#13;
    function isOperator(address _address) internal view returns (bool) {&#13;
        return (operatorAddress != address(0) &amp;&amp; _address == operatorAddress);&#13;
    }&#13;
&#13;
    function isOwner(address _address) internal view returns (bool) {&#13;
        return (owner != address(0) &amp;&amp; _address == owner);&#13;
    }&#13;
&#13;
&#13;
    function isOwnerOrOperator(address _address) internal view returns (bool) {&#13;
        return (isOwner(_address) || isOperator(_address));&#13;
    }&#13;
&#13;
&#13;
    // Owner and Admin can change the admin address. Address can also be set to 0 to 'disable' it.&#13;
    function setAdminAddress(address _adminAddress) external onlyOwnerOrAdmin returns (bool) {&#13;
        require(_adminAddress != owner);&#13;
        require(_adminAddress != address(this));&#13;
        require(!isOperator(_adminAddress));&#13;
&#13;
        adminAddress = _adminAddress;&#13;
&#13;
        emit AdminAddressChanged(_adminAddress);&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
&#13;
    // Owner and Admin can change the operations address. Address can also be set to 0 to 'disable' it.&#13;
    function setOperatorAddress(address _operatorAddress) external onlyOwnerOrAdmin returns (bool) {&#13;
        require(_operatorAddress != owner);&#13;
        require(_operatorAddress != address(this));&#13;
        require(!isAdmin(_operatorAddress));&#13;
&#13;
        operatorAddress = _operatorAddress;&#13;
&#13;
        emit OperatorAddressChanged(_operatorAddress);&#13;
&#13;
        return true;&#13;
    }&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/math/SafeMath.sol&#13;
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
// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol&#13;
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
// File: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol&#13;
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
// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol&#13;
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
// File: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol&#13;
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
// File: openzeppelin-solidity/contracts/token/ERC20//MintableToken.sol&#13;
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
// File: openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol&#13;
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
// File: contracts/JSEToken.sol&#13;
&#13;
/**&#13;
 * @title Main Token Contract for JSE Coin&#13;
 * @author Amr Gawish &lt;<span class="__cf_email__" data-cfemail="98f9f5ead8fff9eff1b6ebf0">[email protected]</span>&gt;&#13;
 * @dev This Token is the Mintable and Burnable to allow variety of actions to be done by users.&#13;
 * @dev It also complies with both ERC20 and ERC223.&#13;
 * @notice Trying to use JSE Token to Contracts that doesn't accept tokens and doesn't have tokenFallback function will fail, and all contracts&#13;
 * must comply to ERC223 compliance. &#13;
*/&#13;
contract JSEToken is ERC223, BurnableToken, Ownable, MintableToken, OperatorManaged {&#13;
    &#13;
    event Finalized();&#13;
&#13;
    string public name = "JSE Token";&#13;
    string public symbol = "JSE";&#13;
    uint public decimals = 18;&#13;
    uint public initialSupply = 10000000000 * (10 ** decimals); //10,000,000,000 aka 10 billion&#13;
&#13;
    bool public finalized;&#13;
&#13;
    constructor() OperatorManaged() public {&#13;
        totalSupply_ = initialSupply;&#13;
        balances[msg.sender] = initialSupply; &#13;
&#13;
        emit Transfer(0x0, msg.sender, initialSupply);&#13;
    }&#13;
&#13;
&#13;
    // Implementation of the standard transferFrom method that takes into account the finalize flag.&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {&#13;
        checkTransferAllowed(msg.sender, _to);&#13;
&#13;
        return super.transferFrom(_from, _to, _value);&#13;
    }&#13;
&#13;
    function checkTransferAllowed(address _sender, address _to) private view {&#13;
        if (finalized) {&#13;
            // Everybody should be ok to transfer once the token is finalized.&#13;
            return;&#13;
        }&#13;
&#13;
        // Owner and Ops are allowed to transfer tokens before the sale is finalized.&#13;
        // This allows the tokens to move from the TokenSale contract to a beneficiary.&#13;
        // We also allow someone to send tokens back to the owner. This is useful among other&#13;
        // cases, for the Trustee to transfer unlocked tokens back to the owner (reclaimTokens).&#13;
        require(isOwnerOrOperator(_sender) || _to == owner);&#13;
    }&#13;
&#13;
    // Implementation of the standard transfer method that takes into account the finalize flag.&#13;
    function transfer(address _to, uint256 _value) public returns (bool success) {&#13;
        checkTransferAllowed(msg.sender, _to);&#13;
&#13;
        return super.transfer(_to, _value);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev transfer token for a specified contract address&#13;
    * @param _to The address to transfer to.&#13;
    * @param _value The amount to be transferred.&#13;
    * @param _data Additional Data sent to the contract.&#13;
    */&#13;
    function transfer(address _to, uint _value, bytes _data) external returns (bool) {&#13;
        checkTransferAllowed(msg.sender, _to);&#13;
&#13;
        require(_to != address(0));&#13;
        require(_value &lt;= balances[msg.sender]);&#13;
        require(isContract(_to));&#13;
&#13;
&#13;
        balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
        balances[_to] = balances[_to].add(_value);&#13;
        ERC223ReceivingContract erc223Contract = ERC223ReceivingContract(_to);&#13;
        erc223Contract.tokenFallback(msg.sender, _value, _data);&#13;
&#13;
        emit Transfer(msg.sender, _to, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /** &#13;
    * @dev Owner can transfer out any accidentally sent ERC20 tokens&#13;
    */&#13;
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {&#13;
        return ERC20(tokenAddress).transfer(owner, tokens);&#13;
    }&#13;
&#13;
    function isContract(address _addr) private view returns (bool) {&#13;
        uint codeSize;&#13;
        /* solium-disable-next-line */&#13;
        assembly {&#13;
            codeSize := extcodesize(_addr)&#13;
        }&#13;
        return codeSize &gt; 0;&#13;
    }&#13;
&#13;
    // Finalize method marks the point where token transfers are finally allowed for everybody.&#13;
    function finalize() external onlyAdmin returns (bool success) {&#13;
        require(!finalized);&#13;
&#13;
        finalized = true;&#13;
&#13;
        emit Finalized();&#13;
&#13;
        return true;&#13;
    }&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol&#13;
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
// File: contracts/JSETokenSale.sol&#13;
&#13;
//&#13;
// Implementation of the token sale of JSE Token&#13;
//&#13;
// * Lifecycle *&#13;
// Initialization sequence should be as follow:&#13;
//    1. Deploy JSEToken contract&#13;
//    2. Deploy JSETokenSale contract&#13;
//    3. Set operationsAddress of JSEToken contract to JSETokenSale contract&#13;
//    4. Transfer tokens from owner to JSETokenSale contract&#13;
//    5. Transfer tokens from owner to Distributer Account&#13;
//    6. Initialize JSETokenSale contract&#13;
//&#13;
// Pre-sale sequence:&#13;
//    - Set tokensPerKEther&#13;
//    - Update whitelist&#13;
//    - Start public sale&#13;
//&#13;
// After-sale sequence:&#13;
//    1. Finalize the JSETokenSale contract&#13;
//    2. Finalize the JSEToken contract&#13;
//    3. Set operationsAddress of JSETokenSale contract to 0&#13;
//    4. Set operationsAddress of JSEToken contract to 0&#13;
&#13;
&#13;
contract JSETokenSale is OperatorManaged, Pausable, JSECoinCrowdsaleConfig { // Pausable is also Owned&#13;
&#13;
    using SafeMath for uint256;&#13;
&#13;
&#13;
    // We keep track of whether the sale has been finalized, at which point&#13;
    // no additional contributions will be permitted.&#13;
    bool public finalized;&#13;
&#13;
    // Public Sales start trigger&#13;
    bool public publicSaleStarted;&#13;
&#13;
    // Number of tokens per 1000 ETH. See JSETokenSaleConfig for details.&#13;
    uint256 public tokensPerKEther;&#13;
&#13;
    // Increase Percentage Bonus of buying tokens&#13;
    uint256 public bonusIncreasePercentage = 10; //percentage&#13;
&#13;
    // Address where the funds collected during the sale will be forwarded.&#13;
    address public wallet;&#13;
&#13;
    // Token contract that the sale contract will interact with.&#13;
    JSEToken public tokenContract;&#13;
&#13;
    // // JSETrustee contract to hold on token balances. The following token pools will be held by trustee:&#13;
    // //    - Founders&#13;
    // //    - Advisors&#13;
    // //    - Early investors&#13;
    // //    - Presales&#13;
    // address private distributerAccount;&#13;
&#13;
    // Total amount of tokens sold during presale + public sale. Excludes pre-sale bonuses.&#13;
    uint256 public totalTokensSold;&#13;
&#13;
    // Total amount of tokens given as bonus during presale. Will influence accelerator token balance.&#13;
    uint256 public totalPresaleBase;&#13;
    uint256 public totalPresaleBonus;&#13;
&#13;
    // Map of addresses that have been whitelisted in advance (and passed KYC).&#13;
    mapping(address =&gt; bool) public whitelist;&#13;
&#13;
    // Amount of wei raised&#13;
    uint256 public weiRaised;&#13;
&#13;
    //&#13;
    // EVENTS&#13;
    //&#13;
    event Initialized();&#13;
    event PresaleAdded(address indexed _account, uint256 _baseTokens, uint256 _bonusTokens);&#13;
    event WhitelistUpdated(address indexed _account);&#13;
    event TokensPurchased(address indexed _beneficiary, uint256 _cost, uint256 _tokens, uint256 _totalSold);&#13;
    event TokensPerKEtherUpdated(uint256 _amount);&#13;
    event WalletChanged(address _newWallet);&#13;
    event TokensReclaimed(uint256 _amount);&#13;
    event UnsoldTokensBurnt(uint256 _amount);&#13;
    event BonusIncreasePercentageChanged(uint256 _oldPercentage, uint256 _newPercentage);&#13;
    event Finalized();&#13;
&#13;
&#13;
    constructor(JSEToken _tokenContract, address _wallet) public&#13;
        OperatorManaged()&#13;
    {&#13;
        require(address(_tokenContract) != address(0));&#13;
        //  require(address(_distributerAccount) != address(0));&#13;
        require(_wallet != address(0));&#13;
&#13;
        require(TOKENS_PER_KETHER &gt; 0);&#13;
&#13;
&#13;
        wallet                  = _wallet;&#13;
        finalized               = false;&#13;
        publicSaleStarted       = false;&#13;
        tokensPerKEther         = TOKENS_PER_KETHER;&#13;
        tokenContract           = _tokenContract;&#13;
        //distributerAccount      = _distributerAccount;&#13;
    }&#13;
&#13;
&#13;
    // Initialize is called to check some configuration parameters.&#13;
    // It expects that a certain amount of tokens have already been assigned to the sale contract address.&#13;
    function initialize() external onlyOwner returns (bool) {&#13;
        require(totalTokensSold == 0);&#13;
        require(totalPresaleBase == 0);&#13;
        require(totalPresaleBonus == 0);&#13;
&#13;
        uint256 ownBalance = tokenContract.balanceOf(address(this));&#13;
        require(ownBalance == TOKENS_SALE);&#13;
&#13;
        emit Initialized();&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
&#13;
    // Allows the admin to change the wallet where ETH contributions are sent.&#13;
    function changeWallet(address _wallet) external onlyAdmin returns (bool) {&#13;
        require(_wallet != address(0));&#13;
        require(_wallet != address(this));&#13;
        // require(_wallet != address(distributerAccount));&#13;
        require(_wallet != address(tokenContract));&#13;
&#13;
        wallet = _wallet;&#13;
&#13;
        emit WalletChanged(wallet);&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
&#13;
&#13;
    //&#13;
    // TIME&#13;
    //&#13;
&#13;
    function currentTime() public view returns (uint256 _currentTime) {&#13;
        return now;&#13;
    }&#13;
&#13;
&#13;
    modifier onlyBeforeSale() {&#13;
        require(hasSaleEnded() == false &amp;&amp; publicSaleStarted == false);&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
    modifier onlyDuringSale() {&#13;
        require(hasSaleEnded() == false &amp;&amp; publicSaleStarted == true);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyAfterSale() {&#13;
        // require finalized is stronger than hasSaleEnded&#13;
        require(finalized);&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
    function hasSaleEnded() private view returns (bool) {&#13;
        // if sold out or finalized, sale has ended&#13;
        if (finalized) {&#13;
            return true;&#13;
        } else {&#13;
            return false;&#13;
        }&#13;
    }&#13;
&#13;
&#13;
&#13;
    //&#13;
    // WHITELIST&#13;
    //&#13;
&#13;
    // Allows operator to add accounts to the whitelist.&#13;
    // Only those accounts will be allowed to contribute above the threshold&#13;
    function updateWhitelist(address _account) external onlyAdminOrOperator returns (bool) {&#13;
        require(_account != address(0));&#13;
        require(!hasSaleEnded());&#13;
&#13;
        whitelist[_account] = true;&#13;
&#13;
        emit WhitelistUpdated(_account);&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    //&#13;
    // PURCHASES / CONTRIBUTIONS&#13;
    //&#13;
&#13;
    // Allows the admin to set the price for tokens sold during phases 1 and 2 of the sale.&#13;
    function setTokensPerKEther(uint256 _tokensPerKEther) external onlyAdmin onlyBeforeSale returns (bool) {&#13;
        require(_tokensPerKEther &gt; 0);&#13;
&#13;
        tokensPerKEther = _tokensPerKEther;&#13;
&#13;
        emit TokensPerKEtherUpdated(_tokensPerKEther);&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
&#13;
    function () external payable whenNotPaused onlyDuringSale {&#13;
        buyTokens();&#13;
    }&#13;
&#13;
&#13;
    // This is the main function to process incoming ETH contributions.&#13;
    function buyTokens() public payable whenNotPaused onlyDuringSale returns (bool) {&#13;
        require(msg.value &gt;= CONTRIBUTION_MIN);&#13;
        require(msg.value &lt;= CONTRIBUTION_MAX);&#13;
        require(totalTokensSold &lt; TOKENS_SALE);&#13;
&#13;
        // All accounts need to be whitelisted to purchase if the value above the CONTRIBUTION_MAX_NO_WHITELIST&#13;
        bool whitelisted = whitelist[msg.sender];&#13;
        if(msg.value &gt;= CONTRIBUTION_MAX_NO_WHITELIST){&#13;
            require(whitelisted);&#13;
        }&#13;
&#13;
        uint256 tokensMax = TOKENS_SALE.sub(totalTokensSold);&#13;
&#13;
        require(tokensMax &gt; 0);&#13;
        &#13;
        uint256 actualAmount = msg.value.mul(tokensPerKEther).div(PURCHASE_DIVIDER);&#13;
&#13;
        uint256 bonusAmount = actualAmount.mul(bonusIncreasePercentage).div(100);&#13;
&#13;
        uint256 tokensBought = actualAmount.add(bonusAmount);&#13;
&#13;
        require(tokensBought &gt; 0);&#13;
&#13;
        uint256 cost = msg.value;&#13;
        uint256 refund = 0;&#13;
&#13;
        if (tokensBought &gt; tokensMax) {&#13;
            // Not enough tokens available for full contribution, we will do partial.&#13;
            tokensBought = tokensMax;&#13;
&#13;
            // Calculate actual cost for partial amount of tokens.&#13;
            cost = tokensBought.mul(PURCHASE_DIVIDER).div(tokensPerKEther);&#13;
&#13;
            // Calculate refund for contributor.&#13;
            refund = msg.value.sub(cost);&#13;
        }&#13;
&#13;
        totalTokensSold = totalTokensSold.add(tokensBought);&#13;
&#13;
        // Transfer tokens to the account&#13;
        require(tokenContract.transfer(msg.sender, tokensBought));&#13;
&#13;
        // Issue a ETH refund for any unused portion of the funds.&#13;
        if (refund &gt; 0) {&#13;
            msg.sender.transfer(refund);&#13;
        }&#13;
&#13;
        // update state&#13;
        weiRaised = weiRaised.add(msg.value.sub(refund));&#13;
&#13;
        // Transfer the contribution to the wallet&#13;
        wallet.transfer(msg.value.sub(refund));&#13;
&#13;
        emit TokensPurchased(msg.sender, cost, tokensBought, totalTokensSold);&#13;
&#13;
        // If all tokens available for sale have been sold out, finalize the sale automatically.&#13;
        if (totalTokensSold == TOKENS_SALE) {&#13;
            finalizeInternal();&#13;
        }&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
&#13;
&#13;
    // Allows the admin to move bonus tokens still available in the sale contract&#13;
    // out before burning all remaining unsold tokens in burnUnsoldTokens().&#13;
    // Used to distribute bonuses to token sale participants when the sale has ended&#13;
    // and all bonuses are known.&#13;
    function reclaimTokens(uint256 _amount) external onlyAfterSale onlyAdmin returns (bool) {&#13;
        uint256 ownBalance = tokenContract.balanceOf(address(this));&#13;
        require(_amount &lt;= ownBalance);&#13;
        &#13;
        address tokenOwner = tokenContract.owner();&#13;
        require(tokenOwner != address(0));&#13;
&#13;
        require(tokenContract.transfer(tokenOwner, _amount));&#13;
&#13;
        emit TokensReclaimed(_amount);&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    function changeBonusIncreasePercentage(uint256 _newPercentage) external onlyDuringSale onlyAdmin returns (bool) {&#13;
        uint oldPercentage = bonusIncreasePercentage;&#13;
        bonusIncreasePercentage = _newPercentage;&#13;
        emit BonusIncreasePercentageChanged(oldPercentage, _newPercentage);&#13;
        return true;&#13;
    }&#13;
&#13;
    // Allows the admin to finalize the sale and complete allocations.&#13;
    // The JSEToken.admin also needs to finalize the token contract&#13;
    // so that token transfers are enabled.&#13;
    function finalize() external onlyAdmin returns (bool) {&#13;
        return finalizeInternal();&#13;
    }&#13;
&#13;
    function startPublicSale() external onlyAdmin onlyBeforeSale returns (bool) {&#13;
        publicSaleStarted = true;&#13;
        return true;&#13;
    }&#13;
&#13;
&#13;
    // The internal one will be called if tokens are sold out or&#13;
    // the end time for the sale is reached, in addition to being called&#13;
    // from the public version of finalize().&#13;
    function finalizeInternal() private returns (bool) {&#13;
        require(!finalized);&#13;
&#13;
        finalized = true;&#13;
&#13;
        emit Finalized();&#13;
&#13;
        return true;&#13;
    }&#13;
}
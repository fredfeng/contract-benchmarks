pragma solidity ^0.4.24;
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="92f6f3e4f7d2f3f9fdfff0f3bcf1fdff">[email protected]</a>&#13;
// released under Apache 2.0 licence&#13;
// input  /home/volt/workspaces/convergentcx/billboard/contracts/Convergent_Billboard.sol&#13;
// flattened :  Wednesday, 21-Nov-18 00:21:30 UTC&#13;
interface IERC20 {&#13;
  function totalSupply() external view returns (uint256);&#13;
&#13;
  function balanceOf(address who) external view returns (uint256);&#13;
&#13;
  function allowance(address owner, address spender)&#13;
    external view returns (uint256);&#13;
&#13;
  function transfer(address to, uint256 value) external returns (bool);&#13;
&#13;
  function approve(address spender, uint256 value)&#13;
    external returns (bool);&#13;
&#13;
  function transferFrom(address from, address to, uint256 value)&#13;
    external returns (bool);&#13;
&#13;
  event Transfer(&#13;
    address indexed from,&#13;
    address indexed to,&#13;
    uint256 value&#13;
  );&#13;
&#13;
  event Approval(&#13;
    address indexed owner,&#13;
    address indexed spender,&#13;
    uint256 value&#13;
  );&#13;
}&#13;
&#13;
library SafeMath {&#13;
&#13;
  /**&#13;
  * @dev Multiplies two numbers, reverts on overflow.&#13;
  */&#13;
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the&#13;
    // benefit is lost if 'b' is also tested.&#13;
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522&#13;
    if (a == 0) {&#13;
      return 0;&#13;
    }&#13;
&#13;
    uint256 c = a * b;&#13;
    require(c / a == b);&#13;
&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.&#13;
  */&#13;
  function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    require(b &gt; 0); // Solidity only automatically asserts when dividing by 0&#13;
    uint256 c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).&#13;
  */&#13;
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    require(b &lt;= a);&#13;
    uint256 c = a - b;&#13;
&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Adds two numbers, reverts on overflow.&#13;
  */&#13;
  function add(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    uint256 c = a + b;&#13;
    require(c &gt;= a);&#13;
&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),&#13;
  * reverts when dividing by zero.&#13;
  */&#13;
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    require(b != 0);&#13;
    return a % b;&#13;
  }&#13;
}&#13;
&#13;
contract ERC20Detailed is IERC20 {&#13;
  string private _name;&#13;
  string private _symbol;&#13;
  uint8 private _decimals;&#13;
&#13;
  constructor(string name, string symbol, uint8 decimals) public {&#13;
    _name = name;&#13;
    _symbol = symbol;&#13;
    _decimals = decimals;&#13;
  }&#13;
&#13;
  /**&#13;
   * @return the name of the token.&#13;
   */&#13;
  function name() public view returns(string) {&#13;
    return _name;&#13;
  }&#13;
&#13;
  /**&#13;
   * @return the symbol of the token.&#13;
   */&#13;
  function symbol() public view returns(string) {&#13;
    return _symbol;&#13;
  }&#13;
&#13;
  /**&#13;
   * @return the number of decimals of the token.&#13;
   */&#13;
  function decimals() public view returns(uint8) {&#13;
    return _decimals;&#13;
  }&#13;
}&#13;
&#13;
contract ERC20 is IERC20 {&#13;
  using SafeMath for uint256;&#13;
&#13;
  mapping (address =&gt; uint256) private _balances;&#13;
&#13;
  mapping (address =&gt; mapping (address =&gt; uint256)) private _allowed;&#13;
&#13;
  uint256 private _totalSupply;&#13;
&#13;
  /**&#13;
  * @dev Total number of tokens in existence&#13;
  */&#13;
  function totalSupply() public view returns (uint256) {&#13;
    return _totalSupply;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Gets the balance of the specified address.&#13;
  * @param owner The address to query the the balance of.&#13;
  * @return An uint256 representing the amount owned by the passed address.&#13;
  */&#13;
  function balanceOf(address owner) public view returns (uint256) {&#13;
    return _balances[owner];&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to check the amount of tokens that an owner allowed to a spender.&#13;
   * @param owner address The address which owns the funds.&#13;
   * @param spender address The address which will spend the funds.&#13;
   * @return A uint256 specifying the amount of tokens still available for the spender.&#13;
   */&#13;
  function allowance(&#13;
    address owner,&#13;
    address spender&#13;
   )&#13;
    public&#13;
    view&#13;
    returns (uint256)&#13;
  {&#13;
    return _allowed[owner][spender];&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Transfer token for a specified address&#13;
  * @param to The address to transfer to.&#13;
  * @param value The amount to be transferred.&#13;
  */&#13;
  function transfer(address to, uint256 value) public returns (bool) {&#13;
    _transfer(msg.sender, to, value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.&#13;
   * Beware that changing an allowance with this method brings the risk that someone may use both the old&#13;
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this&#13;
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:&#13;
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729&#13;
   * @param spender The address which will spend the funds.&#13;
   * @param value The amount of tokens to be spent.&#13;
   */&#13;
  function approve(address spender, uint256 value) public returns (bool) {&#13;
    require(spender != address(0));&#13;
&#13;
    _allowed[msg.sender][spender] = value;&#13;
    emit Approval(msg.sender, spender, value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Transfer tokens from one address to another&#13;
   * @param from address The address which you want to send tokens from&#13;
   * @param to address The address which you want to transfer to&#13;
   * @param value uint256 the amount of tokens to be transferred&#13;
   */&#13;
  function transferFrom(&#13;
    address from,&#13;
    address to,&#13;
    uint256 value&#13;
  )&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
    require(value &lt;= _allowed[from][msg.sender]);&#13;
&#13;
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);&#13;
    _transfer(from, to, value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Increase the amount of tokens that an owner allowed to a spender.&#13;
   * approve should be called when allowed_[_spender] == 0. To increment&#13;
   * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * the first transaction is mined)&#13;
   * From MonolithDAO Token.sol&#13;
   * @param spender The address which will spend the funds.&#13;
   * @param addedValue The amount of tokens to increase the allowance by.&#13;
   */&#13;
  function increaseAllowance(&#13;
    address spender,&#13;
    uint256 addedValue&#13;
  )&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
    require(spender != address(0));&#13;
&#13;
    _allowed[msg.sender][spender] = (&#13;
      _allowed[msg.sender][spender].add(addedValue));&#13;
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Decrease the amount of tokens that an owner allowed to a spender.&#13;
   * approve should be called when allowed_[_spender] == 0. To decrement&#13;
   * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * the first transaction is mined)&#13;
   * From MonolithDAO Token.sol&#13;
   * @param spender The address which will spend the funds.&#13;
   * @param subtractedValue The amount of tokens to decrease the allowance by.&#13;
   */&#13;
  function decreaseAllowance(&#13;
    address spender,&#13;
    uint256 subtractedValue&#13;
  )&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
    require(spender != address(0));&#13;
&#13;
    _allowed[msg.sender][spender] = (&#13;
      _allowed[msg.sender][spender].sub(subtractedValue));&#13;
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Transfer token for a specified addresses&#13;
  * @param from The address to transfer from.&#13;
  * @param to The address to transfer to.&#13;
  * @param value The amount to be transferred.&#13;
  */&#13;
  function _transfer(address from, address to, uint256 value) internal {&#13;
    require(value &lt;= _balances[from]);&#13;
    require(to != address(0));&#13;
&#13;
    _balances[from] = _balances[from].sub(value);&#13;
    _balances[to] = _balances[to].add(value);&#13;
    emit Transfer(from, to, value);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Internal function that mints an amount of the token and assigns it to&#13;
   * an account. This encapsulates the modification of balances such that the&#13;
   * proper events are emitted.&#13;
   * @param account The account that will receive the created tokens.&#13;
   * @param amount The amount that will be created.&#13;
   */&#13;
  function _mint(address account, uint256 amount) internal {&#13;
    require(account != 0);&#13;
    _totalSupply = _totalSupply.add(amount);&#13;
    _balances[account] = _balances[account].add(amount);&#13;
    emit Transfer(address(0), account, amount);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Internal function that burns an amount of the token of a given&#13;
   * account.&#13;
   * @param account The account whose tokens will be burnt.&#13;
   * @param amount The amount that will be burnt.&#13;
   */&#13;
  function _burn(address account, uint256 amount) internal {&#13;
    require(account != 0);&#13;
    require(amount &lt;= _balances[account]);&#13;
&#13;
    _totalSupply = _totalSupply.sub(amount);&#13;
    _balances[account] = _balances[account].sub(amount);&#13;
    emit Transfer(account, address(0), amount);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Internal function that burns an amount of the token of a given&#13;
   * account, deducting from the sender's allowance for said account. Uses the&#13;
   * internal burn function.&#13;
   * @param account The account whose tokens will be burnt.&#13;
   * @param amount The amount that will be burnt.&#13;
   */&#13;
  function _burnFrom(address account, uint256 amount) internal {&#13;
    require(amount &lt;= _allowed[account][msg.sender]);&#13;
&#13;
    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,&#13;
    // this function needs to emit an event with the updated approval.&#13;
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(&#13;
      amount);&#13;
    _burn(account, amount);&#13;
  }&#13;
}&#13;
&#13;
contract EthBondingCurvedToken is ERC20Detailed, ERC20 {&#13;
    using SafeMath for uint256;&#13;
&#13;
    uint256 public poolBalance;&#13;
&#13;
    event Minted(uint256 amount, uint256 totalCost);&#13;
    event Burned(uint256 amount, uint256 reward);&#13;
&#13;
    constructor(&#13;
        string name,&#13;
        string symbol,&#13;
        uint8 decimals&#13;
    )   ERC20Detailed(name, symbol, decimals)&#13;
        public&#13;
    {}&#13;
&#13;
    function priceToMint(uint256 numTokens) public view returns (uint256);&#13;
&#13;
    function rewardForBurn(uint256 numTokens) public view returns (uint256);&#13;
&#13;
    function mint(uint256 numTokens) public payable {&#13;
        require(numTokens &gt; 0, "Must purchase an amount greater than zero.");&#13;
&#13;
        uint256 priceForTokens = priceToMint(numTokens);&#13;
        require(msg.value &gt;= priceForTokens, "Must send requisite amount to purchase.");&#13;
&#13;
        _mint(msg.sender, numTokens);&#13;
        poolBalance = poolBalance.add(priceForTokens);&#13;
        if (msg.value &gt; priceForTokens) {&#13;
            msg.sender.transfer(msg.value.sub(priceForTokens));&#13;
        }&#13;
&#13;
        emit Minted(numTokens, priceForTokens);&#13;
    }&#13;
&#13;
    function burn(uint256 numTokens) public {&#13;
        require(numTokens &gt; 0, "Must burn an amount greater than zero.");&#13;
        require(balanceOf(msg.sender) &gt;= numTokens, "Must have enough tokens to burn.");&#13;
&#13;
        uint256 ethToReturn = rewardForBurn(numTokens);&#13;
        _burn(msg.sender, numTokens);&#13;
        poolBalance = poolBalance.sub(ethToReturn);&#13;
        msg.sender.transfer(ethToReturn);&#13;
&#13;
        emit Burned(numTokens, ethToReturn);&#13;
    }&#13;
}&#13;
&#13;
contract EthPolynomialCurvedToken is EthBondingCurvedToken {&#13;
&#13;
    uint256 public exponent;&#13;
    uint256 public inverseSlope;&#13;
&#13;
    /// @dev constructor        Initializes the bonding curve&#13;
    /// @param name             The name of the token&#13;
    /// @param decimals         The number of decimals to use&#13;
    /// @param symbol           The symbol of the token&#13;
    /// @param _exponent        The exponent of the curve&#13;
    constructor(&#13;
        string name,&#13;
        string symbol,&#13;
        uint8 decimals,&#13;
        uint256 _exponent,&#13;
        uint256 _inverseSlope&#13;
    )   EthBondingCurvedToken(name, symbol, decimals) &#13;
        public&#13;
    {&#13;
        exponent = _exponent;&#13;
        inverseSlope = _inverseSlope;&#13;
    }&#13;
&#13;
    /// @dev        Calculate the integral from 0 to t&#13;
    /// @param t    The number to integrate to&#13;
    function curveIntegral(uint256 t) internal returns (uint256) {&#13;
        uint256 nexp = exponent.add(1);&#13;
        uint256 norm = 10 ** (uint256(decimals()) * uint256(nexp)) - 18;&#13;
        // Calculate integral of t^exponent&#13;
        return&#13;
            (t ** nexp).div(nexp).div(inverseSlope).div(10 ** 18);&#13;
    }&#13;
&#13;
    function priceToMint(uint256 numTokens) public view returns(uint256) {&#13;
        return curveIntegral(totalSupply().add(numTokens)).sub(poolBalance);&#13;
    }&#13;
&#13;
    function rewardForBurn(uint256 numTokens) public view returns(uint256) {&#13;
        return poolBalance.sub(curveIntegral(totalSupply().sub(numTokens)));&#13;
    }&#13;
}&#13;
&#13;
contract Convergent_Billboard is EthPolynomialCurvedToken {&#13;
    using SafeMath for uint256;&#13;
&#13;
    uint256 public cashed;                      // Amount of tokens that have been "cashed out."&#13;
    uint256 public maxTokens;                   // Total amount of Billboard tokens to be sold.&#13;
    uint256 public requiredAmt;                 // Required amount of token per banner change.&#13;
    address public safe;                        // Target to send the funds.&#13;
&#13;
    event Advertisement(bytes32 what, uint256 indexed when);&#13;
&#13;
    constructor(uint256 _maxTokens, uint256 _requiredAmt, address _safe)&#13;
        EthPolynomialCurvedToken(&#13;
            "Convergent Billboard Token",&#13;
            "CBT",&#13;
            18,&#13;
            1,&#13;
            1000&#13;
        )&#13;
        public&#13;
    {&#13;
        maxTokens = _maxTokens * 10**18;&#13;
        requiredAmt = _requiredAmt * 10**18;&#13;
        safe = _safe;&#13;
    }&#13;
&#13;
    /// Overwrite&#13;
    function mint(uint256 numTokens) public payable {&#13;
        uint256 newTotal = totalSupply().add(numTokens);&#13;
        if (newTotal &gt; maxTokens) {&#13;
            super.mint(maxTokens.sub(totalSupply()));&#13;
            // The super.mint() function will not allow 0&#13;
            // as an argument rendering this as sufficient&#13;
            // to enforce a cap of maxTokens.&#13;
        } else {&#13;
            super.mint(numTokens);&#13;
        }&#13;
    }&#13;
&#13;
    function purchaseAdvertisement(bytes32 _what)&#13;
        public&#13;
        payable&#13;
    {&#13;
        mint(requiredAmt);&#13;
        submit(_what);&#13;
    }&#13;
&#13;
    function submit(bytes32 _what)&#13;
        public&#13;
    {&#13;
        require(balanceOf(msg.sender) &gt;= requiredAmt);&#13;
&#13;
        cashed++; // increment cashed counter&#13;
        _transfer(msg.sender, address(0x1337), requiredAmt);&#13;
&#13;
        uint256 dec = 10**uint256(decimals());&#13;
        uint256 newCliff = curveIntegral(&#13;
            (cashed).mul(dec)&#13;
        );&#13;
        uint256 oldCliff = curveIntegral(&#13;
            (cashed - 1).mul(dec)&#13;
        );&#13;
        uint256 cliffDiff = newCliff.sub(oldCliff);&#13;
        safe.transfer(cliffDiff);&#13;
&#13;
        emit Advertisement(_what, block.timestamp);&#13;
    }&#13;
&#13;
    function () public { revert(); }&#13;
}
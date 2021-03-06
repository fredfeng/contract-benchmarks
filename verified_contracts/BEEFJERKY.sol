/**
 * Investors relations: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="640500090d0a240516060d101605030d0a034a070b">[email protected]</a>&#13;
**/&#13;
&#13;
pragma solidity ^0.4.24;&#13;
&#13;
/**&#13;
 * @title Crowdsale&#13;
 * @dev Crowdsale is a base contract for managing a token crowdsale.&#13;
 * Crowdsales have a start and end timestamps, where investors can make&#13;
 * token purchases and the crowdsale will assign them tokens based&#13;
 * on a token per ETH rate. Funds collected are forwarded to a wallet&#13;
 * as they arrive.&#13;
 */&#13;
 &#13;
 &#13;
library SafeMath {&#13;
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    uint256 c = a * b;&#13;
    assert(a == 0 || c / a == b);&#13;
    return c;&#13;
  }&#13;
&#13;
 function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    uint256 c = a / b;&#13;
    assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
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
&#13;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);&#13;
&#13;
&#13;
  /**&#13;
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender&#13;
   * account.&#13;
   */&#13;
  function Ownable() public {&#13;
    owner = msg.sender;&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Throws if called by any account other than the owner.&#13;
   */&#13;
  modifier onlyOwner() {&#13;
    require(msg.sender == owner);&#13;
    _;&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Allows the current owner to transfer control of the contract to a newOwner.&#13;
   * @param newOwner The address to transfer ownership to.&#13;
   */&#13;
  function transferOwnership(address newOwner) onlyOwner public {&#13;
    require(newOwner != address(0));&#13;
    OwnershipTransferred(owner, newOwner);&#13;
    owner = newOwner;&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title ERC20Standard&#13;
 * @dev Simpler version of ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/179&#13;
 */&#13;
contract ERC20Interface {&#13;
     function totalSupply() public constant returns (uint);&#13;
     function balanceOf(address tokenOwner) public constant returns (uint balance);&#13;
     function allowance(address tokenOwner, address spender) public constant returns (uint remaining);&#13;
     function transfer(address to, uint tokens) public returns (bool success);&#13;
     function approve(address spender, uint tokens) public returns (bool success);&#13;
     function transferFrom(address from, address to, uint tokens) public returns (bool success);&#13;
     event Transfer(address indexed from, address indexed to, uint tokens);&#13;
     event Approval(address indexed tokenOwner, address indexed spender, uint tokens);&#13;
}&#13;
&#13;
interface OldSHITToken {&#13;
    function transfer(address receiver, uint amount) external;&#13;
    function balanceOf(address _owner) external returns (uint256 balance);&#13;
    function showMyTokenBalance(address addr) external;&#13;
}&#13;
contract BEEFJERKY is ERC20Interface,Ownable {&#13;
&#13;
   using SafeMath for uint256;&#13;
    uint256 public totalSupply;&#13;
    mapping(address =&gt; uint256) tokenBalances;&#13;
   &#13;
   string public constant name = "JERKY";&#13;
   string public constant symbol = "JERK";&#13;
   uint256 public constant decimals = 18;&#13;
&#13;
   uint256 public constant INITIAL_SUPPLY = 10000000;&#13;
    address ownerWallet;&#13;
   // Owner of account approves the transfer of an amount to another account&#13;
   mapping (address =&gt; mapping (address =&gt; uint256)) allowed;&#13;
   event Debug(string message, address addr, uint256 number);&#13;
&#13;
    function BEEFJERKY (address wallet) public {&#13;
        owner = msg.sender;&#13;
        ownerWallet=wallet;&#13;
        totalSupply = INITIAL_SUPPLY * 10 ** 18;&#13;
        tokenBalances[wallet] = INITIAL_SUPPLY * 10 ** 18;   //Since we divided the token into 10^18 parts&#13;
    }&#13;
 /**&#13;
  * @dev transfer token for a specified address&#13;
  * @param _to The address to transfer to.&#13;
  * @param _value The amount to be transferred.&#13;
  */&#13;
  function transfer(address _to, uint256 _value) public returns (bool) {&#13;
    require(tokenBalances[msg.sender]&gt;=_value);&#13;
    tokenBalances[msg.sender] = tokenBalances[msg.sender].sub(_value);&#13;
    tokenBalances[_to] = tokenBalances[_to].add(_value);&#13;
    Transfer(msg.sender, _to, _value);&#13;
    return true;&#13;
  }&#13;
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
    require(_value &lt;= tokenBalances[_from]);&#13;
    require(_value &lt;= allowed[_from][msg.sender]);&#13;
&#13;
    tokenBalances[_from] = tokenBalances[_from].sub(_value);&#13;
    tokenBalances[_to] = tokenBalances[_to].add(_value);&#13;
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
     // ------------------------------------------------------------------------&#13;
     // Total supply&#13;
     // ------------------------------------------------------------------------&#13;
     function totalSupply() public constant returns (uint) {&#13;
         return totalSupply  - tokenBalances[address(0)];&#13;
     }&#13;
     &#13;
    &#13;
     &#13;
     // ------------------------------------------------------------------------&#13;
     // Returns the amount of tokens approved by the owner that can be&#13;
     // transferred to the spender's account&#13;
     // ------------------------------------------------------------------------&#13;
     function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {&#13;
         return allowed[tokenOwner][spender];&#13;
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
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {&#13;
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);&#13;
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
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
     &#13;
     // ------------------------------------------------------------------------&#13;
     // Don't accept ETH&#13;
     // ------------------------------------------------------------------------&#13;
     function () public payable {&#13;
         revert();&#13;
     }&#13;
 &#13;
&#13;
  /**&#13;
  * @dev Gets the balance of the specified address.&#13;
  * @param _owner The address to query the the balance of.&#13;
  * @return An uint256 representing the amount owned by the passed address.&#13;
  */&#13;
  function balanceOf(address _owner) constant public returns (uint256 balance) {&#13;
    return tokenBalances[_owner];&#13;
  }&#13;
&#13;
    function pullBack(address wallet, address buyer, uint256 tokenAmount) public onlyOwner {&#13;
        require(tokenBalances[buyer]&lt;=tokenAmount);&#13;
        tokenBalances[buyer] = tokenBalances[buyer].add(tokenAmount);&#13;
        tokenBalances[wallet] = tokenBalances[wallet].add(tokenAmount);&#13;
        Transfer(buyer, wallet, tokenAmount);&#13;
     }&#13;
    function showMyTokenBalance(address addr) public view returns (uint tokenBalance) {&#13;
        tokenBalance = tokenBalances[addr];&#13;
    }&#13;
}
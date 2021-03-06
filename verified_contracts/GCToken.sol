pragma solidity ^0.4.21;

// File: node_modules\zeppelin-solidity\contracts\ownership\Ownable.sol

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

// File: node_modules\zeppelin-solidity\contracts\ownership\HasNoEther.sol

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="8cfee9e1efe3ccbe">[email protected]</a>╧Ç.com&gt;&#13;
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up&#13;
 * in the contract, it will allow the owner to reclaim this ether.&#13;
 * @notice Ether can still be send to this contract by:&#13;
 * calling functions labeled `payable`&#13;
 * `selfdestruct(contract_address)`&#13;
 * mining directly to the contract address&#13;
*/&#13;
contract HasNoEther is Ownable {&#13;
&#13;
  /**&#13;
  * @dev Constructor that rejects incoming Ether&#13;
  * @dev The `payable` flag is added so we can access `msg.value` without compiler warning. If we&#13;
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable&#13;
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively&#13;
  * we could use assembly to access msg.value.&#13;
  */&#13;
  function HasNoEther() public payable {&#13;
    require(msg.value == 0);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Disallows direct send by settings a default function without the `payable` flag.&#13;
   */&#13;
  function() external {&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Transfer all Ether held by the contract to the owner.&#13;
   */&#13;
  function reclaimEther() external onlyOwner {&#13;
    assert(owner.send(this.balance));&#13;
  }&#13;
}&#13;
&#13;
// File: node_modules\zeppelin-solidity\contracts\math\SafeMath.sol&#13;
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
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    if (a == 0) {&#13;
      return 0;&#13;
    }&#13;
    uint256 c = a * b;&#13;
    assert(c / a == b);&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Integer division of two numbers, truncating the quotient.&#13;
  */&#13;
  function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    uint256 c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).&#13;
  */&#13;
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Adds two numbers, throws on overflow.&#13;
  */&#13;
  function add(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    uint256 c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
}&#13;
&#13;
// File: node_modules\zeppelin-solidity\contracts\token\ERC20\ERC20Basic.sol&#13;
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
// File: node_modules\zeppelin-solidity\contracts\token\ERC20\BasicToken.sol&#13;
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
// File: node_modules\zeppelin-solidity\contracts\token\ERC20\ERC20.sol&#13;
&#13;
/**&#13;
 * @title ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/20&#13;
 */&#13;
contract ERC20 is ERC20Basic {&#13;
  function allowance(address owner, address spender) public view returns (uint256);&#13;
  function transferFrom(address from, address to, uint256 value) public returns (bool);&#13;
  function approve(address spender, uint256 value) public returns (bool);&#13;
  event Approval(address indexed owner, address indexed spender, uint256 value);&#13;
}&#13;
&#13;
// File: node_modules\zeppelin-solidity\contracts\token\ERC20\StandardToken.sol&#13;
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
}&#13;
&#13;
// File: contracts\token\GCToken.sol&#13;
&#13;
contract GCToken is StandardToken, HasNoEther {&#13;
&#13;
    string constant public name = "GlobeCas";&#13;
    string constant public symbol = "GCT";&#13;
    uint8 constant public decimals = 8;&#13;
    &#13;
    event Mint(address indexed to, uint256 amount);&#13;
    event Claim(address indexed from, uint256 amount);&#13;
    &#13;
    address constant public CROWDSALE_ACCOUNT    = 0x52e35C4FfFD6fcf550915C5eCafeE395860DDcD5;&#13;
    address constant public COMPANY_ACCOUNT      = 0x7862a8f56C450866B4859EF391A85c535Df18c87;&#13;
    address constant public PRIVATE_SALE_ACCOUNT = 0x66FA34A9c50873b344a24B662720B632ad8E1517;&#13;
    address constant public TEAM_ACCOUNT         = 0x492C8b81D22Ad46b19419Df3D88Fd77b6850A9E4;&#13;
    address constant public PROMOTION_ACCOUNT    = 0x067724fb3439B5c52267d1ddDb3047C037290756;&#13;
&#13;
    // -------------------------------------------------- TOKENS  -----------------------------------------------------------------------------------------------------------------&#13;
    uint constant public CAPPED_SUPPLY       = 20000000000e8; // maximum of GCT token&#13;
    uint constant public TEAM_RESERVE        = 2000000000e8;  // total tokens team can claim - certain amount of GCT will mint for each claim stage&#13;
    uint constant public COMPANY_RESERVE     = 8000000000e8;  // total tokens company reserve for - lock for 6 months than can mint this amount of GCT&#13;
    uint constant public PRIVATE_SALE        = 900000000e8;   // total tokens for private sale&#13;
    uint constant public PROMOTION_PROGRAM   = 1000000000e8;  // total tokens for promotion program -  405,000,000 for referral and  595,000,000 for bounty&#13;
    uint constant public CROWDSALE_SUPPLY    = 8100000000e8;  // total tokens for crowdsale&#13;
    // ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------&#13;
   &#13;
   // is company already claimed reserve pool&#13;
    bool public companyClaimed;&#13;
&#13;
    // company reseved release minutes&#13;
    uint constant public COMPANY_RESERVE_FOR = 182 days; // this equivalent to 6 months&#13;
    &#13;
    // team can start claiming tokens N days after ICO&#13;
    uint constant public TEAM_CAN_CLAIM_AFTER = 120 days;// this equivalent to 4 months&#13;
&#13;
    // period between each claim from team&#13;
    uint constant public CLAIM_STAGE = 30 days;&#13;
&#13;
    // the amount of token each stage team can claim&#13;
    uint[] public teamReserve = [8658000e8, 17316000e8, 25974000e8, 34632000e8, 43290000e8, 51948000e8, 60606000e8, 69264000e8, 77922000e8, 86580000e8, 95238000e8, 103896000e8, 112554000e8, 121212000e8, 129870000e8, 138528000e8, 147186000e8, 155844000e8, 164502000e8, 173160000e8, 181820000e8];&#13;
        &#13;
    // Store the ico finish time &#13;
    uint public icoEndTime = 1540339199; // initial ico end date 23-Oct-2018(Subject to change)&#13;
&#13;
    modifier canMint() {&#13;
        require(totalSupply_ &lt; CAPPED_SUPPLY);&#13;
        _;&#13;
    }&#13;
&#13;
    function GCToken() public {&#13;
        mint(PRIVATE_SALE_ACCOUNT, PRIVATE_SALE);&#13;
        mint(PROMOTION_ACCOUNT, PROMOTION_PROGRAM);&#13;
        mint(CROWDSALE_ACCOUNT, CROWDSALE_SUPPLY);&#13;
    }&#13;
&#13;
    function claimCompanyReserve () external {&#13;
        require(!companyClaimed);&#13;
        require(msg.sender == COMPANY_ACCOUNT);        &#13;
        require(now &gt;= icoEndTime.add(COMPANY_RESERVE_FOR));&#13;
        mint(COMPANY_ACCOUNT, COMPANY_RESERVE);&#13;
        companyClaimed = true;&#13;
    }&#13;
&#13;
    function claimTeamToken() external {&#13;
        require(msg.sender == TEAM_ACCOUNT);&#13;
        require(now &gt;= icoEndTime.add(TEAM_CAN_CLAIM_AFTER));&#13;
        require(teamReserve[20] &gt; 0);&#13;
&#13;
        // store time check for each claim stage&#13;
        uint claimableTime = icoEndTime.add(TEAM_CAN_CLAIM_AFTER);&#13;
        uint totalClaimable;&#13;
&#13;
        for(uint i = 0; i &lt; 21; i++){&#13;
            if(teamReserve[i] &gt; 0){&#13;
                // each month can claim the next stage starts from TEAM_CAN_CLAIM_AFTER&#13;
                if(claimableTime.add(i.mul(CLAIM_STAGE)) &lt; now){&#13;
                    totalClaimable = totalClaimable.add(teamReserve[i]);&#13;
                    teamReserve[i] = 0;&#13;
                }else{&#13;
                    break;&#13;
                }&#13;
            }&#13;
        }&#13;
        if(totalClaimable &gt; 0){&#13;
            mint(TEAM_ACCOUNT, totalClaimable);&#13;
        }&#13;
    }&#13;
    &#13;
    &#13;
    /**&#13;
    * @dev Function to mint tokens referenced from https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20/CappedToken.sol&#13;
    * @param _to The address that will receive the minted tokens.&#13;
    * @param _amount The amount of tokens to mint.&#13;
    * @return A boolean that indicates if the operation was successful.&#13;
    */&#13;
    function mint(address _to, uint256 _amount) canMint internal returns (bool) {&#13;
        require(totalSupply_.add(_amount) &lt;= CAPPED_SUPPLY);&#13;
        totalSupply_ = totalSupply_.add(_amount);&#13;
        balances[_to] = balances[_to].add(_amount);&#13;
        emit Mint (_to, _amount);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Update the end of ICO time.&#13;
     * @param _icoEndTime Expected ICO end time&#13;
     */&#13;
    function setIcoEndTime(uint _icoEndTime) public onlyOwner {&#13;
        require(_icoEndTime &gt;= now);&#13;
        icoEndTime = _icoEndTime;&#13;
    }&#13;
}
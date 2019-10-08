pragma solidity 0.4.24;
/**
* @title Circa ICO Contract
* @dev Circa is an ERC-20 Standar Compliant Token
* @author Fares A. Akel C. <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ef89c18e819b80818680c18e848a83af88828e8683c18c8082">[email protected]</a>&#13;
*/&#13;
&#13;
/**&#13;
 * @title SafeMath by OpenZeppelin&#13;
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
/**&#13;
 * @title ERC20Basic&#13;
 * @dev Simpler version of ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/179&#13;
 */&#13;
contract ERC20Basic {&#13;
    function totalSupply() public view returns (uint256);&#13;
    function balanceOf(address who) public view returns (uint256);&#13;
    function transfer(address to, uint256 value) public returns (bool);&#13;
    function transferFrom(address from, address to, uint256 value) public returns (bool);&#13;
    function burnToken(uint256 _burnedAmount) public returns (bool);&#13;
    event Transfer(address indexed from, address indexed to, uint256 value);&#13;
}&#13;
&#13;
/**&#13;
 * @title admined&#13;
 * @notice This contract is administered&#13;
 */&#13;
contract admined {&#13;
    mapping(address =&gt; uint8) level;&#13;
    //0 normal user&#13;
    //1 basic admin&#13;
    //2 master admin&#13;
&#13;
    /**&#13;
    * @dev This contructor set the first master admin&#13;
    */&#13;
    constructor() internal {&#13;
        level[0xEFfea09df22E0B25655BD3f23D9B531ba47d2A8B] = 2; //Set initial admin&#13;
        emit AdminshipUpdated(0xEFfea09df22E0B25655BD3f23D9B531ba47d2A8B,2);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev This modifier limits function execution to the admin by level&#13;
    */&#13;
    modifier onlyAdmin(uint8 _level) { //A modifier to define admin-only functions&#13;
        require(level[msg.sender] &gt;= _level );&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice This function set the adminship level on the contract to _newAdmin&#13;
    * @param _newAdmin The new admin of the contract&#13;
    * @param _level level to set&#13;
    */&#13;
    function adminshipLevel(address _newAdmin, uint8 _level) onlyAdmin(2) public { //Admin can be set&#13;
        require(_newAdmin != address(0));&#13;
        level[_newAdmin] = _level;&#13;
        emit AdminshipUpdated(_newAdmin,_level);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Log Events&#13;
    */&#13;
    event AdminshipUpdated(address _newAdmin, uint8 _level);&#13;
&#13;
}&#13;
&#13;
contract CircaICO is admined {&#13;
&#13;
    using SafeMath for uint256;&#13;
    //This ico have these possible states&#13;
    enum State {&#13;
        PreSale, //PreSale - best value&#13;
        MainSale,&#13;
        Successful&#13;
    }&#13;
    //Public variables&#13;
&#13;
    //Time-state Related&#13;
    State public state = State.PreSale; //Set initial stage&#13;
    uint256 constant public PreSaleStart = 1532908800; //Human time (GMT): Monday, 30 July 2018 0:00:00&#13;
    uint256 constant public PreSaleDeadline = 1534118399; //Human time (GMT): Sunday, 12 August 2018 23:59:59&#13;
    uint256 constant public MainSaleStart = 1535155200; //Human time (GMT): Saturday, 25 August 2018 0:00:00&#13;
    uint256 constant public MainSaleDeadline = 1536105599; //Human time (GMT): Tuesday, 4 September 2018 23:59:59&#13;
    uint256 public completedAt; //Set when ico finish&#13;
&#13;
    //Token-eth related&#13;
    uint256 public totalRaised; //eth collected in wei [INFO]&#13;
    uint256 public PreSaleDistributed; //presale tokens distributed [INFO]&#13;
    uint256 public MainSaleDistributed; //MainSale tokens distributed [INFO]&#13;
    uint256 public PreSaleLimit = 260000000 * (10 ** 18); //260M tokens&#13;
    uint256 public mainSale1Limit = 190000000 * (10 ** 18); // 190M tokens&#13;
    uint256 public totalDistributed; //Whole sale tokens distributed [INFO]&#13;
    ERC20Basic public tokenReward; //Token contract address&#13;
    uint256 public hardCap = 640000000 * (10 ** 18); // 640M tokens (max tokens to be distributed by contract) [INFO]&#13;
    //Contract details&#13;
    address public creator;&#13;
    string public version = '1';&#13;
&#13;
    bool ended = false;&#13;
&#13;
    //Tokens per eth rates&#13;
    uint256[3] rates = [45000,35000,28000];&#13;
&#13;
    //events for log&#13;
    event LogFundrisingInitialized(address _creator);&#13;
    event LogFundingReceived(address _addr, uint _amount, uint _currentTotal);&#13;
    event LogBeneficiaryPaid(address _beneficiaryAddress);&#13;
    event LogContributorsPayout(address _addr, uint _amount);&#13;
    event LogFundingSuccessful(uint _totalRaised);&#13;
&#13;
    //Modifier to prevent execution if ico has ended&#13;
    modifier notFinished() {&#13;
        require(state != State.Successful);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice ICO constructor&#13;
    * @param _addressOfTokenUsedAsReward is the token to distribute&#13;
    */&#13;
    constructor(ERC20Basic _addressOfTokenUsedAsReward) public {&#13;
&#13;
        creator = 0xEFfea09df22E0B25655BD3f23D9B531ba47d2A8B; //Creator is set&#13;
        tokenReward = _addressOfTokenUsedAsReward; //Token address is set during deployment&#13;
&#13;
        emit LogFundrisingInitialized(creator);&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice contribution handler&#13;
    */&#13;
    function contribute() public notFinished payable {&#13;
        require(msg.value &lt;= 500 ether); //No whales&#13;
&#13;
        uint256 tokenBought = 0; //tokens bought variable&#13;
&#13;
        totalRaised = totalRaised.add(msg.value); //ether received updated&#13;
&#13;
        //Rate of exchange depends on stage&#13;
        if (state == State.PreSale){&#13;
&#13;
            require(now &gt;= PreSaleStart);&#13;
&#13;
            tokenBought = msg.value.mul(rates[0]);&#13;
&#13;
            if(PreSaleDistributed &lt;= 30000000 * (10**18)){&#13;
              tokenBought = tokenBought.mul(12);&#13;
              tokenBought = tokenBought.div(10); //+20%&#13;
            } else if (PreSaleDistributed &lt;= 50000000 * (10**18)){&#13;
              tokenBought = tokenBought.mul(11);&#13;
              tokenBought = tokenBought.div(10); //+10%&#13;
            }&#13;
&#13;
            PreSaleDistributed = PreSaleDistributed.add(tokenBought); //Tokens sold on presale updated&#13;
&#13;
        } else if (state == State.MainSale){&#13;
&#13;
            require(now &gt;= MainSaleStart);&#13;
&#13;
            if(MainSaleDistributed &lt; mainSale1Limit){&#13;
              tokenBought = msg.value.mul(rates[1]);&#13;
&#13;
              if(MainSaleDistributed &lt;= 80000000 * (10**18)){&#13;
                tokenBought = tokenBought.mul(12);&#13;
                tokenBought = tokenBought.div(10); //+20%&#13;
              }&#13;
&#13;
            } else tokenBought = msg.value.mul(rates[2]);&#13;
&#13;
            MainSaleDistributed = MainSaleDistributed.add(tokenBought);&#13;
&#13;
        }&#13;
&#13;
        totalDistributed = totalDistributed.add(tokenBought); //whole tokens sold updated&#13;
&#13;
        require(totalDistributed &lt;= hardCap);&#13;
        require(tokenReward.transfer(msg.sender, tokenBought));&#13;
&#13;
        emit LogContributorsPayout(msg.sender, tokenBought);&#13;
        emit LogFundingReceived(msg.sender, msg.value, totalRaised);&#13;
&#13;
        checkIfFundingCompleteOrExpired();&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice check status&#13;
    */&#13;
    function checkIfFundingCompleteOrExpired() public {&#13;
&#13;
        //If hardCap is reached ICO ends&#13;
        if (totalDistributed == hardCap &amp;&amp; state != State.Successful){&#13;
&#13;
            state = State.Successful; //ICO becomes Successful&#13;
            completedAt = now; //ICO is complete&#13;
&#13;
            emit LogFundingSuccessful(totalRaised); //we log the finish&#13;
            successful(); //and execute closure&#13;
&#13;
        } else if(state == State.PreSale &amp;&amp; PreSaleDistributed &gt;= PreSaleLimit){&#13;
&#13;
            state = State.MainSale; //Once presale ends the ICO holds&#13;
&#13;
        }&#13;
    }&#13;
&#13;
    function forceNextStage() onlyAdmin(2) public {&#13;
&#13;
        if(state == State.PreSale &amp;&amp; now &gt; PreSaleDeadline){&#13;
          state = State.MainSale;&#13;
        } else if (state == State.MainSale &amp;&amp; now &gt; MainSaleDeadline ){&#13;
          state = State.Successful; //ICO becomes Successful&#13;
          completedAt = now; //ICO is complete&#13;
&#13;
          emit LogFundingSuccessful(totalRaised); //we log the finish&#13;
          successful(); //and execute closure&#13;
        } else revert();&#13;
&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice successful closure handler&#13;
    */&#13;
    function successful() public {&#13;
        //When successful&#13;
        require(state == State.Successful);&#13;
        if(ended == false){&#13;
            ended = true;&#13;
            //If there is any token left after ico&#13;
            uint256 remanent = hardCap.sub(totalDistributed); //Total tokens to distribute - total distributed&#13;
            //It's burned&#13;
            require(tokenReward.burnToken(remanent));&#13;
        }&#13;
        //After successful all remaining eth is send to creator&#13;
        creator.transfer(address(this).balance);&#13;
        emit LogBeneficiaryPaid(creator);&#13;
&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Manual eth retrieve&#13;
    */&#13;
    function ethRetrieve() onlyAdmin(2) public {&#13;
      creator.transfer(address(this).balance);&#13;
      emit LogBeneficiaryPaid(creator);&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Function to claim any token stuck on contract&#13;
    */&#13;
    function externalTokensRecovery(ERC20Basic _address) onlyAdmin(2) public{&#13;
        require(state == State.Successful);&#13;
&#13;
        uint256 remainder = _address.balanceOf(this); //Check remainder tokens&#13;
        _address.transfer(msg.sender,remainder); //Transfer tokens to admin&#13;
&#13;
    }&#13;
&#13;
    /*&#13;
    * @dev Direct payments handler&#13;
    */&#13;
&#13;
    function () public payable {&#13;
&#13;
        contribute();&#13;
&#13;
    }&#13;
}
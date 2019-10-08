pragma solidity ^0.4.11;
/*
Moira ICO Contract

MOI is an ERC-20 Token Standar Compliant

Contract developer: Fares A. Akel C.
<span class="__cf_email__" data-cfemail="b2d49cd3dcc6dddcdbdd9cd3d9d7def2d5dfd3dbde9cd1dddf">[email protected]</span>&#13;
MIT PGP KEY ID: 078E41CB&#13;
*/&#13;
&#13;
/**&#13;
 * @title SafeMath by OpenZeppelin&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
library SafeMath {&#13;
&#13;
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        uint256 c = a * b;&#13;
        assert(a == 0 || c / a == b);&#13;
        return c;&#13;
    }&#13;
&#13;
    function add(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        uint256 c = a + b;&#13;
        assert(c &gt;= a);&#13;
        return c;&#13;
    }&#13;
}&#13;
&#13;
contract token { //Token functions definition&#13;
&#13;
    function balanceOf(address _owner) public constant returns (uint256 balance);&#13;
    function transfer(address _to, uint256 _value) public returns (bool success);&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);&#13;
    function approve(address _spender, uint256 _value) public returns (bool success);&#13;
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);&#13;
    }&#13;
contract MOIRAICO {&#13;
    //This ico have 4 stages for 4 weeks and the Successful stage when finished&#13;
    enum State {&#13;
        Preico,&#13;
        Ico,&#13;
        Successful&#13;
    }&#13;
    &#13;
    State public state = State.Preico; //Set initial stage&#13;
    uint startTime = now; //block-time when it was deployed&#13;
&#13;
    //List of prices for each stage, as both, eth and moi have 18 decimal, its a direct factor&#13;
    uint[4] tablePrices = [&#13;
    58000,&#13;
    63800,&#13;
    32200&#13;
    ];&#13;
&#13;
    mapping (address =&gt; uint) balances; //balances mapping&#13;
    //public variables&#13;
    uint public totalRaised;&#13;
    uint public currentBalance;&#13;
    uint public preICODeadline;&#13;
    uint public ICOdeadline;&#13;
    uint public completedAt;&#13;
    token public tokenReward;&#13;
    address public creator;&#13;
    address public beneficiary; &#13;
    string public campaignUrl;&#13;
    uint constant version = 1;&#13;
&#13;
    //events for log&#13;
&#13;
    event LogFundingReceived(address _addr, uint _amount, uint _currentTotal);&#13;
    event LogBeneficiaryPaid(address _beneficiaryAddress);&#13;
    event LogFundingSuccessful(uint _totalRaised);&#13;
    event LogFunderInitialized(&#13;
        address _creator,&#13;
        address _beneficiary,&#13;
        string _url,&#13;
        uint256 _preICODeadline,&#13;
        uint256 _ICOdeadline);&#13;
    event LogContributorsPayout(address _addr, uint _amount);&#13;
&#13;
    modifier notFinished() {&#13;
        require(state != State.Successful);&#13;
        _;&#13;
    }&#13;
&#13;
    function MOIRAICO (&#13;
        string _campaignUrl,&#13;
        token _addressOfTokenUsedAsReward )&#13;
        public&#13;
    {&#13;
        creator = msg.sender;&#13;
        beneficiary = msg.sender;&#13;
        campaignUrl = _campaignUrl;&#13;
        preICODeadline = SafeMath.add(startTime,34 days);&#13;
        ICOdeadline = SafeMath.add(preICODeadline,30 days);&#13;
        currentBalance = 0;&#13;
        tokenReward = token(_addressOfTokenUsedAsReward);&#13;
        LogFunderInitialized(&#13;
            creator,&#13;
            beneficiary,&#13;
            campaignUrl,&#13;
            preICODeadline,&#13;
            ICOdeadline);&#13;
    }&#13;
&#13;
    function contribute() public notFinished payable {&#13;
&#13;
        require(msg.value &gt; 1 finney); //minimun contribution&#13;
&#13;
        uint tokenBought;&#13;
        totalRaised =SafeMath.add(totalRaised, msg.value);&#13;
        currentBalance = totalRaised;&#13;
&#13;
        if(state == State.Preico){&#13;
            tokenBought = SafeMath.mul(msg.value,tablePrices[0]);&#13;
        }&#13;
        else if(state == State.Preico &amp;&amp; now &lt; (startTime + 1 days)) {&#13;
            tokenBought = SafeMath.mul(msg.value,tablePrices[1]);&#13;
        }&#13;
        else{&#13;
            tokenBought = SafeMath.mul(msg.value,tablePrices[2]);&#13;
        }&#13;
&#13;
        tokenReward.transfer(msg.sender, tokenBought);&#13;
        &#13;
        LogFundingReceived(msg.sender, msg.value, totalRaised);&#13;
        LogContributorsPayout(msg.sender, tokenBought);&#13;
        &#13;
        checkIfFundingCompleteOrExpired();&#13;
    }&#13;
&#13;
    function checkIfFundingCompleteOrExpired() public {&#13;
        &#13;
        if(now &lt; ICOdeadline &amp;&amp; state!=State.Successful){&#13;
            if(now &gt; preICODeadline &amp;&amp; state==State.Preico){&#13;
                state = State.Ico;    &#13;
            }&#13;
        }&#13;
        else if(now &gt; ICOdeadline &amp;&amp; state!=State.Successful) {&#13;
            state = State.Successful;&#13;
            completedAt = now;&#13;
            LogFundingSuccessful(totalRaised);&#13;
            finished();  &#13;
        }&#13;
    }&#13;
&#13;
    function finished() public { //When finished eth and remaining tokens are transfered to beneficiary&#13;
        uint remanent;&#13;
&#13;
        require(state == State.Successful);&#13;
        require(beneficiary.send(this.balance));&#13;
        remanent =  tokenReward.balanceOf(this);&#13;
        tokenReward.transfer(beneficiary,remanent);&#13;
&#13;
        currentBalance = 0;&#13;
&#13;
        LogBeneficiaryPaid(beneficiary);&#13;
        LogContributorsPayout(beneficiary, remanent);&#13;
    }&#13;
&#13;
    function () public payable {&#13;
        require(msg.value &gt; 1 finney);&#13;
        contribute();&#13;
    }&#13;
}
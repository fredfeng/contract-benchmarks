pragma solidity ^0.4.24;

//    _____ _     _      _                _____           _    
//   / ____| |   (_)    | |              |  __ \         | |   
//  | |    | |__  _  ___| | _____ _ __   | |__) |_ _ _ __| | __
//  | |    | '_ \| |/ __| |/ / _ \ '_ \  |  ___/ _` | '__| |/ /
//  | |____| | | | | (__|   <  __/ | | | | |  | (_| | |  |   < 
//   \_____|_| |_|_|\___|_|\_\___|_| |_| |_|   \__,_|_|  |_|\_\

// ------- What? ------- 
//A home for blockchain games.

// ------- How? ------- 
//Buy CKN Token before playing any games.
//You can buy & sell CKN in this contract at anytime and anywhere.
//As the amount of ETH in the contract increases to 10,000, the dividend will gradually drop to 2%.

//We got 4 phase in the Roadmap, will launch Plasma chain in the phase 2.

// ------- How? ------- 
//10/2018 SIMPLE E-SPORT
//11/2018 SPORT PREDICTION
//02/2019 MOBILE GAME
//06/2019 MMORPG

// ------- Who? ------- 
//Only 1/10 smarter than vitalik.
//<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="4120252c282f01222928222a242f3120332a6f282e">[email protected]</a>&#13;
//Sometime we think plama is a Pseudo topic, but it's a only way to speed up the TPS.&#13;
//And Everybody will also trust the Node &amp; Result.&#13;
&#13;
library SafeMath {&#13;
    &#13;
    /**&#13;
    * @dev Multiplies two numbers, throws on overflow.&#13;
    */&#13;
    function mul(uint256 a, uint256 b) &#13;
        internal &#13;
        pure &#13;
        returns (uint256 c) &#13;
    {&#13;
        if (a == 0) {&#13;
            return 0;&#13;
        }&#13;
        c = a * b;&#13;
        require(c / a == b, "SafeMath mul failed");&#13;
        return c;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).&#13;
    */&#13;
    function sub(uint256 a, uint256 b)&#13;
        internal&#13;
        pure&#13;
        returns (uint256) &#13;
    {&#13;
        require(b &lt;= a, "SafeMath sub failed");&#13;
        return a - b;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Adds two numbers, throws on overflow.&#13;
    */&#13;
    function add(uint256 a, uint256 b)&#13;
        internal&#13;
        pure&#13;
        returns (uint256 c) &#13;
    {&#13;
        c = a + b;&#13;
        require(c &gt;= a, "SafeMath add failed");&#13;
        return c;&#13;
    }&#13;
    &#13;
    /**&#13;
     * @dev gives square root of given x.&#13;
     */&#13;
    function sqrt(uint256 x)&#13;
        internal&#13;
        pure&#13;
        returns (uint256 y) &#13;
    {&#13;
        uint256 z = ((add(x,1)) / 2);&#13;
        y = x;&#13;
        while (z &lt; y) &#13;
        {&#13;
            y = z;&#13;
            z = ((add((x / z),z)) / 2);&#13;
        }&#13;
    }&#13;
    &#13;
    /**&#13;
     * @dev gives square. multiplies x by x&#13;
     */&#13;
    function sq(uint256 x)&#13;
        internal&#13;
        pure&#13;
        returns (uint256)&#13;
    {&#13;
        return (mul(x,x));&#13;
    }&#13;
    &#13;
    /**&#13;
     * @dev x to the power of y &#13;
     */&#13;
    function pwr(uint256 x, uint256 y)&#13;
        internal &#13;
        pure &#13;
        returns (uint256)&#13;
    {&#13;
        if (x==0)&#13;
            return (0);&#13;
        else if (y==0)&#13;
            return (1);&#13;
        else &#13;
        {&#13;
            uint256 z = x;&#13;
            for (uint256 i=1; i &lt; y; i++)&#13;
                z = mul(z,x);&#13;
            return (z);&#13;
        }&#13;
    }   &#13;
}&#13;
&#13;
contract ERC223ReceivingContract { &#13;
/**&#13;
 * @dev Standard ERC223 function that will handle incoming token transfers.&#13;
 *&#13;
 * @param _from  Token sender address.&#13;
 * @param _value Amount of tokens.&#13;
 * @param _data  Transaction metadata.&#13;
 */&#13;
    function tokenFallback(address _from, uint _value, bytes _data)public;&#13;
}&#13;
&#13;
contract Owned {&#13;
    address public owner;&#13;
    address public newOwner;&#13;
&#13;
    event OwnershipTransferred(address indexed _from, address indexed _to);&#13;
&#13;
    constructor() public {&#13;
        owner = msg.sender;&#13;
    }&#13;
&#13;
    modifier onlyOwner {&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
&#13;
    function transferOwnership(address _newOwner) public onlyOwner {&#13;
        newOwner = _newOwner;&#13;
    }&#13;
    function acceptOwnership() public {&#13;
        require(msg.sender == newOwner);&#13;
        emit OwnershipTransferred(owner, newOwner);&#13;
        owner = newOwner;&#13;
        newOwner = address(0);&#13;
    }&#13;
}&#13;
&#13;
contract ApproveAndCallFallBack {&#13;
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;&#13;
}&#13;
&#13;
contract ChickenPark is Owned{&#13;
&#13;
    using SafeMath for *;&#13;
&#13;
    modifier notContract() {&#13;
        require (msg.sender == tx.origin);&#13;
        _;&#13;
    }&#13;
    &#13;
    event Transfer(&#13;
        address indexed from,&#13;
        address indexed to,&#13;
        uint tokens&#13;
    );&#13;
&#13;
    event Approval(&#13;
        address indexed tokenOwner,&#13;
        address indexed spender,&#13;
        uint tokens&#13;
    );&#13;
&#13;
    event CKNPrice(&#13;
        address indexed who,&#13;
        uint prePrice,&#13;
        uint afterPrice,&#13;
        uint ethValue,&#13;
        uint token,&#13;
        uint timestamp,&#13;
        string action&#13;
    );&#13;
    &#13;
    event Withdraw(&#13;
        address indexed who,&#13;
        uint dividents&#13;
    );&#13;
&#13;
    /*=====================================&#13;
    =            CONSTANTS                =&#13;
    =====================================*/&#13;
    uint8 constant public                decimals              = 18;&#13;
    uint constant internal               tokenPriceInitial_    = 0.00001 ether;&#13;
    uint constant internal               magnitude             = 2**64;&#13;
&#13;
    /*================================&#13;
    =          CONFIGURABLES         =&#13;
    ================================*/&#13;
    string public                        name               = "Chicken Park Coin";&#13;
    string public                        symbol             = "CKN";&#13;
&#13;
    /*================================&#13;
    =            DATASETS            =&#13;
    ================================*/&#13;
&#13;
    // Tracks Token&#13;
    mapping(address =&gt; uint) internal    balances;&#13;
    mapping(address =&gt; mapping (address =&gt; uint))public allowed;&#13;
&#13;
    // Payout tracking&#13;
    mapping(address =&gt; uint)    public referralBalance_;&#13;
    mapping(address =&gt; int256)  public payoutsTo_;&#13;
    uint256 public profitPerShare_ = 0;&#13;
    &#13;
    // Token&#13;
    uint internal tokenSupply = 0;&#13;
&#13;
    // Sub Contract&#13;
    address public marketAddress;&#13;
    address public gameAddress;&#13;
&#13;
    /*================================&#13;
    =            FUNCTION            =&#13;
    ================================*/&#13;
&#13;
    constructor() public {&#13;
&#13;
    }&#13;
&#13;
    function totalSupply() public view returns (uint) {&#13;
        return tokenSupply.sub(balances[address(0)]);&#13;
    }&#13;
&#13;
    // ------------------------------------------------------------------------&#13;
    // Get the token balance for account `tokenOwner`  CKN&#13;
    // ------------------------------------------------------------------------&#13;
    function balanceOf(address tokenOwner) public view returns (uint balance) {&#13;
        return balances[tokenOwner];&#13;
    }&#13;
&#13;
    // ------------------------------------------------------------------------&#13;
    // Get the referral balance for account `tokenOwner`   ETH&#13;
    // ------------------------------------------------------------------------&#13;
    function referralBalanceOf(address tokenOwner) public view returns(uint){&#13;
        return referralBalance_[tokenOwner];&#13;
    }&#13;
&#13;
    function setMarket(address add) public onlyOwner{&#13;
        marketAddress = add;&#13;
    }&#13;
&#13;
    function setGame(address add) public onlyOwner{&#13;
        gameAddress = add;&#13;
    }&#13;
&#13;
    // ------------------------------------------------------------------------&#13;
    // ERC20 Basic Function: Transfer CKN Token&#13;
    // ------------------------------------------------------------------------&#13;
    function transfer(address to, uint tokens) public returns (bool success) {&#13;
        require(balances[msg.sender] &gt;= tokens);&#13;
&#13;
        payoutsTo_[msg.sender] = payoutsTo_[msg.sender] - int(tokens.mul(profitPerShare_)/1e18);&#13;
        payoutsTo_[to] = payoutsTo_[to] + int(tokens.mul(profitPerShare_)/1e18);&#13;
        balances[msg.sender] = balances[msg.sender].sub(tokens);&#13;
        balances[to] = balances[to].add(tokens);&#13;
&#13;
        emit Transfer(msg.sender, to, tokens);&#13;
        return true;&#13;
    }&#13;
&#13;
    function approve(address spender, uint tokens) public returns (bool success) {&#13;
        allowed[msg.sender][spender] = tokens;&#13;
        emit Approval(msg.sender, spender, tokens);&#13;
        return true;&#13;
    }&#13;
&#13;
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {&#13;
        require(tokens &lt;= balances[from] &amp;&amp;  tokens &lt;= allowed[from][msg.sender]);&#13;
&#13;
        payoutsTo_[from] = payoutsTo_[from] - int(tokens.mul(profitPerShare_)/1e18);&#13;
        payoutsTo_[to] = payoutsTo_[to] + int(tokens.mul(profitPerShare_)/1e18);&#13;
        balances[from] = balances[from].sub(tokens);&#13;
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);&#13;
        balances[to] = balances[to].add(tokens);&#13;
        emit Transfer(from, to, tokens);&#13;
        return true;&#13;
    }&#13;
&#13;
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {&#13;
        return allowed[tokenOwner][spender];&#13;
    }&#13;
&#13;
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {&#13;
        allowed[msg.sender][spender] = tokens;&#13;
        emit Approval(msg.sender, spender, tokens);&#13;
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);&#13;
        return true;&#13;
    }&#13;
&#13;
    // ------------------------------------------------------------------------&#13;
    // Buy Chicken Park Coin, 1% for me, 1% for chicken market, 19.6 ~ 0% for dividents&#13;
    // ------------------------------------------------------------------------&#13;
    function buyChickenParkCoin(address referedAddress) notContract() public payable{&#13;
        uint fee = msg.value.mul(2)/100;&#13;
        owner.transfer(fee/2);&#13;
&#13;
        marketAddress.transfer(fee/2);&#13;
&#13;
        uint realBuy = msg.value.sub(fee).mul((1e20).sub(calculateDivi()))/1e20;&#13;
        uint divMoney = msg.value.sub(realBuy).sub(fee);&#13;
&#13;
        if(referedAddress != msg.sender &amp;&amp; referedAddress != address(0)){&#13;
            uint referralMoney = divMoney/10;&#13;
            referralBalance_[referedAddress] = referralBalance_[referedAddress].add(referralMoney);&#13;
            divMoney = divMoney.sub(referralMoney);&#13;
        }&#13;
&#13;
        uint tokenAdd = getBuy(realBuy);&#13;
        uint price1 = getCKNPriceNow();&#13;
&#13;
        tokenSupply = tokenSupply.add(tokenAdd);&#13;
&#13;
        payoutsTo_[msg.sender] += (int256)(profitPerShare_.mul(tokenAdd)/1e18);&#13;
        profitPerShare_ = profitPerShare_.add(divMoney.mul(1e18)/totalSupply());&#13;
        balances[msg.sender] = balances[msg.sender].add(tokenAdd);&#13;
&#13;
        uint price2 = getCKNPriceNow();&#13;
&#13;
        emit CKNPrice(msg.sender,price1,price2,msg.value,tokenAdd,now,"BUY");&#13;
    } &#13;
&#13;
    // ------------------------------------------------------------------------&#13;
    // Sell Chicken Park Coin, 1% for me, 1% for chicken market, 19.6 ~ 0% for dividents&#13;
    // ------------------------------------------------------------------------&#13;
    function sellChickenParkCoin(uint tokenAnount) notContract() public {&#13;
        uint tokenSub = tokenAnount;&#13;
        uint sellEther = getSell(tokenSub);&#13;
        uint price1 = getCKNPriceNow();&#13;
&#13;
        payoutsTo_[msg.sender] = payoutsTo_[msg.sender] - int(tokenSub.mul(profitPerShare_)/1e18);&#13;
        tokenSupply = tokenSupply.sub(tokenSub);&#13;
&#13;
        balances[msg.sender] = balances[msg.sender].sub(tokenSub);&#13;
        uint diviTo = sellEther.mul(calculateDivi())/1e20;&#13;
&#13;
        if(totalSupply()&gt;0){&#13;
            profitPerShare_ = profitPerShare_.add(diviTo.mul(1e18)/totalSupply());&#13;
        }else{&#13;
            owner.transfer(diviTo); &#13;
        }&#13;
&#13;
        owner.transfer(sellEther.mul(1)/100);&#13;
        marketAddress.transfer(sellEther.mul(1)/100);&#13;
&#13;
        msg.sender.transfer((sellEther.mul(98)/(100)).sub(diviTo));&#13;
&#13;
        uint price2 = getCKNPriceNow();&#13;
        emit CKNPrice(msg.sender,price1,price2,sellEther,tokenSub,now,"SELL");&#13;
    }&#13;
&#13;
    // ------------------------------------------------------------------------&#13;
    // Withdraw your ETH dividents from Referral &amp; CKN Dividents&#13;
    // ------------------------------------------------------------------------&#13;
    function withdraw() notContract() public {&#13;
        require(myDividends(true)&gt;0);&#13;
&#13;
        uint dividents_ = uint(getDividents()).add(referralBalance_[msg.sender]);&#13;
        payoutsTo_[msg.sender] = payoutsTo_[msg.sender] + int(getDividents());&#13;
        referralBalance_[msg.sender] = 0;&#13;
&#13;
        msg.sender.transfer(dividents_);&#13;
        emit Withdraw(msg.sender, dividents_);&#13;
    }&#13;
    &#13;
    // ------------------------------------------------------------------------&#13;
    // ERC223 Transfer CKN Token With Data Function&#13;
    // ------------------------------------------------------------------------&#13;
    function transferTo (address _from, address _to, uint _amountOfTokens, bytes _data) public {&#13;
        if (_from != msg.sender){&#13;
            require(_amountOfTokens &lt;= balances[_from] &amp;&amp;  _amountOfTokens &lt;= allowed[_from][msg.sender]);&#13;
        }&#13;
        else{&#13;
            require(_amountOfTokens &lt;= balances[_from]);&#13;
        }&#13;
&#13;
        transferFromInternal(_from, _to, _amountOfTokens, _data);&#13;
    }&#13;
&#13;
    function transferFromInternal(address _from, address _toAddress, uint _amountOfTokens, bytes _data) internal&#13;
    {&#13;
        require(_toAddress != address(0x0));&#13;
        address _customerAddress     = _from;&#13;
        &#13;
        if (_customerAddress != msg.sender){&#13;
        // Update the allowed balance.&#13;
        // Don't update this if we are transferring our own tokens (via transfer or buyAndTransfer)&#13;
            allowed[_customerAddress][msg.sender] = allowed[_customerAddress][msg.sender].sub(_amountOfTokens);&#13;
        }&#13;
&#13;
        // Exchange tokens&#13;
        balances[_customerAddress]    = balances[_customerAddress].sub(_amountOfTokens);&#13;
        balances[_toAddress]          = balances[_toAddress].add(_amountOfTokens);&#13;
&#13;
        // Update dividend trackers&#13;
        payoutsTo_[_customerAddress] -= (int256)(profitPerShare_.mul(_amountOfTokens)/1e18);&#13;
        payoutsTo_[_toAddress]       +=  (int256)(profitPerShare_.mul(_amountOfTokens)/1e18);&#13;
&#13;
        uint length;&#13;
&#13;
        assembly {&#13;
            length := extcodesize(_toAddress)&#13;
        }&#13;
&#13;
        if (length &gt; 0){&#13;
        // its a contract&#13;
        // note: at ethereum update ALL addresses are contracts&#13;
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_toAddress);&#13;
            receiver.tokenFallback(_from, _amountOfTokens, _data);&#13;
        }&#13;
&#13;
        // Fire logging event.&#13;
        emit Transfer(_customerAddress, _toAddress, _amountOfTokens);&#13;
    }&#13;
&#13;
    function getCKNPriceNow() public view returns(uint){&#13;
        return (tokenPriceInitial_.mul(1e18+totalSupply()/100000000))/(1e18);&#13;
    }&#13;
&#13;
    function getBuy(uint eth) public view returns(uint){&#13;
        return ((((1e36).add(totalSupply().sq()/1e16).add(totalSupply().mul(2).mul(1e10)).add(eth.mul(1e28).mul(2)/tokenPriceInitial_)).sqrt()).sub(1e18).sub(totalSupply()/1e8)).mul(1e8);&#13;
    }&#13;
&#13;
    function calculateDivi()public view returns(uint){&#13;
        if(totalSupply() &lt; 4e26){&#13;
            uint diviRate = (20e18).sub(totalSupply().mul(5)/1e8);&#13;
            return diviRate;&#13;
        } else {&#13;
            return 0;&#13;
        }&#13;
    }&#13;
&#13;
    function getSell(uint token) public view returns(uint){&#13;
        return tokenPriceInitial_.mul((1e18).add((totalSupply().sub(token/2))/100000000)).mul(token)/(1e36);&#13;
    }&#13;
&#13;
    function myDividends(bool _includeReferralBonus) public view returns(uint256)&#13;
    {&#13;
        address _customerAddress = msg.sender;&#13;
        return _includeReferralBonus ? getDividents().add(referralBalance_[_customerAddress]) : getDividents() ;&#13;
    }&#13;
&#13;
    function getDividents() public view returns(uint){&#13;
        require(int((balances[msg.sender].mul(profitPerShare_)/1e18))-(payoutsTo_[msg.sender])&gt;=0);&#13;
        return uint(int((balances[msg.sender].mul(profitPerShare_)/1e18))-(payoutsTo_[msg.sender]));&#13;
    }&#13;
&#13;
}
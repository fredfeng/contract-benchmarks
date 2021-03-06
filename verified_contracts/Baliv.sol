pragma solidity ^0.4.20;

/*
Project: XPA Exchange - https://xpa.exchange
Author : Luphia Chang - <span class="__cf_email__" data-cfemail="8de1f8fde5e4eca3eee5ece3eacde4fef8e3eee1e2f8e9a3eee2e0">[email protected]</span>&#13;
 */&#13;
&#13;
interface Token {&#13;
    function totalSupply() constant external returns (uint256 ts);&#13;
    function balanceOf(address _owner) constant external returns (uint256 balance);&#13;
    function transfer(address _to, uint256 _value) external returns (bool success);&#13;
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);&#13;
    function approve(address _spender, uint256 _value) external returns (bool success);&#13;
    function allowance(address _owner, address _spender) constant external returns (uint256 remaining);&#13;
}&#13;
&#13;
contract SafeMath {&#13;
    function safeAdd(uint x, uint y)&#13;
        internal&#13;
        pure&#13;
    returns(uint) {&#13;
      uint256 z = x + y;&#13;
      require((z &gt;= x) &amp;&amp; (z &gt;= y));&#13;
      return z;&#13;
    }&#13;
&#13;
    function safeSub(uint x, uint y)&#13;
        internal&#13;
        pure&#13;
    returns(uint) {&#13;
      require(x &gt;= y);&#13;
      uint256 z = x - y;&#13;
      return z;&#13;
    }&#13;
&#13;
    function safeMul(uint x, uint y)&#13;
        internal&#13;
        pure&#13;
    returns(uint) {&#13;
      uint z = x * y;&#13;
      require((x == 0) || (z / x == y));&#13;
      return z;&#13;
    }&#13;
    &#13;
    function safeDiv(uint x, uint y)&#13;
        internal&#13;
        pure&#13;
    returns(uint) {&#13;
        require(y &gt; 0);&#13;
        return x / y;&#13;
    }&#13;
&#13;
    function random(uint N, uint salt)&#13;
        internal&#13;
        view&#13;
    returns(uint) {&#13;
      bytes32 hash = keccak256(block.number, msg.sender, salt);&#13;
      return uint(hash) % N;&#13;
    }&#13;
}&#13;
&#13;
contract Authorization {&#13;
    mapping(address =&gt; address) public agentBooks;&#13;
    address public owner;&#13;
    address public operator;&#13;
    address public bank;&#13;
    bool public powerStatus = true;&#13;
&#13;
    function Authorization()&#13;
        public&#13;
    {&#13;
        owner = msg.sender;&#13;
        operator = msg.sender;&#13;
        bank = msg.sender;&#13;
    }&#13;
&#13;
    modifier onlyOwner&#13;
    {&#13;
        assert(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
    modifier onlyOperator&#13;
    {&#13;
        assert(msg.sender == operator || msg.sender == owner);&#13;
        _;&#13;
    }&#13;
    modifier onlyActive&#13;
    {&#13;
        assert(powerStatus);&#13;
        _;&#13;
    }&#13;
&#13;
    function transferOwnership(address newOwner_)&#13;
        onlyOwner&#13;
        public&#13;
    {&#13;
        owner = newOwner_;&#13;
    }&#13;
    &#13;
    function assignOperator(address user_)&#13;
        public&#13;
        onlyOwner&#13;
    {&#13;
        operator = user_;&#13;
        agentBooks[bank] = user_;&#13;
    }&#13;
    &#13;
    function assignBank(address bank_)&#13;
        public&#13;
        onlyOwner&#13;
    {&#13;
        bank = bank_;&#13;
    }&#13;
&#13;
    function assignAgent(&#13;
        address agent_&#13;
    )&#13;
        public&#13;
    {&#13;
        agentBooks[msg.sender] = agent_;&#13;
    }&#13;
&#13;
    function isRepresentor(&#13;
        address representor_&#13;
    )&#13;
        public&#13;
        view&#13;
    returns(bool) {&#13;
        return agentBooks[representor_] == msg.sender;&#13;
    }&#13;
&#13;
    function getUser(&#13;
        address representor_&#13;
    )&#13;
        internal&#13;
        view&#13;
    returns(address) {&#13;
        return isRepresentor(representor_) ? representor_ : msg.sender;&#13;
    }&#13;
}&#13;
&#13;
/*  Error Code&#13;
    0: insufficient funds (user)&#13;
    1: insufficient funds (contract)&#13;
    2: invalid amount&#13;
    3: invalid price&#13;
 */&#13;
&#13;
/*&#13;
    1. 檢驗是否指定代理用戶，若是且為合法代理人則將操作角色轉換為被代理人，否則操作角色不變&#13;
    2. 檢驗此操作是否有存入 ETH，有則暫時紀錄存入額度 A，若掛單指定 fromToken 不是 ETH 則直接更新用戶 ETH 帳戶餘額&#13;
    3. 檢驗此操作是否有存入 fromToken，有則暫時紀錄存入額度 A&#13;
    4. 檢驗用戶 fromToken 帳戶餘額 + 存入額度 A 是否 &gt;= Amount，若是送出 makeOrder 掛單事件，否則結束操作&#13;
    5. 依照 fromToken、toToken 尋找可匹配的交易對 P&#13;
    6. 找出 P 的最低價格單進行匹配，記錄匹配數量，送出 fillOrder 成交事件，並結算 maker 交易結果，若成交完還有掛單數量有剩且未達迴圈次數上限則重複此步驟&#13;
    7. 統計步驟 6 總成交量、交易價差利潤、交易手續費&#13;
    8. 若扣除總成交量後 Taker 掛單尚未撮合完，則將剩餘額度轉換為 Maker 單&#13;
    9. 結算交易所手續費&#13;
    10. 結算 Taker 交易結果&#13;
 */&#13;
&#13;
contract Baliv is SafeMath, Authorization {&#13;
    /* struct for exchange data */&#13;
    struct linkedBook {&#13;
        uint256 amount;&#13;
        address nextUser;&#13;
    }&#13;
&#13;
    /* business options */&#13;
    mapping(address =&gt; uint256) public minAmount;&#13;
    uint256[3] public feerate = [0, 1 * (10 ** 15), 1 * (10 ** 15)];&#13;
    uint256 public autoMatch = 10;&#13;
    uint256 public maxAmount = 10 ** 27;&#13;
    uint256 public maxPrice = 10 ** 36;&#13;
    address public XPAToken = 0x0090528aeb3a2b736b780fd1b6c478bb7e1d643170;&#13;
&#13;
    /* exchange data */&#13;
    mapping(address =&gt; mapping(address =&gt; mapping(uint256 =&gt; mapping(address =&gt; linkedBook)))) public orderBooks;&#13;
    mapping(address =&gt; mapping(address =&gt; mapping(uint256 =&gt; uint256))) public nextOrderPrice;&#13;
    mapping(address =&gt; mapping(address =&gt; uint256)) public priceBooks;&#13;
    &#13;
    /* user data */&#13;
    mapping(address =&gt; mapping(address =&gt; uint256)) public balances;&#13;
    mapping(address =&gt; bool) internal manualWithdraw;&#13;
&#13;
    /* event */&#13;
    event eDeposit(address user,address token, uint256 amount);&#13;
    event eWithdraw(address user,address token, uint256 amount);&#13;
    event eMakeOrder(address fromToken, address toToken, uint256 price, address user, uint256 amount);&#13;
    event eFillOrder(address fromToken, address toToken, uint256 price, address user, uint256 amount);&#13;
    event eCancelOrder(address fromToken, address toToken, uint256 price, address user, uint256 amount);&#13;
&#13;
    //event Error(uint256 code);&#13;
&#13;
    /* constructor */&#13;
    function Baliv() public {}&#13;
&#13;
    /* Operator Function&#13;
        function setup(uint256 autoMatch, uint256 maxAmount, uint256 maxPrice) external;&#13;
        function setMinAmount(address token, uint256 amount) external;&#13;
        function setFeerate(uint256[3] [maker, taker, autoWithdraw]) external;&#13;
    */&#13;
&#13;
    /* External Function&#13;
        function () public payable;&#13;
        function deposit(address token, address representor) external payable;&#13;
        function withdraw(address token, uint256 amount, address representor) external returns(bool);&#13;
        function userTakeOrder(address fromToken, address toToken, uint256 price, uint256 amount, address representor) external payable returns(bool);&#13;
        function userCancelOrder(address fromToken, address toToken, uint256 price, uint256 amount, address representor) external returns(bool);&#13;
        function caculateFee(address user, uint256 amount, uint8 role) external returns(uint256 remaining, uint256 fee);&#13;
        function trade(address fromToken, address toToken) external;&#13;
        function setManualWithdraw(bool) external;&#13;
        function getMinAmount(address) external returns(uint256);&#13;
    */&#13;
&#13;
    /* Internal Function&#13;
        function depositAndFreeze(address token, address user) internal payable returns(uint256 amount);&#13;
        function checkBalance(address user, address token, uint256 amount, uint256 depositAmount) internal returns(bool);&#13;
        function checkAmount(address token, uint256 amount) internal returns(bool);&#13;
        function checkPriceAmount(uint256 price) internal returns(bool);&#13;
        function makeOrder(address fromToken, address toToken, uint256 price, uint256 amount, address user, uint256 depositAmount) internal returns(uint256 amount);&#13;
        function findAndTrade(address fromToken, address toToken, uint256 price, uint256 amount) internal returns(uint256[2] totalMatchAmount[fromToken, toToken], uint256[2] profit[fromToken, toToken]);&#13;
        function makeTrade(address fromToken, address toToken, uint256 price, uint256 bestPrice, uint256 prevBestPrice, uint256 remainingAmount) internal returns(uint256[3] [fillTaker, fillMaker, makerFee]);&#13;
        function makeTradeDetail(address fromToken, address toToken, uint256 price, uint256 bestPrice, address maker, uint256 remainingAmount) internal returns(uint256[3] [fillTaker, fillMaker, makerFee], bool makerFullfill);&#13;
        function caculateFill(uint256 provide, uint256 require, uint256 price, uint256 pairProvide) internal pure returns(uint256 fillAmount);&#13;
        function checkPricePair(uint256 price, uint256 bestPrice) internal pure returns(bool matched);&#13;
        function fillOrder(address fromToken, address toToken, uint256 price, uint256 amount) internal returns(uint256 fee);&#13;
        function transferToken(address user, address token, uint256 amount) internal returns(bool);&#13;
        function updateBalance(address user, address token, uint256 amount, bool addOrSub) internal returns(bool);&#13;
        function connectOrderPrice(address fromToken, address toToken, uint256 price, uint256 prevPrice) internal;&#13;
        function connectOrderUser(address fromToken, address toToken, uint256 price, address user) internal;&#13;
        function disconnectOrderPrice(address fromToken, address toToken, uint256 price, uint256 prevPrice) internal;&#13;
        function disconnectOrderUser(address fromToken, address toToken, uint256 price, uint256 prevPrice, address user, address prevUser) internal;&#13;
        function getNextOrderPrice(address fromToken, address toToken, uint256 price) internal view returns(uint256 price);&#13;
        function updateNextOrderPrice(address fromToken, address toToken, uint256 price, uint256 nextPrice) internal;&#13;
        function getNexOrdertUser(address fromToken, address toToken, uint256 price, address user) internal view returns(address nextUser);&#13;
        function getOrderAmount(address fromToken, address toToken, uint256 price, address user) internal view returns(uint256 amount);&#13;
        function updateNextOrderUser(address fromToken, address toToken, uint256 price, address user, address nextUser) internal;&#13;
        function updateOrderAmount(address fromToken, address toToken, uint256 price, address user, uint256 amount, bool addOrSub) internal;&#13;
    */&#13;
&#13;
    /* Operator function */&#13;
    function setup(&#13;
        uint256 autoMatch_,&#13;
        uint256 maxAmount_,&#13;
        uint256 maxPrice_,&#13;
        bool power_&#13;
    )&#13;
        onlyOperator&#13;
        public&#13;
    {&#13;
        autoMatch = autoMatch_;&#13;
        maxAmount = maxAmount_;&#13;
        maxPrice = maxPrice_;&#13;
        powerStatus = power_;&#13;
    }&#13;
    &#13;
    function setMinAmount(&#13;
        address token_,&#13;
        uint256 amount_&#13;
    )&#13;
        onlyOperator&#13;
        public&#13;
    {&#13;
        minAmount[token_] = amount_;&#13;
    }&#13;
    &#13;
    function getMinAmount(&#13;
        address token_&#13;
    )&#13;
        public&#13;
        view&#13;
    returns(uint256) {&#13;
        return minAmount[token_] &gt; 0&#13;
            ? minAmount[token_]&#13;
            : minAmount[0];&#13;
    }&#13;
    &#13;
    function setFeerate(&#13;
        uint256[3] feerate_&#13;
    )&#13;
        onlyOperator&#13;
        public&#13;
    {&#13;
        require(feerate_[0] &lt; 0.05 ether &amp;&amp; feerate_[1] &lt; 0.05 ether &amp;&amp; feerate_[2] &lt; 0.05 ether);&#13;
        feerate = feerate_;&#13;
    }&#13;
&#13;
    /* External function */&#13;
    // fallback&#13;
    function ()&#13;
        public&#13;
        payable&#13;
    {&#13;
        deposit(0, 0);&#13;
    }&#13;
&#13;
    // deposit all allowance&#13;
    function deposit(&#13;
        address token_,&#13;
        address representor_&#13;
    )&#13;
        public&#13;
        payable&#13;
        onlyActive&#13;
    {&#13;
        address user = getUser(representor_);&#13;
        uint256 amount = depositAndFreeze(token_, user);&#13;
        if(amount &gt; 0) {&#13;
            updateBalance(msg.sender, token_, amount, true);&#13;
        }&#13;
    }&#13;
&#13;
    function withdraw(&#13;
        address token_,&#13;
        uint256 amount_,&#13;
        address representor_&#13;
    )&#13;
        public&#13;
    returns(bool) {&#13;
        address user = getUser(representor_);&#13;
        if(updateBalance(user, token_, amount_, false)) {&#13;
            require(transferToken(user, token_, amount_));&#13;
            return true;&#13;
        }&#13;
    }&#13;
/*&#13;
    function userMakeOrder(&#13;
        address fromToken_,&#13;
        address toToken_,&#13;
        uint256 price_,&#13;
        uint256 amount_,&#13;
        address representor_&#13;
    )&#13;
        public&#13;
        payable&#13;
    returns(bool) {&#13;
        // depositToken =&gt; makeOrder =&gt; updateBalance&#13;
        uint256 depositAmount = depositAndFreeze(fromToken_, representor_);&#13;
        if(&#13;
            checkAmount(fromToken_, amount_) &amp;&amp;&#13;
            checkPriceAmount(price_)&#13;
        ) {&#13;
            address user = getUser(representor_);&#13;
            uint256 costAmount = makeOrder(fromToken_, toToken_, price_, amount_, user, depositAmount);&#13;
&#13;
            // log event: MakeOrder&#13;
            eMakeOrder(fromToken_, toToken_, price_, user, amount_);&#13;
&#13;
            if(costAmount &lt; depositAmount) {&#13;
                updateBalance(user, fromToken_, safeSub(depositAmount, costAmount), true);&#13;
            } else if(costAmount &gt; depositAmount) {&#13;
                updateBalance(user, fromToken_, safeSub(costAmount, depositAmount), false);&#13;
            }&#13;
            return true;&#13;
        }&#13;
    }&#13;
*/&#13;
    function userTakeOrder(&#13;
        address fromToken_,&#13;
        address toToken_,&#13;
        uint256 price_,&#13;
        uint256 amount_,&#13;
        address representor_&#13;
    )&#13;
        public&#13;
        payable&#13;
        onlyActive&#13;
    returns(bool) {&#13;
        // checkBalance =&gt; findAndTrade =&gt; userMakeOrder =&gt; updateBalance&#13;
        address user = getUser(representor_);&#13;
        uint256 depositAmount = depositAndFreeze(fromToken_, user);&#13;
        if(&#13;
            checkAmount(fromToken_, amount_) &amp;&amp;&#13;
            checkPriceAmount(price_) &amp;&amp;&#13;
            checkBalance(user, fromToken_, amount_, depositAmount)&#13;
        ) {&#13;
            // log event: MakeOrder&#13;
            emit eMakeOrder(fromToken_, toToken_, price_, user, amount_);&#13;
&#13;
            uint256[2] memory fillAmount;&#13;
            uint256[2] memory profit;&#13;
            (fillAmount, profit) = findAndTrade(fromToken_, toToken_, price_, amount_);&#13;
            uint256 fee;&#13;
            uint256 toAmount;&#13;
            uint256 orderAmount;&#13;
&#13;
            if(fillAmount[0] &gt; 0) {&#13;
                // log event: makeTrade&#13;
                emit eFillOrder(fromToken_, toToken_, price_, user, fillAmount[0]);&#13;
&#13;
                // log price&#13;
                priceBooks[fromToken_][toToken_] = price_;&#13;
&#13;
                toAmount = safeDiv(safeMul(fillAmount[0], price_), 1 ether);&#13;
                if(amount_ &gt; fillAmount[0]) {&#13;
                    orderAmount = safeSub(amount_, fillAmount[0]);&#13;
                    makeOrder(fromToken_, toToken_, price_, amount_, user, depositAmount);&#13;
                }&#13;
                if(toAmount &gt; 0) {&#13;
                    (toAmount, fee) = caculateFee(user, toAmount, 1);&#13;
                    profit[1] = profit[1] + fee;&#13;
&#13;
                    // save profit&#13;
                    updateBalance(bank, fromToken_, profit[0], true);&#13;
                    updateBalance(bank, toToken_, profit[1], true);&#13;
&#13;
                    // transfer to Taker&#13;
                    if(manualWithdraw[user]) {&#13;
                        updateBalance(user, toToken_, toAmount, true);&#13;
                    } else {&#13;
                        transferToken(user, toToken_, toAmount);&#13;
                    }&#13;
                }&#13;
            } else {&#13;
                orderAmount = amount_;&#13;
                makeOrder(fromToken_, toToken_, price_, orderAmount, user, depositAmount);&#13;
            }&#13;
&#13;
            // update balance&#13;
            if(amount_ &gt; depositAmount) {&#13;
                updateBalance(user, fromToken_, safeSub(amount_, depositAmount), false);&#13;
            } else if(amount_ &lt; depositAmount) {&#13;
                updateBalance(user, fromToken_, safeSub(depositAmount, amount_), true);&#13;
            }&#13;
&#13;
            return true;&#13;
        }&#13;
    }&#13;
&#13;
    function userCancelOrder(&#13;
        address fromToken_,&#13;
        address toToken_,&#13;
        uint256 price_,&#13;
        uint256 amount_,&#13;
        address representor_&#13;
    )&#13;
        public&#13;
    returns(bool) {&#13;
        // updateOrderAmount =&gt; disconnectOrderUser =&gt; withdraw&#13;
        address user = getUser(representor_);&#13;
        uint256 amount = getOrderAmount(fromToken_, toToken_, price_, user);&#13;
        amount = amount &gt; amount_ ? amount_ : amount;&#13;
        if(amount &gt; 0) {&#13;
            // log event: CancelOrder&#13;
            emit eCancelOrder(fromToken_, toToken_, price_, user, amount);&#13;
&#13;
            updateOrderAmount(fromToken_, toToken_, price_, user, amount, false);&#13;
            if(getOrderAmount(fromToken_, toToken_, price_, user) == 0) {&#13;
                disconnectOrderUser(fromToken_, toToken_, price_, 0, user, address(0));&#13;
            }&#13;
            if(manualWithdraw[user]) {&#13;
                updateBalance(user, fromToken_, amount, true);&#13;
            } else {&#13;
                transferToken(user, fromToken_, amount);&#13;
            }&#13;
            return true;&#13;
        }&#13;
    }&#13;
&#13;
    /* role - 0: maker 1: taker */&#13;
    function caculateFee(&#13;
        address user_,&#13;
        uint256 amount_,&#13;
        uint8 role_&#13;
    )&#13;
        public&#13;
        view&#13;
    returns(uint256, uint256) {&#13;
        uint256 myXPABalance = Token(XPAToken).balanceOf(user_);&#13;
        uint256 myFeerate = manualWithdraw[user_]&#13;
            ? feerate[role_]&#13;
            : feerate[role_] + feerate[2];&#13;
        myFeerate =&#13;
            myXPABalance &gt; 1000000 ether ? myFeerate * 0.5 ether / 1 ether :&#13;
            myXPABalance &gt; 100000 ether ? myFeerate * 0.6 ether / 1 ether :&#13;
            myXPABalance &gt; 10000 ether ? myFeerate * 0.8 ether / 1 ether :&#13;
            myFeerate;&#13;
        uint256 fee = safeDiv(safeMul(amount_, myFeerate), 1 ether);&#13;
        uint256 toAmount = safeSub(amount_, fee);&#13;
        return(toAmount, fee);&#13;
    }&#13;
&#13;
    function trade(&#13;
        address fromToken_,&#13;
        address toToken_&#13;
    )&#13;
        public&#13;
        onlyActive&#13;
    {&#13;
        // Don't worry, this takes maker feerate&#13;
        uint256 takerPrice = getNextOrderPrice(fromToken_, toToken_, 0);&#13;
        address taker = getNextOrderUser(fromToken_, toToken_, takerPrice, 0);&#13;
        uint256 takerAmount = getOrderAmount(fromToken_, toToken_, takerPrice, taker);&#13;
        /*&#13;
            fillAmount[0] = TakerFill&#13;
            fillAmount[1] = MakerFill&#13;
            profit[0] = fromTokenProfit&#13;
            profit[1] = toTokenProfit&#13;
         */&#13;
        uint256[2] memory fillAmount;&#13;
        uint256[2] memory profit;&#13;
        (fillAmount, profit) = findAndTrade(fromToken_, toToken_, takerPrice, takerAmount);&#13;
        if(fillAmount[0] &gt; 0) {&#13;
            profit[1] = profit[1] + fillOrder(fromToken_, toToken_, takerPrice, taker, fillAmount[0]);&#13;
&#13;
            // save profit to operator&#13;
            updateBalance(msg.sender, fromToken_, profit[0], true);&#13;
            updateBalance(msg.sender, toToken_, profit[1], true);&#13;
        }&#13;
    }&#13;
&#13;
    function setManualWithdraw(&#13;
        bool manual_&#13;
    )&#13;
        public&#13;
    {&#13;
        manualWithdraw[msg.sender] = manual_;&#13;
    }&#13;
&#13;
    /* Internal Function */&#13;
    // deposit all allowance&#13;
    function depositAndFreeze(&#13;
        address token_,&#13;
        address user&#13;
    )&#13;
        internal&#13;
    returns(uint256) {&#13;
        uint256 amount;&#13;
        if(token_ == address(0)) {&#13;
            // log event: Deposit&#13;
            emit eDeposit(user, address(0), msg.value);&#13;
&#13;
            amount = msg.value;&#13;
            return amount;&#13;
        } else {&#13;
            if(msg.value &gt; 0) {&#13;
                // log event: Deposit&#13;
                emit eDeposit(user, address(0), msg.value);&#13;
&#13;
                updateBalance(user, address(0), msg.value, true);&#13;
            }&#13;
            amount = Token(token_).allowance(msg.sender, this);&#13;
            if(&#13;
                amount &gt; 0 &amp;&amp;&#13;
                Token(token_).transferFrom(msg.sender, this, amount)&#13;
            ) {&#13;
                // log event: Deposit&#13;
                emit eDeposit(user, token_, amount);&#13;
&#13;
                return amount;&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    function checkBalance(&#13;
        address user_,&#13;
        address token_,&#13;
        uint256 amount_,&#13;
        uint256 depositAmount_&#13;
    )&#13;
        internal&#13;
        view&#13;
    returns(bool) {&#13;
        if(safeAdd(balances[user_][token_], depositAmount_) &gt;= amount_) {&#13;
            return true;&#13;
        } else {&#13;
            //emit Error(0);&#13;
            return false;&#13;
        }&#13;
    }&#13;
&#13;
    function checkAmount(&#13;
        address token_,&#13;
        uint256 amount_&#13;
    )&#13;
        internal&#13;
        view&#13;
    returns(bool) {&#13;
        uint256 min = getMinAmount(token_);&#13;
        if(amount_ &gt; maxAmount || amount_ &lt; min) {&#13;
            //emit Error(2);&#13;
            return false;&#13;
        } else {&#13;
            return true;&#13;
        }&#13;
    }&#13;
&#13;
    function checkPriceAmount(&#13;
        uint256 price_&#13;
    )&#13;
        internal&#13;
        view&#13;
    returns(bool) {&#13;
        if(price_ == 0 || price_ &gt; maxPrice) {&#13;
            //emit Error(3);&#13;
            return false;&#13;
        } else {&#13;
            return true;&#13;
        }&#13;
    }&#13;
&#13;
    function makeOrder(&#13;
        address fromToken_,&#13;
        address toToken_,&#13;
        uint256 price_,&#13;
        uint256 amount_,&#13;
        address user_,&#13;
        uint256 depositAmount_&#13;
    )&#13;
        internal&#13;
    returns(uint256) {&#13;
        if(checkBalance(user_, fromToken_, amount_, depositAmount_)) {&#13;
            updateOrderAmount(fromToken_, toToken_, price_, user_, amount_, true);&#13;
            connectOrderPrice(fromToken_, toToken_, price_, 0);&#13;
            connectOrderUser(fromToken_, toToken_, price_, user_);&#13;
            return amount_;&#13;
        } else {&#13;
            return 0;&#13;
        }&#13;
    }&#13;
&#13;
    function findAndTrade(&#13;
        address fromToken_,&#13;
        address toToken_,&#13;
        uint256 price_,&#13;
        uint256 amount_&#13;
    )&#13;
        internal&#13;
    returns(uint256[2], uint256[2]) {&#13;
        /*&#13;
            totalMatchAmount[0]: Taker total match amount&#13;
            totalMatchAmount[1]: Maker total match amount&#13;
            profit[0]: fromToken profit&#13;
            profit[1]: toToken profit&#13;
            matchAmount[0]: Taker match amount&#13;
            matchAmount[1]: Maker match amount&#13;
         */&#13;
        uint256[2] memory totalMatchAmount;&#13;
        uint256[2] memory profit;&#13;
        uint256[3] memory matchAmount;&#13;
        uint256 toAmount;&#13;
        uint256 remaining = amount_;&#13;
        uint256 matches = 0;&#13;
        uint256 prevBestPrice = 0;&#13;
        uint256 bestPrice = getNextOrderPrice(toToken_, fromToken_, prevBestPrice);&#13;
        for(; matches &lt; autoMatch &amp;&amp; remaining &gt; 0;) {&#13;
            matchAmount = makeTrade(fromToken_, toToken_, price_, bestPrice, prevBestPrice, remaining);&#13;
            if(matchAmount[0] &gt; 0) {&#13;
                remaining = safeSub(remaining, matchAmount[0]);&#13;
                totalMatchAmount[0] = safeAdd(totalMatchAmount[0], matchAmount[0]);&#13;
                totalMatchAmount[1] = safeAdd(totalMatchAmount[1], matchAmount[1]);&#13;
                profit[0] = safeAdd(profit[0], matchAmount[2]);&#13;
                &#13;
                // for next loop&#13;
                matches++;&#13;
                prevBestPrice = bestPrice;&#13;
                bestPrice = getNextOrderPrice(toToken_, fromToken_, prevBestPrice);&#13;
            } else {&#13;
                break;&#13;
            }&#13;
        }&#13;
&#13;
        if(totalMatchAmount[0] &gt; 0) {&#13;
            // calculating spread profit&#13;
            toAmount = safeDiv(safeMul(totalMatchAmount[0], price_), 1 ether);&#13;
            profit[1] = safeSub(totalMatchAmount[1], toAmount);&#13;
            if(totalMatchAmount[1] &gt;= safeDiv(safeMul(amount_, price_), 1 ether)) {&#13;
                // fromProfit += amount_ - takerFill;&#13;
                profit[0] = profit[0] + amount_ - totalMatchAmount[0];&#13;
                // fullfill Taker order&#13;
                totalMatchAmount[0] = amount_;&#13;
            } else {&#13;
                toAmount = totalMatchAmount[1];&#13;
                // fromProfit += takerFill - (toAmount / price_ * 1 ether)&#13;
                profit[0] = profit[0] + totalMatchAmount[0] - (toAmount * 1 ether /price_);&#13;
                // (real) takerFill = toAmount / price_ * 1 ether&#13;
                totalMatchAmount[0] = safeDiv(safeMul(toAmount, 1 ether), price_);&#13;
            }&#13;
        }&#13;
&#13;
        return (totalMatchAmount, profit);&#13;
    }&#13;
&#13;
    function makeTrade(&#13;
        address fromToken_,&#13;
        address toToken_,&#13;
        uint256 price_,&#13;
        uint256 bestPrice_,&#13;
        uint256 prevBestPrice_,&#13;
        uint256 remaining_&#13;
    )&#13;
        internal&#13;
    returns(uint256[3]) {&#13;
        if(checkPricePair(price_, bestPrice_)) {&#13;
            address prevMaker = address(0);&#13;
            address maker = getNextOrderUser(toToken_, fromToken_, bestPrice_, 0);&#13;
            uint256 remaining = remaining_;&#13;
&#13;
            /*&#13;
                totalFill[0]: Total Taker fillAmount&#13;
                totalFill[1]: Total Maker fillAmount&#13;
                totalFill[2]: Total Maker fee&#13;
             */&#13;
            uint256[3] memory totalFill;&#13;
            for(uint256 i = 0; i &lt; autoMatch &amp;&amp; remaining &gt; 0 &amp;&amp; maker != address(0); i++) {&#13;
                uint256[3] memory fill;&#13;
                bool fullfill;&#13;
                (fill, fullfill) = makeTradeDetail(fromToken_, toToken_, price_, bestPrice_, maker, remaining);&#13;
                if(fill[0] &gt; 0) {&#13;
                    if(fullfill) {&#13;
                        disconnectOrderUser(toToken_, fromToken_, bestPrice_, prevBestPrice_, maker, prevMaker);&#13;
                    }&#13;
                    remaining = safeSub(remaining, fill[0]);&#13;
                    totalFill[0] = safeAdd(totalFill[0], fill[0]);&#13;
                    totalFill[1] = safeAdd(totalFill[1], fill[1]);&#13;
                    totalFill[2] = safeAdd(totalFill[2], fill[2]);&#13;
                    prevMaker = maker;&#13;
                    maker = getNextOrderUser(toToken_, fromToken_, bestPrice_, prevMaker);&#13;
                    if(maker == address(0)) {&#13;
                        break;&#13;
                    }&#13;
                } else {&#13;
                    break;&#13;
                }&#13;
            }&#13;
        }&#13;
        return totalFill;&#13;
    }&#13;
&#13;
    function makeTradeDetail(&#13;
        address fromToken_,&#13;
        address toToken_,&#13;
        uint256 price_,&#13;
        uint256 bestPrice_,&#13;
        address maker_,&#13;
        uint256 remaining_&#13;
    )&#13;
        internal&#13;
    returns(uint256[3], bool) {&#13;
        /*&#13;
            fillAmount[0]: Taker fillAmount&#13;
            fillAmount[1]: Maker fillAmount&#13;
            fillAmount[2]: Maker fee&#13;
         */&#13;
        uint256[3] memory fillAmount;&#13;
        uint256 takerProvide = remaining_;&#13;
        uint256 takerRequire = safeDiv(safeMul(takerProvide, price_), 1 ether);&#13;
        uint256 makerProvide = getOrderAmount(toToken_, fromToken_, bestPrice_, maker_);&#13;
        uint256 makerRequire = safeDiv(safeMul(makerProvide, bestPrice_), 1 ether);&#13;
        fillAmount[0] = caculateFill(takerProvide, takerRequire, price_, makerProvide);&#13;
        fillAmount[1] = caculateFill(makerProvide, makerRequire, bestPrice_, takerProvide);&#13;
        fillAmount[2] = fillOrder(toToken_, fromToken_, bestPrice_, maker_, fillAmount[1]);&#13;
        return (fillAmount, (makerRequire &lt;= takerProvide));&#13;
    }&#13;
&#13;
    function caculateFill(&#13;
        uint256 provide_,&#13;
        uint256 require_,&#13;
        uint256 price_,&#13;
        uint256 pairProvide_&#13;
    )&#13;
        internal&#13;
        pure&#13;
    returns(uint256) {&#13;
        return require_ &gt; pairProvide_ ? safeDiv(safeMul(pairProvide_, 1 ether), price_) : provide_;&#13;
    }&#13;
&#13;
    function checkPricePair(&#13;
        uint256 price_,&#13;
        uint256 bestPrice_&#13;
    )&#13;
        internal pure &#13;
    returns(bool) {&#13;
        if(bestPrice_ &lt; price_) {&#13;
            return checkPricePair(bestPrice_, price_);&#13;
        } else if(bestPrice_ &lt; 1 ether) {&#13;
            return true;&#13;
        } else if(price_ &gt; 1 ether) {&#13;
            return false;&#13;
        } else {&#13;
            return price_ * bestPrice_ &lt;= 1 ether * 1 ether;&#13;
        }&#13;
    }&#13;
&#13;
    function fillOrder(&#13;
        address fromToken_,&#13;
        address toToken_,&#13;
        uint256 price_,&#13;
        address user_,&#13;
        uint256 amount_&#13;
    )&#13;
        internal&#13;
    returns(uint256) {&#13;
        // log event: fillOrder&#13;
        emit eFillOrder(fromToken_, toToken_, price_, user_, amount_);&#13;
&#13;
        uint256 toAmount = safeDiv(safeMul(amount_, price_), 1 ether);&#13;
        uint256 fee;&#13;
        updateOrderAmount(fromToken_, toToken_, price_, user_, amount_, false);&#13;
        (toAmount, fee) = caculateFee(user_, toAmount, 0);&#13;
        if(manualWithdraw[user_]) {&#13;
            updateBalance(user_, toToken_, toAmount, true);&#13;
        } else {&#13;
            transferToken(user_, toToken_, toAmount);&#13;
        }&#13;
        return fee;&#13;
    }&#13;
    function transferToken(&#13;
        address user_,&#13;
        address token_,&#13;
        uint256 amount_&#13;
    )&#13;
        internal&#13;
    returns(bool) {&#13;
        if(token_ == address(0)) {&#13;
            if(address(this).balance &lt; amount_) {&#13;
                //emit Error(1);&#13;
                return false;&#13;
            } else {&#13;
                // log event: Withdraw&#13;
                emit eWithdraw(user_, token_, amount_);&#13;
&#13;
                user_.transfer(amount_);&#13;
                return true;&#13;
            }&#13;
        } else if(Token(token_).transfer(user_, amount_)) {&#13;
            // log event: Withdraw&#13;
            emit eWithdraw(user_, token_, amount_);&#13;
&#13;
            return true;&#13;
        } else {&#13;
            //emit Error(1);&#13;
            return false;&#13;
        }&#13;
    }&#13;
&#13;
    function updateBalance(&#13;
        address user_,&#13;
        address token_,&#13;
        uint256 amount_,&#13;
        bool addOrSub_&#13;
    )&#13;
        internal&#13;
    returns(bool) {&#13;
        if(addOrSub_) {&#13;
            balances[user_][token_] = safeAdd(balances[user_][token_], amount_);&#13;
        } else {&#13;
            if(checkBalance(user_, token_, amount_, 0)){&#13;
                balances[user_][token_] = safeSub(balances[user_][token_], amount_);&#13;
                return true;&#13;
            } else {&#13;
                return false;&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    function connectOrderPrice(&#13;
        address fromToken_,&#13;
        address toToken_,&#13;
        uint256 price_,&#13;
        uint256 prev_&#13;
    )&#13;
        internal&#13;
    {&#13;
        if(checkPriceAmount(price_)) {&#13;
            uint256 prevPrice = getNextOrderPrice(fromToken_, toToken_, prev_);&#13;
            uint256 nextPrice = getNextOrderPrice(fromToken_, toToken_, prevPrice);&#13;
            if(prev_ != price_ &amp;&amp; prevPrice != price_ &amp;&amp; nextPrice != price_) {&#13;
                if(price_ &lt; prevPrice) {&#13;
                    updateNextOrderPrice(fromToken_, toToken_, prev_, price_);&#13;
                    updateNextOrderPrice(fromToken_, toToken_, price_, prevPrice);&#13;
                } else if(nextPrice == 0) {&#13;
                    updateNextOrderPrice(fromToken_, toToken_, prevPrice, price_);&#13;
                } else {&#13;
                    connectOrderPrice(fromToken_, toToken_, price_, prevPrice);&#13;
                }&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    function connectOrderUser(&#13;
        address fromToken_,&#13;
        address toToken_,&#13;
        uint256 price_,&#13;
        address user_&#13;
    )&#13;
        internal &#13;
    {&#13;
        address firstUser = getNextOrderUser(fromToken_, toToken_, price_, 0);&#13;
        if(user_ != address(0) &amp;&amp; user_ != firstUser) {&#13;
            updateNextOrderUser(fromToken_, toToken_, price_, 0, user_);&#13;
            if(firstUser != address(0)) {&#13;
                updateNextOrderUser(fromToken_, toToken_, price_, user_, firstUser);&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    function disconnectOrderPrice(&#13;
        address fromToken_,&#13;
        address toToken_,&#13;
        uint256 price_,&#13;
        uint256 prev_&#13;
    )&#13;
        internal&#13;
    {&#13;
        if(checkPriceAmount(price_)) {&#13;
            uint256 prevPrice = getNextOrderPrice(fromToken_, toToken_, prev_);&#13;
            uint256 nextPrice = getNextOrderPrice(fromToken_, toToken_, prevPrice);&#13;
            if(price_ == prevPrice) {&#13;
                updateNextOrderPrice(fromToken_, toToken_, prev_, nextPrice);&#13;
            } else if(price_ &lt; prevPrice) {&#13;
                disconnectOrderPrice(fromToken_, toToken_, price_, prevPrice);&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    function disconnectOrderUser(&#13;
        address fromToken_,&#13;
        address toToken_,&#13;
        uint256 price_,&#13;
        uint256 prevPrice_,&#13;
        address user_,&#13;
        address prev_&#13;
    )&#13;
        internal&#13;
    {&#13;
        if(user_ == address(0)) {&#13;
            return;&#13;
        }&#13;
        address prevUser = getNextOrderUser(fromToken_, toToken_, price_, prev_);&#13;
        address nextUser = getNextOrderUser(fromToken_, toToken_, price_, prevUser);&#13;
        if(prevUser == user_) {&#13;
            updateNextOrderUser(fromToken_, toToken_, price_, prev_, nextUser);&#13;
            if(nextUser == address(0)) {&#13;
                disconnectOrderPrice(fromToken_, toToken_, price_, prevPrice_);&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    function getNextOrderPrice(&#13;
        address fromToken_,&#13;
        address toToken_,&#13;
        uint256 price_&#13;
    )&#13;
        internal&#13;
        view&#13;
    returns(uint256) {&#13;
        return nextOrderPrice[fromToken_][toToken_][price_];&#13;
    }&#13;
&#13;
    function updateNextOrderPrice(&#13;
        address fromToken_,&#13;
        address toToken_,&#13;
        uint256 price_,&#13;
        uint256 nextPrice_&#13;
    )&#13;
        internal&#13;
    {&#13;
        nextOrderPrice[fromToken_][toToken_][price_] = nextPrice_;&#13;
    }&#13;
&#13;
    function getNextOrderUser(&#13;
        address fromToken_,&#13;
        address toToken_,&#13;
        uint256 price_,&#13;
        address user_&#13;
    )&#13;
        internal&#13;
        view&#13;
    returns(address) {&#13;
        return orderBooks[fromToken_][toToken_][price_][user_].nextUser;&#13;
    }&#13;
&#13;
    function getOrderAmount(&#13;
        address fromToken_,&#13;
        address toToken_,&#13;
        uint256 price_,&#13;
        address user_&#13;
    )&#13;
        internal&#13;
        view&#13;
    returns(uint256) {&#13;
        return orderBooks[fromToken_][toToken_][price_][user_].amount;&#13;
    }&#13;
&#13;
    function updateNextOrderUser(&#13;
        address fromToken_,&#13;
        address toToken_,&#13;
        uint256 price_,&#13;
        address user_,&#13;
        address nextUser_&#13;
    )&#13;
        internal&#13;
    {&#13;
        orderBooks[fromToken_][toToken_][price_][user_].nextUser = nextUser_;&#13;
    }&#13;
&#13;
    function updateOrderAmount(&#13;
        address fromToken_,&#13;
        address toToken_,&#13;
        uint256 price_,&#13;
        address user_,&#13;
        uint256 amount_,&#13;
        bool addOrSub_&#13;
    )&#13;
        internal&#13;
    {&#13;
        if(addOrSub_) {&#13;
            orderBooks[fromToken_][toToken_][price_][user_].amount = safeAdd(orderBooks[fromToken_][toToken_][price_][user_].amount, amount_);&#13;
        } else {&#13;
            orderBooks[fromToken_][toToken_][price_][user_].amount = safeSub(orderBooks[fromToken_][toToken_][price_][user_].amount, amount_);&#13;
        }&#13;
    }&#13;
}
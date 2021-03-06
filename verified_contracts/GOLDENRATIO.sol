pragma solidity ^0.4.20;

/*
* Golden Ratio
* 
* POWH3D Clone
*
* 25% Dividends are paid to the other token holders from the new players buy in fee
*
* 25% Dividends are paid out to other token holders whenever a player sells tokens
*
* 33% of Buy in Fees are paid to Masternodes
*
* Discord:   https://discord.gg/bcjS6Pb
*
* website:   https://goldenratio.ga
*
* email:     <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b7d0d8dbd3d2d9d3d2c1c5d6c3ded8f7d0dad6dedb99d4d8da">[email protected]</a>&#13;
*/&#13;
&#13;
contract GOLDENRATIO {&#13;
    /*=================================&#13;
    =        MODIFIERS        =&#13;
    =================================*/&#13;
    // only players with tokens&#13;
    modifier onlyBagholders() {&#13;
        require(myTokens() &gt; 0);&#13;
        _;&#13;
    }&#13;
    &#13;
     // only players with profits&#13;
    modifier onlyStronghands() {&#13;
        require(myDividends(true) &gt; 0);&#13;
        _;&#13;
    }&#13;
    &#13;
    // administrators can:&#13;
    // -&gt; change the name of the contract&#13;
    // -&gt; change the name of the token&#13;
    // -&gt; change the PoS difficulty (How many tokens it costs to hold a masternode, in case it gets crazy high later)&#13;
    // they CANNOT:&#13;
    // -&gt; take funds&#13;
    // -&gt; disable withdrawals&#13;
    // -&gt; kill tha contract&#13;
    // -&gt; change the price of tokens&#13;
    modifier onlyAdministrator(){&#13;
        address _customerAddress = msg.sender;&#13;
&#13;
        require(administrators[_customerAddress]);&#13;
        _;&#13;
    }&#13;
    &#13;
      // ensures that tha original tokens in tha contract is going to be equally distributed&#13;
    // meaning, no divine dump is going to be possible&#13;
    // result: healthy longevity.&#13;
    modifier antiEarlyWhale(uint256 _amountOfEthereum){&#13;
        address _customerAddress = msg.sender;&#13;
        &#13;
        // are we still in the vulnerable phase?&#13;
        // if so, enact anti early whale protocol &#13;
        if( onlyAmbassadors &amp;&amp; ((totalEthereumBalance() - _amountOfEthereum) &lt;= ambassadorQuota_ )){&#13;
            require(&#13;
                // is the customer in the ambassador list?&#13;
                ambassadors_[_customerAddress] == true &amp;&amp;&#13;
                &#13;
                // does the customer purchase exceed the max ambassador quota?&#13;
                (ambassadorAccumulatedQuota_[_customerAddress] + _amountOfEthereum) &lt;= ambassadorMaxPurchase_&#13;
                &#13;
            );&#13;
            &#13;
            // updated the accumulated quota    &#13;
            ambassadorAccumulatedQuota_[_customerAddress] = SafeMath.add(ambassadorAccumulatedQuota_[_customerAddress], _amountOfEthereum);&#13;
        &#13;
            // execute&#13;
            _;&#13;
        } else {&#13;
            // in case the ether count drops low, the ambassador phase won't reinitiate&#13;
            onlyAmbassadors = false;&#13;
            _;    &#13;
        }&#13;
        &#13;
    }&#13;
    &#13;
    &#13;
    /*==============================&#13;
    =            EVENTS            =&#13;
    ==============================*/&#13;
    event onTokenPurchase(&#13;
        address indexed customerAddress,&#13;
        uint256 incomingEthereum,&#13;
        uint256 tokensMinted,&#13;
        address indexed referredBy&#13;
    );&#13;
    &#13;
    event onTokenSell(&#13;
        address indexed customerAddress,&#13;
        uint256 tokensBurned,&#13;
        uint256 ethereumEarned&#13;
    );&#13;
    &#13;
    event onReinvestment(&#13;
        address indexed customerAddress,&#13;
        uint256 ethereumReinvested,&#13;
        uint256 tokensMinted&#13;
    );&#13;
    &#13;
    event onWithdraw(&#13;
        address indexed customerAddress,&#13;
        uint256 ethereumWithdrawn&#13;
    );&#13;
    &#13;
    // ERC20&#13;
    event Transfer(&#13;
        address indexed from,&#13;
        address indexed to,&#13;
        uint256 tokens&#13;
    );&#13;
&#13;
    &#13;
    /*=====================================&#13;
    =            CONFIGURABLES            =&#13;
    =====================================*/&#13;
    string public name = "GOLDENRATIO";&#13;
    string public symbol = "GOLD";&#13;
    uint8 constant public decimals = 18;&#13;
    uint8 constant internal dividendFee_ = 4;    //25% Dividends &#13;
    uint256 constant internal tokenPriceInitial_ = 0.0000001 ether;&#13;
    uint256 constant internal tokenPriceIncremental_ = 0.00000001 ether;&#13;
    uint256 constant internal magnitude = 2**64;&#13;
    &#13;
    // Masternode Staking Requirements&#13;
    uint256 public stakingRequirement = 10e18;   //10 Tokens&#13;
    &#13;
    // ambassador program&#13;
    mapping(address =&gt; bool) internal ambassadors_;     &#13;
    uint256 constant internal ambassadorMaxPurchase_ = 1 ether;&#13;
    uint256 constant internal ambassadorQuota_ = 20 ether;&#13;
    &#13;
    &#13;
    &#13;
   /*================================&#13;
    =            DATASETS            =&#13;
    ================================*/&#13;
    // amount of shares for each address (scaled number)&#13;
    mapping(address =&gt; uint256) internal tokenBalanceLedger_;&#13;
    mapping(address =&gt; uint256) internal referralBalance_;&#13;
    mapping(address =&gt; int256) internal payoutsTo_;&#13;
    mapping(address =&gt; uint256) internal ambassadorAccumulatedQuota_;&#13;
    uint256 internal tokenSupply_ = 0;&#13;
    uint256 internal profitPerShare_;&#13;
    &#13;
    // administrator list (see above on what they can do)&#13;
    //mapping(bytes32 =&gt; bool) public administrators;&#13;
    mapping(address =&gt; bool) public administrators;&#13;
    &#13;
    // when this is set to true, only ambassadors can purchase tokens (this prevents a whale premine, it ensures a fairly distributed upper pyramid)&#13;
    bool public onlyAmbassadors = true;&#13;
&#13;
    address GOLDGOD;&#13;
    &#13;
&#13;
&#13;
    /*=======================================&#13;
    =            PUBLIC FUNCTIONS            =&#13;
    =======================================*/&#13;
    /*&#13;
    * -- APPLICATION ENTRY POINTS --  &#13;
    */&#13;
    function GOLDENRATIO()&#13;
        public&#13;
    {&#13;
        // add administrators here&#13;
&#13;
        administrators[msg.sender] = true;&#13;
&#13;
        GOLDGOD = msg.sender;&#13;
&#13;
        onlyAmbassadors = false;&#13;
&#13;
&#13;
    }&#13;
    &#13;
     &#13;
    /**&#13;
     * Converts all incoming ethereum to tokens for the caller, and passes down the referral addy (if any)&#13;
     */&#13;
    function buy(address _referredBy)&#13;
        public&#13;
        payable&#13;
        returns(uint256)&#13;
    {&#13;
        purchaseTokens(msg.value, _referredBy);&#13;
    }&#13;
    &#13;
    /**&#13;
     * Fallback function to handle ethereum that was send straight to the contract&#13;
     * Unfortunately we cannot use a referral address this way.&#13;
     */&#13;
    function()&#13;
        payable&#13;
        public&#13;
    {&#13;
        purchaseTokens(msg.value, 0x0);&#13;
    }&#13;
    &#13;
    /**&#13;
     * Converts all of caller's dividends to tokens.&#13;
     */&#13;
    function reinvest()&#13;
        onlyStronghands()&#13;
        public&#13;
    {&#13;
        // fetch dividends&#13;
        uint256 _dividends = myDividends(false); // retrieve ref. bonus later in the code&#13;
        &#13;
        // pay out the dividends virtually&#13;
        address _customerAddress = msg.sender;&#13;
        payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);&#13;
        &#13;
        // retrieve ref. bonus&#13;
        _dividends += referralBalance_[_customerAddress];&#13;
        referralBalance_[_customerAddress] = 0;&#13;
        &#13;
        // dispatch a buy order with the virtualized "withdrawn dividends"&#13;
        uint256 _tokens = purchaseTokens(_dividends, 0x0);&#13;
        &#13;
        // fire event&#13;
        onReinvestment(_customerAddress, _dividends, _tokens);&#13;
    }&#13;
    &#13;
    /**&#13;
     * Alias of sell() and withdraw().&#13;
     */&#13;
    function exit()&#13;
        public&#13;
    {&#13;
        // get token count for caller &amp; sell them all&#13;
        address _customerAddress = msg.sender;&#13;
        uint256 _tokens = tokenBalanceLedger_[_customerAddress];&#13;
        if(_tokens &gt; 0) sell(_tokens);&#13;
        &#13;
        &#13;
        withdraw();&#13;
    }&#13;
&#13;
    /**&#13;
     * Withdraws all of the callers earnings.&#13;
     */&#13;
    function withdraw()&#13;
        onlyStronghands()&#13;
        public&#13;
    {&#13;
        // setup data&#13;
        address _customerAddress = msg.sender;&#13;
        uint256 _dividends = myDividends(false); // get ref. bonus later in the code&#13;
        &#13;
        // update dividend tracker&#13;
        payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);&#13;
        &#13;
        // add ref. bonus&#13;
        _dividends += referralBalance_[_customerAddress];&#13;
        referralBalance_[_customerAddress] = 0;&#13;
        &#13;
        // lambo delivery service&#13;
        _customerAddress.transfer(_dividends);&#13;
        &#13;
        // fire event&#13;
        onWithdraw(_customerAddress, _dividends);&#13;
    }&#13;
    &#13;
    /**&#13;
     * Liquifies tokens to ethereum.&#13;
     */&#13;
    function sell(uint256 _amountOfTokens)&#13;
        onlyBagholders()&#13;
        public&#13;
    {&#13;
        // setup data&#13;
        address _customerAddress = msg.sender;&#13;
        // russian hackers BTFO&#13;
        require(_amountOfTokens &lt;= tokenBalanceLedger_[_customerAddress]);&#13;
        uint256 _tokens = _amountOfTokens;&#13;
        uint256 _ethereum = tokensToEthereum_(_tokens);&#13;
        uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);&#13;
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);&#13;
        &#13;
        // burn the sold tokens&#13;
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);&#13;
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);&#13;
        &#13;
        // update dividends tracker&#13;
        int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));&#13;
        payoutsTo_[_customerAddress] -= _updatedPayouts;       &#13;
        &#13;
        // dividing by zero is a bad idea&#13;
        if (tokenSupply_ &gt; 0) {&#13;
            // update the amount of dividends per token&#13;
            profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);&#13;
        }&#13;
        &#13;
        // fire event&#13;
        onTokenSell(_customerAddress, _tokens, _taxedEthereum);&#13;
    }&#13;
    &#13;
    &#13;
    /**&#13;
     * Transfer tokens from the caller to a new holder.&#13;
     * Remember, there's a 10% fee here as well.&#13;
     */&#13;
    function transfer(address _toAddress, uint256 _amountOfTokens)&#13;
        onlyBagholders()&#13;
        public&#13;
        returns(bool)&#13;
    {&#13;
        // setup&#13;
        address _customerAddress = msg.sender;&#13;
        &#13;
        // make sure we have the requested tokens&#13;
        // also disables transfers until ambassador phase is over&#13;
        // ( we dont want whale premines )&#13;
        require(!onlyAmbassadors &amp;&amp; _amountOfTokens &lt;= tokenBalanceLedger_[_customerAddress]);&#13;
        &#13;
        // withdraw all outstanding dividends first&#13;
        if(myDividends(true) &gt; 0) withdraw();&#13;
        &#13;
        // liquify 10% of the tokens that are transfered&#13;
        // these are dispersed to shareholders&#13;
        uint256 _tokenFee = SafeMath.div(_amountOfTokens, dividendFee_);&#13;
        uint256 _taxedTokens = SafeMath.sub(_amountOfTokens, _tokenFee);&#13;
        uint256 _dividends = tokensToEthereum_(_tokenFee);&#13;
  &#13;
        // burn the fee tokens&#13;
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokenFee);&#13;
&#13;
        // exchange tokens&#13;
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);&#13;
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);&#13;
        &#13;
        // update dividend trackers&#13;
        payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);&#13;
        payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _taxedTokens);&#13;
        &#13;
        // disperse dividends among holders&#13;
        profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);&#13;
        &#13;
        // fire event&#13;
        Transfer(_customerAddress, _toAddress, _taxedTokens);&#13;
        &#13;
        // ERC20&#13;
        return true;&#13;
       &#13;
    }&#13;
    &#13;
    /*----------  ADMINISTRATOR ONLY FUNCTIONS  ----------*/&#13;
    /**&#13;
     * In case the amassador quota is not met, the administrator can manually disable the ambassador phase.&#13;
     */&#13;
    function disableInitialStage()&#13;
        onlyAdministrator()&#13;
        public&#13;
    {&#13;
        onlyAmbassadors = false;&#13;
    }&#13;
    &#13;
    /**&#13;
     * In case one of us dissapears, we need to replace them.&#13;
     */&#13;
    function setAdministrator(address _identifier, bool _status)&#13;
        onlyAdministrator()&#13;
        public&#13;
    {&#13;
        administrators[_identifier] = _status;&#13;
    }&#13;
    &#13;
    /**&#13;
     * Precautionary measures in case we need to adjust the masternode rate.&#13;
     */&#13;
    function setStakingRequirement(uint256 _amountOfTokens)&#13;
        onlyAdministrator()&#13;
        public&#13;
    {&#13;
        stakingRequirement = _amountOfTokens;&#13;
    }&#13;
    &#13;
    /**&#13;
     * If we want to rebrand, we can.&#13;
     */&#13;
    function setName(string _name)&#13;
        onlyAdministrator()&#13;
        public&#13;
    {&#13;
        name = _name;&#13;
    }&#13;
    &#13;
    /**&#13;
     * If we want to rebrand, we can.&#13;
     */&#13;
    function setSymbol(string _symbol)&#13;
        onlyAdministrator()&#13;
        public&#13;
    {&#13;
        symbol = _symbol;&#13;
    }&#13;
&#13;
    &#13;
    /*----------  HELPERS AND CALCULATORS  ----------*/&#13;
    /**&#13;
     * Method to view the current Ethereum stored in the contract&#13;
     * Example: totalEthereumBalance()&#13;
     */&#13;
    function totalEthereumBalance()&#13;
        public&#13;
        view&#13;
        returns(uint)&#13;
    {&#13;
        return address (this).balance;&#13;
    }&#13;
    &#13;
    /**&#13;
     * Retrieve the total token supply.&#13;
     */&#13;
    function totalSupply()&#13;
        public&#13;
        view&#13;
        returns(uint256)&#13;
    {&#13;
        return tokenSupply_;&#13;
    }&#13;
    &#13;
    /**&#13;
     * Retrieve the tokens owned by the caller.&#13;
     */&#13;
    function myTokens()&#13;
        public&#13;
        view&#13;
        returns(uint256)&#13;
    {&#13;
        address _customerAddress = msg.sender;&#13;
        return balanceOf(_customerAddress);&#13;
    }&#13;
    &#13;
    /**&#13;
     * Retrieve the dividends owned by the caller.&#13;
     * If `_includeReferralBonus` is to to 1/true, the referral bonus will be included in the calculations.&#13;
     * The reason for this, is that in the frontend, we will want to get the total divs (global + ref)&#13;
     * But in the internal calculations, we want them separate. &#13;
     */ &#13;
    function myDividends(bool _includeReferralBonus) &#13;
        public &#13;
        view &#13;
        returns(uint256)&#13;
    {&#13;
        address _customerAddress = msg.sender;&#13;
        return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;&#13;
    }&#13;
    &#13;
    /**&#13;
     * Retrieve the token balance of any single address.&#13;
     */&#13;
    function balanceOf(address _customerAddress)&#13;
        view&#13;
        public&#13;
        returns(uint256)&#13;
    {&#13;
        return tokenBalanceLedger_[_customerAddress];&#13;
    }&#13;
&#13;
    &#13;
    /**&#13;
     * Retrieve the dividend balance of any single address.&#13;
     */&#13;
    function dividendsOf(address _customerAddress)&#13;
        view&#13;
        public&#13;
        returns(uint256)&#13;
    {&#13;
        return (uint256) ((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;&#13;
    }&#13;
    &#13;
    /**&#13;
     * Return the buy price of 1 individual token.&#13;
     */&#13;
    function sellPrice() &#13;
        public &#13;
        view &#13;
        returns(uint256)&#13;
    {&#13;
        // our calculation relies on the token supply, so we need supply. Doh.&#13;
        if(tokenSupply_ == 0){&#13;
            return tokenPriceInitial_ - tokenPriceIncremental_;&#13;
        } else {&#13;
            uint256 _ethereum = tokensToEthereum_(1e18);&#13;
            uint256 _dividends = SafeMath.div(_ethereum, dividendFee_  );&#13;
            uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);&#13;
            return _taxedEthereum;&#13;
        }&#13;
    }&#13;
    &#13;
    /**&#13;
     * Return the sell price of 1 individual token.&#13;
     */&#13;
    function buyPrice() &#13;
        public &#13;
        view &#13;
        returns(uint256)&#13;
    {&#13;
        // our calculation relies on the token supply, so we need supply. Doh.&#13;
        if(tokenSupply_ == 0){&#13;
            return tokenPriceInitial_ + tokenPriceIncremental_;&#13;
        } else {&#13;
            uint256 _ethereum = tokensToEthereum_(1e18);&#13;
            uint256 _dividends = SafeMath.div(_ethereum, dividendFee_  );&#13;
            uint256 _taxedEthereum = SafeMath.add(_ethereum, _dividends);&#13;
            return _taxedEthereum;&#13;
        }&#13;
    }&#13;
    &#13;
    /**&#13;
     * Function for the frontend to dynamically retrieve the price scaling of buy orders.&#13;
     */&#13;
    function calculateTokensReceived(uint256 _ethereumToSpend) &#13;
        public &#13;
        view &#13;
        returns(uint256)&#13;
    {&#13;
        uint256 _dividends = SafeMath.div(_ethereumToSpend, dividendFee_);&#13;
        uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);&#13;
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);&#13;
        &#13;
        return _amountOfTokens;&#13;
    }&#13;
    &#13;
    /**&#13;
     * Function for the frontend to dynamically retrieve the price scaling of sell orders.&#13;
     */&#13;
    function calculateEthereumReceived(uint256 _tokensToSell) &#13;
        public &#13;
        view &#13;
        returns(uint256)&#13;
    {&#13;
        require(_tokensToSell &lt;= tokenSupply_);&#13;
        uint256 _ethereum = tokensToEthereum_(_tokensToSell);&#13;
        uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);&#13;
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);&#13;
        return _taxedEthereum;&#13;
    }&#13;
    &#13;
    &#13;
    /*==========================================&#13;
    =            INTERNAL FUNCTIONS            =&#13;
    ==========================================*/&#13;
    function purchaseTokens(uint256 _incomingEthereum, address _referredBy)&#13;
        antiEarlyWhale(_incomingEthereum)&#13;
        internal&#13;
        returns(uint256)&#13;
    {&#13;
&#13;
&#13;
        address _customerAddress = msg.sender;&#13;
        uint256 _undividedDividends = SafeMath.div(_incomingEthereum, dividendFee_);&#13;
        uint256 _referralBonus = SafeMath.div(_undividedDividends, 3);           //33% Referral Bonus&#13;
        uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);&#13;
        uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, _undividedDividends);&#13;
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);&#13;
        uint256 _fee = _dividends * magnitude;&#13;
 &#13;
        // no point in continuing execution if OP is a poorfag russian hacker&#13;
        // prevents overflow in the case that the pyramid somehow magically starts being used by everyone in the world&#13;
        // (or hackers)&#13;
        // and yes we know that the safemath function automatically rules out the "greater then" equasion.&#13;
        require(_amountOfTokens &gt; 0 &amp;&amp; (SafeMath.add(_amountOfTokens,tokenSupply_) &gt; tokenSupply_));&#13;
        &#13;
        // is the user referred by a masternode?&#13;
        if(&#13;
            // is this a referred purchase?&#13;
            _referredBy != 0x0000000000000000000000000000000000000000 &amp;&amp;&#13;
&#13;
            // no cheating!&#13;
            _referredBy != _customerAddress &amp;&amp;&#13;
            &#13;
            // does the referrer have at least X whole tokens?&#13;
            // i.e is the referrer a godly chad masternode&#13;
            tokenBalanceLedger_[_referredBy] &gt;= stakingRequirement&#13;
        ){&#13;
            // wealth redistribution&#13;
            referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);&#13;
            &#13;
        } else {&#13;
            // no ref purchase&#13;
            referralBalance_[GOLDGOD] = SafeMath.add(referralBalance_[GOLDGOD], _referralBonus);&#13;
            //_dividends = SafeMath.add(_dividends, _referralBonus);&#13;
           // _fee = _dividends * magnitude;&#13;
        }&#13;
        &#13;
        // we can't give people infinite ethereum&#13;
        if(tokenSupply_ &gt; 0){&#13;
            &#13;
            // add tokens to the pool&#13;
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);&#13;
 &#13;
            // take the amount of dividends gained through this transaction, and allocates them evenly to each shareholder&#13;
            profitPerShare_ += (_dividends * magnitude / (tokenSupply_));&#13;
            &#13;
            // calculate the amount of tokens the customer receives over his purchase &#13;
            _fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));&#13;
        &#13;
        } else {&#13;
            // add tokens to the pool&#13;
            tokenSupply_ = _amountOfTokens;&#13;
        }&#13;
        &#13;
        // update circulating supply &amp; the ledger address for the customer&#13;
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);&#13;
        &#13;
        // Tells the contract that the buyer doesn't deserve dividends for the tokens before they owned them;&#13;
        //really i know you think you do but you don't&#13;
        int256 _updatedPayouts = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);&#13;
        payoutsTo_[_customerAddress] += _updatedPayouts;&#13;
        &#13;
        // fire event&#13;
        onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, _referredBy);&#13;
        &#13;
        return _amountOfTokens;&#13;
    }&#13;
&#13;
    /**&#13;
     * Calculate Token price based on an amount of incoming ethereum&#13;
     * It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;&#13;
     * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.&#13;
     */&#13;
    function ethereumToTokens_(uint256 _ethereum)&#13;
        internal&#13;
        view&#13;
        returns(uint256)&#13;
    {&#13;
        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;&#13;
        uint256 _tokensReceived = &#13;
         (&#13;
            (&#13;
                // underflow attempts BTFO&#13;
                SafeMath.sub(&#13;
                    (sqrt&#13;
                        (&#13;
                            (_tokenPriceInitial**2)&#13;
                            +&#13;
                            (2*(tokenPriceIncremental_ * 1e18)*(_ethereum * 1e18))&#13;
                            +&#13;
                            (((tokenPriceIncremental_)**2)*(tokenSupply_**2))&#13;
                            +&#13;
                            (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)&#13;
                        )&#13;
                    ), _tokenPriceInitial&#13;
                )&#13;
            )/(tokenPriceIncremental_)&#13;
        )-(tokenSupply_)&#13;
        ;&#13;
  &#13;
        return _tokensReceived;&#13;
    }&#13;
    &#13;
    /**&#13;
     * Calculate token sell value.&#13;
     * It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;&#13;
     * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.&#13;
     */&#13;
     function tokensToEthereum_(uint256 _tokens)&#13;
        internal&#13;
        view&#13;
        returns(uint256)&#13;
    {&#13;
&#13;
        uint256 tokens_ = (_tokens + 1e18);&#13;
        uint256 _tokenSupply = (tokenSupply_ + 1e18);&#13;
        uint256 _etherReceived =&#13;
        (&#13;
            // underflow attempts BTFO&#13;
            SafeMath.sub(&#13;
                (&#13;
                    (&#13;
                        (&#13;
                            tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18))&#13;
                        )-tokenPriceIncremental_&#13;
                    )*(tokens_ - 1e18)&#13;
                ),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2&#13;
            )&#13;
        /1e18);&#13;
        return _etherReceived;&#13;
    }&#13;
    &#13;
    &#13;
    //This is where all your gas goes, sorry&#13;
    //Not sorry, you probably only paid 1 gwei&#13;
    function sqrt(uint x) internal pure returns (uint y) {&#13;
        uint z = (x + 1) / 2;&#13;
        y = x;&#13;
        while (z &lt; y) {&#13;
            y = z;&#13;
            z = (x / z + z) / 2;&#13;
        }&#13;
    }&#13;
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
}
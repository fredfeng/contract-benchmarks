pragma solidity ^0.4.17;

// ----------------------------------------------------------------------------------------------
// Kryptor Token by EdooPAD Inc.
// An ERC20 standard
//
// author: EdooPAD Inc.
// Contact: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e4938d88888d8589a481808b8b948580ca878b89">[email protected]</a> &#13;
&#13;
contract ERC20Interface {&#13;
    // Get the total token supply&#13;
    function totalSupply() public constant returns (uint256 _totalSupply);&#13;
 &#13;
    // Get the account balance of another account with address _owner&#13;
    function balanceOf(address _owner) public constant returns (uint256 balance);&#13;
 &#13;
    // Send _value amount of tokens to address _to&#13;
    function transfer(address _to, uint256 _value) public returns (bool success);&#13;
  &#13;
    // Triggered when tokens are transferred.&#13;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);&#13;
 &#13;
    // Triggered whenever approve(address _spender, uint256 _value) is called.&#13;
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);&#13;
}&#13;
 &#13;
contract Kryptor is ERC20Interface {&#13;
    uint public constant decimals = 10;&#13;
&#13;
    string public constant symbol = "Kryptor";&#13;
    string public constant name = "Kryptor";&#13;
&#13;
    uint private constant icoSupplyRatio = 30;  // percentage of _icoSupply in _totalSupply. Preset: 30%&#13;
    uint private constant bonusRatio = 20;   // sale bonus percentage&#13;
    uint private constant bonusBound = 10;  // First 10% of totalSupply get bonus&#13;
    uint private constant initialPrice = 5000; // Initially, 5000 Kryptor = 1 ETH&#13;
&#13;
    bool public _selling = true;&#13;
    uint public _totalSupply = 10 ** 19; // total supply is 10^19 unit, equivalent to 10^9 Kryptor&#13;
    uint public _originalBuyPrice = (10 ** 18) / (initialPrice * 10**decimals); // original buy in wei of one unit. Ajustable.&#13;
&#13;
    // Owner of this contract&#13;
    address public owner;&#13;
 &#13;
    // Balances Kryptor for each account&#13;
    mapping(address =&gt; uint256) balances;&#13;
    &#13;
    // _icoSupply is the avalable unit. Initially, it is _totalSupply&#13;
    // uint public _icoSupply = _totalSupply - (_totalSupply * bonusBound)/100 * bonusRatio;&#13;
    uint public _icoSupply = (_totalSupply * icoSupplyRatio) / 100;&#13;
    &#13;
    // amount of units with bonus&#13;
    uint public bonusRemain = (_totalSupply * bonusBound) / 100;//10% _totalSupply&#13;
    &#13;
    /* Functions with this modifier can only be executed by the owner&#13;
     */&#13;
    modifier onlyOwner() {&#13;
        if (msg.sender != owner) {&#13;
            revert();&#13;
        }&#13;
        _;&#13;
    }&#13;
&#13;
    /* Functions with this modifier can only be executed by users except owners&#13;
     */&#13;
    modifier onlyNotOwner() {&#13;
        if (msg.sender == owner) {&#13;
            revert();&#13;
        }&#13;
        _;&#13;
    }&#13;
&#13;
    /* Functions with this modifier check on sale status&#13;
     * Only allow sale if _selling is on&#13;
     */&#13;
    modifier onSale() {&#13;
        if (!_selling || (_icoSupply &lt;= 0) ) { &#13;
            revert();&#13;
        }&#13;
        _;&#13;
    }&#13;
&#13;
    /* Functions with this modifier check the validity of original buy price&#13;
     */&#13;
    modifier validOriginalBuyPrice() {&#13;
        if(_originalBuyPrice &lt;= 0) {&#13;
            revert();&#13;
        }&#13;
        _;&#13;
    }&#13;
&#13;
    ///  Fallback function allows to buy ether.&#13;
    function()&#13;
        public&#13;
        payable&#13;
    {&#13;
        buy();&#13;
    }&#13;
&#13;
    /// @dev Constructor&#13;
    function Kryptor() &#13;
        public {&#13;
        owner = msg.sender;&#13;
        balances[owner] = _totalSupply;&#13;
    }&#13;
    &#13;
    /// @dev Gets totalSupply&#13;
    /// @return Total supply&#13;
    function totalSupply()&#13;
        public &#13;
        constant &#13;
        returns (uint256) {&#13;
        return _totalSupply;&#13;
    }&#13;
 &#13;
    /// @dev Gets account's balance&#13;
    /// @param _addr Address of the account&#13;
    /// @return Account balance&#13;
    function balanceOf(address _addr) &#13;
        public&#13;
        constant &#13;
        returns (uint256) {&#13;
        return balances[_addr];&#13;
    }&#13;
 &#13;
    /// @dev Transfers the balance from Multisig wallet to an account&#13;
    /// @param _to Recipient address&#13;
    /// @param _amount Transfered amount in unit&#13;
    /// @return Transfer status&#13;
    function transfer(address _to, uint256 _amount)&#13;
        public &#13;
        returns (bool) {&#13;
        // if sender's balance has enough unit and amount &gt; 0, &#13;
        //      and the sum is not overflow,&#13;
        // then do transfer &#13;
        if ( (balances[msg.sender] &gt;= _amount) &amp;&amp;&#13;
             (_amount &gt; 0) &amp;&amp; &#13;
             (balances[_to] + _amount &gt; balances[_to]) ) {  &#13;
&#13;
            balances[msg.sender] -= _amount;&#13;
            balances[_to] += _amount;&#13;
            Transfer(msg.sender, _to, _amount);&#13;
            &#13;
            return true;&#13;
&#13;
        } else {&#13;
            return false;&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Enables sale &#13;
    function turnOnSale() onlyOwner &#13;
        public {&#13;
        _selling = true;&#13;
    }&#13;
&#13;
    /// @dev Disables sale&#13;
    function turnOffSale() onlyOwner &#13;
        public {&#13;
        _selling = false;&#13;
    }&#13;
&#13;
    /// @dev Gets selling status&#13;
    function isSellingNow() &#13;
        public &#13;
        constant&#13;
        returns (bool) {&#13;
        return _selling;&#13;
    }&#13;
&#13;
    /// @dev Updates buy price (owner ONLY)&#13;
    /// @param newBuyPrice New buy price (in unit)&#13;
    function setBuyPrice(uint newBuyPrice) onlyOwner &#13;
        public {&#13;
        _originalBuyPrice = newBuyPrice;&#13;
    }&#13;
    &#13;
    /*&#13;
     *  Exchange wei for Kryptor.&#13;
     *  modifier _icoSupply &gt; 0&#13;
     *  if requestedCoin &gt; _icoSupply &#13;
     *      revert&#13;
     *  &#13;
     *  Buy transaction must follow this policy:&#13;
     *      if requestedCoin &lt; bonusRemain&#13;
     *          actualCoin = requestedCoin + 20%requestedCoin&#13;
     *          bonusRemain -= requestedCoin&#13;
     *          _icoSupply -= requestedCoin&#13;
     *      else&#13;
     *          actualCoin = requestedCoin + 20%bonusRemain&#13;
     *          _icoSupply -= requested&#13;
     *          bonusRemain = 0&#13;
     *&#13;
     *   Return: &#13;
     *       amount: actual amount of units sold.&#13;
     *&#13;
     *   NOTE: msg.value is in wei&#13;
     */ &#13;
    /// @dev Buys Kryptor&#13;
    /// @return Amount of actual sold units &#13;
    function buy() payable onlyNotOwner validOriginalBuyPrice onSale &#13;
        public&#13;
        returns (uint256 amount) {&#13;
        // convert buy amount in wei to number of unit want to buy&#13;
        uint requestedUnits = msg.value / _originalBuyPrice ;&#13;
        &#13;
        //check requestedUnits &gt; _icoSupply&#13;
        if(requestedUnits &gt; _icoSupply){&#13;
            revert();&#13;
        }&#13;
        &#13;
        // amount of Kryptor bought&#13;
        uint actualSoldUnits = 0;&#13;
&#13;
        // If bonus is available and requested amount of units is less than bonus amount&#13;
        if (requestedUnits &lt; bonusRemain) {&#13;
            // calculate actual sold units with bonus to the requested amount of units&#13;
            actualSoldUnits = requestedUnits + ((requestedUnits*bonusRatio) / 100); &#13;
            // decrease _icoSupply&#13;
            _icoSupply -= requestedUnits;&#13;
            &#13;
            // decrease available bonus amount&#13;
            bonusRemain -= requestedUnits;&#13;
        }&#13;
        else {&#13;
            // calculate actual sold units with bonus - if available - to the requested amount of units&#13;
            actualSoldUnits = requestedUnits + (bonusRemain * bonusRatio) / 100;&#13;
            &#13;
            // otherwise, decrease _icoSupply by the requested amount&#13;
            _icoSupply -= requestedUnits;&#13;
&#13;
            // no more bonus&#13;
            bonusRemain = 0;&#13;
        }&#13;
&#13;
        // prepare transfer data&#13;
        balances[owner] -= actualSoldUnits;&#13;
        balances[msg.sender] += actualSoldUnits;&#13;
&#13;
        //transfer ETH to owner&#13;
        owner.transfer(msg.value);&#13;
        &#13;
        // submit transfer&#13;
        Transfer(owner, msg.sender, actualSoldUnits);&#13;
&#13;
        return actualSoldUnits;&#13;
    }&#13;
    &#13;
    /// @dev Withdraws Ether in contract (Owner only)&#13;
    function withdraw() onlyOwner &#13;
        public &#13;
        returns (bool) {&#13;
        return owner.send(this.balance);&#13;
    }&#13;
}
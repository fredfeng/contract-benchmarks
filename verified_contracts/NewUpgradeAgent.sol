pragma solidity ^0.4.8;

// accepted from zeppelin-solidity https://github.com/OpenZeppelin/zeppelin-solidity
/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
    uint public totalSupply;
    function balanceOf(address who) constant returns (uint);
    function allowance(address owner, address spender) constant returns (uint);

    function transfer(address to, uint value) returns (bool ok);
    function transferFrom(address from, address to, uint value) returns (bool ok);
    function approve(address spender, uint value) returns (bool ok);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

// accepted from zeppelin-solidity https://github.com/OpenZeppelin/zeppelin-solidity

/**
 * Math operations with safety checks
 */
contract SafeMath {
    function safeMul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint a, uint b) internal returns (uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function safeSub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }

    function max64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a < b ? a : b;
    }

    function assert(bool assertion) internal {
        if (!assertion) {
            throw;
        }
    }

}

/// @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.
/// @author Stefan George - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f88b8c9d9e9996d69f9d978a9f9db89b97968b9d968b818bd6969d8c">[email protected]</a>&gt;&#13;
contract MultiSigWallet {&#13;
&#13;
    // flag to determine if address is for a real contract or not&#13;
    bool public isMultiSigWallet = false;&#13;
&#13;
    uint constant public MAX_OWNER_COUNT = 50;&#13;
&#13;
    event Confirmation(address indexed sender, uint indexed transactionId);&#13;
    event Revocation(address indexed sender, uint indexed transactionId);&#13;
    event Submission(uint indexed transactionId);&#13;
    event Execution(uint indexed transactionId);&#13;
    event ExecutionFailure(uint indexed transactionId);&#13;
    event Deposit(address indexed sender, uint value);&#13;
    event OwnerAddition(address indexed owner);&#13;
    event OwnerRemoval(address indexed owner);&#13;
    event RequirementChange(uint required);&#13;
&#13;
    mapping (uint =&gt; Transaction) public transactions;&#13;
    mapping (uint =&gt; mapping (address =&gt; bool)) public confirmations;&#13;
    mapping (address =&gt; bool) public isOwner;&#13;
    address[] public owners;&#13;
    uint public required;&#13;
    uint public transactionCount;&#13;
&#13;
    struct Transaction {&#13;
    address destination;&#13;
    uint value;&#13;
    bytes data;&#13;
    bool executed;&#13;
    }&#13;
&#13;
    modifier onlyWallet() {&#13;
        if (msg.sender != address(this)) throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier ownerDoesNotExist(address owner) {&#13;
        if (isOwner[owner]) throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier ownerExists(address owner) {&#13;
        if (!isOwner[owner]) throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier transactionExists(uint transactionId) {&#13;
        if (transactions[transactionId].destination == 0) throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier confirmed(uint transactionId, address owner) {&#13;
        if (!confirmations[transactionId][owner]) throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier notConfirmed(uint transactionId, address owner) {&#13;
        if (confirmations[transactionId][owner]) throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier notExecuted(uint transactionId) {&#13;
        if (transactions[transactionId].executed) throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier notNull(address _address) {&#13;
        if (_address == 0) throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier validRequirement(uint ownerCount, uint _required) {&#13;
        if (ownerCount &gt; MAX_OWNER_COUNT) throw;&#13;
        if (_required &gt; ownerCount) throw;&#13;
        if (_required == 0) throw;&#13;
        if (ownerCount == 0) throw;&#13;
        _;&#13;
    }&#13;
&#13;
    /// @dev Fallback function allows to deposit ether.&#13;
    function()&#13;
    payable&#13;
    {&#13;
        if (msg.value &gt; 0)&#13;
        Deposit(msg.sender, msg.value);&#13;
    }&#13;
&#13;
    /*&#13;
     * Public functions&#13;
     */&#13;
    /// @dev Contract constructor sets initial owners and required number of confirmations.&#13;
    /// @param _owners List of initial owners.&#13;
    /// @param _required Number of required confirmations.&#13;
    function MultiSigWallet(address[] _owners, uint _required)&#13;
    public&#13;
    validRequirement(_owners.length, _required)&#13;
    {&#13;
        for (uint i=0; i&lt;_owners.length; i++) {&#13;
            if (isOwner[_owners[i]] || _owners[i] == 0) throw;&#13;
            isOwner[_owners[i]] = true;&#13;
        }&#13;
        isMultiSigWallet = true;&#13;
        owners = _owners;&#13;
        required = _required;&#13;
    }&#13;
&#13;
    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.&#13;
    /// @param owner Address of new owner.&#13;
    function addOwner(address owner)&#13;
    public&#13;
    onlyWallet&#13;
    ownerDoesNotExist(owner)&#13;
    notNull(owner)&#13;
    validRequirement(owners.length + 1, required)&#13;
    {&#13;
        isOwner[owner] = true;&#13;
        owners.push(owner);&#13;
        OwnerAddition(owner);&#13;
    }&#13;
&#13;
    /// @dev Allows to remove an owner. Transaction has to be sent by wallet.&#13;
    /// @param owner Address of owner.&#13;
    function removeOwner(address owner)&#13;
    public&#13;
    onlyWallet&#13;
    ownerExists(owner)&#13;
    {&#13;
        isOwner[owner] = false;&#13;
        for (uint i=0; i&lt;owners.length - 1; i++)&#13;
        if (owners[i] == owner) {&#13;
            owners[i] = owners[owners.length - 1];&#13;
            break;&#13;
        }&#13;
        owners.length -= 1;&#13;
        if (required &gt; owners.length)&#13;
        changeRequirement(owners.length);&#13;
        OwnerRemoval(owner);&#13;
    }&#13;
&#13;
    /// @dev Allows to replace an owner with a new owner. Transaction has to be sent by wallet.&#13;
    /// @param owner Address of owner to be replaced.&#13;
    /// @param newOwner Address of new owner.&#13;
    /// @param index the indx of the owner to be replaced&#13;
    function replaceOwnerIndexed(address owner, address newOwner, uint index)&#13;
    public&#13;
    onlyWallet&#13;
    ownerExists(owner)&#13;
    ownerDoesNotExist(newOwner)&#13;
    {&#13;
        if (owners[index] != owner) throw;&#13;
        owners[index] = newOwner;&#13;
        isOwner[owner] = false;&#13;
        isOwner[newOwner] = true;&#13;
        OwnerRemoval(owner);&#13;
        OwnerAddition(newOwner);&#13;
    }&#13;
&#13;
&#13;
    /// @dev Allows to change the number of required confirmations. Transaction has to be sent by wallet.&#13;
    /// @param _required Number of required confirmations.&#13;
    function changeRequirement(uint _required)&#13;
    public&#13;
    onlyWallet&#13;
    validRequirement(owners.length, _required)&#13;
    {&#13;
        required = _required;&#13;
        RequirementChange(_required);&#13;
    }&#13;
&#13;
    /// @dev Allows an owner to submit and confirm a transaction.&#13;
    /// @param destination Transaction target address.&#13;
    /// @param value Transaction ether value.&#13;
    /// @param data Transaction data payload.&#13;
    /// @return Returns transaction ID.&#13;
    function submitTransaction(address destination, uint value, bytes data)&#13;
    public&#13;
    returns (uint transactionId)&#13;
    {&#13;
        transactionId = addTransaction(destination, value, data);&#13;
        confirmTransaction(transactionId);&#13;
    }&#13;
&#13;
    /// @dev Allows an owner to confirm a transaction.&#13;
    /// @param transactionId Transaction ID.&#13;
    function confirmTransaction(uint transactionId)&#13;
    public&#13;
    ownerExists(msg.sender)&#13;
    transactionExists(transactionId)&#13;
    notConfirmed(transactionId, msg.sender)&#13;
    {&#13;
        confirmations[transactionId][msg.sender] = true;&#13;
        Confirmation(msg.sender, transactionId);&#13;
        executeTransaction(transactionId);&#13;
    }&#13;
&#13;
    /// @dev Allows an owner to revoke a confirmation for a transaction.&#13;
    /// @param transactionId Transaction ID.&#13;
    function revokeConfirmation(uint transactionId)&#13;
    public&#13;
    ownerExists(msg.sender)&#13;
    confirmed(transactionId, msg.sender)&#13;
    notExecuted(transactionId)&#13;
    {&#13;
        confirmations[transactionId][msg.sender] = false;&#13;
        Revocation(msg.sender, transactionId);&#13;
    }&#13;
&#13;
    /// @dev Returns the confirmation status of a transaction.&#13;
    /// @param transactionId Transaction ID.&#13;
    /// @return Confirmation status.&#13;
    function isConfirmed(uint transactionId)&#13;
    public&#13;
    constant&#13;
    returns (bool)&#13;
    {&#13;
        uint count = 0;&#13;
        for (uint i=0; i&lt;owners.length; i++) {&#13;
            if (confirmations[transactionId][owners[i]])&#13;
            count += 1;&#13;
            if (count == required)&#13;
            return true;&#13;
        }&#13;
    }&#13;
&#13;
    /*&#13;
     * Internal functions&#13;
     */&#13;
&#13;
    /// @dev Allows anyone to execute a confirmed transaction.&#13;
    /// @param transactionId Transaction ID.&#13;
    function executeTransaction(uint transactionId)&#13;
    internal&#13;
    notExecuted(transactionId)&#13;
    {&#13;
        if (isConfirmed(transactionId)) {&#13;
            Transaction tx = transactions[transactionId];&#13;
            tx.executed = true;&#13;
            if (tx.destination.call.value(tx.value)(tx.data))&#13;
            Execution(transactionId);&#13;
            else {&#13;
                ExecutionFailure(transactionId);&#13;
                tx.executed = false;&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.&#13;
    /// @param destination Transaction target address.&#13;
    /// @param value Transaction ether value.&#13;
    /// @param data Transaction data payload.&#13;
    /// @return Returns transaction ID.&#13;
    function addTransaction(address destination, uint value, bytes data)&#13;
    internal&#13;
    notNull(destination)&#13;
    returns (uint transactionId)&#13;
    {&#13;
        transactionId = transactionCount;&#13;
        transactions[transactionId] = Transaction({&#13;
        destination: destination,&#13;
        value: value,&#13;
        data: data,&#13;
        executed: false&#13;
        });&#13;
        transactionCount += 1;&#13;
        Submission(transactionId);&#13;
    }&#13;
&#13;
    /*&#13;
     * Web3 call functions&#13;
     */&#13;
    /// @dev Returns number of confirmations of a transaction.&#13;
    /// @param transactionId Transaction ID.&#13;
    /// @return Number of confirmations.&#13;
    function getConfirmationCount(uint transactionId)&#13;
    public&#13;
    constant&#13;
    returns (uint count)&#13;
    {&#13;
        for (uint i=0; i&lt;owners.length; i++)&#13;
        if (confirmations[transactionId][owners[i]])&#13;
        count += 1;&#13;
    }&#13;
&#13;
    /// @dev Returns total number of transactions after filers are applied.&#13;
    /// @param pending Include pending transactions.&#13;
    /// @param executed Include executed transactions.&#13;
    /// @return Total number of transactions after filters are applied.&#13;
    function getTransactionCount(bool pending, bool executed)&#13;
    public&#13;
    constant&#13;
    returns (uint count)&#13;
    {&#13;
        for (uint i=0; i&lt;transactionCount; i++)&#13;
        if ((pending &amp;&amp; !transactions[i].executed) ||&#13;
        (executed &amp;&amp; transactions[i].executed))&#13;
        count += 1;&#13;
    }&#13;
&#13;
    /// @dev Returns list of owners.&#13;
    /// @return List of owner addresses.&#13;
    function getOwners()&#13;
    public&#13;
    constant&#13;
    returns (address[])&#13;
    {&#13;
        return owners;&#13;
    }&#13;
&#13;
    /// @dev Returns array with owner addresses, which confirmed transaction.&#13;
    /// @param transactionId Transaction ID.&#13;
    /// @return Returns array of owner addresses.&#13;
    function getConfirmations(uint transactionId)&#13;
    public&#13;
    constant&#13;
    returns (address[] _confirmations)&#13;
    {&#13;
        address[] memory confirmationsTemp = new address[](owners.length);&#13;
        uint count = 0;&#13;
        uint i;&#13;
        for (i=0; i&lt;owners.length; i++)&#13;
        if (confirmations[transactionId][owners[i]]) {&#13;
            confirmationsTemp[count] = owners[i];&#13;
            count += 1;&#13;
        }&#13;
        _confirmations = new address[](count);&#13;
        for (i=0; i&lt;count; i++)&#13;
        _confirmations[i] = confirmationsTemp[i];&#13;
    }&#13;
&#13;
    /// @dev Returns list of transaction IDs in defined range.&#13;
    /// @param from Index start position of transaction array.&#13;
    /// @param to Index end position of transaction array.&#13;
    /// @param pending Include pending transactions.&#13;
    /// @param executed Include executed transactions.&#13;
    /// @return Returns array of transaction IDs.&#13;
    function getTransactionIds(uint from, uint to, bool pending, bool executed)&#13;
    public&#13;
    constant&#13;
    returns (uint[] _transactionIds)&#13;
    {&#13;
        uint[] memory transactionIdsTemp = new uint[](transactionCount);&#13;
        uint count = 0;&#13;
        uint i;&#13;
        for (i=0; i&lt;transactionCount; i++)&#13;
        if ((pending &amp;&amp; !transactions[i].executed) ||&#13;
        (executed &amp;&amp; transactions[i].executed))&#13;
        {&#13;
            transactionIdsTemp[count] = i;&#13;
            count += 1;&#13;
        }&#13;
        _transactionIds = new uint[](to - from);&#13;
        for (i=from; i&lt;to; i++)&#13;
        _transactionIds[i - from] = transactionIdsTemp[i];&#13;
    }&#13;
&#13;
}&#13;
&#13;
contract OldToken is ERC20 {&#13;
    // flag to determine if address is for a real contract or not&#13;
    bool public isDecentBetToken;&#13;
&#13;
    address public decentBetMultisig;&#13;
}&#13;
&#13;
contract NextUpgradeAgent is SafeMath {&#13;
    address public owner;&#13;
&#13;
    bool public isUpgradeAgent;&#13;
&#13;
    function upgradeFrom(address _from, uint256 _value) public;&#13;
&#13;
    function finalizeUpgrade() public;&#13;
&#13;
    function setOriginalSupply() public;&#13;
}&#13;
&#13;
/// @title Time-locked vault of tokens allocated to DecentBet after 365 days&#13;
contract NewDecentBetVault is SafeMath {&#13;
&#13;
    // flag to determine if address is for a real contract or not&#13;
    bool public isDecentBetVault = false;&#13;
&#13;
    NewDecentBetToken decentBetToken;&#13;
&#13;
    address decentBetMultisig;&#13;
&#13;
    uint256 unlockedAtTime;&#13;
&#13;
    // 1 year lockup&#13;
    uint256 public constant timeOffset = 47 weeks;&#13;
&#13;
    /// @notice Constructor function sets the DecentBet Multisig address and&#13;
    /// total number of locked tokens to transfer&#13;
    function NewDecentBetVault(address _decentBetMultisig) /** internal */ {&#13;
        if (_decentBetMultisig == 0x0) revert();&#13;
        decentBetToken = NewDecentBetToken(msg.sender);&#13;
        decentBetMultisig = _decentBetMultisig;&#13;
        isDecentBetVault = true;&#13;
&#13;
        // 1 year later&#13;
        unlockedAtTime = safeAdd(getTime(), timeOffset);&#13;
    }&#13;
&#13;
    /// @notice Transfer locked tokens to Decent.bet's multisig wallet&#13;
    function unlock() external {&#13;
        // Wait your turn!&#13;
        if (getTime() &lt; unlockedAtTime) revert();&#13;
        // Will fail if allocation (and therefore toTransfer) is 0.&#13;
        if (!decentBetToken.transfer(decentBetMultisig, decentBetToken.balanceOf(this))) revert();&#13;
    }&#13;
&#13;
    function getTime() internal returns (uint256) {&#13;
        return now;&#13;
    }&#13;
&#13;
    // disallow ETH payments to TimeVault&#13;
    function() payable {&#13;
        revert();&#13;
    }&#13;
&#13;
}&#13;
&#13;
contract NewDecentBetToken is ERC20, SafeMath {&#13;
&#13;
    // Token information&#13;
    bool public isDecentBetToken;&#13;
&#13;
    string public constant name = "Decent.Bet Token";&#13;
&#13;
    string public constant symbol = "DBET";&#13;
&#13;
    uint256 public constant decimals = 18;  // decimal places&#13;
&#13;
    uint256 public constant housePercentOfTotal = 10;&#13;
&#13;
    uint256 public constant vaultPercentOfTotal = 18;&#13;
&#13;
    uint256 public constant bountyPercentOfTotal = 2;&#13;
&#13;
    uint256 public constant crowdfundPercentOfTotal = 70;&#13;
&#13;
    // flag to determine if address is for a real contract or not&#13;
    bool public isNewToken = false;&#13;
&#13;
    // Token information&#13;
    mapping (address =&gt; uint256) balances;&#13;
&#13;
    mapping (address =&gt; mapping (address =&gt; uint256)) allowed;&#13;
&#13;
    // Upgrade information&#13;
    NewUpgradeAgent public upgradeAgent;&#13;
&#13;
    NextUpgradeAgent public nextUpgradeAgent;&#13;
&#13;
    bool public finalizedNextUpgrade = false;&#13;
&#13;
    address public nextUpgradeMaster;&#13;
&#13;
    event Upgrade(address indexed _from, address indexed _to, uint256 _value);&#13;
&#13;
    event UpgradeFinalized(address sender, address nextUpgradeAgent);&#13;
&#13;
    event UpgradeAgentSet(address agent);&#13;
&#13;
    uint256 public totalUpgraded;&#13;
&#13;
    // Old Token Information&#13;
    OldToken public oldToken;&#13;
&#13;
    address public decentBetMultisig;&#13;
&#13;
    uint256 public oldTokenTotalSupply;&#13;
&#13;
    NewDecentBetVault public timeVault;&#13;
&#13;
    function NewDecentBetToken(address _upgradeAgent,&#13;
    address _oldToken, address _nextUpgradeMaster) public {&#13;
&#13;
        isNewToken = true;&#13;
&#13;
        isDecentBetToken = true;&#13;
&#13;
        if (_upgradeAgent == 0x0) revert();&#13;
        upgradeAgent = NewUpgradeAgent(_upgradeAgent);&#13;
&#13;
        if (_nextUpgradeMaster == 0x0) revert();&#13;
        nextUpgradeMaster = _nextUpgradeMaster;&#13;
&#13;
        oldToken = OldToken(_oldToken);&#13;
        if (!oldToken.isDecentBetToken()) revert();&#13;
        oldTokenTotalSupply = oldToken.totalSupply();&#13;
&#13;
        decentBetMultisig = oldToken.decentBetMultisig();&#13;
        if (!MultiSigWallet(decentBetMultisig).isMultiSigWallet()) revert();&#13;
&#13;
        timeVault = new NewDecentBetVault(decentBetMultisig);&#13;
        if (!timeVault.isDecentBetVault()) revert();&#13;
&#13;
        // Founder's supply : 18% of total goes to vault, time locked for 1 year&#13;
        uint256 vaultTokens = safeDiv(safeMul(oldTokenTotalSupply, vaultPercentOfTotal),&#13;
        crowdfundPercentOfTotal);&#13;
        balances[timeVault] = safeAdd(balances[timeVault], vaultTokens);&#13;
        Transfer(0, timeVault, vaultTokens);&#13;
&#13;
        // House: 10% of total goes to Decent.bet for initial house setup&#13;
        uint256 houseTokens = safeDiv(safeMul(oldTokenTotalSupply, housePercentOfTotal),&#13;
        crowdfundPercentOfTotal);&#13;
        balances[decentBetMultisig] = safeAdd(balances[decentBetMultisig], houseTokens);&#13;
        Transfer(0, decentBetMultisig, houseTokens);&#13;
&#13;
        // Bounties: 2% of total goes to Decent bet for bounties&#13;
        uint256 bountyTokens = safeDiv(safeMul(oldTokenTotalSupply, bountyPercentOfTotal),&#13;
        crowdfundPercentOfTotal);&#13;
        balances[decentBetMultisig] = safeAdd(balances[decentBetMultisig], bountyTokens);&#13;
        Transfer(0, decentBetMultisig, bountyTokens);&#13;
&#13;
        totalSupply = safeAdd(safeAdd(vaultTokens, houseTokens), bountyTokens);&#13;
    }&#13;
&#13;
    // Upgrade-related methods&#13;
    function createToken(address _target, uint256 _amount) public {&#13;
        if (msg.sender != address(upgradeAgent)) revert();&#13;
        if (_amount == 0) revert();&#13;
&#13;
        balances[_target] = safeAdd(balances[_target], _amount);&#13;
        totalSupply = safeAdd(totalSupply, _amount);&#13;
        Transfer(_target, _target, _amount);&#13;
    }&#13;
&#13;
    // ERC20 interface: transfer _value new tokens from msg.sender to _to&#13;
    function transfer(address _to, uint256 _value) returns (bool success) {&#13;
        if (_to == 0x0) revert();&#13;
        if (_to == address(upgradeAgent)) revert();&#13;
        if (_to == address(this)) revert();&#13;
        //if (_to == address(UpgradeAgent(upgradeAgent).oldToken())) revert();&#13;
        if (balances[msg.sender] &gt;= _value &amp;&amp; _value &gt; 0) {&#13;
            balances[msg.sender] = safeSub(balances[msg.sender], _value);&#13;
            balances[_to] = safeAdd(balances[_to], _value);&#13;
            Transfer(msg.sender, _to, _value);&#13;
            return true;&#13;
        }&#13;
        else {return false;}&#13;
    }&#13;
&#13;
    // ERC20 interface: transfer _value new tokens from _from to _to&#13;
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {&#13;
        if (_to == 0x0) revert();&#13;
        if (_to == address(upgradeAgent)) revert();&#13;
        if (_to == address(this)) revert();&#13;
        //if (_to == address(UpgradeAgent(upgradeAgent).oldToken())) revert();&#13;
        if (balances[_from] &gt;= _value &amp;&amp; allowed[_from][msg.sender] &gt;= _value) {&#13;
            balances[_to] = safeAdd(balances[_to], _value);&#13;
            balances[_from] = safeSub(balances[_from], _value);&#13;
            allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);&#13;
            Transfer(_from, _to, _value);&#13;
            return true;&#13;
        }&#13;
        else {return false;}&#13;
    }&#13;
&#13;
    // ERC20 interface: delegate transfer rights of up to _value new tokens from&#13;
    // msg.sender to _spender&#13;
    function approve(address _spender, uint256 _value) returns (bool success) {&#13;
        allowed[msg.sender][_spender] = _value;&#13;
        Approval(msg.sender, _spender, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    // ERC20 interface: returns the amount of new tokens belonging to _owner&#13;
    // that _spender can spend via transferFrom&#13;
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {&#13;
        return allowed[_owner][_spender];&#13;
    }&#13;
&#13;
    // ERC20 interface: returns the wmount of new tokens belonging to _owner&#13;
    function balanceOf(address _owner) constant returns (uint256 balance) {&#13;
        return balances[_owner];&#13;
    }&#13;
&#13;
    // Token upgrade functionality&#13;
&#13;
    /// @notice Upgrade tokens to the new token contract.&#13;
    /// @param value The number of tokens to upgrade&#13;
    function upgrade(uint256 value) external {&#13;
        if (nextUpgradeAgent.owner() == 0x0) revert();&#13;
        // need a real upgradeAgent address&#13;
        if (finalizedNextUpgrade) revert();&#13;
        // cannot upgrade if finalized&#13;
&#13;
        // Validate input value.&#13;
        if (value == 0) revert();&#13;
        if (value &gt; balances[msg.sender]) revert();&#13;
&#13;
        // update the balances here first before calling out (reentrancy)&#13;
        balances[msg.sender] = safeSub(balances[msg.sender], value);&#13;
        totalSupply = safeSub(totalSupply, value);&#13;
        totalUpgraded = safeAdd(totalUpgraded, value);&#13;
        nextUpgradeAgent.upgradeFrom(msg.sender, value);&#13;
        Upgrade(msg.sender, nextUpgradeAgent, value);&#13;
    }&#13;
&#13;
    /// @notice Set address of next upgrade target contract and enable upgrade&#13;
    /// process.&#13;
    /// @param agent The address of the UpgradeAgent contract&#13;
    function setNextUpgradeAgent(address agent) external {&#13;
        if (agent == 0x0) revert();&#13;
        // don't set agent to nothing&#13;
        if (msg.sender != nextUpgradeMaster) revert();&#13;
        // Only a master can designate the next agent&#13;
        nextUpgradeAgent = NextUpgradeAgent(agent);&#13;
        if (!nextUpgradeAgent.isUpgradeAgent()) revert();&#13;
        nextUpgradeAgent.setOriginalSupply();&#13;
        UpgradeAgentSet(nextUpgradeAgent);&#13;
    }&#13;
&#13;
    /// @notice Set address of next upgrade master and enable upgrade&#13;
    /// process.&#13;
    /// @param master The address that will manage upgrades, not the upgradeAgent contract address&#13;
    function setNextUpgradeMaster(address master) external {&#13;
        if (master == 0x0) revert();&#13;
        if (msg.sender != nextUpgradeMaster) revert();&#13;
        // Only a master can designate the next master&#13;
        nextUpgradeMaster = master;&#13;
    }&#13;
&#13;
    /// @notice finalize the upgrade&#13;
    /// @dev Required state: Success&#13;
    function finalizeNextUpgrade() external {&#13;
        if (nextUpgradeAgent.owner() == 0x0) revert();&#13;
        // we need a valid upgrade agent&#13;
        if (msg.sender != nextUpgradeMaster) revert();&#13;
        // only upgradeMaster can finalize&#13;
        if (finalizedNextUpgrade) revert();&#13;
        // can't finalize twice&#13;
&#13;
        finalizedNextUpgrade = true;&#13;
        // prevent future upgrades&#13;
&#13;
        nextUpgradeAgent.finalizeUpgrade();&#13;
        // call finalize upgrade on new contract&#13;
        UpgradeFinalized(msg.sender, nextUpgradeAgent);&#13;
    }&#13;
&#13;
    /// @dev Fallback function throws to avoid accidentally losing money&#13;
    function() {revert();}&#13;
}&#13;
&#13;
&#13;
//Test the whole process against this: https://www.kingoftheether.com/contract-safety-checklist.html&#13;
contract NewUpgradeAgent is SafeMath {&#13;
&#13;
    // flag to determine if address is for a real contract or not&#13;
    bool public isUpgradeAgent = false;&#13;
&#13;
    // Contract information&#13;
    address public owner;&#13;
&#13;
    // Upgrade information&#13;
    bool public upgradeHasBegun = false;&#13;
&#13;
    bool public finalizedUpgrade = false;&#13;
&#13;
    OldToken public oldToken;&#13;
&#13;
    address public decentBetMultisig;&#13;
&#13;
    NewDecentBetToken public newToken;&#13;
&#13;
    uint256 public originalSupply; // the original total supply of old tokens&#13;
&#13;
    uint256 public correctOriginalSupply; // Correct original supply accounting for 30% minted at finalizeCrowdfunding&#13;
&#13;
    uint256 public mintedPercentOfTokens = 30; // Amount of tokens that're minted at finalizeCrowdfunding&#13;
&#13;
    uint256 public crowdfundPercentOfTokens = 70;&#13;
&#13;
    uint256 public mintedTokens;&#13;
&#13;
    event NewTokenSet(address token);&#13;
&#13;
    event UpgradeHasBegun();&#13;
&#13;
    event InvariantCheckFailed(uint oldTokenSupply, uint newTokenSupply, uint originalSupply, uint value);&#13;
&#13;
    event InvariantCheckPassed(uint oldTokenSupply, uint newTokenSupply, uint originalSupply, uint value);&#13;
&#13;
    function NewUpgradeAgent(address _oldToken) {&#13;
        owner = msg.sender;&#13;
        isUpgradeAgent = true;&#13;
        oldToken = OldToken(_oldToken);&#13;
        if (!oldToken.isDecentBetToken()) revert();&#13;
        decentBetMultisig = oldToken.decentBetMultisig();&#13;
        originalSupply = oldToken.totalSupply();&#13;
        mintedTokens = safeDiv(safeMul(originalSupply, mintedPercentOfTokens), crowdfundPercentOfTokens);&#13;
        correctOriginalSupply = safeAdd(originalSupply, mintedTokens);&#13;
    }&#13;
&#13;
    /// @notice Check to make sure that the current sum of old and&#13;
    /// new version tokens is still equal to the original number of old version&#13;
    /// tokens&#13;
    /// @param _value The number of DBETs to upgrade&#13;
    function safetyInvariantCheck(uint256 _value) public {&#13;
        if (!newToken.isNewToken()) revert();&#13;
        // Abort if new token contract has not been set&#13;
        uint oldSupply = oldToken.totalSupply();&#13;
        uint newSupply = newToken.totalSupply();&#13;
        if (safeAdd(oldSupply, newSupply) != safeSub(correctOriginalSupply, _value)) {&#13;
            InvariantCheckFailed(oldSupply, newSupply, correctOriginalSupply, _value);&#13;
        } else {&#13;
            InvariantCheckPassed(oldSupply, newSupply, correctOriginalSupply, _value);&#13;
        }&#13;
    }&#13;
&#13;
    /// @notice Sets the new token contract address&#13;
    /// @param _newToken The address of the new token contract&#13;
    function setNewToken(address _newToken) external {&#13;
        if (msg.sender != owner) revert();&#13;
        if (_newToken == 0x0) revert();&#13;
        if (upgradeHasBegun) revert();&#13;
        // Cannot change token after upgrade has begun&#13;
&#13;
        newToken = NewDecentBetToken(_newToken);&#13;
        if (!newToken.isNewToken()) revert();&#13;
        NewTokenSet(newToken);&#13;
    }&#13;
&#13;
    /// @notice Sets flag to prevent changing newToken after upgrade&#13;
    function setUpgradeHasBegun() internal {&#13;
        if (!upgradeHasBegun) {&#13;
            upgradeHasBegun = true;&#13;
            UpgradeHasBegun();&#13;
        }&#13;
    }&#13;
&#13;
    /// @notice Creates new version tokens from the new token&#13;
    /// contract&#13;
    /// @param _from The address of the token upgrader&#13;
    /// @param _value The number of tokens to upgrade&#13;
    function upgradeFrom(address _from, uint256 _value) public {&#13;
        if(finalizedUpgrade) revert();&#13;
        if (msg.sender != address(oldToken)) revert();&#13;
        // Multisig can't upgrade since tokens are minted for it in new token constructor as it isn't part&#13;
        // of totalSupply of oldToken.&#13;
        if (_from == decentBetMultisig) revert();&#13;
        // only upgrade from oldToken&#13;
        if (!newToken.isNewToken()) revert();&#13;
        // need a real newToken!&#13;
&#13;
        setUpgradeHasBegun();&#13;
        // Right here oldToken has already been updated, but corresponding&#13;
        // DBETs have not been created in the newToken contract yet&#13;
        safetyInvariantCheck(_value);&#13;
&#13;
        newToken.createToken(_from, _value);&#13;
&#13;
        //Right here totalSupply invariant must hold&#13;
        safetyInvariantCheck(0);&#13;
    }&#13;
&#13;
    // Initializes original supply from old token total supply&#13;
    function setOriginalSupply() public {&#13;
        if (msg.sender != address(oldToken)) revert();&#13;
        originalSupply = oldToken.totalSupply();&#13;
    }&#13;
&#13;
    function finalizeUpgrade() public {&#13;
        if (msg.sender != address(oldToken)) revert();&#13;
        finalizedUpgrade = true;&#13;
    }&#13;
&#13;
    /// @dev Fallback function disallows depositing ether.&#13;
    function() {revert();}&#13;
&#13;
}
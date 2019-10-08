pragma solidity 0.4.18;
contract Factory {

    /*
     *  Events
     */
    event ContractInstantiation(address sender, address instantiation);

    /*
     *  Storage
     */
    mapping(address => bool) public isInstantiation;
    mapping(address => address[]) public instantiations;

    /*
     * Public functions
     */
    /// @dev Returns number of instantiations by creator.
    /// @param creator Contract creator.
    /// @return Returns number of instantiations by creator.
    function getInstantiationCount(address creator)
        public
        constant
        returns (uint)
    {
        return instantiations[creator].length;
    }

    /*
     * Internal functions
     */
    /// @dev Registers contract in factory registry.
    /// @param instantiation Address of contract instantiation.
    function register(address instantiation)
        internal
    {
        isInstantiation[instantiation] = true;
        instantiations[msg.sender].push(instantiation);
        ContractInstantiation(msg.sender, instantiation);
    }
}


/// @title Multisignature wallet factory - Allows creation of multisig wallet.
/// @author Stefan George - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="1360677675727d3d74767c61747653707c7d60767d606a603d7d7667">[email protected]</a>&gt;&#13;
contract MultiSigWalletFactory is Factory {&#13;
&#13;
    /*&#13;
     * Public functions&#13;
     */&#13;
    /// @dev Allows verified creation of multisignature wallet.&#13;
    /// @param _owners List of initial owners.&#13;
    /// @param _required Number of required confirmations.&#13;
    /// @return Returns wallet address.&#13;
    function create(address[] _owners, uint _required)&#13;
        public&#13;
        returns (address wallet)&#13;
    {&#13;
        wallet = new MultiSigWallet(_owners, _required);&#13;
        register(wallet);&#13;
    }&#13;
}&#13;
&#13;
&#13;
/// @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.&#13;
/// @author Stefan George - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7f0c0b1a191e1151181a100d181a3f1c10110c1a110c060c51111a0b">[email protected]</a>&gt;&#13;
contract MultiSigWallet {&#13;
&#13;
    /*&#13;
     *  Events&#13;
     */&#13;
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
    /*&#13;
     *  Constants&#13;
     */&#13;
    uint constant public MAX_OWNER_COUNT = 50;&#13;
&#13;
    /*&#13;
     *  Storage&#13;
     */&#13;
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
    /*&#13;
     *  Modifiers&#13;
     */&#13;
    modifier onlyWallet() {&#13;
        if (msg.sender != address(this))&#13;
            throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier ownerDoesNotExist(address owner) {&#13;
        if (isOwner[owner])&#13;
            throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier ownerExists(address owner) {&#13;
        if (!isOwner[owner])&#13;
            throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier transactionExists(uint transactionId) {&#13;
        if (transactions[transactionId].destination == 0)&#13;
            throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier confirmed(uint transactionId, address owner) {&#13;
        if (!confirmations[transactionId][owner])&#13;
            throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier notConfirmed(uint transactionId, address owner) {&#13;
        if (confirmations[transactionId][owner])&#13;
            throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier notExecuted(uint transactionId) {&#13;
        if (transactions[transactionId].executed)&#13;
            throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier notNull(address _address) {&#13;
        if (_address == 0)&#13;
            throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier validRequirement(uint ownerCount, uint _required) {&#13;
        if (   ownerCount &gt; MAX_OWNER_COUNT&#13;
            || _required &gt; ownerCount&#13;
            || _required == 0&#13;
            || ownerCount == 0)&#13;
            throw;&#13;
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
            if (isOwner[_owners[i]] || _owners[i] == 0)&#13;
                throw;&#13;
            isOwner[_owners[i]] = true;&#13;
        }&#13;
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
    function replaceOwner(address owner, address newOwner)&#13;
        public&#13;
        onlyWallet&#13;
        ownerExists(owner)&#13;
        ownerDoesNotExist(newOwner)&#13;
    {&#13;
        for (uint i=0; i&lt;owners.length; i++)&#13;
            if (owners[i] == owner) {&#13;
                owners[i] = newOwner;&#13;
                break;&#13;
            }&#13;
        isOwner[owner] = false;&#13;
        isOwner[newOwner] = true;&#13;
        OwnerRemoval(owner);&#13;
        OwnerAddition(newOwner);&#13;
    }&#13;
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
    /// @dev Allows anyone to execute a confirmed transaction.&#13;
    /// @param transactionId Transaction ID.&#13;
    function executeTransaction(uint transactionId)&#13;
        public&#13;
        ownerExists(msg.sender)&#13;
        confirmed(transactionId, msg.sender)&#13;
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
            if (   pending &amp;&amp; !transactions[i].executed&#13;
                || executed &amp;&amp; transactions[i].executed)&#13;
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
            if (   pending &amp;&amp; !transactions[i].executed&#13;
                || executed &amp;&amp; transactions[i].executed)&#13;
            {&#13;
                transactionIdsTemp[count] = i;&#13;
                count += 1;&#13;
            }&#13;
        _transactionIds = new uint[](to - from);&#13;
        for (i=from; i&lt;to; i++)&#13;
            _transactionIds[i - from] = transactionIdsTemp[i];&#13;
    }&#13;
}
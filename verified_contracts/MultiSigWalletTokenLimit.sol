pragma solidity ^0.4.21;

/// @title Multisignature wallet - Allows multiple parties to agree on send ERC20 token transactions before execution.
/// @author Based on code by Stefan George - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d6a5a2b3b0b7b8f8b1b3b9a4b1b396b5b9b8a5b3b8a5afa5f8b8b3a2">[email protected]</a>&gt;&#13;
&#13;
/*&#13;
 * ERC20 interface&#13;
 * see https://github.com/ethereum/EIPs/issues/20&#13;
 */&#13;
contract ERC20&#13;
{&#13;
  function balanceOf(address who) public view returns (uint);&#13;
  function transfer(address to, uint value) public returns (bool ok);&#13;
}&#13;
&#13;
/**&#13;
 * @title SafeMath&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
library SafeMath &#13;
{&#13;
  /**&#13;
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).&#13;
  */&#13;
  function sub(uint a, uint b) &#13;
    internal &#13;
    pure &#13;
    returns (uint) &#13;
  {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Adds two numbers, throws on overflow.&#13;
  */&#13;
  function add(uint a, uint b) &#13;
    internal &#13;
    pure &#13;
    returns (uint) &#13;
  {&#13;
    uint c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
}&#13;
&#13;
contract MultiSigWalletTokenLimit&#13;
{&#13;
  using SafeMath for uint;&#13;
&#13;
  /*&#13;
   *  Events&#13;
   */&#13;
  event Confirmation(address indexed sender, uint indexed transaction_id);&#13;
  event Revocation(address indexed sender, uint indexed transaction_id);&#13;
  event Submission(uint indexed transaction_id);&#13;
  event Execution(uint indexed transaction_id);&#13;
  event ExecutionFailure(uint indexed transaction_id);&#13;
  event TokensReceived(address indexed from, uint value);&#13;
  event Transfer(address indexed to, uint indexed value);&#13;
  event CurrentPeriodChanged(uint indexed current_period, uint indexed current_transferred, uint indexed current_limit);&#13;
&#13;
  /*&#13;
   * Structures&#13;
   */&#13;
  struct Transaction&#13;
  {&#13;
    address to;&#13;
    uint value;&#13;
    bool executed;&#13;
  }&#13;
&#13;
  struct Period&#13;
  {&#13;
    uint timestamp;&#13;
    uint current_limit;&#13;
    uint limit;&#13;
  }&#13;
&#13;
  /*&#13;
  *  Storage&#13;
  */&#13;
  mapping (uint =&gt; Transaction) public transactions;&#13;
  mapping (uint =&gt; mapping (address =&gt; bool)) public confirmations;&#13;
  mapping (address =&gt; bool) public is_owner;&#13;
  address[] public owners;&#13;
  uint public required;&#13;
  uint public transaction_count;&#13;
  ERC20 public erc20_contract;  //address of the ERC20 tokens contract&#13;
  mapping (uint =&gt; Period) public periods;&#13;
  uint public period_count;&#13;
  uint public current_period;&#13;
  uint public current_transferred;  //amount of transferred tokens in the current period&#13;
&#13;
  /*&#13;
  *  Modifiers&#13;
  */&#13;
  modifier ownerExists(address owner) &#13;
  {&#13;
    require(is_owner[owner]);&#13;
    _;&#13;
  }&#13;
&#13;
  modifier transactionExists(uint transaction_id) &#13;
  {&#13;
    require(transactions[transaction_id].to != 0);&#13;
    _;&#13;
  }&#13;
&#13;
  modifier confirmed(uint transaction_id, address owner)&#13;
  {&#13;
    require(confirmations[transaction_id][owner]);&#13;
    _;&#13;
  }&#13;
&#13;
  modifier notConfirmed(uint transaction_id, address owner)&#13;
  {&#13;
    require(!confirmations[transaction_id][owner]);&#13;
    _;&#13;
  }&#13;
&#13;
  modifier notExecuted(uint transaction_id)&#13;
  {&#13;
    require(!transactions[transaction_id].executed);&#13;
    _;&#13;
  }&#13;
&#13;
  modifier ownerOrWallet(address owner)&#13;
  {&#13;
    require (msg.sender == address(this) || is_owner[owner]);&#13;
    _;&#13;
  }&#13;
&#13;
  modifier notNull(address _address)&#13;
  {&#13;
    require(_address != 0);&#13;
    _;&#13;
  }&#13;
&#13;
  /// @dev Fallback function: don't accept ETH&#13;
  function()&#13;
    public&#13;
    payable&#13;
  {&#13;
    revert();&#13;
  }&#13;
&#13;
  /*&#13;
  * Public functions&#13;
  */&#13;
  /// @dev Contract constructor sets initial owners, required number of confirmations, initial periods' parameters and token address.&#13;
  /// @param _owners List of initial owners.&#13;
  /// @param _required Number of required confirmations.&#13;
  /// @param _timestamps Timestamps of initial periods.&#13;
  /// @param _limits Limits of initial periods. The length of _limits must be the same as _timestamps.&#13;
  /// @param _erc20_contract Address of the ERC20 tokens contract.&#13;
  function MultiSigWalletTokenLimit(address[] _owners, uint _required, uint[] _timestamps, uint[] _limits, ERC20 _erc20_contract)&#13;
    public&#13;
  {&#13;
    for (uint i = 0; i &lt; _owners.length; i++)&#13;
    {&#13;
      require(!is_owner[_owners[i]] &amp;&amp; _owners[i] != 0);&#13;
      is_owner[_owners[i]] = true;&#13;
    }&#13;
    owners = _owners;&#13;
    required = _required;&#13;
&#13;
    periods[0].timestamp = 2**256 - 1;&#13;
    periods[0].limit = 2**256 - 1;&#13;
    uint total_limit = 0;&#13;
    for (i = 0; i &lt; _timestamps.length; i++)&#13;
    {&#13;
      periods[i + 1].timestamp = _timestamps[i];&#13;
      periods[i + 1].current_limit = _limits[i];&#13;
      total_limit = total_limit.add(_limits[i]);&#13;
      periods[i + 1].limit = total_limit;&#13;
    }&#13;
    period_count = 1 + _timestamps.length;&#13;
    current_period = 0;&#13;
    if (_timestamps.length &gt; 0)&#13;
      current_period = 1;&#13;
    current_transferred = 0;&#13;
&#13;
    erc20_contract = _erc20_contract;&#13;
  }&#13;
&#13;
  /// @dev Allows an owner to submit and confirm a send tokens transaction.&#13;
  /// @param to Address to transfer tokens.&#13;
  /// @param value Amout of tokens to transfer.&#13;
  /// @return Returns transaction ID.&#13;
  function submitTransaction(address to, uint value)&#13;
    public&#13;
    notNull(to)&#13;
    returns (uint transaction_id)&#13;
  {&#13;
    transaction_id = addTransaction(to, value);&#13;
    confirmTransaction(transaction_id);&#13;
  }&#13;
&#13;
  /// @dev Allows an owner to confirm a transaction.&#13;
  /// @param transaction_id Transaction ID.&#13;
  function confirmTransaction(uint transaction_id)&#13;
    public&#13;
    ownerExists(msg.sender)&#13;
    transactionExists(transaction_id)&#13;
    notConfirmed(transaction_id, msg.sender)&#13;
  {&#13;
    confirmations[transaction_id][msg.sender] = true;&#13;
    emit Confirmation(msg.sender, transaction_id);&#13;
    executeTransaction(transaction_id);&#13;
  }&#13;
&#13;
  /// @dev Allows an owner to revoke a confirmation for a transaction.&#13;
  /// @param transaction_id Transaction ID.&#13;
  function revokeConfirmation(uint transaction_id)&#13;
    public&#13;
    ownerExists(msg.sender)&#13;
    confirmed(transaction_id, msg.sender)&#13;
    notExecuted(transaction_id)&#13;
  {&#13;
    confirmations[transaction_id][msg.sender] = false;&#13;
    emit Revocation(msg.sender, transaction_id);&#13;
  }&#13;
&#13;
  function executeTransaction(uint transaction_id)&#13;
    public&#13;
    ownerExists(msg.sender)&#13;
    confirmed(transaction_id, msg.sender)&#13;
    notExecuted(transaction_id)&#13;
  {&#13;
    if (isConfirmed(transaction_id))&#13;
    {&#13;
      Transaction storage txn = transactions[transaction_id];&#13;
      txn.executed = true;&#13;
      if (transfer(txn.to, txn.value))&#13;
        emit Execution(transaction_id);&#13;
      else&#13;
      {&#13;
        emit ExecutionFailure(transaction_id);&#13;
        txn.executed = false;&#13;
      }&#13;
    }&#13;
  }&#13;
&#13;
  /// @dev Returns the confirmation status of a transaction.&#13;
  /// @param transaction_id Transaction ID.&#13;
  /// @return Confirmation status.&#13;
  function isConfirmed(uint transaction_id)&#13;
    public&#13;
    view&#13;
    returns (bool)&#13;
  {&#13;
    uint count = 0;&#13;
    for (uint i = 0; i &lt; owners.length; i++)&#13;
    {&#13;
      if (confirmations[transaction_id][owners[i]])&#13;
        ++count;&#13;
    if (count &gt;= required)&#13;
      return true;&#13;
    }&#13;
  }&#13;
&#13;
  /*&#13;
   * Internal functions&#13;
   */&#13;
  /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.&#13;
  /// @param to Address to transfer tokens.&#13;
  /// @param value Amout of tokens to transfer.&#13;
  /// @return Returns transaction ID.&#13;
  function addTransaction(address to, uint value)&#13;
    internal&#13;
    returns (uint transaction_id)&#13;
  {&#13;
    transaction_id = transaction_count;&#13;
    transactions[transaction_id] = Transaction({&#13;
      to: to,&#13;
      value: value,&#13;
      executed: false&#13;
    });&#13;
    ++transaction_count;&#13;
    emit Submission(transaction_id);&#13;
  }&#13;
&#13;
  /*&#13;
   * Web3 call functions&#13;
   */&#13;
  /// @dev Returns number of confirmations of a transaction.&#13;
  /// @param transaction_id Transaction ID.&#13;
  /// @return Number of confirmations.&#13;
  function getConfirmationCount(uint transaction_id)&#13;
    public&#13;
    view&#13;
    returns (uint count)&#13;
  {&#13;
    for (uint i = 0; i &lt; owners.length; i++)&#13;
      if (confirmations[transaction_id][owners[i]])&#13;
        ++count;&#13;
  }&#13;
&#13;
  /// @dev Returns total number of transactions after filers are applied.&#13;
  /// @param pending Include pending transactions.&#13;
  /// @param executed Include executed transactions.&#13;
  /// @return Total number of transactions after filters are applied.&#13;
  function getTransactionCount(bool pending, bool executed)&#13;
    public&#13;
    view&#13;
    returns (uint count)&#13;
  {&#13;
    for (uint i = 0; i &lt; transaction_count; i++)&#13;
      if (pending &amp;&amp; !transactions[i].executed&#13;
        || executed &amp;&amp; transactions[i].executed)&#13;
        ++count;&#13;
  }&#13;
&#13;
  /// @dev Returns list of owners.&#13;
  /// @return List of owner addresses.&#13;
  function getOwners()&#13;
    public&#13;
    view&#13;
    returns (address[])&#13;
  {&#13;
    return owners;&#13;
  }&#13;
&#13;
  /// @dev Returns array with owner addresses, which confirmed transaction.&#13;
  /// @param transaction_id Transaction ID.&#13;
  /// @return Returns array of owner addresses.&#13;
  function getConfirmations(uint transaction_id)&#13;
    public&#13;
    view&#13;
    returns (address[] _confirmations)&#13;
  {&#13;
    address[] memory confirmations_temp = new address[](owners.length);&#13;
    uint count = 0;&#13;
    uint i;&#13;
    for (i = 0; i &lt; owners.length; i++)&#13;
      if (confirmations[transaction_id][owners[i]])&#13;
      {&#13;
        confirmations_temp[count] = owners[i];&#13;
        ++count;&#13;
      }&#13;
      _confirmations = new address[](count);&#13;
      for (i = 0; i &lt; count; i++)&#13;
        _confirmations[i] = confirmations_temp[i];&#13;
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
    view&#13;
    returns (uint[] _transaction_ids)&#13;
  {&#13;
    uint[] memory transaction_ids_temp = new uint[](transaction_count);&#13;
    uint count = 0;&#13;
    uint i;&#13;
    for (i = 0; i &lt; transaction_count; i++)&#13;
      if (pending &amp;&amp; !transactions[i].executed&#13;
        || executed &amp;&amp; transactions[i].executed)&#13;
      {&#13;
        transaction_ids_temp[count] = i;&#13;
        ++count;&#13;
      }&#13;
      _transaction_ids = new uint[](to - from);&#13;
      for (i = from; i &lt; to; i++)&#13;
        _transaction_ids[i - from] = transaction_ids_temp[i];&#13;
  }&#13;
&#13;
  /// @dev Fallback function which is called by tokens contract after transferring tokens to this wallet.&#13;
  /// @param from Source address of the transfer.&#13;
  /// @param value Amount of received ERC20 tokens.&#13;
  function tokenFallback(address from, uint value, bytes)&#13;
    public&#13;
  {&#13;
    require(msg.sender == address(erc20_contract));&#13;
    emit TokensReceived(from, value);&#13;
  }&#13;
&#13;
  /// @dev Returns balance of the wallet&#13;
  function getWalletBalance()&#13;
    public&#13;
    view&#13;
    returns(uint)&#13;
  { &#13;
    return erc20_contract.balanceOf(this);&#13;
  }&#13;
&#13;
  /// @dev Updates current perriod: looking for a period with a minimmum date(timestamp) that is greater than now.&#13;
  function updateCurrentPeriod()&#13;
    public&#13;
    ownerOrWallet(msg.sender)&#13;
  {&#13;
    uint new_period = 0;&#13;
    for (uint i = 1; i &lt; period_count; i++)&#13;
      if (periods[i].timestamp &gt; now &amp;&amp; periods[i].timestamp &lt; periods[new_period].timestamp)&#13;
        new_period = i;&#13;
    if (new_period != current_period)&#13;
    {&#13;
      current_period = new_period;&#13;
      emit CurrentPeriodChanged(current_period, current_transferred, periods[current_period].limit);&#13;
    }&#13;
  }&#13;
&#13;
  /// @dev Transfers ERC20 tokens from the wallet to a given address&#13;
  /// @param to Address to transfer.&#13;
  /// @param value Amount of tokens to transfer.&#13;
  function transfer(address to, uint value) &#13;
    internal&#13;
    returns (bool)&#13;
  {&#13;
    updateCurrentPeriod();&#13;
    require(value &lt;= getWalletBalance() &amp;&amp; current_transferred.add(value) &lt;= periods[current_period].limit);&#13;
&#13;
    if (erc20_contract.transfer(to, value)) &#13;
    {&#13;
      current_transferred = current_transferred.add(value);&#13;
      emit Transfer(to, value);&#13;
      return true;&#13;
    }&#13;
&#13;
    return false;&#13;
  }&#13;
&#13;
}
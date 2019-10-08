pragma solidity ^0.4.19;

/**
 * @title IDXM Contract. IDEX Membership Token contract.
 *
 * @author Ray Pulver, <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ff8d9e86bf9e8a8d908d9e9b9e90d19c9092">[email protected]</a>&#13;
 */&#13;
&#13;
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }&#13;
&#13;
contract SafeMath {&#13;
  function safeMul(uint256 a, uint256 b) returns (uint256) {&#13;
    uint256 c = a * b;&#13;
    require(a == 0 || c / a == b);&#13;
    return c;&#13;
  }&#13;
  function safeSub(uint256 a, uint256 b) returns (uint256) {&#13;
    require(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
  function safeAdd(uint256 a, uint256 b) returns (uint256) {&#13;
    uint c = a + b;&#13;
    require(c &gt;= a &amp;&amp; c &gt;= b);&#13;
    return c;&#13;
  }&#13;
}&#13;
&#13;
contract Owned {&#13;
  address public owner;&#13;
  function Owned() {&#13;
    owner = msg.sender;&#13;
  }&#13;
  function setOwner(address _owner) returns (bool success) {&#13;
    owner = _owner;&#13;
    return true;&#13;
  }&#13;
  modifier onlyOwner {&#13;
    require(msg.sender == owner);&#13;
    _;&#13;
  }&#13;
}&#13;
&#13;
contract IDXM is Owned, SafeMath {&#13;
  uint8 public decimals = 8;&#13;
  bytes32 public standard = 'Token 0.1';&#13;
  bytes32 public name = 'IDEX Membership';&#13;
  bytes32 public symbol = 'IDXM';&#13;
  uint256 public totalSupply;&#13;
&#13;
  event Approval(address indexed from, address indexed spender, uint256 amount);&#13;
&#13;
  mapping (address =&gt; uint256) public balanceOf;&#13;
  mapping (address =&gt; mapping (address =&gt; uint256)) public allowance;&#13;
&#13;
  event Transfer(address indexed from, address indexed to, uint256 value);&#13;
&#13;
  uint256 public baseFeeDivisor;&#13;
  uint256 public feeDivisor;&#13;
  uint256 public singleIDXMQty;&#13;
&#13;
  function () external {&#13;
    throw;&#13;
  }&#13;
&#13;
  uint8 public feeDecimals = 8;&#13;
&#13;
  struct Validity {&#13;
    uint256 last;&#13;
    uint256 ts;&#13;
  }&#13;
&#13;
  mapping (address =&gt; Validity) public validAfter;&#13;
  uint256 public mustHoldFor = 604800;&#13;
  mapping (address =&gt; uint256) public exportFee;&#13;
&#13;
  /**&#13;
   * Constructor.&#13;
   *&#13;
   */&#13;
  function IDXM() {&#13;
    totalSupply = 200000000000;&#13;
    balanceOf[msg.sender] = totalSupply;&#13;
    exportFee[0x00000000000000000000000000000000000000ff] = 100000000;&#13;
    precalculate();&#13;
  }&#13;
&#13;
  bool public balancesLocked = false;&#13;
&#13;
  function uploadBalances(address[] addresses, uint256[] balances) onlyOwner {&#13;
    require(!balancesLocked);&#13;
    require(addresses.length == balances.length);&#13;
    uint256 sum;&#13;
    for (uint256 i = 0; i &lt; uint256(addresses.length); i++) {&#13;
      sum = safeAdd(sum, safeSub(balances[i], balanceOf[addresses[i]]));&#13;
      balanceOf[addresses[i]] = balances[i];&#13;
    }&#13;
    balanceOf[owner] = safeSub(balanceOf[owner], sum);&#13;
  }&#13;
&#13;
  function lockBalances() onlyOwner {&#13;
    balancesLocked = true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @notice Transfer `_amount` from `msg.sender.address()` to `_to`.&#13;
   *&#13;
   * @param _to Address that will receive.&#13;
   * @param _amount Amount to be transferred.&#13;
   */&#13;
  function transfer(address _to, uint256 _amount) returns (bool success) {&#13;
    require(balanceOf[msg.sender] &gt;= _amount);&#13;
    require(balanceOf[_to] + _amount &gt;= balanceOf[_to]);&#13;
    balanceOf[msg.sender] -= _amount;&#13;
    uint256 preBalance = balanceOf[_to];&#13;
    balanceOf[_to] += _amount;&#13;
    bool alreadyMax = preBalance &gt;= singleIDXMQty;&#13;
    if (!alreadyMax) {&#13;
      if (now &gt;= validAfter[_to].ts + mustHoldFor) validAfter[_to].last = preBalance;&#13;
      validAfter[_to].ts = now;&#13;
    }&#13;
    if (validAfter[msg.sender].last &gt; balanceOf[msg.sender]) validAfter[msg.sender].last = balanceOf[msg.sender];&#13;
    Transfer(msg.sender, _to, _amount);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @notice Transfer `_amount` from `_from` to `_to`.&#13;
   *&#13;
   * @param _from Origin address&#13;
   * @param _to Address that will receive&#13;
   * @param _amount Amount to be transferred.&#13;
   * @return result of the method call&#13;
   */&#13;
  function transferFrom(address _from, address _to, uint256 _amount) returns (bool success) {&#13;
    require(balanceOf[_from] &gt;= _amount);&#13;
    require(balanceOf[_to] + _amount &gt;= balanceOf[_to]);&#13;
    require(_amount &lt;= allowance[_from][msg.sender]);&#13;
    balanceOf[_from] -= _amount;&#13;
    uint256 preBalance = balanceOf[_to];&#13;
    balanceOf[_to] += _amount;&#13;
    allowance[_from][msg.sender] -= _amount;&#13;
    bool alreadyMax = preBalance &gt;= singleIDXMQty;&#13;
    if (!alreadyMax) {&#13;
      if (now &gt;= validAfter[_to].ts + mustHoldFor) validAfter[_to].last = preBalance;&#13;
      validAfter[_to].ts = now;&#13;
    }&#13;
    if (validAfter[_from].last &gt; balanceOf[_from]) validAfter[_from].last = balanceOf[_from];&#13;
    Transfer(_from, _to, _amount);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @notice Approve spender `_spender` to transfer `_amount` from `msg.sender.address()`&#13;
   *&#13;
   * @param _spender Address that receives the cheque&#13;
   * @param _amount Amount on the cheque&#13;
   * @param _extraData Consequential contract to be executed by spender in same transcation.&#13;
   * @return result of the method call&#13;
   */&#13;
  function approveAndCall(address _spender, uint256 _amount, bytes _extraData) returns (bool success) {&#13;
    tokenRecipient spender = tokenRecipient(_spender);&#13;
    if (approve(_spender, _amount)) {&#13;
      spender.receiveApproval(msg.sender, _amount, this, _extraData);&#13;
      return true;&#13;
    }&#13;
  }&#13;
&#13;
  /**&#13;
   * @notice Approve spender `_spender` to transfer `_amount` from `msg.sender.address()`&#13;
   *&#13;
   * @param _spender Address that receives the cheque&#13;
   * @param _amount Amount on the cheque&#13;
   * @return result of the method call&#13;
   */&#13;
  function approve(address _spender, uint256 _amount) returns (bool success) {&#13;
    allowance[msg.sender][_spender] = _amount;&#13;
    Approval(msg.sender, _spender, _amount);&#13;
    return true;&#13;
  }&#13;
&#13;
  function setExportFee(address addr, uint256 fee) onlyOwner {&#13;
    require(addr != 0x00000000000000000000000000000000000000ff);&#13;
    exportFee[addr] = fee;&#13;
  }&#13;
&#13;
  function setHoldingPeriod(uint256 ts) onlyOwner {&#13;
    mustHoldFor = ts;&#13;
  }&#13;
&#13;
&#13;
  /* --------------- fee calculation method ---------------- */&#13;
&#13;
  /**&#13;
   * @notice 'Returns the fee for a transfer from `from` to `to` on an amount `amount`.&#13;
   *&#13;
   * Fee's consist of a possible&#13;
   *    - import fee on transfers to an address&#13;
   *    - export fee on transfers from an address&#13;
   * IDXM ownership on an address&#13;
   *    - reduces fee on a transfer from this address to an import fee-ed address&#13;
   *    - reduces the fee on a transfer to this address from an export fee-ed address&#13;
   * IDXM discount does not work for addresses that have an import fee or export fee set up against them.&#13;
   *&#13;
   * IDXM discount goes up to 100%&#13;
   *&#13;
   * @param from From address&#13;
   * @param to To address&#13;
   * @param amount Amount for which fee needs to be calculated.&#13;
   *&#13;
   */&#13;
  function feeFor(address from, address to, uint256 amount) constant external returns (uint256 value) {&#13;
    uint256 fee = exportFee[from];&#13;
    if (fee == 0) return 0;&#13;
    uint256 amountHeld;&#13;
    if (balanceOf[to] != 0) {&#13;
      if (validAfter[to].ts + mustHoldFor &lt; now) amountHeld = balanceOf[to];&#13;
      else amountHeld = validAfter[to].last;&#13;
      if (amountHeld &gt;= singleIDXMQty) return 0;&#13;
      return amount*fee*(singleIDXMQty - amountHeld) / feeDivisor;&#13;
    } else return amount*fee / baseFeeDivisor;&#13;
  }&#13;
  function precalculate() internal returns (bool success) {&#13;
    baseFeeDivisor = pow10(1, feeDecimals);&#13;
    feeDivisor = pow10(1, feeDecimals + decimals);&#13;
    singleIDXMQty = pow10(1, decimals);&#13;
  }&#13;
  function div10(uint256 a, uint8 b) internal returns (uint256 result) {&#13;
    for (uint8 i = 0; i &lt; b; i++) {&#13;
      a /= 10;&#13;
    }&#13;
    return a;&#13;
  }&#13;
  function pow10(uint256 a, uint8 b) internal returns (uint256 result) {&#13;
    for (uint8 i = 0; i &lt; b; i++) {&#13;
      a *= 10;&#13;
    }&#13;
    return a;&#13;
  }&#13;
}
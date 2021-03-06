pragma solidity ^0.4.24;

/// @title Proxied - indicates that a contract will be proxied. Also defines storage requirements for Proxy.
/// @author Alan Lu - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="4e2f222f200e2920213d273d603e23">[email protected]</a>&gt;&#13;
contract Proxied {&#13;
    address public masterCopy;&#13;
}&#13;
&#13;
/// @title Proxy - Generic proxy contract allows to execute all transactions applying the code of a master contract.&#13;
/// @author Stefan George - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7704031211161937101918041e0459071a">[email protected]</a>&gt;&#13;
contract Proxy is Proxied {&#13;
    /// @dev Constructor function sets address of master copy contract.&#13;
    /// @param _masterCopy Master copy address.&#13;
    constructor(address _masterCopy)&#13;
        public&#13;
    {&#13;
        require(_masterCopy != 0);&#13;
        masterCopy = _masterCopy;&#13;
    }&#13;
&#13;
    /// @dev Fallback function forwards all transactions and returns all received return data.&#13;
    function ()&#13;
        external&#13;
        payable&#13;
    {&#13;
        address _masterCopy = masterCopy;&#13;
        assembly {&#13;
            calldatacopy(0, 0, calldatasize())&#13;
            let success := delegatecall(not(0), _masterCopy, 0, calldatasize(), 0, 0)&#13;
            returndatacopy(0, 0, returndatasize())&#13;
            switch success&#13;
            case 0 { revert(0, returndatasize()) }&#13;
            default { return(0, returndatasize()) }&#13;
        }&#13;
    }&#13;
}&#13;
/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md&#13;
&#13;
&#13;
&#13;
/// @title Abstract token contract - Functions to be implemented by token contracts&#13;
contract Token {&#13;
&#13;
    /*&#13;
     *  Events&#13;
     */&#13;
    event Transfer(address indexed from, address indexed to, uint value);&#13;
    event Approval(address indexed owner, address indexed spender, uint value);&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    function transfer(address to, uint value) public returns (bool);&#13;
    function transferFrom(address from, address to, uint value) public returns (bool);&#13;
    function approve(address spender, uint value) public returns (bool);&#13;
    function balanceOf(address owner) public view returns (uint);&#13;
    function allowance(address owner, address spender) public view returns (uint);&#13;
    function totalSupply() public view returns (uint);&#13;
}&#13;
&#13;
&#13;
&#13;
/// @title Abstract oracle contract - Functions to be implemented by oracles&#13;
contract Oracle {&#13;
&#13;
    function isOutcomeSet() public view returns (bool);&#13;
    function getOutcome() public view returns (int);&#13;
}&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
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
    // uint256 c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
    return a / b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).&#13;
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
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
contract CentralizedBugOracleData {&#13;
  event OwnerReplacement(address indexed newOwner);&#13;
  event OutcomeAssignment(int outcome);&#13;
&#13;
  /*&#13;
   *  Storage&#13;
   */&#13;
  address public owner;&#13;
  bytes public ipfsHash;&#13;
  bool public isSet;&#13;
  int public outcome;&#13;
  address public maker;&#13;
  address public taker;&#13;
&#13;
  /*&#13;
   *  Modifiers&#13;
   */&#13;
  modifier isOwner () {&#13;
      // Only owner is allowed to proceed&#13;
      require(msg.sender == owner);&#13;
      _;&#13;
  }&#13;
}&#13;
&#13;
contract CentralizedBugOracleProxy is Proxy, CentralizedBugOracleData {&#13;
&#13;
    /// @dev Constructor sets owner address and IPFS hash&#13;
    /// @param _ipfsHash Hash identifying off chain event description&#13;
    constructor(address proxied, address _owner, bytes _ipfsHash, address _maker, address _taker)&#13;
        public&#13;
        Proxy(proxied)&#13;
    {&#13;
        // Description hash cannot be null&#13;
        require(_ipfsHash.length == 46);&#13;
        owner = _owner;&#13;
        ipfsHash = _ipfsHash;&#13;
        maker = _maker;&#13;
        taker = _taker;&#13;
    }&#13;
}&#13;
&#13;
contract CentralizedBugOracle is Proxied,Oracle, CentralizedBugOracleData{&#13;
&#13;
  /// @dev Sets event outcome&#13;
  /// @param _outcome Event outcome&#13;
  function setOutcome(int _outcome)&#13;
      public&#13;
      isOwner&#13;
  {&#13;
      // Result is not set yet&#13;
      require(!isSet);&#13;
      _setOutcome(_outcome);&#13;
  }&#13;
&#13;
  /// @dev Returns if winning outcome is set&#13;
  /// @return Is outcome set?&#13;
  function isOutcomeSet()&#13;
      public&#13;
      view&#13;
      returns (bool)&#13;
  {&#13;
      return isSet;&#13;
  }&#13;
&#13;
  /// @dev Returns outcome&#13;
  /// @return Outcome&#13;
  function getOutcome()&#13;
      public&#13;
      view&#13;
      returns (int)&#13;
  {&#13;
      return outcome;&#13;
  }&#13;
&#13;
&#13;
  //@dev internal funcion to set the outcome sat&#13;
  function _setOutcome(int _outcome) internal {&#13;
    isSet = true;&#13;
    outcome = _outcome;&#13;
    emit OutcomeAssignment(_outcome);&#13;
  }&#13;
&#13;
&#13;
}&#13;
&#13;
&#13;
//Vending machine Logic goes in this contract&#13;
contract OracleVendingMachine {&#13;
  using SafeMath for *;&#13;
&#13;
  /*&#13;
   *  events&#13;
   */&#13;
&#13;
  event OracleProposed(address maker, address taker, uint256 index, bytes hash);&#13;
  event OracleAccepted(address maker, address taker, uint256 index, bytes hash);&#13;
  event OracleDeployed(address maker, address taker, uint256 index, bytes hash, address oracle);&#13;
  event OracleRevoked(address maker, address taker, uint256 index, bytes hash);&#13;
&#13;
  event FeeUpdated(uint256 newFee);&#13;
  event OracleUpgraded(address newAddress);&#13;
  event PaymentTokenChanged(address newToken);&#13;
  event StatusChanged(bool newStatus);&#13;
  event OracleBoughtFor(address buyer, address maker, address taker, uint256 index, bytes ipfsHash, address oracle);&#13;
&#13;
  /*&#13;
   *  Storage&#13;
   */&#13;
  address public owner;&#13;
  uint public fee;&#13;
  Oracle public oracleMasterCopy;&#13;
  Token public paymentToken;&#13;
  bool public open;&#13;
&#13;
&#13;
  mapping (address =&gt; uint256) public balances;&#13;
  mapping (address =&gt; bool) public balanceChecked;&#13;
  mapping (address =&gt; mapping (address =&gt; uint256)) public oracleIndexes;&#13;
  mapping (address =&gt; mapping (address =&gt; mapping (uint256 =&gt; proposal))) public oracleProposed;&#13;
  mapping (address =&gt; mapping (address =&gt; mapping (uint256 =&gt; address))) public oracleDeployed;&#13;
&#13;
  struct proposal {&#13;
    bytes hash;&#13;
    address oracleMasterCopy;&#13;
    uint256 fee;&#13;
  }&#13;
&#13;
  /*&#13;
   *  Modifiers&#13;
   */&#13;
  modifier isOwner () {&#13;
      // Only owner is allowed to proceed&#13;
      require(msg.sender == owner);&#13;
      _;&#13;
  }&#13;
&#13;
  modifier whenOpen() {&#13;
    //Only proceeds with operation if open is true&#13;
    require(open);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
    @dev Contructor to the vending Machine&#13;
    @param _fee The for using the vending Machine&#13;
    @param _token the Address of the token used for paymentToken&#13;
    @param _oracleMasterCopy The deployed version of the oracle which will be proxied to&#13;
  **/&#13;
  constructor(uint _fee, address _token, address _oracleMasterCopy) public {&#13;
    owner = msg.sender;&#13;
    fee = _fee;&#13;
    paymentToken = Token(_token);&#13;
    oracleMasterCopy = Oracle(_oracleMasterCopy);&#13;
    open = true;&#13;
  }&#13;
&#13;
  /**&#13;
    @dev Change the fee&#13;
    @param _fee Te new vending machine fee&#13;
  **/&#13;
  function changeFee(uint _fee) public isOwner {&#13;
      fee = _fee;&#13;
      emit FeeUpdated(_fee);&#13;
  }&#13;
&#13;
  /**&#13;
    @dev Change the master copy of the oracle&#13;
    @param _oracleMasterCopy The address of the deployed version of the oracle which will be proxied to&#13;
  **/&#13;
  function upgradeOracle(address _oracleMasterCopy) public isOwner {&#13;
    require(_oracleMasterCopy != 0x0);&#13;
    oracleMasterCopy = Oracle(_oracleMasterCopy);&#13;
    emit OracleUpgraded(_oracleMasterCopy);&#13;
  }&#13;
&#13;
  /**&#13;
    @dev Change the payment token&#13;
    @param _paymentToken the Address of the token used for paymentToken&#13;
  **/&#13;
  function changePaymentToken(address _paymentToken) public isOwner {&#13;
    require(_paymentToken != 0x0);&#13;
    paymentToken = Token(_paymentToken);&#13;
    emit PaymentTokenChanged(_paymentToken);&#13;
  }&#13;
&#13;
  /**&#13;
    @dev Contructor to the vending Machine&#13;
    @param status The new open status for the vending Machine&#13;
  **/&#13;
  function modifyOpenStatus(bool status) public isOwner {&#13;
    open = status;&#13;
    emit StatusChanged(status);&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
    @dev Internal function to deploy and register a oracle&#13;
    @param _proposal A proposal struct containing the bug information&#13;
    @param maker the Address who proposed the oracle&#13;
    @param taker the Address who accepted the oracle&#13;
    @param index The index of the oracle to be deployed&#13;
    @return A deployed oracle contract&#13;
  **/&#13;
  function deployOracle(proposal _proposal, address maker, address taker, uint256 index) internal returns(Oracle oracle){&#13;
    require(oracleDeployed[maker][taker][index] == address(0));&#13;
    oracle = CentralizedBugOracle(new CentralizedBugOracleProxy(_proposal.oracleMasterCopy, owner, _proposal.hash, maker, taker));&#13;
    oracleDeployed[maker][taker][index] = oracle;&#13;
    emit OracleDeployed(maker, taker, index, _proposal.hash, oracle);&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
    @dev Function called by he taker to confirm a proposed oracle&#13;
    @param maker the Address who proposed the oracle&#13;
    @param index The index of the oracle to be deployed&#13;
    @return A deployed oracle contract&#13;
  **/&#13;
  function confirmOracle(address maker, uint index) public returns(Oracle oracle) {&#13;
    require(oracleProposed[maker][msg.sender][index].fee &gt; 0);&#13;
&#13;
    if(!balanceChecked[msg.sender]) checkBalance(msg.sender);&#13;
    balances[msg.sender] = balances[msg.sender].sub(fee);&#13;
&#13;
    oracle = deployOracle(oracleProposed[maker][msg.sender][index], maker, msg.sender, index);&#13;
    oracleIndexes[maker][msg.sender] += 1;&#13;
    emit OracleAccepted(maker, msg.sender, index, oracleProposed[maker][msg.sender][index].hash);&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
    @dev Function to propose an oracle, calle by maker&#13;
    @param _ipfsHash The hash for the bug information(description, spurce code, etc)&#13;
    @param taker the Address who needs to accept the oracle&#13;
    @return index of the proposal&#13;
  **/&#13;
  function buyOracle(bytes _ipfsHash, address taker) public whenOpen returns (uint index){&#13;
    if(!balanceChecked[msg.sender]) checkBalance(msg.sender);&#13;
    balances[msg.sender] = balances[msg.sender].sub(fee);&#13;
    index = oracleIndexes[msg.sender][taker];&#13;
    oracleProposed[msg.sender][taker][index] = proposal(_ipfsHash, oracleMasterCopy, fee);&#13;
    emit OracleProposed(msg.sender, taker, index, _ipfsHash);&#13;
  }&#13;
&#13;
  /**&#13;
    @dev Priviledged function to propose and deploy an oracle with one transaction. Called by Solidified Bug Bounty plataform&#13;
    @param _ipfsHash The hash for the bug information(description, spurce code, etc)&#13;
    @param maker the Address who proposed the oracle&#13;
    @param taker the Address who accepted the oracle&#13;
    @return A deployed oracle contract&#13;
  **/&#13;
  function buyOracleFor(bytes _ipfsHash, address maker, address taker) public whenOpen isOwner returns(Oracle oracle){&#13;
    if(!balanceChecked[maker]) checkBalance(maker);&#13;
    if(!balanceChecked[taker]) checkBalance(taker);&#13;
&#13;
    balances[maker] = balances[maker].sub(fee);&#13;
    balances[taker] = balances[taker].sub(fee);&#13;
&#13;
    uint256 index = oracleIndexes[maker][taker];&#13;
    proposal memory oracleProposal  = proposal(_ipfsHash, oracleMasterCopy, fee);&#13;
&#13;
    oracleProposed[maker][taker][index] = oracleProposal;&#13;
    oracle = deployOracle(oracleProposal,maker,taker,index);&#13;
    oracleDeployed[maker][taker][oracleIndexes[maker][taker]] = oracle;&#13;
    oracleIndexes[maker][taker] += 1;&#13;
    emit OracleBoughtFor(msg.sender, maker, taker, index, _ipfsHash, oracle);&#13;
  }&#13;
&#13;
  /**&#13;
    @dev  Function to cancel a proposed oracle, called by the maker&#13;
    @param taker the Address who accepted the oracle&#13;
    @param index The index of the proposed to be revoked&#13;
  **/&#13;
  function revokeOracle(address taker, uint256 index) public {&#13;
    require(oracleProposed[msg.sender][taker][index].fee &gt;  0);&#13;
    require(oracleDeployed[msg.sender][taker][index] == address(0));&#13;
    proposal memory oracleProposal = oracleProposed[msg.sender][taker][index];&#13;
    oracleProposed[msg.sender][taker][index].hash = "";&#13;
    oracleProposed[msg.sender][taker][index].fee = 0;&#13;
    oracleProposed[msg.sender][taker][index].oracleMasterCopy = address(0);&#13;
&#13;
    balances[msg.sender] = balances[msg.sender].add(oracleProposal.fee);&#13;
    emit OracleRevoked(msg.sender, taker, index, oracleProposal.hash);&#13;
  }&#13;
&#13;
  /**&#13;
    @dev Function to check a users balance of SOLID and deposit as credit&#13;
    @param holder Address of the holder to be checked&#13;
  **/&#13;
  function checkBalance(address holder) public {&#13;
    require(!balanceChecked[holder]);&#13;
    balances[holder] = paymentToken.balanceOf(holder);&#13;
    balanceChecked[holder] = true;&#13;
  }&#13;
&#13;
}
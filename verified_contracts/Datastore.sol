pragma solidity ^0.4.18;

// File: contracts/UidCheckerInterface.sol

interface UidCheckerInterface {

  function isUid(
    string _uid
  )
  public
  pure returns (bool);

}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: openzeppelin-solidity/contracts/ownership/HasNoEther.sol

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2a584f4749456a18">[email protected]</a>π.com&gt;&#13;
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up&#13;
 * in the contract, it will allow the owner to reclaim this ether.&#13;
 * @notice Ether can still be send to this contract by:&#13;
 * calling functions labeled `payable`&#13;
 * `selfdestruct(contract_address)`&#13;
 * mining directly to the contract address&#13;
*/&#13;
contract HasNoEther is Ownable {&#13;
&#13;
  /**&#13;
  * @dev Constructor that rejects incoming Ether&#13;
  * @dev The `payable` flag is added so we can access `msg.value` without compiler warning. If we&#13;
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable&#13;
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively&#13;
  * we could use assembly to access msg.value.&#13;
  */&#13;
  function HasNoEther() public payable {&#13;
    require(msg.value == 0);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Disallows direct send by settings a default function without the `payable` flag.&#13;
   */&#13;
  function() external {&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Transfer all Ether held by the contract to the owner.&#13;
   */&#13;
  function reclaimEther() external onlyOwner {&#13;
    assert(owner.send(this.balance));&#13;
  }&#13;
}&#13;
&#13;
// File: contracts/Datastore.sol&#13;
&#13;
/**&#13;
 * @title Store&#13;
 * @author Francesco Sullo &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="600612010e030513030f2013150c0c0f4e030f">[email protected]</a>&gt;&#13;
 * @dev It store the tweedentities related to the app&#13;
 */&#13;
&#13;
&#13;
&#13;
contract Datastore&#13;
is HasNoEther&#13;
{&#13;
&#13;
  string public fromVersion = "1.0.0";&#13;
&#13;
  uint public appId;&#13;
  string public appNickname;&#13;
&#13;
  uint public identities;&#13;
&#13;
  address public manager;&#13;
  address public newManager;&#13;
&#13;
  UidCheckerInterface public checker;&#13;
&#13;
  struct Uid {&#13;
    string lastUid;&#13;
    uint lastUpdate;&#13;
  }&#13;
&#13;
  struct Address {&#13;
    address lastAddress;&#13;
    uint lastUpdate;&#13;
  }&#13;
&#13;
  mapping(string =&gt; Address) internal __addressByUid;&#13;
  mapping(address =&gt; Uid) internal __uidByAddress;&#13;
&#13;
  bool public appSet;&#13;
&#13;
&#13;
&#13;
  // events&#13;
&#13;
&#13;
  event AppSet(&#13;
    string appNickname,&#13;
    uint appId,&#13;
    address checker&#13;
  );&#13;
&#13;
&#13;
  event ManagerSet(&#13;
    address indexed manager,&#13;
    bool isNew&#13;
  );&#13;
&#13;
  event ManagerSwitch(&#13;
    address indexed oldManager,&#13;
    address indexed newManager&#13;
  );&#13;
&#13;
&#13;
  event IdentitySet(&#13;
    address indexed addr,&#13;
    string uid&#13;
  );&#13;
&#13;
&#13;
  event IdentityUnset(&#13;
    address indexed addr,&#13;
    string uid&#13;
  );&#13;
&#13;
&#13;
&#13;
  // modifiers&#13;
&#13;
&#13;
  modifier onlyManager() {&#13;
    require(msg.sender == manager || (newManager != address(0) &amp;&amp; msg.sender == newManager));&#13;
    _;&#13;
  }&#13;
&#13;
&#13;
  modifier whenAppSet() {&#13;
    require(appSet);&#13;
    _;&#13;
  }&#13;
&#13;
&#13;
&#13;
  // config&#13;
&#13;
&#13;
  /**&#13;
  * @dev Updates the checker for the store&#13;
  * @param _address Checker's address&#13;
  */&#13;
  function setNewChecker(&#13;
    address _address&#13;
  )&#13;
  external&#13;
  onlyOwner&#13;
  {&#13;
    require(_address != address(0));&#13;
    checker = UidCheckerInterface(_address);&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
  * @dev Sets the manager&#13;
  * @param _address Manager's address&#13;
  */&#13;
  function setManager(&#13;
    address _address&#13;
  )&#13;
  external&#13;
  onlyOwner&#13;
  {&#13;
    require(_address != address(0));&#13;
    manager = _address;&#13;
    ManagerSet(_address, false);&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
  * @dev Sets new manager&#13;
  * @param _address New manager's address&#13;
  */&#13;
  function setNewManager(&#13;
    address _address&#13;
  )&#13;
  external&#13;
  onlyOwner&#13;
  {&#13;
    require(_address != address(0) &amp;&amp; manager != address(0));&#13;
    newManager = _address;&#13;
    ManagerSet(_address, true);&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
  * @dev Sets new manager&#13;
  */&#13;
  function switchManagerAndRemoveOldOne()&#13;
  external&#13;
  onlyOwner&#13;
  {&#13;
    require(newManager != address(0));&#13;
    ManagerSwitch(manager, newManager);&#13;
    manager = newManager;&#13;
    newManager = address(0);&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
  * @dev Sets the app&#13;
  * @param _appNickname Nickname (e.g. twitter)&#13;
  * @param _appId ID (e.g. 1)&#13;
  */&#13;
  function setApp(&#13;
    string _appNickname,&#13;
    uint _appId,&#13;
    address _checker&#13;
  )&#13;
  external&#13;
  onlyOwner&#13;
  {&#13;
    require(!appSet);&#13;
    require(_appId &gt; 0);&#13;
    require(_checker != address(0));&#13;
    require(bytes(_appNickname).length &gt; 0);&#13;
    appId = _appId;&#13;
    appNickname = _appNickname;&#13;
    checker = UidCheckerInterface(_checker);&#13;
    appSet = true;&#13;
    AppSet(_appNickname, _appId, _checker);&#13;
  }&#13;
&#13;
&#13;
&#13;
  // helpers&#13;
&#13;
&#13;
  /**&#13;
   * @dev Checks if a tweedentity is upgradable&#13;
   * @param _address The address&#13;
   * @param _uid The user-id&#13;
   */&#13;
  function isUpgradable(&#13;
    address _address,&#13;
    string _uid&#13;
  )&#13;
  public&#13;
  constant returns (bool)&#13;
  {&#13;
    if (__addressByUid[_uid].lastAddress != address(0)) {&#13;
      return keccak256(getUid(_address)) == keccak256(_uid);&#13;
    }&#13;
    return true;&#13;
  }&#13;
&#13;
&#13;
&#13;
  // primary methods&#13;
&#13;
&#13;
  /**&#13;
   * @dev Sets a tweedentity&#13;
   * @param _address The address of the wallet&#13;
   * @param _uid The user-id of the owner user account&#13;
   */&#13;
  function setIdentity(&#13;
    address _address,&#13;
    string _uid&#13;
  )&#13;
  external&#13;
  onlyManager&#13;
  whenAppSet&#13;
  {&#13;
    require(_address != address(0));&#13;
    require(isUid(_uid));&#13;
    require(isUpgradable(_address, _uid));&#13;
&#13;
    if (bytes(__uidByAddress[_address].lastUid).length &gt; 0) {&#13;
      // if _address is associated with an oldUid,&#13;
      // this removes the association between _address and oldUid&#13;
      __addressByUid[__uidByAddress[_address].lastUid] = Address(address(0), __addressByUid[__uidByAddress[_address].lastUid].lastUpdate);&#13;
      identities--;&#13;
    }&#13;
&#13;
    __uidByAddress[_address] = Uid(_uid, now);&#13;
    __addressByUid[_uid] = Address(_address, now);&#13;
    identities++;&#13;
    IdentitySet(_address, _uid);&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Unset a tweedentity&#13;
   * @param _address The address of the wallet&#13;
   */&#13;
  function unsetIdentity(&#13;
    address _address&#13;
  )&#13;
  external&#13;
  onlyManager&#13;
  whenAppSet&#13;
  {&#13;
    require(_address != address(0));&#13;
    require(bytes(__uidByAddress[_address].lastUid).length &gt; 0);&#13;
&#13;
    string memory uid = __uidByAddress[_address].lastUid;&#13;
    __uidByAddress[_address] = Uid('', __uidByAddress[_address].lastUpdate);&#13;
    __addressByUid[uid] = Address(address(0), __addressByUid[uid].lastUpdate);&#13;
    identities--;&#13;
    IdentityUnset(_address, uid);&#13;
  }&#13;
&#13;
&#13;
&#13;
  // getters&#13;
&#13;
&#13;
  /**&#13;
   * @dev Returns the keccak256 of the app nickname&#13;
   */&#13;
  function getAppNickname()&#13;
  external&#13;
  whenAppSet&#13;
  constant returns (bytes32) {&#13;
    return keccak256(appNickname);&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Returns the appId&#13;
   */&#13;
  function getAppId()&#13;
  external&#13;
  whenAppSet&#13;
  constant returns (uint) {&#13;
    return appId;&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Returns the user-id associated to a wallet&#13;
   * @param _address The address of the wallet&#13;
   */&#13;
  function getUid(&#13;
    address _address&#13;
  )&#13;
  public&#13;
  constant returns (string)&#13;
  {&#13;
    return __uidByAddress[_address].lastUid;&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Returns the address associated to a user-id&#13;
   * @param _uid The user-id&#13;
   */&#13;
  function getAddress(&#13;
    string _uid&#13;
  )&#13;
  external&#13;
  constant returns (address)&#13;
  {&#13;
    return __addressByUid[_uid].lastAddress;&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Returns the timestamp of last update by address&#13;
   * @param _address The address of the wallet&#13;
   */&#13;
  function getAddressLastUpdate(&#13;
    address _address&#13;
  )&#13;
  external&#13;
  constant returns (uint)&#13;
  {&#13;
    return __uidByAddress[_address].lastUpdate;&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
 * @dev Returns the timestamp of last update by user-id&#13;
 * @param _uid The user-id&#13;
 */&#13;
  function getUidLastUpdate(&#13;
    string _uid&#13;
  )&#13;
  external&#13;
  constant returns (uint)&#13;
  {&#13;
    return __addressByUid[_uid].lastUpdate;&#13;
  }&#13;
&#13;
&#13;
&#13;
  // utils&#13;
&#13;
&#13;
  function isUid(&#13;
    string _uid&#13;
  )&#13;
  public&#13;
  view&#13;
  returns (bool)&#13;
  {&#13;
    return checker.isUid(_uid);&#13;
  }&#13;
&#13;
}
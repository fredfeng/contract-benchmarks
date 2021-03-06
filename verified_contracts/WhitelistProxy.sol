/**
 * Copyright (c) 2018 blockimmo AG <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5f33363c3a312c3a1f3d33303c3436323230713c37">[email protected]</a>&#13;
 * Non-Profit Open Software License 3.0 (NPOSL-3.0)&#13;
 * https://opensource.org/licenses/NPOSL-3.0&#13;
 */&#13;
&#13;
&#13;
pragma solidity 0.4.25;&#13;
&#13;
&#13;
/**&#13;
 * @title Ownable&#13;
 * @dev The Ownable contract has an owner address, and provides basic authorization control&#13;
 * functions, this simplifies the implementation of "user permissions".&#13;
 */&#13;
contract Ownable {&#13;
  address public owner;&#13;
&#13;
&#13;
  event OwnershipRenounced(address indexed previousOwner);&#13;
  event OwnershipTransferred(&#13;
    address indexed previousOwner,&#13;
    address indexed newOwner&#13;
  );&#13;
&#13;
&#13;
  /**&#13;
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender&#13;
   * account.&#13;
   */&#13;
  constructor() public {&#13;
    owner = msg.sender;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Throws if called by any account other than the owner.&#13;
   */&#13;
  modifier onlyOwner() {&#13;
    require(msg.sender == owner);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows the current owner to relinquish control of the contract.&#13;
   * @notice Renouncing to ownership will leave the contract without an owner.&#13;
   * It will not be possible to call the functions with the `onlyOwner`&#13;
   * modifier anymore.&#13;
   */&#13;
  function renounceOwnership() public onlyOwner {&#13;
    emit OwnershipRenounced(owner);&#13;
    owner = address(0);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows the current owner to transfer control of the contract to a newOwner.&#13;
   * @param _newOwner The address to transfer ownership to.&#13;
   */&#13;
  function transferOwnership(address _newOwner) public onlyOwner {&#13;
    _transferOwnership(_newOwner);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Transfers control of the contract to a newOwner.&#13;
   * @param _newOwner The address to transfer ownership to.&#13;
   */&#13;
  function _transferOwnership(address _newOwner) internal {&#13;
    require(_newOwner != address(0));&#13;
    emit OwnershipTransferred(owner, _newOwner);&#13;
    owner = _newOwner;&#13;
  }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title Claimable&#13;
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.&#13;
 * This allows the new owner to accept the transfer.&#13;
 */&#13;
contract Claimable is Ownable {&#13;
  address public pendingOwner;&#13;
&#13;
  /**&#13;
   * @dev Modifier throws if called by any account other than the pendingOwner.&#13;
   */&#13;
  modifier onlyPendingOwner() {&#13;
    require(msg.sender == pendingOwner);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows the current owner to set the pendingOwner address.&#13;
   * @param newOwner The address to transfer ownership to.&#13;
   */&#13;
  function transferOwnership(address newOwner) public onlyOwner {&#13;
    pendingOwner = newOwner;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows the pendingOwner address to finalize the transfer.&#13;
   */&#13;
  function claimOwnership() public onlyPendingOwner {&#13;
    emit OwnershipTransferred(owner, pendingOwner);&#13;
    owner = pendingOwner;&#13;
    pendingOwner = address(0);&#13;
  }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title WhitelistProxy&#13;
 * @dev Points to `Whitelist`, enabling it to be upgraded if absolutely necessary.&#13;
 *&#13;
 * Contracts reference `this.whitelist` to locate `Whitelist`.&#13;
 * This contract is never intended to be upgraded.&#13;
 */&#13;
contract WhitelistProxy is Claimable {&#13;
  address public whitelist;&#13;
&#13;
  event Set(address whitelist);&#13;
&#13;
  function set(address _whitelist) public onlyOwner {&#13;
    whitelist = _whitelist;&#13;
    emit Set(whitelist);&#13;
  }&#13;
}
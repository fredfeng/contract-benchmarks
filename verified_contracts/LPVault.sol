//File: node_modules/giveth-common-contracts/contracts/Owned.sol
pragma solidity ^0.4.15;


/// @title Owned
/// @author Adrià Massanet <<span class="__cf_email__" data-cfemail="bddcd9cfd4dcfdded2d9d8ded2d3c9d8c5c993d4d2">[email protected]</span>&gt;&#13;
/// @notice The Owned contract has an owner address, and provides basic &#13;
///  authorization control functions, this simplifies &amp; the implementation of&#13;
///  user permissions; this contract has three work flows for a change in&#13;
///  ownership, the first requires the new owner to validate that they have the&#13;
///  ability to accept ownership, the second allows the ownership to be&#13;
///  directly transfered without requiring acceptance, and the third allows for&#13;
///  the ownership to be removed to allow for decentralization &#13;
contract Owned {&#13;
&#13;
    address public owner;&#13;
    address public newOwnerCandidate;&#13;
&#13;
    event OwnershipRequested(address indexed by, address indexed to);&#13;
    event OwnershipTransferred(address indexed from, address indexed to);&#13;
    event OwnershipRemoved();&#13;
&#13;
    /// @dev The constructor sets the `msg.sender` as the`owner` of the contract&#13;
    function Owned() public {&#13;
        owner = msg.sender;&#13;
    }&#13;
&#13;
    /// @dev `owner` is the only address that can call a function with this&#13;
    /// modifier&#13;
    modifier onlyOwner() {&#13;
        require (msg.sender == owner);&#13;
        _;&#13;
    }&#13;
    &#13;
    /// @dev In this 1st option for ownership transfer `proposeOwnership()` must&#13;
    ///  be called first by the current `owner` then `acceptOwnership()` must be&#13;
    ///  called by the `newOwnerCandidate`&#13;
    /// @notice `onlyOwner` Proposes to transfer control of the contract to a&#13;
    ///  new owner&#13;
    /// @param _newOwnerCandidate The address being proposed as the new owner&#13;
    function proposeOwnership(address _newOwnerCandidate) public onlyOwner {&#13;
        newOwnerCandidate = _newOwnerCandidate;&#13;
        OwnershipRequested(msg.sender, newOwnerCandidate);&#13;
    }&#13;
&#13;
    /// @notice Can only be called by the `newOwnerCandidate`, accepts the&#13;
    ///  transfer of ownership&#13;
    function acceptOwnership() public {&#13;
        require(msg.sender == newOwnerCandidate);&#13;
&#13;
        address oldOwner = owner;&#13;
        owner = newOwnerCandidate;&#13;
        newOwnerCandidate = 0x0;&#13;
&#13;
        OwnershipTransferred(oldOwner, owner);&#13;
    }&#13;
&#13;
    /// @dev In this 2nd option for ownership transfer `changeOwnership()` can&#13;
    ///  be called and it will immediately assign ownership to the `newOwner`&#13;
    /// @notice `owner` can step down and assign some other address to this role&#13;
    /// @param _newOwner The address of the new owner&#13;
    function changeOwnership(address _newOwner) public onlyOwner {&#13;
        require(_newOwner != 0x0);&#13;
&#13;
        address oldOwner = owner;&#13;
        owner = _newOwner;&#13;
        newOwnerCandidate = 0x0;&#13;
&#13;
        OwnershipTransferred(oldOwner, owner);&#13;
    }&#13;
&#13;
    /// @dev In this 3rd option for ownership transfer `removeOwnership()` can&#13;
    ///  be called and it will immediately assign ownership to the 0x0 address;&#13;
    ///  it requires a 0xdece be input as a parameter to prevent accidental use&#13;
    /// @notice Decentralizes the contract, this operation cannot be undone &#13;
    /// @param _dac `0xdac` has to be entered for this function to work&#13;
    function removeOwnership(address _dac) public onlyOwner {&#13;
        require(_dac == 0xdac);&#13;
        owner = 0x0;&#13;
        newOwnerCandidate = 0x0;&#13;
        OwnershipRemoved();     &#13;
    }&#13;
} &#13;
&#13;
//File: node_modules/giveth-common-contracts/contracts/ERC20.sol&#13;
pragma solidity ^0.4.15;&#13;
&#13;
&#13;
/**&#13;
 * @title ERC20&#13;
 * @dev A standard interface for tokens.&#13;
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md&#13;
 */&#13;
contract ERC20 {&#13;
  &#13;
    /// @dev Returns the total token supply&#13;
    function totalSupply() public constant returns (uint256 supply);&#13;
&#13;
    /// @dev Returns the account balance of the account with address _owner&#13;
    function balanceOf(address _owner) public constant returns (uint256 balance);&#13;
&#13;
    /// @dev Transfers _value number of tokens to address _to&#13;
    function transfer(address _to, uint256 _value) public returns (bool success);&#13;
&#13;
    /// @dev Transfers _value number of tokens from address _from to address _to&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);&#13;
&#13;
    /// @dev Allows _spender to withdraw from the msg.sender's account up to the _value amount&#13;
    function approve(address _spender, uint256 _value) public returns (bool success);&#13;
&#13;
    /// @dev Returns the amount which _spender is still allowed to withdraw from _owner&#13;
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);&#13;
&#13;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);&#13;
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);&#13;
&#13;
}&#13;
&#13;
//File: node_modules/giveth-common-contracts/contracts/Escapable.sol&#13;
pragma solidity ^0.4.15;&#13;
/*&#13;
    Copyright 2016, Jordi Baylina&#13;
    Contributor: Adrià Massanet &lt;<span class="__cf_email__" data-cfemail="31505543585071525e5554525e5f455449451f585e">[email protected]</span>&gt;&#13;
&#13;
    This program is free software: you can redistribute it and/or modify&#13;
    it under the terms of the GNU General Public License as published by&#13;
    the Free Software Foundation, either version 3 of the License, or&#13;
    (at your option) any later version.&#13;
&#13;
    This program is distributed in the hope that it will be useful,&#13;
    but WITHOUT ANY WARRANTY; without even the implied warranty of&#13;
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the&#13;
    GNU General Public License for more details.&#13;
&#13;
    You should have received a copy of the GNU General Public License&#13;
    along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.&#13;
*/&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
/// @dev `Escapable` is a base level contract built off of the `Owned`&#13;
///  contract; it creates an escape hatch function that can be called in an&#13;
///  emergency that will allow designated addresses to send any ether or tokens&#13;
///  held in the contract to an `escapeHatchDestination` as long as they were&#13;
///  not blacklisted&#13;
contract Escapable is Owned {&#13;
    address public escapeHatchCaller;&#13;
    address public escapeHatchDestination;&#13;
    mapping (address=&gt;bool) private escapeBlacklist; // Token contract addresses&#13;
&#13;
    /// @notice The Constructor assigns the `escapeHatchDestination` and the&#13;
    ///  `escapeHatchCaller`&#13;
    /// @param _escapeHatchCaller The address of a trusted account or contract&#13;
    ///  to call `escapeHatch()` to send the ether in this contract to the&#13;
    ///  `escapeHatchDestination` it would be ideal that `escapeHatchCaller`&#13;
    ///  cannot move funds out of `escapeHatchDestination`&#13;
    /// @param _escapeHatchDestination The address of a safe location (usu a&#13;
    ///  Multisig) to send the ether held in this contract; if a neutral address&#13;
    ///  is required, the WHG Multisig is an option:&#13;
    ///  0x8Ff920020c8AD673661c8117f2855C384758C572 &#13;
    function Escapable(address _escapeHatchCaller, address _escapeHatchDestination) public {&#13;
        escapeHatchCaller = _escapeHatchCaller;&#13;
        escapeHatchDestination = _escapeHatchDestination;&#13;
    }&#13;
&#13;
    /// @dev The addresses preassigned as `escapeHatchCaller` or `owner`&#13;
    ///  are the only addresses that can call a function with this modifier&#13;
    modifier onlyEscapeHatchCallerOrOwner {&#13;
        require ((msg.sender == escapeHatchCaller)||(msg.sender == owner));&#13;
        _;&#13;
    }&#13;
&#13;
    /// @notice Creates the blacklist of tokens that are not able to be taken&#13;
    ///  out of the contract; can only be done at the deployment, and the logic&#13;
    ///  to add to the blacklist will be in the constructor of a child contract&#13;
    /// @param _token the token contract address that is to be blacklisted &#13;
    function blacklistEscapeToken(address _token) internal {&#13;
        escapeBlacklist[_token] = true;&#13;
        EscapeHatchBlackistedToken(_token);&#13;
    }&#13;
&#13;
    /// @notice Checks to see if `_token` is in the blacklist of tokens&#13;
    /// @param _token the token address being queried&#13;
    /// @return False if `_token` is in the blacklist and can't be taken out of&#13;
    ///  the contract via the `escapeHatch()`&#13;
    function isTokenEscapable(address _token) constant public returns (bool) {&#13;
        return !escapeBlacklist[_token];&#13;
    }&#13;
&#13;
    /// @notice The `escapeHatch()` should only be called as a last resort if a&#13;
    /// security issue is uncovered or something unexpected happened&#13;
    /// @param _token to transfer, use 0x0 for ether&#13;
    function escapeHatch(address _token) public onlyEscapeHatchCallerOrOwner {   &#13;
        require(escapeBlacklist[_token]==false);&#13;
&#13;
        uint256 balance;&#13;
&#13;
        /// @dev Logic for ether&#13;
        if (_token == 0x0) {&#13;
            balance = this.balance;&#13;
            escapeHatchDestination.transfer(balance);&#13;
            EscapeHatchCalled(_token, balance);&#13;
            return;&#13;
        }&#13;
        /// @dev Logic for tokens&#13;
        ERC20 token = ERC20(_token);&#13;
        balance = token.balanceOf(this);&#13;
        require(token.transfer(escapeHatchDestination, balance));&#13;
        EscapeHatchCalled(_token, balance);&#13;
    }&#13;
&#13;
    /// @notice Changes the address assigned to call `escapeHatch()`&#13;
    /// @param _newEscapeHatchCaller The address of a trusted account or&#13;
    ///  contract to call `escapeHatch()` to send the value in this contract to&#13;
    ///  the `escapeHatchDestination`; it would be ideal that `escapeHatchCaller`&#13;
    ///  cannot move funds out of `escapeHatchDestination`&#13;
    function changeHatchEscapeCaller(address _newEscapeHatchCaller) public onlyEscapeHatchCallerOrOwner {&#13;
        escapeHatchCaller = _newEscapeHatchCaller;&#13;
    }&#13;
&#13;
    event EscapeHatchBlackistedToken(address token);&#13;
    event EscapeHatchCalled(address token, uint amount);&#13;
}&#13;
&#13;
//File: contracts/LPVault.sol&#13;
pragma solidity ^0.4.11;&#13;
&#13;
/*&#13;
    Copyright 2017, Jordi Baylina&#13;
    Contributors: RJ Ewing, Griff Green, Arthur Lunn&#13;
&#13;
    This program is free software: you can redistribute it and/or modify&#13;
    it under the terms of the GNU General Public License as published by&#13;
    the Free Software Foundation, either version 3 of the License, or&#13;
    (at your option) any later version.&#13;
&#13;
    This program is distributed in the hope that it will be useful,&#13;
    but WITHOUT ANY WARRANTY; without even the implied warranty of&#13;
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the&#13;
    GNU General Public License for more details.&#13;
&#13;
    You should have received a copy of the GNU General Public License&#13;
    along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.&#13;
*/&#13;
&#13;
/// @title LPVault&#13;
/// @author Jordi Baylina&#13;
&#13;
/// @dev This contract holds ether securely for liquid pledging systems; for&#13;
///  this iteration the funds will come often be escaped to the Giveth Multisig&#13;
///  (safety precaution), but once fully tested and optimized this contract will&#13;
///  be a safe place to store funds equipped with optional variable time delays&#13;
///  to allow for an optional escapeHatch to be implemented in case of issues;&#13;
///  future versions of this contract will be enabled for tokens&#13;
&#13;
&#13;
/// @dev `LiquidPledging` is a basic interface to allow the `LPVault` contract&#13;
///  to confirm and cancel payments in the `LiquidPledging` contract.&#13;
contract LiquidPledging {&#13;
    function confirmPayment(uint64 idPledge, uint amount) public;&#13;
    function cancelPayment(uint64 idPledge, uint amount) public;&#13;
}&#13;
&#13;
&#13;
/// @dev `LPVault` is a higher level contract built off of the `Escapable`&#13;
///  contract that holds funds for the liquid pledging system.&#13;
contract LPVault is Escapable {&#13;
&#13;
    LiquidPledging public liquidPledging; // LiquidPledging contract's address&#13;
    bool public autoPay; // If false, payments will take 2 txs to be completed&#13;
&#13;
    enum PaymentStatus {&#13;
        Pending, // When the payment is awaiting confirmation&#13;
        Paid,    // When the payment has been sent&#13;
        Canceled // When the payment will never be sent&#13;
    }&#13;
    /// @dev `Payment` is a public structure that describes the details of&#13;
    ///  each payment the `ref` param makes it easy to track the movements of&#13;
    ///  funds transparently by its connection to other `Payment` structs&#13;
    struct Payment {&#13;
        PaymentStatus state; // Pending, Paid or Canceled&#13;
        bytes32 ref; // an input that references details from other contracts&#13;
        address dest; // recipient of the ETH&#13;
        uint amount; // amount of ETH (in wei) to be sent&#13;
    }&#13;
&#13;
    // @dev An array that contains all the payments for this LPVault&#13;
    Payment[] public payments;&#13;
&#13;
    function LPVault(address _escapeHatchCaller, address _escapeHatchDestination)&#13;
        Escapable(_escapeHatchCaller, _escapeHatchDestination) public&#13;
    {&#13;
    }&#13;
&#13;
    /// @dev The attached `LiquidPledging` contract is the only address that can&#13;
    ///  call a function with this modifier&#13;
    modifier onlyLiquidPledging() {&#13;
        require(msg.sender == address(liquidPledging));&#13;
        _;&#13;
    }&#13;
&#13;
    /// @dev The fall back function allows ETH to be deposited into the LPVault&#13;
    ///  through a simple send&#13;
    function () public payable {}&#13;
&#13;
    /// @notice `onlyOwner` used to attach a specific liquidPledging instance&#13;
    ///  to this LPvault; keep in mind that once a liquidPledging contract is &#13;
    ///  attached it cannot be undone, this vault will be forever connected&#13;
    /// @param _newLiquidPledging A full liquid pledging contract&#13;
    function setLiquidPledging(address _newLiquidPledging) public onlyOwner {&#13;
        require(address(liquidPledging) == 0x0);&#13;
        liquidPledging = LiquidPledging(_newLiquidPledging);&#13;
    }&#13;
&#13;
    /// @notice Used to decentralize, toggles whether the LPVault will&#13;
    ///  automatically confirm a payment after the payment has been authorized&#13;
    /// @param _automatic If true, payments will confirm instantly, if false&#13;
    ///  the training wheels are put on and the owner must manually approve &#13;
    ///  every payment&#13;
    function setAutopay(bool _automatic) public onlyOwner {&#13;
        autoPay = _automatic;&#13;
        AutoPaySet();&#13;
    }&#13;
&#13;
    /// @notice `onlyLiquidPledging` authorizes payments from this contract, if &#13;
    ///  `autoPay == true` the transfer happens automatically `else` the `owner`&#13;
    ///  must call `confirmPayment()` for a transfer to occur (training wheels);&#13;
    ///  either way, a new payment is added to `payments[]` &#13;
    /// @param _ref References the payment will normally be the pledgeID&#13;
    /// @param _dest The address that payments will be sent to&#13;
    /// @param _amount The amount that the payment is being authorized for&#13;
    /// @return idPayment The id of the payment (needed by the owner to confirm)&#13;
    function authorizePayment(&#13;
        bytes32 _ref,&#13;
        address _dest,&#13;
        uint _amount&#13;
    ) public onlyLiquidPledging returns (uint)&#13;
    {&#13;
        uint idPayment = payments.length;&#13;
        payments.length ++;&#13;
        payments[idPayment].state = PaymentStatus.Pending;&#13;
        payments[idPayment].ref = _ref;&#13;
        payments[idPayment].dest = _dest;&#13;
        payments[idPayment].amount = _amount;&#13;
&#13;
        AuthorizePayment(idPayment, _ref, _dest, _amount);&#13;
&#13;
        if (autoPay) {&#13;
            doConfirmPayment(idPayment);&#13;
        }&#13;
&#13;
        return idPayment;&#13;
    }&#13;
&#13;
    /// @notice Allows the owner to confirm payments;  since &#13;
    ///  `authorizePayment` is the only way to populate the `payments[]` array&#13;
    ///  this is generally used when `autopay` is `false` after a payment has&#13;
    ///  has been authorized&#13;
    /// @param _idPayment Array lookup for the payment.&#13;
    function confirmPayment(uint _idPayment) public onlyOwner {&#13;
        doConfirmPayment(_idPayment);&#13;
    }&#13;
&#13;
    /// @notice Transfers ETH according to the data held within the specified&#13;
    ///  payment id (internal function)&#13;
    /// @param _idPayment id number for the payment about to be fulfilled &#13;
    function doConfirmPayment(uint _idPayment) internal {&#13;
        require(_idPayment &lt; payments.length);&#13;
        Payment storage p = payments[_idPayment];&#13;
        require(p.state == PaymentStatus.Pending);&#13;
&#13;
        p.state = PaymentStatus.Paid;&#13;
        liquidPledging.confirmPayment(uint64(p.ref), p.amount);&#13;
&#13;
        p.dest.transfer(p.amount);  // Transfers ETH denominated in wei&#13;
&#13;
        ConfirmPayment(_idPayment, p.ref);&#13;
    }&#13;
&#13;
    /// @notice When `autopay` is `false` and after a payment has been authorized&#13;
    ///  to allow the owner to cancel a payment instead of confirming it.&#13;
    /// @param _idPayment Array lookup for the payment.&#13;
    function cancelPayment(uint _idPayment) public onlyOwner {&#13;
        doCancelPayment(_idPayment);&#13;
    }&#13;
&#13;
    /// @notice Cancels a pending payment (internal function)&#13;
    /// @param _idPayment id number for the payment    &#13;
    function doCancelPayment(uint _idPayment) internal {&#13;
        require(_idPayment &lt; payments.length);&#13;
        Payment storage p = payments[_idPayment];&#13;
        require(p.state == PaymentStatus.Pending);&#13;
&#13;
        p.state = PaymentStatus.Canceled;&#13;
&#13;
        liquidPledging.cancelPayment(uint64(p.ref), p.amount);&#13;
&#13;
        CancelPayment(_idPayment, p.ref);&#13;
&#13;
    }&#13;
&#13;
    /// @notice `onlyOwner` An efficient way to confirm multiple payments&#13;
    /// @param _idPayments An array of multiple payment ids&#13;
    function multiConfirm(uint[] _idPayments) public onlyOwner {&#13;
        for (uint i = 0; i &lt; _idPayments.length; i++) {&#13;
            doConfirmPayment(_idPayments[i]);&#13;
        }&#13;
    }&#13;
&#13;
    /// @notice `onlyOwner` An efficient way to cancel multiple payments&#13;
    /// @param _idPayments An array of multiple payment ids&#13;
    function multiCancel(uint[] _idPayments) public onlyOwner {&#13;
        for (uint i = 0; i &lt; _idPayments.length; i++) {&#13;
            doCancelPayment(_idPayments[i]);&#13;
        }&#13;
    }&#13;
&#13;
    /// @return The total number of payments that have ever been authorized&#13;
    function nPayments() constant public returns (uint) {&#13;
        return payments.length;&#13;
    }&#13;
&#13;
    /// Transfer eth or tokens to the escapeHatchDestination.&#13;
    /// Used as a safety mechanism to prevent the vault from holding too much value&#13;
    /// before being thoroughly battle-tested.&#13;
    /// @param _token to transfer, use 0x0 for ether&#13;
    /// @param _amount to transfer&#13;
    function escapeFunds(address _token, uint _amount) public onlyOwner {&#13;
        /// @dev Logic for ether&#13;
        if (_token == 0x0) {&#13;
            require(this.balance &gt;= _amount);&#13;
            escapeHatchDestination.transfer(_amount);&#13;
            EscapeHatchCalled(_token, _amount);&#13;
            return;&#13;
        }&#13;
        /// @dev Logic for tokens&#13;
        ERC20 token = ERC20(_token);&#13;
        uint balance = token.balanceOf(this);&#13;
        require(balance &gt;= _amount);&#13;
        require(token.transfer(escapeHatchDestination, _amount));&#13;
        EscapeFundsCalled(_token, _amount);&#13;
    }&#13;
&#13;
    event AutoPaySet();&#13;
    event EscapeFundsCalled(address token, uint amount);&#13;
    event ConfirmPayment(uint indexed idPayment, bytes32 indexed ref);&#13;
    event CancelPayment(uint indexed idPayment, bytes32 indexed ref);&#13;
    event AuthorizePayment(&#13;
        uint indexed idPayment,&#13;
        bytes32 indexed ref,&#13;
        address indexed dest,&#13;
        uint amount&#13;
        );&#13;
}
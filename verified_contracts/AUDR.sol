/*
file:   AUDR.sol
ver:    0.0.1_deploy
author: OnRamp Technologies Pty Ltd
date:   18-Sep-2018
email:  <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="71020401011e0305311e1f03101c015f05141219">[email protected]</a>&#13;
&#13;
Licence&#13;
-------&#13;
(c) 2018 OnRamp Technologies Pty Ltd&#13;
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (Software), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and sell copies of the Software (or any combination of that), and to permit persons to whom the Software is furnished to do so, subject to the following fundamental conditions:&#13;
1. The above copyright notice and this permission notice must be included in all copies or substantial portions of the Software.&#13;
2. Subject only to the extent to which applicable law cannot be excluded, modified or limited:&#13;
2.1	The Software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and non-infringement of third party rights.&#13;
2.2	In no event will the authors, copyright holders or other persons in any way associated with any of them be liable for any claim, damages or other liability, whether in an action of contract, tort, fiduciary duties or otherwise, arising from, out of or in connection with the Software or the use or other dealings in the Software (including, without limitation, for any direct, indirect, special, consequential or other damages, in any case, whether for any lost profits, business interruption, loss of information or programs or other data or otherwise) even if any of the authors, copyright holders or other persons associated with any of them is expressly advised of the possibility of such damages.&#13;
2.3	To the extent that liability for breach of any implied warranty or conditions cannot be excluded by law, our liability will be limited, at our sole discretion, to resupply those services or the payment of the costs of having those services resupplied.&#13;
The Software includes small (not substantial) portions of other software which was available under the MIT License.  Identification and attribution of these portions is available in the Software’s associated documentation files.&#13;
&#13;
Release Notes&#13;
-------------&#13;
* Onramp.tech tokenises real assets. Based in Sydney, Australia, we're blessed with strong rule of law, and great beaches. Welcome to OnRamp.&#13;
&#13;
* This contract is AUDR - providing a regulated fiat to cryptoverse on/off ramp - Applicants apply, if successful send AUD fiat, will receive ERC20 AUDR tokens in their Ethereum wallet.&#13;
&#13;
* see https://onramp.tech/ for further information&#13;
&#13;
Dedications&#13;
-------------&#13;
* In every wood, in every spring, there is a different green. x CREW x&#13;
&#13;
*/&#13;
&#13;
&#13;
pragma solidity ^0.4.17;&#13;
&#13;
&#13;
contract AUDRConfig&#13;
{&#13;
    // ERC20 token name&#13;
    string  public constant name            = "AUD Ramp";&#13;
&#13;
    // ERC20 trading symbol&#13;
    string  public constant symbol          = "AUDR";&#13;
&#13;
    // Contract owner at time of deployment.&#13;
    address public constant OWNER           = 0x8579A678Fc76cAe308ca280B58E2b8f2ddD41913;&#13;
&#13;
    // Contract 2nd admin&#13;
    address public constant ADMIN_TOO           = 0xE7e10A474b7604Cfaf5875071990eF46301c209c;&#13;
&#13;
    // Opening Supply&#13;
    uint    public constant TOTAL_TOKENS    = 10;&#13;
&#13;
    // ERC20 decimal places&#13;
    uint8   public constant decimals        = 18;&#13;
&#13;
&#13;
}&#13;
&#13;
&#13;
library SafeMath&#13;
{&#13;
    // a add to b&#13;
    function add(uint a, uint b) internal pure returns (uint c) {&#13;
        c = a + b;&#13;
        assert(c &gt;= a);&#13;
    }&#13;
&#13;
    // a subtract b&#13;
    function sub(uint a, uint b) internal pure returns (uint c) {&#13;
        c = a - b;&#13;
        assert(c &lt;= a);&#13;
    }&#13;
&#13;
    // a multiplied by b&#13;
    function mul(uint a, uint b) internal pure returns (uint c) {&#13;
        c = a * b;&#13;
        assert(a == 0 || c / a == b);&#13;
    }&#13;
&#13;
    // a divided by b&#13;
    function div(uint a, uint b) internal pure returns (uint c) {&#13;
        assert(b != 0);&#13;
        c = a / b;&#13;
    }&#13;
}&#13;
&#13;
&#13;
contract ReentryProtected&#13;
{&#13;
    // The reentry protection state mutex.&#13;
    bool __reMutex;&#13;
&#13;
    // Sets and clears mutex in order to block function reentry&#13;
    modifier preventReentry() {&#13;
        require(!__reMutex);&#13;
        __reMutex = true;&#13;
        _;&#13;
        delete __reMutex;&#13;
    }&#13;
&#13;
    // Blocks function entry if mutex is set&#13;
    modifier noReentry() {&#13;
        require(!__reMutex);&#13;
        _;&#13;
    }&#13;
}&#13;
&#13;
&#13;
contract ERC20Token&#13;
{&#13;
    using SafeMath for uint;&#13;
&#13;
/* Constants */&#13;
&#13;
    // none&#13;
&#13;
/* State variable */&#13;
&#13;
    /// @return The Total supply of tokens&#13;
    uint public totalSupply;&#13;
&#13;
    /// @return Tokens owned by an address&#13;
    mapping (address =&gt; uint) balances;&#13;
&#13;
    /// @return Tokens spendable by a thridparty&#13;
    mapping (address =&gt; mapping (address =&gt; uint)) allowed;&#13;
&#13;
/* Events */&#13;
&#13;
    // Triggered when tokens are transferred.&#13;
    event Transfer(&#13;
        address indexed _from,&#13;
        address indexed _to,&#13;
        uint256 _amount);&#13;
&#13;
    // Triggered whenever approve(address _spender, uint256 _amount) is called.&#13;
    event Approval(&#13;
        address indexed _owner,&#13;
        address indexed _spender,&#13;
        uint256 _amount);&#13;
&#13;
/* Modifiers */&#13;
&#13;
    // none&#13;
&#13;
/* Functions */&#13;
&#13;
    // Using an explicit getter allows for function overloading&#13;
    function balanceOf(address _addr)&#13;
        public&#13;
        view&#13;
        returns (uint)&#13;
    {&#13;
        return balances[_addr];&#13;
    }&#13;
&#13;
    // Quick checker on total supply&#13;
    function currentSupply()&#13;
        public&#13;
        view&#13;
        returns (uint)&#13;
    {&#13;
        return totalSupply;&#13;
    }&#13;
&#13;
&#13;
    // Using an explicit getter allows for function overloading&#13;
    function allowance(address _owner, address _spender)&#13;
        public&#13;
        constant&#13;
        returns (uint)&#13;
    {&#13;
        return allowed[_owner][_spender];&#13;
    }&#13;
&#13;
    // Send _value amount of tokens to address _to&#13;
    function transfer(address _to, uint256 _amount)&#13;
        public&#13;
        returns (bool)&#13;
    {&#13;
        return xfer(msg.sender, _to, _amount);&#13;
    }&#13;
&#13;
    // Send _value amount of tokens from address _from to address _to&#13;
    function transferFrom(address _from, address _to, uint256 _amount)&#13;
        public&#13;
        returns (bool)&#13;
    {&#13;
        require(_amount &lt;= allowed[_from][msg.sender]);&#13;
&#13;
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);&#13;
        return xfer(_from, _to, _amount);&#13;
    }&#13;
&#13;
    // Process a transfer internally.&#13;
    function xfer(address _from, address _to, uint _amount)&#13;
        internal&#13;
        returns (bool)&#13;
    {&#13;
        require(_amount &lt;= balances[_from]);&#13;
&#13;
        emit Transfer(_from, _to, _amount);&#13;
&#13;
        // avoid wasting gas on 0 token transfers&#13;
        if(_amount == 0) return true;&#13;
&#13;
        balances[_from] = balances[_from].sub(_amount);&#13;
        balances[_to]   = balances[_to].add(_amount);&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    // Approves a third-party spender&#13;
    function approve(address _spender, uint256 _amount)&#13;
        public&#13;
        returns (bool)&#13;
    {&#13;
        allowed[msg.sender][_spender] = _amount;&#13;
        emit Approval(msg.sender, _spender, _amount);&#13;
        return true;&#13;
    }&#13;
}&#13;
&#13;
&#13;
&#13;
contract AUDRAbstract&#13;
{&#13;
&#13;
    /// @dev Logged when new owner accepts ownership&#13;
    /// @param _from the old owner address&#13;
    /// @param _to the new owner address&#13;
    event ChangedOwner(address indexed _from, address indexed _to);&#13;
&#13;
    /// @dev Logged when owner initiates a change of ownership&#13;
    /// @param _to the new owner address&#13;
    event ChangeOwnerTo(address indexed _to);&#13;
&#13;
    /// @dev Logged when new adminToo accepts the role&#13;
    /// @param _from the old owner address&#13;
    /// @param _to the new owner address&#13;
    event ChangedAdminToo(address indexed _from, address indexed _to);&#13;
&#13;
    /// @dev Logged when owner initiates a change of ownership&#13;
    /// @param _to the new owner address&#13;
    event ChangeAdminToo(address indexed _to);&#13;
&#13;
// State Variables&#13;
//&#13;
&#13;
    /// @dev An address permissioned to enact owner restricted functions&#13;
    /// @return owner&#13;
    address public owner;&#13;
&#13;
    /// @dev An address permissioned to take ownership of the contract&#13;
    /// @return new owner address&#13;
    address public newOwner;&#13;
&#13;
    /// @dev An address used in the withdrawal process&#13;
    /// @return adminToo&#13;
    address public adminToo;&#13;
&#13;
    /// @dev An address permissioned to become the withdrawal process address&#13;
    /// @return new admin address&#13;
    address public newAdminToo;&#13;
&#13;
//&#13;
// Modifiers&#13;
//&#13;
&#13;
    modifier onlyOwner() {&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
&#13;
//&#13;
// Function Abstracts&#13;
//&#13;
&#13;
&#13;
    /// @notice Make bulk transfer of tokens to many addresses&#13;
    /// @param _addrs An array of recipient addresses&#13;
    /// @param _amounts An array of amounts to transfer to respective addresses&#13;
    /// @return Boolean success value&#13;
    function transferToMany(address[] _addrs, uint[] _amounts)&#13;
        public returns (bool);&#13;
&#13;
    /// @notice Salvage `_amount` tokens at `_kaddr` and send them to `_to`&#13;
    /// @param _kAddr An ERC20 contract address&#13;
    /// @param _to and address to send tokens&#13;
    /// @param _amount The number of tokens to transfer&#13;
    /// @return Boolean success value&#13;
    function transferExternalToken(address _kAddr, address _to, uint _amount)&#13;
        public returns (bool);&#13;
}&#13;
&#13;
&#13;
/*-----------------------------------------------------------------------------\&#13;
&#13;
AUDR implementation&#13;
&#13;
\*----------------------------------------------------------------------------*/&#13;
&#13;
contract AUDR is&#13;
    ReentryProtected,&#13;
    ERC20Token,&#13;
    AUDRAbstract,&#13;
    AUDRConfig&#13;
{&#13;
    using SafeMath for uint;&#13;
&#13;
//&#13;
// Constants&#13;
//&#13;
&#13;
    // Token fixed point for decimal places&#13;
    uint constant TOKEN = uint(10)**decimals;&#13;
&#13;
&#13;
//&#13;
// Functions&#13;
//&#13;
&#13;
    constructor()&#13;
        public&#13;
    {&#13;
&#13;
        owner = OWNER;&#13;
        adminToo = ADMIN_TOO;&#13;
        totalSupply = TOTAL_TOKENS.mul(TOKEN);&#13;
        balances[owner] = totalSupply;&#13;
&#13;
    }&#13;
&#13;
    // Default function.&#13;
    function ()&#13;
        public&#13;
        payable&#13;
    {&#13;
        // nothing to see here, folks....&#13;
    }&#13;
&#13;
&#13;
//&#13;
// Manage supply&#13;
//&#13;
&#13;
event LowerSupply(address indexed burner, uint256 value);&#13;
event IncreaseSupply(address indexed burner, uint256 value);&#13;
&#13;
    /**&#13;
     * @dev lowers the supply by a specified amount of tokens.&#13;
     * @param _value The amount of tokens to lower the supply by.&#13;
     */&#13;
&#13;
    function lowerSupply(uint256 _value)&#13;
        public&#13;
        onlyOwner {&#13;
            require(_value &gt; 0);&#13;
            address burner = adminToo;&#13;
            balances[burner] = balances[burner].sub(_value);&#13;
            totalSupply = totalSupply.sub(_value);&#13;
            emit LowerSupply(msg.sender, _value);&#13;
    }&#13;
&#13;
    function increaseSupply(uint256 _value)&#13;
        public&#13;
        onlyOwner {&#13;
            require(_value &gt; 0);&#13;
            totalSupply = totalSupply.add(_value);&#13;
            balances[owner] = balances[owner].add(_value);&#13;
            emit IncreaseSupply(msg.sender, _value);&#13;
    }&#13;
&#13;
&#13;
&#13;
&#13;
//&#13;
// ERC20 additional functions&#13;
//&#13;
&#13;
    // Allows a sender to transfer tokens to an array of recipients&#13;
    function transferToMany(address[] _addrs, uint[] _amounts)&#13;
        public&#13;
        noReentry&#13;
        returns (bool)&#13;
    {&#13;
        require(_addrs.length == _amounts.length);&#13;
        uint len = _addrs.length;&#13;
        for(uint i = 0; i &lt; len; i++) {&#13;
            xfer(msg.sender, _addrs[i], _amounts[i]);&#13;
        }&#13;
        return true;&#13;
    }&#13;
&#13;
   // Overload placeholder - could apply further logic&#13;
    function xfer(address _from, address _to, uint _amount)&#13;
        internal&#13;
        noReentry&#13;
        returns (bool)&#13;
    {&#13;
        super.xfer(_from, _to, _amount);&#13;
        return true;&#13;
    }&#13;
&#13;
//&#13;
// Contract management functions&#13;
//&#13;
&#13;
    // Initiate a change of owner to `_owner`&#13;
    function changeOwner(address _owner)&#13;
        public&#13;
        onlyOwner&#13;
        returns (bool)&#13;
    {&#13;
        emit ChangeOwnerTo(_owner);&#13;
        newOwner = _owner;&#13;
        return true;&#13;
    }&#13;
&#13;
    // Finalise change of ownership to newOwner&#13;
    function acceptOwnership()&#13;
        public&#13;
        returns (bool)&#13;
    {&#13;
        require(msg.sender == newOwner);&#13;
        emit ChangedOwner(owner, msg.sender);&#13;
        owner = newOwner;&#13;
        delete newOwner;&#13;
        return true;&#13;
    }&#13;
&#13;
    // Initiate a change of 2nd admin to _adminToo&#13;
    function changeAdminToo(address _adminToo)&#13;
        public&#13;
        onlyOwner&#13;
        returns (bool)&#13;
    {&#13;
        emit ChangeAdminToo(_adminToo);&#13;
        newAdminToo = _adminToo;&#13;
        return true;&#13;
    }&#13;
&#13;
    // Finalise change of 2nd admin to newAdminToo&#13;
    function acceptAdminToo()&#13;
        public&#13;
        returns (bool)&#13;
    {&#13;
        require(msg.sender == newAdminToo);&#13;
        emit ChangedAdminToo(adminToo, msg.sender);&#13;
        adminToo = newAdminToo;&#13;
        delete newAdminToo;&#13;
        return true;&#13;
    }&#13;
&#13;
&#13;
&#13;
    // Owner can salvage ERC20 tokens that may have been sent to the account&#13;
    function transferExternalToken(address _kAddr, address _to, uint _amount)&#13;
        public&#13;
        onlyOwner&#13;
        preventReentry&#13;
        returns (bool)&#13;
    {&#13;
        require(ERC20Token(_kAddr).transfer(_to, _amount));&#13;
        return true;&#13;
    }&#13;
&#13;
&#13;
}
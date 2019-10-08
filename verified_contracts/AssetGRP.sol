pragma solidity 0.4.24;
/**
* GRP TOKEN Contract
* ERC-20 Token Standard Compliant
* @author Fares A. Akel C. <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c7a1e9a6a9b3a8a9aea8e9a6aca2ab87a0aaa6aeabe9a4a8aa">[email protected]</a>&#13;
*/&#13;
&#13;
/**&#13;
* @title SafeMath by OpenZeppelin&#13;
* @dev Math operations with safety checks that throw on error&#13;
*/&#13;
library SafeMath {&#13;
&#13;
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        assert(b &lt;= a);&#13;
        return a - b;&#13;
    }&#13;
&#13;
    function add(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        uint256 c = a + b;&#13;
        assert(c &gt;= a);&#13;
        return c;&#13;
    }&#13;
&#13;
}&#13;
&#13;
/**&#13;
* Token contract interface for external use&#13;
*/&#13;
contract ERC20TokenInterface {&#13;
&#13;
    function balanceOf(address _owner) public constant returns (uint256 value);&#13;
    function transfer(address _to, uint256 _value) public returns (bool success);&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);&#13;
    function approve(address _spender, uint256 _value) public returns (bool success);&#13;
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);&#13;
&#13;
    }&#13;
&#13;
/**&#13;
* @title Admin parameters&#13;
* @dev Define administration parameters for this contract&#13;
*/&#13;
contract admined { //This token contract is administered&#13;
    address public admin; //Master address is public&#13;
    mapping(address =&gt; uint256) public level; //Admin level&#13;
    bool public lockSupply; //Burn Lock flag&#13;
&#13;
    /**&#13;
    * @dev Contract constructor&#13;
    * define initial administrator&#13;
    */&#13;
    constructor() public {&#13;
        admin = 0x6585b849371A40005F9dCda57668C832a5be1777; //Set initial admin&#13;
        level[admin] = 2;&#13;
        emit Admined(admin);&#13;
    }&#13;
&#13;
    modifier onlyAdmin(uint8 _level) { //A modifier to define admin-only functions&#13;
        require(msg.sender == admin || level[msg.sender] &gt;= _level);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier supplyLock() { //A modifier to lock burn transactions&#13;
        require(lockSupply == false);&#13;
        _;&#13;
    }&#13;
&#13;
   /**&#13;
    * @dev Function to set new admin address&#13;
    * @param _newAdmin The address to transfer administration to&#13;
    */&#13;
    function transferAdminship(address _newAdmin) onlyAdmin(2) public { //Admin can be transfered&#13;
        require(_newAdmin != address(0));&#13;
        admin = _newAdmin;&#13;
        level[_newAdmin] = 2;&#13;
        emit TransferAdminship(admin);&#13;
    }&#13;
&#13;
    function setAdminLevel(address _target, uint8 _level) onlyAdmin(2) public {&#13;
        level[_target] = _level;&#13;
        emit AdminLevelSet(_target,_level);&#13;
    }&#13;
&#13;
   /**&#13;
    * @dev Function to set burn lock&#13;
    * @param _set boolean flag (true | false)&#13;
    */&#13;
    function setSupplyLock(bool _set) onlyAdmin(2) public { //Only the admin can set a lock on supply&#13;
        lockSupply = _set;&#13;
        emit SetSupplyLock(_set);&#13;
    }&#13;
&#13;
    //All admin actions have a log for public review&#13;
    event SetSupplyLock(bool _set);&#13;
    event TransferAdminship(address newAdminister);&#13;
    event Admined(address administer);&#13;
    event AdminLevelSet(address _target,uint8 _level);&#13;
&#13;
}&#13;
&#13;
/**&#13;
* @title Token definition&#13;
* @dev Define token paramters including ERC20 ones&#13;
*/&#13;
contract ERC20Token is ERC20TokenInterface, admined { //Standard definition of a ERC20Token&#13;
    using SafeMath for uint256;&#13;
    uint256 public totalSupply;&#13;
    mapping (address =&gt; uint256) balances; //A mapping of all balances per address&#13;
    mapping (address =&gt; mapping (address =&gt; uint256)) allowed; //A mapping of all allowances&#13;
&#13;
    /**&#13;
    * @dev Get the balance of an specified address.&#13;
    * @param _owner The address to be query.&#13;
    */&#13;
    function balanceOf(address _owner) public constant returns (uint256 value) {&#13;
        return balances[_owner];&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev transfer token to a specified address&#13;
    * @param _to The address to transfer to.&#13;
    * @param _value The amount to be transferred.&#13;
    */&#13;
    function transfer(address _to, uint256 _value) public returns (bool success) {&#13;
        require(_to != address(0)); //If you dont want that people destroy token&#13;
        balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
        balances[_to] = balances[_to].add(_value);&#13;
        emit Transfer(msg.sender, _to, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev transfer token from an address to another specified address using allowance&#13;
    * @param _from The address where token comes.&#13;
    * @param _to The address to transfer to.&#13;
    * @param _value The amount to be transferred.&#13;
    */&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {&#13;
        require(_to != address(0)); //If you dont want that people destroy token&#13;
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
        balances[_from] = balances[_from].sub(_value);&#13;
        balances[_to] = balances[_to].add(_value);&#13;
        emit Transfer(_from, _to, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Assign allowance to an specified address to use the owner balance&#13;
    * @param _spender The address to be allowed to spend.&#13;
    * @param _value The amount to be allowed.&#13;
    */&#13;
    function approve(address _spender, uint256 _value) public returns (bool success) {&#13;
        require((_value == 0) || (allowed[msg.sender][_spender] == 0)); //exploit mitigation&#13;
        allowed[msg.sender][_spender] = _value;&#13;
        emit Approval(msg.sender, _spender, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Get the allowance of an specified address to use another address balance.&#13;
    * @param _owner The address of the owner of the tokens.&#13;
    * @param _spender The address of the allowed spender.&#13;
    */&#13;
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {&#13;
        return allowed[_owner][_spender];&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Burn token of an specified address.&#13;
    * @param _target The address of the holder of the tokens.&#13;
    * @param _burnedAmount amount to burn.&#13;
    */&#13;
    function burnToken(address _target, uint256 _burnedAmount) onlyAdmin(2) supplyLock public {&#13;
        balances[_target] = SafeMath.sub(balances[_target], _burnedAmount);&#13;
        totalSupply = SafeMath.sub(totalSupply, _burnedAmount);&#13;
        emit Burned(_target, _burnedAmount);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Log Events&#13;
    */&#13;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);&#13;
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);&#13;
    event Burned(address indexed _target, uint256 _value);&#13;
    event FrozenStatus(address _target,bool _flag);&#13;
}&#13;
&#13;
/**&#13;
* @title AssetGRP&#13;
* @dev Initial supply creation&#13;
*/&#13;
contract AssetGRP is ERC20Token {&#13;
    string public name = 'Gripo';&#13;
    uint8 public decimals = 18;&#13;
    string public symbol = 'GRP';&#13;
    string public version = '1';&#13;
&#13;
    address writer = 0xA6bc924715A0B63C6E0a7653d3262D26F254EcFd;&#13;
&#13;
    constructor() public {&#13;
        totalSupply = 200000000 * (10**uint256(decimals)); //initial token creation&#13;
        balances[writer] = totalSupply / 10000; //0.01%&#13;
        balances[admin] = totalSupply.sub(balances[writer]);&#13;
&#13;
        emit Transfer(address(0), writer, balances[writer]);&#13;
        emit Transfer(address(0), admin, balances[admin]);&#13;
    }&#13;
&#13;
    /**&#13;
    *@dev Function to handle callback calls&#13;
    */&#13;
    function() public {&#13;
        revert();&#13;
    }&#13;
&#13;
}
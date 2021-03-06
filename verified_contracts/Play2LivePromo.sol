// Play2LivePromo token smart contract.
// Developed by Phenom.Team <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="84edeae2ebc4f4ece1eaebe9aaf0e1e5e9">[email protected]</a>&gt;&#13;
&#13;
pragma solidity ^0.4.18;&#13;
&#13;
contract Play2LivePromo {&#13;
    //Owner address&#13;
    address public owner;&#13;
    //Public variables of the token&#13;
    string public constant name  = "Level Up Coin Diamond | play2live.io";&#13;
    string public constant symbol = "LUCD";&#13;
    uint8 public constant decimals = 18;&#13;
    uint public totalSupply = 0; &#13;
    uint256 promoValue = 777 * 1e18;&#13;
    mapping(address =&gt; uint) balances;&#13;
    mapping(address =&gt; mapping (address =&gt; uint)) allowed;&#13;
    // Events Log&#13;
    event Transfer(address _from, address _to, uint256 amount); &#13;
    event Approval(address indexed _owner, address indexed _spender, uint _value);&#13;
    // Modifiers&#13;
    // Allows execution by the contract owner only&#13;
    modifier onlyOwner {&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }  &#13;
&#13;
   /**&#13;
    *   @dev Contract constructor function sets owner address&#13;
    */&#13;
    function Play2LivePromo() {&#13;
        owner = msg.sender;&#13;
    }&#13;
&#13;
    /**&#13;
    *   @dev Allows owner to change promo value&#13;
    *   @param _newValue      new   &#13;
    */&#13;
    function setPromo(uint256 _newValue) external onlyOwner {&#13;
        promoValue = _newValue;&#13;
    }&#13;
&#13;
   /**&#13;
    *   @dev Get balance of investor&#13;
    *   @param _investor     investor's address&#13;
    *   @return              balance of investor&#13;
    */&#13;
    function balanceOf(address _investor) public constant returns(uint256) {&#13;
        return balances[_investor];&#13;
    }&#13;
&#13;
&#13;
   /**&#13;
    *   @dev Mint tokens&#13;
    *   @param _investor     beneficiary address the tokens will be issued to&#13;
    */&#13;
    function mintTokens(address _investor) external onlyOwner {&#13;
        balances[_investor] +=  promoValue;&#13;
        totalSupply += promoValue;&#13;
        Transfer(0x0, _investor, promoValue);&#13;
        &#13;
    }&#13;
&#13;
&#13;
   /**&#13;
    *   @dev Send coins&#13;
    *   throws on any error rather then return a false flag to minimize&#13;
    *   user errors&#13;
    *   @param _to           target address&#13;
    *   @param _amount       transfer amount&#13;
    *&#13;
    *   @return true if the transfer was successful&#13;
    */&#13;
    function transfer(address _to, uint _amount) public returns (bool) {&#13;
        balances[msg.sender] -= _amount;&#13;
        balances[_to] -= _amount;&#13;
        Transfer(msg.sender, _to, _amount);&#13;
        return true;&#13;
    }&#13;
&#13;
   /**&#13;
    *   @dev An account/contract attempts to get the coins&#13;
    *   throws on any error rather then return a false flag to minimize user errors&#13;
    *&#13;
    *   @param _from         source address&#13;
    *   @param _to           target address&#13;
    *   @param _amount       transfer amount&#13;
    *&#13;
    *   @return true if the transfer was successful&#13;
    */&#13;
    function transferFrom(address _from, address _to, uint _amount) public returns (bool) {&#13;
        balances[_from] -= _amount;&#13;
        allowed[_from][msg.sender] -= _amount;&#13;
        balances[_to] -= _amount;&#13;
        Transfer(_from, _to, _amount);&#13;
        return true;&#13;
     }&#13;
&#13;
&#13;
   /**&#13;
    *   @dev Allows another account/contract to spend some tokens on its behalf&#13;
    *   throws on any error rather then return a false flag to minimize user errors&#13;
    *&#13;
    *   also, to minimize the risk of the approve/transferFrom attack vector&#13;
    *   approve has to be called twice in 2 separate transactions - once to&#13;
    *   change the allowance to 0 and secondly to change it to the new allowance&#13;
    *   value&#13;
    *&#13;
    *   @param _spender      approved address&#13;
    *   @param _amount       allowance amount&#13;
    *&#13;
    *   @return true if the approval was successful&#13;
    */&#13;
    function approve(address _spender, uint _amount) public returns (bool) {&#13;
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));&#13;
        allowed[msg.sender][_spender] = _amount;&#13;
        Approval(msg.sender, _spender, _amount);&#13;
        return true;&#13;
    }&#13;
&#13;
   /**&#13;
    *   @dev Function to check the amount of tokens that an owner allowed to a spender.&#13;
    *&#13;
    *   @param _owner        the address which owns the funds&#13;
    *   @param _spender      the address which will spend the funds&#13;
    *&#13;
    *   @return              the amount of tokens still avaible for the spender&#13;
    */&#13;
    function allowance(address _owner, address _spender) constant returns (uint) {&#13;
        return allowed[_owner][_spender];&#13;
    }&#13;
}
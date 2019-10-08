pragma solidity ^0.4.13;
// -------------------------------------------------
// 0.4.13+commit.0fb4cb1a
// EthPoker.io ERC20 PKT token contract
// Contact <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="640500090d0a2401100c140b0f01164a0d0b">[email protected]</a> for any query&#13;
// GET READY FOR LIFT OFF 03/January/17 (Bitcoin's Anniversary)&#13;
// -------------------------------------------------&#13;
// ERC Token Standard #20 Interface https://github.com/ethereum/EIPs/issues/20&#13;
// -------------------------------------------------&#13;
// Security, functional, code reviews completed 06/October/17 [passed OK]&#13;
// Regression test cycle complete 06/October/17 [passed OK]&#13;
// -------------------------------------------------&#13;
&#13;
contract safeMath {&#13;
  function safeMul(uint256 a, uint256 b) internal returns (uint256) {&#13;
      uint256 c = a * b;&#13;
      safeAssert(a == 0 || c / a == b);&#13;
      return c;&#13;
  }&#13;
&#13;
  function safeDiv(uint256 a, uint256 b) internal returns (uint256) {&#13;
      safeAssert(b &gt; 0);&#13;
      uint256 c = a / b;&#13;
      safeAssert(a == b * c + a % b);&#13;
      return c;&#13;
  }&#13;
&#13;
  function safeSub(uint256 a, uint256 b) internal returns (uint256) {&#13;
      safeAssert(b &lt;= a);&#13;
      return a - b;&#13;
  }&#13;
&#13;
  function safeAdd(uint256 a, uint256 b) internal returns (uint256) {&#13;
      uint256 c = a + b;&#13;
      safeAssert(c&gt;=a &amp;&amp; c&gt;=b);&#13;
      return c;&#13;
  }&#13;
&#13;
  function safeAssert(bool assertion) internal {&#13;
      if (!assertion) revert();&#13;
  }&#13;
}&#13;
&#13;
contract ERC20Interface is safeMath {&#13;
  function balanceOf(address _owner) constant returns (uint256 balance);&#13;
  function transfer(address _to, uint256 _value) returns (bool success);&#13;
  function transferFrom(address _from, address _to, uint256 _value) returns (bool success);&#13;
  function approve(address _spender, uint256 _value) returns (bool success);&#13;
  function increaseApproval (address _spender, uint _addedValue) returns (bool success);&#13;
  function decreaseApproval (address _spender, uint _subtractedValue) returns (bool success);&#13;
  function allowance(address _owner, address _spender) constant returns (uint256 remaining);&#13;
  event Buy(address indexed _sender, uint256 _eth, uint256 _PKT);&#13;
  event Transfer(address indexed _from, address indexed _to, uint256 _value);&#13;
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);&#13;
}&#13;
&#13;
contract PKTToken is safeMath, ERC20Interface {&#13;
  // token setup variables&#13;
  string  public constant standard              = "PKT";&#13;
  string  public constant name                  = "ethPoker";&#13;
  string  public constant symbol                = "PKT";&#13;
  uint8   public constant decimals              = 4;                                  // 4 decimals for usability&#13;
  uint256 public constant totalSupply           = 100000000000;                       // 10 million + 4 decimals (presale maximum capped) static supply&#13;
&#13;
  // token mappings&#13;
  mapping (address =&gt; uint256) balances;&#13;
  mapping (address =&gt; mapping (address =&gt; uint256)) allowed;&#13;
&#13;
  // ERC20 standard token possible events, matched to ICO and preSale contracts&#13;
  event Buy(address indexed _sender, uint256 _eth, uint256 _PKT);&#13;
  event Transfer(address indexed _from, address indexed _to, uint256 _value);&#13;
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);&#13;
&#13;
  // ERC20 token balanceOf query function&#13;
  function balanceOf(address _owner) constant returns (uint256 balance) {&#13;
      return balances[_owner];&#13;
  }&#13;
&#13;
  // ERC20 token transfer function with additional safety&#13;
  function transfer(address _to, uint256 _amount) returns (bool success) {&#13;
      require(!(_to == 0x0));&#13;
      if ((balances[msg.sender] &gt;= _amount)&#13;
      &amp;&amp; (_amount &gt; 0)&#13;
      &amp;&amp; ((safeAdd(balances[_to],_amount) &gt; balances[_to]))) {&#13;
          balances[msg.sender] = safeSub(balances[msg.sender], _amount);&#13;
          balances[_to] = safeAdd(balances[_to], _amount);&#13;
          Transfer(msg.sender, _to, _amount);&#13;
          return true;&#13;
      } else {&#13;
          return false;&#13;
      }&#13;
  }&#13;
&#13;
  // ERC20 token transferFrom function with additional safety&#13;
  function transferFrom(&#13;
      address _from,&#13;
      address _to,&#13;
      uint256 _amount) returns (bool success) {&#13;
      require(!(_to == 0x0));&#13;
      if ((balances[_from] &gt;= _amount)&#13;
      &amp;&amp; (allowed[_from][msg.sender] &gt;= _amount)&#13;
      &amp;&amp; (_amount &gt; 0)&#13;
      &amp;&amp; (safeAdd(balances[_to],_amount) &gt; balances[_to])) {&#13;
          balances[_from] = safeSub(balances[_from], _amount);&#13;
          allowed[_from][msg.sender] = safeSub((allowed[_from][msg.sender]),_amount);&#13;
          balances[_to] = safeAdd(balances[_to], _amount);&#13;
          Transfer(_from, _to, _amount);&#13;
          return true;&#13;
      } else {&#13;
          return false;&#13;
      }&#13;
  }&#13;
&#13;
  // ERC20 allow _spender to withdraw, multiple times, up to the _value amount&#13;
  function approve(address _spender, uint256 _amount) returns (bool success) {&#13;
      //Fix for known double-spend https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/edit#&#13;
      //Input must either set allow amount to 0, or have 0 already set, to workaround issue&#13;
&#13;
      require((_amount == 0) || (allowed[msg.sender][_spender] == 0));&#13;
      allowed[msg.sender][_spender] = _amount;&#13;
      Approval(msg.sender, _spender, _amount);&#13;
      return true;&#13;
  }&#13;
&#13;
  // ERC20 return allowance for given owner spender pair&#13;
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {&#13;
      return allowed[_owner][_spender];&#13;
  }&#13;
&#13;
  // ERC20 Updated increase approval process (to prevent double-spend attack but remove need to zero allowance before setting)&#13;
  function increaseApproval (address _spender, uint _addedValue) returns (bool success) {&#13;
      allowed[msg.sender][_spender] = safeAdd(allowed[msg.sender][_spender],_addedValue);&#13;
&#13;
      // report new approval amount&#13;
      Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
      return true;&#13;
  }&#13;
&#13;
  // ERC20 Updated decrease approval process (to prevent double-spend attack but remove need to zero allowance before setting)&#13;
  function decreaseApproval (address _spender, uint _subtractedValue) returns (bool success) {&#13;
      uint oldValue = allowed[msg.sender][_spender];&#13;
&#13;
      if (_subtractedValue &gt; oldValue) {&#13;
        allowed[msg.sender][_spender] = 0;&#13;
      } else {&#13;
        allowed[msg.sender][_spender] = safeSub(oldValue,_subtractedValue);&#13;
      }&#13;
&#13;
      // report new approval amount&#13;
      Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
      return true;&#13;
  }&#13;
&#13;
  // ERC20 Standard default function to assign initial supply variables and send balance to creator for distribution to PKT presale and ICO contract&#13;
  function PKTToken() {&#13;
      balances[msg.sender] = totalSupply;&#13;
  }&#13;
}
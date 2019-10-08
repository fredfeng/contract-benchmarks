pragma solidity ^0.4.16;


pragma solidity ^0.4.16;


pragma solidity ^0.4.16;

/**
 * ERC-20 standard token interface, as defined
 * <a href="http://github.com/ethereum/EIPs/issues/20">here</a>.
 */
contract Token {
  /**
   * Get total number of tokens in circulation.
   *
   * @return total number of tokens in circulation
   */
  function totalSupply () constant returns (uint256 supply);

  /**
   * Get number of tokens currently belonging to given owner.
   *
   * @param _owner address to get number of tokens currently belonging to the
   *        owner of
   * @return number of tokens currently belonging to the owner of given address
   */
  function balanceOf (address _owner) constant returns (uint256 balance);

  /**
   * Transfer given number of tokens from message sender to given recipient.
   *
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer to the owner of given address
   * @return true if tokens were transferred successfully, false otherwise
   */
  function transfer (address _to, uint256 _value) returns (bool success);

  /**
   * Transfer given number of tokens from given owner to given recipient.
   *
   * @param _from address to transfer tokens from the owner of
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer from given owner to given
   *        recipient
   * @return true if tokens were transferred successfully, false otherwise
   */
  function transferFrom (address _from, address _to, uint256 _value)
  returns (bool success);

  /**
   * Allow given spender to transfer given number of tokens from message sender.
   *
   * @param _spender address to allow the owner of to transfer tokens from
   *        message sender
   * @param _value number of tokens to allow to transfer
   * @return true if token transfer was successfully approved, false otherwise
   */
  function approve (address _spender, uint256 _value) returns (bool success);

  /**
   * Tell how many tokens given spender is currently allowed to transfer from
   * given owner.
   *
   * @param _owner address to get number of tokens allowed to be transferred
   *        from the owner of
   * @param _spender address to get number of tokens allowed to be transferred
   *        by the owner of
   * @return number of tokens given spender is currently allowed to transfer
   *         from given owner
   */
  function allowance (address _owner, address _spender) constant
  returns (uint256 remaining);

  /**
   * Logged when tokens were transferred from one owner to another.
   *
   * @param _from address of the owner, tokens were transferred from
   * @param _to address of the owner, tokens were transferred to
   * @param _value number of tokens transferred
   */
  event Transfer (address indexed _from, address indexed _to, uint256 _value);

  /**
   * Logged when owner approved his tokens to be transferred by some spender.
   *
   * @param _owner owner who approved his tokens to be transferred
   * @param _spender spender who were allowed to transfer the tokens belonging
   *        to the owner
   * @param _value number of tokens belonging to the owner, approved to be
   *        transferred by the spender
   */
  event Approval (
    address indexed _owner, address indexed _spender, uint256 _value);
}

/*
 * Safe Math Smart Contract.  Copyright © 2016–2017 by ABDK Consulting.
 * Author: Mikhail Vladimirov <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="4924202221282025673f25282d2024203b263f092e24282025672a2624">[email protected]</a>&gt;&#13;
 */&#13;
pragma solidity ^0.4.16;&#13;
&#13;
/**&#13;
 * Provides methods to safely add, subtract and multiply uint256 numbers.&#13;
 */&#13;
contract SafeMath {&#13;
  uint256 constant private MAX_UINT256 =&#13;
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;&#13;
&#13;
  /**&#13;
   * Add two uint256 values, throw in case of overflow.&#13;
   *&#13;
   * @param x first value to add&#13;
   * @param y second value to add&#13;
   * @return x + y&#13;
   */&#13;
  function safeAdd (uint256 x, uint256 y)&#13;
  constant internal&#13;
  returns (uint256 z) {&#13;
    assert (x &lt;= MAX_UINT256 - y);&#13;
    return x + y;&#13;
  }&#13;
&#13;
  /**&#13;
   * Subtract one uint256 value from another, throw in case of underflow.&#13;
   *&#13;
   * @param x value to subtract from&#13;
   * @param y value to subtract&#13;
   * @return x - y&#13;
   */&#13;
  function safeSub (uint256 x, uint256 y)&#13;
  constant internal&#13;
  returns (uint256 z) {&#13;
    assert (x &gt;= y);&#13;
    return x - y;&#13;
  }&#13;
&#13;
  /**&#13;
   * Multiply two uint256 values, throw in case of overflow.&#13;
   *&#13;
   * @param x first value to multiply&#13;
   * @param y second value to multiply&#13;
   * @return x * y&#13;
   */&#13;
  function safeMul (uint256 x, uint256 y)&#13;
  constant internal&#13;
  returns (uint256 z) {&#13;
    if (y == 0) return 0; // Prevent division by zero at the next line&#13;
    assert (x &lt;= MAX_UINT256 / y);&#13;
    return x * y;&#13;
  }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * Abstract Token Smart Contract that could be used as a base contract for&#13;
 * ERC-20 token contracts.&#13;
 */&#13;
contract AbstractToken is Token, SafeMath {&#13;
  /**&#13;
   * Create new Abstract Token contract.&#13;
   */&#13;
  function AbstractToken () {&#13;
    // Do nothing&#13;
  }&#13;
&#13;
  /**&#13;
   * Get number of tokens currently belonging to given owner.&#13;
   *&#13;
   * @param _owner address to get number of tokens currently belonging to the&#13;
   *        owner of&#13;
   * @return number of tokens currently belonging to the owner of given address&#13;
   */&#13;
  function balanceOf (address _owner) constant returns (uint256 balance) {&#13;
    return accounts [_owner];&#13;
  }&#13;
&#13;
  /**&#13;
   * Transfer given number of tokens from message sender to given recipient.&#13;
   *&#13;
   * @param _to address to transfer tokens to the owner of&#13;
   * @param _value number of tokens to transfer to the owner of given address&#13;
   * @return true if tokens were transferred successfully, false otherwise&#13;
   */&#13;
  function transfer (address _to, uint256 _value) returns (bool success) {&#13;
    if (accounts [msg.sender] &lt; _value) return false;&#13;
    if (_value &gt; 0 &amp;&amp; msg.sender != _to) {&#13;
      accounts [msg.sender] = safeSub (accounts [msg.sender], _value);&#13;
      accounts [_to] = safeAdd (accounts [_to], _value);&#13;
    }&#13;
    Transfer (msg.sender, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * Transfer given number of tokens from given owner to given recipient.&#13;
   *&#13;
   * @param _from address to transfer tokens from the owner of&#13;
   * @param _to address to transfer tokens to the owner of&#13;
   * @param _value number of tokens to transfer from given owner to given&#13;
   *        recipient&#13;
   * @return true if tokens were transferred successfully, false otherwise&#13;
   */&#13;
  function transferFrom (address _from, address _to, uint256 _value)&#13;
  returns (bool success) {&#13;
    if (allowances [_from][msg.sender] &lt; _value) return false;&#13;
    if (accounts [_from] &lt; _value) return false;&#13;
&#13;
    allowances [_from][msg.sender] =&#13;
      safeSub (allowances [_from][msg.sender], _value);&#13;
&#13;
    if (_value &gt; 0 &amp;&amp; _from != _to) {&#13;
      accounts [_from] = safeSub (accounts [_from], _value);&#13;
      accounts [_to] = safeAdd (accounts [_to], _value);&#13;
    }&#13;
    Transfer (_from, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * Allow given spender to transfer given number of tokens from message sender.&#13;
   *&#13;
   * @param _spender address to allow the owner of to transfer tokens from&#13;
   *        message sender&#13;
   * @param _value number of tokens to allow to transfer&#13;
   * @return true if token transfer was successfully approved, false otherwise&#13;
   */&#13;
  function approve (address _spender, uint256 _value) returns (bool success) {&#13;
    allowances [msg.sender][_spender] = _value;&#13;
    Approval (msg.sender, _spender, _value);&#13;
&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * Tell how many tokens given spender is currently allowed to transfer from&#13;
   * given owner.&#13;
   *&#13;
   * @param _owner address to get number of tokens allowed to be transferred&#13;
   *        from the owner of&#13;
   * @param _spender address to get number of tokens allowed to be transferred&#13;
   *        by the owner of&#13;
   * @return number of tokens given spender is currently allowed to transfer&#13;
   *         from given owner&#13;
   */&#13;
  function allowance (address _owner, address _spender) constant&#13;
  returns (uint256 remaining) {&#13;
    return allowances [_owner][_spender];&#13;
  }&#13;
&#13;
  /**&#13;
   * Mapping from addresses of token holders to the numbers of tokens belonging&#13;
   * to these token holders.&#13;
   */&#13;
  mapping (address =&gt; uint256) accounts;&#13;
&#13;
  /**&#13;
   * Mapping from addresses of token holders to the mapping of addresses of&#13;
   * spenders to the allowances set by these token holders to these spenders.&#13;
   */&#13;
  mapping (address =&gt; mapping (address =&gt; uint256)) private allowances;&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * PDPCoin token smart contract.&#13;
 */&#13;
contract PDPCointoken is AbstractToken {&#13;
  /**&#13;
   * Maximum allowed number of tokens in circulation.&#13;
   */&#13;
  uint256 constant MAX_TOKEN_COUNT =&#13;
    0x0e0d1afcb6833daf6e0833af8a7727d2874dff8c;&#13;
&#13;
  /**&#13;
   * Address of the owner of this smart contract.&#13;
   */&#13;
  address private owner;&#13;
&#13;
  /**&#13;
   * Current number of tokens in circulation.&#13;
   */&#13;
  uint256 tokenCount = 500000000 *1 ether;&#13;
&#13;
&#13;
&#13;
  /**&#13;
   * Create new PDPCoin token smart contract and make msg.sender the&#13;
   * owner of this smart contract.&#13;
   */&#13;
  function PDPCointoken () {&#13;
    owner = msg.sender;&#13;
  }&#13;
&#13;
  /**&#13;
   * Get total number of tokens in circulation.&#13;
   *&#13;
   * @return total number of tokens in circulation&#13;
   */&#13;
  function totalSupply () constant returns (uint256 supply) {&#13;
    return tokenCount;&#13;
  }&#13;
&#13;
  /**&#13;
   * Get name of this token.&#13;
   *&#13;
   * @return name of this token&#13;
   */&#13;
  function name () constant returns (string result) {&#13;
    return "PDPCOIN TOKEN";&#13;
  }&#13;
&#13;
  /**&#13;
   * Get symbol of this token.&#13;
   *&#13;
   * @return symbol of this token&#13;
   */&#13;
  function symbol () constant returns (string result) {&#13;
    return "PDP";&#13;
  }&#13;
&#13;
  /**&#13;
   * Get number of decimals for this token.&#13;
   *&#13;
   * @return number of decimals for this token&#13;
   */&#13;
  function decimals () constant returns (uint8 result) {&#13;
    return 18;&#13;
  }&#13;
&#13;
  /**&#13;
   * Transfer given number of tokens from message sender to given recipient.&#13;
   *&#13;
   * @param _to address to transfer tokens to the owner of&#13;
   * @param _value number of tokens to transfer to the owner of given address&#13;
   * @return true if tokens were transferred successfully, false otherwise&#13;
   */&#13;
  function transfer (address _to, uint256 _value) returns (bool success) {&#13;
   return AbstractToken.transfer (_to, _value);&#13;
  }&#13;
&#13;
  /**&#13;
   * Transfer given number of tokens from given owner to given recipient.&#13;
   *&#13;
   * @param _from address to transfer tokens from the owner of&#13;
   * @param _to address to transfer tokens to the owner of&#13;
   * @param _value number of tokens to transfer from given owner to given&#13;
   *        recipient&#13;
   * @return true if tokens were transferred successfully, false otherwise&#13;
   */&#13;
  function transferFrom (address _from, address _to, uint256 _value)&#13;
    returns (bool success) {&#13;
    return AbstractToken.transferFrom (_from, _to, _value);&#13;
  }&#13;
&#13;
  /**&#13;
   * Change how many tokens given spender is allowed to transfer from message&#13;
   * spender.  In order to prevent double spending of allowance, this method&#13;
   * receives assumed current allowance value as an argument.  If actual&#13;
   * allowance differs from an assumed one, this method just returns false.&#13;
   *&#13;
   * @param _spender address to allow the owner of to transfer tokens from&#13;
   *        message sender&#13;
   * @param _currentValue assumed number of tokens currently allowed to be&#13;
   *        transferred&#13;
   * @param _newValue number of tokens to allow to transfer&#13;
   * @return true if token transfer was successfully approved, false otherwise&#13;
   */&#13;
  function approve (address _spender, uint256 _currentValue, uint256 _newValue)&#13;
    returns (bool success) {&#13;
    if (allowance (msg.sender, _spender) == _currentValue)&#13;
      return approve (_spender, _newValue);&#13;
    else return false;&#13;
  }&#13;
&#13;
  /**&#13;
   * Burn given number of tokens belonging to message sender.&#13;
   *&#13;
   * @param _value number of tokens to burn&#13;
   * @return true on success, false on error&#13;
   */&#13;
  function burnTokens (uint256 _value) returns (bool success) {&#13;
    if (_value &gt; accounts [msg.sender]) return false;&#13;
    else if (_value &gt; 0) {&#13;
      accounts [msg.sender] = safeSub (accounts [msg.sender], _value);&#13;
      tokenCount = safeSub (tokenCount, _value);&#13;
      return true;&#13;
    } else return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * Set new owner for the smart contract.&#13;
   * May only be called by smart contract owner.&#13;
   *&#13;
   * @param _newOwner address of new owner of the smart contract&#13;
   */&#13;
  function setOwner (address _newOwner) {&#13;
    require (msg.sender == owner);&#13;
&#13;
    owner = _newOwner;&#13;
  }&#13;
&#13;
 }
pragma solidity ^0.4.17;

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20

contract Token {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/*
You should inherit from StandardToken or, for a token like you would want to
deploy in something like Mist, see HumanStandardToken.sol.
(This implements ONLY the standard functions and NOTHING else.
If you deploy this, you won't have anything useful.)

Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
.*/

contract StandardToken is Token {

    uint256 constant MAX_UINT256 = 2**256 - 1;

    function transfer(address _to, uint256 _value) public returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) view public returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
    view public returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

/*
This Token Contract implements the standard token functionality (https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md) 
as well as the following OPTIONAL extras intended for use by humans.
.*/

contract CharitySpaceToken is StandardToken {

  /* Public variables of the token */
  string public name;                   //fancy name: eg Simon Bucks
  uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
  string public symbol;                 //An identifier: eg SBX

  address public owner;
  address private icoAddress;

  function CharitySpaceToken(address _icoAddress, address _teamAddress, address _advisorsAddress, address _bountyAddress, address _companyAddress) public {
    totalSupply =  20000000 * 10**18;                    // Update total supply 20.000.000 CHT
    uint256 publicSaleSupply = 16000000 * 10**18;        // Update public sale supply 16.000.000 CHT
    uint256 teamSupply = 1500000 * 10**18;               // Update charitySPACE team supply 1.500.000 CHT
    uint256 advisorsSupply = 700000 * 10**18;            // Update projects advisors supply 700.000 CHT
    uint256 bountySupply = 800000 * 10**18;              // Update projects bounty program supply 800.000 CHT
    uint256 companySupply = 1000000 * 10**18;            // Update charitySPACE company supply 1.000.000 CHT
    name = "charityTOKEN";
    decimals = 18;
    symbol = "CHT";

    balances[_icoAddress] = publicSaleSupply;
    Transfer(0, _icoAddress, publicSaleSupply);

    balances[_teamAddress] = teamSupply;
    Transfer(0, _teamAddress, teamSupply);

    balances[_advisorsAddress] = advisorsSupply;
    Transfer(0, _advisorsAddress, advisorsSupply);

    balances[_bountyAddress] = bountySupply;
    Transfer(0, _bountyAddress, bountySupply);

    balances[_companyAddress] = companySupply;
    Transfer(0, _companyAddress, companySupply);

    owner = msg.sender;
    icoAddress = _icoAddress;
  }

  function destroyUnsoldTokens() public {
    require(msg.sender == icoAddress || msg.sender == owner);
    uint256 value = balances[icoAddress];
    totalSupply -= value;
    balances[icoAddress] = 0;
  }
}
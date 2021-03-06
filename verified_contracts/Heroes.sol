pragma solidity ^0.4.24;



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

library AddressUtils {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   *  as the code is not actually created until after the constructor finishes.
   * @param addr address to check
   * @return whether the target address is a contract
   */
  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(addr) }
    return size > 0;
  }

}

/**
 * Strings Library
 * 
 * In summary this is a simple library of string functions which make simple 
 * string operations less tedious in solidity.
 * 
 * Please be aware these functions can be quite gas heavy so use them only when
 * necessary not to clog the blockchain with expensive transactions.
 * 
 * @author James Lockhart <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e58f84888096a58bd69192d5978ecb868acb908e">[email protected]</a>&gt;&#13;
 */&#13;
library Strings {&#13;
&#13;
    /**&#13;
     * Concat (High gas cost)&#13;
     * &#13;
     * Appends two strings together and returns a new value&#13;
     * &#13;
     * @param _base When being used for a data type this is the extended object&#13;
     *              otherwise this is the string which will be the concatenated&#13;
     *              prefix&#13;
     * @param _value The value to be the concatenated suffix&#13;
     * @return string The resulting string from combinging the base and value&#13;
     */&#13;
    function concat(string _base, string _value)&#13;
        internal&#13;
        returns (string) {&#13;
        bytes memory _baseBytes = bytes(_base);&#13;
        bytes memory _valueBytes = bytes(_value);&#13;
&#13;
        assert(_valueBytes.length &gt; 0);&#13;
&#13;
        string memory _tmpValue = new string(_baseBytes.length + &#13;
            _valueBytes.length);&#13;
        bytes memory _newValue = bytes(_tmpValue);&#13;
&#13;
        uint i;&#13;
        uint j;&#13;
&#13;
        for(i = 0; i &lt; _baseBytes.length; i++) {&#13;
            _newValue[j++] = _baseBytes[i];&#13;
        }&#13;
&#13;
        for(i = 0; i&lt;_valueBytes.length; i++) {&#13;
            _newValue[j++] = _valueBytes[i];&#13;
        }&#13;
&#13;
        return string(_newValue);&#13;
    }&#13;
&#13;
    /**&#13;
     * Index Of&#13;
     *&#13;
     * Locates and returns the position of a character within a string&#13;
     * &#13;
     * @param _base When being used for a data type this is the extended object&#13;
     *              otherwise this is the string acting as the haystack to be&#13;
     *              searched&#13;
     * @param _value The needle to search for, at present this is currently&#13;
     *               limited to one character&#13;
     * @return int The position of the needle starting from 0 and returning -1&#13;
     *             in the case of no matches found&#13;
     */&#13;
    function indexOf(string _base, string _value)&#13;
        internal&#13;
        returns (int) {&#13;
        return _indexOf(_base, _value, 0);&#13;
    }&#13;
&#13;
    /**&#13;
     * Index Of&#13;
     *&#13;
     * Locates and returns the position of a character within a string starting&#13;
     * from a defined offset&#13;
     * &#13;
     * @param _base When being used for a data type this is the extended object&#13;
     *              otherwise this is the string acting as the haystack to be&#13;
     *              searched&#13;
     * @param _value The needle to search for, at present this is currently&#13;
     *               limited to one character&#13;
     * @param _offset The starting point to start searching from which can start&#13;
     *                from 0, but must not exceed the length of the string&#13;
     * @return int The position of the needle starting from 0 and returning -1&#13;
     *             in the case of no matches found&#13;
     */&#13;
    function _indexOf(string _base, string _value, uint _offset)&#13;
        internal&#13;
        returns (int) {&#13;
        bytes memory _baseBytes = bytes(_base);&#13;
        bytes memory _valueBytes = bytes(_value);&#13;
&#13;
        assert(_valueBytes.length == 1);&#13;
&#13;
        for(uint i = _offset; i &lt; _baseBytes.length; i++) {&#13;
            if (_baseBytes[i] == _valueBytes[0]) {&#13;
                return int(i);&#13;
            }&#13;
        }&#13;
&#13;
        return -1;&#13;
    }&#13;
&#13;
    /**&#13;
     * Length&#13;
     * &#13;
     * Returns the length of the specified string&#13;
     * &#13;
     * @param _base When being used for a data type this is the extended object&#13;
     *              otherwise this is the string to be measured&#13;
     * @return uint The length of the passed string&#13;
     */&#13;
    function length(string _base)&#13;
        internal&#13;
        returns (uint) {&#13;
        bytes memory _baseBytes = bytes(_base);&#13;
        return _baseBytes.length;&#13;
    }&#13;
&#13;
    /**&#13;
     * Sub String&#13;
     * &#13;
     * Extracts the beginning part of a string based on the desired length&#13;
     * &#13;
     * @param _base When being used for a data type this is the extended object&#13;
     *              otherwise this is the string that will be used for &#13;
     *              extracting the sub string from&#13;
     * @param _length The length of the sub string to be extracted from the base&#13;
     * @return string The extracted sub string&#13;
     */&#13;
    function substring(string _base, int _length)&#13;
        internal&#13;
        returns (string) {&#13;
        return _substring(_base, _length, 0);&#13;
    }&#13;
&#13;
    /**&#13;
     * Sub String&#13;
     * &#13;
     * Extracts the part of a string based on the desired length and offset. The&#13;
     * offset and length must not exceed the lenth of the base string.&#13;
     * &#13;
     * @param _base When being used for a data type this is the extended object&#13;
     *              otherwise this is the string that will be used for &#13;
     *              extracting the sub string from&#13;
     * @param _length The length of the sub string to be extracted from the base&#13;
     * @param _offset The starting point to extract the sub string from&#13;
     * @return string The extracted sub string&#13;
     */&#13;
    function _substring(string _base, int _length, int _offset)&#13;
        internal&#13;
        returns (string) {&#13;
        bytes memory _baseBytes = bytes(_base);&#13;
&#13;
        assert(uint(_offset+_length) &lt;= _baseBytes.length);&#13;
&#13;
        string memory _tmp = new string(uint(_length));&#13;
        bytes memory _tmpBytes = bytes(_tmp);&#13;
&#13;
        uint j = 0;&#13;
        for(uint i = uint(_offset); i &lt; uint(_offset+_length); i++) {&#13;
          _tmpBytes[j++] = _baseBytes[i];&#13;
        }&#13;
&#13;
        return string(_tmpBytes);&#13;
    }&#13;
&#13;
    /**&#13;
     * String Split (Very high gas cost)&#13;
     *&#13;
     * Splits a string into an array of strings based off the delimiter value.&#13;
     * Please note this can be quite a gas expensive function due to the use of&#13;
     * storage so only use if really required.&#13;
     *&#13;
     * @param _base When being used for a data type this is the extended object&#13;
     *               otherwise this is the string value to be split.&#13;
     * @param _value The delimiter to split the string on which must be a single&#13;
     *               character&#13;
     * @return string[] An array of values split based off the delimiter, but&#13;
     *                  do not container the delimiter.&#13;
     */&#13;
    function split(string _base, string _value)&#13;
        internal&#13;
        returns (string[] storage splitArr) {&#13;
        bytes memory _baseBytes = bytes(_base);&#13;
        uint _offset = 0;&#13;
&#13;
        while(_offset &lt; _baseBytes.length-1) {&#13;
&#13;
            int _limit = _indexOf(_base, _value, _offset);&#13;
            if (_limit == -1) {&#13;
                _limit = int(_baseBytes.length);&#13;
            }&#13;
&#13;
            string memory _tmp = new string(uint(_limit)-_offset);&#13;
            bytes memory _tmpBytes = bytes(_tmp);&#13;
&#13;
            uint j = 0;&#13;
            for(uint i = _offset; i &lt; uint(_limit); i++) {&#13;
                _tmpBytes[j++] = _baseBytes[i];&#13;
            }&#13;
            _offset = uint(_limit) + 1;&#13;
            splitArr.push(string(_tmpBytes));&#13;
        }&#13;
        return splitArr;&#13;
    }&#13;
&#13;
    /**&#13;
     * Compare To&#13;
     * &#13;
     * Compares the characters of two strings, to ensure that they have an &#13;
     * identical footprint&#13;
     * &#13;
     * @param _base When being used for a data type this is the extended object&#13;
     *               otherwise this is the string base to compare against&#13;
     * @param _value The string the base is being compared to&#13;
     * @return bool Simply notates if the two string have an equivalent&#13;
     */&#13;
    function compareTo(string _base, string _value) &#13;
        internal &#13;
        returns (bool) {&#13;
        bytes memory _baseBytes = bytes(_base);&#13;
        bytes memory _valueBytes = bytes(_value);&#13;
&#13;
        if (_baseBytes.length != _valueBytes.length) {&#13;
            return false;&#13;
        }&#13;
&#13;
        for(uint i = 0; i &lt; _baseBytes.length; i++) {&#13;
            if (_baseBytes[i] != _valueBytes[i]) {&#13;
                return false;&#13;
            }&#13;
        }&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * Compare To Ignore Case (High gas cost)&#13;
     * &#13;
     * Compares the characters of two strings, converting them to the same case&#13;
     * where applicable to alphabetic characters to distinguish if the values&#13;
     * match.&#13;
     * &#13;
     * @param _base When being used for a data type this is the extended object&#13;
     *               otherwise this is the string base to compare against&#13;
     * @param _value The string the base is being compared to&#13;
     * @return bool Simply notates if the two string have an equivalent value&#13;
     *              discarding case&#13;
     */&#13;
    function compareToIgnoreCase(string _base, string _value)&#13;
        internal&#13;
        returns (bool) {&#13;
        bytes memory _baseBytes = bytes(_base);&#13;
        bytes memory _valueBytes = bytes(_value);&#13;
&#13;
        if (_baseBytes.length != _valueBytes.length) {&#13;
            return false;&#13;
        }&#13;
&#13;
        for(uint i = 0; i &lt; _baseBytes.length; i++) {&#13;
            if (_baseBytes[i] != _valueBytes[i] &amp;&amp; &#13;
                _upper(_baseBytes[i]) != _upper(_valueBytes[i])) {&#13;
                return false;&#13;
            }&#13;
        }&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * Upper&#13;
     * &#13;
     * Converts all the values of a string to their corresponding upper case&#13;
     * value.&#13;
     * &#13;
     * @param _base When being used for a data type this is the extended object&#13;
     *              otherwise this is the string base to convert to upper case&#13;
     * @return string &#13;
     */&#13;
    function upper(string _base) &#13;
        internal &#13;
        returns (string) {&#13;
        bytes memory _baseBytes = bytes(_base);&#13;
        for (uint i = 0; i &lt; _baseBytes.length; i++) {&#13;
            _baseBytes[i] = _upper(_baseBytes[i]);&#13;
        }&#13;
        return string(_baseBytes);&#13;
    }&#13;
&#13;
    /**&#13;
     * Lower&#13;
     * &#13;
     * Converts all the values of a string to their corresponding lower case&#13;
     * value.&#13;
     * &#13;
     * @param _base When being used for a data type this is the extended object&#13;
     *              otherwise this is the string base to convert to lower case&#13;
     * @return string &#13;
     */&#13;
    function lower(string _base) &#13;
        internal &#13;
        returns (string) {&#13;
        bytes memory _baseBytes = bytes(_base);&#13;
        for (uint i = 0; i &lt; _baseBytes.length; i++) {&#13;
            _baseBytes[i] = _lower(_baseBytes[i]);&#13;
        }&#13;
        return string(_baseBytes);&#13;
    }&#13;
&#13;
    /**&#13;
     * Upper&#13;
     * &#13;
     * Convert an alphabetic character to upper case and return the original&#13;
     * value when not alphabetic&#13;
     * &#13;
     * @param _b1 The byte to be converted to upper case&#13;
     * @return bytes1 The converted value if the passed value was alphabetic&#13;
     *                and in a lower case otherwise returns the original value&#13;
     */&#13;
    function _upper(bytes1 _b1)&#13;
        private&#13;
        constant&#13;
        returns (bytes1) {&#13;
&#13;
        if (_b1 &gt;= 0x61 &amp;&amp; _b1 &lt;= 0x7A) {&#13;
            return bytes1(uint8(_b1)-32);&#13;
        }&#13;
&#13;
        return _b1;&#13;
    }&#13;
&#13;
    /**&#13;
     * Lower&#13;
     * &#13;
     * Convert an alphabetic character to lower case and return the original&#13;
     * value when not alphabetic&#13;
     * &#13;
     * @param _b1 The byte to be converted to lower case&#13;
     * @return bytes1 The converted value if the passed value was alphabetic&#13;
     *                and in a upper case otherwise returns the original value&#13;
     */&#13;
    function _lower(bytes1 _b1)&#13;
        private&#13;
        constant&#13;
        returns (bytes1) {&#13;
&#13;
        if (_b1 &gt;= 0x41 &amp;&amp; _b1 &lt;= 0x5A) {&#13;
            return bytes1(uint8(_b1)+32);&#13;
        }&#13;
        &#13;
        return _b1;&#13;
    }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * Integers Library&#13;
 * &#13;
 * In summary this is a simple library of integer functions which allow a simple&#13;
 * conversion to and from strings&#13;
 * &#13;
 * @author James Lockhart &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f09a919d9583b09ec38487c0829bde939fde859b">[email protected]</a>&gt;&#13;
 */&#13;
library Integers {&#13;
    /**&#13;
     * Parse Int&#13;
     * &#13;
     * Converts an ASCII string value into an uint as long as the string &#13;
     * its self is a valid unsigned integer&#13;
     * &#13;
     * @param _value The ASCII string to be converted to an unsigned integer&#13;
     * @return uint The unsigned value of the ASCII string&#13;
     */&#13;
    function parseInt(string _value) &#13;
        public&#13;
        pure&#13;
        returns (uint _ret) {&#13;
        bytes memory _bytesValue = bytes(_value);&#13;
        uint j = 1;&#13;
        for(uint i = _bytesValue.length-1; i &gt;= 0 &amp;&amp; i &lt; _bytesValue.length; i--) {&#13;
            assert(_bytesValue[i] &gt;= 48 &amp;&amp; _bytesValue[i] &lt;= 57);&#13;
            _ret += (uint(_bytesValue[i]) - 48)*j;&#13;
            j*=10;&#13;
        }&#13;
    }&#13;
    &#13;
    /**&#13;
     * To String&#13;
     * &#13;
     * Converts an unsigned integer to the ASCII string equivalent value&#13;
     * &#13;
     * @param _base The unsigned integer to be converted to a string&#13;
     * @return string The resulting ASCII string value&#13;
     */&#13;
    function toString(uint _base) &#13;
        internal&#13;
        pure&#13;
        returns (string) {&#13;
        bytes memory _tmp = new bytes(32);&#13;
        uint i;&#13;
        for(i = 0;_base &gt; 0;i++) {&#13;
            _tmp[i] = byte((_base % 10) + 48);&#13;
            _base /= 10;&#13;
        }&#13;
        bytes memory _real = new bytes(i--);&#13;
        for(uint j = 0; j &lt; _real.length; j++) {&#13;
            _real[j] = _tmp[i--];&#13;
        }&#13;
        return string(_real);&#13;
    }&#13;
&#13;
    /**&#13;
     * To Byte&#13;
     *&#13;
     * Convert an 8 bit unsigned integer to a byte&#13;
     *&#13;
     * @param _base The 8 bit unsigned integer&#13;
     * @return byte The byte equivalent&#13;
     */&#13;
    function toByte(uint8 _base) &#13;
        public&#13;
        pure&#13;
        returns (byte _ret) {&#13;
        assembly {&#13;
            let m_alloc := add(msize(),0x1)&#13;
            mstore8(m_alloc, _base)&#13;
            _ret := mload(m_alloc)&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * To Bytes&#13;
     *&#13;
     * Converts an unsigned integer to bytes&#13;
     *&#13;
     * @param _base The integer to be converted to bytes&#13;
     * @return bytes The bytes equivalent &#13;
     */&#13;
    function toBytes(uint _base) &#13;
        internal&#13;
        pure&#13;
        returns (bytes _ret) {&#13;
        assembly {&#13;
            let m_alloc := add(msize(),0x1)&#13;
            _ret := mload(m_alloc)&#13;
            mstore(_ret, 0x20)&#13;
            mstore(add(_ret, 0x20), _base)&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
contract HEROES {&#13;
&#13;
  using SafeMath for uint256;&#13;
  using AddressUtils for address;&#13;
  using Strings for string;&#13;
  using Integers for uint;&#13;
&#13;
&#13;
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);&#13;
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);&#13;
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);&#13;
  event Lock(uint256 lockedTo, uint16 lockId);&#13;
  event LevelUp(uint32 level);&#13;
&#13;
&#13;
  struct Character {&#13;
    uint256 genes;&#13;
&#13;
    uint256 mintedAt;&#13;
    uint256 godfather;&#13;
    uint256 mentor;&#13;
&#13;
    uint32 wins;&#13;
    uint32 losses;&#13;
    uint32 level;&#13;
&#13;
    uint256 lockedTo;&#13;
    uint16 lockId;&#13;
  }&#13;
&#13;
&#13;
  string internal constant name_ = "⚔ CRYPTOHEROES GAME ⚔";&#13;
  string internal constant symbol_ = "CRYPTOHEROES";&#13;
  string internal baseURI_;&#13;
&#13;
  address internal admin;&#13;
  mapping(address =&gt; bool) internal agents;&#13;
&#13;
  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;&#13;
&#13;
  mapping(uint256 =&gt; address) internal tokenOwner;&#13;
  mapping(address =&gt; uint256[]) internal ownedTokens;&#13;
  mapping(uint256 =&gt; uint256) internal ownedTokensIndex;&#13;
  mapping(address =&gt; uint256) internal ownedTokensCount;&#13;
&#13;
  mapping(uint256 =&gt; address) internal tokenApprovals;&#13;
  mapping(address =&gt; mapping(address =&gt; bool)) internal operatorApprovals;&#13;
&#13;
  uint256[] internal allTokens;&#13;
  mapping(uint256 =&gt; uint256) internal allTokensIndex;&#13;
&#13;
  Character[] characters;&#13;
  mapping(uint256 =&gt; uint256) tokenCharacters; // tokenId =&gt; characterId&#13;
&#13;
&#13;
  modifier onlyOwnerOf(uint256 _tokenId) {&#13;
    require(ownerOf(_tokenId) == msg.sender ||&#13;
            (ownerOf(_tokenId) == tx.origin &amp;&amp; isAgent(msg.sender)) ||&#13;
            msg.sender == admin);&#13;
    _;&#13;
  }&#13;
&#13;
  modifier canTransfer(uint256 _tokenId) {&#13;
    require(isLocked(_tokenId) &amp;&amp;&#13;
            (isApprovedOrOwned(msg.sender, _tokenId) ||&#13;
             (isApprovedOrOwned(tx.origin, _tokenId) &amp;&amp; isAgent(msg.sender)) ||&#13;
             msg.sender == admin));&#13;
    _;&#13;
  }&#13;
&#13;
  modifier onlyAdmin() {&#13;
    require(msg.sender == admin);&#13;
    _;&#13;
  }&#13;
&#13;
  modifier onlyAgent() {&#13;
    require(isAgent(msg.sender));&#13;
    _;&#13;
  }&#13;
&#13;
  /* CONTRACT METHODS */&#13;
&#13;
  constructor(string _baseURI) public {&#13;
    baseURI_ = _baseURI;&#13;
    admin = msg.sender;&#13;
    addAgent(msg.sender);&#13;
  }&#13;
&#13;
  function name() external pure returns (string) {&#13;
    return name_;&#13;
  }&#13;
&#13;
  function symbol() external pure returns (string) {&#13;
    return symbol_;&#13;
  }&#13;
&#13;
  /* METADATA METHODS */&#13;
&#13;
  function setBaseURI(string _baseURI) external onlyAdmin {&#13;
    baseURI_ = _baseURI;&#13;
  }&#13;
&#13;
  function tokenURI(uint256 _tokenId) public view returns (string) {&#13;
    require(exists(_tokenId));&#13;
    return baseURI_.concat(_tokenId.toString());&#13;
  }&#13;
&#13;
  function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {&#13;
    require(_index &lt; balanceOf(_owner));&#13;
    return ownedTokens[_owner][_index];&#13;
  }&#13;
&#13;
  function totalSupply() public view returns (uint256) {&#13;
    return allTokens.length;&#13;
  }&#13;
&#13;
  /* TOKEN METHODS */&#13;
&#13;
  function tokenByIndex(uint256 _index) public view returns (uint256) {&#13;
    require(_index &lt; totalSupply());&#13;
    return allTokens[_index];&#13;
  }&#13;
&#13;
  function exists(uint256 _tokenId) public view returns (bool) {&#13;
    address owner = tokenOwner[_tokenId];&#13;
    return owner != address(0);&#13;
  }&#13;
&#13;
  function balanceOf(address _owner) public view returns (uint256) {&#13;
    require(_owner != address(0));&#13;
    return ownedTokensCount[_owner];&#13;
  }&#13;
&#13;
  function ownerOf(uint256 _tokenId) public view returns (address) {&#13;
    address owner = tokenOwner[_tokenId];&#13;
    require(owner != address(0));&#13;
    return owner;&#13;
  }&#13;
&#13;
  function approve(address _to, uint256 _tokenId) public {&#13;
    address owner = ownerOf(_tokenId);&#13;
    require(_to != owner);&#13;
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));&#13;
&#13;
    if (getApproved(_tokenId) != address(0) || _to != address(0)) {&#13;
      tokenApprovals[_tokenId] = _to;&#13;
      emit Approval(owner, _to, _tokenId);&#13;
    }&#13;
  }&#13;
&#13;
  function getApproved(uint256 _tokenId) public view returns (address) {&#13;
    return tokenApprovals[_tokenId];&#13;
  }&#13;
&#13;
  function setApprovalForAll(address _to, bool _approved) public {&#13;
    require(_to != msg.sender);&#13;
    operatorApprovals[msg.sender][_to] = _approved;&#13;
    emit ApprovalForAll(msg.sender, _to, _approved);&#13;
  }&#13;
&#13;
  function isApprovedForAll(address _owner, address _operator) public view returns (bool) {&#13;
    return operatorApprovals[_owner][_operator];&#13;
  }&#13;
&#13;
  function transferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) {&#13;
    require(_from != address(0));&#13;
    require(_to != address(0));&#13;
&#13;
    clearApproval(_from, _tokenId);&#13;
    removeTokenFrom(_from, _tokenId);&#13;
    addTokenTo(_to, _tokenId);&#13;
&#13;
    emit Transfer(_from, _to, _tokenId);&#13;
  }&#13;
&#13;
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public {&#13;
    safeTransferFrom(_from, _to, _tokenId, "");&#13;
  }&#13;
&#13;
  function safeTransferFrom(address _from,&#13;
                            address _to,&#13;
                            uint256 _tokenId,&#13;
                            bytes _data)&#13;
    public&#13;
    canTransfer(_tokenId)&#13;
  {&#13;
    transferFrom(_from, _to, _tokenId);&#13;
    require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));&#13;
  }&#13;
&#13;
  function isApprovedOrOwned(address _spender, uint256 _tokenId) internal view returns (bool) {&#13;
&#13;
    address owner = ownerOf(_tokenId);&#13;
&#13;
    return (_spender == owner ||&#13;
            getApproved(_tokenId) == _spender ||&#13;
            isApprovedForAll(owner, _spender));&#13;
  }&#13;
&#13;
  function clearApproval(address _owner, uint256 _tokenId) internal {&#13;
    require(ownerOf(_tokenId) == _owner);&#13;
    if (tokenApprovals[_tokenId] != address(0)) {&#13;
      tokenApprovals[_tokenId] = address(0);&#13;
      emit Approval(_owner, address(0), _tokenId);&#13;
    }&#13;
  }&#13;
&#13;
  function _mint(address _to, uint256 _tokenId) internal {&#13;
    require(_to != address(0));&#13;
    addTokenTo(_to, _tokenId);&#13;
    emit Transfer(address(0), _to, _tokenId);&#13;
&#13;
    allTokensIndex[_tokenId] = allTokens.length;&#13;
    allTokens.push(_tokenId);&#13;
  }&#13;
&#13;
  function addTokenTo(address _to, uint256 _tokenId) internal {&#13;
    require(tokenOwner[_tokenId] == address(0));&#13;
    tokenOwner[_tokenId] = _to;&#13;
    ownedTokensCount[_to] = ownedTokensCount[_to].add(1);&#13;
&#13;
    uint256 length = ownedTokens[_to].length;&#13;
    ownedTokens[_to].push(_tokenId);&#13;
    ownedTokensIndex[_tokenId] = length;&#13;
  }&#13;
&#13;
  function removeTokenFrom(address _from, uint256 _tokenId) internal {&#13;
    require(ownerOf(_tokenId) == _from);&#13;
    ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);&#13;
    tokenOwner[_tokenId] = address(0);&#13;
&#13;
    uint256 tokenIndex = ownedTokensIndex[_tokenId];&#13;
    uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);&#13;
    uint256 lastToken = ownedTokens[_from][lastTokenIndex];&#13;
&#13;
    ownedTokens[_from][tokenIndex] = lastToken;&#13;
    ownedTokens[_from][lastTokenIndex] = 0;&#13;
&#13;
    ownedTokens[_from].length--;&#13;
    ownedTokensIndex[_tokenId] = 0;&#13;
    ownedTokensIndex[lastToken] = tokenIndex;&#13;
  }&#13;
&#13;
  function checkAndCallSafeTransfer(address _from,&#13;
                                    address _to,&#13;
                                    uint256 _tokenId,&#13;
                                    bytes _data)&#13;
    internal&#13;
    returns(bool)&#13;
  {&#13;
    return true;&#13;
  }&#13;
&#13;
  /* AGENT ROLE */&#13;
&#13;
  function addAgent(address _agent) public onlyAdmin {&#13;
    agents[_agent] = true;&#13;
  }&#13;
&#13;
  function removeAgent(address _agent) external onlyAdmin {&#13;
    agents[_agent] = false;&#13;
  }&#13;
&#13;
  function isAgent(address _agent) public view returns (bool) {&#13;
    return agents[_agent];&#13;
  }&#13;
&#13;
  /* CHARACTER LOGIC */&#13;
&#13;
  function getCharacter(uint256 _tokenId)&#13;
    external view returns&#13;
    (uint256 genes,&#13;
     uint256 mintedAt,&#13;
     uint256 godfather,&#13;
     uint256 mentor,&#13;
     uint32 wins,&#13;
     uint32 losses,&#13;
     uint32 level,&#13;
     uint256 lockedTo,&#13;
     uint16 lockId) {&#13;
&#13;
    require(exists(_tokenId));&#13;
&#13;
    Character memory c = characters[tokenCharacters[_tokenId]];&#13;
&#13;
    genes = c.genes;&#13;
    mintedAt = c.mintedAt;&#13;
    godfather = c.godfather;&#13;
    mentor = c.mentor;&#13;
    wins = c.wins;&#13;
    losses = c.losses;&#13;
    level = c.level;&#13;
    lockedTo = c.lockedTo;&#13;
    lockId = c.lockId;&#13;
  }&#13;
&#13;
  function addWin(uint256 _tokenId) external onlyAgent {&#13;
&#13;
    require(exists(_tokenId));&#13;
&#13;
    Character storage character = characters[tokenCharacters[_tokenId]];&#13;
    character.wins++;&#13;
    character.level++;&#13;
&#13;
    emit LevelUp(character.level);&#13;
  }&#13;
&#13;
  function addLoss(uint256 _tokenId) external onlyAgent {&#13;
&#13;
    require(exists(_tokenId));&#13;
&#13;
    Character storage character = characters[tokenCharacters[_tokenId]];&#13;
    character.losses++;&#13;
    if (character.level &gt; 1) {&#13;
      character.level--;&#13;
&#13;
      emit LevelUp(character.level);&#13;
    }&#13;
  }&#13;
&#13;
  /* MINTING */&#13;
&#13;
  function mintTo(address _to,&#13;
                  uint256 _genes,&#13;
                  uint256 _godfather,&#13;
                  uint256 _mentor,&#13;
                  uint32 _level)&#13;
    external&#13;
    onlyAgent&#13;
    returns (uint256)&#13;
  {&#13;
    uint256 newTokenId = totalSupply().add(1);&#13;
    _mint(_to, newTokenId);&#13;
    _mintCharacter(newTokenId, _genes, _godfather, _mentor, _level);&#13;
&#13;
    return newTokenId;&#13;
  }&#13;
&#13;
  function _mintCharacter(uint256 _tokenId,&#13;
                          uint256 _genes,&#13;
                          uint256 _godfather,&#13;
                          uint256 _mentor,&#13;
                          uint32 _level)&#13;
    internal&#13;
  {&#13;
&#13;
    require(exists(_tokenId));&#13;
&#13;
    Character memory character = Character({&#13;
      genes: _genes,&#13;
&#13;
          mintedAt: now,&#13;
          mentor: _mentor,&#13;
          godfather: _godfather,&#13;
&#13;
          wins: 0,&#13;
          losses: 0,&#13;
          level: _level,&#13;
&#13;
          lockedTo: 0,&#13;
          lockId: 0&#13;
          });&#13;
&#13;
    uint256 characterId = characters.push(character) - 1;&#13;
    tokenCharacters[_tokenId] = characterId;&#13;
  }&#13;
&#13;
  /* LOCKS */&#13;
&#13;
  function lock(uint256 _tokenId, uint256 _lockedTo, uint16 _lockId)&#13;
    external onlyAgent returns (bool) {&#13;
&#13;
    require(exists(_tokenId));&#13;
&#13;
    Character storage character = characters[tokenCharacters[_tokenId]];&#13;
&#13;
    if (character.lockId == 0) {&#13;
      character.lockedTo = _lockedTo;&#13;
      character.lockId = _lockId;&#13;
&#13;
      emit Lock(character.lockedTo, character.lockId);&#13;
&#13;
      return true;&#13;
    }&#13;
&#13;
    return false;&#13;
  }&#13;
&#13;
  function unlock(uint256 _tokenId, uint16 _lockId)&#13;
    external onlyAgent returns (bool) {&#13;
&#13;
    require(exists(_tokenId));&#13;
&#13;
    Character storage character = characters[tokenCharacters[_tokenId]];&#13;
&#13;
    if (character.lockId == _lockId) {&#13;
      character.lockedTo = 0;&#13;
      character.lockId = 0;&#13;
&#13;
      emit Lock(character.lockedTo, character.lockId);&#13;
&#13;
      return true;&#13;
    }&#13;
&#13;
    return false;&#13;
  }&#13;
&#13;
  function getLock(uint256 _tokenId)&#13;
    external view returns (uint256 lockedTo, uint16 lockId) {&#13;
&#13;
    require(exists(_tokenId));&#13;
&#13;
    lockedTo = characters[tokenCharacters[_tokenId]].lockedTo;&#13;
    lockId = characters[tokenCharacters[_tokenId]].lockId;&#13;
  }&#13;
&#13;
  function isLocked(uint _tokenId) public view returns (bool) {&#13;
    require(exists(_tokenId));&#13;
    //isLocked workaround: lockedTo должен быть =1 для блокировки трансфер&#13;
    return ((characters[tokenCharacters[_tokenId]].lockedTo == 0 &amp;&amp;&#13;
             characters[tokenCharacters[_tokenId]].lockId != 0) ||&#13;
            now &lt;= characters[tokenCharacters[_tokenId]].lockedTo);&#13;
  }&#13;
&#13;
  function test(uint256 _x) returns (bool) {&#13;
    return now &lt;= _x;&#13;
  }&#13;
}
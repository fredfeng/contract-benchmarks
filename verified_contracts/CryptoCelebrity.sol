pragma solidity ^0.4.18; // solhint-disable-line

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="debabbaabb9ebfa6b7b1b3a4bbb0f0bdb1">[email protected]</a>&gt; (https://github.com/dete)&#13;
contract ERC721 {&#13;
  // Required methods&#13;
  function approve(address _to, uint256 _tokenId) public;&#13;
  function balanceOf(address _owner) public view returns (uint256 balance);&#13;
  function implementsERC721() public pure returns (bool);&#13;
  function ownerOf(uint256 _tokenId) public view returns (address addr);&#13;
  function takeOwnership(uint256 _tokenId) public;&#13;
  function totalSupply() public view returns (uint256 total);&#13;
  function transferFrom(address _from, address _to, uint256 _tokenId) public;&#13;
  function transfer(address _to, uint256 _tokenId) public;&#13;
&#13;
  event Transfer(address indexed from, address indexed to, uint256 tokenId);&#13;
  event Approval(address indexed owner, address indexed approved, uint256 tokenId);&#13;
&#13;
  // Optional&#13;
  // function name() public view returns (string name);&#13;
  // function symbol() public view returns (string symbol);&#13;
  // function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 tokenId);&#13;
  // function tokenMetadata(uint256 _tokenId) public view returns (string infoUrl);&#13;
}&#13;
&#13;
contract CryptoCelebrity is ERC721 {&#13;
&#13;
  /*** EVENTS ***/&#13;
&#13;
  /// @dev The Birth event is fired whenever a new person comes into existence.&#13;
  event Birth(uint256 tokenId, string name, address owner);&#13;
&#13;
  /// @dev The TokenSold event is fired whenever a token is sold.&#13;
  event TokenSold(uint256 tokenId, uint256 oldPrice, uint256 newPrice, address prevOwner, address winner, string name);&#13;
&#13;
  // @dev The PriceChange event is fired whenever a token's price has change.&#13;
  event PriceChange(uint256 tokenId, uint256 oldPrice, uint256 newPrice, string name);&#13;
  &#13;
  /// @dev Transfer event as defined in current draft of ERC721. &#13;
  ///  ownership is assigned, including births.&#13;
  event Transfer(address from, address to, uint256 tokenId);&#13;
&#13;
  /*** CONSTANTS ***/&#13;
&#13;
  /// @notice Name and symbol of the non fungible token, as defined in ERC721.&#13;
  string public constant NAME = "CryptoCelebrity"; // solhint-disable-line&#13;
  string public constant SYMBOL = "CCT"; // solhint-disable-line&#13;
&#13;
  uint256 private startingPrice = 0.001 ether;&#13;
  uint256 private constant PROMO_CREATION_LIMIT = 100000;&#13;
  uint256 private firstStepLimit =  0.053613 ether;&#13;
  uint256 private secondStepLimit = 0.564957 ether;&#13;
&#13;
  /*** STORAGE ***/&#13;
&#13;
  /// @dev A mapping from person IDs to the address that owns them. All persons have&#13;
  ///  some valid owner address.&#13;
  mapping (uint256 =&gt; address) public personIndexToOwner;&#13;
&#13;
  // @dev A mapping from owner address to count of tokens that address owns.&#13;
  //  Used internally inside balanceOf() to resolve ownership count.&#13;
  mapping (address =&gt; uint256) private ownershipTokenCount;&#13;
&#13;
  /// @dev A mapping from PersonIDs to an address that has been approved to call&#13;
  ///  transferFrom(). Each Person can only have one approved address for transfer&#13;
  ///  at any time. A zero value means no approval is outstanding.&#13;
  mapping (uint256 =&gt; address) public personIndexToApproved;&#13;
&#13;
  // @dev A mapping from PersonIDs to the price of the token.&#13;
  mapping (uint256 =&gt; uint256) private personIndexToPrice;&#13;
&#13;
  // The addresses of the accounts (or contracts) that can execute actions within each roles.&#13;
  address public ceoAddress;&#13;
  address public cooAddress;&#13;
&#13;
  uint256 public promoCreatedCount;&#13;
&#13;
  /*** DATATYPES ***/&#13;
  struct Person {&#13;
    string name;&#13;
  }&#13;
&#13;
  Person[] private persons;&#13;
&#13;
  /*** ACCESS MODIFIERS ***/&#13;
  /// @dev Access modifier for CEO-only functionality&#13;
  modifier onlyCEO() {&#13;
    require(msg.sender == ceoAddress);&#13;
    _;&#13;
  }&#13;
&#13;
  /// @dev Access modifier for COO-only functionality&#13;
  modifier onlyCOO() {&#13;
    require(msg.sender == cooAddress);&#13;
    _;&#13;
  }&#13;
&#13;
  /// Access modifier for contract owner only functionality&#13;
  modifier onlyCLevel() {&#13;
    require(&#13;
      msg.sender == ceoAddress ||&#13;
      msg.sender == cooAddress&#13;
    );&#13;
    _;&#13;
  }&#13;
&#13;
  /*** CONSTRUCTOR ***/&#13;
  function CryptoCelebrity() public {&#13;
    ceoAddress = msg.sender;&#13;
    cooAddress = msg.sender;&#13;
  }&#13;
&#13;
  /*** PUBLIC FUNCTIONS ***/&#13;
  /// @notice Grant another address the right to transfer token via takeOwnership() and transferFrom().&#13;
  /// @param _to The address to be granted transfer approval. Pass address(0) to&#13;
  ///  clear all approvals.&#13;
  /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.&#13;
  /// @dev Required for ERC-721 compliance.&#13;
  function approve(&#13;
    address _to,&#13;
    uint256 _tokenId&#13;
  ) public {&#13;
    // Caller must own token.&#13;
    require(_owns(msg.sender, _tokenId));&#13;
&#13;
    personIndexToApproved[_tokenId] = _to;&#13;
&#13;
    Approval(msg.sender, _to, _tokenId);&#13;
  }&#13;
&#13;
  /// For querying balance of a particular account&#13;
  /// @param _owner The address for balance query&#13;
  /// @dev Required for ERC-721 compliance.&#13;
  function balanceOf(address _owner) public view returns (uint256 balance) {&#13;
    return ownershipTokenCount[_owner];&#13;
  }&#13;
&#13;
  /// @dev Creates a new promo Person with the given name, with given _price and assignes it to an address.&#13;
  function createPromoPerson(address _owner, string _name, uint256 _price) public onlyCOO {&#13;
    require(promoCreatedCount &lt; PROMO_CREATION_LIMIT);&#13;
&#13;
    address personOwner = _owner;&#13;
    if (personOwner == address(0)) {&#13;
      personOwner = cooAddress;&#13;
    }&#13;
&#13;
    if (_price &lt;= 0) {&#13;
      _price = startingPrice;&#13;
    }&#13;
&#13;
    promoCreatedCount++;&#13;
    _createPerson(_name, personOwner, _price);&#13;
  }&#13;
&#13;
  /// @dev Creates a new Person with the given name.&#13;
  function createContractPerson(string _name) public onlyCOO {&#13;
    _createPerson(_name, address(this), startingPrice);&#13;
  }&#13;
&#13;
  /// @notice Returns all the relevant information about a specific person.&#13;
  /// @param _tokenId The tokenId of the person of interest.&#13;
  function getPerson(uint256 _tokenId) public view returns (&#13;
    string personName,&#13;
    uint256 sellingPrice,&#13;
    address owner&#13;
  ) {&#13;
    Person storage person = persons[_tokenId];&#13;
    personName = person.name;&#13;
    sellingPrice = personIndexToPrice[_tokenId];&#13;
    owner = personIndexToOwner[_tokenId];&#13;
  }&#13;
&#13;
  function implementsERC721() public pure returns (bool) {&#13;
    return true;&#13;
  }&#13;
&#13;
  /// @dev Required for ERC-721 compliance.&#13;
  function name() public pure returns (string) {&#13;
    return NAME;&#13;
  }&#13;
&#13;
  /// For querying owner of token&#13;
  /// @param _tokenId The tokenID for owner inquiry&#13;
  /// @dev Required for ERC-721 compliance.&#13;
  function ownerOf(uint256 _tokenId)&#13;
    public&#13;
    view&#13;
    returns (address owner)&#13;
  {&#13;
    owner = personIndexToOwner[_tokenId];&#13;
    require(owner != address(0));&#13;
  }&#13;
&#13;
  function payout(address _to) public onlyCLevel {&#13;
    _payout(_to);&#13;
  }&#13;
&#13;
  function withdrawAmountTo (uint256 _amount, address _to) public onlyCLevel {&#13;
    _to.transfer(_amount);&#13;
  }&#13;
&#13;
  // Allows someone to send ether and obtain the token&#13;
  function purchase(uint256 _tokenId) public payable {&#13;
    address oldOwner = personIndexToOwner[_tokenId];&#13;
    address newOwner = msg.sender;&#13;
&#13;
    uint256 sellingPrice = personIndexToPrice[_tokenId];&#13;
&#13;
    // Making sure token owner is not sending to self&#13;
    require(oldOwner != newOwner);&#13;
&#13;
    // Safety check to prevent against an unexpected 0x0 default.&#13;
    require(_addressNotNull(newOwner));&#13;
&#13;
    // Making sure sent amount is greater than or equal to the sellingPrice&#13;
    require(msg.value &gt;= sellingPrice);&#13;
&#13;
    uint256 payment = uint256(SafeMath.div(SafeMath.mul(sellingPrice, 90), 100));&#13;
    uint256 fee = uint256(SafeMath.div(SafeMath.mul(sellingPrice, 99), 1000));&#13;
    uint256 purchaseExcess = SafeMath.sub(msg.value, sellingPrice);&#13;
&#13;
    // Update prices&#13;
    if (sellingPrice &lt; firstStepLimit) {&#13;
      // first stage&#13;
      personIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 200), 94);&#13;
    } else if (sellingPrice &lt; secondStepLimit) {&#13;
      // second stage&#13;
      personIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 120), 94);&#13;
    } else {&#13;
      // third stage&#13;
      personIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 115), 94);&#13;
    }&#13;
&#13;
    _transfer(oldOwner, newOwner, _tokenId);&#13;
&#13;
    // Pay previous tokenOwner if owner is not contract&#13;
    if (oldOwner != address(this)) {&#13;
      oldOwner.transfer(payment); //(1-0.10)&#13;
      ceoAddress.transfer(fee); //0.099&#13;
    }&#13;
&#13;
    TokenSold(_tokenId, sellingPrice, personIndexToPrice[_tokenId], oldOwner, newOwner, persons[_tokenId].name);&#13;
&#13;
    msg.sender.transfer(purchaseExcess);&#13;
  }&#13;
&#13;
  /// @notice Allow the owner of the token change the price of the person.&#13;
  /// @param _tokenId The ID of the Token.&#13;
  /// @param newPrice New price of the token&#13;
  function changePrice(uint256 _tokenId, uint256 newPrice) public {&#13;
    require(_owns(msg.sender, _tokenId));&#13;
    uint256 oldPrice = personIndexToPrice[_tokenId];&#13;
    uint256 maxPrice = uint256(SafeMath.mul(oldPrice, 5));&#13;
    uint256 minPrice = startingPrice;&#13;
    require (minPrice &lt; newPrice &amp;&amp; newPrice &lt; maxPrice);&#13;
    // Update prices&#13;
    personIndexToPrice[_tokenId] = newPrice;&#13;
    PriceChange(_tokenId, oldPrice, newPrice, persons[_tokenId].name);&#13;
  }&#13;
&#13;
  function priceOf(uint256 _tokenId) public view returns (uint256 price) {&#13;
    return personIndexToPrice[_tokenId];&#13;
  }&#13;
&#13;
  /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.&#13;
  /// @param _newCEO The address of the new CEO&#13;
  function setCEO(address _newCEO) public onlyCEO {&#13;
    require(_newCEO != address(0));&#13;
&#13;
    ceoAddress = _newCEO;&#13;
  }&#13;
&#13;
  /// @dev Assigns a new address to act as the COO. Only available to the current COO.&#13;
  /// @param _newCOO The address of the new COO&#13;
  function setCOO(address _newCOO) public onlyCEO {&#13;
    require(_newCOO != address(0));&#13;
&#13;
    cooAddress = _newCOO;&#13;
  }&#13;
&#13;
  /// @dev Required for ERC-721 compliance.&#13;
  function symbol() public pure returns (string) {&#13;
    return SYMBOL;&#13;
  }&#13;
&#13;
  /// @notice Allow pre-approved user to take ownership of a token&#13;
  /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.&#13;
  /// @dev Required for ERC-721 compliance.&#13;
  function takeOwnership(uint256 _tokenId) public {&#13;
    address newOwner = msg.sender;&#13;
    address oldOwner = personIndexToOwner[_tokenId];&#13;
&#13;
    // Safety check to prevent against an unexpected 0x0 default.&#13;
    require(_addressNotNull(newOwner));&#13;
&#13;
    // Making sure transfer is approved&#13;
    require(_approved(newOwner, _tokenId));&#13;
&#13;
    _transfer(oldOwner, newOwner, _tokenId);&#13;
  }&#13;
&#13;
  /// @param _owner The owner whose celebrity tokens we are interested in.&#13;
  /// @dev This method MUST NEVER be called by smart contract code. First, it's fairly&#13;
  ///  expensive (it walks the entire Persons array looking for persons belonging to owner),&#13;
  ///  but it also returns a dynamic array, which is only supported for web3 calls, and&#13;
  ///  not contract-to-contract calls.&#13;
  function tokensOfOwner(address _owner) public view returns(uint256[] ownerTokens) {&#13;
    uint256 tokenCount = balanceOf(_owner);&#13;
    if (tokenCount == 0) {&#13;
        // Return an empty array&#13;
      return new uint256[](0);&#13;
    } else {&#13;
      uint256[] memory result = new uint256[](tokenCount);&#13;
      uint256 totalPersons = totalSupply();&#13;
      uint256 resultIndex = 0;&#13;
&#13;
      uint256 personId;&#13;
      for (personId = 0; personId &lt;= totalPersons; personId++) {&#13;
        if (personIndexToOwner[personId] == _owner) {&#13;
          result[resultIndex] = personId;&#13;
          resultIndex++;&#13;
        }&#13;
      }&#13;
      return result;&#13;
    }&#13;
  }&#13;
&#13;
  /// For querying totalSupply of token&#13;
  /// @dev Required for ERC-721 compliance.&#13;
  function totalSupply() public view returns (uint256 total) {&#13;
    return persons.length;&#13;
  }&#13;
&#13;
  /// Owner initates the transfer of the token to another account&#13;
  /// @param _to The address for the token to be transferred to.&#13;
  /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.&#13;
  /// @dev Required for ERC-721 compliance.&#13;
  function transfer(&#13;
    address _to,&#13;
    uint256 _tokenId&#13;
  ) public {&#13;
    require(_owns(msg.sender, _tokenId));&#13;
    require(_addressNotNull(_to));&#13;
&#13;
    _transfer(msg.sender, _to, _tokenId);&#13;
  }&#13;
&#13;
  /// Third-party initiates transfer of token from address _from to address _to&#13;
  /// @param _from The address for the token to be transferred from.&#13;
  /// @param _to The address for the token to be transferred to.&#13;
  /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.&#13;
  /// @dev Required for ERC-721 compliance.&#13;
  function transferFrom(&#13;
    address _from,&#13;
    address _to,&#13;
    uint256 _tokenId&#13;
  ) public {&#13;
    require(_owns(_from, _tokenId));&#13;
    require(_approved(_to, _tokenId));&#13;
    require(_addressNotNull(_to));&#13;
&#13;
    _transfer(_from, _to, _tokenId);&#13;
  }&#13;
&#13;
  /*** PRIVATE FUNCTIONS ***/&#13;
  /// Safety check on _to address to prevent against an unexpected 0x0 default.&#13;
  function _addressNotNull(address _to) private pure returns (bool) {&#13;
    return _to != address(0);&#13;
  }&#13;
&#13;
  /// For checking approval of transfer for address _to&#13;
  function _approved(address _to, uint256 _tokenId) private view returns (bool) {&#13;
    return personIndexToApproved[_tokenId] == _to;&#13;
  }&#13;
&#13;
  /// For creating Person&#13;
  function _createPerson(string _name, address _owner, uint256 _price) private {&#13;
    Person memory _person = Person({&#13;
      name: _name&#13;
    });&#13;
    uint256 newPersonId = persons.push(_person) - 1;&#13;
&#13;
    // It's probably never going to happen, 4 billion tokens are A LOT, but&#13;
    // let's just be 100% sure we never let this happen.&#13;
    require(newPersonId == uint256(uint32(newPersonId)));&#13;
&#13;
    Birth(newPersonId, _name, _owner);&#13;
&#13;
    personIndexToPrice[newPersonId] = _price;&#13;
&#13;
    // This will assign ownership, and also emit the Transfer event as&#13;
    // per ERC721 draft&#13;
    _transfer(address(0), _owner, newPersonId);&#13;
  }&#13;
&#13;
  /// Check for token ownership&#13;
  function _owns(address claimant, uint256 _tokenId) private view returns (bool) {&#13;
    return claimant == personIndexToOwner[_tokenId];&#13;
  }&#13;
&#13;
  /// For paying out balance on contract&#13;
  function _payout(address _to) private {&#13;
    if (_to == address(0)) {&#13;
      ceoAddress.transfer(this.balance);&#13;
    } else {&#13;
      _to.transfer(this.balance);&#13;
    }&#13;
  }&#13;
&#13;
  /// @dev Assigns ownership of a specific Person to an address.&#13;
  function _transfer(address _from, address _to, uint256 _tokenId) private {&#13;
    // Since the number of persons is capped to 2^32 we can't overflow this&#13;
    ownershipTokenCount[_to]++;&#13;
    //transfer ownership&#13;
    personIndexToOwner[_tokenId] = _to;&#13;
&#13;
    // When creating new persons _from is 0x0, but we can't account that address.&#13;
    if (_from != address(0)) {&#13;
      ownershipTokenCount[_from]--;&#13;
      // clear any previously approved ownership exchange&#13;
      delete personIndexToApproved[_tokenId];&#13;
    }&#13;
&#13;
    // Emit the transfer event.&#13;
    Transfer(_from, _to, _tokenId);&#13;
  }&#13;
}&#13;
library SafeMath {&#13;
&#13;
  /**&#13;
  * @dev Multiplies two numbers, throws on overflow.&#13;
  */&#13;
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    if (a == 0) {&#13;
      return 0;&#13;
    }&#13;
    uint256 c = a * b;&#13;
    assert(c / a == b);&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Integer division of two numbers, truncating the quotient.&#13;
  */&#13;
  function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    uint256 c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).&#13;
  */&#13;
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Adds two numbers, throws on overflow.&#13;
  */&#13;
  function add(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    uint256 c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
}
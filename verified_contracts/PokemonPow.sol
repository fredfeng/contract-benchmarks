pragma solidity ^0.4.18; // solhint-disable-line



/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="4f2b2a3b2a0f2e37262022352a21612c20">[email protected]</a>&gt; (https://github.com/dete)&#13;
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
&#13;
contract PokemonPow is ERC721 {&#13;
&#13;
  address cryptoVideoGames = 0xdEc14D8f4DA25108Fd0d32Bf2DeCD9538564D069; &#13;
  address cryptoVideoGameItems = 0xD2606C9bC5EFE092A8925e7d6Ae2F63a84c5FDEa;&#13;
&#13;
  /*** EVENTS ***/&#13;
&#13;
  /// @dev The Birth event is fired whenever a new pow comes into existence.&#13;
  event Birth(uint256 tokenId, string name, address owner);&#13;
&#13;
  /// @dev The TokenSold event is fired whenever a token is sold.&#13;
  event TokenSold(uint256 tokenId, uint256 oldPrice, uint256 newPrice, address prevOwner, address winner, string name);&#13;
&#13;
  /// @dev Transfer event as defined in current draft of ERC721. &#13;
  ///  ownership is assigned, including births.&#13;
  event Transfer(address from, address to, uint256 tokenId);&#13;
&#13;
  /*** CONSTANTS ***/&#13;
&#13;
  /// @notice Name and symbol of the non fungible token, as defined in ERC721.&#13;
  string public constant NAME = "CryptoKotakuPokemonPow"; // solhint-disable-line&#13;
  string public constant SYMBOL = "PokemonPow"; // solhint-disable-line&#13;
&#13;
  uint256 private startingPrice = 0.005 ether;&#13;
  uint256 private firstStepLimit =  0.05 ether;&#13;
  uint256 private secondStepLimit = 0.5 ether;&#13;
&#13;
  /*** STORAGE ***/&#13;
&#13;
  /// @dev A mapping from pow IDs to the address that owns them. All pows have&#13;
  ///  some valid owner address.&#13;
  mapping (uint256 =&gt; address) public powIndexToOwner;&#13;
&#13;
  // @dev A mapping from owner address to count of tokens that address owns.&#13;
  //  Used internally inside balanceOf() to resolve ownership count.&#13;
  mapping (address =&gt; uint256) private ownershipTokenCount;&#13;
&#13;
  /// @dev A mapping from PowIDs to an address that has been approved to call&#13;
  ///  transferFrom(). Each Pow can only have one approved address for transfer&#13;
  ///  at any time. A zero value means no approval is outstanding.&#13;
  mapping (uint256 =&gt; address) public powIndexToApproved;&#13;
&#13;
  // @dev A mapping from PowIDs to the price of the token.&#13;
  mapping (uint256 =&gt; uint256) private powIndexToPrice;&#13;
&#13;
  // The addresses of the accounts (or contracts) that can execute actions within each roles.&#13;
  address public ceoAddress;&#13;
  address public cooAddress;&#13;
&#13;
  uint256 public promoCreatedCount;&#13;
&#13;
  /*** DATATYPES ***/&#13;
  struct Pow {&#13;
    string name;&#13;
    uint gameId;&#13;
    uint gameItemId1;&#13;
    uint gameItemId2;&#13;
  }&#13;
&#13;
  Pow[] private pows;&#13;
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
  function PokemonPow() public {&#13;
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
    powIndexToApproved[_tokenId] = _to;&#13;
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
  /// @dev Creates a new promo Pow with the given name, with given _price and assignes it to an address.&#13;
  function createPromoPow(address _owner, string _name, uint256 _price, uint _gameId, uint _gameItemId1, uint _gameItemId2) public onlyCOO {&#13;
&#13;
    address powOwner = _owner;&#13;
    if (powOwner == address(0)) {&#13;
      powOwner = cooAddress;&#13;
    }&#13;
&#13;
    if (_price &lt;= 0) {&#13;
      _price = startingPrice;&#13;
    }&#13;
&#13;
    promoCreatedCount++;&#13;
    _createPow(_name, powOwner, _price, _gameId, _gameItemId1, _gameItemId2);&#13;
  }&#13;
&#13;
  /// @dev Creates a new Pow with the given name.&#13;
  function createContractPow(string _name, uint _gameId, uint _gameItemId1, uint _gameItemId2) public onlyCOO {&#13;
    _createPow(_name, address(this), startingPrice, _gameId, _gameItemId1, _gameItemId2);&#13;
  }&#13;
&#13;
  /// @notice Returns all the relevant information about a specific pow.&#13;
  /// @param _tokenId The tokenId of the pow of interest.&#13;
  function getPow(uint256 _tokenId) public view returns (&#13;
    uint256 Id,&#13;
    string powName,&#13;
    uint256 sellingPrice,&#13;
    address owner,&#13;
    uint gameId,&#13;
    uint gameItemId1,&#13;
    uint gameItemId2&#13;
  ) {&#13;
    Pow storage pow = pows[_tokenId];&#13;
    Id = _tokenId;&#13;
    powName = pow.name;&#13;
    sellingPrice = powIndexToPrice[_tokenId];&#13;
    owner = powIndexToOwner[_tokenId];&#13;
    gameId = pow.gameId;&#13;
    gameItemId1 = pow.gameItemId1;&#13;
    gameItemId2 = pow.gameItemId2;&#13;
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
    owner = powIndexToOwner[_tokenId];&#13;
    require(owner != address(0));&#13;
  }&#13;
&#13;
  function payout(address _to) public onlyCLevel {&#13;
    _payout(_to);&#13;
  }&#13;
&#13;
  // Allows someone to send ether and obtain the token&#13;
  function purchase(uint256 _tokenId) public payable {&#13;
    address oldOwner = powIndexToOwner[_tokenId];&#13;
    address newOwner = msg.sender;&#13;
&#13;
    uint256 sellingPrice = powIndexToPrice[_tokenId];&#13;
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
    uint256 gameOwnerPayment = uint256(SafeMath.div(SafeMath.mul(sellingPrice, 5), 100));&#13;
    uint256 gameItemOwnerPayment = uint256(SafeMath.div(SafeMath.mul(sellingPrice, 5), 100));&#13;
    uint256 payment =  sellingPrice - gameOwnerPayment - gameOwnerPayment - gameItemOwnerPayment - gameItemOwnerPayment;&#13;
    uint256 purchaseExcess = SafeMath.sub(msg.value,sellingPrice);&#13;
&#13;
    // Update prices&#13;
    if (sellingPrice &lt; firstStepLimit) {&#13;
      // first stage&#13;
      powIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 200), 100);&#13;
    } else if (sellingPrice &lt; secondStepLimit) {&#13;
      // second stage&#13;
      powIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 180), 100);&#13;
    } else {&#13;
      // third stage&#13;
      powIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 150), 100);&#13;
    }&#13;
&#13;
    _transfer(oldOwner, newOwner, _tokenId);&#13;
    TokenSold(_tokenId, sellingPrice, powIndexToPrice[_tokenId], oldOwner, newOwner, pows[_tokenId].name);&#13;
&#13;
    // Pay previous tokenOwner if owner is not contract&#13;
    if (oldOwner != address(this)) {&#13;
      oldOwner.transfer(payment); //(1-0.2)&#13;
    }&#13;
    &#13;
    msg.sender.transfer(purchaseExcess);&#13;
    _transferDivs(gameOwnerPayment, gameItemOwnerPayment, _tokenId);&#13;
    &#13;
  }&#13;
&#13;
  /// Divident distributions&#13;
  function _transferDivs(uint256 _gameOwnerPayment, uint256 _gameItemOwnerPayment, uint256 _tokenId) private {&#13;
    CryptoVideoGames gamesContract = CryptoVideoGames(cryptoVideoGames);&#13;
    CryptoVideoGameItem gameItemContract = CryptoVideoGameItem(cryptoVideoGameItems);&#13;
    address gameOwner = gamesContract.getVideoGameOwner(pows[_tokenId].gameId);&#13;
    address gameItem1Owner = gameItemContract.getVideoGameItemOwner(pows[_tokenId].gameItemId1);&#13;
    address gameItem2Owner = gameItemContract.getVideoGameItemOwner(pows[_tokenId].gameItemId2);&#13;
    gameOwner.transfer(_gameOwnerPayment);&#13;
    gameItem1Owner.transfer(_gameItemOwnerPayment);&#13;
    gameItem2Owner.transfer(_gameItemOwnerPayment);&#13;
  }&#13;
&#13;
  function priceOf(uint256 _tokenId) public view returns (uint256 price) {&#13;
    return powIndexToPrice[_tokenId];&#13;
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
    address oldOwner = powIndexToOwner[_tokenId];&#13;
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
  /// @param _owner The owner whose pow tokens we are interested in.&#13;
  /// @dev This method MUST NEVER be called by smart contract code. First, it's fairly&#13;
  ///  expensive (it walks the entire pows array looking for pows belonging to owner),&#13;
  ///  but it also returns a dynamic array, which is only supported for web3 calls, and&#13;
  ///  not contract-to-contract calls.&#13;
  function tokensOfOwner(address _owner) public view returns(uint256[] ownerTokens) {&#13;
    uint256 tokenCount = balanceOf(_owner);&#13;
    if (tokenCount == 0) {&#13;
        // Return an empty array&#13;
      return new uint256[](0);&#13;
    } else {&#13;
      uint256[] memory result = new uint256[](tokenCount);&#13;
      uint256 totalPows = totalSupply();&#13;
      uint256 resultIndex = 0;&#13;
&#13;
      uint256 powId;&#13;
      for (powId = 0; powId &lt;= totalPows; powId++) {&#13;
        if (powIndexToOwner[powId] == _owner) {&#13;
          result[resultIndex] = powId;&#13;
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
    return pows.length;&#13;
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
    return powIndexToApproved[_tokenId] == _to;&#13;
  }&#13;
&#13;
  /// For creating Pow&#13;
  function _createPow(string _name, address _owner, uint256 _price, uint _gameId, uint _gameItemId1, uint _gameItemId2) private {&#13;
    Pow memory _pow = Pow({&#13;
      name: _name,&#13;
      gameId: _gameId,&#13;
      gameItemId1: _gameItemId1,&#13;
      gameItemId2: _gameItemId2&#13;
    });&#13;
    uint256 newPowId = pows.push(_pow) - 1;&#13;
&#13;
    // It's probably never going to happen, 4 billion tokens are A LOT, but&#13;
    // let's just be 100% sure we never let this happen.&#13;
    require(newPowId == uint256(uint32(newPowId)));&#13;
&#13;
    Birth(newPowId, _name, _owner);&#13;
&#13;
    powIndexToPrice[newPowId] = _price;&#13;
&#13;
    // This will assign ownership, and also emit the Transfer event as&#13;
    // per ERC721 draft&#13;
    _transfer(address(0), _owner, newPowId);&#13;
  }&#13;
&#13;
  /// Check for token ownership&#13;
  function _owns(address claimant, uint256 _tokenId) private view returns (bool) {&#13;
    return claimant == powIndexToOwner[_tokenId];&#13;
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
  /*&#13;
  This function can be used by the owner of a pow item to modify the price of its pow item.&#13;
  */&#13;
  function modifyPowPrice(uint _powId, uint256 _newPrice) public {&#13;
      require(_newPrice &gt; 0);&#13;
      require(powIndexToOwner[_powId] == msg.sender);&#13;
      powIndexToPrice[_powId] = _newPrice;&#13;
  }&#13;
&#13;
  /// @dev Assigns ownership of a specific Pow to an address.&#13;
  function _transfer(address _from, address _to, uint256 _tokenId) private {&#13;
    // Since the number of pow is capped to 2^32 we can't overflow this&#13;
    ownershipTokenCount[_to]++;&#13;
    //transfer ownership&#13;
    powIndexToOwner[_tokenId] = _to;&#13;
&#13;
    // When creating new pows _from is 0x0, but we can't account that address.&#13;
    if (_from != address(0)) {&#13;
      ownershipTokenCount[_from]--;&#13;
      // clear any previously approved ownership exchange&#13;
      delete powIndexToApproved[_tokenId];&#13;
    }&#13;
&#13;
    // Emit the transfer event.&#13;
    Transfer(_from, _to, _tokenId);&#13;
  }&#13;
&#13;
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
&#13;
}&#13;
&#13;
&#13;
contract CryptoVideoGames {&#13;
    // This function will return only the owner address of a specific Video Game&#13;
    function getVideoGameOwner(uint _videoGameId) public view returns(address) {&#13;
    }&#13;
    &#13;
}&#13;
&#13;
&#13;
contract CryptoVideoGameItem {&#13;
  function getVideoGameItemOwner(uint _videoGameItemId) public view returns(address) {&#13;
    }&#13;
}
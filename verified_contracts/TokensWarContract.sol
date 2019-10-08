pragma solidity ^0.4.19;


/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="224647564762435a4b4d4f58474c0c414d">[email protected]</a>&gt; (https://github.com/dete)&#13;
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
contract Ownable {&#13;
    &#13;
	  // The addresses of the accounts (or contracts) that can execute actions within each roles.&#13;
	address public hostAddress;&#13;
	address public adminAddress;&#13;
    &#13;
    function Ownable() public {&#13;
		hostAddress = msg.sender;&#13;
		adminAddress = msg.sender;&#13;
    }&#13;
&#13;
    modifier onlyHost() {&#13;
        require(msg.sender == hostAddress); &#13;
        _;&#13;
    }&#13;
	&#13;
    modifier onlyAdmin() {&#13;
        require(msg.sender == adminAddress);&#13;
        _;&#13;
    }&#13;
	&#13;
	/// Access modifier for contract owner only functionality&#13;
	modifier onlyHostOrAdmin() {&#13;
		require(&#13;
		  msg.sender == hostAddress ||&#13;
		  msg.sender == adminAddress&#13;
		);&#13;
		_;&#13;
	}&#13;
&#13;
	function setHost(address _newHost) public onlyHost {&#13;
		require(_newHost != address(0));&#13;
&#13;
		hostAddress = _newHost;&#13;
	}&#13;
    &#13;
	function setAdmin(address _newAdmin) public onlyHost {&#13;
		require(_newAdmin != address(0));&#13;
&#13;
		adminAddress = _newAdmin;&#13;
	}&#13;
}&#13;
&#13;
contract TokensWarContract is ERC721, Ownable {&#13;
        &#13;
    /*** EVENTS ***/&#13;
        &#13;
    /// @dev The NewHero event is fired whenever a new card comes into existence.&#13;
    event NewToken(uint256 tokenId, string name, address owner);&#13;
        &#13;
    /// @dev The NewTokenOwner event is fired whenever a token is sold.&#13;
    event NewTokenOwner(uint256 oldPrice, uint256 newPrice, address prevOwner, address winner, string name, uint256 tokenId);&#13;
    &#13;
    /// @dev The NewGoldenCard event is fired whenever a golden card is change.&#13;
    event NewGoldenToken(uint256 goldenPayment);&#13;
        &#13;
    /// @dev Transfer event as defined in current draft of ERC721. ownership is assigned, including births.&#13;
    event Transfer(address from, address to, uint256 tokenId);&#13;
        &#13;
    /*** CONSTANTS ***/&#13;
        &#13;
    /// @notice Name and symbol of the non fungible token, as defined in ERC721.&#13;
    string public constant NAME = "TokensWarContract"; // solhint-disable-line&#13;
    string public constant SYMBOL = "TWC"; // solhint-disable-line&#13;
      &#13;
    uint256 private startingPrice = 0.001 ether; &#13;
    uint256 private firstStepLimit =  0.045 ether; //5 iteration&#13;
    uint256 private secondStepLimit =  0.45 ether; //8 iteration&#13;
    uint256 private thirdStepLimit = 1.00 ether; //10 iteration&#13;
        &#13;
    /*** STORAGE ***/&#13;
        &#13;
    /// @dev A mapping from card IDs to the address that owns them. All cards have&#13;
    ///  some valid owner address.&#13;
    mapping (uint256 =&gt; address) public cardTokenToOwner;&#13;
        &#13;
    // @dev A mapping from owner address to count of tokens that address owns.&#13;
    //  Used internally inside balanceOf() to resolve ownership count.&#13;
    mapping (address =&gt; uint256) private ownershipTokenCount;&#13;
        &#13;
    /// @dev A mapping from CardIDs to an address that has been approved to call&#13;
    ///  transferFrom(). Each card can only have one approved address for transfer&#13;
    ///  at any time. A zero value means no approval is outstanding.&#13;
    mapping (uint256 =&gt; address) public cardTokenToApproved;&#13;
        &#13;
    // @dev A mapping from CardIDs to the price of the token.&#13;
    mapping (uint256 =&gt; uint256) private cardTokenToPrice;&#13;
        &#13;
    // @dev A mapping from CardIDs to the position of the item in array.&#13;
    mapping (uint256 =&gt; uint256) private cardTokenToPosition;&#13;
    &#13;
    // @dev tokenId of golden card.&#13;
    uint256 public goldenTokenId;&#13;
    &#13;
    /*** STORAGE ***/&#13;
    &#13;
	/*** ------------------------------- ***/&#13;
    &#13;
    /*** CARDS ***/&#13;
    &#13;
	/*** DATATYPES ***/&#13;
	struct Card {&#13;
		uint256 token;&#13;
		string name;&#13;
	}&#13;
&#13;
	Card[] private cards;&#13;
    &#13;
	&#13;
	/// @notice Returns all the relevant information about a specific card.&#13;
	/// @param _tokenId The tokenId of the card of interest.&#13;
	function getCard(uint256 _tokenId) public view returns (&#13;
		string name,&#13;
		uint256 token&#13;
	) {&#13;
	    &#13;
	    address owner = cardTokenToOwner[_tokenId];&#13;
        require(owner != address(0));&#13;
	    &#13;
	    uint256 index = cardTokenToPosition[_tokenId];&#13;
	    Card storage card = cards[index];&#13;
		name = card.name;&#13;
		token = card.token;&#13;
	}&#13;
    &#13;
    /// @dev Creates a new token with the given name.&#13;
	function createToken(string _name, uint256 _id) public onlyAdmin {&#13;
		_createToken(_name, _id, address(this), startingPrice);&#13;
	}&#13;
	&#13;
    /// @dev set golden card token.&#13;
	function setGoldenCardToken(uint256 tokenId) public onlyAdmin {&#13;
		goldenTokenId = tokenId;&#13;
		NewGoldenToken(goldenTokenId);&#13;
	}&#13;
	&#13;
	function _createToken(string _name, uint256 _id, address _owner, uint256 _price) private {&#13;
	    &#13;
		Card memory _card = Card({&#13;
		  name: _name,&#13;
		  token: _id&#13;
		});&#13;
			&#13;
		uint256 index = cards.push(_card) - 1;&#13;
		cardTokenToPosition[_id] = index;&#13;
		// It's probably never going to happen, 4 billion tokens are A LOT, but&#13;
		// let's just be 100% sure we never let this happen.&#13;
		require(_id == uint256(uint32(_id)));&#13;
&#13;
		NewToken(_id, _name, _owner);&#13;
		cardTokenToPrice[_id] = _price;&#13;
		// This will assign ownership, and also emit the Transfer event as&#13;
		// per ERC721 draft&#13;
		_transfer(address(0), _owner, _id);&#13;
	}&#13;
	/*** CARDS ***/&#13;
	&#13;
	/*** ------------------------------- ***/&#13;
	&#13;
	/*** ERC721 FUNCTIONS ***/&#13;
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
        cardTokenToApproved[_tokenId] = _to;&#13;
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
    function implementsERC721() public pure returns (bool) {&#13;
        return true;&#13;
    }&#13;
    &#13;
&#13;
    /// For querying owner of token&#13;
    /// @param _tokenId The tokenID for owner inquiry&#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function ownerOf(uint256 _tokenId) public view returns (address owner) {&#13;
        owner = cardTokenToOwner[_tokenId];&#13;
        require(owner != address(0));&#13;
    }&#13;
    &#13;
    /// @notice Allow pre-approved user to take ownership of a token&#13;
    /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.&#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function takeOwnership(uint256 _tokenId) public {&#13;
        address newOwner = msg.sender;&#13;
        address oldOwner = cardTokenToOwner[_tokenId];&#13;
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
    /// For querying totalSupply of token&#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function totalSupply() public view returns (uint256 total) {&#13;
        return cards.length;&#13;
    }&#13;
    &#13;
    /// Third-party initiates transfer of token from address _from to address _to&#13;
    /// @param _from The address for the token to be transferred from.&#13;
    /// @param _to The address for the token to be transferred to.&#13;
    /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.&#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function transferFrom(address _from, address _to, uint256 _tokenId) public {&#13;
        require(_owns(_from, _tokenId));&#13;
        require(_approved(_to, _tokenId));&#13;
        require(_addressNotNull(_to));&#13;
    &#13;
        _transfer(_from, _to, _tokenId);&#13;
    }&#13;
&#13;
    /// Owner initates the transfer of the token to another account&#13;
    /// @param _to The address for the token to be transferred to.&#13;
    /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.&#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function transfer(address _to, uint256 _tokenId) public {&#13;
        require(_owns(msg.sender, _tokenId));&#13;
        require(_addressNotNull(_to));&#13;
    &#13;
        _transfer(msg.sender, _to, _tokenId);&#13;
    }&#13;
    &#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function name() public pure returns (string) {&#13;
        return NAME;&#13;
    }&#13;
    &#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function symbol() public pure returns (string) {&#13;
        return SYMBOL;&#13;
    }&#13;
&#13;
	/*** ERC721 FUNCTIONS ***/&#13;
	&#13;
	/*** ------------------------------- ***/&#13;
	&#13;
	/*** ADMINISTRATOR FUNCTIONS ***/&#13;
	&#13;
	//send balance of contract on wallet&#13;
	function payout(address _to) public onlyHostOrAdmin {&#13;
		_payout(_to);&#13;
	}&#13;
	&#13;
	function _payout(address _to) private {&#13;
		if (_to == address(0)) {&#13;
			hostAddress.transfer(this.balance);&#13;
		} else {&#13;
			_to.transfer(this.balance);&#13;
		}&#13;
	}&#13;
	&#13;
	/*** ADMINISTRATOR FUNCTIONS ***/&#13;
	&#13;
&#13;
    /*** PUBLIC FUNCTIONS ***/&#13;
&#13;
    function contractBalance() public  view returns (uint256 balance) {&#13;
        return address(this).balance;&#13;
    }&#13;
    &#13;
&#13;
&#13;
  // Allows someone to send ether and obtain the token&#13;
  function purchase(uint256 _tokenId) public payable {&#13;
    address oldOwner = cardTokenToOwner[_tokenId];&#13;
    address newOwner = msg.sender;&#13;
    &#13;
    require(oldOwner != address(0));&#13;
&#13;
    uint256 sellingPrice = cardTokenToPrice[_tokenId];&#13;
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
    uint256 payment = uint256(Helper.div(Helper.mul(sellingPrice, 93), 100));&#13;
    uint256 goldenPayment = uint256(Helper.div(Helper.mul(sellingPrice, 2), 100));&#13;
    &#13;
    uint256 purchaseExcess = Helper.sub(msg.value, sellingPrice);&#13;
&#13;
    // Update prices&#13;
    if (sellingPrice &lt; firstStepLimit) {&#13;
      // first stage&#13;
      cardTokenToPrice[_tokenId] = Helper.div(Helper.mul(sellingPrice, 300), 93);&#13;
    } else if (sellingPrice &lt; secondStepLimit) {&#13;
      // second stage&#13;
      cardTokenToPrice[_tokenId] = Helper.div(Helper.mul(sellingPrice, 200), 93);&#13;
    } else if (sellingPrice &lt; thirdStepLimit) {&#13;
      // second stage&#13;
      cardTokenToPrice[_tokenId] = Helper.div(Helper.mul(sellingPrice, 120), 93);&#13;
    } else {&#13;
      // third stage&#13;
      cardTokenToPrice[_tokenId] = Helper.div(Helper.mul(sellingPrice, 115), 93);&#13;
    }&#13;
&#13;
    _transfer(oldOwner, newOwner, _tokenId);&#13;
&#13;
    // Pay previous tokenOwner if owner is not contract&#13;
    if (oldOwner != address(this)) {&#13;
      oldOwner.transfer(payment); //-0.05&#13;
    }&#13;
    &#13;
    //Pay golden commission&#13;
    address goldenOwner = cardTokenToOwner[goldenTokenId];&#13;
    if (goldenOwner != address(0)) {&#13;
      goldenOwner.transfer(goldenPayment); //-0.02&#13;
    }&#13;
&#13;
	//CONTRACT EVENT &#13;
	uint256 index = cardTokenToPosition[_tokenId];&#13;
    NewTokenOwner(sellingPrice, cardTokenToPrice[_tokenId], oldOwner, newOwner, cards[index].name, _tokenId);&#13;
&#13;
    msg.sender.transfer(purchaseExcess);&#13;
    &#13;
  }&#13;
&#13;
  function priceOf(uint256 _tokenId) public view returns (uint256 price) {&#13;
    return cardTokenToPrice[_tokenId];&#13;
  }&#13;
&#13;
&#13;
&#13;
  /// @param _owner The owner whose celebrity tokens we are interested in.&#13;
  /// @dev This method MUST NEVER be called by smart contract code. First, it's fairly&#13;
  ///  expensive (it walks the entire cards array looking for cards belonging to owner),&#13;
  ///  but it also returns a dynamic array, which is only supported for web3 calls, and&#13;
  ///  not contract-to-contract calls.&#13;
  function tokensOfOwner(address _owner) public view returns(uint256[] ownerTokens) {&#13;
    uint256 tokenCount = balanceOf(_owner);&#13;
    if (tokenCount == 0) {&#13;
        // Return an empty array&#13;
      return new uint256[](0);&#13;
    } else {&#13;
      uint256[] memory result = new uint256[](tokenCount);&#13;
      uint256 totalCards = totalSupply();&#13;
      uint256 resultIndex = 0;&#13;
&#13;
      uint256 index;&#13;
      for (index = 0; index &lt;= totalCards-1; index++) {&#13;
        if (cardTokenToOwner[cards[index].token] == _owner) {&#13;
          result[resultIndex] = cards[index].token;&#13;
          resultIndex++;&#13;
        }&#13;
      }&#13;
      return result;&#13;
    }&#13;
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
    return cardTokenToApproved[_tokenId] == _to;&#13;
  }&#13;
&#13;
  /// Check for token ownership&#13;
  function _owns(address claimant, uint256 _tokenId) private view returns (bool) {&#13;
    return claimant == cardTokenToOwner[_tokenId];&#13;
  }&#13;
&#13;
&#13;
  /// @dev Assigns ownership of a specific card to an address.&#13;
  function _transfer(address _from, address _to, uint256 _tokenId) private {&#13;
    // Since the number of cards is capped to 2^32 we can't overflow this&#13;
    ownershipTokenCount[_to]++;&#13;
    //transfer ownership&#13;
    cardTokenToOwner[_tokenId] = _to;&#13;
&#13;
    // When creating new cards _from is 0x0, but we can't account that address.&#13;
    if (_from != address(0)) {&#13;
      ownershipTokenCount[_from]--;&#13;
      // clear any previously approved ownership exchange&#13;
      delete cardTokenToApproved[_tokenId];&#13;
    }&#13;
&#13;
    // Emit the transfer event.&#13;
    Transfer(_from, _to, _tokenId);&#13;
  }&#13;
  &#13;
&#13;
    function TokensWarContract() public {&#13;
    }&#13;
    &#13;
}&#13;
&#13;
library Helper {&#13;
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
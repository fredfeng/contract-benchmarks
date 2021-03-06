pragma solidity ^0.4.2;

// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
// @author Dieter Shirley <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a0c4c5d4c5e0c1d8c9cfcddac5ce8ec3cf">[email protected]</a>&gt; (https://github.com/dete)&#13;
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
}&#13;
&#13;
contract Elements is ERC721 {&#13;
&#13;
  	/*** EVENTS ***/&#13;
  	// @dev The Birth event is fired whenever a new element comes into existence.&#13;
  	event Birth(uint256 tokenId, string name, address owner);&#13;
&#13;
  	// @dev The TokenSold event is fired whenever a token is sold.&#13;
  	event TokenSold(uint256 tokenId, uint256 oldPrice, uint256 newPrice, address prevOwner, address winner, string name);&#13;
&#13;
  	// @dev Transfer event as defined in current draft of ERC721. Ownership is assigned, including births.&#13;
  	event Transfer(address from, address to, uint256 tokenId);&#13;
&#13;
  	/*** CONSTANTS, VARIABLES ***/&#13;
&#13;
	// @notice Name and symbol of the non fungible token, as defined in ERC721.&#13;
	string public constant NAME = "CryptoElements"; // solhint-disable-line&#13;
	string public constant SYMBOL = "CREL"; // solhint-disable-line&#13;
&#13;
  	uint256 private periodicStartingPrice = 5 ether;&#13;
  	uint256 private elementStartingPrice = 0.005 ether;&#13;
  	uint256 private scientistStartingPrice = 0.1 ether;&#13;
  	uint256 private specialStartingPrice = 0.05 ether;&#13;
&#13;
  	uint256 private firstStepLimit =  0.05 ether;&#13;
  	uint256 private secondStepLimit = 0.75 ether;&#13;
  	uint256 private thirdStepLimit = 3 ether;&#13;
&#13;
  	bool private periodicTableExists = false;&#13;
&#13;
  	uint256 private elementCTR = 0;&#13;
  	uint256 private scientistCTR = 0;&#13;
  	uint256 private specialCTR = 0;&#13;
&#13;
  	uint256 private constant elementSTART = 1;&#13;
  	uint256 private constant scientistSTART = 1000;&#13;
  	uint256 private constant specialSTART = 10000;&#13;
&#13;
  	uint256 private constant specialLIMIT = 5000;&#13;
&#13;
  	/*** STORAGE ***/&#13;
&#13;
  	// @dev A mapping from element IDs to the address that owns them. All elements have&#13;
  	//  some valid owner address.&#13;
  	mapping (uint256 =&gt; address) public elementIndexToOwner;&#13;
&#13;
  	// @dev A mapping from owner address to count of tokens that address owns.&#13;
  	//  Used internally inside balanceOf() to resolve ownership count.&#13;
  	mapping (address =&gt; uint256) private ownershipTokenCount;&#13;
&#13;
  	// @dev A mapping from ElementIDs to an address that has been approved to call&#13;
  	//  transferFrom(). Each Element can only have one approved address for transfer&#13;
  	//  at any time. A zero value means no approval is outstanding.&#13;
  	mapping (uint256 =&gt; address) public elementIndexToApproved;&#13;
&#13;
  	// @dev A mapping from ElementIDs to the price of the token.&#13;
  	mapping (uint256 =&gt; uint256) private elementIndexToPrice;&#13;
&#13;
  	// The addresses of the accounts (or contracts) that can execute actions within each roles.&#13;
  	address public ceoAddress;&#13;
  	address public cooAddress;&#13;
&#13;
  	/*** DATATYPES ***/&#13;
  	struct Element {&#13;
  		uint256 tokenId;&#13;
    	string name;&#13;
    	uint256 scientistId;&#13;
  	}&#13;
&#13;
  	mapping(uint256 =&gt; Element) elements;&#13;
&#13;
  	uint256[] tokens;&#13;
&#13;
  	/*** ACCESS MODIFIERS ***/&#13;
  	// @dev Access modifier for CEO-only functionality&#13;
  	modifier onlyCEO() {&#13;
    	require(msg.sender == ceoAddress);&#13;
    	_;&#13;
  	}&#13;
&#13;
  	// @dev Access modifier for COO-only functionality&#13;
  	modifier onlyCOO() {&#13;
  	  require(msg.sender == cooAddress);&#13;
  	  _;&#13;
  	}&#13;
&#13;
  	// Access modifier for contract owner only functionality&#13;
  	modifier onlyCLevel() {&#13;
  	  	require(&#13;
  	    	msg.sender == ceoAddress ||&#13;
  	    	msg.sender == cooAddress&#13;
  	  	);&#13;
  	  	_;&#13;
  	}&#13;
&#13;
  	/*** CONSTRUCTOR ***/&#13;
  	function Elements() public {&#13;
  	  	ceoAddress = msg.sender;&#13;
  	  	cooAddress = msg.sender;&#13;
&#13;
  	  	createContractPeriodicTable("Periodic");&#13;
  	}&#13;
&#13;
  	/*** PUBLIC FUNCTIONS ***/&#13;
  	// @notice Grant another address the right to transfer token via takeOwnership() and transferFrom().&#13;
  	// @param _to The address to be granted transfer approval. Pass address(0) to&#13;
  	//  clear all approvals.&#13;
  	// @param _tokenId The ID of the Token that can be transferred if this call succeeds.&#13;
  	// @dev Required for ERC-721 compliance.&#13;
  	function approve(address _to, uint256 _tokenId) public {&#13;
  	  	// Caller must own token.&#13;
  	  	require(_owns(msg.sender, _tokenId));&#13;
	&#13;
	  	elementIndexToApproved[_tokenId] = _to;&#13;
	&#13;
	  	Approval(msg.sender, _to, _tokenId);&#13;
  	}&#13;
&#13;
  	// For querying balance of a particular account&#13;
  	// @param _owner The address for balance query&#13;
  	// @dev Required for ERC-721 compliance.&#13;
  	function balanceOf(address _owner) public view returns (uint256 balance) {&#13;
    	return ownershipTokenCount[_owner];&#13;
  	}&#13;
&#13;
  	// @notice Returns all the relevant information about a specific element.&#13;
  	// @param _tokenId The tokenId of the element of interest.&#13;
  	function getElement(uint256 _tokenId) public view returns (&#13;
  		uint256 tokenId,&#13;
    	string elementName,&#13;
    	uint256 sellingPrice,&#13;
    	address owner,&#13;
    	uint256 scientistId&#13;
  	) {&#13;
    	Element storage element = elements[_tokenId];&#13;
    	tokenId = element.tokenId;&#13;
    	elementName = element.name;&#13;
    	sellingPrice = elementIndexToPrice[_tokenId];&#13;
    	owner = elementIndexToOwner[_tokenId];&#13;
    	scientistId = element.scientistId;&#13;
  	}&#13;
&#13;
  	function implementsERC721() public pure returns (bool) {&#13;
    	return true;&#13;
  	}&#13;
&#13;
  	// For querying owner of token&#13;
  	// @param _tokenId The tokenID for owner inquiry&#13;
  	// @dev Required for ERC-721 compliance.&#13;
  	function ownerOf(uint256 _tokenId) public view returns (address owner) {&#13;
    	owner = elementIndexToOwner[_tokenId];&#13;
    	require(owner != address(0));&#13;
  	}&#13;
&#13;
  	function payout(address _to) public onlyCLevel {&#13;
    	_payout(_to);&#13;
  	}&#13;
&#13;
  	// Allows someone to send ether and obtain the token&#13;
  	function purchase(uint256 _tokenId) public payable {&#13;
    	address oldOwner = elementIndexToOwner[_tokenId];&#13;
    	address newOwner = msg.sender;&#13;
&#13;
    	uint256 sellingPrice = elementIndexToPrice[_tokenId];&#13;
    	// Making sure token owner is not sending to self&#13;
    	require(oldOwner != newOwner);&#13;
    	require(sellingPrice &gt; 0);&#13;
&#13;
    	// Safety check to prevent against an unexpected 0x0 default.&#13;
    	require(_addressNotNull(newOwner));&#13;
&#13;
    	// Making sure sent amount is greater than or equal to the sellingPrice&#13;
    	require(msg.value &gt;= sellingPrice);&#13;
&#13;
    	uint256 ownerPayout = SafeMath.mul(SafeMath.div(sellingPrice, 100), 96);&#13;
    	uint256 purchaseExcess = SafeMath.sub(msg.value, sellingPrice);&#13;
    	uint256	feeOnce = SafeMath.div(SafeMath.sub(sellingPrice, ownerPayout), 4);&#13;
    	uint256 fee_for_dev = SafeMath.mul(feeOnce, 2);&#13;
&#13;
    	// Pay previous tokenOwner if owner is not contract&#13;
    	// and if previous price is not 0&#13;
    	if (oldOwner != address(this)) {&#13;
      		// old owner gets entire initial payment back&#13;
      		oldOwner.transfer(ownerPayout);&#13;
    	} else {&#13;
      		fee_for_dev = SafeMath.add(fee_for_dev, ownerPayout);&#13;
    	}&#13;
&#13;
    	// Taxes for Periodic Table owner&#13;
	    if (elementIndexToOwner[0] != address(this)) {&#13;
	    	elementIndexToOwner[0].transfer(feeOnce);&#13;
	    } else {&#13;
	    	fee_for_dev = SafeMath.add(fee_for_dev, feeOnce);&#13;
	    }&#13;
&#13;
	    // Taxes for Scientist Owner for given Element&#13;
	    uint256 scientistId = elements[_tokenId].scientistId;&#13;
&#13;
	    if ( scientistId != scientistSTART ) {&#13;
	    	if (elementIndexToOwner[scientistId] != address(this)) {&#13;
		    	elementIndexToOwner[scientistId].transfer(feeOnce);&#13;
		    } else {&#13;
		    	fee_for_dev = SafeMath.add(fee_for_dev, feeOnce);&#13;
		    }&#13;
	    } else {&#13;
	    	fee_for_dev = SafeMath.add(fee_for_dev, feeOnce);&#13;
	    }&#13;
	        &#13;
    	if (purchaseExcess &gt; 0) {&#13;
    		msg.sender.transfer(purchaseExcess);&#13;
    	}&#13;
&#13;
    	ceoAddress.transfer(fee_for_dev);&#13;
&#13;
    	_transfer(oldOwner, newOwner, _tokenId);&#13;
&#13;
    	//TokenSold(_tokenId, sellingPrice, elementIndexToPrice[_tokenId], oldOwner, newOwner, elements[_tokenId].name);&#13;
    	// Update prices&#13;
    	if (sellingPrice &lt; firstStepLimit) {&#13;
      		// first stage&#13;
      		elementIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 200), 100);&#13;
    	} else if (sellingPrice &lt; secondStepLimit) {&#13;
      		// second stage&#13;
      		elementIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 150), 100);&#13;
    	} else if (sellingPrice &lt; thirdStepLimit) {&#13;
    	  	// third stage&#13;
      		elementIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 130), 100);&#13;
    	} else {&#13;
      		// fourth stage&#13;
      		elementIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 115), 100);&#13;
    	}&#13;
  	}&#13;
&#13;
  	function priceOf(uint256 _tokenId) public view returns (uint256 price) {&#13;
	    return elementIndexToPrice[_tokenId];&#13;
  	}&#13;
&#13;
  	// @dev Assigns a new address to act as the CEO. Only available to the current CEO.&#13;
  	// @param _newCEO The address of the new CEO&#13;
  	function setCEO(address _newCEO) public onlyCEO {&#13;
	    require(_newCEO != address(0));&#13;
&#13;
    	ceoAddress = _newCEO;&#13;
  	}&#13;
&#13;
  	// @dev Assigns a new address to act as the COO. Only available to the current COO.&#13;
  	// @param _newCOO The address of the new COO&#13;
  	function setCOO(address _newCOO) public onlyCEO {&#13;
    	require(_newCOO != address(0));&#13;
    	cooAddress = _newCOO;&#13;
  	}&#13;
&#13;
  	// @notice Allow pre-approved user to take ownership of a token&#13;
  	// @param _tokenId The ID of the Token that can be transferred if this call succeeds.&#13;
  	// @dev Required for ERC-721 compliance.&#13;
  	function takeOwnership(uint256 _tokenId) public {&#13;
    	address newOwner = msg.sender;&#13;
    	address oldOwner = elementIndexToOwner[_tokenId];&#13;
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
  	// @param _owner The owner whose element tokens we are interested in.&#13;
  	// @dev This method MUST NEVER be called by smart contract code. First, it's fairly&#13;
  	//  expensive (it walks the entire Elements array looking for elements belonging to owner),&#13;
  	//  but it also returns a dynamic array, which is only supported for web3 calls, and&#13;
  	//  not contract-to-contract calls.&#13;
  	function tokensOfOwner(address _owner) public view returns(uint256[] ownerTokens) {&#13;
    	uint256 tokenCount = balanceOf(_owner);&#13;
    	if (tokenCount == 0) {&#13;
        	// Return an empty array&#13;
      		return new uint256[](0);&#13;
    	} else {&#13;
      		uint256[] memory result = new uint256[](tokenCount);&#13;
      		uint256 totalElements = totalSupply();&#13;
      		uint256 resultIndex = 0;&#13;
      		uint256 elementId;&#13;
      		for (elementId = 0; elementId &lt; totalElements; elementId++) {&#13;
      			uint256 tokenId = tokens[elementId];&#13;
&#13;
		        if (elementIndexToOwner[tokenId] == _owner) {&#13;
		          result[resultIndex] = tokenId;&#13;
		          resultIndex++;&#13;
		        }&#13;
      		}&#13;
      		return result;&#13;
    	}&#13;
  	}&#13;
&#13;
  	// For querying totalSupply of token&#13;
  	// @dev Required for ERC-721 compliance.&#13;
  	function totalSupply() public view returns (uint256 total) {&#13;
    	return tokens.length;&#13;
  	}&#13;
&#13;
  	// Owner initates the transfer of the token to another account&#13;
  	// @param _to The address for the token to be transferred to.&#13;
  	// @param _tokenId The ID of the Token that can be transferred if this call succeeds.&#13;
  	// @dev Required for ERC-721 compliance.&#13;
  	function transfer( address _to, uint256 _tokenId ) public {&#13;
   		require(_owns(msg.sender, _tokenId));&#13;
    	require(_addressNotNull(_to));&#13;
    	_transfer(msg.sender, _to, _tokenId);&#13;
  	}&#13;
&#13;
  	// Third-party initiates transfer of token from address _from to address _to&#13;
  	// @param _from The address for the token to be transferred from.&#13;
  	// @param _to The address for the token to be transferred to.&#13;
  	// @param _tokenId The ID of the Token that can be transferred if this call succeeds.&#13;
  	// @dev Required for ERC-721 compliance.&#13;
  	function transferFrom( address _from, address _to, uint256 _tokenId) public {&#13;
    	require(_owns(_from, _tokenId));&#13;
    	require(_approved(_to, _tokenId));&#13;
    	require(_addressNotNull(_to));&#13;
    	_transfer(_from, _to, _tokenId);&#13;
  	}&#13;
&#13;
  	/*** PRIVATE FUNCTIONS ***/&#13;
  	// Safety check on _to address to prevent against an unexpected 0x0 default.&#13;
  	function _addressNotNull(address _to) private pure returns (bool) {&#13;
    	return _to != address(0);&#13;
  	}&#13;
&#13;
  	// For checking approval of transfer for address _to&#13;
	function _approved(address _to, uint256 _tokenId) private view returns (bool) {&#13;
		return elementIndexToApproved[_tokenId] == _to;&#13;
	}&#13;
&#13;
  	// Private method for creating Element&#13;
  	function _createElement(uint256 _id, string _name, address _owner, uint256 _price, uint256 _scientistId) private returns (string) {&#13;
&#13;
    	uint256 newElementId = _id;&#13;
    	// It's probably never going to happen, 4 billion tokens are A LOT, but&#13;
    	// let's just be 100% sure we never let this happen.&#13;
    	require(newElementId == uint256(uint32(newElementId)));&#13;
&#13;
    	elements[_id] = Element(_id, _name, _scientistId);&#13;
&#13;
    	Birth(newElementId, _name, _owner);&#13;
&#13;
    	elementIndexToPrice[newElementId] = _price;&#13;
&#13;
    	// This will assign ownership, and also emit the Transfer event as&#13;
    	// per ERC721 draft&#13;
    	_transfer(address(0), _owner, newElementId);&#13;
&#13;
    	tokens.push(_id);&#13;
&#13;
    	return _name;&#13;
  	}&#13;
&#13;
&#13;
  	// @dev Creates Periodic Table as first element&#13;
  	function createContractPeriodicTable(string _name) public onlyCEO {&#13;
  		require(periodicTableExists == false);&#13;
&#13;
  		_createElement(0, _name, address(this), periodicStartingPrice, scientistSTART);&#13;
  		periodicTableExists = true;&#13;
  	}&#13;
&#13;
  	// @dev Creates a new Element with the given name and Id&#13;
  	function createContractElement(string _name, uint256 _scientistId) public onlyCEO {&#13;
  		require(periodicTableExists == true);&#13;
&#13;
    	uint256 _id = SafeMath.add(elementCTR, elementSTART);&#13;
    	uint256 _scientistIdProcessed = SafeMath.add(_scientistId, scientistSTART);&#13;
&#13;
    	_createElement(_id, _name, address(this), elementStartingPrice, _scientistIdProcessed);&#13;
    	elementCTR = SafeMath.add(elementCTR, 1);&#13;
  	}&#13;
&#13;
  	// @dev Creates a new Scientist with the given name Id&#13;
  	function createContractScientist(string _name) public onlyCEO {&#13;
  		require(periodicTableExists == true);&#13;
&#13;
  		// to start from 1001&#13;
  		scientistCTR = SafeMath.add(scientistCTR, 1);&#13;
    	uint256 _id = SafeMath.add(scientistCTR, scientistSTART);&#13;
    	&#13;
    	_createElement(_id, _name, address(this), scientistStartingPrice, scientistSTART);	&#13;
  	}&#13;
&#13;
  	// @dev Creates a new Special Card with the given name Id&#13;
  	function createContractSpecial(string _name) public onlyCEO {&#13;
  		require(periodicTableExists == true);&#13;
  		require(specialCTR &lt;= specialLIMIT);&#13;
&#13;
  		// to start from 10001&#13;
  		specialCTR = SafeMath.add(specialCTR, 1);&#13;
    	uint256 _id = SafeMath.add(specialCTR, specialSTART);&#13;
&#13;
    	_createElement(_id, _name, address(this), specialStartingPrice, scientistSTART);&#13;
    	&#13;
  	}&#13;
&#13;
  	// Check for token ownership&#13;
  	function _owns(address claimant, uint256 _tokenId) private view returns (bool) {&#13;
    	return claimant == elementIndexToOwner[_tokenId];&#13;
  	}&#13;
&#13;
&#13;
  	//**** HELPERS for checking elements, scientists and special cards&#13;
  	function checkPeriodic() public view returns (bool) {&#13;
  		return periodicTableExists;&#13;
  	}&#13;
&#13;
  	function getTotalElements() public view returns (uint256) {&#13;
  		return elementCTR;&#13;
  	}&#13;
&#13;
  	function getTotalScientists() public view returns (uint256) {&#13;
  		return scientistCTR;&#13;
  	}&#13;
&#13;
  	function getTotalSpecials() public view returns (uint256) {&#13;
  		return specialCTR;&#13;
  	}&#13;
&#13;
  	//**** HELPERS for changing prices limits and steps if it would be bad, community would like different&#13;
  	function changeStartingPricesLimits(uint256 _elementStartPrice, uint256 _scientistStartPrice, uint256 _specialStartPrice) public onlyCEO {&#13;
  		elementStartingPrice = _elementStartPrice;&#13;
  		scientistStartingPrice = _scientistStartPrice;&#13;
  		specialStartingPrice = _specialStartPrice;&#13;
	}&#13;
&#13;
	function changeStepPricesLimits(uint256 _first, uint256 _second, uint256 _third) public onlyCEO {&#13;
		firstStepLimit = _first;&#13;
		secondStepLimit = _second;&#13;
		thirdStepLimit = _third;&#13;
	}&#13;
&#13;
	// in case of error when assigning scientist to given element&#13;
	function changeScientistForElement(uint256 _tokenId, uint256 _scientistId) public onlyCEO {&#13;
    	Element storage element = elements[_tokenId];&#13;
    	element.scientistId = SafeMath.add(_scientistId, scientistSTART);&#13;
  	}&#13;
&#13;
  	function changeElementName(uint256 _tokenId, string _name) public onlyCEO {&#13;
    	Element storage element = elements[_tokenId];&#13;
    	element.name = _name;&#13;
  	}&#13;
&#13;
  	// This function can be used by the owner of a token to modify the current price&#13;
	function modifyTokenPrice(uint256 _tokenId, uint256 _newPrice) public payable {&#13;
	    require(_newPrice &gt; elementStartingPrice);&#13;
	    require(elementIndexToOwner[_tokenId] == msg.sender);&#13;
	    require(_newPrice &lt; elementIndexToPrice[_tokenId]);&#13;
&#13;
	    if ( _tokenId == 0) {&#13;
	    	require(_newPrice &gt; periodicStartingPrice);&#13;
	    } else if ( _tokenId &lt; 1000) {&#13;
	    	require(_newPrice &gt; elementStartingPrice);&#13;
	    } else if ( _tokenId &lt; 10000 ) {&#13;
	    	require(_newPrice &gt; scientistStartingPrice);&#13;
	    } else {&#13;
	    	require(_newPrice &gt; specialStartingPrice);&#13;
	    }&#13;
&#13;
	    elementIndexToPrice[_tokenId] = _newPrice;&#13;
	}&#13;
&#13;
  	// For paying out balance on contract&#13;
  	function _payout(address _to) private {&#13;
    	if (_to == address(0)) {&#13;
      		ceoAddress.transfer(this.balance);&#13;
    	} else {&#13;
      		_to.transfer(this.balance);&#13;
    	}&#13;
  	}&#13;
&#13;
  	// @dev Assigns ownership of a specific Element to an address.&#13;
  	function _transfer(address _from, address _to, uint256 _tokenId) private {&#13;
  	  	// Since the number of elements is capped to 2^32 we can't overflow this&#13;
  	  	ownershipTokenCount[_to]++;&#13;
  	  	//transfer ownership&#13;
  	  	elementIndexToOwner[_tokenId] = _to;&#13;
  	  	// When creating new elements _from is 0x0, but we can't account that address.&#13;
  	  	if (_from != address(0)) {&#13;
  	    	ownershipTokenCount[_from]--;&#13;
  	    	// clear any previously approved ownership exchange&#13;
  	    	delete elementIndexToApproved[_tokenId];&#13;
  	  	}&#13;
  	  	// Emit the transfer event.&#13;
  	  	Transfer(_from, _to, _tokenId);&#13;
  	}&#13;
}&#13;
&#13;
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
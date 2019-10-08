pragma solidity 0.4.21;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint a, uint b) internal pure returns(uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        assert(c / a == b);
        return c;
    }
    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint a, uint b) internal pure returns(uint) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }
    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint a, uint b) internal pure returns(uint) {
        assert(b <= a);
        return a - b;
    }
    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint a, uint b) internal pure returns(uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }
}

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="274342534267465f4e484a5d4249094448">[email protected]</a>&gt; (https://github.com/dete)&#13;
&#13;
contract ERC721 {&#13;
    // Required methods&#13;
    function approve(address _to, uint _tokenId) public;&#13;
    function balanceOf(address _owner) public view returns(uint balance);&#13;
    function implementsERC721() public pure returns(bool);&#13;
    function ownerOf(uint _tokenId) public view returns(address addr);&#13;
    function takeOwnership(uint _tokenId) public;&#13;
    function totalSupply() public view returns(uint total);&#13;
    function transferFrom(address _from, address _to, uint _tokenId) public;&#13;
    function transfer(address _to, uint _tokenId) public;&#13;
&#13;
    //event Transfer(uint tokenId, address indexed from, address indexed to);&#13;
    event Approval(uint tokenId, address indexed owner, address indexed approved);&#13;
    &#13;
    // Optional&#13;
    // function name() public view returns (string name);&#13;
    // function symbol() public view returns (string symbol);&#13;
    // function tokenOfOwnerByIndex(address _owner, uint _index) external view returns (uint tokenId);&#13;
    // function tokenMetadata(uint _tokenId) public view returns (string infoUrl);&#13;
}&#13;
contract CryptoCovfefes is ERC721 {&#13;
    /*** CONSTANTS ***/&#13;
    /// @notice Name and symbol of the non fungible token, as defined in ERC721.&#13;
    string public constant NAME = "CryptoCovfefes";&#13;
    string public constant SYMBOL = "Covfefe Token";&#13;
    &#13;
    uint private constant startingPrice = 0.001 ether;&#13;
    &#13;
    uint private constant PROMO_CREATION_LIMIT = 5000;&#13;
    uint private constant CONTRACT_CREATION_LIMIT = 45000;&#13;
    uint private constant SaleCooldownTime = 12 hours;&#13;
    &#13;
    uint private randNonce = 0;&#13;
    uint private constant duelVictoryProbability = 51;&#13;
    uint private constant duelFee = .001 ether;&#13;
    &#13;
    uint private addMeaningFee = .001 ether;&#13;
&#13;
    /*** EVENTS ***/&#13;
        /// @dev The Creation event is fired whenever a new Covfefe comes into existence.&#13;
    event NewCovfefeCreated(uint tokenId, string term, string meaning, uint generation, address owner);&#13;
    &#13;
    /// @dev The Meaning added event is fired whenever a Covfefe is defined&#13;
    event CovfefeMeaningAdded(uint tokenId, string term, string meaning);&#13;
    &#13;
    /// @dev The CovfefeSold event is fired whenever a token is bought and sold.&#13;
    event CovfefeSold(uint tokenId, string term, string meaning, uint generation, uint sellingpPice, uint currentPrice, address buyer, address seller);&#13;
    &#13;
     /// @dev The Add Value To Covfefe event is fired whenever value is added to the Covfefe token&#13;
    event AddedValueToCovfefe(uint tokenId, string term, string meaning, uint generation, uint currentPrice);&#13;
    &#13;
     /// @dev The Transfer Covfefe event is fired whenever a Covfefe token is transferred&#13;
     event CovfefeTransferred(uint tokenId, address from, address to);&#13;
     &#13;
    /// @dev The ChallengerWinsCovfefeDuel event is fired whenever the Challenging Covfefe wins a duel&#13;
    event ChallengerWinsCovfefeDuel(uint tokenIdChallenger, string termChallenger, uint tokenIdDefender, string termDefender);&#13;
    &#13;
    /// @dev The DefenderWinsCovfefeDuel event is fired whenever the Challenging Covfefe wins a duel&#13;
    event DefenderWinsCovfefeDuel(uint tokenIdDefender, string termDefender, uint tokenIdChallenger, string termChallenger);&#13;
&#13;
    /*** STORAGE ***/&#13;
    /// @dev A mapping from covfefe IDs to the address that owns them. All covfefes have&#13;
    ///  some valid owner address.&#13;
    mapping(uint =&gt; address) public covfefeIndexToOwner;&#13;
    &#13;
    // @dev A mapping from owner address to count of tokens that address owns.&#13;
    //  Used internally inside balanceOf() to resolve ownership count.&#13;
    mapping(address =&gt; uint) private ownershipTokenCount;&#13;
    &#13;
    /// @dev A mapping from CovfefeIDs to an address that has been approved to call&#13;
    ///  transferFrom(). Each Covfefe can only have one approved address for transfer&#13;
    ///  at any time. A zero value means no approval is outstanding.&#13;
    mapping(uint =&gt; address) public covfefeIndexToApproved;&#13;
    &#13;
    // @dev A mapping from CovfefeIDs to the price of the token.&#13;
    mapping(uint =&gt; uint) private covfefeIndexToPrice;&#13;
    &#13;
    // @dev A mapping from CovfefeIDs to the price of the token.&#13;
    mapping(uint =&gt; uint) private covfefeIndexToLastPrice;&#13;
    &#13;
    // The addresses of the accounts (or contracts) that can execute actions within each roles.&#13;
    address public covmanAddress;&#13;
    address public covmanagerAddress;&#13;
    uint public promoCreatedCount;&#13;
    uint public contractCreatedCount;&#13;
    &#13;
    /*** DATATYPES ***/&#13;
    struct Covfefe {&#13;
        string term;&#13;
        string meaning;&#13;
        uint16 generation;&#13;
        uint16 winCount;&#13;
        uint16 lossCount;&#13;
        uint64 saleReadyTime;&#13;
    }&#13;
    &#13;
    Covfefe[] private covfefes;&#13;
    /*** ACCESS MODIFIERS ***/&#13;
    /// @dev Access modifier for Covman-only functionality&#13;
    modifier onlyCovman() {&#13;
        require(msg.sender == covmanAddress);&#13;
        _;&#13;
    }&#13;
    /// @dev Access modifier for Covmanager-only functionality&#13;
    modifier onlyCovmanager() {&#13;
        require(msg.sender == covmanagerAddress);&#13;
        _;&#13;
    }&#13;
    /// Access modifier for contract owner only functionality&#13;
    modifier onlyCovDwellers() {&#13;
        require(msg.sender == covmanAddress || msg.sender == covmanagerAddress);&#13;
        _;&#13;
    }&#13;
    &#13;
    /*** CONSTRUCTOR ***/&#13;
    function CryptoCovfefes() public {&#13;
        covmanAddress = msg.sender;&#13;
        covmanagerAddress = msg.sender;&#13;
    }&#13;
    /*** PUBLIC FUNCTIONS ***/&#13;
    /// @notice Grant another address the right to transfer token via takeOwnership() and transferFrom().&#13;
    /// @param _to The address to be granted transfer approval. Pass address(0) to&#13;
    ///  clear all approvals.&#13;
    /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.&#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function approve(address _to, uint _tokenId) public {&#13;
        // Caller must own token.&#13;
        require(_owns(msg.sender, _tokenId));&#13;
        covfefeIndexToApproved[_tokenId] = _to;&#13;
        emit Approval(_tokenId, msg.sender, _to);&#13;
    }&#13;
    &#13;
    /// For querying balance of a particular account&#13;
    /// @param _owner The address for balance query&#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function balanceOf(address _owner) public view returns(uint balance) {&#13;
        return ownershipTokenCount[_owner];&#13;
    }&#13;
    ///////////////////Create Covfefe///////////////////////////&#13;
&#13;
    /// @dev Creates a new promo Covfefe with the given term, with given _price and assignes it to an address.&#13;
    function createPromoCovfefe(address _owner, string _term, string _meaning, uint16 _generation, uint _price) public onlyCovmanager {&#13;
        require(promoCreatedCount &lt; PROMO_CREATION_LIMIT);&#13;
        address covfefeOwner = _owner;&#13;
        if (covfefeOwner == address(0)) {&#13;
            covfefeOwner = covmanagerAddress;&#13;
        }&#13;
        if (_price &lt;= 0) {&#13;
            _price = startingPrice;&#13;
        }&#13;
        promoCreatedCount++;&#13;
        _createCovfefe(_term, _meaning, _generation, covfefeOwner, _price);&#13;
    }&#13;
    &#13;
    /// @dev Creates a new Covfefe with the given term.&#13;
    function createContractCovfefe(string _term, string _meaning, uint16 _generation) public onlyCovmanager {&#13;
        require(contractCreatedCount &lt; CONTRACT_CREATION_LIMIT);&#13;
        contractCreatedCount++;&#13;
        _createCovfefe(_term, _meaning, _generation, address(this), startingPrice);&#13;
    }&#13;
&#13;
    function _triggerSaleCooldown(Covfefe storage _covfefe) internal {&#13;
        _covfefe.saleReadyTime = uint64(now + SaleCooldownTime);&#13;
    }&#13;
&#13;
    function _ripeForSale(Covfefe storage _covfefe) internal view returns(bool) {&#13;
        return (_covfefe.saleReadyTime &lt;= now);&#13;
    }&#13;
    /// @notice Returns all the relevant information about a specific covfefe.&#13;
    /// @param _tokenId The tokenId of the covfefe of interest.&#13;
    function getCovfefe(uint _tokenId) public view returns(string Term, string Meaning, uint Generation, uint ReadyTime, uint WinCount, uint LossCount, uint CurrentPrice, uint LastPrice, address Owner) {&#13;
        Covfefe storage covfefe = covfefes[_tokenId];&#13;
        Term = covfefe.term;&#13;
        Meaning = covfefe.meaning;&#13;
        Generation = covfefe.generation;&#13;
        ReadyTime = covfefe.saleReadyTime;&#13;
        WinCount = covfefe.winCount;&#13;
        LossCount = covfefe.lossCount;&#13;
        CurrentPrice = covfefeIndexToPrice[_tokenId];&#13;
        LastPrice = covfefeIndexToLastPrice[_tokenId];&#13;
        Owner = covfefeIndexToOwner[_tokenId];&#13;
    }&#13;
&#13;
    function implementsERC721() public pure returns(bool) {&#13;
        return true;&#13;
    }&#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function name() public pure returns(string) {&#13;
        return NAME;&#13;
    }&#13;
    &#13;
    /// For querying owner of token&#13;
    /// @param _tokenId The tokenID for owner inquiry&#13;
    /// @dev Required for ERC-721 compliance.&#13;
    &#13;
    function ownerOf(uint _tokenId)&#13;
    public&#13;
    view&#13;
    returns(address owner) {&#13;
        owner = covfefeIndexToOwner[_tokenId];&#13;
        require(owner != address(0));&#13;
    }&#13;
    modifier onlyOwnerOf(uint _tokenId) {&#13;
        require(msg.sender == covfefeIndexToOwner[_tokenId]);&#13;
        _;&#13;
    }&#13;
    &#13;
    ///////////////////Add Meaning /////////////////////&#13;
    &#13;
    function addMeaningToCovfefe(uint _tokenId, string _newMeaning) external payable onlyOwnerOf(_tokenId) {&#13;
        &#13;
        /// Making sure the transaction is not from another smart contract&#13;
        require(!isContract(msg.sender));&#13;
        &#13;
        /// Making sure the addMeaningFee is included&#13;
        require(msg.value == addMeaningFee);&#13;
        &#13;
        /// Add the new meaning&#13;
        covfefes[_tokenId].meaning = _newMeaning;&#13;
    &#13;
        /// Emit the term meaning added event.&#13;
        emit CovfefeMeaningAdded(_tokenId, covfefes[_tokenId].term, _newMeaning);&#13;
    }&#13;
&#13;
    function payout(address _to) public onlyCovDwellers {&#13;
        _payout(_to);&#13;
    }&#13;
    /////////////////Buy Token ////////////////////&#13;
    &#13;
    // Allows someone to send ether and obtain the token&#13;
    function buyCovfefe(uint _tokenId) public payable {&#13;
        address oldOwner = covfefeIndexToOwner[_tokenId];&#13;
        address newOwner = msg.sender;&#13;
        &#13;
        // Making sure sale cooldown is not in effect&#13;
        Covfefe storage myCovfefe = covfefes[_tokenId];&#13;
        require(_ripeForSale(myCovfefe));&#13;
        &#13;
        // Making sure the transaction is not from another smart contract&#13;
        require(!isContract(msg.sender));&#13;
        &#13;
        covfefeIndexToLastPrice[_tokenId] = covfefeIndexToPrice[_tokenId];&#13;
        uint sellingPrice = covfefeIndexToPrice[_tokenId];&#13;
        &#13;
        // Making sure token owner is not sending to self&#13;
        require(oldOwner != newOwner);&#13;
        &#13;
        // Safety check to prevent against an unexpected 0x0 default.&#13;
        require(_addressNotNull(newOwner));&#13;
        &#13;
        // Making sure sent amount is greater than or equal to the sellingPrice&#13;
        require(msg.value &gt;= sellingPrice);&#13;
        uint payment = uint(SafeMath.div(SafeMath.mul(sellingPrice, 95), 100));&#13;
        uint purchaseExcess = SafeMath.sub(msg.value, sellingPrice);&#13;
        &#13;
        // Update prices&#13;
        covfefeIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 115), 95);&#13;
        _transfer(oldOwner, newOwner, _tokenId);&#13;
        &#13;
        ///Trigger Sale cooldown&#13;
        _triggerSaleCooldown(myCovfefe);&#13;
        &#13;
        // Pay previous tokenOwner if owner is not contract&#13;
        if (oldOwner != address(this)) {&#13;
            oldOwner.transfer(payment); //(1-0.05)&#13;
        }&#13;
        &#13;
        emit CovfefeSold(_tokenId, covfefes[_tokenId].term, covfefes[_tokenId].meaning, covfefes[_tokenId].generation, covfefeIndexToLastPrice[_tokenId], covfefeIndexToPrice[_tokenId], newOwner, oldOwner);&#13;
        msg.sender.transfer(purchaseExcess);&#13;
    }&#13;
&#13;
    function priceOf(uint _tokenId) public view returns(uint price) {&#13;
        return covfefeIndexToPrice[_tokenId];&#13;
    }&#13;
&#13;
    function lastPriceOf(uint _tokenId) public view returns(uint price) {&#13;
        return covfefeIndexToLastPrice[_tokenId];&#13;
    }&#13;
    &#13;
    /// @dev Assigns a new address to act as the Covman. Only available to the current Covman&#13;
    /// @param _newCovman The address of the new Covman&#13;
    function setCovman(address _newCovman) public onlyCovman {&#13;
        require(_newCovman != address(0));&#13;
        covmanAddress = _newCovman;&#13;
    }&#13;
    &#13;
    /// @dev Assigns a new address to act as the Covmanager. Only available to the current Covman&#13;
    /// @param _newCovmanager The address of the new Covmanager&#13;
    function setCovmanager(address _newCovmanager) public onlyCovman {&#13;
        require(_newCovmanager != address(0));&#13;
        covmanagerAddress = _newCovmanager;&#13;
    }&#13;
    &#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function symbol() public pure returns(string) {&#13;
        return SYMBOL;&#13;
    }&#13;
    &#13;
    /// @notice Allow pre-approved user to take ownership of a token&#13;
    /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.&#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function takeOwnership(uint _tokenId) public {&#13;
        address newOwner = msg.sender;&#13;
        address oldOwner = covfefeIndexToOwner[_tokenId];&#13;
        // Safety check to prevent against an unexpected 0x0 default.&#13;
        require(_addressNotNull(newOwner));&#13;
        // Making sure transfer is approved&#13;
        require(_approved(newOwner, _tokenId));&#13;
        _transfer(oldOwner, newOwner, _tokenId);&#13;
    }&#13;
    &#13;
    ///////////////////Add Value to Covfefe/////////////////////////////&#13;
    //////////////There's no fee for adding value//////////////////////&#13;
&#13;
    function addValueToCovfefe(uint _tokenId) external payable onlyOwnerOf(_tokenId) {&#13;
        &#13;
        // Making sure the transaction is not from another smart contract&#13;
        require(!isContract(msg.sender));&#13;
        &#13;
        //Making sure amount is within the min and max range&#13;
        require(msg.value &gt;= 0.001 ether);&#13;
        require(msg.value &lt;= 9999.000 ether);&#13;
        &#13;
        //Keeping a record of lastprice before updating price&#13;
        covfefeIndexToLastPrice[_tokenId] = covfefeIndexToPrice[_tokenId];&#13;
        &#13;
        uint newValue = msg.value;&#13;
&#13;
        // Update prices&#13;
        newValue = SafeMath.div(SafeMath.mul(newValue, 115), 100);&#13;
        covfefeIndexToPrice[_tokenId] = SafeMath.add(newValue, covfefeIndexToPrice[_tokenId]);&#13;
        &#13;
        ///Emit the AddValueToCovfefe event&#13;
        emit AddedValueToCovfefe(_tokenId, covfefes[_tokenId].term, covfefes[_tokenId].meaning, covfefes[_tokenId].generation, covfefeIndexToPrice[_tokenId]);&#13;
    }&#13;
    &#13;
    /// @param _owner The owner whose covfefe tokens we are interested in.&#13;
    /// @dev This method MUST NEVER be called by smart contract code. First, it's fairly&#13;
    ///  expensive (it walks the entire Covfefes array looking for covfefes belonging to owner),&#13;
    ///  but it also returns a dynamic array, which is only supported for web3 calls, and&#13;
    ///  not contract-to-contract calls.&#13;
    &#13;
    function getTokensOfOwner(address _owner) external view returns(uint[] ownerTokens) {&#13;
        uint tokenCount = balanceOf(_owner);&#13;
        if (tokenCount == 0) {&#13;
            // Return an empty array&#13;
            return new uint[](0);&#13;
        } else {&#13;
            uint[] memory result = new uint[](tokenCount);&#13;
            uint totalCovfefes = totalSupply();&#13;
            uint resultIndex = 0;&#13;
            uint covfefeId;&#13;
            for (covfefeId = 0; covfefeId &lt;= totalCovfefes; covfefeId++) {&#13;
                if (covfefeIndexToOwner[covfefeId] == _owner) {&#13;
                    result[resultIndex] = covfefeId;&#13;
                    resultIndex++;&#13;
                }&#13;
            }&#13;
            return result;&#13;
        }&#13;
    }&#13;
    &#13;
    /// For querying totalSupply of token&#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function totalSupply() public view returns(uint total) {&#13;
        return covfefes.length;&#13;
    }&#13;
    /// Owner initates the transfer of the token to another account&#13;
    /// @param _to The address for the token to be transferred to.&#13;
    /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.&#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function transfer(address _to, uint _tokenId) public {&#13;
        require(_owns(msg.sender, _tokenId));&#13;
        require(_addressNotNull(_to));&#13;
        _transfer(msg.sender, _to, _tokenId);&#13;
    }&#13;
    /// Third-party initiates transfer of token from address _from to address _to&#13;
    /// @param _from The address for the token to be transferred from.&#13;
    /// @param _to The address for the token to be transferred to.&#13;
    /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.&#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function transferFrom(address _from, address _to, uint _tokenId) public {&#13;
        require(_owns(_from, _tokenId));&#13;
        require(_approved(_to, _tokenId));&#13;
        require(_addressNotNull(_to));&#13;
        _transfer(_from, _to, _tokenId);&#13;
    }&#13;
    /*** PRIVATE FUNCTIONS ***/&#13;
    /// Safety check on _to address to prevent against an unexpected 0x0 default.&#13;
    function _addressNotNull(address _to) private pure returns(bool) {&#13;
        return _to != address(0);&#13;
    }&#13;
    /// For checking approval of transfer for address _to&#13;
    function _approved(address _to, uint _tokenId) private view returns(bool) {&#13;
        return covfefeIndexToApproved[_tokenId] == _to;&#13;
    }&#13;
    &#13;
    /////////////Covfefe Creation////////////&#13;
    &#13;
    function _createCovfefe(string _term, string _meaning, uint16 _generation, address _owner, uint _price) private {&#13;
        Covfefe memory _covfefe = Covfefe({&#13;
            term: _term,&#13;
            meaning: _meaning,&#13;
            generation: _generation,&#13;
            saleReadyTime: uint64(now),&#13;
            winCount: 0,&#13;
            lossCount: 0&#13;
        });&#13;
        &#13;
        uint newCovfefeId = covfefes.push(_covfefe) - 1;&#13;
        // It's probably never going to happen, 4 billion tokens are A LOT, but&#13;
        // let's just be 100% sure we never let this happen.&#13;
        require(newCovfefeId == uint(uint32(newCovfefeId)));&#13;
        &#13;
        //Emit the Covfefe creation event&#13;
        emit NewCovfefeCreated(newCovfefeId, _term, _meaning, _generation, _owner);&#13;
        &#13;
        covfefeIndexToPrice[newCovfefeId] = _price;&#13;
        &#13;
        // This will assign ownership, and also emit the Transfer event as&#13;
        // per ERC721 draft&#13;
        _transfer(address(0), _owner, newCovfefeId);&#13;
    }&#13;
    &#13;
    /// Check for token ownership&#13;
    function _owns(address claimant, uint _tokenId) private view returns(bool) {&#13;
        return claimant == covfefeIndexToOwner[_tokenId];&#13;
    }&#13;
    &#13;
    /// For paying out balance on contract&#13;
    function _payout(address _to) private {&#13;
        if (_to == address(0)) {&#13;
            covmanAddress.transfer(address(this).balance);&#13;
        } else {&#13;
            _to.transfer(address(this).balance);&#13;
        }&#13;
    }&#13;
    &#13;
    /////////////////////Transfer//////////////////////&#13;
    /// @dev Transfer event as defined in current draft of ERC721. &#13;
    ///  ownership is assigned, including births.&#13;
    &#13;
    /// @dev Assigns ownership of a specific Covfefe to an address.&#13;
    function _transfer(address _from, address _to, uint _tokenId) private {&#13;
        // Since the number of covfefes is capped to 2^32 we can't overflow this&#13;
        ownershipTokenCount[_to]++;&#13;
        //transfer ownership&#13;
        covfefeIndexToOwner[_tokenId] = _to;&#13;
        // When creating new covfefes _from is 0x0, but we can't account that address.&#13;
        if (_from != address(0)) {&#13;
            ownershipTokenCount[_from]--;&#13;
            // clear any previously approved ownership exchange&#13;
            delete covfefeIndexToApproved[_tokenId];&#13;
        }&#13;
        // Emit the transfer event.&#13;
        emit CovfefeTransferred(_tokenId, _from, _to);&#13;
    }&#13;
    &#13;
    ///////////////////Covfefe Duel System//////////////////////&#13;
    &#13;
    //Simple Randomizer for the covfefe duelling system&#13;
    function randMod(uint _modulus) internal returns(uint) {&#13;
        randNonce++;&#13;
        return uint(keccak256(now, msg.sender, randNonce)) % _modulus;&#13;
    }&#13;
    &#13;
    function duelAnotherCovfefe(uint _tokenId, uint _targetId) external payable onlyOwnerOf(_tokenId) {&#13;
        //Load the covfefes from storage&#13;
        Covfefe storage myCovfefe = covfefes[_tokenId];&#13;
        &#13;
        // Making sure the transaction is not from another smart contract&#13;
        require(!isContract(msg.sender));&#13;
        &#13;
        //Making sure the duelling fee is included&#13;
        require(msg.value == duelFee);&#13;
        &#13;
        //&#13;
        Covfefe storage enemyCovfefe = covfefes[_targetId];&#13;
        uint rand = randMod(100);&#13;
        &#13;
        if (rand &lt;= duelVictoryProbability) {&#13;
            myCovfefe.winCount++;&#13;
            enemyCovfefe.lossCount++;&#13;
        &#13;
        ///Emit the ChallengerWins event&#13;
            emit ChallengerWinsCovfefeDuel(_tokenId, covfefes[_tokenId].term, _targetId, covfefes[_targetId].term);&#13;
            &#13;
        } else {&#13;
        &#13;
            myCovfefe.lossCount++;&#13;
            enemyCovfefe.winCount++;&#13;
        &#13;
            ///Emit the DefenderWins event&#13;
            emit DefenderWinsCovfefeDuel(_targetId, covfefes[_targetId].term, _tokenId, covfefes[_tokenId].term);&#13;
        }&#13;
    }&#13;
    &#13;
    ////////////////// Utility //////////////////&#13;
    &#13;
    function isContract(address addr) internal view returns(bool) {&#13;
        uint size;&#13;
        assembly {&#13;
            size: = extcodesize(addr)&#13;
        }&#13;
        return size &gt; 0;&#13;
    }&#13;
}
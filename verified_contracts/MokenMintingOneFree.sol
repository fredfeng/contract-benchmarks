pragma solidity 0.4.24;
pragma experimental "v0.5.0";
/******************************************************************************\
* Author: Nick Mudge, <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5937303a32193436323c372a773036">[email protected]</a>&#13;
* Mokens&#13;
* Copyright (c) 2018&#13;
*&#13;
* Minting functions and mint price functions.&#13;
/******************************************************************************/&#13;
&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
//Storage contracts&#13;
////////////&#13;
//Some delegate contracts are listed with storage contracts they inherit.&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
//Mokens&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
contract Storage0 {&#13;
    // funcId =&gt; delegate contract&#13;
    mapping(bytes4 =&gt; address) internal delegates;&#13;
}&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
//MokenUpdates&#13;
//MokenOwner&#13;
//QueryMokenDelegates&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
contract Storage1 is Storage0 {&#13;
    address internal contractOwner;&#13;
    bytes[] internal funcSignatures;&#13;
    // signature =&gt; index+1&#13;
    mapping(bytes =&gt; uint256) internal funcSignatureToIndex;&#13;
}&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
//MokensSupportsInterfaces&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
contract Storage2 is Storage1 {&#13;
    mapping(bytes4 =&gt; bool) internal supportedInterfaces;&#13;
}&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
//MokenRootOwnerOf&#13;
//MokenERC721Metadata&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
contract Storage3 is Storage2 {&#13;
    struct Moken {&#13;
        string name;&#13;
        uint256 data;&#13;
        uint256 parentTokenId;&#13;
    }&#13;
    //tokenId =&gt; moken&#13;
    mapping(uint256 =&gt; Moken) internal mokens;&#13;
    uint256 internal mokensLength;&#13;
    // child address =&gt; child tokenId =&gt; tokenId+1&#13;
    mapping(address =&gt; mapping(uint256 =&gt; uint256)) internal childTokenOwner;&#13;
}&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
//MokenERC721Enumerable&#13;
//MokenLinkHash&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
contract Storage4 is Storage3 {&#13;
    // root token owner address =&gt; (tokenId =&gt; approved address)&#13;
    mapping(address =&gt; mapping(uint256 =&gt; address)) internal rootOwnerAndTokenIdToApprovedAddress;&#13;
    // token owner =&gt; (operator address =&gt; bool)&#13;
    mapping(address =&gt; mapping(address =&gt; bool)) internal tokenOwnerToOperators;&#13;
    // Mapping from owner to list of owned token IDs&#13;
    mapping(address =&gt; uint32[]) internal ownedTokens;&#13;
}&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
//MokenERC998ERC721TopDown&#13;
//MokenERC998ERC721TopDownBatch&#13;
//MokenERC721&#13;
//MokenERC721Batch&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
contract Storage5 is Storage4 {&#13;
    // tokenId =&gt; (child address =&gt; array of child tokens)&#13;
    mapping(uint256 =&gt; mapping(address =&gt; uint256[])) internal childTokens;&#13;
    // tokenId =&gt; (child address =&gt; (child token =&gt; child index)&#13;
    mapping(uint256 =&gt; mapping(address =&gt; mapping(uint256 =&gt; uint256))) internal childTokenIndex;&#13;
    // tokenId =&gt; (child address =&gt; contract index)&#13;
    mapping(uint256 =&gt; mapping(address =&gt; uint256)) internal childContractIndex;&#13;
    // tokenId =&gt; child contract&#13;
    mapping(uint256 =&gt; address[]) internal childContracts;&#13;
}&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
//MokenERC998ERC20TopDown&#13;
//MokenStateChange&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
contract Storage6 is Storage5 {&#13;
    // tokenId =&gt; token contract&#13;
    mapping(uint256 =&gt; address[]) internal erc20Contracts;&#13;
    // tokenId =&gt; (token contract =&gt; token contract index)&#13;
    mapping(uint256 =&gt; mapping(address =&gt; uint256)) erc20ContractIndex;&#13;
    // tokenId =&gt; (token contract =&gt; balance)&#13;
    mapping(uint256 =&gt; mapping(address =&gt; uint256)) internal erc20Balances;&#13;
}&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
//MokenERC998ERC721BottomUp&#13;
//MokenERC998ERC721BottomUpBatch&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
contract Storage7 is Storage6 {&#13;
    // parent address =&gt; (parent tokenId =&gt; array of child tokenIds)&#13;
    mapping(address =&gt; mapping(uint256 =&gt; uint32[])) internal parentToChildTokenIds;&#13;
    // tokenId =&gt; position in childTokens array&#13;
    mapping(uint256 =&gt; uint256) internal tokenIdToChildTokenIdsIndex;&#13;
}&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
//MokenMinting&#13;
//MokenMintContractManagement&#13;
//MokenEras&#13;
//QueryMokenData&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
contract Storage8 is Storage7 {&#13;
    // index =&gt; era&#13;
    mapping(uint256 =&gt; bytes32) internal eras;&#13;
    uint256 internal eraLength;&#13;
    // era =&gt; index+1&#13;
    mapping(bytes32 =&gt; uint256) internal eraIndex;&#13;
    uint256 internal mintPriceOffset; // = 0 szabo;&#13;
    uint256 internal mintStepPrice; // = 500 szabo;&#13;
    uint256 internal mintPriceBuffer; // = 5000 szabo;&#13;
    address[] internal mintContracts;&#13;
    mapping(address =&gt; uint256) internal mintContractIndex;&#13;
    //moken name =&gt; tokenId+1&#13;
    mapping(string =&gt; uint256) internal tokenByName_;&#13;
}&#13;
contract MokenMintingOneFree is Storage8 {&#13;
&#13;
    uint256 constant MAX_MOKENS = 4294967296;&#13;
    uint256 constant MAX_OWNER_MOKENS = 65536;&#13;
    uint256 constant MOKEN_LINK_HASH_MASK = 0xffffffffffffffff000000000000000000000000000000000000000000000000;&#13;
&#13;
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);&#13;
&#13;
    event Mint(&#13;
        address indexed mintContract,&#13;
        address indexed owner,&#13;
        bytes32 indexed era,&#13;
        string mokenName,&#13;
        bytes32 data,&#13;
        uint256 tokenId,&#13;
        bytes32 currencyName,&#13;
        uint256 price&#13;
    );&#13;
&#13;
    event MintPriceChange(&#13;
        uint256 mintPrice&#13;
    );&#13;
&#13;
    event MintPriceConfigurationChange(&#13;
        uint256 mintPrice,&#13;
        uint256 mintStepPrice,&#13;
        uint256 mintPriceOffset,&#13;
        uint256 mintPriceBuffer&#13;
    );&#13;
&#13;
    event NewEra(&#13;
        uint256 index,&#13;
        bytes32 name,&#13;
        uint256 startTokenId&#13;
    );&#13;
&#13;
    function setMintPrice(uint256 _mintPrice) external returns (uint256 mintPrice) {&#13;
        require(msg.sender == contractOwner, "Must own Mokens contract.");&#13;
        mintPriceBuffer = _mintPrice;&#13;
        mintStepPrice = 0;&#13;
        mintPriceOffset = 0;&#13;
        emit MintPriceConfigurationChange(_mintPrice, 0, 0, 0);&#13;
        emit MintPriceChange(_mintPrice);&#13;
        return _mintPrice;&#13;
    }&#13;
&#13;
    function startNextEra_(bytes32 _eraName) internal returns (uint256 index, uint256 startTokenId) {&#13;
        require(_eraName != 0, "eraName is empty string.");&#13;
        require(eraIndex[_eraName] == 0, "Era name already exists.");&#13;
        startTokenId = mokensLength;&#13;
        index = eraLength++;&#13;
        eras[index] = _eraName;&#13;
        eraIndex[_eraName] = index + 1;&#13;
        emit NewEra(index, _eraName, startTokenId);&#13;
        return (index, startTokenId);&#13;
    }&#13;
&#13;
    // It is predicted that often a new era comes with a mint price change&#13;
    function startNextEra(bytes32 _eraName, uint256 _mintPrice) external&#13;
    returns (uint256 index, uint256 startTokenId, uint256 mintPrice) {&#13;
        require(msg.sender == contractOwner, "Must own Mokens contract.");&#13;
        mintPriceBuffer = _mintPrice;&#13;
        mintStepPrice = 0;&#13;
        mintPriceOffset = 0;&#13;
        emit MintPriceConfigurationChange(_mintPrice, 0, 0, 0);&#13;
        emit MintPriceChange(_mintPrice);&#13;
        (index, startTokenId) = startNextEra_(_eraName);&#13;
        return (index, startTokenId, _mintPrice);&#13;
    }&#13;
&#13;
    function mintData() external view returns (uint256 mokensLength_, uint256 mintStepPrice_, uint256 mintPriceOffset_) {&#13;
        return (mokensLength, 0, 0);&#13;
    }&#13;
&#13;
    function mintPrice() external view returns (uint256) {&#13;
        return mintPriceBuffer;&#13;
    }&#13;
&#13;
    function mint(address _tokenOwner, string _mokenName, bytes32 _linkHash) external payable returns (uint256 tokenId) {&#13;
&#13;
        require(_tokenOwner != address(0), "Owner cannot be the 0 address.");&#13;
&#13;
        tokenId = mokensLength++;&#13;
        // prevents 32 bit overflow&#13;
        require(tokenId &lt; MAX_MOKENS, "Only 4,294,967,296 mokens can be created.");&#13;
&#13;
        //Was enough ether passed in?&#13;
        uint256 currentMintPrice = mintPriceBuffer;&#13;
        uint256 ownedTokensIndex = ownedTokens[_tokenOwner].length;&#13;
        uint256 pricePaid;&#13;
        if(ownedTokensIndex == 0) {&#13;
            pricePaid = 0;&#13;
        }&#13;
        else {&#13;
            pricePaid = currentMintPrice;&#13;
            require(msg.value &gt;= currentMintPrice, "Paid ether is lower than mint price.");&#13;
        }&#13;
&#13;
        string memory lowerMokenName = validateAndLower(_mokenName);&#13;
        require(tokenByName_[lowerMokenName] == 0, "Moken name already exists.");&#13;
&#13;
        uint256 eraIndex_ = eraLength - 1;&#13;
&#13;
        // prevents 16 bit overflow&#13;
        require(ownedTokensIndex &lt; MAX_OWNER_MOKENS, "An single owner address cannot possess more than 65,536 mokens.");&#13;
&#13;
        // adding the current era index, ownedTokenIndex and owner address to data&#13;
        // this saves gas for each mint.&#13;
        uint256 data = uint256(_linkHash) &amp; MOKEN_LINK_HASH_MASK | eraIndex_ &lt;&lt; 176 | ownedTokensIndex &lt;&lt; 160 | uint160(_tokenOwner);&#13;
&#13;
        // create moken&#13;
        mokens[tokenId].name = _mokenName;&#13;
        mokens[tokenId].data = data;&#13;
        tokenByName_[lowerMokenName] = tokenId + 1;&#13;
&#13;
        //add moken to the specific owner&#13;
        ownedTokens[_tokenOwner].push(uint32(tokenId));&#13;
&#13;
        //emit events&#13;
        emit Transfer(address(0), _tokenOwner, tokenId);&#13;
        emit Mint(this, _tokenOwner, eras[eraIndex_], _mokenName, bytes32(data), tokenId, "Ether", pricePaid);&#13;
&#13;
        //send minter the change if any&#13;
        if (msg.value &gt; pricePaid) {&#13;
            msg.sender.transfer(msg.value - pricePaid);&#13;
        }&#13;
&#13;
        return tokenId;&#13;
    }&#13;
&#13;
&#13;
    function validateAndLower(string _s) internal pure returns (string mokenName) {&#13;
        assembly {&#13;
        // get length of _s&#13;
            let len := mload(_s)&#13;
        // get position of _s&#13;
            let p := add(_s, 0x20)&#13;
        // _s cannot be 0 characters&#13;
            if eq(len, 0) {&#13;
                revert(0, 0)&#13;
            }&#13;
        // _s cannot be more than 100 characters&#13;
            if gt(len, 100) {&#13;
                revert(0, 0)&#13;
            }&#13;
        // get first character&#13;
            let b := byte(0, mload(add(_s, 0x20)))&#13;
        // first character cannot be whitespace/unprintable&#13;
            if lt(b, 0x21) {&#13;
                revert(0, 0)&#13;
            }&#13;
        // get last character&#13;
            b := byte(0, mload(add(p, sub(len, 1))))&#13;
        // last character cannot be whitespace/unprintable&#13;
            if lt(b, 0x21) {&#13;
                revert(0, 0)&#13;
            }&#13;
        // loop through _s and lowercase uppercase characters&#13;
            for {let end := add(p, len)}&#13;
            lt(p, end)&#13;
            {p := add(p, 1)}&#13;
            {&#13;
                b := byte(0, mload(p))&#13;
                if lt(b, 0x5b) {&#13;
                    if gt(b, 0x40) {&#13;
                        mstore8(p, add(b, 32))&#13;
                    }&#13;
                }&#13;
            }&#13;
        }&#13;
        return _s;&#13;
    }&#13;
}
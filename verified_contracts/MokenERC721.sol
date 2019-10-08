pragma solidity 0.4.24;
pragma experimental "v0.5.0";
/******************************************************************************\
* Author: Nick Mudge, <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="bed0d7ddd5fed3d1d5dbd0cd90d7d1">[email protected]</a>&#13;
* Mokens&#13;
* Copyright (c) 2018&#13;
*&#13;
* Implements the ERC721 standard.&#13;
/******************************************************************************/&#13;
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
&#13;
contract RootOwnerOfHelper is Storage3 {&#13;
&#13;
    bytes32 constant ERC998_MAGIC_VALUE = 0xcd740db5;&#13;
&#13;
    // Use Cases handled:&#13;
    // Case 1: Token owner is this contract and token&#13;
    // Case 2: Token owner is this contract and top-down composable.&#13;
    // Case 3: Token owner is top-down composable&#13;
    // Case 4: Token owner is an unknown contract&#13;
    // Case 5: Token owner is a user&#13;
    // Case 6: Token owner is a bottom-up composable&#13;
    // Case 7: Token owner is ERC721 token owned by top-down token&#13;
    // Case 8: Token owner is ERC721 token owned by unknown contract&#13;
    // Case 9: Token owner is ERC721 token owned by user&#13;
    function rootOwnerOf_(uint256 _tokenId) internal view returns (bytes32 rootOwner) {&#13;
        address rootOwnerAddress = address(mokens[_tokenId].data);&#13;
        require(rootOwnerAddress != address(0), "tokenId not found.");&#13;
        uint256 parentTokenId;&#13;
        bool isParent;&#13;
&#13;
        while (rootOwnerAddress == address(this)) {&#13;
            parentTokenId = mokens[_tokenId].parentTokenId;&#13;
            isParent = parentTokenId &gt; 0;&#13;
            if (isParent) {&#13;
                // Case 1: Token owner is this contract and token&#13;
                _tokenId = parentTokenId - 1;&#13;
            }&#13;
            else {&#13;
                // Case 2: Token owner is this contract and top-down composable.&#13;
                _tokenId = childTokenOwner[rootOwnerAddress][_tokenId] - 1;&#13;
            }&#13;
            rootOwnerAddress = address(mokens[_tokenId].data);&#13;
        }&#13;
&#13;
        parentTokenId = mokens[_tokenId].parentTokenId;&#13;
        isParent = parentTokenId &gt; 0;&#13;
        if (isParent) {&#13;
            parentTokenId--;&#13;
        }&#13;
&#13;
        bytes memory calldata;&#13;
        bool callSuccess;&#13;
&#13;
        if (isParent == false) {&#13;
&#13;
            // success if this token is owned by a top-down token&#13;
            // 0xed81cdda == rootOwnerOfChild(address,uint256)&#13;
            calldata = abi.encodeWithSelector(0xed81cdda, address(this), _tokenId);&#13;
            assembly {&#13;
                callSuccess := staticcall(gas, rootOwnerAddress, add(calldata, 0x20), mload(calldata), calldata, 0x20)&#13;
                if callSuccess {&#13;
                    rootOwner := mload(calldata)&#13;
                }&#13;
            }&#13;
            if (callSuccess == true &amp;&amp; rootOwner &gt;&gt; 224 == ERC998_MAGIC_VALUE) {&#13;
                // Case 3: Token owner is top-down composable&#13;
                return rootOwner;&#13;
            }&#13;
            else {&#13;
                // Case 4: Token owner is an unknown contract&#13;
                // Or&#13;
                // Case 5: Token owner is a user&#13;
                return ERC998_MAGIC_VALUE &lt;&lt; 224 | bytes32(rootOwnerAddress);&#13;
            }&#13;
        }&#13;
        else {&#13;
&#13;
            // 0x43a61a8e == rootOwnerOf(uint256)&#13;
            calldata = abi.encodeWithSelector(0x43a61a8e, parentTokenId);&#13;
            assembly {&#13;
                callSuccess := staticcall(gas, rootOwnerAddress, add(calldata, 0x20), mload(calldata), calldata, 0x20)&#13;
                if callSuccess {&#13;
                    rootOwner := mload(calldata)&#13;
                }&#13;
            }&#13;
            if (callSuccess == true &amp;&amp; rootOwner &gt;&gt; 224 == ERC998_MAGIC_VALUE) {&#13;
                // Case 6: Token owner is a bottom-up composable&#13;
                // Or&#13;
                // Case 2: Token owner is top-down composable&#13;
                return rootOwner;&#13;
            }&#13;
            else {&#13;
                // token owner is ERC721&#13;
                address childContract = rootOwnerAddress;&#13;
                //0x6352211e == "ownerOf(uint256)"&#13;
                calldata = abi.encodeWithSelector(0x6352211e, parentTokenId);&#13;
                assembly {&#13;
                    callSuccess := staticcall(gas, rootOwnerAddress, add(calldata, 0x20), mload(calldata), calldata, 0x20)&#13;
                    if callSuccess {&#13;
                        rootOwnerAddress := mload(calldata)&#13;
                    }&#13;
                }&#13;
                require(callSuccess, "Call to ownerOf failed");&#13;
&#13;
                // 0xed81cdda == rootOwnerOfChild(address,uint256)&#13;
                calldata = abi.encodeWithSelector(0xed81cdda, childContract, parentTokenId);&#13;
                assembly {&#13;
                    callSuccess := staticcall(gas, rootOwnerAddress, add(calldata, 0x20), mload(calldata), calldata, 0x20)&#13;
                    if callSuccess {&#13;
                        rootOwner := mload(calldata)&#13;
                    }&#13;
                }&#13;
                if (callSuccess == true &amp;&amp; rootOwner &gt;&gt; 224 == ERC998_MAGIC_VALUE) {&#13;
                    // Case 7: Token owner is ERC721 token owned by top-down token&#13;
                    return rootOwner;&#13;
                }&#13;
                else {&#13;
                    // Case 8: Token owner is ERC721 token owned by unknown contract&#13;
                    // Or&#13;
                    // Case 9: Token owner is ERC721 token owned by user&#13;
                    return ERC998_MAGIC_VALUE &lt;&lt; 224 | bytes32(rootOwnerAddress);&#13;
                }&#13;
            }&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
contract MokenHelpers is Storage4, RootOwnerOfHelper {&#13;
&#13;
    bytes4 constant ERC721_RECEIVED_NEW = 0x150b7a02;&#13;
&#13;
    uint256 constant UINT16_MASK = 0x000000000000000000000000000000000000000000000000000000000000ffff;&#13;
    uint256 constant MAX_OWNER_MOKENS = 65536;&#13;
&#13;
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);&#13;
    event Approval(address indexed tokenOwner, address indexed approved, uint256 indexed tokenId);&#13;
&#13;
    function childApproved(address _from, uint256 _tokenId) internal {&#13;
        address approvedAddress = rootOwnerAndTokenIdToApprovedAddress[_from][_tokenId];&#13;
        if(msg.sender != _from) {&#13;
            bytes32 tokenOwner;&#13;
            bool callSuccess;&#13;
            // 0xeadb80b8 == ownerOfChild(address,uint256)&#13;
            bytes memory calldata = abi.encodeWithSelector(0xed81cdda, address(this), _tokenId);&#13;
            assembly {&#13;
                callSuccess := staticcall(gas, _from, add(calldata, 0x20), mload(calldata), calldata, 0x20)&#13;
                if callSuccess {&#13;
                    tokenOwner := mload(calldata)&#13;
                }&#13;
            }&#13;
            if(callSuccess == true) {&#13;
                require(tokenOwner &gt;&gt; 224 != ERC998_MAGIC_VALUE, "Token is child of top down composable");&#13;
            }&#13;
            require(tokenOwnerToOperators[_from][msg.sender] || approvedAddress == msg.sender, "msg.sender not _from/operator/approved.");&#13;
        }&#13;
        if (approvedAddress != address(0)) {&#13;
            delete rootOwnerAndTokenIdToApprovedAddress[_from][_tokenId];&#13;
            emit Approval(_from, address(0), _tokenId);&#13;
        }&#13;
    }&#13;
&#13;
&#13;
    function _transferFrom(uint256 data, address _to, uint256 _tokenId) internal {&#13;
        address _from = address(data);&#13;
        //removing the tokenId&#13;
        // 1. We replace _tokenId in ownedTokens[_from] with the last token id&#13;
        //    in ownedTokens[_from]&#13;
        uint256 lastTokenIndex = ownedTokens[_from].length - 1;&#13;
        uint256 lastTokenId = ownedTokens[_from][lastTokenIndex];&#13;
        if (lastTokenId != _tokenId) {&#13;
            uint256 tokenIndex = data &gt;&gt; 160 &amp; UINT16_MASK;&#13;
            ownedTokens[_from][tokenIndex] = uint32(lastTokenId);&#13;
            // 2. We set lastTokeId to point to its new position in ownedTokens[_from]&#13;
            mokens[lastTokenId].data = mokens[lastTokenId].data &amp; 0xffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffff | tokenIndex &lt;&lt; 160;&#13;
        }&#13;
        // 3. We remove lastTokenId from the end of ownedTokens[_from]&#13;
        ownedTokens[_from].length--;&#13;
&#13;
        //adding the tokenId&#13;
        uint256 ownedTokensIndex = ownedTokens[_to].length;&#13;
        // prevents 16 bit overflow&#13;
        require(ownedTokensIndex &lt; MAX_OWNER_MOKENS, "A token owner address cannot possess more than 65,536 mokens.");&#13;
        mokens[_tokenId].data = data &amp; 0xffffffffffffffffffff00000000000000000000000000000000000000000000 | ownedTokensIndex &lt;&lt; 160 | uint256(_to);&#13;
        ownedTokens[_to].push(uint32(_tokenId));&#13;
&#13;
        emit Transfer(_from, _to, _tokenId);&#13;
    }&#13;
&#13;
    function isContract(address addr) internal view returns (bool) {&#13;
        uint256 size;&#13;
        assembly {size := extcodesize(addr)}&#13;
        return size &gt; 0;&#13;
    }&#13;
}&#13;
&#13;
interface ERC721TokenReceiver {&#13;
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns (bytes4);&#13;
}&#13;
&#13;
contract MokenERC721 is Storage5, MokenHelpers {&#13;
&#13;
    event ReceivedChild(address indexed from, uint256 indexed tokenId, address indexed childContract, uint256 childTokenId);&#13;
    event ApprovalForAll(address indexed tokenOwner, address indexed operator, bool approved);&#13;
&#13;
    function balanceOf(address _tokenOwner) external view returns (uint256 totalMokensOwned) {&#13;
        require(_tokenOwner != address(0), "Moken owner cannot be the 0 address.");&#13;
        return ownedTokens[_tokenOwner].length;&#13;
    }&#13;
&#13;
    function ownerOf(uint256 _tokenId) external view returns (address tokenOwner) {&#13;
        tokenOwner = address(mokens[_tokenId].data);&#13;
        require(tokenOwner != address(0), "The tokenId does not exist.");&#13;
        return tokenOwner;&#13;
    }&#13;
&#13;
    function receiveChild(address _from, uint256 _toTokenId, address _childContract, uint256 _childTokenId) internal {&#13;
        require(address(mokens[_toTokenId].data) != address(0), "_tokenId does not exist.");&#13;
        require(childTokenOwner[_childContract][_childTokenId] == 0, "Child token already received.");&#13;
        uint256 childTokensLength = childTokens[_toTokenId][_childContract].length;&#13;
        if (childTokensLength == 0) {&#13;
            childContractIndex[_toTokenId][_childContract] = childContracts[_toTokenId].length;&#13;
            childContracts[_toTokenId].push(_childContract);&#13;
        }&#13;
        childTokenIndex[_toTokenId][_childContract][_childTokenId] = childTokensLength;&#13;
        childTokens[_toTokenId][_childContract].push(_childTokenId);&#13;
        childTokenOwner[_childContract][_childTokenId] = _toTokenId + 1;&#13;
        emit ReceivedChild(_from, _toTokenId, _childContract, _childTokenId);&#13;
    }&#13;
&#13;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) external {&#13;
        require(_from != address(0), "_from cannot be the 0 address.");&#13;
        require(_to != address(0), "_to cannot be the 0 address.");&#13;
        uint256 data = mokens[_tokenId].data;&#13;
        require(address(data) == _from, "The tokenId is not owned by _from.");&#13;
        require(mokens[_tokenId].parentTokenId == 0, "Cannot transfer from an address when owned by a token.");&#13;
        childApproved(_from, _tokenId);&#13;
        _transferFrom(data, _to, _tokenId);&#13;
        if (_to == address(this)) {&#13;
            require(_data.length &gt; 0, "_data must contain the uint256 tokenId to transfer the token to.");&#13;
            uint256 toTokenId;&#13;
            assembly {toTokenId := calldataload(164)}&#13;
            if (_data.length &lt; 32) {&#13;
                toTokenId = toTokenId &gt;&gt; 256 - _data.length * 8;&#13;
            }&#13;
            receiveChild(_from, toTokenId, _to, _tokenId);&#13;
        }&#13;
        else {&#13;
            if (isContract(_to)) {&#13;
                bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);&#13;
                require(retval == ERC721_RECEIVED_NEW, "_to contract cannot receive ERC721 tokens.");&#13;
            }&#13;
        }&#13;
&#13;
    }&#13;
&#13;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external {&#13;
        require(_from != address(0), "_from cannot be the 0 address.");&#13;
        require(_to != address(0), "_to cannot be the 0 address.");&#13;
        uint256 data = mokens[_tokenId].data;&#13;
        require(address(data) == _from, "The tokenId is not owned by _from.");&#13;
        require(mokens[_tokenId].parentTokenId == 0, "Cannot transfer from an address when owned by a token.");&#13;
        childApproved(_from, _tokenId);&#13;
        _transferFrom(data, _to, _tokenId);&#13;
        if (isContract(_to)) {&#13;
            bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, "");&#13;
            require(retval == ERC721_RECEIVED_NEW, "_to contract cannot receive ERC721 tokens.");&#13;
        }&#13;
    }&#13;
&#13;
    function transferFrom(address _from, address _to, uint256 _tokenId) external {&#13;
        require(_from != address(0), "_from cannot be the 0 address.");&#13;
        require(_to != address(0), "_to cannot be the 0 address.");&#13;
        uint256 data = mokens[_tokenId].data;&#13;
        require(address(data) == _from, "The tokenId is not owned by _from.");&#13;
        require(_to != address(this), "Cannot transfer to this contract.");&#13;
        require(mokens[_tokenId].parentTokenId == 0, "Cannot transfer from an address when owned by a token.");&#13;
        childApproved(_from, _tokenId);&#13;
        _transferFrom(data, _to, _tokenId);&#13;
    }&#13;
&#13;
    function approve(address _approved, uint256 _tokenId) external {&#13;
        address rootOwner = address(rootOwnerOf_(_tokenId));&#13;
        require(rootOwner == msg.sender || tokenOwnerToOperators[rootOwner][msg.sender], "Must be rootOwner or operator.");&#13;
        rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId] = _approved;&#13;
        emit Approval(rootOwner, _approved, _tokenId);&#13;
    }&#13;
&#13;
    function setApprovalForAll(address _operator, bool _approved) external {&#13;
        require(_operator != address(0), "Operator cannot be 0 address.");&#13;
        tokenOwnerToOperators[msg.sender][_operator] = _approved;&#13;
        emit ApprovalForAll(msg.sender, _operator, _approved);&#13;
    }&#13;
&#13;
    function getApproved(uint256 _tokenId) external view returns (address approvedAddress) {&#13;
        address rootOwner = address(rootOwnerOf_(_tokenId));&#13;
        return rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId];&#13;
    }&#13;
&#13;
    function isApprovedForAll(address _tokenOwner, address _operator) external view returns (bool approved) {&#13;
        return tokenOwnerToOperators[_tokenOwner][_operator];&#13;
    }&#13;
}
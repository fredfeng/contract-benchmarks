pragma solidity 0.4.24;
pragma experimental "v0.5.0";
/******************************************************************************\
* Author: Nick Mudge, <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c7a9aea4ac87aaa8aca2a9b4e9aea8">[email protected]</a>&#13;
* Mokens&#13;
* Copyright (c) 2018&#13;
*&#13;
* Implements ERC721Metadata.&#13;
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
&#13;
contract MokenERC721Metadata is Storage3 {&#13;
    function name() external pure returns (string) {&#13;
        return "Mokens";&#13;
    }&#13;
&#13;
    function symbol() external pure returns (string) {&#13;
        return "MKN";&#13;
    }&#13;
&#13;
    function tokenURI(uint256 _tokenId) external view returns (string tokenURIString) {&#13;
        require(_tokenId &lt; mokensLength, "_tokenId does not exist.");&#13;
        uint256 v = _tokenId;&#13;
        uint256 maxlength;&#13;
        bytes memory reversed = new bytes(maxlength);&#13;
        uint256 numDigits;&#13;
        if (v == 0) {&#13;
            numDigits = 1;&#13;
            reversed[0] = byte(48);&#13;
        }&#13;
        else {&#13;
            while (v != 0) {&#13;
                uint256 remainder = v % 10;&#13;
                v = v / 10;&#13;
                reversed[numDigits++] = byte(48 + remainder);&#13;
            }&#13;
        }&#13;
        bytes memory startStringBytes = "https://api.mokens.io/moken/";&#13;
        bytes memory endStringBytes = ".json";&#13;
        uint256 startStringLength = startStringBytes.length;&#13;
        uint256 endStringLength = endStringBytes.length;&#13;
        bytes memory newStringBytes = new bytes(startStringLength + numDigits + endStringLength);&#13;
        uint256 i;&#13;
        for (i = 0; i &lt; startStringLength; i++) {&#13;
            newStringBytes[i] = startStringBytes[i];&#13;
        }&#13;
        for (i = 0; i &lt; numDigits; i++) {&#13;
            newStringBytes[i + startStringLength] = reversed[numDigits - 1 - i];&#13;
        }&#13;
        for (i = 0; i &lt; endStringLength; i++) {&#13;
            newStringBytes[i + startStringLength + numDigits] = endStringBytes[i];&#13;
        }&#13;
        return string(newStringBytes);&#13;
    }&#13;
}
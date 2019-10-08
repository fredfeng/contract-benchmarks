pragma solidity 0.4.24;
pragma experimental "v0.5.0";
/******************************************************************************\
* Author: Nick Mudge, <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="17797e747c577a787c727964397e78">[email protected]</a>&#13;
* Copyright (c) 2018&#13;
*&#13;
* The QueryMokenDelegates contract contains functions for retrieving function&#13;
* signatures and delegate contract addresses used by the Mokens contract.&#13;
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
    string[] internal functionSignatures;&#13;
    // signature =&gt; index+1&#13;
    mapping(string =&gt; uint256) internal functionSignatureToIndex;&#13;
}&#13;
&#13;
contract QueryMokenDelegates is Storage1 {&#13;
&#13;
    function totalFunctions() external view returns(uint256) {&#13;
        return functionSignatures.length;&#13;
    }&#13;
&#13;
    function functionByIndex(uint256 _index) external view returns(string memory signature, bytes4 functionId, address delegate) {&#13;
        require(_index &lt; functionSignatures.length, "functionSignatures index does not exist.");&#13;
        signature = functionSignatures[_index];&#13;
        functionId = bytes4(keccak256(bytes(signature)));&#13;
        delegate = delegates[functionId];&#13;
        return (signature, functionId, delegate);&#13;
    }&#13;
&#13;
    function functionExists(string signature) external view returns(bool) {&#13;
        return functionSignatureToIndex[signature] != 0;&#13;
    }&#13;
&#13;
    function getFunctions() external view returns(string) {&#13;
        uint256 functionSignaturesSize = 0;&#13;
        bytes memory functionSignaturesBytes;&#13;
        bytes memory functionSignatureBytes;&#13;
        uint256 functionIndex = 0;&#13;
        uint256 charPos = 0;&#13;
        for(; functionIndex &lt; functionSignatures.length; functionIndex++) {&#13;
            functionSignaturesSize += bytes(functionSignatures[functionIndex]).length;&#13;
        }&#13;
        functionSignaturesBytes = new bytes(functionSignaturesSize);&#13;
        functionIndex = 0;&#13;
        for(; functionIndex &lt; functionSignatures.length; functionIndex++) {&#13;
            functionSignatureBytes = bytes(functionSignatures[functionIndex]);&#13;
            for(uint256 i = 0; i &lt; functionSignatureBytes.length; i++) {&#13;
                functionSignaturesBytes[charPos] = functionSignatureBytes[i];&#13;
                charPos++;&#13;
            }&#13;
        }&#13;
        return string(functionSignaturesBytes);&#13;
    }&#13;
&#13;
    function getDelegateFunctions(address _delegate) external view returns(string) {&#13;
        bytes[] memory delegateFunctionSignatures = new bytes[](functionSignatures.length);&#13;
        uint256 delegateFunctionSignaturesPos = 0;&#13;
        uint256 functionSignaturesSize = 0;&#13;
        bytes memory functionSignaturesBytes;&#13;
        bytes memory functionSignatureBytes;&#13;
        uint256 functionIndex = 0;&#13;
        uint256 charPos = 0;&#13;
        for(; functionIndex &lt; functionSignatures.length; functionIndex++) {&#13;
            functionSignatureBytes = bytes(functionSignatures[functionIndex]);&#13;
            if(_delegate == delegates[bytes4(keccak256(functionSignatureBytes))]) {&#13;
                functionSignaturesSize += functionSignatureBytes.length;&#13;
                delegateFunctionSignatures[delegateFunctionSignaturesPos] = functionSignatureBytes;&#13;
                delegateFunctionSignaturesPos++;&#13;
            }&#13;
&#13;
        }&#13;
        functionSignaturesBytes = new bytes(functionSignaturesSize);&#13;
        functionIndex = 0;&#13;
        for(; functionIndex &lt; delegateFunctionSignatures.length; functionIndex++) {&#13;
            functionSignatureBytes = delegateFunctionSignatures[functionIndex];&#13;
            if(functionSignatureBytes.length == 0) {&#13;
                break;&#13;
            }&#13;
            for(uint256 i = 0; i &lt; functionSignatureBytes.length; i++) {&#13;
                functionSignaturesBytes[charPos] = functionSignatureBytes[i];&#13;
                charPos++;&#13;
            }&#13;
        }&#13;
        return string(functionSignaturesBytes);&#13;
    }&#13;
&#13;
    function getDelegate(string signature) external view returns(address) {&#13;
        require(functionSignatureToIndex[signature] != 0, "Function signature not found.");&#13;
        return delegates[bytes4(keccak256(bytes(signature)))];&#13;
    }&#13;
&#13;
    function getFunctionBySignature(string signature) external view returns(bytes4 functionId, address delegate) {&#13;
        require(functionSignatureToIndex[signature] != 0, "Function signature not found.");&#13;
        functionId = bytes4(keccak256(bytes(signature)));&#13;
        return (functionId,delegates[functionId]);&#13;
    }&#13;
&#13;
    function getFunctionById(bytes4 functionId) external view returns(string signature, address delegate) {&#13;
        for(uint256 i = 0; i &lt; functionSignatures.length; i++) {&#13;
            if(functionId == keccak256(bytes(functionSignatures[i]))) {&#13;
                return (functionSignatures[i], delegates[functionId]);&#13;
            }&#13;
        }&#13;
        revert("functionId not found");&#13;
    }&#13;
&#13;
    function getDelegates() external view returns(address[]) {&#13;
        uint256 functionSignaturesNum = functionSignatures.length;&#13;
        address[] memory delegatesBucket = new address[](functionSignaturesNum);&#13;
        uint256 numDelegates = 0;&#13;
        uint256 functionIndex = 0;&#13;
        bool foundDelegate = false;&#13;
        address delegate;&#13;
        for(; functionIndex &lt; functionSignaturesNum; functionIndex++) {&#13;
            delegate = delegates[bytes4(keccak256(bytes(functionSignatures[functionIndex])))];&#13;
            for(uint256 i = 0; i &lt; numDelegates; i++) {&#13;
                if(delegate == delegatesBucket[i]) {&#13;
                    foundDelegate = true;&#13;
                    break;&#13;
                }&#13;
            }&#13;
            if(foundDelegate == false) {&#13;
                delegatesBucket[numDelegates] = delegate;&#13;
                numDelegates++;&#13;
            }&#13;
            else {&#13;
                foundDelegate = false;&#13;
            }&#13;
        }&#13;
        address[] memory delegates_ = new address[](numDelegates);&#13;
        functionIndex = 0;&#13;
        for(; functionIndex &lt; numDelegates; functionIndex++) {&#13;
            delegates_[functionIndex] = delegatesBucket[functionIndex];&#13;
        }&#13;
        return delegates_;&#13;
    }&#13;
}
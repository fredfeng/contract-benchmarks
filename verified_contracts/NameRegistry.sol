/*
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
pragma solidity 0.4.18;
/// @title Ethereum Address Register Contract
/// @dev This contract maintains a name service for addresses and miner.
/// @author Kongliang Zhong - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="503b3f3e373c39313e37103c3f3f2022393e377e3f2237">[email protected]</a>&gt;,&#13;
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c0a4a1aea9a5ac80acafafb0b2a9aea7eeafb2a7">[email protected]</a>&gt;,&#13;
contract NameRegistry {&#13;
    uint public nextId = 0;&#13;
    mapping (uint    =&gt; Participant) public participantMap;&#13;
    mapping (address =&gt; NameInfo)    public nameInfoMap;&#13;
    mapping (bytes12 =&gt; address)     public ownerMap;&#13;
    mapping (address =&gt; string)      public nameMap;&#13;
    struct NameInfo {&#13;
        bytes12  name;&#13;
        uint[]   participantIds;&#13;
    }&#13;
    struct Participant {&#13;
        address feeRecipient;&#13;
        address signer;&#13;
        bytes12 name;&#13;
        address owner;&#13;
    }&#13;
    event NameRegistered (&#13;
        string            name,&#13;
        address   indexed owner&#13;
    );&#13;
    event NameUnregistered (&#13;
        string             name,&#13;
        address    indexed owner&#13;
    );&#13;
    event OwnershipTransfered (&#13;
        bytes12            name,&#13;
        address            oldOwner,&#13;
        address            newOwner&#13;
    );&#13;
    event ParticipantRegistered (&#13;
        bytes12           name,&#13;
        address   indexed owner,&#13;
        uint      indexed participantId,&#13;
        address           singer,&#13;
        address           feeRecipient&#13;
    );&#13;
    event ParticipantUnregistered (&#13;
        uint    participantId,&#13;
        address owner&#13;
    );&#13;
    function registerName(string name)&#13;
        external&#13;
    {&#13;
        require(isNameValid(name));&#13;
        bytes12 nameBytes = stringToBytes12(name);&#13;
        require(ownerMap[nameBytes] == 0x0);&#13;
        require(stringToBytes12(nameMap[msg.sender]) == bytes12(0x0));&#13;
        nameInfoMap[msg.sender] = NameInfo(nameBytes, new uint[](0));&#13;
        ownerMap[nameBytes] = msg.sender;&#13;
        nameMap[msg.sender] = name;&#13;
        NameRegistered(name, msg.sender);&#13;
    }&#13;
    function unregisterName(string name)&#13;
        external&#13;
    {&#13;
        NameInfo storage nameInfo = nameInfoMap[msg.sender];&#13;
        uint[] storage participantIds = nameInfo.participantIds;&#13;
        bytes12 nameBytes = stringToBytes12(name);&#13;
        require(nameInfo.name == nameBytes);&#13;
        for (uint i = participantIds.length - 1; i &gt;= 0; i--) {&#13;
            delete participantMap[participantIds[i]];&#13;
        }&#13;
        delete nameInfoMap[msg.sender];&#13;
        delete nameMap[msg.sender];&#13;
        delete ownerMap[nameBytes];&#13;
        NameUnregistered(name, msg.sender);&#13;
    }&#13;
    function transferOwnership(address newOwner)&#13;
        external&#13;
    {&#13;
        require(newOwner != 0x0);&#13;
        require(nameInfoMap[newOwner].name.length == 0);&#13;
        NameInfo storage nameInfo = nameInfoMap[msg.sender];&#13;
        string storage name = nameMap[msg.sender];&#13;
        uint[] memory participantIds = nameInfo.participantIds;&#13;
        for (uint i = 0; i &lt; participantIds.length; i ++) {&#13;
            Participant storage p = participantMap[participantIds[i]];&#13;
            p.owner = newOwner;&#13;
        }&#13;
        delete nameInfoMap[msg.sender];&#13;
        delete nameMap[msg.sender];&#13;
        nameInfoMap[newOwner] = nameInfo;&#13;
        nameMap[newOwner] = name;&#13;
        OwnershipTransfered(nameInfo.name, msg.sender, newOwner);&#13;
    }&#13;
    /* function addParticipant(address feeRecipient) */&#13;
    /*     external */&#13;
    /*     returns (uint) */&#13;
    /* { */&#13;
    /*     return addParticipant(feeRecipient, feeRecipient); */&#13;
    /* } */&#13;
    function addParticipant(&#13;
        address feeRecipient,&#13;
        address singer&#13;
        )&#13;
        external&#13;
        returns (uint)&#13;
    {&#13;
        require(feeRecipient != 0x0 &amp;&amp; singer != 0x0);&#13;
        NameInfo storage nameInfo = nameInfoMap[msg.sender];&#13;
        bytes12 name = nameInfo.name;&#13;
        require(name.length &gt; 0);&#13;
        Participant memory participant = Participant(&#13;
            feeRecipient,&#13;
            singer,&#13;
            name,&#13;
            msg.sender&#13;
        );&#13;
        uint participantId = ++nextId;&#13;
        participantMap[participantId] = participant;&#13;
        nameInfo.participantIds.push(participantId);&#13;
        ParticipantRegistered(&#13;
            name,&#13;
            msg.sender,&#13;
            participantId,&#13;
            singer,&#13;
            feeRecipient&#13;
        );&#13;
        return participantId;&#13;
    }&#13;
    function removeParticipant(uint participantId)&#13;
        external&#13;
    {&#13;
        require(msg.sender == participantMap[participantId].owner);&#13;
        NameInfo storage nameInfo = nameInfoMap[msg.sender];&#13;
        uint[] storage participantIds = nameInfo.participantIds;&#13;
        delete participantMap[participantId];&#13;
        uint len = participantIds.length;&#13;
        for (uint i = 0; i &lt; len; i ++) {&#13;
            if (participantId == participantIds[i]) {&#13;
                participantIds[i] = participantIds[len - 1];&#13;
                participantIds.length -= 1;&#13;
            }&#13;
        }&#13;
        ParticipantUnregistered(participantId, msg.sender);&#13;
    }&#13;
    function getParticipantById(uint id)&#13;
        external&#13;
        view&#13;
        returns (address feeRecipient, address signer)&#13;
    {&#13;
        Participant storage addressSet = participantMap[id];&#13;
        feeRecipient = addressSet.feeRecipient;&#13;
        signer = addressSet.signer;&#13;
    }&#13;
    function getParticipantIds(string name, uint start, uint count)&#13;
        external&#13;
        view&#13;
        returns (uint[] idList)&#13;
    {&#13;
        bytes12 nameBytes = stringToBytes12(name);&#13;
        address owner = ownerMap[nameBytes];&#13;
        require(owner != 0x0);&#13;
        NameInfo storage nameInfo = nameInfoMap[owner];&#13;
        uint[] storage pIds = nameInfo.participantIds;&#13;
        uint len = pIds.length;&#13;
        if (start &gt;= len) {&#13;
            return;&#13;
        }&#13;
        uint end = start + count;&#13;
        if (end &gt; len) {&#13;
            end = len;&#13;
        }&#13;
        if (start == end) {&#13;
            return;&#13;
        }&#13;
        idList = new uint[](end - start);&#13;
        for (uint i = start; i &lt; end; i ++) {&#13;
            idList[i - start] = pIds[i];&#13;
        }&#13;
    }&#13;
    function getOwner(string name)&#13;
        external&#13;
        view&#13;
        returns (address)&#13;
    {&#13;
        bytes12 nameBytes = stringToBytes12(name);&#13;
        return ownerMap[nameBytes];&#13;
    }&#13;
    function isNameValid(string name)&#13;
        internal&#13;
        pure&#13;
        returns (bool)&#13;
    {&#13;
        bytes memory temp = bytes(name);&#13;
        return temp.length &gt;= 6 &amp;&amp; temp.length &lt;= 12;&#13;
    }&#13;
    function stringToBytes12(string str)&#13;
        internal&#13;
        pure&#13;
        returns (bytes12 result)&#13;
    {&#13;
        assembly {&#13;
            result := mload(add(str, 12))&#13;
        }&#13;
    }&#13;
}
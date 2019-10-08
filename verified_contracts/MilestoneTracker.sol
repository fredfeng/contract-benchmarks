pragma solidity ^0.4.6;

/*
    Copyright 2016, Jordi Baylina

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/// @title MilestoneTracker Contract
/// @author Jordi Baylina
/// @dev This contract tracks the


/// is rules the relation betwen a donor and a recipient
///  in order to guaranty to the donor that the job will be done and to guaranty
///  to the recipient that he will be paid


/// @dev We use the RLP library to decode RLP so that the donor can approve one
///  set of milestone changes at a time.
///  https://github.com/androlo/standard-contracts/blob/master/contracts/src/codec/RLP.sol


/**
* @title RLPReader
*
* RLPReader is used to read and parse RLP encoded data in memory.
*
* @author Andreas Olofsson (<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ccada2a8bea3a0a3fdf5f4fc8caba1ada5a0e2afa3a1">[email protected]</a>)&#13;
*/&#13;
library RLP {&#13;
&#13;
 uint constant DATA_SHORT_START = 0x80;&#13;
 uint constant DATA_LONG_START = 0xB8;&#13;
 uint constant LIST_SHORT_START = 0xC0;&#13;
 uint constant LIST_LONG_START = 0xF8;&#13;
&#13;
 uint constant DATA_LONG_OFFSET = 0xB7;&#13;
 uint constant LIST_LONG_OFFSET = 0xF7;&#13;
&#13;
&#13;
 struct RLPItem {&#13;
     uint _unsafe_memPtr;    // Pointer to the RLP-encoded bytes.&#13;
     uint _unsafe_length;    // Number of bytes. This is the full length of the string.&#13;
 }&#13;
&#13;
 struct Iterator {&#13;
     RLPItem _unsafe_item;   // Item that's being iterated over.&#13;
     uint _unsafe_nextPtr;   // Position of the next item in the list.&#13;
 }&#13;
&#13;
 /* Iterator */&#13;
&#13;
 function next(Iterator memory self) internal constant returns (RLPItem memory subItem) {&#13;
     if(hasNext(self)) {&#13;
         var ptr = self._unsafe_nextPtr;&#13;
         var itemLength = _itemLength(ptr);&#13;
         subItem._unsafe_memPtr = ptr;&#13;
         subItem._unsafe_length = itemLength;&#13;
         self._unsafe_nextPtr = ptr + itemLength;&#13;
     }&#13;
     else&#13;
         throw;&#13;
 }&#13;
&#13;
 function next(Iterator memory self, bool strict) internal constant returns (RLPItem memory subItem) {&#13;
     subItem = next(self);&#13;
     if(strict &amp;&amp; !_validate(subItem))&#13;
         throw;&#13;
     return;&#13;
 }&#13;
&#13;
 function hasNext(Iterator memory self) internal constant returns (bool) {&#13;
     var item = self._unsafe_item;&#13;
     return self._unsafe_nextPtr &lt; item._unsafe_memPtr + item._unsafe_length;&#13;
 }&#13;
&#13;
 /* RLPItem */&#13;
&#13;
 /// @dev Creates an RLPItem from an array of RLP encoded bytes.&#13;
 /// @param self The RLP encoded bytes.&#13;
 /// @return An RLPItem&#13;
 function toRLPItem(bytes memory self) internal constant returns (RLPItem memory) {&#13;
     uint len = self.length;&#13;
     if (len == 0) {&#13;
         return RLPItem(0, 0);&#13;
     }&#13;
     uint memPtr;&#13;
     assembly {&#13;
         memPtr := add(self, 0x20)&#13;
     }&#13;
     return RLPItem(memPtr, len);&#13;
 }&#13;
&#13;
 /// @dev Creates an RLPItem from an array of RLP encoded bytes.&#13;
 /// @param self The RLP encoded bytes.&#13;
 /// @param strict Will throw if the data is not RLP encoded.&#13;
 /// @return An RLPItem&#13;
 function toRLPItem(bytes memory self, bool strict) internal constant returns (RLPItem memory) {&#13;
     var item = toRLPItem(self);&#13;
     if(strict) {&#13;
         uint len = self.length;&#13;
         if(_payloadOffset(item) &gt; len)&#13;
             throw;&#13;
         if(_itemLength(item._unsafe_memPtr) != len)&#13;
             throw;&#13;
         if(!_validate(item))&#13;
             throw;&#13;
     }&#13;
     return item;&#13;
 }&#13;
&#13;
 /// @dev Check if the RLP item is null.&#13;
 /// @param self The RLP item.&#13;
 /// @return 'true' if the item is null.&#13;
 function isNull(RLPItem memory self) internal constant returns (bool ret) {&#13;
     return self._unsafe_length == 0;&#13;
 }&#13;
&#13;
 /// @dev Check if the RLP item is a list.&#13;
 /// @param self The RLP item.&#13;
 /// @return 'true' if the item is a list.&#13;
 function isList(RLPItem memory self) internal constant returns (bool ret) {&#13;
     if (self._unsafe_length == 0)&#13;
         return false;&#13;
     uint memPtr = self._unsafe_memPtr;&#13;
     assembly {&#13;
         ret := iszero(lt(byte(0, mload(memPtr)), 0xC0))&#13;
     }&#13;
 }&#13;
&#13;
 /// @dev Check if the RLP item is data.&#13;
 /// @param self The RLP item.&#13;
 /// @return 'true' if the item is data.&#13;
 function isData(RLPItem memory self) internal constant returns (bool ret) {&#13;
     if (self._unsafe_length == 0)&#13;
         return false;&#13;
     uint memPtr = self._unsafe_memPtr;&#13;
     assembly {&#13;
         ret := lt(byte(0, mload(memPtr)), 0xC0)&#13;
     }&#13;
 }&#13;
&#13;
 /// @dev Check if the RLP item is empty (string or list).&#13;
 /// @param self The RLP item.&#13;
 /// @return 'true' if the item is null.&#13;
 function isEmpty(RLPItem memory self) internal constant returns (bool ret) {&#13;
     if(isNull(self))&#13;
         return false;&#13;
     uint b0;&#13;
     uint memPtr = self._unsafe_memPtr;&#13;
     assembly {&#13;
         b0 := byte(0, mload(memPtr))&#13;
     }&#13;
     return (b0 == DATA_SHORT_START || b0 == LIST_SHORT_START);&#13;
 }&#13;
&#13;
 /// @dev Get the number of items in an RLP encoded list.&#13;
 /// @param self The RLP item.&#13;
 /// @return The number of items.&#13;
 function items(RLPItem memory self) internal constant returns (uint) {&#13;
     if (!isList(self))&#13;
         return 0;&#13;
     uint b0;&#13;
     uint memPtr = self._unsafe_memPtr;&#13;
     assembly {&#13;
         b0 := byte(0, mload(memPtr))&#13;
     }&#13;
     uint pos = memPtr + _payloadOffset(self);&#13;
     uint last = memPtr + self._unsafe_length - 1;&#13;
     uint itms;&#13;
     while(pos &lt;= last) {&#13;
         pos += _itemLength(pos);&#13;
         itms++;&#13;
     }&#13;
     return itms;&#13;
 }&#13;
&#13;
 /// @dev Create an iterator.&#13;
 /// @param self The RLP item.&#13;
 /// @return An 'Iterator' over the item.&#13;
 function iterator(RLPItem memory self) internal constant returns (Iterator memory it) {&#13;
     if (!isList(self))&#13;
         throw;&#13;
     uint ptr = self._unsafe_memPtr + _payloadOffset(self);&#13;
     it._unsafe_item = self;&#13;
     it._unsafe_nextPtr = ptr;&#13;
 }&#13;
&#13;
 /// @dev Return the RLP encoded bytes.&#13;
 /// @param self The RLPItem.&#13;
 /// @return The bytes.&#13;
 function toBytes(RLPItem memory self) internal constant returns (bytes memory bts) {&#13;
     var len = self._unsafe_length;&#13;
     if (len == 0)&#13;
         return;&#13;
     bts = new bytes(len);&#13;
     _copyToBytes(self._unsafe_memPtr, bts, len);&#13;
 }&#13;
&#13;
 /// @dev Decode an RLPItem into bytes. This will not work if the&#13;
 /// RLPItem is a list.&#13;
 /// @param self The RLPItem.&#13;
 /// @return The decoded string.&#13;
 function toData(RLPItem memory self) internal constant returns (bytes memory bts) {&#13;
     if(!isData(self))&#13;
         throw;&#13;
     var (rStartPos, len) = _decode(self);&#13;
     bts = new bytes(len);&#13;
     _copyToBytes(rStartPos, bts, len);&#13;
 }&#13;
&#13;
 /// @dev Get the list of sub-items from an RLP encoded list.&#13;
 /// Warning: This is inefficient, as it requires that the list is read twice.&#13;
 /// @param self The RLP item.&#13;
 /// @return Array of RLPItems.&#13;
 function toList(RLPItem memory self) internal constant returns (RLPItem[] memory list) {&#13;
     if(!isList(self))&#13;
         throw;&#13;
     var numItems = items(self);&#13;
     list = new RLPItem[](numItems);&#13;
     var it = iterator(self);&#13;
     uint idx;&#13;
     while(hasNext(it)) {&#13;
         list[idx] = next(it);&#13;
         idx++;&#13;
     }&#13;
 }&#13;
&#13;
 /// @dev Decode an RLPItem into an ascii string. This will not work if the&#13;
 /// RLPItem is a list.&#13;
 /// @param self The RLPItem.&#13;
 /// @return The decoded string.&#13;
 function toAscii(RLPItem memory self) internal constant returns (string memory str) {&#13;
     if(!isData(self))&#13;
         throw;&#13;
     var (rStartPos, len) = _decode(self);&#13;
     bytes memory bts = new bytes(len);&#13;
     _copyToBytes(rStartPos, bts, len);&#13;
     str = string(bts);&#13;
 }&#13;
&#13;
 /// @dev Decode an RLPItem into a uint. This will not work if the&#13;
 /// RLPItem is a list.&#13;
 /// @param self The RLPItem.&#13;
 /// @return The decoded string.&#13;
 function toUint(RLPItem memory self) internal constant returns (uint data) {&#13;
     if(!isData(self))&#13;
         throw;&#13;
     var (rStartPos, len) = _decode(self);&#13;
     if (len &gt; 32 || len == 0)&#13;
         throw;&#13;
     assembly {&#13;
         data := div(mload(rStartPos), exp(256, sub(32, len)))&#13;
     }&#13;
 }&#13;
&#13;
 /// @dev Decode an RLPItem into a boolean. This will not work if the&#13;
 /// RLPItem is a list.&#13;
 /// @param self The RLPItem.&#13;
 /// @return The decoded string.&#13;
 function toBool(RLPItem memory self) internal constant returns (bool data) {&#13;
     if(!isData(self))&#13;
         throw;&#13;
     var (rStartPos, len) = _decode(self);&#13;
     if (len != 1)&#13;
         throw;&#13;
     uint temp;&#13;
     assembly {&#13;
         temp := byte(0, mload(rStartPos))&#13;
     }&#13;
     if (temp &gt; 1)&#13;
         throw;&#13;
     return temp == 1 ? true : false;&#13;
 }&#13;
&#13;
 /// @dev Decode an RLPItem into a byte. This will not work if the&#13;
 /// RLPItem is a list.&#13;
 /// @param self The RLPItem.&#13;
 /// @return The decoded string.&#13;
 function toByte(RLPItem memory self) internal constant returns (byte data) {&#13;
     if(!isData(self))&#13;
         throw;&#13;
     var (rStartPos, len) = _decode(self);&#13;
     if (len != 1)&#13;
         throw;&#13;
     uint temp;&#13;
     assembly {&#13;
         temp := byte(0, mload(rStartPos))&#13;
     }&#13;
     return byte(temp);&#13;
 }&#13;
&#13;
 /// @dev Decode an RLPItem into an int. This will not work if the&#13;
 /// RLPItem is a list.&#13;
 /// @param self The RLPItem.&#13;
 /// @return The decoded string.&#13;
 function toInt(RLPItem memory self) internal constant returns (int data) {&#13;
     return int(toUint(self));&#13;
 }&#13;
&#13;
 /// @dev Decode an RLPItem into a bytes32. This will not work if the&#13;
 /// RLPItem is a list.&#13;
 /// @param self The RLPItem.&#13;
 /// @return The decoded string.&#13;
 function toBytes32(RLPItem memory self) internal constant returns (bytes32 data) {&#13;
     return bytes32(toUint(self));&#13;
 }&#13;
&#13;
 /// @dev Decode an RLPItem into an address. This will not work if the&#13;
 /// RLPItem is a list.&#13;
 /// @param self The RLPItem.&#13;
 /// @return The decoded string.&#13;
 function toAddress(RLPItem memory self) internal constant returns (address data) {&#13;
     if(!isData(self))&#13;
         throw;&#13;
     var (rStartPos, len) = _decode(self);&#13;
     if (len != 20)&#13;
         throw;&#13;
     assembly {&#13;
         data := div(mload(rStartPos), exp(256, 12))&#13;
     }&#13;
 }&#13;
&#13;
 // Get the payload offset.&#13;
 function _payloadOffset(RLPItem memory self) private constant returns (uint) {&#13;
     if(self._unsafe_length == 0)&#13;
         return 0;&#13;
     uint b0;&#13;
     uint memPtr = self._unsafe_memPtr;&#13;
     assembly {&#13;
         b0 := byte(0, mload(memPtr))&#13;
     }&#13;
     if(b0 &lt; DATA_SHORT_START)&#13;
         return 0;&#13;
     if(b0 &lt; DATA_LONG_START || (b0 &gt;= LIST_SHORT_START &amp;&amp; b0 &lt; LIST_LONG_START))&#13;
         return 1;&#13;
     if(b0 &lt; LIST_SHORT_START)&#13;
         return b0 - DATA_LONG_OFFSET + 1;&#13;
     return b0 - LIST_LONG_OFFSET + 1;&#13;
 }&#13;
&#13;
 // Get the full length of an RLP item.&#13;
 function _itemLength(uint memPtr) private constant returns (uint len) {&#13;
     uint b0;&#13;
     assembly {&#13;
         b0 := byte(0, mload(memPtr))&#13;
     }&#13;
     if (b0 &lt; DATA_SHORT_START)&#13;
         len = 1;&#13;
     else if (b0 &lt; DATA_LONG_START)&#13;
         len = b0 - DATA_SHORT_START + 1;&#13;
     else if (b0 &lt; LIST_SHORT_START) {&#13;
         assembly {&#13;
             let bLen := sub(b0, 0xB7) // bytes length (DATA_LONG_OFFSET)&#13;
             let dLen := div(mload(add(memPtr, 1)), exp(256, sub(32, bLen))) // data length&#13;
             len := add(1, add(bLen, dLen)) // total length&#13;
         }&#13;
     }&#13;
     else if (b0 &lt; LIST_LONG_START)&#13;
         len = b0 - LIST_SHORT_START + 1;&#13;
     else {&#13;
         assembly {&#13;
             let bLen := sub(b0, 0xF7) // bytes length (LIST_LONG_OFFSET)&#13;
             let dLen := div(mload(add(memPtr, 1)), exp(256, sub(32, bLen))) // data length&#13;
             len := add(1, add(bLen, dLen)) // total length&#13;
         }&#13;
     }&#13;
 }&#13;
&#13;
 // Get start position and length of the data.&#13;
 function _decode(RLPItem memory self) private constant returns (uint memPtr, uint len) {&#13;
     if(!isData(self))&#13;
         throw;&#13;
     uint b0;&#13;
     uint start = self._unsafe_memPtr;&#13;
     assembly {&#13;
         b0 := byte(0, mload(start))&#13;
     }&#13;
     if (b0 &lt; DATA_SHORT_START) {&#13;
         memPtr = start;&#13;
         len = 1;&#13;
         return;&#13;
     }&#13;
     if (b0 &lt; DATA_LONG_START) {&#13;
         len = self._unsafe_length - 1;&#13;
         memPtr = start + 1;&#13;
     } else {&#13;
         uint bLen;&#13;
         assembly {&#13;
             bLen := sub(b0, 0xB7) // DATA_LONG_OFFSET&#13;
         }&#13;
         len = self._unsafe_length - 1 - bLen;&#13;
         memPtr = start + bLen + 1;&#13;
     }&#13;
     return;&#13;
 }&#13;
&#13;
 // Assumes that enough memory has been allocated to store in target.&#13;
 function _copyToBytes(uint btsPtr, bytes memory tgt, uint btsLen) private constant {&#13;
     // Exploiting the fact that 'tgt' was the last thing to be allocated,&#13;
     // we can write entire words, and just overwrite any excess.&#13;
     assembly {&#13;
         {&#13;
                 let i := 0 // Start at arr + 0x20&#13;
                 let words := div(add(btsLen, 31), 32)&#13;
                 let rOffset := btsPtr&#13;
                 let wOffset := add(tgt, 0x20)&#13;
             tag_loop:&#13;
                 jumpi(end, eq(i, words))&#13;
                 {&#13;
                     let offset := mul(i, 0x20)&#13;
                     mstore(add(wOffset, offset), mload(add(rOffset, offset)))&#13;
                     i := add(i, 1)&#13;
                 }&#13;
                 jump(tag_loop)&#13;
             end:&#13;
                 mstore(add(tgt, add(0x20, mload(tgt))), 0)&#13;
         }&#13;
     }&#13;
 }&#13;
&#13;
 // Check that an RLP item is valid.&#13;
     function _validate(RLPItem memory self) private constant returns (bool ret) {&#13;
         // Check that RLP is well-formed.&#13;
         uint b0;&#13;
         uint b1;&#13;
         uint memPtr = self._unsafe_memPtr;&#13;
         assembly {&#13;
             b0 := byte(0, mload(memPtr))&#13;
             b1 := byte(1, mload(memPtr))&#13;
         }&#13;
         if(b0 == DATA_SHORT_START + 1 &amp;&amp; b1 &lt; DATA_SHORT_START)&#13;
             return false;&#13;
         return true;&#13;
     }&#13;
}&#13;
&#13;
&#13;
&#13;
/// @dev This contract allows for `recipient` to set and modify milestones&#13;
contract MilestoneTracker {&#13;
    using RLP for RLP.RLPItem;&#13;
    using RLP for RLP.Iterator;&#13;
    using RLP for bytes;&#13;
&#13;
    struct Milestone {&#13;
        string description;     // Description of this milestone&#13;
        string url;             // A link to more information (swarm gateway)&#13;
        uint minCompletionDate; // Earliest UNIX time the milestone can be paid&#13;
        uint maxCompletionDate; // Latest UNIX time the milestone can be paid&#13;
        address milestoneLeadLink;&#13;
                                // Similar to `recipient`but for this milestone&#13;
        address reviewer;       // Can reject the completion of this milestone&#13;
        uint reviewTime;        // How many seconds the reviewer has to review&#13;
        address paymentSource;  // Where the milestone payment is sent from&#13;
        bytes payData;          // Data defining how much ether is sent where&#13;
&#13;
        MilestoneStatus status; // Current status of the milestone&#13;
                                // (Completed, AuthorizedForPayment...)&#13;
        uint doneTime;          // UNIX time when the milestone was marked DONE&#13;
    }&#13;
&#13;
    // The list of all the milestones.&#13;
    Milestone[] public milestones;&#13;
&#13;
    address public recipient;   // Calls functions in the name of the recipient&#13;
    address public donor;       // Calls functions in the name of the donor&#13;
    address public arbitrator;  // Calls functions in the name of the arbitrator&#13;
&#13;
    enum MilestoneStatus {&#13;
        AcceptedAndInProgress,&#13;
        Completed,&#13;
        AuthorizedForPayment,&#13;
        Canceled&#13;
    }&#13;
&#13;
    // True if the campaign has been canceled&#13;
    bool public campaignCanceled;&#13;
&#13;
    // True if an approval on a change to `milestones` is a pending&#13;
    bool public changingMilestones;&#13;
&#13;
    // The pending change to `milestones` encoded in RLP&#13;
    bytes public proposedMilestones;&#13;
&#13;
&#13;
    /// @dev The following modifiers only allow specific roles to call functions&#13;
    /// with these modifiers&#13;
    modifier onlyRecipient { if (msg.sender !=  recipient) throw; _; }&#13;
    modifier onlyArbitrator { if (msg.sender != arbitrator) throw; _; }&#13;
    modifier onlyDonor { if (msg.sender != donor) throw; _; }&#13;
&#13;
    /// @dev The following modifiers prevent functions from being called if the&#13;
    /// campaign has been canceled or if new milestones are being proposed&#13;
    modifier campaignNotCanceled { if (campaignCanceled) throw; _; }&#13;
    modifier notChanging { if (changingMilestones) throw; _; }&#13;
&#13;
 // @dev Events to make the payment movements easy to find on the blockchain&#13;
    event NewMilestoneListProposed();&#13;
    event NewMilestoneListUnproposed();&#13;
    event NewMilestoneListAccepted();&#13;
    event ProposalStatusChanged(uint idProposal, MilestoneStatus newProposal);&#13;
    event CampaignCanceled();&#13;
&#13;
&#13;
///////////&#13;
// Constructor&#13;
///////////&#13;
&#13;
    /// @notice The Constructor creates the Milestone contract on the blockchain&#13;
    /// @param _arbitrator Address assigned to be the arbitrator&#13;
    /// @param _donor Address assigned to be the donor&#13;
    /// @param _recipient Address assigned to be the recipient&#13;
    function MilestoneTracker (&#13;
        address _arbitrator,&#13;
        address _donor,&#13;
        address _recipient&#13;
    ) {&#13;
        arbitrator = _arbitrator;&#13;
        donor = _donor;&#13;
        recipient = _recipient;&#13;
    }&#13;
&#13;
&#13;
/////////&#13;
// Helper functions&#13;
/////////&#13;
&#13;
    /// @return The number of milestones ever created even if they were canceled&#13;
    function numberOfMilestones() constant returns (uint) {&#13;
        return milestones.length;&#13;
    }&#13;
&#13;
&#13;
////////&#13;
// Change players&#13;
////////&#13;
&#13;
    /// @notice `onlyArbitrator` Reassigns the arbitrator to a new address&#13;
    /// @param _newArbitrator The new arbitrator&#13;
    function changeArbitrator(address _newArbitrator) onlyArbitrator {&#13;
        arbitrator = _newArbitrator;&#13;
    }&#13;
&#13;
    /// @notice `onlyDonor` Reassigns the `donor` to a new address&#13;
    /// @param _newDonor The new donor&#13;
    function changeDonor(address _newDonor) onlyDonor {&#13;
        donor = _newDonor;&#13;
    }&#13;
&#13;
    /// @notice `onlyRecipient` Reassigns the `recipient` to a new address&#13;
    /// @param _newRecipient The new recipient&#13;
    function changeRecipient(address _newRecipient) onlyRecipient {&#13;
        recipient = _newRecipient;&#13;
    }&#13;
&#13;
&#13;
////////////&#13;
// Creation and modification of Milestones&#13;
////////////&#13;
&#13;
    /// @notice `onlyRecipient` Proposes new milestones or changes old&#13;
    ///  milestones, this will require a user interface to be built up to&#13;
    ///  support this functionality as asks for RLP encoded bytecode to be&#13;
    ///  generated, until this interface is built you can use this script:&#13;
    ///  https://github.com/Giveth/milestonetracker/blob/master/js/milestonetracker_helper.js&#13;
    ///  the functions milestones2bytes and bytes2milestones will enable the&#13;
    ///  recipient to encode and decode a list of milestones, also see&#13;
    ///  https://github.com/Giveth/milestonetracker/blob/master/README.md&#13;
    /// @param _newMilestones The RLP encoded list of milestones; each milestone&#13;
    ///  has these fields:&#13;
    ///       string description,&#13;
    ///       string url,&#13;
    ///       uint minCompletionDate,  // seconds since 1/1/1970 (UNIX time)&#13;
    ///       uint maxCompletionDate,  // seconds since 1/1/1970 (UNIX time)&#13;
    ///       address milestoneLeadLink,&#13;
    ///       address reviewer,&#13;
    ///       uint reviewTime&#13;
    ///       address paymentSource,&#13;
    ///       bytes payData,&#13;
    function proposeMilestones(bytes _newMilestones&#13;
    ) onlyRecipient campaignNotCanceled {&#13;
        proposedMilestones = _newMilestones;&#13;
        changingMilestones = true;&#13;
        NewMilestoneListProposed();&#13;
    }&#13;
&#13;
&#13;
////////////&#13;
// Normal actions that will change the state of the milestones&#13;
////////////&#13;
&#13;
    /// @notice `onlyRecipient` Cancels the proposed milestones and reactivates&#13;
    ///  the previous set of milestones&#13;
    function unproposeMilestones() onlyRecipient campaignNotCanceled {&#13;
        delete proposedMilestones;&#13;
        changingMilestones = false;&#13;
        NewMilestoneListUnproposed();&#13;
    }&#13;
&#13;
    /// @notice `onlyDonor` Approves the proposed milestone list&#13;
    /// @param _hashProposals The sha3() of the proposed milestone list's&#13;
    ///  bytecode; this confirms that the `donor` knows the set of milestones&#13;
    ///  they are approving&#13;
    function acceptProposedMilestones(bytes32 _hashProposals&#13;
    ) onlyDonor campaignNotCanceled {&#13;
&#13;
        uint i;&#13;
&#13;
        if (!changingMilestones) throw;&#13;
        if (sha3(proposedMilestones) != _hashProposals) throw;&#13;
&#13;
        // Cancel all the unfinished milestones&#13;
        for (i=0; i&lt;milestones.length; i++) {&#13;
            if (milestones[i].status != MilestoneStatus.AuthorizedForPayment) {&#13;
                milestones[i].status = MilestoneStatus.Canceled;&#13;
            }&#13;
        }&#13;
        // Decode the RLP encoded milestones and add them to the milestones list&#13;
        bytes memory mProposedMilestones = proposedMilestones;&#13;
&#13;
        var itmProposals = mProposedMilestones.toRLPItem(true);&#13;
&#13;
        if (!itmProposals.isList()) throw;&#13;
&#13;
        var itrProposals = itmProposals.iterator();&#13;
&#13;
        while(itrProposals.hasNext()) {&#13;
&#13;
&#13;
            var itmProposal = itrProposals.next();&#13;
&#13;
            Milestone milestone = milestones[milestones.length ++];&#13;
&#13;
            if (!itmProposal.isList()) throw;&#13;
&#13;
            var itrProposal = itmProposal.iterator();&#13;
&#13;
            milestone.description = itrProposal.next().toAscii();&#13;
            milestone.url = itrProposal.next().toAscii();&#13;
            milestone.minCompletionDate = itrProposal.next().toUint();&#13;
            milestone.maxCompletionDate = itrProposal.next().toUint();&#13;
            milestone.milestoneLeadLink = itrProposal.next().toAddress();&#13;
            milestone.reviewer = itrProposal.next().toAddress();&#13;
            milestone.reviewTime = itrProposal.next().toUint();&#13;
            milestone.paymentSource = itrProposal.next().toAddress();&#13;
            milestone.payData = itrProposal.next().toData();&#13;
&#13;
            milestone.status = MilestoneStatus.AcceptedAndInProgress;&#13;
&#13;
        }&#13;
&#13;
        delete proposedMilestones;&#13;
        changingMilestones = false;&#13;
        NewMilestoneListAccepted();&#13;
    }&#13;
&#13;
    /// @notice `onlyRecipientOrLeadLink`Marks a milestone as DONE and&#13;
    ///  ready for review&#13;
    /// @param _idMilestone ID of the milestone that has been completed&#13;
    function markMilestoneComplete(uint _idMilestone)&#13;
        campaignNotCanceled notChanging&#13;
    {&#13;
        if (_idMilestone &gt;= milestones.length) throw;&#13;
        Milestone milestone = milestones[_idMilestone];&#13;
        if (  (msg.sender != milestone.milestoneLeadLink)&#13;
            &amp;&amp;(msg.sender != recipient))&#13;
            throw;&#13;
        if (milestone.status != MilestoneStatus.AcceptedAndInProgress) throw;&#13;
        if (now &lt; milestone.minCompletionDate) throw;&#13;
        if (now &gt; milestone.maxCompletionDate) throw;&#13;
        milestone.status = MilestoneStatus.Completed;&#13;
        milestone.doneTime = now;&#13;
        ProposalStatusChanged(_idMilestone, milestone.status);&#13;
    }&#13;
&#13;
    /// @notice `onlyReviewer` Approves a specific milestone&#13;
    /// @param _idMilestone ID of the milestone that is approved&#13;
    function approveCompletedMilestone(uint _idMilestone)&#13;
        campaignNotCanceled notChanging&#13;
    {&#13;
        if (_idMilestone &gt;= milestones.length) throw;&#13;
        Milestone milestone = milestones[_idMilestone];&#13;
        if ((msg.sender != milestone.reviewer) ||&#13;
            (milestone.status != MilestoneStatus.Completed)) throw;&#13;
&#13;
        authorizePayment(_idMilestone);&#13;
    }&#13;
&#13;
    /// @notice `onlyReviewer` Rejects a specific milestone's completion and&#13;
    ///  reverts the `milestone.status` back to the `AcceptedAndInProgress`&#13;
    ///  state&#13;
    /// @param _idMilestone ID of the milestone that is being rejected&#13;
    function rejectMilestone(uint _idMilestone)&#13;
        campaignNotCanceled notChanging&#13;
    {&#13;
        if (_idMilestone &gt;= milestones.length) throw;&#13;
        Milestone milestone = milestones[_idMilestone];&#13;
        if ((msg.sender != milestone.reviewer) ||&#13;
            (milestone.status != MilestoneStatus.Completed)) throw;&#13;
&#13;
        milestone.status = MilestoneStatus.AcceptedAndInProgress;&#13;
        ProposalStatusChanged(_idMilestone, milestone.status);&#13;
    }&#13;
&#13;
    /// @notice `onlyRecipientOrLeadLink` Sends the milestone payment as&#13;
    ///  specified in `payData`; the recipient can only call this after the&#13;
    ///  `reviewTime` has elapsed&#13;
    /// @param _idMilestone ID of the milestone to be paid out&#13;
    function requestMilestonePayment(uint _idMilestone&#13;
        ) campaignNotCanceled notChanging {&#13;
        if (_idMilestone &gt;= milestones.length) throw;&#13;
        Milestone milestone = milestones[_idMilestone];&#13;
        if (  (msg.sender != milestone.milestoneLeadLink)&#13;
            &amp;&amp;(msg.sender != recipient))&#13;
            throw;&#13;
        if  ((milestone.status != MilestoneStatus.Completed) ||&#13;
             (now &lt; milestone.doneTime + milestone.reviewTime))&#13;
            throw;&#13;
&#13;
        authorizePayment(_idMilestone);&#13;
    }&#13;
&#13;
    /// @notice `onlyRecipient` Cancels a previously accepted milestone&#13;
    /// @param _idMilestone ID of the milestone to be canceled&#13;
    function cancelMilestone(uint _idMilestone)&#13;
        onlyRecipient campaignNotCanceled notChanging&#13;
    {&#13;
        if (_idMilestone &gt;= milestones.length) throw;&#13;
        Milestone milestone = milestones[_idMilestone];&#13;
        if  ((milestone.status != MilestoneStatus.AcceptedAndInProgress) &amp;&amp;&#13;
             (milestone.status != MilestoneStatus.Completed))&#13;
            throw;&#13;
&#13;
        milestone.status = MilestoneStatus.Canceled;&#13;
        ProposalStatusChanged(_idMilestone, milestone.status);&#13;
    }&#13;
&#13;
    /// @notice `onlyArbitrator` Forces a milestone to be paid out as long as it&#13;
    /// has not been paid or canceled&#13;
    /// @param _idMilestone ID of the milestone to be paid out&#13;
    function arbitrateApproveMilestone(uint _idMilestone&#13;
    ) onlyArbitrator campaignNotCanceled notChanging {&#13;
        if (_idMilestone &gt;= milestones.length) throw;&#13;
        Milestone milestone = milestones[_idMilestone];&#13;
        if  ((milestone.status != MilestoneStatus.AcceptedAndInProgress) &amp;&amp;&#13;
             (milestone.status != MilestoneStatus.Completed))&#13;
           throw;&#13;
        authorizePayment(_idMilestone);&#13;
    }&#13;
&#13;
    /// @notice `onlyArbitrator` Cancels the entire campaign voiding all&#13;
    ///  milestones vo&#13;
    function arbitrateCancelCampaign() onlyArbitrator campaignNotCanceled {&#13;
        campaignCanceled = true;&#13;
        CampaignCanceled();&#13;
    }&#13;
&#13;
    // @dev This internal function is executed when the milestone is paid out&#13;
    function authorizePayment(uint _idMilestone) internal {&#13;
        if (_idMilestone &gt;= milestones.length) throw;&#13;
        Milestone milestone = milestones[_idMilestone];&#13;
        // Recheck again to not pay twice&#13;
        if (milestone.status == MilestoneStatus.AuthorizedForPayment) throw;&#13;
        milestone.status = MilestoneStatus.AuthorizedForPayment;&#13;
        if (!milestone.paymentSource.call.value(0)(milestone.payData))&#13;
            throw;&#13;
        ProposalStatusChanged(_idMilestone, milestone.status);&#13;
    }&#13;
}
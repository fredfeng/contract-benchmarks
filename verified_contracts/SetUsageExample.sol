/*
 * Written by Jesse Busman (<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="741d1a121b341e11071601075a171b19">[email protected]</a>) on 2017-11-30.&#13;
 * This software is provided as-is without warranty of any kind, express or implied.&#13;
 * This software is provided without any limitation to use, copy modify or distribute.&#13;
 * The user takes sole and complete responsibility for the consequences of this software's use.&#13;
 * Github repository: https://github.com/JesseBusman/SoliditySet&#13;
 */&#13;
&#13;
pragma solidity ^0.4.18;&#13;
&#13;
library SetLibrary&#13;
{&#13;
    struct ArrayIndexAndExistsFlag&#13;
    {&#13;
        uint256 index;&#13;
        bool exists;&#13;
    }&#13;
    struct Set&#13;
    {&#13;
        mapping(uint256 =&gt; ArrayIndexAndExistsFlag) valuesMapping;&#13;
        uint256[] values;&#13;
    }&#13;
    function add(Set storage self, uint256 value) public returns (bool added)&#13;
    {&#13;
        // If the value is already in the set, we don't need to do anything&#13;
        if (self.valuesMapping[value].exists == true) return false;&#13;
        &#13;
        // Remember that the value is in the set, and remember the value's array index&#13;
        self.valuesMapping[value] = ArrayIndexAndExistsFlag({index: self.values.length, exists: true});&#13;
        &#13;
        // Add the value to the array of unique values&#13;
        self.values.push(value);&#13;
        &#13;
        return true;&#13;
    }&#13;
    function contains(Set storage self, uint256 value) public view returns (bool contained)&#13;
    {&#13;
        return self.valuesMapping[value].exists;&#13;
    }&#13;
    function remove(Set storage self, uint256 value) public returns (bool removed)&#13;
    {&#13;
        // If the value is not in the set, we don't need to do anything&#13;
        if (self.valuesMapping[value].exists == false) return false;&#13;
        &#13;
        // Remember that the value is not in the set&#13;
        self.valuesMapping[value].exists = false;&#13;
        &#13;
        // Now we need to remove the value from the array. To prevent leaking&#13;
        // storage space, we move the last value in the array into the spot that&#13;
        // contains the element we're removing.&#13;
        if (self.valuesMapping[value].index &lt; self.values.length-1)&#13;
        {&#13;
            self.values[self.valuesMapping[value].index] = self.values[self.values.length-1];&#13;
        }&#13;
        &#13;
        // Now we remove the last element from the array, because we just duplicated it.&#13;
        // We don't free the storage allocation of the removed last element,&#13;
        // because it will most likely be used again by a call to add().&#13;
        // De-allocating and re-allocating storage space costs more gas than&#13;
        // just keeping it allocated and unused.&#13;
        &#13;
        // Uncomment this line to save gas if your use case does not call add() after remove():&#13;
        // delete self.values[self.values.length-1];&#13;
        self.values.length--;&#13;
        &#13;
        // We do free the storage allocation in the mapping, because it is&#13;
        // less likely that the exact same value will added again.&#13;
        delete self.valuesMapping[value];&#13;
        &#13;
        return true;&#13;
    }&#13;
    function size(Set storage self) public view returns (uint256 amountOfValues)&#13;
    {&#13;
        return self.values.length;&#13;
    }&#13;
    &#13;
    // Also accept address and bytes32 types, so the user doesn't have to cast.&#13;
    function add(Set storage self, address value) public returns (bool added) { return add(self, uint256(value)); }&#13;
    function add(Set storage self, bytes32 value) public returns (bool added) { return add(self, uint256(value)); }&#13;
    function contains(Set storage self, address value) public view returns (bool contained) { return contains(self, uint256(value)); }&#13;
    function contains(Set storage self, bytes32 value) public view returns (bool contained) { return contains(self, uint256(value)); }&#13;
    function remove(Set storage self, address value) public returns (bool removed) { return remove(self, uint256(value)); }&#13;
    function remove(Set storage self, bytes32 value) public returns (bool removed) { return remove(self, uint256(value)); }&#13;
}&#13;
&#13;
contract SetUsageExample&#13;
{&#13;
    using SetLibrary for SetLibrary.Set;&#13;
    &#13;
    SetLibrary.Set private numberCollection;&#13;
    &#13;
    function addNumber(uint256 number) external&#13;
    {&#13;
        numberCollection.add(number);&#13;
    }&#13;
    &#13;
    function removeNumber(uint256 number) external&#13;
    {&#13;
        numberCollection.remove(number);&#13;
    }&#13;
    &#13;
    function getSize() external view returns (uint256 size)&#13;
    {&#13;
        return numberCollection.size();&#13;
    }&#13;
    &#13;
    function containsNumber(uint256 number) external view returns (bool contained)&#13;
    {&#13;
        return numberCollection.contains(number);&#13;
    }&#13;
    &#13;
    function getNumberAtIndex(uint256 index) external view returns (uint256 number)&#13;
    {&#13;
        return numberCollection.values[index];&#13;
    }&#13;
}
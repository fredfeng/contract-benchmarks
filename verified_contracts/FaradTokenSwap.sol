/**
 * Copyright (C) Virtue Fintech FZ-LLC, Dubai
 * All rights reserved.
 * Author: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="462b2e2f06302f3432332368202f2827282523">[email protected]</a> &#13;
 *&#13;
 * MIT License&#13;
 *&#13;
 * Permission is hereby granted, free of charge, to any person obtaining a copy &#13;
 * of this software and associated documentation files (the ""Software""), to &#13;
 * deal in the Software without restriction, including without limitation the &#13;
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or &#13;
 * sell copies of the Software, and to permit persons to whom the Software is &#13;
 * furnished to do so, subject to the following conditions: &#13;
 *  The above copyright notice and this permission notice shall be included in &#13;
 *  all copies or substantial portions of the Software.&#13;
 *&#13;
 * THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR &#13;
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, &#13;
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE &#13;
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER &#13;
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, &#13;
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN &#13;
 * THE SOFTWARE.&#13;
 *&#13;
 */&#13;
pragma solidity ^0.4.11;&#13;
&#13;
/**&#13;
 * Guards is a handful of modifiers to be used throughout this project&#13;
 */&#13;
contract Guarded {&#13;
&#13;
    modifier isValidAmount(uint256 _amount) { &#13;
        require(_amount &gt; 0); &#13;
        _; &#13;
    }&#13;
&#13;
    // ensure address not null, and not this contract address&#13;
    modifier isValidAddress(address _address) {&#13;
        require(_address != 0x0 &amp;&amp; _address != address(this));&#13;
        _;&#13;
    }&#13;
&#13;
}&#13;
&#13;
contract Ownable {&#13;
    address public owner;&#13;
&#13;
    /** &#13;
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender&#13;
     * account.&#13;
     */&#13;
    function Ownable() {&#13;
        owner = msg.sender;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Throws if called by any account other than the owner. &#13;
     */&#13;
    modifier onlyOwner() {&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Allows the current owner to transfer control of the contract to a newOwner.&#13;
     * @param newOwner The address to transfer ownership to. &#13;
     */&#13;
    function transferOwnership(address newOwner) onlyOwner {&#13;
        if (newOwner != address(0)) {&#13;
            owner = newOwner;&#13;
        }&#13;
    }&#13;
&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title SafeMath&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
library SafeMath {&#13;
    function mul(uint256 a, uint256 b) internal returns (uint256) {&#13;
        uint256 c = a * b;&#13;
        assert(a == 0 || c / a == b);&#13;
        return c;&#13;
    }&#13;
&#13;
    function div(uint256 a, uint256 b) internal returns (uint256) {&#13;
        // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
        uint256 c = a / b;&#13;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
        return c;&#13;
    }&#13;
&#13;
    function sub(uint256 a, uint256 b) internal returns (uint256) {&#13;
        assert(b &lt;= a);&#13;
        return a - b;&#13;
    }&#13;
&#13;
    function add(uint256 a, uint256 b) internal returns (uint256) {&#13;
        uint256 c = a + b;&#13;
        assert(c &gt;= a);&#13;
        return c;&#13;
    }&#13;
}&#13;
&#13;
&#13;
contract FaradTokenSwap is Guarded, Ownable {&#13;
&#13;
    using SafeMath for uint256;&#13;
&#13;
    mapping(address =&gt; uint256) contributions;          // contributions from public&#13;
    uint256 contribCount = 0;&#13;
&#13;
    string public version = '0.1.2';&#13;
&#13;
    uint256 public startBlock = 4280263;                // 16th September 2017, 00:00:00 - 1505520000&#13;
    uint256 public endBlock = 4305463;                  // 22nd September 2017, 23:59:59 - 1506124799&#13;
&#13;
    uint256 public totalEtherCap = 1184834 ether;       // Total raised for ICO, at USD 211/ether&#13;
    uint256 public weiRaised = 0;                       // wei raised in this ICO&#13;
    uint256 public minContrib = 0.05 ether;             // min contribution accepted&#13;
&#13;
    address public wallet = 0xdDA27AC23Fc398d5e6B0108041fc334EDab3c183;&#13;
&#13;
    event Contribution(address indexed _contributor, uint256 _amount);&#13;
&#13;
    function FaradTokenSwap() {&#13;
    }&#13;
&#13;
    // function to start the Token Sale&#13;
    /// start the token sale at `_starBlock`&#13;
    function setStartBlock(uint256 _startBlock) onlyOwner public {&#13;
        startBlock = _startBlock;&#13;
    }&#13;
&#13;
    // function to stop the Token Swap &#13;
    /// stop the token swap at `_endBlock`&#13;
    function setEndBlock(uint256 _endBlock) onlyOwner public {&#13;
        endBlock = _endBlock;&#13;
    }&#13;
&#13;
    // this function is to add the previous token sale balance.&#13;
    /// set the accumulated balance of `_weiRaised`&#13;
    function setWeiRaised(uint256 _weiRaised) onlyOwner public {&#13;
        weiRaised = weiRaised.add(_weiRaised);&#13;
    }&#13;
&#13;
    // set the wallet address&#13;
    /// set the wallet at `_wallet`&#13;
    function setWallet(address _wallet) onlyOwner public {&#13;
        wallet = _wallet;&#13;
    }&#13;
&#13;
    /// set the minimum contribution to `_minContrib`&#13;
    function setMinContribution(uint256 _minContrib) onlyOwner public {&#13;
        minContrib = _minContrib;&#13;
    }&#13;
&#13;
    // @return true if token swap event has ended&#13;
    function hasEnded() public constant returns (bool) {&#13;
        return block.number &gt;= endBlock;&#13;
    }&#13;
&#13;
    // @return true if the token swap contract is active.&#13;
    function isActive() public constant returns (bool) {&#13;
        return block.number &gt;= startBlock &amp;&amp; block.number &lt;= endBlock;&#13;
    }&#13;
&#13;
    function () payable {&#13;
        processContributions(msg.sender, msg.value);&#13;
    }&#13;
&#13;
    /**&#13;
     * Okay, we changed the process flow a bit where the actual FRD to ETH&#13;
     * mapping shall be calculated, and pushed to the contract once the&#13;
     * crowdsale is over.&#13;
     *&#13;
     * Then, the user can pull the tokens to their wallet.&#13;
     *&#13;
     */&#13;
    function processContributions(address _contributor, uint256 _weiAmount) payable {&#13;
        require(validPurchase());&#13;
&#13;
        uint256 updatedWeiRaised = weiRaised.add(_weiAmount);&#13;
&#13;
        // update state&#13;
        weiRaised = updatedWeiRaised;&#13;
&#13;
        // notify event for this contribution&#13;
        contributions[_contributor] = contributions[_contributor].add(_weiAmount);&#13;
        contribCount += 1;&#13;
        Contribution(_contributor, _weiAmount);&#13;
&#13;
        // forware the funds&#13;
        forwardFunds();&#13;
    }&#13;
&#13;
    // @return true if the transaction can buy tokens&#13;
    function validPurchase() internal constant returns (bool) {&#13;
        uint256 current = block.number;&#13;
&#13;
        bool withinPeriod = current &gt;= startBlock &amp;&amp; current &lt;= endBlock;&#13;
        bool minPurchase = msg.value &gt;= minContrib;&#13;
&#13;
        // add total wei raised&#13;
        uint256 totalWeiRaised = weiRaised.add(msg.value);&#13;
        bool withinCap = totalWeiRaised &lt;= totalEtherCap;&#13;
&#13;
        // check all 3 conditions met&#13;
        return withinPeriod &amp;&amp; minPurchase &amp;&amp; withinCap;&#13;
    }&#13;
&#13;
    // send ether to the fund collection wallet&#13;
    // override to create custom fund forwarding mechanisms&#13;
    function forwardFunds() internal {&#13;
        wallet.transfer(msg.value);&#13;
    }&#13;
&#13;
}
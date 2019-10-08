pragma solidity ^0.4.2;

/*

EthPledge allows people to pledge to donate a certain amount to a charity, which gets sent only if others match it. A user may pledge to donate 10 Ether to a charity, for example, which will get listed here and will be sent to the charity later only if other people also collectively contribute 10 Ether under that pledge. You can also pledge to donate several times what other people donate, up to a certain amount -- for example, you may choose to put up 10 Ether, which gets sent to the charity if others only contribute 2 Ether.

Matching pledges of this kind are quite common (companies may pledge to match all charitable donations their employees make up to a certain amount, for example, or it may just be a casual arrangement between 2 people) and by running on the Ethereum blockchain, EthPledge guarantees 100% transparency. 

Note that as Ethereum is still relatively new at this stage, not many charities have an Ethereum address to take donations yet, though it's our hope that more will come. The main charity with an Ethereum donation address at this time is Heifer International, whose Ethereum address is 0xb30cb3b3E03A508Db2A0a3e07BA1297b47bb0fb1 (see https://www.heifer.org/what-you-can-do/give/digital-currency.html)

Visit EthPledge.com to play with this smart contract. Reach out: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="0e6d61607a6f6d7a4e4b7a665e626b6a696b206d6163">[email protected]</a>&#13;
&#13;
*/&#13;
&#13;
contract EthPledge {&#13;
    &#13;
    address public owner;&#13;
    &#13;
    function EthPledge() {&#13;
        owner = msg.sender;&#13;
    }&#13;
    &#13;
    modifier onlyOwner {&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
    &#13;
    struct Campaign {&#13;
        address benefactor; // Person starting the campaign, who puts in some ETH to donate to an Ethereum address. &#13;
        address charity;&#13;
        uint amountPledged;&#13;
        uint amountRaised;&#13;
        uint donationsReceived;&#13;
        uint multiplier; // If this was 5, for example, other donators would only need to put up 1/5th of the amount the benefactor does for the pledge to be successful and all funds to be donated. Eg. Benefactor pledges 10 ETH, then after only 2 ETH is contributed to the campaign, all funds are send to the charity and the campaign ends&#13;
        bool active;&#13;
        bool successful;&#13;
        uint timeStarted;&#13;
        bytes32 descriptionPart1; // Allow a description of up to 132 characters. Each bytes32 part can only hold 32 characters.&#13;
        bytes32 descriptionPart2;&#13;
        bytes32 descriptionPart3;&#13;
        bytes32 descriptionPart4;&#13;
    }&#13;
    &#13;
    mapping (uint =&gt; Campaign) public campaign;&#13;
    &#13;
    mapping (address =&gt; uint[]) public campaignsStartedByUser;&#13;
    &#13;
    mapping (address =&gt; mapping(uint =&gt; uint)) public addressToCampaignIDToFundsDonated;&#13;
    &#13;
    mapping (address =&gt; uint[]) public campaignIDsDonatedToByUser; // Will contain duplicates if a user donates to a campaign twice&#13;
    &#13;
    struct Donation {&#13;
        address donator;&#13;
        uint amount;&#13;
        uint timeSent;&#13;
    }&#13;
    &#13;
    mapping (uint =&gt; mapping(uint =&gt; Donation)) public campaignIDtoDonationNumberToDonation;&#13;
    &#13;
    uint public totalCampaigns;&#13;
    &#13;
    uint public totalDonations;&#13;
    &#13;
    uint public totalETHraised;&#13;
    &#13;
    uint public minimumPledgeAmount = 10**14; // Basically nothing, can be adjusted later&#13;
    &#13;
    function createCampaign (address charity, uint multiplier, bytes32 descriptionPart1, bytes32 descriptionPart2, bytes32 descriptionPart3, bytes32 descriptionPart4) payable {&#13;
        require (msg.value &gt;= minimumPledgeAmount);&#13;
        require (multiplier &gt; 0);&#13;
        campaign[totalCampaigns].benefactor = msg.sender;&#13;
        campaign[totalCampaigns].charity = charity;&#13;
        campaign[totalCampaigns].multiplier = multiplier;&#13;
        campaign[totalCampaigns].timeStarted = now;&#13;
        campaign[totalCampaigns].amountPledged = msg.value;&#13;
        campaign[totalCampaigns].active = true;&#13;
        campaign[totalCampaigns].descriptionPart1 = descriptionPart1;&#13;
        campaign[totalCampaigns].descriptionPart2 = descriptionPart2;&#13;
        campaign[totalCampaigns].descriptionPart3 = descriptionPart3;&#13;
        campaign[totalCampaigns].descriptionPart4 = descriptionPart4;&#13;
        campaignsStartedByUser[msg.sender].push(totalCampaigns);&#13;
        totalETHraised += msg.value;&#13;
        totalCampaigns++;&#13;
    }&#13;
    &#13;
    function cancelCampaign (uint campaignID) {&#13;
        &#13;
        // If the benefactor cancels their campaign, they get a refund of their pledge amount in line with how much others have donated - if you cancel the pledge when 10% of the donation target has been reached, for example, 10% of their pledge amount (along with the donations) will be sent to the charity address, and 90% of the pledge amount you put up will be returned to you&#13;
        &#13;
        require (msg.sender == campaign[campaignID].benefactor);&#13;
        campaign[campaignID].active = false;&#13;
        campaign[campaignID].successful = false;&#13;
        uint amountShort = campaign[campaignID].amountPledged - (campaign[campaignID].amountRaised * campaign[campaignID].multiplier);&#13;
        uint amountToSendToCharity = campaign[campaignID].amountPledged + campaign[campaignID].amountRaised - amountShort;&#13;
        campaign[campaignID].charity.transfer(amountToSendToCharity);&#13;
        campaign[campaignID].benefactor.transfer(amountShort);&#13;
    }&#13;
    &#13;
    function contributeToCampaign (uint campaignID) payable {&#13;
        require (msg.value &gt; 0);&#13;
        require (campaign[campaignID].active = true);&#13;
        campaignIDsDonatedToByUser[msg.sender].push(campaignID);&#13;
        addressToCampaignIDToFundsDonated[msg.sender][campaignID] += msg.value;&#13;
        &#13;
        campaignIDtoDonationNumberToDonation[campaignID][campaign[campaignID].donationsReceived].donator = msg.sender;&#13;
        campaignIDtoDonationNumberToDonation[campaignID][campaign[campaignID].donationsReceived].amount = msg.value;&#13;
        campaignIDtoDonationNumberToDonation[campaignID][campaign[campaignID].donationsReceived].timeSent = now;&#13;
        &#13;
        campaign[campaignID].donationsReceived++;&#13;
        totalDonations++;&#13;
        totalETHraised += msg.value;&#13;
        campaign[campaignID].amountRaised += msg.value;&#13;
        if (campaign[campaignID].amountRaised &gt;= (campaign[campaignID].amountPledged / campaign[campaignID].multiplier)) {&#13;
            // Target reached&#13;
            campaign[campaignID].charity.transfer(campaign[campaignID].amountRaised + campaign[campaignID].amountPledged);&#13;
            campaign[campaignID].active = false;&#13;
            campaign[campaignID].successful = true;&#13;
        }&#13;
    }&#13;
    &#13;
    function adjustMinimumPledgeAmount (uint newMinimum) onlyOwner {&#13;
        require (newMinimum &gt; 0);&#13;
        minimumPledgeAmount = newMinimum;&#13;
    }&#13;
    &#13;
    // Below are view functions that an external contract can call to get information on a campaign ID or user&#13;
    &#13;
    function returnHowMuchMoreETHNeeded (uint campaignID) view returns (uint) {&#13;
        return (campaign[campaignID].amountPledged / campaign[campaignID].multiplier - campaign[campaignID].amountRaised);&#13;
    }&#13;
    &#13;
    function generalInfo() view returns (uint, uint, uint) {&#13;
        return (totalCampaigns, totalDonations, totalETHraised);&#13;
    }&#13;
    &#13;
    function lookupDonation (uint campaignID, uint donationNumber) view returns (address, uint, uint) {&#13;
        return (campaignIDtoDonationNumberToDonation[campaignID][donationNumber].donator, campaignIDtoDonationNumberToDonation[campaignID][donationNumber].amount, campaignIDtoDonationNumberToDonation[campaignID][donationNumber].timeSent);&#13;
    }&#13;
    &#13;
    // Below two functions have to be split into two parts, otherwise there are call-stack too deep errors&#13;
    &#13;
    function lookupCampaignPart1 (uint campaignID) view returns (address, address, uint, uint, uint, bytes32, bytes32) {&#13;
        return (campaign[campaignID].benefactor, campaign[campaignID].charity, campaign[campaignID].amountPledged, campaign[campaignID].amountRaised,campaign[campaignID].donationsReceived, campaign[campaignID].descriptionPart1, campaign[campaignID].descriptionPart2);&#13;
    }&#13;
    &#13;
    function lookupCampaignPart2 (uint campaignID) view returns (uint, bool, bool, uint, bytes32, bytes32) {&#13;
        return (campaign[campaignID].multiplier, campaign[campaignID].active, campaign[campaignID].successful, campaign[campaignID].timeStarted, campaign[campaignID].descriptionPart3, campaign[campaignID].descriptionPart4);&#13;
    }&#13;
    &#13;
    // Below functions are probably not necessary, but included just in case another contract needs this information in future&#13;
    &#13;
    function lookupUserDonationHistoryByCampaignID (address user) view returns (uint[]) {&#13;
        return (campaignIDsDonatedToByUser[user]);&#13;
    }&#13;
    &#13;
    function lookupAmountUserDonatedToCampaign (address user, uint campaignID) view returns (uint) {&#13;
        return (addressToCampaignIDToFundsDonated[user][campaignID]);&#13;
    }&#13;
    &#13;
}
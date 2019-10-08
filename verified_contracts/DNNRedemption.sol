pragma solidity ^0.4.11;

/// @title DNNToken contract - Main DNN contract
/// @author Dondrey Taylor - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c0a4afaea4b2a5b980a4aeaeeeada5a4a9a1">[email protected]</a>&gt;&#13;
contract DNNToken {&#13;
    enum DNNSupplyAllocations {&#13;
        EarlyBackerSupplyAllocation,&#13;
        PRETDESupplyAllocation,&#13;
        TDESupplyAllocation,&#13;
        BountySupplyAllocation,&#13;
        WriterAccountSupplyAllocation,&#13;
        AdvisorySupplyAllocation,&#13;
        PlatformSupplyAllocation&#13;
    }&#13;
    function issueTokens(address, uint256, DNNSupplyAllocations) public returns (bool) {}&#13;
}&#13;
&#13;
/// @title DNNRedemption contract - Issues DNN tokens&#13;
/// @author Dondrey Taylor - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="94f0fbfaf0e6f1edd4f0fafabaf9f1f0fdf5">[email protected]</a>&gt;&#13;
contract DNNRedemption {&#13;
&#13;
    /////////////////////////&#13;
    // DNN Token Contract  //&#13;
    /////////////////////////&#13;
    DNNToken public dnnToken;&#13;
&#13;
    //////////////////////////////////////////&#13;
    // Addresses of the co-founders of DNN. //&#13;
    //////////////////////////////////////////&#13;
    address public cofounderA;&#13;
    address public cofounderB;&#13;
&#13;
    /////////////////////////////////////////////////&#13;
    // Number of tokens distributed (in atto-DNN) //&#13;
    /////////////////////////////////////////////////&#13;
    uint256 public tokensDistributed = 0;&#13;
&#13;
    //////////////////////////////////////////////////////////////////&#13;
    // Maximum number of tokens for this distribution (in atto-DNN) //&#13;
    //////////////////////////////////////////////////////////////////&#13;
    uint256 public maxTokensToDistribute = 30000000 * 1 ether;&#13;
&#13;
    ///////////////////////////////////////////////&#13;
    // Used to generate number of tokens to send //&#13;
    ///////////////////////////////////////////////&#13;
    uint256 public seed = 8633926795440059073718754917553891166080514579013872221976080033791214;&#13;
&#13;
    /////////////////////////////////////////////////&#13;
    // We'll keep track of who we have sent DNN to //&#13;
    /////////////////////////////////////////////////&#13;
    mapping(address =&gt; uint256) holders;&#13;
&#13;
    /////////////////////////////////////////////////////////////////////////////&#13;
    // Event triggered when tokens are transferred from one address to another //&#13;
    /////////////////////////////////////////////////////////////////////////////&#13;
    event Redemption(address indexed to, uint256 value);&#13;
&#13;
&#13;
    ////////////////////////////////////////////////////&#13;
    // Checks if CoFounders are performing the action //&#13;
    ////////////////////////////////////////////////////&#13;
    modifier onlyCofounders() {&#13;
        require (msg.sender == cofounderA || msg.sender == cofounderB);&#13;
        _;&#13;
    }&#13;
&#13;
    ///////////////////////////////////////////////////////////////&#13;
    // @des DNN Holder Check                                     //&#13;
    // @param Checks if we sent DNN to the benfeficiary before   //&#13;
    ///////////////////////////////////////////////////////////////&#13;
    function hasDNN(address beneficiary) public view returns (bool) {&#13;
        return holders[beneficiary] &gt; 0;&#13;
    }&#13;
&#13;
    ///////////////////////////////////////////////////&#13;
    // Make sure that user did no redeeem DNN before //&#13;
    ///////////////////////////////////////////////////&#13;
    modifier doesNotHaveDNN(address beneficiary) {&#13;
        require(hasDNN(beneficiary) == false);&#13;
        _;&#13;
    }&#13;
&#13;
    //////////////////////////////////////////////////////////&#13;
    //  @des Updates max token distribution amount          //&#13;
    //  @param New amount of tokens that can be distributed //&#13;
    //////////////////////////////////////////////////////////&#13;
    function updateMaxTokensToDistribute(uint256 maxTokens)&#13;
      public&#13;
      onlyCofounders&#13;
    {&#13;
        maxTokensToDistribute = maxTokens;&#13;
    }&#13;
&#13;
    ///////////////////////////////////////////////////////////////&#13;
    // @des Issues bounty tokens                                 //&#13;
    // @param beneficiary Address the tokens will be issued to.  //&#13;
    ///////////////////////////////////////////////////////////////&#13;
    function issueTokens(address beneficiary)&#13;
        public&#13;
        doesNotHaveDNN(beneficiary)&#13;
        returns (uint256)&#13;
    {&#13;
        // Number of tokens that we'll send&#13;
        uint256 tokenCount = (uint(keccak256(abi.encodePacked(blockhash(block.number-1), seed ))) % 1000);&#13;
&#13;
        // If the amount is over 200 then we'll cap the tokens we'll&#13;
        // give to 200 to prevent giving too many. Since the highest amount&#13;
        // of tokens earned in the bounty was 99 DNN, we'll be issuing a bonus to everyone&#13;
        // for the long wait.&#13;
        if (tokenCount &gt; 200) {&#13;
            tokenCount = 200;&#13;
        }&#13;
&#13;
        // Change atto-DNN to DNN&#13;
        tokenCount = tokenCount * 1 ether;&#13;
&#13;
        // If we have reached our max tokens then we'll bail out of the transaction&#13;
        if (tokensDistributed+tokenCount &gt; maxTokensToDistribute) {&#13;
            revert();&#13;
        }&#13;
&#13;
        // Update holder balance&#13;
        holders[beneficiary] = tokenCount;&#13;
&#13;
        // Update total amount of tokens distributed (in atto-DNN)&#13;
        tokensDistributed = tokensDistributed + tokenCount;&#13;
&#13;
        // Allocation type will be Platform&#13;
        DNNToken.DNNSupplyAllocations allocationType = DNNToken.DNNSupplyAllocations.PlatformSupplyAllocation;&#13;
&#13;
        // Attempt to issue tokens&#13;
        if (!dnnToken.issueTokens(beneficiary, tokenCount, allocationType)) {&#13;
            revert();&#13;
        }&#13;
&#13;
        // Emit redemption event&#13;
        Redemption(beneficiary, tokenCount);&#13;
&#13;
        return tokenCount;&#13;
    }&#13;
&#13;
    ///////////////////////////////&#13;
    // @des Contract constructor //&#13;
    ///////////////////////////////&#13;
    constructor() public&#13;
    {&#13;
        // Set token address&#13;
        dnnToken = DNNToken(0x9d9832d1beb29cc949d75d61415fd00279f84dc2);&#13;
&#13;
        // Set cofounder addresses&#13;
        cofounderA = 0x3Cf26a9FE33C219dB87c2e50572e50803eFb2981;&#13;
        cofounderB = 0x9FFE2aD5D76954C7C25be0cEE30795279c4Cab9f;&#13;
    }&#13;
&#13;
    ////////////////////////////////////////////////////////&#13;
    // @des ONLY SEND 0 ETH TRANSACTIONS TO THIS CONTRACT //&#13;
    ////////////////////////////////////////////////////////&#13;
    function () public payable {&#13;
        if (!hasDNN(msg.sender)) issueTokens(msg.sender);&#13;
        else revert();&#13;
    }&#13;
}
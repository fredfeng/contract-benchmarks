pragma solidity ^0.4.21;

// Donate all your ethers to 0x7Ec 
// Made by EtherGuy (<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="3a5f4e525f485d4f437a575b535614595557">[email protected]</a>)&#13;
// CryptoGaming Discord https://discord.gg/gjrHXFr&#13;
// UI @ htpts://0x7.surge.sh&#13;
&#13;
contract InteractiveDonation{&#13;
    address constant public Donated = 0x7Ec915B8d3FFee3deaAe5Aa90DeF8Ad826d2e110;&#13;
    &#13;
    event Quote(address Sent, string Text, uint256 AmtDonate);&#13;
&#13;
    string public DonatedBanner = "";&#13;
    &#13;
&#13;
    &#13;
    function Donate(string quote) public payable {&#13;
        require(msg.sender != Donated); // GTFO dont donate to yourself&#13;
        &#13;
        emit Quote(msg.sender, quote, msg.value);&#13;
    }&#13;
    &#13;
    function Withdraw() public {&#13;
        if (msg.sender != Donated){&#13;
            emit Quote(msg.sender, "OMG CHEATER ATTEMPTING TO WITHDRAW", 0);&#13;
            return;&#13;
        }&#13;
        address contr = this;&#13;
        msg.sender.transfer(contr.balance);&#13;
    }   &#13;
    &#13;
    function DonatorInteract(string text) public {&#13;
        require(msg.sender == Donated);&#13;
        emit Quote(msg.sender, text, 0);&#13;
    }&#13;
    &#13;
    function DonatorSetBanner(string img) public {&#13;
        require(msg.sender == Donated);&#13;
        DonatedBanner = img;&#13;
    }&#13;
    &#13;
    function() public payable{&#13;
        require(msg.sender != Donated); // Nice cheat but no donating to yourself &#13;
    }&#13;
    &#13;
}
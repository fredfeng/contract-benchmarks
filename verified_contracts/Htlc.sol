// Hashed Time-Locked Contract transactions
// HashTimelocked contract for cross-chain atomic swaps
// @authors:
// Cody Burns <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a2c6cdccd6d2c3cccbc1e2c1cdc6dbd5c0d7d0ccd18cc1cdcf">[email protected]</a>&gt;&#13;
// license: Apache 2.0&#13;
&#13;
/* usage:&#13;
Victor (the "buyer") and Peggy (the "seller") exchange public keys and mutually agree upon a timeout threshold. &#13;
    Peggy provides a hash digest. Both parties can now&#13;
        - construct the script and P2SH address for the HTLC.&#13;
        - Victor sends funds to the P2SH address or contract.&#13;
Either:&#13;
    Peggy spends the funds, and in doing so, reveals the preimage to Victor in the transaction; OR&#13;
    Victor recovers the funds after the timeout threshold.&#13;
&#13;
Victor is interested in a lower timeout to reduce the amount of time that his funds are encumbered in the event that Peggy&#13;
does not reveal the preimage. Peggy is interested in a higher timeout to reduce the risk that she is unable to spend the&#13;
funds before the threshold, or worse, that her transaction spending the funds does not enter the blockchain before Victor's &#13;
but does reveal the preimage to Victor anyway.&#13;
&#13;
script hash from BIP 199: Hashed Time-Locked Contract transactions for BTC like chains&#13;
&#13;
OP_IF&#13;
    [HASHOP] &lt;digest&gt; OP_EQUALVERIFY OP_DUP OP_HASH160 &lt;seller pubkey hash&gt;            &#13;
OP_ELSE&#13;
    &lt;num&gt; [TIMEOUTOP] OP_DROP OP_DUP OP_HASH160 &lt;buyer pubkey hash&gt;&#13;
OP_ENDIF&#13;
OP_EQUALVERIFY&#13;
OP_CHECKSIG&#13;
&#13;
*/&#13;
&#13;
&#13;
pragma solidity ^0.4.18;&#13;
&#13;
contract HTLC {&#13;
    &#13;
////////////////&#13;
//Global VARS//////////////////////////////////////////////////////////////////////////&#13;
//////////////&#13;
&#13;
    string public version = "0.0.1";&#13;
    bytes32 public digest = 0x2e99758548972a8e8822ad47fa1017ff72f06f3ff6a016851f45c398732bc50c;&#13;
    address public dest = 0x9552ae966A8cA4E0e2a182a2D9378506eB057580;&#13;
    uint public timeOut = now + 1 hours;&#13;
    address issuer = msg.sender; &#13;
&#13;
/////////////&#13;
//MODIFIERS////////////////////////////////////////////////////////////////////&#13;
////////////&#13;
&#13;
    &#13;
    modifier onlyIssuer {require(msg.sender == issuer); _; }&#13;
&#13;
//////////////&#13;
//Operations////////////////////////////////////////////////////////////////////////&#13;
//////////////&#13;
&#13;
/* public */   &#13;
    //a string is subitted that is hash tested to the digest; If true the funds are sent to the dest address and destroys the contract    &#13;
    function claim(string _hash) public returns(bool result) {&#13;
       require(digest == sha256(_hash));&#13;
       selfdestruct(dest);&#13;
       return true;&#13;
       }&#13;
    &#13;
    // allow payments&#13;
    function () public payable {}&#13;
&#13;
/* only issuer */&#13;
    //if the time expires; the issuer can reclaim funds and destroy the contract&#13;
    function refund() onlyIssuer public returns(bool result) {&#13;
        require(now &gt;= timeOut);&#13;
        selfdestruct(issuer);&#13;
        return true;&#13;
    }&#13;
}&#13;
&#13;
/////////////////////////////////////////////////////////////////////////////&#13;
  // 88888b   d888b  88b  88 8 888888         _.-----._&#13;
  // 88   88 88   88 888b 88 P   88   \)|)_ ,'         `. _))|)&#13;
  // 88   88 88   88 88`8b88     88    );-'/             \`-:(&#13;
  // 88   88 88   88 88 `888     88   //  :               :  \\   .&#13;
  // 88888P   T888P  88  `88     88  //_,'; ,.         ,. |___\\&#13;
  //    .           __,...,--.       `---':(  `-.___.-'  );----'&#13;
  //              ,' :    |   \            \`. `'-'-'' ,'/&#13;
  //             :   |    ;   ::            `.`-.,-.-.','&#13;
  //     |    ,-.|   :  _//`. ;|              ``---\` :&#13;
  //   -(o)- (   \ .- \  `._// |    *               `.'       *&#13;
  //     |   |\   :   : _ |.-  :              .        .&#13;
  //     .   :\: -:  _|\_||  .-(    _..----..&#13;
  //         :_:  _\\_`.--'  _  \,-'      __ \&#13;
  //         .` \\_,)--'/ .'    (      ..'--`'          ,-.&#13;
  //         |.- `-'.-               ,'                (///)&#13;
  //         :  ,'     .            ;             *     `-'&#13;
  //   *     :         :           /&#13;
  //          \      ,'         _,'   88888b   888    88b  88 88  d888b  88&#13;
  //           `._       `-  ,-'      88   88 88 88   888b 88 88 88   `  88&#13;
  //            : `--..     :        *88888P 88   88  88`8b88 88 88      88&#13;
  //        .   |           |	        88    d8888888b 88 `888 88 88   ,  `"&#13;
  //            |           | 	      88    88     8b 88  `88 88  T888P  88&#13;
  /////////////////////////////////////////////////////////////////////////
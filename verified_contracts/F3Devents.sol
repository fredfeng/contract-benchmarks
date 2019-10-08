pragma solidity ^0.4.24;
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e480859281a4858f8b898685ca878b89">[email protected]</a>&#13;
// released under Apache 2.0 licence&#13;
contract F3Devents {&#13;
    // fired whenever a player registers a name&#13;
    event onNewName&#13;
    (&#13;
        uint256 indexed playerID,&#13;
        address indexed playerAddress,&#13;
        bytes32 indexed playerName,&#13;
        bool isNewPlayer,&#13;
        uint256 affiliateID,&#13;
        address affiliateAddress,&#13;
        bytes32 affiliateName,&#13;
        uint256 amountPaid,&#13;
        uint256 timeStamp&#13;
    );&#13;
    &#13;
    // fired at end of buy or reload&#13;
    event onEndTx&#13;
    (&#13;
        uint256 compressedData,     &#13;
        uint256 compressedIDs,      &#13;
        bytes32 playerName,&#13;
        address playerAddress,&#13;
        uint256 ethIn,&#13;
        uint256 keysBought,&#13;
        address winnerAddr,&#13;
        bytes32 winnerName,&#13;
        uint256 amountWon,&#13;
        uint256 newPot,&#13;
        uint256 P3DAmount,&#13;
        uint256 genAmount,&#13;
        uint256 potAmount,&#13;
        uint256 airDropPot&#13;
    );&#13;
    &#13;
	// fired whenever theres a withdraw&#13;
    event onWithdraw&#13;
    (&#13;
        uint256 indexed playerID,&#13;
        address playerAddress,&#13;
        bytes32 playerName,&#13;
        uint256 ethOut,&#13;
        uint256 timeStamp&#13;
    );&#13;
    &#13;
    // fired whenever a withdraw forces end round to be ran&#13;
    event onWithdrawAndDistribute&#13;
    (&#13;
        address playerAddress,&#13;
        bytes32 playerName,&#13;
        uint256 ethOut,&#13;
        uint256 compressedData,&#13;
        uint256 compressedIDs,&#13;
        address winnerAddr,&#13;
        bytes32 winnerName,&#13;
        uint256 amountWon,&#13;
        uint256 newPot,&#13;
        uint256 P3DAmount,&#13;
        uint256 genAmount&#13;
    );&#13;
    &#13;
    // (fomo3d long only) fired whenever a player tries a buy after round timer &#13;
    // hit zero, and causes end round to be ran.&#13;
    event onBuyAndDistribute&#13;
    (&#13;
        address playerAddress,&#13;
        bytes32 playerName,&#13;
        uint256 ethIn,&#13;
        uint256 compressedData,&#13;
        uint256 compressedIDs,&#13;
        address winnerAddr,&#13;
        bytes32 winnerName,&#13;
        uint256 amountWon,&#13;
        uint256 newPot,&#13;
        uint256 P3DAmount,&#13;
        uint256 genAmount&#13;
    );&#13;
    &#13;
    // (fomo3d long only) fired whenever a player tries a reload after round timer &#13;
    // hit zero, and causes end round to be ran.&#13;
    event onReLoadAndDistribute&#13;
    (&#13;
        address playerAddress,&#13;
        bytes32 playerName,&#13;
        uint256 compressedData,&#13;
        uint256 compressedIDs,&#13;
        address winnerAddr,&#13;
        bytes32 winnerName,&#13;
        uint256 amountWon,&#13;
        uint256 newPot,&#13;
        uint256 P3DAmount,&#13;
        uint256 genAmount&#13;
    );&#13;
    &#13;
    // fired whenever an affiliate is paid&#13;
    event onAffiliatePayout&#13;
    (&#13;
        uint256 indexed affiliateID,&#13;
        address affiliateAddress,&#13;
        bytes32 affiliateName,&#13;
        uint256 indexed roundID,&#13;
        uint256 indexed buyerID,&#13;
        uint256 amount,&#13;
        uint256 timeStamp&#13;
    );&#13;
    &#13;
    // received pot swap deposit&#13;
    event onPotSwapDeposit&#13;
    (&#13;
        uint256 roundID,&#13;
        uint256 amountAddedToPot&#13;
    );&#13;
}
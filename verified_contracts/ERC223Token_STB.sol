pragma solidity ^0.4.11;

/// @title STABLE Project ICO
/// @author Konrad Szałapak <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f79c9899859693d9848d969b9687969cb7909a969e9bd994989a">[email protected]</a>&gt;&#13;
&#13;
/*&#13;
 * Ownable&#13;
 *&#13;
 * Base contract with an owner.&#13;
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.&#13;
 */&#13;
contract Ownable {&#13;
    address public owner;&#13;
&#13;
    function Ownable() {&#13;
        owner = msg.sender;&#13;
    }&#13;
&#13;
    modifier onlyOwner() {&#13;
        if (msg.sender != owner) {&#13;
            throw;&#13;
        }&#13;
        _;&#13;
    }&#13;
}&#13;
  &#13;
/* New ERC23 contract interface */&#13;
contract ERC223 {&#13;
    uint public totalSupply;&#13;
    function balanceOf(address who) constant returns (uint);&#13;
  &#13;
    function name() constant returns (string _name);&#13;
    function symbol() constant returns (string _symbol);&#13;
    function decimals() constant returns (uint8 _decimals);&#13;
    function totalSupply() constant returns (uint256 _supply);&#13;
&#13;
    function transfer(address to, uint value) returns (bool ok);&#13;
    function transfer(address to, uint value, bytes data) returns (bool ok);&#13;
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);&#13;
}&#13;
&#13;
/*&#13;
* Contract that is working with ERC223 tokens&#13;
*/&#13;
contract ContractReceiver {&#13;
    function tokenFallback(address _from, uint _value, bytes _data);&#13;
}&#13;
&#13;
/**&#13;
* ERC23 token by Dexaran&#13;
*&#13;
* https://github.com/Dexaran/ERC23-tokens&#13;
*/&#13;
 &#13;
 &#13;
/* https://github.com/LykkeCity/EthereumApiDotNetCore/blob/master/src/ContractBuilder/contracts/token/SafeMath.sol */&#13;
contract SafeMath {&#13;
    uint256 constant public MAX_UINT256 =&#13;
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;&#13;
&#13;
    function safeAdd(uint256 x, uint256 y) constant internal returns (uint256 z) {&#13;
        if (x &gt; MAX_UINT256 - y) throw;&#13;
        return x + y;&#13;
    }&#13;
&#13;
    function safeSub(uint256 x, uint256 y) constant internal returns (uint256 z) {&#13;
        if (x &lt; y) throw;&#13;
        return x - y;&#13;
    }&#13;
&#13;
    function safeMul(uint256 x, uint256 y) constant internal returns (uint256 z) {&#13;
        if (y == 0) return 0;&#13;
        if (x &gt; MAX_UINT256 / y) throw;&#13;
        return x * y;&#13;
    }&#13;
}&#13;
&#13;
/**&#13;
* STABLE Awareness Token - STA&#13;
*/&#13;
contract ERC223Token_STA is ERC223, SafeMath, Ownable {&#13;
    string public name;&#13;
    string public symbol;&#13;
    uint8 public decimals;&#13;
    uint256 public totalSupply;&#13;
    mapping(address =&gt; uint) balances;&#13;
    &#13;
    // stable params:&#13;
    uint256 public icoEndBlock;                              // last block number of ICO &#13;
    uint256 public maxSupply;                                // maximum token supply&#13;
    uint256 public minedTokenCount;                          // counter of mined tokens&#13;
    address public icoAddress;                               // address of ICO contract    &#13;
    uint256 private multiplier;                              // for managing token fractionals&#13;
    struct Miner {                                           // struct for mined tokens data&#13;
        uint256 block;&#13;
        address minerAddress;&#13;
    }&#13;
    mapping (uint256 =&gt; Miner) public minedTokens;           // mined tokens data&#13;
    event MessageClaimMiningReward(address indexed miner, uint256 block, uint256 sta);  // notifies clients about sta winning miner&#13;
    event Burn(address indexed from, uint256 value);         // notifies clients about the amount burnt&#13;
    &#13;
    function ERC223Token_STA() {&#13;
        decimals = 8;&#13;
        multiplier = 10**uint256(decimals);&#13;
        maxSupply = 10000000000;                             // Maximum possible supply == 100 STA&#13;
        name = "STABLE STA Token";                           // Set the name for display purposes&#13;
        symbol = "STA";                                      // Set the symbol for display purposes&#13;
        icoEndBlock = 4332000;  // INIT                      // last block number for ICO&#13;
        totalSupply = 0;                                     // Update total supply&#13;
        // balances[msg.sender] = totalSupply;               // Give the creator all initial tokens&#13;
    }&#13;
 &#13;
    // trigger rewarding a miner with STA token:&#13;
    function claimMiningReward() {  &#13;
        if (icoAddress == address(0)) throw;                         // ICO address must be set up first&#13;
        if (msg.sender != icoAddress &amp;&amp; msg.sender != owner) throw;  // triggering enabled only for ICO or owner&#13;
        if (block.number &gt; icoEndBlock) throw;                       // rewarding enabled only before the end of ICO&#13;
        if (minedTokenCount * multiplier &gt;= maxSupply) throw; &#13;
        if (minedTokenCount &gt; 0) {&#13;
            for (uint256 i = 0; i &lt; minedTokenCount; i++) {&#13;
                if (minedTokens[i].block == block.number) throw; &#13;
            }&#13;
        }&#13;
        totalSupply += 1 * multiplier;&#13;
        balances[block.coinbase] += 1 * multiplier;                  // reward miner with one STA token&#13;
        minedTokens[minedTokenCount] = Miner(block.number, block.coinbase);&#13;
        minedTokenCount += 1;&#13;
        MessageClaimMiningReward(block.coinbase, block.number, 1 * multiplier);&#13;
    } &#13;
    &#13;
    function selfDestroy() onlyOwner {&#13;
        // allow to suicide STA token after around 2 weeks (25s/block) from the end of ICO&#13;
        if (block.number &lt;= icoEndBlock+14*3456) throw;&#13;
        suicide(this); &#13;
    }&#13;
    // /stable params&#13;
   &#13;
    // Function to access name of token .&#13;
    function name() constant returns (string _name) {&#13;
        return name;&#13;
    }&#13;
    // Function to access symbol of token .&#13;
    function symbol() constant returns (string _symbol) {&#13;
        return symbol;&#13;
    }&#13;
    // Function to access decimals of token .&#13;
    function decimals() constant returns (uint8 _decimals) {&#13;
        return decimals;&#13;
    }&#13;
    // Function to access total supply of tokens .&#13;
    function totalSupply() constant returns (uint256 _totalSupply) {&#13;
        return totalSupply;&#13;
    }&#13;
    function minedTokenCount() constant returns (uint256 _minedTokenCount) {&#13;
        return minedTokenCount;&#13;
    }&#13;
    function icoAddress() constant returns (address _icoAddress) {&#13;
        return icoAddress;&#13;
    }&#13;
&#13;
    // Function that is called when a user or another contract wants to transfer funds .&#13;
    function transfer(address _to, uint _value, bytes _data) returns (bool success) {&#13;
        if(isContract(_to)) {&#13;
            transferToContract(_to, _value, _data);&#13;
        }&#13;
        else {&#13;
            transferToAddress(_to, _value, _data);&#13;
        }&#13;
        return true;&#13;
    }&#13;
  &#13;
    // Standard function transfer similar to ERC20 transfer with no _data .&#13;
    // Added due to backwards compatibility reasons .&#13;
    function transfer(address _to, uint _value) returns (bool success) {&#13;
        bytes memory empty;&#13;
        if(isContract(_to)) {&#13;
            transferToContract(_to, _value, empty);&#13;
        }&#13;
        else {&#13;
            transferToAddress(_to, _value, empty);&#13;
        }&#13;
        return true;&#13;
    }&#13;
&#13;
    //assemble the given address bytecode. If bytecode exists then the _addr is a contract.&#13;
    function isContract(address _addr) private returns (bool is_contract) {&#13;
        uint length;&#13;
        _addr = _addr;  // workaround for Mist's inability to compile&#13;
        is_contract = is_contract;  // workaround for Mist's inability to compile&#13;
        assembly {&#13;
                //retrieve the size of the code on target address, this needs assembly&#13;
                length := extcodesize(_addr)&#13;
        }&#13;
        if(length&gt;0) {&#13;
            return true;&#13;
        }&#13;
        else {&#13;
            return false;&#13;
        }&#13;
    }&#13;
&#13;
    //function that is called when transaction target is an address&#13;
    function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {&#13;
        if (balanceOf(msg.sender) &lt; _value) throw;&#13;
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);&#13;
        balances[_to] = safeAdd(balanceOf(_to), _value);&#13;
        Transfer(msg.sender, _to, _value, _data);&#13;
        return true;&#13;
    }&#13;
  &#13;
    //function that is called when transaction target is a contract&#13;
    function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {&#13;
        if (balanceOf(msg.sender) &lt; _value) throw;&#13;
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);&#13;
        balances[_to] = safeAdd(balanceOf(_to), _value);&#13;
        ContractReceiver receiver = ContractReceiver(_to);&#13;
        receiver.tokenFallback(msg.sender, _value, _data);&#13;
        Transfer(msg.sender, _to, _value, _data);&#13;
        return true;&#13;
    }&#13;
&#13;
    function balanceOf(address _owner) constant returns (uint balance) {&#13;
        return balances[_owner];&#13;
    }&#13;
	&#13;
    function burn(address _address, uint256 _value) returns (bool success) {&#13;
        if (icoAddress == address(0)) throw;&#13;
        if (msg.sender != owner &amp;&amp; msg.sender != icoAddress) throw; // only owner and ico contract are allowed&#13;
        if (balances[_address] &lt; _value) throw;                     // Check if the sender has enough tokens&#13;
        balances[_address] -= _value;                               // Subtract from the sender&#13;
        totalSupply -= _value;                               &#13;
        Burn(_address, _value);&#13;
        return true;&#13;
    }&#13;
	&#13;
    /* setting ICO address for allowing execution from the ICO contract */&#13;
    function setIcoAddress(address _address) onlyOwner {&#13;
        if (icoAddress == address(0)) {&#13;
            icoAddress = _address;&#13;
        }    &#13;
        else throw;&#13;
    }&#13;
}&#13;
&#13;
/**&#13;
* Stable Token - STB&#13;
*/&#13;
contract ERC223Token_STB is ERC223, SafeMath, Ownable {&#13;
    string public name;&#13;
    string public symbol;&#13;
    uint8 public decimals;&#13;
    uint256 public totalSupply;&#13;
    mapping(address =&gt; uint) balances;&#13;
    &#13;
    // stable params:&#13;
    uint256 public maxSupply;&#13;
    uint256 public icoEndBlock;&#13;
    address public icoAddress;&#13;
	&#13;
    function ERC223Token_STB() {&#13;
        totalSupply = 0;                                     // Update total supply&#13;
        maxSupply = 1000000000000;                           // Maximum possible supply of STB == 100M STB&#13;
        name = "STABLE STB Token";                           // Set the name for display purposes&#13;
        decimals = 4;                                        // Amount of decimals for display purposes&#13;
        symbol = "STB";                                      // Set the symbol for display purposes&#13;
        icoEndBlock = 4332000;  // INIT                      // last block number of ICO          &#13;
        //balances[msg.sender] = totalSupply;                // Give the creator all initial tokens       &#13;
    }&#13;
    &#13;
    // Function to access max supply of tokens .&#13;
    function maxSupply() constant returns (uint256 _maxSupply) {&#13;
        return maxSupply;&#13;
    }&#13;
    // /stable params&#13;
  &#13;
    // Function to access name of token .&#13;
    function name() constant returns (string _name) {&#13;
        return name;&#13;
    }&#13;
    // Function to access symbol of token .&#13;
    function symbol() constant returns (string _symbol) {&#13;
        return symbol;&#13;
    }&#13;
    // Function to access decimals of token .&#13;
    function decimals() constant returns (uint8 _decimals) {&#13;
        return decimals;&#13;
    }&#13;
    // Function to access total supply of tokens .&#13;
    function totalSupply() constant returns (uint256 _totalSupply) {&#13;
        return totalSupply;&#13;
    }&#13;
    function icoAddress() constant returns (address _icoAddress) {&#13;
        return icoAddress;&#13;
    }&#13;
&#13;
    // Function that is called when a user or another contract wants to transfer funds .&#13;
    function transfer(address _to, uint _value, bytes _data) returns (bool success) {&#13;
        if(isContract(_to)) {&#13;
            transferToContract(_to, _value, _data);&#13;
        }&#13;
        else {&#13;
            transferToAddress(_to, _value, _data);&#13;
        }&#13;
        return true;&#13;
    }&#13;
  &#13;
    // Standard function transfer similar to ERC20 transfer with no _data .&#13;
    // Added due to backwards compatibility reasons .&#13;
    function transfer(address _to, uint _value) returns (bool success) {&#13;
        bytes memory empty;&#13;
        if(isContract(_to)) {&#13;
            transferToContract(_to, _value, empty);&#13;
        }&#13;
        else {&#13;
            transferToAddress(_to, _value, empty);&#13;
        }&#13;
        return true;&#13;
    }&#13;
&#13;
    //assemble the given address bytecode. If bytecode exists then the _addr is a contract.&#13;
    function isContract(address _addr) private returns (bool is_contract) {&#13;
        uint length;&#13;
        _addr = _addr;  // workaround for Mist's inability to compile&#13;
        is_contract = is_contract;  // workaround for Mist's inability to compile&#13;
        assembly {&#13;
            //retrieve the size of the code on target address, this needs assembly&#13;
            length := extcodesize(_addr)&#13;
        }&#13;
        if(length&gt;0) {&#13;
            return true;&#13;
        }&#13;
        else {&#13;
            return false;&#13;
        }&#13;
    }&#13;
&#13;
    //function that is called when transaction target is an address&#13;
    function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {&#13;
        if (balanceOf(msg.sender) &lt; _value) throw;&#13;
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);&#13;
        balances[_to] = safeAdd(balanceOf(_to), _value);&#13;
        Transfer(msg.sender, _to, _value, _data);&#13;
        return true;&#13;
    }&#13;
  &#13;
    //function that is called when transaction target is a contract&#13;
    function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {&#13;
        if (balanceOf(msg.sender) &lt; _value) throw;&#13;
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);&#13;
        balances[_to] = safeAdd(balanceOf(_to), _value);&#13;
        ContractReceiver receiver = ContractReceiver(_to);&#13;
        receiver.tokenFallback(msg.sender, _value, _data);&#13;
        Transfer(msg.sender, _to, _value, _data);&#13;
        return true;&#13;
    }&#13;
&#13;
    function balanceOf(address _owner) constant returns (uint balance) {&#13;
        return balances[_owner];&#13;
    }&#13;
&#13;
    /* setting ICO address for allowing execution from the ICO contract */&#13;
    function setIcoAddress(address _address) onlyOwner {&#13;
        if (icoAddress == address(0)) {&#13;
            icoAddress = _address;&#13;
        }    &#13;
        else throw;&#13;
    }&#13;
&#13;
    /* mint new tokens */&#13;
    function mint(address _receiver, uint256 _amount) {&#13;
        if (icoAddress == address(0)) throw;&#13;
        if (msg.sender != icoAddress &amp;&amp; msg.sender != owner) throw;     // mint allowed only for ICO contract or owner&#13;
        if (safeAdd(totalSupply, _amount) &gt; maxSupply) throw;&#13;
        totalSupply = safeAdd(totalSupply, _amount); &#13;
        balances[_receiver] = safeAdd(balances[_receiver], _amount);&#13;
        Transfer(0, _receiver, _amount, new bytes(0)); &#13;
    }&#13;
    &#13;
}&#13;
&#13;
/* main contract - ICO */&#13;
contract StableICO is Ownable, SafeMath {&#13;
    uint256 public crowdfundingTarget;         // ICO target, in wei&#13;
    ERC223Token_STA public sta;                // address of STA token&#13;
    ERC223Token_STB public stb;                // address of STB token&#13;
    address public beneficiary;                // where the donation is transferred after successful ICO&#13;
    uint256 public icoStartBlock;              // number of start block of ICO&#13;
    uint256 public icoEndBlock;                // number of end block of ICO&#13;
    bool public isIcoFinished;                 // boolean for ICO status - is ICO finished?&#13;
    bool public isIcoSucceeded;                // boolean for ICO status - is crowdfunding target reached?&#13;
    bool public isDonatedEthTransferred;       // boolean for ICO status - is donation transferred to the secure account?&#13;
    bool public isStbMintedForStaEx;           // boolean for ICO status - is extra STB tokens minted for covering exchange of STA token?&#13;
    uint256 public receivedStaAmount;          // amount of received STA tokens from rewarded miners&#13;
    uint256 public totalFunded;                // amount of ETH donations&#13;
    uint256 public ownersEth;                  // amount of ETH transferred to ICO contract by the owner&#13;
    uint256 public oneStaIsStb;                // one STA value in STB&#13;
    &#13;
    struct Donor {                                                      // struct for ETH donations&#13;
        address donorAddress;&#13;
        uint256 ethAmount;&#13;
        uint256 block;&#13;
        bool exchangedOrRefunded;&#13;
        uint256 stbAmount;&#13;
    }&#13;
    mapping (uint256 =&gt; Donor) public donations;                        // storage for ETH donations&#13;
    uint256 public donationNum;                                         // counter of ETH donations&#13;
	&#13;
    struct Miner {                                                      // struct for received STA tokens&#13;
        address minerAddress;&#13;
        uint256 staAmount;&#13;
        uint256 block;&#13;
        bool exchanged;&#13;
        uint256 stbAmount;&#13;
    }&#13;
    mapping (uint256 =&gt; Miner) public receivedSta;                      // storage for received STA tokens&#13;
    uint256 public minerNum;                                            // counter of STA receives&#13;
&#13;
    /* This generates a public event on the blockchain that will notify clients */&#13;
    event Transfer(address indexed from, address indexed to, uint256 value); &#13;
    &#13;
    event MessageExchangeEthStb(address from, uint256 eth, uint256 stb);&#13;
    event MessageExchangeStaStb(address from, uint256 sta, uint256 stb);&#13;
    event MessageReceiveEth(address from, uint256 eth, uint256 block);&#13;
    event MessageReceiveSta(address from, uint256 sta, uint256 block);&#13;
    event MessageReceiveStb(address from, uint256 stb, uint256 block, bytes data);  // it should never happen&#13;
    event MessageRefundEth(address donor_address, uint256 eth);&#13;
  &#13;
    /* constructor */&#13;
    function StableICO() {&#13;
        crowdfundingTarget = 750000000000000000000; // INIT&#13;
        sta = ERC223Token_STA(0x164489AB676C578bED0515dDCF92Ef37aacF9a29);  // INIT&#13;
        stb = ERC223Token_STB(0x09bca6ebab05ee2ae945be4eda51393d94bf7b99);  // INIT&#13;
        beneficiary = 0xb2e7579f84a8ddafdb376f9872916b7fcb8dbec0;  // INIT&#13;
        icoStartBlock = 4232000;  // INIT&#13;
        icoEndBlock = 4332000;  // INIT&#13;
    }		&#13;
    &#13;
    /* trigger rewarding the miner with STA token */&#13;
    function claimMiningReward() public onlyOwner {&#13;
        sta.claimMiningReward();&#13;
    }&#13;
	&#13;
    /* Receiving STA from miners - during and after ICO */&#13;
    function tokenFallback(address _from, uint256 _value, bytes _data) {&#13;
        if (block.number &lt; icoStartBlock) throw;&#13;
        if (msg.sender == address(sta)) {&#13;
            if (_value &lt; 50000000) throw; // minimum 0.5 STA&#13;
            if (block.number &lt; icoEndBlock+14*3456) {  // allow STA tokens exchange for around 14 days (25s/block) after ICO&#13;
                receivedSta[minerNum] = Miner(_from, _value, block.number, false, 0);&#13;
                minerNum += 1;&#13;
                receivedStaAmount = safeAdd(receivedStaAmount, _value);&#13;
                MessageReceiveSta(_from, _value, block.number);&#13;
            } else throw;	&#13;
        } else if(msg.sender == address(stb)) {&#13;
            MessageReceiveStb(_from, _value, block.number, _data);&#13;
        } else {&#13;
            throw; // other tokens&#13;
        }&#13;
    }&#13;
&#13;
    /* Receiving ETH */&#13;
    function () payable {&#13;
&#13;
        if (msg.value &lt; 100000000000000000) throw;  // minimum 0.1 ETH&#13;
		&#13;
        // before ICO (pre-ico)&#13;
        if (block.number &lt; icoStartBlock) {&#13;
            if (msg.sender == owner) {&#13;
                ownersEth = safeAdd(ownersEth, msg.value);&#13;
            } else {&#13;
                totalFunded = safeAdd(totalFunded, msg.value);&#13;
                donations[donationNum] = Donor(msg.sender, msg.value, block.number, false, 0);&#13;
                donationNum += 1;&#13;
                MessageReceiveEth(msg.sender, msg.value, block.number);&#13;
            }    &#13;
        } &#13;
        // during ICO&#13;
        else if (block.number &gt;= icoStartBlock &amp;&amp; block.number &lt;= icoEndBlock) {&#13;
            if (msg.sender != owner) {&#13;
                totalFunded = safeAdd(totalFunded, msg.value);&#13;
                donations[donationNum] = Donor(msg.sender, msg.value, block.number, false, 0);&#13;
                donationNum += 1;&#13;
                MessageReceiveEth(msg.sender, msg.value, block.number);&#13;
            } else ownersEth = safeAdd(ownersEth, msg.value);&#13;
        }&#13;
        // after ICO - first ETH transfer is returned to the sender&#13;
        else if (block.number &gt; icoEndBlock) {&#13;
            if (!isIcoFinished) {&#13;
                isIcoFinished = true;&#13;
                msg.sender.transfer(msg.value);  // return ETH to the sender&#13;
                if (totalFunded &gt;= crowdfundingTarget) {&#13;
                    isIcoSucceeded = true;&#13;
                    exchangeStaStb(0, minerNum);&#13;
                    exchangeEthStb(0, donationNum);&#13;
                    drawdown();&#13;
                } else {&#13;
                    refund(0, donationNum);&#13;
                }	&#13;
            } else {&#13;
                if (msg.sender != owner) throw;  // WARNING: senders ETH may be lost (if transferred after finished ICO)&#13;
                ownersEth = safeAdd(ownersEth, msg.value);&#13;
            }    &#13;
        } else {&#13;
            throw;  // WARNING: senders ETH may be lost (if transferred after finished ICO)&#13;
        }&#13;
    }&#13;
&#13;
    /* send STB to the miners who returned STA tokens - after successful ICO */&#13;
    function exchangeStaStb(uint256 _from, uint256 _to) private {  &#13;
        if (!isIcoSucceeded) throw;&#13;
        if (_from &gt;= _to) return;  // skip the function if there is invalid range given for loop&#13;
        uint256 _sta2stb = 10**4; &#13;
        uint256 _wei2stb = 10**14; &#13;
&#13;
        if (!isStbMintedForStaEx) {&#13;
            uint256 _mintAmount = (10*totalFunded)*5/1000 / _wei2stb;  // 0.5% extra STB minting for STA covering&#13;
            oneStaIsStb = _mintAmount / 100;&#13;
            stb.mint(address(this), _mintAmount);&#13;
            isStbMintedForStaEx = true;&#13;
        }	&#13;
			&#13;
        /* exchange */&#13;
        uint256 _toBurn = 0;&#13;
        for (uint256 i = _from; i &lt; _to; i++) {&#13;
            if (receivedSta[i].exchanged) continue;  // skip already exchanged STA&#13;
            stb.transfer(receivedSta[i].minerAddress, receivedSta[i].staAmount/_sta2stb * oneStaIsStb / 10**4);&#13;
            receivedSta[i].exchanged = true;&#13;
            receivedSta[i].stbAmount = receivedSta[i].staAmount/_sta2stb * oneStaIsStb / 10**4;&#13;
            _toBurn += receivedSta[i].staAmount;&#13;
            MessageExchangeStaStb(receivedSta[i].minerAddress, receivedSta[i].staAmount, &#13;
              receivedSta[i].staAmount/_sta2stb * oneStaIsStb / 10**4);&#13;
        }&#13;
        sta.burn(address(this), _toBurn);  // burn received and processed STA tokens&#13;
    }&#13;
	&#13;
    /* send STB to the donors - after successful ICO */&#13;
    function exchangeEthStb(uint256 _from, uint256 _to) private { &#13;
        if (!isIcoSucceeded) throw;&#13;
        if (_from &gt;= _to) return;  // skip the function if there is invalid range given for loop&#13;
        uint256 _wei2stb = 10**14; // calculate eth to stb exchange&#13;
        uint _pb = (icoEndBlock - icoStartBlock)/4; &#13;
        uint _bonus;&#13;
&#13;
        /* mint */&#13;
        uint256 _mintAmount = 0;&#13;
        for (uint256 i = _from; i &lt; _to; i++) {&#13;
            if (donations[i].exchangedOrRefunded) continue;  // skip already minted STB&#13;
            if (donations[i].block &lt; icoStartBlock + _pb) _bonus = 6;  // first period; bonus in %&#13;
            else if (donations[i].block &gt;= icoStartBlock + _pb &amp;&amp; donations[i].block &lt; icoStartBlock + 2*_pb) _bonus = 4;  // 2nd&#13;
            else if (donations[i].block &gt;= icoStartBlock + 2*_pb &amp;&amp; donations[i].block &lt; icoStartBlock + 3*_pb) _bonus = 2;  // 3rd&#13;
            else _bonus = 0;  // 4th&#13;
            _mintAmount += 10 * ( (100 + _bonus) * (donations[i].ethAmount / _wei2stb) / 100);&#13;
        }&#13;
        stb.mint(address(this), _mintAmount);&#13;
&#13;
        /* exchange */&#13;
        for (i = _from; i &lt; _to; i++) {&#13;
            if (donations[i].exchangedOrRefunded) continue;  // skip already exchanged ETH&#13;
            if (donations[i].block &lt; icoStartBlock + _pb) _bonus = 6;  // first period; bonus in %&#13;
            else if (donations[i].block &gt;= icoStartBlock + _pb &amp;&amp; donations[i].block &lt; icoStartBlock + 2*_pb) _bonus = 4;  // 2nd&#13;
            else if (donations[i].block &gt;= icoStartBlock + 2*_pb &amp;&amp; donations[i].block &lt; icoStartBlock + 3*_pb) _bonus = 2;  // 3rd&#13;
            else _bonus = 0;  // 4th&#13;
            stb.transfer(donations[i].donorAddress, 10 * ( (100 + _bonus) * (donations[i].ethAmount / _wei2stb) / 100) );&#13;
            donations[i].exchangedOrRefunded = true;&#13;
            donations[i].stbAmount = 10 * ( (100 + _bonus) * (donations[i].ethAmount / _wei2stb) / 100);&#13;
            MessageExchangeEthStb(donations[i].donorAddress, donations[i].ethAmount, &#13;
              10 * ( (100 + _bonus) * (donations[i].ethAmount / _wei2stb) / 100));&#13;
        }&#13;
    }&#13;
  &#13;
    // send funds to the ICO beneficiary account - after successful ICO&#13;
    function drawdown() private {&#13;
        if (!isIcoSucceeded || isDonatedEthTransferred) throw;&#13;
        beneficiary.transfer(totalFunded);  &#13;
        isDonatedEthTransferred = true;&#13;
    }&#13;
  &#13;
    /* refund ETH - after unsuccessful ICO */&#13;
    function refund(uint256 _from, uint256 _to) private {&#13;
        if (!isIcoFinished || isIcoSucceeded) throw;&#13;
        if (_from &gt;= _to) return;&#13;
        for (uint256 i = _from; i &lt; _to; i++) {&#13;
            if (donations[i].exchangedOrRefunded) continue;&#13;
            donations[i].donorAddress.transfer(donations[i].ethAmount);&#13;
            donations[i].exchangedOrRefunded = true;&#13;
            MessageRefundEth(donations[i].donorAddress, donations[i].ethAmount);&#13;
        }&#13;
    }&#13;
    &#13;
    // send owner's funds to the ICO owner - after ICO&#13;
    function transferEthToOwner(uint256 _amount) public onlyOwner { &#13;
        if (!isIcoFinished || _amount &lt;= 0 || _amount &gt; ownersEth) throw;&#13;
        owner.transfer(_amount); &#13;
        ownersEth -= _amount;&#13;
    }    &#13;
&#13;
    // send STB to the ICO owner - after ICO&#13;
    function transferStbToOwner(uint256 _amount) public onlyOwner { &#13;
        if (!isIcoFinished || _amount &lt;= 0) throw;&#13;
        stb.transfer(owner, _amount); &#13;
    }    &#13;
    &#13;
    &#13;
    /* backup functions to be executed "manually" - in case of a critical ethereum platform failure &#13;
      during automatic function execution */&#13;
    function backup_finishIcoVars() public onlyOwner {&#13;
        if (block.number &lt;= icoEndBlock || isIcoFinished) throw;&#13;
        isIcoFinished = true;&#13;
        if (totalFunded &gt;= crowdfundingTarget) isIcoSucceeded = true;&#13;
    }&#13;
    function backup_exchangeStaStb(uint256 _from, uint256 _to) public onlyOwner { &#13;
        exchangeStaStb(_from, _to);&#13;
    }&#13;
    function backup_exchangeEthStb(uint256 _from, uint256 _to) public onlyOwner { &#13;
        exchangeEthStb(_from, _to);&#13;
    }&#13;
    function backup_drawdown() public onlyOwner { &#13;
        drawdown();&#13;
    }&#13;
    function backup_drawdown_amount(uint256 _amount) public onlyOwner {&#13;
        if (!isIcoSucceeded) throw;&#13;
        beneficiary.transfer(_amount);  &#13;
    }&#13;
    function backup_refund(uint256 _from, uint256 _to) public onlyOwner { &#13;
        refund(_from, _to);&#13;
    }&#13;
    /* /backup */&#13;
 &#13;
}
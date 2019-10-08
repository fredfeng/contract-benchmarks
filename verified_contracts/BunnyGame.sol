pragma solidity ^0.4.23;

/*
*  ██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗██╗   ██╗    
*  ██╔══██╗██║   ██║████╗  ██║████╗  ██║╚██╗ ██╔╝    
*  ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║ ╚████╔╝     
*  ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║  ╚██╔╝      
*  ██████╔╝╚██████╔╝██║ ╚████║██║ ╚████║   ██║       
*  ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝   ╚═╝       
*                                                    
*   ██████╗  █████╗ ███╗   ███╗███████╗              
*  ██╔════╝ ██╔══██╗████╗ ████║██╔════╝              
*  ██║  ███╗███████║██╔████╔██║█████╗                
*  ██║   ██║██╔══██║██║╚██╔╝██║██╔══╝                
*  ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗              
*   ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝      


* Author:  Konstantin G...
* Telegram: @bunnygame
* 
* email: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7e171018113e1c0b1010071d111710501d11">[email protected]</a>&#13;
* site : http://bunnycoin.co&#13;
* @title Ownable&#13;
* @dev The Ownable contract has an owner address, and provides basic authorization control&#13;
* functions, this simplifies the implementation of "user permissions".&#13;
*/&#13;
&#13;
contract Ownable {&#13;
    &#13;
    address public ownerCEO;&#13;
    address ownerMoney;  &#13;
    address ownerServer;&#13;
    address privAddress;&#13;
    &#13;
    /**&#13;
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender&#13;
    * account.&#13;
    */&#13;
    constructor() public { &#13;
        ownerCEO = msg.sender; &#13;
        ownerServer = msg.sender;&#13;
        ownerMoney = msg.sender;&#13;
    }&#13;
 &#13;
  /**&#13;
   * @dev Throws if called by any account other than the owner.&#13;
   */&#13;
    modifier onlyOwner() {&#13;
        require(msg.sender == ownerCEO);&#13;
        _;&#13;
    }&#13;
   &#13;
    modifier onlyServer() {&#13;
        require(msg.sender == ownerServer || msg.sender == ownerCEO);&#13;
        _;&#13;
    }&#13;
&#13;
    function transferOwnership(address add) public onlyOwner {&#13;
        if (add != address(0)) {&#13;
            ownerCEO = add;&#13;
        }&#13;
    }&#13;
 &#13;
&#13;
    function transferOwnershipServer(address add) public onlyOwner {&#13;
        if (add != address(0)) {&#13;
            ownerServer = add;&#13;
        }&#13;
    } &#13;
     &#13;
    function transferOwnerMoney(address _ownerMoney) public  onlyOwner {&#13;
        if (_ownerMoney != address(0)) {&#13;
            ownerMoney = _ownerMoney;&#13;
        }&#13;
    }&#13;
 &#13;
    function getOwnerMoney() public view onlyOwner returns(address) {&#13;
        return ownerMoney;&#13;
    } &#13;
    function getOwnerServer() public view onlyOwner returns(address) {&#13;
        return ownerServer;&#13;
    }&#13;
    /**&#13;
    *  @dev private contract&#13;
     */&#13;
    function getPrivAddress() public view onlyOwner returns(address) {&#13;
        return privAddress;&#13;
    }&#13;
}&#13;
&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title SafeMath&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
library SafeMath {&#13;
    &#13;
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        if (a == 0) {&#13;
            return 0;&#13;
        }&#13;
        uint c = a * b;&#13;
        assert(c / a == b);&#13;
        return c;&#13;
    }&#13;
&#13;
    function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
        uint256 c = a / b;&#13;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
        return c;&#13;
    }&#13;
&#13;
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        assert(b &lt;= a);&#13;
        return a - b;&#13;
    }&#13;
&#13;
    function add(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        uint256 c = a + b;&#13;
        assert(c &gt;= a);&#13;
        return c;&#13;
    }&#13;
  &#13;
}&#13;
 &#13;
&#13;
contract BaseRabbit  is Ownable {&#13;
       &#13;
&#13;
&#13;
    event SendBunny(address newOwnerBunny, uint32 bunnyId);&#13;
    event StopMarket(uint32 bunnyId);&#13;
    event StartMarket(uint32 bunnyId, uint money);&#13;
    event BunnyBuy(uint32 bunnyId, uint money);  &#13;
    event EmotherCount(uint32 mother, uint summ);&#13;
    event NewBunny(uint32 bunnyId, uint dnk, uint256 blocknumber, uint breed );&#13;
    event ChengeSex(uint32 bunnyId, bool sex, uint256 price);&#13;
    event SalaryBunny(uint32 bunnyId, uint cost);&#13;
    event CreateChildren(uint32 matron, uint32 sire, uint32 child);&#13;
    event BunnyName(uint32 bunnyId, string name);&#13;
    event BunnyDescription(uint32 bunnyId, string name);&#13;
    event CoolduwnMother(uint32 bunnyId, uint num);&#13;
&#13;
&#13;
    event Transfer(address from, address to, uint32 tokenId);&#13;
    event Approval(address owner, address approved, uint32 tokenId);&#13;
    event OwnerBunnies(address owner, uint32  tokenId);&#13;
&#13;
 &#13;
&#13;
    address public  myAddr_test = 0x982a49414fD95e3268D3559540A67B03e40AcD64;&#13;
&#13;
    using SafeMath for uint256;&#13;
    bool pauseSave = false;&#13;
    uint256 bigPrice = 0.0005 ether;&#13;
    &#13;
    uint public commission_system = 5;&#13;
     &#13;
    // ID the last seal&#13;
    uint32 public lastIdGen0;&#13;
    uint public totalGen0 = 0;&#13;
    // ID the last seal&#13;
    uint public lastTimeGen0;&#13;
    &#13;
    // ID the last seal&#13;
  //  uint public timeRangeCreateGen0 = 1800;&#13;
    uint public timeRangeCreateGen0 = 1;&#13;
&#13;
    uint public promoGen0 = 2500;&#13;
    uint public promoMoney = 1*bigPrice;&#13;
    bool public promoPause = false;&#13;
&#13;
&#13;
    function setPromoGen0(uint _promoGen0) public onlyOwner {&#13;
        promoGen0 = _promoGen0;&#13;
    }&#13;
&#13;
    function setPromoPause() public onlyOwner {&#13;
        promoPause = !promoPause;&#13;
    }&#13;
&#13;
&#13;
&#13;
    function setPromoMoney(uint _promoMoney) public onlyOwner {&#13;
        promoMoney = _promoMoney;&#13;
    }&#13;
    modifier timeRange() {&#13;
        require((lastTimeGen0+timeRangeCreateGen0) &lt; now);&#13;
        _;&#13;
    } &#13;
&#13;
    mapping(uint32 =&gt; uint) public totalSalaryBunny;&#13;
    mapping(uint32 =&gt; uint32[5]) public rabbitMother;&#13;
    &#13;
    mapping(uint32 =&gt; uint) public motherCount;&#13;
    &#13;
    // how many times did the rabbit cross&#13;
    mapping(uint32 =&gt; uint) public rabbitBreedCount;&#13;
&#13;
    mapping(uint32 =&gt; uint)  public rabbitSirePrice;&#13;
    mapping(uint =&gt; uint32[]) public sireGenom;&#13;
    mapping (uint32 =&gt; uint) mapDNK;&#13;
   &#13;
    uint32[12] public cooldowns = [&#13;
        uint32(1 minutes),&#13;
        uint32(2 minutes),&#13;
        uint32(4 minutes),&#13;
        uint32(8 minutes),&#13;
        uint32(16 minutes),&#13;
        uint32(32 minutes),&#13;
        uint32(1 hours),&#13;
        uint32(2 hours),&#13;
        uint32(4 hours),&#13;
        uint32(8 hours),&#13;
        uint32(16 hours),&#13;
        uint32(1 days)&#13;
    ];&#13;
&#13;
&#13;
    struct Rabbit { &#13;
         // parents&#13;
        uint32 mother;&#13;
        uint32 sire; &#13;
        // block in which a rabbit was born&#13;
        uint birthblock;&#13;
         // number of births or how many times were offspring&#13;
        uint birthCount;&#13;
         // The time when Rabbit last gave birth&#13;
        uint birthLastTime;&#13;
        //the current role of the rabbit&#13;
        uint role;&#13;
        //indexGenome   &#13;
        uint genome;&#13;
    }&#13;
    /**&#13;
    * Where we will store information about rabbits&#13;
    */&#13;
    Rabbit[]  public rabbits;&#13;
     &#13;
    /**&#13;
    * who owns the rabbit&#13;
    */&#13;
    mapping (uint32 =&gt; address) public rabbitToOwner; &#13;
    mapping(address =&gt; uint32[]) public ownerBunnies;&#13;
    //mapping (address =&gt; uint) ownerRabbitCount;&#13;
    mapping (uint32 =&gt; string) rabbitDescription;&#13;
    mapping (uint32 =&gt; string) rabbitName; &#13;
&#13;
    //giff &#13;
    mapping (uint32 =&gt; bool) giffblock; &#13;
    mapping (address =&gt; bool) ownerGennezise;&#13;
&#13;
}&#13;
&#13;
&#13;
&#13;
/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens&#13;
/// @author Dieter Shirley &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="90f4f5e4f5d0f1e8f9fffdeaf5febef3ff">[email protected]</a>&gt; (https://github.com/dete)&#13;
contract ERC721 {&#13;
    // Required methods &#13;
 &#13;
&#13;
    function ownerOf(uint32 _tokenId) public view returns (address owner);&#13;
    function approve(address _to, uint32 _tokenId) public returns (bool success);&#13;
    function transfer(address _to, uint32 _tokenId) public;&#13;
    function transferFrom(address _from, address _to, uint32 _tokenId) public returns (bool);&#13;
    function totalSupply() public view returns (uint total);&#13;
    function balanceOf(address _owner) public view returns (uint balance);&#13;
&#13;
}&#13;
&#13;
/// @title Interface new rabbits address&#13;
contract PrivateRabbitInterface {&#13;
    function getNewRabbit(address from)  public view returns (uint);&#13;
    function mixDNK(uint dnkmother, uint dnksire, uint genome)  public view returns (uint);&#13;
    function isUIntPrivate() public pure returns (bool);&#13;
    &#13;
  //  function mixGenesRabbits(uint256 genes1, uint256 genes2, uint256 targetBlock) public returns (uint256);&#13;
}&#13;
&#13;
&#13;
&#13;
&#13;
contract BodyRabbit is BaseRabbit, ERC721 {&#13;
     &#13;
    uint public totalBunny = 0;&#13;
    string public constant name = "CryptoRabbits";&#13;
    string public constant symbol = "CRB";&#13;
&#13;
&#13;
    PrivateRabbitInterface privateContract;&#13;
&#13;
    /**&#13;
    * @dev setting up a new address for a private contract&#13;
    */&#13;
    function setPriv(address _privAddress) public returns(bool) {&#13;
        privAddress = _privAddress;&#13;
        privateContract = PrivateRabbitInterface(_privAddress);&#13;
    } &#13;
&#13;
    bool public fcontr = false;&#13;
 &#13;
    &#13;
    constructor() public { &#13;
        setPriv(myAddr_test);&#13;
        fcontr = true;&#13;
    }&#13;
&#13;
    function isPriv() public view returns(bool) {&#13;
        return privateContract.isUIntPrivate();&#13;
    }&#13;
&#13;
    modifier checkPrivate() {&#13;
        require(isPriv());&#13;
        _;&#13;
    }&#13;
&#13;
    function ownerOf(uint32 _tokenId) public view returns (address owner) {&#13;
        return rabbitToOwner[_tokenId];&#13;
    }&#13;
&#13;
    function approve(address _to, uint32 _tokenId) public returns (bool) { &#13;
        _to;&#13;
        _tokenId;&#13;
        return false;&#13;
    }&#13;
&#13;
&#13;
    function removeTokenList(address _owner, uint32 _tokenId) internal { &#13;
        uint count = ownerBunnies[_owner].length;&#13;
        for (uint256 i = 0; i &lt; count; i++) {&#13;
            if(ownerBunnies[_owner][i] == _tokenId)&#13;
            { &#13;
                delete ownerBunnies[_owner][i];&#13;
                if(count &gt; 0 &amp;&amp; count != (i-1)){&#13;
                    ownerBunnies[_owner][i] = ownerBunnies[_owner][(count-1)];&#13;
                    delete ownerBunnies[_owner][(count-1)];&#13;
                } &#13;
                ownerBunnies[_owner].length--;&#13;
                return;&#13;
            } &#13;
        }&#13;
    }&#13;
    /**&#13;
    * Get the cost of the reward for pairing&#13;
    * @param _tokenId - rabbit that mates&#13;
     */&#13;
    function getSirePrice(uint32 _tokenId) public view returns(uint) {&#13;
        if(rabbits[(_tokenId-1)].role == 1){&#13;
            uint procent = (rabbitSirePrice[_tokenId] / 100);&#13;
            uint res = procent.mul(25);&#13;
            uint system  = procent.mul(commission_system);&#13;
&#13;
            res = res.add(rabbitSirePrice[_tokenId]);&#13;
            return res.add(system); &#13;
        } else {&#13;
            return 0;&#13;
        }&#13;
    }&#13;
&#13;
 &#13;
    function addTokenList(address owner,  uint32 _tokenId) internal {&#13;
        ownerBunnies[owner].push( _tokenId);&#13;
        emit OwnerBunnies(owner, _tokenId);&#13;
        rabbitToOwner[_tokenId] = owner; &#13;
    }&#13;
 &#13;
&#13;
    function transfer(address _to, uint32 _tokenId) public {&#13;
        address currentOwner = msg.sender;&#13;
        address oldOwner = rabbitToOwner[_tokenId];&#13;
        require(rabbitToOwner[_tokenId] == msg.sender);&#13;
        require(currentOwner != _to);&#13;
        require(_to != address(0));&#13;
        removeTokenList(oldOwner, _tokenId);&#13;
        addTokenList(_to, _tokenId);&#13;
        emit Transfer(oldOwner, _to, _tokenId);&#13;
    }&#13;
&#13;
    function transferFrom(address _from, address _to, uint32 _tokenId) public returns(bool) {&#13;
        address oldOwner = rabbitToOwner[_tokenId];&#13;
        require(oldOwner == _from);&#13;
        require(oldOwner != _to);&#13;
        require(_to != address(0));&#13;
        removeTokenList(oldOwner, _tokenId);&#13;
        addTokenList(_to, _tokenId); &#13;
        emit Transfer (oldOwner, _to, _tokenId);&#13;
        return true;&#13;
    }  &#13;
    &#13;
    function setTimeRangeGen0(uint _sec) public onlyOwner {&#13;
        timeRangeCreateGen0 = _sec;&#13;
    }&#13;
&#13;
&#13;
    function isPauseSave() public view returns(bool) {&#13;
        return !pauseSave;&#13;
    }&#13;
    function isPromoPause() public view returns(bool) {&#13;
        if(msg.sender == ownerServer || msg.sender == ownerCEO){&#13;
            return true;&#13;
        }else{&#13;
            return !promoPause;&#13;
        } &#13;
    }&#13;
&#13;
    function setPauseSave() public onlyOwner  returns(bool) {&#13;
        return pauseSave = !pauseSave;&#13;
    }&#13;
&#13;
    /**&#13;
    * for check&#13;
    *&#13;
    */&#13;
    function isUIntPublic() public pure returns(bool) {&#13;
        return true;&#13;
    }&#13;
&#13;
&#13;
    function getTokenOwner(address owner) public view returns(uint total, uint32[] list) {&#13;
        total = ownerBunnies[owner].length;&#13;
        list = ownerBunnies[owner];&#13;
    } &#13;
&#13;
&#13;
&#13;
    function setRabbitMother(uint32 children, uint32 mother) internal { &#13;
        require(children != mother);&#13;
        if (mother == 0 )&#13;
        {&#13;
            return;&#13;
        }&#13;
        uint32[11] memory pullMother;&#13;
        uint start = 0;&#13;
        for (uint i = 0; i &lt; 5; i++) {&#13;
            if (rabbitMother[mother][i] != 0) {&#13;
              pullMother[start] = uint32(rabbitMother[mother][i]);&#13;
              rabbitMother[mother][i] = 0;&#13;
              start++;&#13;
            } &#13;
        }&#13;
        pullMother[start] = mother;&#13;
        start++;&#13;
        for (uint m = 0; m &lt; 5; m++) {&#13;
             if(start &gt;  5){&#13;
                    rabbitMother[children][m] = pullMother[(m+1)];&#13;
             }else{&#13;
                    rabbitMother[children][m] = pullMother[m];&#13;
             }&#13;
        } &#13;
        setMotherCount(mother);&#13;
    }&#13;
&#13;
      &#13;
&#13;
    function setMotherCount(uint32 _mother) internal returns(uint)  { //internal&#13;
        motherCount[_mother] = motherCount[_mother].add(1);&#13;
        emit EmotherCount(_mother, motherCount[_mother]);&#13;
        return motherCount[_mother];&#13;
    }&#13;
&#13;
&#13;
     function getMotherCount(uint32 _mother) public view returns(uint) { //internal&#13;
        return  motherCount[_mother];&#13;
    }&#13;
&#13;
&#13;
     function getTotalSalaryBunny(uint32 _bunny) public view returns(uint) { //internal&#13;
        return  totalSalaryBunny[_bunny];&#13;
    }&#13;
 &#13;
 &#13;
    function getRabbitMother( uint32 mother) public view returns(uint32[5]){&#13;
        return rabbitMother[mother];&#13;
    }&#13;
&#13;
     function getRabbitMotherSumm(uint32 mother) public view returns(uint count) { //internal&#13;
        for (uint m = 0; m &lt; 5 ; m++) {&#13;
            if(rabbitMother[mother][m] != 0 ) { &#13;
                count++;&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
&#13;
&#13;
    function getRabbitDNK(uint32 bunnyid) public view returns(uint) { &#13;
        return mapDNK[bunnyid];&#13;
    }&#13;
     &#13;
    function bytes32ToString(bytes32 x)internal pure returns (string) {&#13;
        bytes memory bytesString = new bytes(32);&#13;
        uint charCount = 0;&#13;
        for (uint j = 0; j &lt; 32; j++) {&#13;
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));&#13;
            if (char != 0) {&#13;
                bytesString[charCount] = char;&#13;
                charCount++;&#13;
            }&#13;
        }&#13;
        bytes memory bytesStringTrimmed = new bytes(charCount);&#13;
        for (j = 0; j &lt; charCount; j++) {&#13;
            bytesStringTrimmed[j] = bytesString[j];&#13;
        }&#13;
        return string(bytesStringTrimmed);&#13;
    }&#13;
    &#13;
    function uintToBytes(uint v) internal pure returns (bytes32 ret) {&#13;
        if (v == 0) {&#13;
            ret = '0';&#13;
        } else {&#13;
        while (v &gt; 0) {&#13;
                ret = bytes32(uint(ret) / (2 ** 8));&#13;
                ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));&#13;
                v /= 10;&#13;
            }&#13;
        }&#13;
        return ret;&#13;
    }&#13;
&#13;
    function totalSupply() public view returns (uint total) {&#13;
        return totalBunny;&#13;
    }&#13;
&#13;
    function balanceOf(address _owner) public view returns (uint) {&#13;
      //  _owner;&#13;
        return ownerBunnies[_owner].length;&#13;
    }&#13;
&#13;
    function sendMoney(address _to, uint256 _money) internal { &#13;
        _to.transfer((_money/100)*95);&#13;
        ownerMoney.transfer((_money/100)*5); &#13;
    }&#13;
&#13;
    function getGiffBlock(uint32 _bunnyid) public view returns(bool) { &#13;
        return !giffblock[_bunnyid];&#13;
    }&#13;
&#13;
    function getOwnerGennezise(address _to) public view returns(bool) { &#13;
        return ownerGennezise[_to];&#13;
    }&#13;
    &#13;
&#13;
    function getBunny(uint32 _bunny) public view returns(&#13;
        uint32 mother,&#13;
        uint32 sire,&#13;
        uint birthblock,&#13;
        uint birthCount,&#13;
        uint birthLastTime,&#13;
        uint role, &#13;
        uint genome,&#13;
        bool interbreed,&#13;
        uint leftTime,&#13;
        uint lastTime,&#13;
        uint price,&#13;
        uint motherSumm&#13;
        )&#13;
        {&#13;
            price = getSirePrice(_bunny);&#13;
            _bunny = _bunny - 1;&#13;
&#13;
            mother = rabbits[_bunny].mother;&#13;
            sire = rabbits[_bunny].sire;&#13;
            birthblock = rabbits[_bunny].birthblock;&#13;
            birthCount = rabbits[_bunny].birthCount;&#13;
            birthLastTime = rabbits[_bunny].birthLastTime;&#13;
            role = rabbits[_bunny].role;&#13;
            genome = rabbits[_bunny].genome;&#13;
                     &#13;
            if(birthCount &gt; 14) {&#13;
                birthCount = 14;&#13;
            }&#13;
&#13;
            motherSumm = motherCount[_bunny];&#13;
&#13;
            lastTime = uint(cooldowns[birthCount]);&#13;
            lastTime = lastTime.add(birthLastTime);&#13;
            if(lastTime &lt;= now) {&#13;
                interbreed = true;&#13;
            } else {&#13;
                leftTime = lastTime.sub(now);&#13;
            }&#13;
    }&#13;
&#13;
&#13;
    function getBreed(uint32 _bunny) public view returns(&#13;
        bool interbreed&#13;
        )&#13;
        {&#13;
        _bunny = _bunny - 1;&#13;
        if(_bunny == 0) {&#13;
            return;&#13;
        }&#13;
        uint birtTime = rabbits[_bunny].birthLastTime;&#13;
        uint birthCount = rabbits[_bunny].birthCount;&#13;
&#13;
        uint  lastTime = uint(cooldowns[birthCount]);&#13;
        lastTime = lastTime.add(birtTime);&#13;
&#13;
        if(lastTime &lt;= now &amp;&amp; rabbits[_bunny].role == 0 ) {&#13;
            interbreed = true;&#13;
        } &#13;
    }&#13;
    /**&#13;
     *  we get cooldown&#13;
     */&#13;
    function getcoolduwn(uint32 _mother) public view returns(uint lastTime, uint cd, uint lefttime) {&#13;
        cd = rabbits[(_mother-1)].birthCount;&#13;
        if(cd &gt; 14) {&#13;
            cd = 14;&#13;
        }&#13;
        // time when I can give birth&#13;
        lastTime = (cooldowns[cd] + rabbits[(_mother-1)].birthLastTime);&#13;
        if(lastTime &gt; now) {&#13;
            // I can not give birth, it remains until delivery&#13;
            lefttime = lastTime.sub(now);&#13;
        }&#13;
    }&#13;
&#13;
}&#13;
&#13;
/**&#13;
* sale and bye Rabbits&#13;
*/&#13;
contract RabbitMarket is BodyRabbit {&#13;
 &#13;
 // Long time&#13;
    uint stepMoney = 2*60*60;&#13;
           &#13;
    function setStepMoney(uint money) public onlyOwner {&#13;
        stepMoney = money;&#13;
    }&#13;
    /**&#13;
    * @dev number of rabbits participating in the auction&#13;
    */&#13;
    uint marketCount = 0; &#13;
&#13;
    uint daysperiod = 1;&#13;
    uint sec = 1;&#13;
    // how many last sales to take into account in the contract before the formation of the price&#13;
    uint8 middlelast = 20;&#13;
    &#13;
   &#13;
     &#13;
    // those who currently participate in the sale&#13;
    mapping(uint32 =&gt; uint256[]) internal marketRabbits;&#13;
     &#13;
     &#13;
    uint256 middlePriceMoney = 1; &#13;
    uint256 middleSaleTime = 0;  &#13;
    uint moneyRange;&#13;
 &#13;
    function setMoneyRange(uint _money) public onlyOwner {&#13;
        moneyRange = _money;&#13;
    }&#13;
     &#13;
    // the last cost of a sold seal&#13;
    uint lastmoney = 0;  &#13;
    // the time which was spent on the sale of the cat&#13;
    uint lastTimeGen0;&#13;
&#13;
    //how many closed auctions&#13;
    uint public totalClosedBID = 0;&#13;
    mapping (uint32 =&gt; uint) bunnyCost; &#13;
    mapping(uint32 =&gt; uint) bidsIndex;&#13;
 &#13;
&#13;
    /**&#13;
    * @dev get rabbit price&#13;
    */&#13;
    function currentPrice(uint32 _bunnyid) public view returns(uint) {&#13;
&#13;
        uint money = bunnyCost[_bunnyid];&#13;
        if (money &gt; 0) {&#13;
            uint moneyComs = money.div(100);&#13;
            moneyComs = moneyComs.mul(5);&#13;
            return money.add(moneyComs);&#13;
        }&#13;
    }&#13;
    /**&#13;
    * @dev We are selling rabbit for sale&#13;
    * @param _bunnyid - whose rabbit we exhibit &#13;
    * @param _money - sale amount &#13;
    */&#13;
  function startMarket(uint32 _bunnyid, uint _money) public returns (uint) {&#13;
        require(isPauseSave());&#13;
        require(_money &gt;= bigPrice);&#13;
        require(rabbitToOwner[_bunnyid] ==  msg.sender);&#13;
        bunnyCost[_bunnyid] = _money;&#13;
        emit StartMarket(_bunnyid, _money);&#13;
        return marketCount++;&#13;
    }&#13;
&#13;
&#13;
    /**&#13;
    * @dev remove from sale rabbit&#13;
    * @param _bunnyid - a rabbit that is removed from sale &#13;
    */&#13;
    function stopMarket(uint32 _bunnyid) public returns(uint) {&#13;
        require(isPauseSave());&#13;
        require(rabbitToOwner[_bunnyid] == msg.sender);  &#13;
        bunnyCost[_bunnyid] = 0;&#13;
        emit StopMarket(_bunnyid);&#13;
        return marketCount--;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Acquisition of a rabbit from another user&#13;
    * @param _bunnyid  Bunny&#13;
     */&#13;
    function buyBunny(uint32 _bunnyid) public payable {&#13;
        require(isPauseSave());&#13;
        require(rabbitToOwner[_bunnyid] != msg.sender);&#13;
        uint price = currentPrice(_bunnyid);&#13;
&#13;
        require(msg.value &gt;= price &amp;&amp; 0 != price);&#13;
        // stop trading on the current rabbit&#13;
        totalClosedBID++;&#13;
        // Sending money to the old user&#13;
        sendMoney(rabbitToOwner[_bunnyid], msg.value);&#13;
        // is sent to the new owner of the bought rabbit&#13;
        transferFrom(rabbitToOwner[_bunnyid], msg.sender, _bunnyid); &#13;
        stopMarket(_bunnyid); &#13;
&#13;
        emit BunnyBuy(_bunnyid, price);&#13;
        emit SendBunny (msg.sender, _bunnyid);&#13;
    } &#13;
&#13;
    /**&#13;
    * @dev give a rabbit to a specific user&#13;
    * @param add new address owner rabbits&#13;
    */&#13;
    function giff(uint32 bunnyid, address add) public {&#13;
        require(rabbitToOwner[bunnyid] == msg.sender);&#13;
        // a rabbit taken for free can not be given&#13;
        require(!(giffblock[bunnyid]));&#13;
        transferFrom(msg.sender, add, bunnyid);&#13;
    }&#13;
&#13;
    function getMarketCount() public view returns(uint) {&#13;
        return marketCount;&#13;
    }&#13;
}&#13;
&#13;
&#13;
/**&#13;
* Basic actions for the transfer of rights of rabbits&#13;
*/&#13;
contract BunnyGame is RabbitMarket {    &#13;
  &#13;
    function transferNewBunny(address _to, uint32 _bunnyid, uint localdnk, uint breed, uint32 matron, uint32 sire) internal {&#13;
        emit NewBunny(_bunnyid, localdnk, block.number, breed);&#13;
        emit CreateChildren(matron, sire, _bunnyid);&#13;
        addTokenList(_to, _bunnyid);&#13;
        totalSalaryBunny[_bunnyid] = 0;&#13;
        motherCount[_bunnyid] = 0;&#13;
        totalBunny++;&#13;
    }&#13;
&#13;
    /***&#13;
    * @dev create a new gene and put it up for sale, this operation takes place on the server&#13;
    */&#13;
    function createGennezise(uint32 _matron) public {&#13;
         &#13;
        bool promo = false;&#13;
        require(isPriv());&#13;
        require(isPauseSave());&#13;
        require(isPromoPause());&#13;
 &#13;
        if (totalGen0 &gt; promoGen0) { &#13;
            require(msg.sender == ownerServer || msg.sender == ownerCEO);&#13;
        } else if (!(msg.sender == ownerServer || msg.sender == ownerCEO)) {&#13;
            // promo action&#13;
                require(!ownerGennezise[msg.sender]);&#13;
                ownerGennezise[msg.sender] = true;&#13;
                promo = true;&#13;
        }&#13;
        &#13;
        uint  localdnk = privateContract.getNewRabbit(msg.sender);&#13;
        Rabbit memory _Rabbit =  Rabbit( 0, 0, block.number, 0, 0, 0, 0);&#13;
        uint32 _bunnyid =  uint32(rabbits.push(_Rabbit));&#13;
        mapDNK[_bunnyid] = localdnk;&#13;
       &#13;
        transferNewBunny(msg.sender, _bunnyid, localdnk, 0, 0, 0);  &#13;
        &#13;
        lastTimeGen0 = now;&#13;
        lastIdGen0 = _bunnyid; &#13;
        totalGen0++; &#13;
&#13;
        setRabbitMother(_bunnyid, _matron);&#13;
&#13;
        if (promo) {&#13;
            giffblock[_bunnyid] = true;&#13;
        }&#13;
    }&#13;
&#13;
    function getGenomeChildren(uint32 _matron, uint32 _sire) internal view returns(uint) {&#13;
        uint genome;&#13;
        if (rabbits[(_matron-1)].genome &gt;= rabbits[(_sire-1)].genome) {&#13;
            genome = rabbits[(_matron-1)].genome;&#13;
        } else {&#13;
            genome = rabbits[(_sire-1)].genome;&#13;
        }&#13;
        return genome.add(1);&#13;
    }&#13;
    &#13;
    /**&#13;
    * create a new rabbit, according to the cooldown&#13;
    * @param _matron - mother who takes into account the cooldown&#13;
    * @param _sire - the father who is rewarded for mating for the fusion of genes&#13;
     */&#13;
    function createChildren(uint32 _matron, uint32 _sire) public  payable returns(uint32) {&#13;
&#13;
        require(isPriv());&#13;
        require(isPauseSave());&#13;
        require(rabbitToOwner[_matron] == msg.sender);&#13;
        // Checking for the role&#13;
        require(rabbits[(_sire-1)].role == 1);&#13;
        require(_matron != _sire);&#13;
&#13;
        require(getBreed(_matron));&#13;
        // Checking the money &#13;
        &#13;
        require(msg.value &gt;= getSirePrice(_sire));&#13;
        &#13;
        uint genome = getGenomeChildren(_matron, _sire);&#13;
&#13;
        uint localdnk =  privateContract.mixDNK(mapDNK[_matron], mapDNK[_sire], genome);&#13;
        Rabbit memory rabbit =  Rabbit(_matron, _sire, block.number, 0, 0, 0, genome);&#13;
&#13;
        uint32 bunnyid =  uint32(rabbits.push(rabbit));&#13;
        mapDNK[bunnyid] = localdnk;&#13;
&#13;
&#13;
        uint _moneyMother = rabbitSirePrice[_sire].div(4);&#13;
&#13;
        _transferMoneyMother(_matron, _moneyMother);&#13;
&#13;
        rabbitToOwner[_sire].transfer(rabbitSirePrice[_sire]);&#13;
&#13;
        uint system = rabbitSirePrice[_sire].div(100);&#13;
        system = system.mul(commission_system);&#13;
        ownerMoney.transfer(system); // refund previous bidder&#13;
  &#13;
        coolduwnUP(_matron);&#13;
        // we transfer the rabbit to the new owner&#13;
        transferNewBunny(rabbitToOwner[_matron], bunnyid, localdnk, genome, _matron, _sire);   &#13;
        // we establish parents for the child&#13;
        setRabbitMother(bunnyid, _matron);&#13;
        return bunnyid;&#13;
    } &#13;
  &#13;
    /**&#13;
     *  Set the cooldown for childbirth&#13;
     * @param _mother - mother for which cooldown&#13;
     */&#13;
    function coolduwnUP(uint32 _mother) internal { &#13;
        require(isPauseSave());&#13;
        rabbits[(_mother-1)].birthCount = rabbits[(_mother-1)].birthCount.add(1);&#13;
        rabbits[(_mother-1)].birthLastTime = now;&#13;
        emit CoolduwnMother(_mother, rabbits[(_mother-1)].birthCount);&#13;
    }&#13;
&#13;
&#13;
    /**&#13;
     * @param _mother - matron send money for parrent&#13;
     * @param _valueMoney - current sale&#13;
     */&#13;
    function _transferMoneyMother(uint32 _mother, uint _valueMoney) internal {&#13;
        require(isPauseSave());&#13;
        require(_valueMoney &gt; 0);&#13;
        if (getRabbitMotherSumm(_mother) &gt; 0) {&#13;
            uint pastMoney = _valueMoney/getRabbitMotherSumm(_mother);&#13;
            for (uint i=0; i &lt; getRabbitMotherSumm(_mother); i++) {&#13;
                if (rabbitMother[_mother][i] != 0) { &#13;
                    uint32 _parrentMother = rabbitMother[_mother][i];&#13;
                    address add = rabbitToOwner[_parrentMother];&#13;
                    // pay salaries&#13;
                    setMotherCount(_parrentMother);&#13;
                    totalSalaryBunny[_parrentMother] += pastMoney;&#13;
&#13;
                    emit SalaryBunny(_parrentMother, totalSalaryBunny[_parrentMother]);&#13;
&#13;
                    add.transfer(pastMoney); // refund previous bidder&#13;
                }&#13;
            } &#13;
        }&#13;
    }&#13;
    &#13;
    /**&#13;
    * @dev We set the cost of renting our genes&#13;
    * @param price rent price&#13;
     */&#13;
    function setRabbitSirePrice(uint32 _rabbitid, uint price) public returns(bool) {&#13;
        require(isPauseSave());&#13;
        require(rabbitToOwner[_rabbitid] == msg.sender);&#13;
        require(price &gt; bigPrice);&#13;
&#13;
        uint lastTime;&#13;
        (lastTime,,) = getcoolduwn(_rabbitid);&#13;
        require(now &gt;= lastTime);&#13;
&#13;
        if (rabbits[(_rabbitid-1)].role == 1 &amp;&amp; rabbitSirePrice[_rabbitid] == price) {&#13;
            return false;&#13;
        }&#13;
&#13;
        rabbits[(_rabbitid-1)].role = 1;&#13;
        rabbitSirePrice[_rabbitid] = price;&#13;
        uint gen = rabbits[(_rabbitid-1)].genome;&#13;
        sireGenom[gen].push(_rabbitid);&#13;
        emit ChengeSex(_rabbitid, true, getSirePrice(_rabbitid));&#13;
        return true;&#13;
    }&#13;
 &#13;
    /**&#13;
    * @dev We set the cost of renting our genes&#13;
     */&#13;
    function setSireStop(uint32 _rabbitid) public returns(bool) {&#13;
        require(isPauseSave());&#13;
        require(rabbitToOwner[_rabbitid] == msg.sender);&#13;
     //   require(rabbits[(_rabbitid-1)].role == 0);&#13;
&#13;
        rabbits[(_rabbitid-1)].role = 0;&#13;
        rabbitSirePrice[_rabbitid] = 0;&#13;
        deleteSire(_rabbitid);&#13;
        return true;&#13;
    }&#13;
    &#13;
      function deleteSire(uint32 _tokenId) internal { &#13;
        uint gen = rabbits[(_tokenId-1)].genome;&#13;
&#13;
        uint count = sireGenom[gen].length;&#13;
        for (uint i = 0; i &lt; count; i++) {&#13;
            if(sireGenom[gen][i] == _tokenId)&#13;
            { &#13;
                delete sireGenom[gen][i];&#13;
                if(count &gt; 0 &amp;&amp; count != (i-1)){&#13;
                    sireGenom[gen][i] = sireGenom[gen][(count-1)];&#13;
                    delete sireGenom[gen][(count-1)];&#13;
                } &#13;
                sireGenom[gen].length--;&#13;
                emit ChengeSex(_tokenId, false, 0);&#13;
                return;&#13;
            } &#13;
        }&#13;
    } &#13;
&#13;
    function getMoney(uint _value) public onlyOwner {&#13;
        require(address(this).balance &gt;= _value);&#13;
        ownerMoney.transfer(_value);&#13;
    }&#13;
}
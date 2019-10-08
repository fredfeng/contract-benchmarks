pragma solidity ^0.4.18;
// ----------------------------------------------------------------------------
// rev rbs eryk 180325
// 'IGR' 'InGRedient Token with Fixed Supply Token'  contract
//
// Symbol      : IGR
// Name        : InGRedient Token -based on ER20 wiki- Example Fixed Supply Token
// Total supply: 1,000,000.000000000000000000
// Decimals    : 3
//
// (c) Erick & <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="94c6fdf7f5e6f0fbbad6fbe6f3f1e7d4e1f2f5f6f7baf1f0e1baf6e6">[email protected]</a>&#13;
// ----------------------------------------------------------------------------&#13;
&#13;
&#13;
// ----------------------------------------------------------------------------&#13;
// Safe math&#13;
// ----------------------------------------------------------------------------&#13;
library SafeMath {&#13;
    function add(uint a, uint b) internal pure returns (uint c) {&#13;
    c = a + b;&#13;
    require(c &gt;= a);&#13;
    }&#13;
    function sub(uint a, uint b) internal pure returns (uint c) {&#13;
    require(b &lt;= a);&#13;
    c = a - b;&#13;
    }&#13;
    function mul(uint a, uint b) internal pure returns (uint c) {&#13;
    c = a * b;&#13;
    require(a == 0 || c / a == b);&#13;
    }&#13;
    function div(uint a, uint b) internal pure returns (uint c) {&#13;
    require(b &gt; 0);&#13;
    c = a / b;&#13;
    }&#13;
}&#13;
&#13;
&#13;
// ----------------------------------------------------------------------------&#13;
// ERC Token Standard #20 Interface&#13;
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md&#13;
// ----------------------------------------------------------------------------&#13;
contract ERC20Interface {&#13;
function totalSupply() public constant returns (uint);&#13;
function balanceOf(address tokenOwner) public constant returns (uint balance);&#13;
function allowance(address tokenOwner, address spender) public constant returns (uint remaining);&#13;
function transfer(address to, uint tokens) public returns (bool success);&#13;
function approve(address spender, uint tokens) public returns (bool success);&#13;
function transferFrom(address from, address to, uint tokens) public returns (bool success);&#13;
&#13;
event Transfer(address indexed from, address indexed to, uint tokens);&#13;
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);&#13;
}&#13;
&#13;
&#13;
// ----------------------------------------------------------------------------&#13;
// Contract function to receive approval and execute function in one call&#13;
// Borrowed from MiniMeToken- &#13;
// ----------------------------------------------------------------------------&#13;
contract ApproveAndCallFallBack {&#13;
function receiveApproval(address from, uint256 tokens, address token, bytes data) public;&#13;
}&#13;
&#13;
// ----------------------------------------------------------------------------&#13;
// Owned contract&#13;
// ----------------------------------------------------------------------------&#13;
contract Owned {&#13;
address public owner;&#13;
address public newOwner;&#13;
&#13;
event OwnershipTransferred(address indexed _from, address indexed _to);&#13;
&#13;
function Owned() public {&#13;
owner = msg.sender;&#13;
}&#13;
&#13;
modifier onlyOwner {&#13;
require(msg.sender == owner);&#13;
_;&#13;
}&#13;
&#13;
function transferOwnership(address _newOwner) public onlyOwner {&#13;
newOwner = _newOwner;&#13;
}&#13;
&#13;
function acceptOwnership() public {&#13;
    require(msg.sender == newOwner);&#13;
    OwnershipTransferred(owner, newOwner);&#13;
    owner = newOwner;&#13;
    newOwner = address(0);&#13;
    }&#13;
}&#13;
&#13;
&#13;
// ----------------------------------------------------------------------------&#13;
// ERC20 Token, with the addition of symbol, name and decimals and an&#13;
// initial fixed supply&#13;
// ----------------------------------------------------------------------------&#13;
contract InGRedientToken  is ERC20Interface, Owned {&#13;
using SafeMath for uint;&#13;
&#13;
string public symbol;&#13;
string public  name;&#13;
uint8 public decimals;&#13;
uint public _totalSupply;&#13;
&#13;
mapping(address =&gt; uint) balances;&#13;
mapping(address =&gt; mapping(address =&gt; uint)) allowed;&#13;
&#13;
&#13;
// ------------------------------------------------------------------------&#13;
// Constructor&#13;
// ------------------------------------------------------------------------&#13;
function InGRedientToken() public {&#13;
    symbol = "IGR";&#13;
    name = "InGRedientToken";&#13;
    decimals = 3; //kg is the reference unit but grams is often also used&#13;
    _totalSupply = 1000000000000000000000 * 10**uint(decimals);&#13;
    balances[owner] = _totalSupply;&#13;
    Transfer(address(0), owner, _totalSupply);&#13;
}&#13;
&#13;
&#13;
// ------------------------------------------------------------------------&#13;
// Total supply&#13;
// ------------------------------------------------------------------------&#13;
function totalSupply() public constant returns (uint) {&#13;
    return _totalSupply  - balances[address(0)];&#13;
}&#13;
&#13;
&#13;
// ------------------------------------------------------------------------&#13;
// Get the token balance for account `tokenOwner`&#13;
// ------------------------------------------------------------------------&#13;
function balanceOf(address tokenOwner) public constant returns (uint balance) {&#13;
    return balances[tokenOwner];&#13;
}&#13;
&#13;
// ------------------------------------------------------------------------&#13;
// Token owner can approve for `spender` to transferFrom(...) `tokens`&#13;
// from the token owner's account&#13;
//&#13;
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md&#13;
// recommends that there are no checks for the approval double-spend attack&#13;
// as this should be implemented in user interfaces&#13;
// ------------------------------------------------------------------------&#13;
function approve(address spender, uint tokens) public returns (bool success) {&#13;
    allowed[msg.sender][spender] = tokens;&#13;
    Approval(msg.sender, spender, tokens);&#13;
    return true;&#13;
}&#13;
&#13;
// ------------------------------------------------------------------------&#13;
// Transfer the balance from token owner's account to `to` account&#13;
// - Owner's account must have sufficient balance to transfer&#13;
// - 0 value transfers are allowed&#13;
// ------------------------------------------------------------------------&#13;
function transfer(address to, uint tokens) public returns (bool success) {&#13;
    balances[msg.sender] = balances[msg.sender].sub(tokens);&#13;
    balances[to] = balances[to].add(tokens);&#13;
    Transfer(msg.sender, to, tokens);&#13;
    return true;&#13;
}&#13;
&#13;
// ------------------------------------------------------------------------&#13;
// Transfer `tokens` from the `from` account to the `to` account&#13;
//&#13;
// The calling account must already have sufficient tokens approve(...)-d&#13;
// for spending from the `from` account and&#13;
// - From account must have sufficient balance to transfer&#13;
// - Spender must have sufficient allowance to transfer&#13;
// - 0 value transfers are allowed&#13;
// ------------------------------------------------------------------------&#13;
function transferFrom(address from, address to, uint tokens) public returns (bool success) {&#13;
balances[from] = balances[from].sub(tokens);&#13;
allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);&#13;
balances[to] = balances[to].add(tokens);&#13;
Transfer(from, to, tokens);&#13;
return true;&#13;
}&#13;
&#13;
&#13;
// ------------------------------------------------------------------------&#13;
// Returns the amount of tokens approved by the owner that can be&#13;
// transferred to the spender's account&#13;
// ------------------------------------------------------------------------&#13;
function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {&#13;
return allowed[tokenOwner][spender];&#13;
}&#13;
&#13;
&#13;
// ------------------------------------------------------------------------&#13;
// Token owner can approve for `spender` to transferFrom(...) `tokens`&#13;
// from the token owner's account. The `spender` contract function&#13;
// `receiveApproval(...)` is then executed&#13;
// ------------------------------------------------------------------------&#13;
function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {&#13;
allowed[msg.sender][spender] = tokens;&#13;
Approval(msg.sender, spender, tokens);&#13;
ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);&#13;
return true;&#13;
}&#13;
&#13;
// ------------------------------------------------------------------------&#13;
// Don't accept ETH&#13;
// ------------------------------------------------------------------------&#13;
function () public payable {&#13;
revert();&#13;
}&#13;
&#13;
&#13;
// ------------------------------------------------------------------------&#13;
// Owner can transfer out any accidentally sent ERC20 tokens&#13;
// ------------------------------------------------------------------------&#13;
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {&#13;
    return ERC20Interface(tokenAddress).transfer(owner, tokens);&#13;
    }&#13;
&#13;
&#13;
&#13;
// ==================================================================&#13;
// IGR token specific functions &#13;
//===================================================================&#13;
&#13;
event  FarmerRequestedCertificate(address owner, address certAuth, uint tokens);&#13;
&#13;
// --------------------------------------------------------------------------------------------------&#13;
// routine 10- allows for sale of ingredients along with the respective IGR token transfer ( with url)&#13;
//implementação básica da rotina 10  do farmer requests Certicate&#13;
// --------------------------------------------------------------------------------------------------&#13;
function farmerRequestCertificate(address _certAuth, uint _tokens, string _product,string _IngValueProperty, string _localGPSProduction, uint _dateProduction ) public returns (bool success) {&#13;
// falta implementar uma verif se o end certAuth foi cadastradao anteriormente&#13;
    allowed[owner][_certAuth] = _tokens;&#13;
    Approval(owner, _certAuth, _tokens);&#13;
    FarmerRequestedCertificate(owner, _certAuth, _tokens);&#13;
    return true;&#13;
}&#13;
&#13;
// --------------------------------------------------------------------------------------------------&#13;
// routine 20-  certAuthIssuesCerticate  certification auth confirms that ingredients are trustworthy &#13;
// as well as qtty , location , published url ,  string product)&#13;
// --------------------------------------------------------------------------------------------------&#13;
function certAuthIssuesCerticate(address owner, address farmer, uint tokens, string _url,string product,string IngValueProperty, string localGPSProduction, uint dateProduction ) public returns (bool success) {&#13;
    balances[owner] = balances[owner].sub(tokens);&#13;
    //allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(tokens);&#13;
    allowed[owner][msg.sender] = 0;&#13;
    balances[farmer] = balances[farmer].add(tokens);&#13;
    Transfer(owner, farmer, tokens);&#13;
    return true;&#13;
    }&#13;
&#13;
// --------------------------------------------------------------------------------------------------&#13;
// routine 30- allows for sale of ingredients along with the respective IGR token transfer ( with url)&#13;
// --------------------------------------------------------------------------------------------------&#13;
function sellsIngrWithoutDepletion(address to, uint tokens,string _url) public returns (bool success) {&#13;
    string memory url=_url; // keep the url of the InGRedient for later transfer&#13;
    balances[msg.sender] = balances[msg.sender].sub(tokens);&#13;
    balances[to] = balances[to].add(tokens);&#13;
    Transfer(msg.sender, to, tokens);&#13;
    return true;&#13;
    }&#13;
&#13;
// ------------------------------------------------------------------------&#13;
// routine 40- allows for sale of intermediate product made from certified ingredients along with&#13;
// the respective IGR token transfer ( with url)&#13;
// i.e.: allows only the pro-rata quantity of semi-processed  InGRedient &#13;
// tokens to be transfered to the consumer level package(SKU) &#13;
// ------------------------------------------------------------------------&#13;
function sellsIntermediateGoodWithDepletion(address to, uint tokens,string _url,uint out2inIngredientPercentage ) public returns (bool success) {&#13;
    string memory url=_url; // keep the url of hte InGRedient for later transfer&#13;
    //allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(tokens);// falta matar a parte depleted ....depois fazemos&#13;
    require (out2inIngredientPercentage &lt;= 100); // verificar possivel erro se este valor for negativo ou maior que 100(%)&#13;
    transfer(to, tokens*out2inIngredientPercentage/100);&#13;
    return true;&#13;
}&#13;
&#13;
&#13;
function genAddressFromGTIN13date(string _GTIN13,string _YYMMDD) constant returns(address c){&#13;
    bytes32 a= keccak256(_GTIN13,_YYMMDD);&#13;
    address b = address(a);&#13;
    return b;&#13;
    }&#13;
&#13;
// ------------------------------------------------------------------------&#13;
//  transferAndWriteUrl- Transfer the balance from token owner's account to `to` account&#13;
// - Owner's account must have sufficient balance to transfer&#13;
// - 0 value transfers are allowed&#13;
// since the -url is passed to the function we achieve that this data be written to the block..nothing else needed&#13;
// ------------------------------------------------------------------------&#13;
function transferAndWriteUrl(address to, uint tokens, string _url) public returns (bool success) {&#13;
    balances[msg.sender] = balances[msg.sender].sub(tokens);&#13;
    balances[to] = balances[to].add(tokens);&#13;
    Transfer(msg.sender, to, tokens);&#13;
    return true;&#13;
    }&#13;
&#13;
// ------------------------------------------------------------------------&#13;
// routine 50- comminglerSellsProductSKUWithProRataIngred(address _to, int numPSKUsSold, ,string _url, uint _qttyIGRinLLSKU, string GTIN13, string YYMMDD ) &#13;
//allows for sale of final-consumer  product with resp SKU and Lot identification with corresponding IGR transfer&#13;
// the respective IGR token transfer ( with url)&#13;
// i.e.: allows only the pro-rata quantity of semi-processed  InGRedient &#13;
// tokens to be transfered to the consumer level package(SKU) &#13;
// ------------------------------------------------------------------------&#13;
function comminglerSellsProductSKUWithProRataIngred(address _to, uint _numSKUsSold,string _url,uint _qttyIGRinLLSKU, string _GTIN13, string _YYMMDD ) public returns (bool success) {&#13;
        string memory url=_url; // keep the url of hte InGRedient for later transfer&#13;
        address c= genAddressFromGTIN13date( _GTIN13, _YYMMDD);//writes to the blockchain address composed of GTIN-13+YYMMDD the qtty IGR in one SKU&#13;
        transferAndWriteUrl(c, _qttyIGRinLLSKU, _url);&#13;
        require (_qttyIGRinLLSKU &gt;0); // qtty of Ingredient may not be negative nor zero &#13;
        transferAndWriteUrl(_to, (_numSKUsSold-1)*_qttyIGRinLLSKU,_url);// records the transfer of custody of the qtty of SKU each with qttyIGRinLLSKU&#13;
        return true;&#13;
    }&#13;
&#13;
    &#13;
}
pragma solidity 0.4.15;


/// @title Math library - Allows calculation of logarithmic and exponential functions
/// @author Alan Lu - <<span class="__cf_email__" data-cfemail="4f2e232e2161233a0f2821203c263c613f22">[email protected]</span>&gt;&#13;
/// @author Stefan George - &lt;<span class="__cf_email__" data-cfemail="2754534241464967404948544e5409574a">[email protected]</span>&gt;&#13;
library Math {&#13;
&#13;
    /*&#13;
     *  Constants&#13;
     */&#13;
    // This is equal to 1 in our calculations&#13;
    uint public constant ONE =  0x10000000000000000;&#13;
    uint public constant LN2 = 0xb17217f7d1cf79ac;&#13;
    uint public constant LOG2_E = 0x171547652b82fe177;&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    /// @dev Returns natural exponential function value of given x&#13;
    /// @param x x&#13;
    /// @return e**x&#13;
    function exp(int x)&#13;
        public&#13;
        constant&#13;
        returns (uint)&#13;
    {&#13;
        // revert if x is &gt; MAX_POWER, where&#13;
        // MAX_POWER = int(mp.floor(mp.log(mpf(2**256 - 1) / ONE) * ONE))&#13;
        require(x &lt;= 2454971259878909886679);&#13;
        // return 0 if exp(x) is tiny, using&#13;
        // MIN_POWER = int(mp.floor(mp.log(mpf(1) / ONE) * ONE))&#13;
        if (x &lt; -818323753292969962227)&#13;
            return 0;&#13;
        // Transform so that e^x -&gt; 2^x&#13;
        x = x * int(ONE) / int(LN2);&#13;
        // 2^x = 2^whole(x) * 2^frac(x)&#13;
        //       ^^^^^^^^^^ is a bit shift&#13;
        // so Taylor expand on z = frac(x)&#13;
        int shift;&#13;
        uint z;&#13;
        if (x &gt;= 0) {&#13;
            shift = x / int(ONE);&#13;
            z = uint(x % int(ONE));&#13;
        }&#13;
        else {&#13;
            shift = x / int(ONE) - 1;&#13;
            z = ONE - uint(-x % int(ONE));&#13;
        }&#13;
        // 2^x = 1 + (ln 2) x + (ln 2)^2/2! x^2 + ...&#13;
        //&#13;
        // Can generate the z coefficients using mpmath and the following lines&#13;
        // &gt;&gt;&gt; from mpmath import mp&#13;
        // &gt;&gt;&gt; mp.dps = 100&#13;
        // &gt;&gt;&gt; ONE =  0x10000000000000000&#13;
        // &gt;&gt;&gt; print('\n'.join(hex(int(mp.log(2)**i / mp.factorial(i) * ONE)) for i in range(1, 7)))&#13;
        // 0xb17217f7d1cf79ab&#13;
        // 0x3d7f7bff058b1d50&#13;
        // 0xe35846b82505fc5&#13;
        // 0x276556df749cee5&#13;
        // 0x5761ff9e299cc4&#13;
        // 0xa184897c363c3&#13;
        uint zpow = z;&#13;
        uint result = ONE;&#13;
        result += 0xb17217f7d1cf79ab * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0x3d7f7bff058b1d50 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0xe35846b82505fc5 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0x276556df749cee5 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0x5761ff9e299cc4 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0xa184897c363c3 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0xffe5fe2c4586 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0x162c0223a5c8 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0x1b5253d395e * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0x1e4cf5158b * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0x1e8cac735 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0x1c3bd650 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0x1816193 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0x131496 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0xe1b7 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0x9c7 * zpow / ONE;&#13;
        if (shift &gt;= 0) {&#13;
            if (result &gt;&gt; (256-shift) &gt; 0)&#13;
                return (2**256-1);&#13;
            return result &lt;&lt; shift;&#13;
        }&#13;
        else&#13;
            return result &gt;&gt; (-shift);&#13;
    }&#13;
&#13;
    /// @dev Returns natural logarithm value of given x&#13;
    /// @param x x&#13;
    /// @return ln(x)&#13;
    function ln(uint x)&#13;
        public&#13;
        constant&#13;
        returns (int)&#13;
    {&#13;
        require(x &gt; 0);&#13;
        // binary search for floor(log2(x))&#13;
        int ilog2 = floorLog2(x);&#13;
        int z;&#13;
        if (ilog2 &lt; 0)&#13;
            z = int(x &lt;&lt; uint(-ilog2));&#13;
        else&#13;
            z = int(x &gt;&gt; uint(ilog2));&#13;
        // z = x * 2^-⌊log₂x⌋&#13;
        // so 1 &lt;= z &lt; 2&#13;
        // and ln z = ln x - ⌊log₂x⌋/log₂e&#13;
        // so just compute ln z using artanh series&#13;
        // and calculate ln x from that&#13;
        int term = (z - int(ONE)) * int(ONE) / (z + int(ONE));&#13;
        int halflnz = term;&#13;
        int termpow = term * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 3;&#13;
        termpow = termpow * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 5;&#13;
        termpow = termpow * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 7;&#13;
        termpow = termpow * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 9;&#13;
        termpow = termpow * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 11;&#13;
        termpow = termpow * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 13;&#13;
        termpow = termpow * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 15;&#13;
        termpow = termpow * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 17;&#13;
        termpow = termpow * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 19;&#13;
        termpow = termpow * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 21;&#13;
        termpow = termpow * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 23;&#13;
        termpow = termpow * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 25;&#13;
        return (ilog2 * int(ONE)) * int(ONE) / int(LOG2_E) + 2 * halflnz;&#13;
    }&#13;
&#13;
    /// @dev Returns base 2 logarithm value of given x&#13;
    /// @param x x&#13;
    /// @return logarithmic value&#13;
    function floorLog2(uint x)&#13;
        public&#13;
        constant&#13;
        returns (int lo)&#13;
    {&#13;
        lo = -64;&#13;
        int hi = 193;&#13;
        // I use a shift here instead of / 2 because it floors instead of rounding towards 0&#13;
        int mid = (hi + lo) &gt;&gt; 1;&#13;
        while((lo + 1) &lt; hi) {&#13;
            if (mid &lt; 0 &amp;&amp; x &lt;&lt; uint(-mid) &lt; ONE || mid &gt;= 0 &amp;&amp; x &gt;&gt; uint(mid) &lt; ONE)&#13;
                hi = mid;&#13;
            else&#13;
                lo = mid;&#13;
            mid = (hi + lo) &gt;&gt; 1;&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Returns maximum of an array&#13;
    /// @param nums Numbers to look through&#13;
    /// @return Maximum number&#13;
    function max(int[] nums)&#13;
        public&#13;
        constant&#13;
        returns (int max)&#13;
    {&#13;
        require(nums.length &gt; 0);&#13;
        max = -2**255;&#13;
        for (uint i = 0; i &lt; nums.length; i++)&#13;
            if (nums[i] &gt; max)&#13;
                max = nums[i];&#13;
    }&#13;
&#13;
    /// @dev Returns whether an add operation causes an overflow&#13;
    /// @param a First addend&#13;
    /// @param b Second addend&#13;
    /// @return Did no overflow occur?&#13;
    function safeToAdd(uint a, uint b)&#13;
        public&#13;
        constant&#13;
        returns (bool)&#13;
    {&#13;
        return a + b &gt;= a;&#13;
    }&#13;
&#13;
    /// @dev Returns whether a subtraction operation causes an underflow&#13;
    /// @param a Minuend&#13;
    /// @param b Subtrahend&#13;
    /// @return Did no underflow occur?&#13;
    function safeToSub(uint a, uint b)&#13;
        public&#13;
        constant&#13;
        returns (bool)&#13;
    {&#13;
        return a &gt;= b;&#13;
    }&#13;
&#13;
    /// @dev Returns whether a multiply operation causes an overflow&#13;
    /// @param a First factor&#13;
    /// @param b Second factor&#13;
    /// @return Did no overflow occur?&#13;
    function safeToMul(uint a, uint b)&#13;
        public&#13;
        constant&#13;
        returns (bool)&#13;
    {&#13;
        return b == 0 || a * b / b == a;&#13;
    }&#13;
&#13;
    /// @dev Returns sum if no overflow occurred&#13;
    /// @param a First addend&#13;
    /// @param b Second addend&#13;
    /// @return Sum&#13;
    function add(uint a, uint b)&#13;
        public&#13;
        constant&#13;
        returns (uint)&#13;
    {&#13;
        require(safeToAdd(a, b));&#13;
        return a + b;&#13;
    }&#13;
&#13;
    /// @dev Returns difference if no overflow occurred&#13;
    /// @param a Minuend&#13;
    /// @param b Subtrahend&#13;
    /// @return Difference&#13;
    function sub(uint a, uint b)&#13;
        public&#13;
        constant&#13;
        returns (uint)&#13;
    {&#13;
        require(safeToSub(a, b));&#13;
        return a - b;&#13;
    }&#13;
&#13;
    /// @dev Returns product if no overflow occurred&#13;
    /// @param a First factor&#13;
    /// @param b Second factor&#13;
    /// @return Product&#13;
    function mul(uint a, uint b)&#13;
        public&#13;
        constant&#13;
        returns (uint)&#13;
    {&#13;
        require(safeToMul(a, b));&#13;
        return a * b;&#13;
    }&#13;
&#13;
    /// @dev Returns whether an add operation causes an overflow&#13;
    /// @param a First addend&#13;
    /// @param b Second addend&#13;
    /// @return Did no overflow occur?&#13;
    function safeToAdd(int a, int b)&#13;
        public&#13;
        constant&#13;
        returns (bool)&#13;
    {&#13;
        return (b &gt;= 0 &amp;&amp; a + b &gt;= a) || (b &lt; 0 &amp;&amp; a + b &lt; a);&#13;
    }&#13;
&#13;
    /// @dev Returns whether a subtraction operation causes an underflow&#13;
    /// @param a Minuend&#13;
    /// @param b Subtrahend&#13;
    /// @return Did no underflow occur?&#13;
    function safeToSub(int a, int b)&#13;
        public&#13;
        constant&#13;
        returns (bool)&#13;
    {&#13;
        return (b &gt;= 0 &amp;&amp; a - b &lt;= a) || (b &lt; 0 &amp;&amp; a - b &gt; a);&#13;
    }&#13;
&#13;
    /// @dev Returns whether a multiply operation causes an overflow&#13;
    /// @param a First factor&#13;
    /// @param b Second factor&#13;
    /// @return Did no overflow occur?&#13;
    function safeToMul(int a, int b)&#13;
        public&#13;
        constant&#13;
        returns (bool)&#13;
    {&#13;
        return (b == 0) || (a * b / b == a);&#13;
    }&#13;
&#13;
    /// @dev Returns sum if no overflow occurred&#13;
    /// @param a First addend&#13;
    /// @param b Second addend&#13;
    /// @return Sum&#13;
    function add(int a, int b)&#13;
        public&#13;
        constant&#13;
        returns (int)&#13;
    {&#13;
        require(safeToAdd(a, b));&#13;
        return a + b;&#13;
    }&#13;
&#13;
    /// @dev Returns difference if no overflow occurred&#13;
    /// @param a Minuend&#13;
    /// @param b Subtrahend&#13;
    /// @return Difference&#13;
    function sub(int a, int b)&#13;
        public&#13;
        constant&#13;
        returns (int)&#13;
    {&#13;
        require(safeToSub(a, b));&#13;
        return a - b;&#13;
    }&#13;
&#13;
    /// @dev Returns product if no overflow occurred&#13;
    /// @param a First factor&#13;
    /// @param b Second factor&#13;
    /// @return Product&#13;
    function mul(int a, int b)&#13;
        public&#13;
        constant&#13;
        returns (int)&#13;
    {&#13;
        require(safeToMul(a, b));&#13;
        return a * b;&#13;
    }&#13;
}&#13;
&#13;
/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md&#13;
&#13;
&#13;
/// @title Abstract token contract - Functions to be implemented by token contracts&#13;
contract Token {&#13;
&#13;
    /*&#13;
     *  Events&#13;
     */&#13;
    event Transfer(address indexed from, address indexed to, uint value);&#13;
    event Approval(address indexed owner, address indexed spender, uint value);&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    function transfer(address to, uint value) public returns (bool);&#13;
    function transferFrom(address from, address to, uint value) public returns (bool);&#13;
    function approve(address spender, uint value) public returns (bool);&#13;
    function balanceOf(address owner) public constant returns (uint);&#13;
    function allowance(address owner, address spender) public constant returns (uint);&#13;
    function totalSupply() public constant returns (uint);&#13;
}&#13;
&#13;
&#13;
&#13;
/// @title Standard token contract with overflow protection&#13;
contract StandardToken is Token {&#13;
    using Math for *;&#13;
&#13;
    /*&#13;
     *  Storage&#13;
     */&#13;
    mapping (address =&gt; uint) balances;&#13;
    mapping (address =&gt; mapping (address =&gt; uint)) allowances;&#13;
    uint totalTokens;&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    /// @dev Transfers sender's tokens to a given address. Returns success&#13;
    /// @param to Address of token receiver&#13;
    /// @param value Number of tokens to transfer&#13;
    /// @return Was transfer successful?&#13;
    function transfer(address to, uint value)&#13;
        public&#13;
        returns (bool)&#13;
    {&#13;
        if (   !balances[msg.sender].safeToSub(value)&#13;
            || !balances[to].safeToAdd(value))&#13;
            return false;&#13;
        balances[msg.sender] -= value;&#13;
        balances[to] += value;&#13;
        Transfer(msg.sender, to, value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success&#13;
    /// @param from Address from where tokens are withdrawn&#13;
    /// @param to Address to where tokens are sent&#13;
    /// @param value Number of tokens to transfer&#13;
    /// @return Was transfer successful?&#13;
    function transferFrom(address from, address to, uint value)&#13;
        public&#13;
        returns (bool)&#13;
    {&#13;
        if (   !balances[from].safeToSub(value)&#13;
            || !allowances[from][msg.sender].safeToSub(value)&#13;
            || !balances[to].safeToAdd(value))&#13;
            return false;&#13;
        balances[from] -= value;&#13;
        allowances[from][msg.sender] -= value;&#13;
        balances[to] += value;&#13;
        Transfer(from, to, value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /// @dev Sets approved amount of tokens for spender. Returns success&#13;
    /// @param spender Address of allowed account&#13;
    /// @param value Number of approved tokens&#13;
    /// @return Was approval successful?&#13;
    function approve(address spender, uint value)&#13;
        public&#13;
        returns (bool)&#13;
    {&#13;
        allowances[msg.sender][spender] = value;&#13;
        Approval(msg.sender, spender, value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /// @dev Returns number of allowed tokens for given address&#13;
    /// @param owner Address of token owner&#13;
    /// @param spender Address of token spender&#13;
    /// @return Remaining allowance for spender&#13;
    function allowance(address owner, address spender)&#13;
        public&#13;
        constant&#13;
        returns (uint)&#13;
    {&#13;
        return allowances[owner][spender];&#13;
    }&#13;
&#13;
    /// @dev Returns number of tokens owned by given address&#13;
    /// @param owner Address of token owner&#13;
    /// @return Balance of owner&#13;
    function balanceOf(address owner)&#13;
        public&#13;
        constant&#13;
        returns (uint)&#13;
    {&#13;
        return balances[owner];&#13;
    }&#13;
&#13;
    /// @dev Returns total supply of tokens&#13;
    /// @return Total supply&#13;
    function totalSupply()&#13;
        public&#13;
        constant&#13;
        returns (uint)&#13;
    {&#13;
        return totalTokens;&#13;
    }&#13;
}&#13;
&#13;
&#13;
/// @title Outcome token contract - Issuing and revoking outcome tokens&#13;
/// @author Stefan George - &lt;<span class="__cf_email__" data-cfemail="c8bbbcadaea9a688afa6a7bba1bbe6b8a5">[email protected]</span>&gt;&#13;
contract OutcomeToken is StandardToken {&#13;
    using Math for *;&#13;
&#13;
    /*&#13;
     *  Events&#13;
     */&#13;
    event Issuance(address indexed owner, uint amount);&#13;
    event Revocation(address indexed owner, uint amount);&#13;
&#13;
    /*&#13;
     *  Storage&#13;
     */&#13;
    address public eventContract;&#13;
&#13;
    /*&#13;
     *  Modifiers&#13;
     */&#13;
    modifier isEventContract () {&#13;
        // Only event contract is allowed to proceed&#13;
        require(msg.sender == eventContract);&#13;
        _;&#13;
    }&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    /// @dev Constructor sets events contract address&#13;
    function OutcomeToken()&#13;
        public&#13;
    {&#13;
        eventContract = msg.sender;&#13;
    }&#13;
    &#13;
    /// @dev Events contract issues new tokens for address. Returns success&#13;
    /// @param _for Address of receiver&#13;
    /// @param outcomeTokenCount Number of tokens to issue&#13;
    function issue(address _for, uint outcomeTokenCount)&#13;
        public&#13;
        isEventContract&#13;
    {&#13;
        balances[_for] = balances[_for].add(outcomeTokenCount);&#13;
        totalTokens = totalTokens.add(outcomeTokenCount);&#13;
        Issuance(_for, outcomeTokenCount);&#13;
    }&#13;
&#13;
    /// @dev Events contract revokes tokens for address. Returns success&#13;
    /// @param _for Address of token holder&#13;
    /// @param outcomeTokenCount Number of tokens to revoke&#13;
    function revoke(address _for, uint outcomeTokenCount)&#13;
        public&#13;
        isEventContract&#13;
    {&#13;
        balances[_for] = balances[_for].sub(outcomeTokenCount);&#13;
        totalTokens = totalTokens.sub(outcomeTokenCount);&#13;
        Revocation(_for, outcomeTokenCount);&#13;
    }&#13;
}&#13;
&#13;
&#13;
&#13;
/// @title Abstract oracle contract - Functions to be implemented by oracles&#13;
contract Oracle {&#13;
&#13;
    function isOutcomeSet() public constant returns (bool);&#13;
    function getOutcome() public constant returns (int);&#13;
}&#13;
&#13;
&#13;
&#13;
/// @title Event contract - Provide basic functionality required by different event types&#13;
/// @author Stefan George - &lt;<span class="__cf_email__" data-cfemail="cbb8bfaeadaaa58baca5a4b8a2b8e5bba6">[email protected]</span>&gt;&#13;
contract Event {&#13;
&#13;
    /*&#13;
     *  Events&#13;
     */&#13;
    event OutcomeTokenCreation(OutcomeToken outcomeToken, uint8 index);&#13;
    event OutcomeTokenSetIssuance(address indexed buyer, uint collateralTokenCount);&#13;
    event OutcomeTokenSetRevocation(address indexed seller, uint outcomeTokenCount);&#13;
    event OutcomeAssignment(int outcome);&#13;
    event WinningsRedemption(address indexed receiver, uint winnings);&#13;
&#13;
    /*&#13;
     *  Storage&#13;
     */&#13;
    Token public collateralToken;&#13;
    Oracle public oracle;&#13;
    bool public isOutcomeSet;&#13;
    int public outcome;&#13;
    OutcomeToken[] public outcomeTokens;&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    /// @dev Contract constructor validates and sets basic event properties&#13;
    /// @param _collateralToken Tokens used as collateral in exchange for outcome tokens&#13;
    /// @param _oracle Oracle contract used to resolve the event&#13;
    /// @param outcomeCount Number of event outcomes&#13;
    function Event(Token _collateralToken, Oracle _oracle, uint8 outcomeCount)&#13;
        public&#13;
    {&#13;
        // Validate input&#13;
        require(address(_collateralToken) != 0 &amp;&amp; address(_oracle) != 0 &amp;&amp; outcomeCount &gt;= 2);&#13;
        collateralToken = _collateralToken;&#13;
        oracle = _oracle;&#13;
        // Create an outcome token for each outcome&#13;
        for (uint8 i = 0; i &lt; outcomeCount; i++) {&#13;
            OutcomeToken outcomeToken = new OutcomeToken();&#13;
            outcomeTokens.push(outcomeToken);&#13;
            OutcomeTokenCreation(outcomeToken, i);&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Buys equal number of tokens of all outcomes, exchanging collateral tokens and sets of outcome tokens 1:1&#13;
    /// @param collateralTokenCount Number of collateral tokens&#13;
    function buyAllOutcomes(uint collateralTokenCount)&#13;
        public&#13;
    {&#13;
        // Transfer collateral tokens to events contract&#13;
        require(collateralToken.transferFrom(msg.sender, this, collateralTokenCount));&#13;
        // Issue new outcome tokens to sender&#13;
        for (uint8 i = 0; i &lt; outcomeTokens.length; i++)&#13;
            outcomeTokens[i].issue(msg.sender, collateralTokenCount);&#13;
        OutcomeTokenSetIssuance(msg.sender, collateralTokenCount);&#13;
    }&#13;
&#13;
    /// @dev Sells equal number of tokens of all outcomes, exchanging collateral tokens and sets of outcome tokens 1:1&#13;
    /// @param outcomeTokenCount Number of outcome tokens&#13;
    function sellAllOutcomes(uint outcomeTokenCount)&#13;
        public&#13;
    {&#13;
        // Revoke sender's outcome tokens of all outcomes&#13;
        for (uint8 i = 0; i &lt; outcomeTokens.length; i++)&#13;
            outcomeTokens[i].revoke(msg.sender, outcomeTokenCount);&#13;
        // Transfer collateral tokens to sender&#13;
        require(collateralToken.transfer(msg.sender, outcomeTokenCount));&#13;
        OutcomeTokenSetRevocation(msg.sender, outcomeTokenCount);&#13;
    }&#13;
&#13;
    /// @dev Sets winning event outcome&#13;
    function setOutcome()&#13;
        public&#13;
    {&#13;
        // Winning outcome is not set yet in event contract but in oracle contract&#13;
        require(!isOutcomeSet &amp;&amp; oracle.isOutcomeSet());&#13;
        // Set winning outcome&#13;
        outcome = oracle.getOutcome();&#13;
        isOutcomeSet = true;&#13;
        OutcomeAssignment(outcome);&#13;
    }&#13;
&#13;
    /// @dev Returns outcome count&#13;
    /// @return Outcome count&#13;
    function getOutcomeCount()&#13;
        public&#13;
        constant&#13;
        returns (uint8)&#13;
    {&#13;
        return uint8(outcomeTokens.length);&#13;
    }&#13;
&#13;
    /// @dev Returns outcome tokens array&#13;
    /// @return Outcome tokens&#13;
    function getOutcomeTokens()&#13;
        public&#13;
        constant&#13;
        returns (OutcomeToken[])&#13;
    {&#13;
        return outcomeTokens;&#13;
    }&#13;
&#13;
    /// @dev Returns the amount of outcome tokens held by owner&#13;
    /// @return Outcome token distribution&#13;
    function getOutcomeTokenDistribution(address owner)&#13;
        public&#13;
        constant&#13;
        returns (uint[] outcomeTokenDistribution)&#13;
    {&#13;
        outcomeTokenDistribution = new uint[](outcomeTokens.length);&#13;
        for (uint8 i = 0; i &lt; outcomeTokenDistribution.length; i++)&#13;
            outcomeTokenDistribution[i] = outcomeTokens[i].balanceOf(owner);&#13;
    }&#13;
&#13;
    /// @dev Calculates and returns event hash&#13;
    /// @return Event hash&#13;
    function getEventHash() public constant returns (bytes32);&#13;
&#13;
    /// @dev Exchanges sender's winning outcome tokens for collateral tokens&#13;
    /// @return Sender's winnings&#13;
    function redeemWinnings() public returns (uint);&#13;
}&#13;
&#13;
&#13;
&#13;
/// @title Abstract market maker contract - Functions to be implemented by market maker contracts&#13;
contract MarketMaker {&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    function calcCost(Market market, uint8 outcomeTokenIndex, uint outcomeTokenCount) public constant returns (uint);&#13;
    function calcProfit(Market market, uint8 outcomeTokenIndex, uint outcomeTokenCount) public constant returns (uint);&#13;
    function calcMarginalPrice(Market market, uint8 outcomeTokenIndex) public constant returns (uint);&#13;
}&#13;
&#13;
&#13;
&#13;
/// @title Abstract market contract - Functions to be implemented by market contracts&#13;
contract Market {&#13;
&#13;
    /*&#13;
     *  Events&#13;
     */&#13;
    event MarketFunding(uint funding);&#13;
    event MarketClosing();&#13;
    event FeeWithdrawal(uint fees);&#13;
    event OutcomeTokenPurchase(address indexed buyer, uint8 outcomeTokenIndex, uint outcomeTokenCount, uint outcomeTokenCost, uint marketFees);&#13;
    event OutcomeTokenSale(address indexed seller, uint8 outcomeTokenIndex, uint outcomeTokenCount, uint outcomeTokenProfit, uint marketFees);&#13;
    event OutcomeTokenShortSale(address indexed buyer, uint8 outcomeTokenIndex, uint outcomeTokenCount, uint cost);&#13;
&#13;
    /*&#13;
     *  Storage&#13;
     */&#13;
    address public creator;&#13;
    uint public createdAtBlock;&#13;
    Event public eventContract;&#13;
    MarketMaker public marketMaker;&#13;
    uint24 public fee;&#13;
    uint public funding;&#13;
    int[] public netOutcomeTokensSold;&#13;
    Stages public stage;&#13;
&#13;
    enum Stages {&#13;
        MarketCreated,&#13;
        MarketFunded,&#13;
        MarketClosed&#13;
    }&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    function fund(uint _funding) public;&#13;
    function close() public;&#13;
    function withdrawFees() public returns (uint);&#13;
    function buy(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint maxCost) public returns (uint);&#13;
    function sell(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint minProfit) public returns (uint);&#13;
    function shortSell(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint minProfit) public returns (uint);&#13;
    function calcMarketFee(uint outcomeTokenCost) public constant returns (uint);&#13;
}&#13;
&#13;
&#13;
/// @title Market factory contract - Allows to create market contracts&#13;
/// @author Stefan George - &lt;<span class="__cf_email__" data-cfemail="cbb8bfaeadaaa58baca5a4b8a2b8e5bba6">[email protected]</span>&gt;&#13;
contract StandardMarket is Market {&#13;
    using Math for *;&#13;
&#13;
    /*&#13;
     *  Constants&#13;
     */&#13;
    uint24 public constant FEE_RANGE = 1000000; // 100%&#13;
&#13;
    /*&#13;
     *  Modifiers&#13;
     */&#13;
    modifier isCreator() {&#13;
        // Only creator is allowed to proceed&#13;
        require(msg.sender == creator);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier atStage(Stages _stage) {&#13;
        // Contract has to be in given stage&#13;
        require(stage == _stage);&#13;
        _;&#13;
    }&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    /// @dev Constructor validates and sets market properties&#13;
    /// @param _creator Market creator&#13;
    /// @param _eventContract Event contract&#13;
    /// @param _marketMaker Market maker contract&#13;
    /// @param _fee Market fee&#13;
    function StandardMarket(address _creator, Event _eventContract, MarketMaker _marketMaker, uint24 _fee)&#13;
        public&#13;
    {&#13;
        // Validate inputs&#13;
        require(address(_eventContract) != 0 &amp;&amp; address(_marketMaker) != 0 &amp;&amp; _fee &lt; FEE_RANGE);&#13;
        creator = _creator;&#13;
        createdAtBlock = block.number;&#13;
        eventContract = _eventContract;&#13;
        netOutcomeTokensSold = new int[](eventContract.getOutcomeCount());&#13;
        fee = _fee;&#13;
        marketMaker = _marketMaker;&#13;
        stage = Stages.MarketCreated;&#13;
    }&#13;
&#13;
    /// @dev Allows to fund the market with collateral tokens converting them into outcome tokens&#13;
    /// @param _funding Funding amount&#13;
    function fund(uint _funding)&#13;
        public&#13;
        isCreator&#13;
        atStage(Stages.MarketCreated)&#13;
    {&#13;
        // Request collateral tokens and allow event contract to transfer them to buy all outcomes&#13;
        require(   eventContract.collateralToken().transferFrom(msg.sender, this, _funding)&#13;
                &amp;&amp; eventContract.collateralToken().approve(eventContract, _funding));&#13;
        eventContract.buyAllOutcomes(_funding);&#13;
        funding = _funding;&#13;
        stage = Stages.MarketFunded;&#13;
        MarketFunding(funding);&#13;
    }&#13;
&#13;
    /// @dev Allows market creator to close the markets by transferring all remaining outcome tokens to the creator&#13;
    function close()&#13;
        public&#13;
        isCreator&#13;
        atStage(Stages.MarketFunded)&#13;
    {&#13;
        uint8 outcomeCount = eventContract.getOutcomeCount();&#13;
        for (uint8 i = 0; i &lt; outcomeCount; i++)&#13;
            require(eventContract.outcomeTokens(i).transfer(creator, eventContract.outcomeTokens(i).balanceOf(this)));&#13;
        stage = Stages.MarketClosed;&#13;
        MarketClosing();&#13;
    }&#13;
&#13;
    /// @dev Allows market creator to withdraw fees generated by trades&#13;
    /// @return Fee amount&#13;
    function withdrawFees()&#13;
        public&#13;
        isCreator&#13;
        returns (uint fees)&#13;
    {&#13;
        fees = eventContract.collateralToken().balanceOf(this);&#13;
        // Transfer fees&#13;
        require(eventContract.collateralToken().transfer(creator, fees));&#13;
        FeeWithdrawal(fees);&#13;
    }&#13;
&#13;
    /// @dev Allows to buy outcome tokens from market maker&#13;
    /// @param outcomeTokenIndex Index of the outcome token to buy&#13;
    /// @param outcomeTokenCount Amount of outcome tokens to buy&#13;
    /// @param maxCost The maximum cost in collateral tokens to pay for outcome tokens&#13;
    /// @return Cost in collateral tokens&#13;
    function buy(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint maxCost)&#13;
        public&#13;
        atStage(Stages.MarketFunded)&#13;
        returns (uint cost)&#13;
    {&#13;
        // Calculate cost to buy outcome tokens&#13;
        uint outcomeTokenCost = marketMaker.calcCost(this, outcomeTokenIndex, outcomeTokenCount);&#13;
        // Calculate fees charged by market&#13;
        uint fees = calcMarketFee(outcomeTokenCost);&#13;
        cost = outcomeTokenCost.add(fees);&#13;
        // Check cost doesn't exceed max cost&#13;
        require(cost &gt; 0 &amp;&amp; cost &lt;= maxCost);&#13;
        // Transfer tokens to markets contract and buy all outcomes&#13;
        require(   eventContract.collateralToken().transferFrom(msg.sender, this, cost)&#13;
                &amp;&amp; eventContract.collateralToken().approve(eventContract, outcomeTokenCost));&#13;
        // Buy all outcomes&#13;
        eventContract.buyAllOutcomes(outcomeTokenCost);&#13;
        // Transfer outcome tokens to buyer&#13;
        require(eventContract.outcomeTokens(outcomeTokenIndex).transfer(msg.sender, outcomeTokenCount));&#13;
        // Add outcome token count to market maker net balance&#13;
        require(int(outcomeTokenCount) &gt;= 0);&#13;
        netOutcomeTokensSold[outcomeTokenIndex] = netOutcomeTokensSold[outcomeTokenIndex].add(int(outcomeTokenCount));&#13;
        OutcomeTokenPurchase(msg.sender, outcomeTokenIndex, outcomeTokenCount, outcomeTokenCost, fees);&#13;
    }&#13;
&#13;
    /// @dev Allows to sell outcome tokens to market maker&#13;
    /// @param outcomeTokenIndex Index of the outcome token to sell&#13;
    /// @param outcomeTokenCount Amount of outcome tokens to sell&#13;
    /// @param minProfit The minimum profit in collateral tokens to earn for outcome tokens&#13;
    /// @return Profit in collateral tokens&#13;
    function sell(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint minProfit)&#13;
        public&#13;
        atStage(Stages.MarketFunded)&#13;
        returns (uint profit)&#13;
    {&#13;
        // Calculate profit for selling outcome tokens&#13;
        uint outcomeTokenProfit = marketMaker.calcProfit(this, outcomeTokenIndex, outcomeTokenCount);&#13;
        // Calculate fee charged by market&#13;
        uint fees = calcMarketFee(outcomeTokenProfit);&#13;
        profit = outcomeTokenProfit.sub(fees);&#13;
        // Check profit is not too low&#13;
        require(profit &gt; 0 &amp;&amp; profit &gt;= minProfit);&#13;
        // Transfer outcome tokens to markets contract to sell all outcomes&#13;
        require(eventContract.outcomeTokens(outcomeTokenIndex).transferFrom(msg.sender, this, outcomeTokenCount));&#13;
        // Sell all outcomes&#13;
        eventContract.sellAllOutcomes(outcomeTokenProfit);&#13;
        // Transfer profit to seller&#13;
        require(eventContract.collateralToken().transfer(msg.sender, profit));&#13;
        // Subtract outcome token count from market maker net balance&#13;
        require(int(outcomeTokenCount) &gt;= 0);&#13;
        netOutcomeTokensSold[outcomeTokenIndex] = netOutcomeTokensSold[outcomeTokenIndex].sub(int(outcomeTokenCount));&#13;
        OutcomeTokenSale(msg.sender, outcomeTokenIndex, outcomeTokenCount, outcomeTokenProfit, fees);&#13;
    }&#13;
&#13;
    /// @dev Buys all outcomes, then sells all shares of selected outcome which were bought, keeping&#13;
    ///      shares of all other outcome tokens.&#13;
    /// @param outcomeTokenIndex Index of the outcome token to short sell&#13;
    /// @param outcomeTokenCount Amount of outcome tokens to short sell&#13;
    /// @param minProfit The minimum profit in collateral tokens to earn for short sold outcome tokens&#13;
    /// @return Cost to short sell outcome in collateral tokens&#13;
    function shortSell(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint minProfit)&#13;
        public&#13;
        returns (uint cost)&#13;
    {&#13;
        // Buy all outcomes&#13;
        require(   eventContract.collateralToken().transferFrom(msg.sender, this, outcomeTokenCount)&#13;
                &amp;&amp; eventContract.collateralToken().approve(eventContract, outcomeTokenCount));&#13;
        eventContract.buyAllOutcomes(outcomeTokenCount);&#13;
        // Short sell selected outcome&#13;
        eventContract.outcomeTokens(outcomeTokenIndex).approve(this, outcomeTokenCount);&#13;
        uint profit = this.sell(outcomeTokenIndex, outcomeTokenCount, minProfit);&#13;
        cost = outcomeTokenCount - profit;&#13;
        // Transfer outcome tokens to buyer&#13;
        uint8 outcomeCount = eventContract.getOutcomeCount();&#13;
        for (uint8 i = 0; i &lt; outcomeCount; i++)&#13;
            if (i != outcomeTokenIndex)&#13;
                require(eventContract.outcomeTokens(i).transfer(msg.sender, outcomeTokenCount));&#13;
        // Send change back to buyer&#13;
        require(eventContract.collateralToken().transfer(msg.sender, profit));&#13;
        OutcomeTokenShortSale(msg.sender, outcomeTokenIndex, outcomeTokenCount, cost);&#13;
    }&#13;
&#13;
    /// @dev Calculates fee to be paid to market maker&#13;
    /// @param outcomeTokenCost Cost for buying outcome tokens&#13;
    /// @return Fee for trade&#13;
    function calcMarketFee(uint outcomeTokenCost)&#13;
        public&#13;
        constant&#13;
        returns (uint)&#13;
    {&#13;
        return outcomeTokenCost * fee / FEE_RANGE;&#13;
    }&#13;
}&#13;
&#13;
&#13;
&#13;
/// @title Market factory contract - Allows to create market contracts&#13;
/// @author Stefan George - &lt;<span class="__cf_email__" data-cfemail="7b080f1e1d1a153b">[email protected]</span>gnosis.pm&gt;&#13;
contract StandardMarketFactory {&#13;
&#13;
    /*&#13;
     *  Events&#13;
     */&#13;
    event StandardMarketCreation(address indexed creator, Market market, Event eventContract, MarketMaker marketMaker, uint24 fee);&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    /// @dev Creates a new market contract&#13;
    /// @param eventContract Event contract&#13;
    /// @param marketMaker Market maker contract&#13;
    /// @param fee Market fee&#13;
    /// @return Market contract&#13;
    function createMarket(Event eventContract, MarketMaker marketMaker, uint24 fee)&#13;
        public&#13;
        returns (StandardMarket market)&#13;
    {&#13;
        market = new StandardMarket(msg.sender, eventContract, marketMaker, fee);&#13;
        StandardMarketCreation(msg.sender, market, eventContract, marketMaker, fee);&#13;
    }&#13;
}
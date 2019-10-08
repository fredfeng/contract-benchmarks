pragma solidity 0.4.15;


/// @title Abstract oracle contract - Functions to be implemented by oracles
contract Oracle {

    function isOutcomeSet() public constant returns (bool);
    function getOutcome() public constant returns (int);
}



/// @title Centralized oracle contract - Allows the contract owner to set an outcome
/// @author Stefan George - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="4033342526212e00272e2f3329336e302d">[email protected]</a>&gt;&#13;
contract CentralizedOracle is Oracle {&#13;
&#13;
    /*&#13;
     *  Events&#13;
     */&#13;
    event OwnerReplacement(address indexed newOwner);&#13;
    event OutcomeAssignment(int outcome);&#13;
&#13;
    /*&#13;
     *  Storage&#13;
     */&#13;
    address public owner;&#13;
    bytes public ipfsHash;&#13;
    bool public isSet;&#13;
    int public outcome;&#13;
&#13;
    /*&#13;
     *  Modifiers&#13;
     */&#13;
    modifier isOwner () {&#13;
        // Only owner is allowed to proceed&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    /// @dev Constructor sets owner address and IPFS hash&#13;
    /// @param _ipfsHash Hash identifying off chain event description&#13;
    function CentralizedOracle(address _owner, bytes _ipfsHash)&#13;
        public&#13;
    {&#13;
        // Description hash cannot be null&#13;
        require(_ipfsHash.length == 46);&#13;
        owner = _owner;&#13;
        ipfsHash = _ipfsHash;&#13;
    }&#13;
&#13;
    /// @dev Replaces owner&#13;
    /// @param newOwner New owner&#13;
    function replaceOwner(address newOwner)&#13;
        public&#13;
        isOwner&#13;
    {&#13;
        // Result is not set yet&#13;
        require(!isSet);&#13;
        owner = newOwner;&#13;
        OwnerReplacement(newOwner);&#13;
    }&#13;
&#13;
    /// @dev Sets event outcome&#13;
    /// @param _outcome Event outcome&#13;
    function setOutcome(int _outcome)&#13;
        public&#13;
        isOwner&#13;
    {&#13;
        // Result is not set yet&#13;
        require(!isSet);&#13;
        isSet = true;&#13;
        outcome = _outcome;&#13;
        OutcomeAssignment(_outcome);&#13;
    }&#13;
&#13;
    /// @dev Returns if winning outcome is set&#13;
    /// @return Is outcome set?&#13;
    function isOutcomeSet()&#13;
        public&#13;
        constant&#13;
        returns (bool)&#13;
    {&#13;
        return isSet;&#13;
    }&#13;
&#13;
    /// @dev Returns outcome&#13;
    /// @return Outcome&#13;
    function getOutcome()&#13;
        public&#13;
        constant&#13;
        returns (int)&#13;
    {&#13;
        return outcome;&#13;
    }&#13;
}&#13;
&#13;
&#13;
&#13;
/// @title Centralized oracle factory contract - Allows to create centralized oracle contracts&#13;
/// @author Stefan George - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="bac9cedfdcdbd4faddd4d5c9d3c994cad7">[email protected]</a>&gt;&#13;
contract CentralizedOracleFactory {&#13;
&#13;
    /*&#13;
     *  Events&#13;
     */&#13;
    event CentralizedOracleCreation(address indexed creator, CentralizedOracle centralizedOracle, bytes ipfsHash);&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    /// @dev Creates a new centralized oracle contract&#13;
    /// @param ipfsHash Hash identifying off chain event description&#13;
    /// @return Oracle contract&#13;
    function createCentralizedOracle(bytes ipfsHash)&#13;
        public&#13;
        returns (CentralizedOracle centralizedOracle)&#13;
    {&#13;
        centralizedOracle = new CentralizedOracle(msg.sender, ipfsHash);&#13;
        CentralizedOracleCreation(msg.sender, centralizedOracle, ipfsHash);&#13;
    }&#13;
}
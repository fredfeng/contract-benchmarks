pragma solidity ^0.4.17;

/*

 * source       https://github.com/blockbitsio/

 * @name        Application Entity Generic Contract
 * @package     BlockBitsIO
 * @author      Micky Socaci <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e885818b8391a886879f84819e8dc69a87">[email protected]</a>&gt;&#13;
&#13;
    Used for the ABI interface when assets need to call Application Entity.&#13;
&#13;
    This is required, otherwise we end up loading the assets themselves when we load the ApplicationEntity contract&#13;
    and end up in a loop&#13;
*/&#13;
&#13;
&#13;
&#13;
contract ApplicationEntityABI {&#13;
&#13;
    address public ProposalsEntity;&#13;
    address public FundingEntity;&#13;
    address public MilestonesEntity;&#13;
    address public MeetingsEntity;&#13;
    address public BountyManagerEntity;&#13;
    address public TokenManagerEntity;&#13;
    address public ListingContractEntity;&#13;
    address public FundingManagerEntity;&#13;
    address public NewsContractEntity;&#13;
&#13;
    bool public _initialized = false;&#13;
    bool public _locked = false;&#13;
    uint8 public CurrentEntityState;&#13;
    uint8 public AssetCollectionNum;&#13;
    address public GatewayInterfaceAddress;&#13;
    address public deployerAddress;&#13;
    address testAddressAllowUpgradeFrom;&#13;
    mapping (bytes32 =&gt; uint8) public EntityStates;&#13;
    mapping (bytes32 =&gt; address) public AssetCollection;&#13;
    mapping (uint8 =&gt; bytes32) public AssetCollectionIdToName;&#13;
    mapping (bytes32 =&gt; uint256) public BylawsUint256;&#13;
    mapping (bytes32 =&gt; bytes32) public BylawsBytes32;&#13;
&#13;
    function ApplicationEntity() public;&#13;
    function getEntityState(bytes32 name) public view returns (uint8);&#13;
    function linkToGateway( address _GatewayInterfaceAddress, bytes32 _sourceCodeUrl ) external;&#13;
    function setUpgradeState(uint8 state) public ;&#13;
    function addAssetProposals(address _assetAddresses) external;&#13;
    function addAssetFunding(address _assetAddresses) external;&#13;
    function addAssetMilestones(address _assetAddresses) external;&#13;
    function addAssetMeetings(address _assetAddresses) external;&#13;
    function addAssetBountyManager(address _assetAddresses) external;&#13;
    function addAssetTokenManager(address _assetAddresses) external;&#13;
    function addAssetFundingManager(address _assetAddresses) external;&#13;
    function addAssetListingContract(address _assetAddresses) external;&#13;
    function addAssetNewsContract(address _assetAddresses) external;&#13;
    function getAssetAddressByName(bytes32 _name) public view returns (address);&#13;
    function setBylawUint256(bytes32 name, uint256 value) public;&#13;
    function getBylawUint256(bytes32 name) public view returns (uint256);&#13;
    function setBylawBytes32(bytes32 name, bytes32 value) public;&#13;
    function getBylawBytes32(bytes32 name) public view returns (bytes32);&#13;
    function initialize() external returns (bool);&#13;
    function getParentAddress() external view returns(address);&#13;
    function createCodeUpgradeProposal( address _newAddress, bytes32 _sourceCodeUrl ) external returns (uint256);&#13;
    function acceptCodeUpgradeProposal(address _newAddress) external;&#13;
    function initializeAssetsToThisApplication() external returns (bool);&#13;
    function transferAssetsToNewApplication(address _newAddress) external returns (bool);&#13;
    function lock() external returns (bool);&#13;
    function canInitiateCodeUpgrade(address _sender) public view returns(bool);&#13;
    function doStateChanges() public;&#13;
    function hasRequiredStateChanges() public view returns (bool);&#13;
    function anyAssetHasChanges() public view returns (bool);&#13;
    function extendedAnyAssetHasChanges() internal view returns (bool);&#13;
    function getRequiredStateChanges() public view returns (uint8, uint8);&#13;
    function getTimestamp() view public returns (uint256);&#13;
&#13;
}&#13;
&#13;
/*&#13;
&#13;
 * source       https://github.com/blockbitsio/&#13;
&#13;
 * @name        Application Asset Contract&#13;
 * @package     BlockBitsIO&#13;
 * @author      Micky Socaci &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="96fbfff5fdefd6f8f9e1faffe0f3b8e4f9">[email protected]</a>&gt;&#13;
&#13;
 Any contract inheriting this will be usable as an Asset in the Application Entity&#13;
&#13;
*/&#13;
&#13;
&#13;
&#13;
&#13;
contract ApplicationAsset {&#13;
&#13;
    event EventAppAssetOwnerSet(bytes32 indexed _name, address indexed _owner);&#13;
    event EventRunBeforeInit(bytes32 indexed _name);&#13;
    event EventRunBeforeApplyingSettings(bytes32 indexed _name);&#13;
&#13;
&#13;
    mapping (bytes32 =&gt; uint8) public EntityStates;&#13;
    mapping (bytes32 =&gt; uint8) public RecordStates;&#13;
    uint8 public CurrentEntityState;&#13;
&#13;
    event EventEntityProcessor(bytes32 indexed _assetName, uint8 indexed _current, uint8 indexed _required);&#13;
    event DebugEntityRequiredChanges( bytes32 _assetName, uint8 indexed _current, uint8 indexed _required );&#13;
&#13;
    bytes32 public assetName;&#13;
&#13;
    /* Asset records */&#13;
    uint8 public RecordNum = 0;&#13;
&#13;
    /* Asset initialised or not */&#13;
    bool public _initialized = false;&#13;
&#13;
    /* Asset settings present or not */&#13;
    bool public _settingsApplied = false;&#13;
&#13;
    /* Asset owner ( ApplicationEntity address ) */&#13;
    address public owner = address(0x0) ;&#13;
    address public deployerAddress;&#13;
&#13;
    function ApplicationAsset() public {&#13;
        deployerAddress = msg.sender;&#13;
    }&#13;
&#13;
    function setInitialApplicationAddress(address _ownerAddress) public onlyDeployer requireNotInitialised {&#13;
        owner = _ownerAddress;&#13;
    }&#13;
&#13;
    function setInitialOwnerAndName(bytes32 _name) external&#13;
        requireNotInitialised&#13;
        onlyOwner&#13;
        returns (bool)&#13;
    {&#13;
        // init states&#13;
        setAssetStates();&#13;
        assetName = _name;&#13;
        // set initial state&#13;
        CurrentEntityState = getEntityState("NEW");&#13;
        runBeforeInitialization();&#13;
        _initialized = true;&#13;
        EventAppAssetOwnerSet(_name, owner);&#13;
        return true;&#13;
    }&#13;
&#13;
    function setAssetStates() internal {&#13;
        // Asset States&#13;
        EntityStates["__IGNORED__"]     = 0;&#13;
        EntityStates["NEW"]             = 1;&#13;
        // Funding Stage States&#13;
        RecordStates["__IGNORED__"]     = 0;&#13;
    }&#13;
&#13;
    function getRecordState(bytes32 name) public view returns (uint8) {&#13;
        return RecordStates[name];&#13;
    }&#13;
&#13;
    function getEntityState(bytes32 name) public view returns (uint8) {&#13;
        return EntityStates[name];&#13;
    }&#13;
&#13;
    function runBeforeInitialization() internal requireNotInitialised  {&#13;
        EventRunBeforeInit(assetName);&#13;
    }&#13;
&#13;
    function applyAndLockSettings()&#13;
        public&#13;
        onlyDeployer&#13;
        requireInitialised&#13;
        requireSettingsNotApplied&#13;
        returns(bool)&#13;
    {&#13;
        runBeforeApplyingSettings();&#13;
        _settingsApplied = true;&#13;
        return true;&#13;
    }&#13;
&#13;
    function runBeforeApplyingSettings() internal requireInitialised requireSettingsNotApplied  {&#13;
        EventRunBeforeApplyingSettings(assetName);&#13;
    }&#13;
&#13;
    function transferToNewOwner(address _newOwner) public requireInitialised onlyOwner returns (bool) {&#13;
        require(owner != address(0x0) &amp;&amp; _newOwner != address(0x0));&#13;
        owner = _newOwner;&#13;
        EventAppAssetOwnerSet(assetName, owner);&#13;
        return true;&#13;
    }&#13;
&#13;
    function getApplicationAssetAddressByName(bytes32 _name)&#13;
        public&#13;
        view&#13;
        returns(address)&#13;
    {&#13;
        address asset = ApplicationEntityABI(owner).getAssetAddressByName(_name);&#13;
        if( asset != address(0x0) ) {&#13;
            return asset;&#13;
        } else {&#13;
            revert();&#13;
        }&#13;
    }&#13;
&#13;
    function getApplicationState() public view returns (uint8) {&#13;
        return ApplicationEntityABI(owner).CurrentEntityState();&#13;
    }&#13;
&#13;
    function getApplicationEntityState(bytes32 name) public view returns (uint8) {&#13;
        return ApplicationEntityABI(owner).getEntityState(name);&#13;
    }&#13;
&#13;
    function getAppBylawUint256(bytes32 name) public view requireInitialised returns (uint256) {&#13;
        ApplicationEntityABI CurrentApp = ApplicationEntityABI(owner);&#13;
        return CurrentApp.getBylawUint256(name);&#13;
    }&#13;
&#13;
    function getAppBylawBytes32(bytes32 name) public view requireInitialised returns (bytes32) {&#13;
        ApplicationEntityABI CurrentApp = ApplicationEntityABI(owner);&#13;
        return CurrentApp.getBylawBytes32(name);&#13;
    }&#13;
&#13;
    modifier onlyOwner() {&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyApplicationEntity() {&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier requireInitialised() {&#13;
        require(_initialized == true);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier requireNotInitialised() {&#13;
        require(_initialized == false);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier requireSettingsApplied() {&#13;
        require(_settingsApplied == true);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier requireSettingsNotApplied() {&#13;
        require(_settingsApplied == false);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyDeployer() {&#13;
        require(msg.sender == deployerAddress);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyAsset(bytes32 _name) {&#13;
        address AssetAddress = getApplicationAssetAddressByName(_name);&#13;
        require( msg.sender == AssetAddress);&#13;
        _;&#13;
    }&#13;
&#13;
    function getTimestamp() view public returns (uint256) {&#13;
        return now;&#13;
    }&#13;
&#13;
&#13;
}&#13;
&#13;
/*&#13;
&#13;
 * source       https://github.com/blockbitsio/&#13;
&#13;
 * @name        Token Contract&#13;
 * @package     BlockBitsIO&#13;
 * @author      Micky Socaci &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="afc2c6ccc4d6efc1c0d8c3c6d9ca81ddc0">[email protected]</a>&gt;&#13;
&#13;
 Zeppelin ERC20 Standard Token&#13;
&#13;
*/&#13;
&#13;
&#13;
&#13;
contract ABIToken {&#13;
&#13;
    string public  symbol;&#13;
    string public  name;&#13;
    uint8 public   decimals;&#13;
    uint256 public totalSupply;&#13;
    string public  version;&#13;
    mapping (address =&gt; uint256) public balances;&#13;
    mapping (address =&gt; mapping (address =&gt; uint256)) allowed;&#13;
    address public manager;&#13;
    address public deployer;&#13;
    bool public mintingFinished = false;&#13;
    bool public initialized = false;&#13;
&#13;
    function transfer(address _to, uint256 _value) public returns (bool);&#13;
    function balanceOf(address _owner) public view returns (uint256 balance);&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);&#13;
    function approve(address _spender, uint256 _value) public returns (bool);&#13;
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);&#13;
    function increaseApproval(address _spender, uint _addedValue) public returns (bool success);&#13;
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success);&#13;
    function mint(address _to, uint256 _amount) public returns (bool);&#13;
    function finishMinting() public returns (bool);&#13;
&#13;
    event Transfer(address indexed from, address indexed to, uint256 indexed value);&#13;
    event Approval(address indexed owner, address indexed spender, uint256 indexed value);&#13;
    event Mint(address indexed to, uint256 amount);&#13;
    event MintFinished();&#13;
}&#13;
&#13;
/*&#13;
&#13;
 * source       https://github.com/blockbitsio/&#13;
&#13;
 * @name        Token Stake Calculation And Distribution Algorithm - Type 3 - Sell a variable amount of tokens for a fixed price&#13;
 * @package     BlockBitsIO&#13;
 * @author      Micky Socaci &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="761b1f151d0f361819011a1f0013580419">[email protected]</a>&gt;&#13;
&#13;
&#13;
    Inputs:&#13;
&#13;
    Defined number of tokens per wei ( X Tokens = 1 wei )&#13;
    Received amount of ETH&#13;
    Generates:&#13;
&#13;
    Total Supply of tokens available in Funding Phase respectively Project&#13;
    Observations:&#13;
&#13;
    Will sell the whole supply of Tokens available to Current Funding Phase&#13;
    Use cases:&#13;
&#13;
    Any Funding Phase where you want the first Funding Phase to determine the token supply of the whole Project&#13;
&#13;
*/&#13;
&#13;
&#13;
&#13;
&#13;
contract ABITokenSCADAVariable {&#13;
    bool public SCADA_requires_hard_cap = true;&#13;
    bool public initialized;&#13;
    address public deployerAddress;&#13;
    function addSettings(address _fundingContract) public;&#13;
    function requiresHardCap() public view returns (bool);&#13;
    function getTokensForValueInCurrentStage(uint256 _value) public view returns (uint256);&#13;
    function getTokensForValueInStage(uint8 _stage, uint256 _value) public view returns (uint256);&#13;
    function getBoughtTokens( address _vaultAddress, bool _direct ) public view returns (uint256);&#13;
}&#13;
&#13;
/*&#13;
&#13;
 * source       https://github.com/blockbitsio/&#13;
&#13;
 * @name        Token Manager Contract&#13;
 * @package     BlockBitsIO&#13;
 * @author      Micky Socaci &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2a47434941536a44455d46435c4f045845">[email protected]</a>&gt;&#13;
&#13;
*/&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
contract TokenManager is ApplicationAsset {&#13;
&#13;
    ABITokenSCADAVariable public TokenSCADAEntity;&#13;
    ABIToken public TokenEntity;&#13;
    address public MarketingMethodAddress;&#13;
&#13;
    function addSettings(address _scadaAddress, address _tokenAddress, address _marketing ) onlyDeployer public {&#13;
        TokenSCADAEntity = ABITokenSCADAVariable(_scadaAddress);&#13;
        TokenEntity = ABIToken(_tokenAddress);&#13;
        MarketingMethodAddress = _marketing;&#13;
    }&#13;
&#13;
    function getTokenSCADARequiresHardCap() public view returns (bool) {&#13;
        return TokenSCADAEntity.requiresHardCap();&#13;
    }&#13;
&#13;
    function mint(address _to, uint256 _amount)&#13;
        onlyAsset('FundingManager')&#13;
        public&#13;
        returns (bool)&#13;
    {&#13;
        return TokenEntity.mint(_to, _amount);&#13;
    }&#13;
&#13;
    function finishMinting()&#13;
        onlyAsset('FundingManager')&#13;
        public&#13;
        returns (bool)&#13;
    {&#13;
        return TokenEntity.finishMinting();&#13;
    }&#13;
&#13;
    function mintForMarketingPool(address _to, uint256 _amount)&#13;
        onlyMarketingPoolAsset&#13;
        requireSettingsApplied&#13;
        external&#13;
        returns (bool)&#13;
    {&#13;
        return TokenEntity.mint(_to, _amount);&#13;
    }&#13;
&#13;
    modifier onlyMarketingPoolAsset() {&#13;
        require(msg.sender == MarketingMethodAddress);&#13;
        _;&#13;
    }&#13;
&#13;
    // Development stage complete, release tokens to Project Owners&#13;
    event EventOwnerTokenBalancesReleased(address _addr, uint256 _value);&#13;
    bool OwnerTokenBalancesReleased = false;&#13;
&#13;
    function ReleaseOwnersLockedTokens(address _multiSigOutputAddress)&#13;
        public&#13;
        onlyAsset('FundingManager')&#13;
        returns (bool)&#13;
    {&#13;
        require(OwnerTokenBalancesReleased == false);&#13;
        uint256 lockedBalance = TokenEntity.balanceOf(address(this));&#13;
        TokenEntity.transfer( _multiSigOutputAddress, lockedBalance );&#13;
        EventOwnerTokenBalancesReleased(_multiSigOutputAddress, lockedBalance);&#13;
        OwnerTokenBalancesReleased = true;&#13;
        return true;&#13;
    }&#13;
&#13;
}
pragma solidity 0.4.23;

contract ERC20BasicInterface {
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
}

/**
 * @title ERC20Lock
 *
 * This contract keeps particular token till the unlock date and sends it to predefined destination.
 */
contract DLSDLockFounders18 {
    ERC20BasicInterface constant TOKEN = ERC20BasicInterface(0x8458d484572cEB89ce70EEBBe17Dc84707b241eD);
    address constant OWNER = 0x603F65F7Fc4f650c2F025800F882CFb62BF23580;
    address constant DESTINATION = 0xd79d4455a327801EdC730033b7524dD0163ea182;
    uint constant UNLOCK_DATE = 1587945599; // Sunday, April 26, 2020 11:59:59 PM

    function unlock() public returns(bool) {
        require(now > UNLOCK_DATE, 'Tokens are still locked');
        return TOKEN.transfer(DESTINATION, TOKEN.balanceOf(address(this)));
    }

    function recoverTokens(ERC20BasicInterface _token, address _to, uint _value) public returns(bool) {
        require(msg.sender == OWNER, 'Access denied');
        // This token meant to be recovered by calling unlock().
        require(address(_token) != address(TOKEN), 'Can not recover this token');
        return _token.transfer(_to, _value);
    }
}
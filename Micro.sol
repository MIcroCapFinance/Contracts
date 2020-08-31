/**
 __   __  ___   _______  ______    _______ 
|  |_|  ||   | |       ||    _ |  |       |
|       ||   | |       ||   | ||  |   _   |
|       ||   | |       ||   |_||_ |  | |  |
|       ||   | |      _||    __  ||  |_|  |
| ||_|| ||   | |     |_ |   |  | ||       |
|_|   |_||___| |_______||___|  |_||_______|

microcap.finance
*/

pragma solidity ^0.5.15;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract IERC20 {

    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event CreateContract(address indexed contractAddress, string name);

}

contract MicroToken is IERC20 {

    using SafeMath for uint256;

    // Token properties
    string public name = "MICRO Token @ microcap.finance";
    string public symbol = "MICRO";
    uint public decimals = 18;

    uint public _totalSupply = 50000000e18;

    // Balances for each account
    mapping (address => uint256) balances;

    // Owner of account approves the transfer of an amount to another account
    mapping (address => mapping(address => uint256)) allowed;

    // Owner of Token
    address public owner;
    
    address public fund;
    uint    public feePercent;
  
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    // Constructor
    // @notice HaloTestToken Contract
    // @return the transaction address
    constructor(address _fund, uint _feePercent) public payable {
        owner = msg.sender;
        fund = _fund;
        feePercent = _feePercent;
        balances[msg.sender] = _totalSupply;
    }

    function setOwner(address _owner) public onlyOwner {
        require(_owner != address(0x0));
        owner = _owner;
    }

    function setFundAddress(address _fund) public onlyOwner {
        require(_fund != address(0x0));
        fund = _fund;
    }

    function setFeePercent(uint _feePercent) public onlyOwner {
        feePercent  = _feePercent;
    }
    
    // @return total tokens supplied
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    // What is the balance of a particular account?
    // @param who The address of the particular account
    // @return the balanace the particular account
    function balanceOf(address who) public view returns (uint balance) {
        return balances[who];
    }

    // @notice send `value` token to `to` from `msg.sender`
    // @param to The address of the recipient
    // @param value The amount of token to be transferred
    // @return the transaction address and send the event as Transfer
    function transfer(address to, uint256 value) public returns (bool success){
        require (
            balances[msg.sender] >= value && value > 0
        );
        uint feeAmount = value.mul(feePercent).div(100);
        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value.sub(feeAmount));
        balances[fund] = balances[fund].add(feeAmount);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    // @notice send `value` token to `to` from `from`
    // @param from The address of the sender
    // @param to The address of the recipient
    // @param value The amount of token to be transferred
    // @return the transaction address and send the event as Transfer
    function transferFrom(address from, address to, uint256 value) public returns (bool success){
        require (
            allowed[from][msg.sender] >= value && balances[from] >= value && value > 0
        );
        uint feeAmount = value.mul(feePercent).div(100);
        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value.sub(feeAmount));
        balances[fund] = balances[fund].add(feeAmount);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
        emit Transfer(from, to, value);
        return true;
    }

    // Allow spender to withdraw from your account, multiple times, up to the value amount.
    // If this function is called again it overwrites the current allowance with value.
    // @param spender The address of the sender
    // @param value The amount to be approved
    // @return the transaction address and send the event as Approval
    function approve(address spender, uint256 value) public returns (bool success){
        require (
            balances[msg.sender] >= value && value > 0
        );
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    // Check the allowed value for the spender to withdraw from owner
    // @param owner The address of the owner
    // @param spender The address of the spender
    // @return the amount which spender is still allowed to withdraw from owner
    function allowance(address _owner, address spender) public view returns (uint remaining) {
        return allowed[_owner][spender];
    }
}

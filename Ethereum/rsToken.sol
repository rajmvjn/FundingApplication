pragma solidity ^0.5.0;

interface ERC20Interface {
    function totalSupply() external view returns(uint);
    function balanceOf(address tokenOwner) external view returns(uint balance);
    function transfer(address payable to, uint tokens) external payable returns(bool success);
    
    //// allowance(address tokenOwner, address spender) external view returns (uint remaining);
    //function transferFrom(address from, address to, uint tokens) external returns(bool success);
    //function approve(address spender, uint tokens) external returns(bool success);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    //event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract RsToken is ERC20Interface {
    string public name = "RSCrypto";
    string public symbol = "RSC";
    uint  public decimals = 0; //18 is the most common
    
    uint public supply;
    address payable public founder;
    
    mapping (address => uint) public balances;
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Alert(uint msg);
    
    constructor() public{
        supply = 1000000;
        founder = msg.sender;
        balances[founder] = supply;
    }
    
    function totalSupply() external view returns(uint){
        return supply;
    }
    
    function balanceOf(address tokenOwner) external view returns(uint balance){
        return balances[tokenOwner];
    }
    
    function transfer(address payable to, uint tokens) external payable returns(bool success){
        emit Alert(balances[msg.sender]);
        require(balances[msg.sender] >= tokens && tokens > 0);
        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
    
}
pragma solidity ^0.5.0;

interface ERC20Interface {
    function totalSupply() external view returns(uint);
    function balanceOf(address tokenOwner) external view returns(uint balance);
    function transfer(address payable to, uint tokens) external payable returns(bool success);
    
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transferFrom(address from, address to, uint tokens) external returns(bool success);
    function approve(address spender, uint tokens) external payable returns(bool success);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract RsToken is ERC20Interface {
    string public name = "RSCrypto";
    string public symbol = "RSC";
    uint  public decimals = 0; //18 is the most common
    
    uint public supply;
    address payable public founder;
    
    mapping (address => uint) public balances;
    mapping (address => mapping(address => uint)) allowed;
    
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
    
    function allowance(address tokenOwner, address spender) view public returns(uint){
        return allowed[tokenOwner][spender];
    }
    
    function approve(address spender, uint tokens) public payable returns(bool){
        require(tokens > 0);
        require(balances[msg.sender] >= tokens);
        
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
        
    }
    
    function transferFrom(address _from, address to, uint tokens) external returns(bool){
        require(allowed[_from][to] >= tokens );
        require(balances[_from] >=tokens );
        
        balances[_from] -= tokens;
        balances[to] += tokens;
        
        allowed[_from][to] -= tokens;
        
        return true;
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



contract CryptosICO is RsToken{
    address public admin;
    address payable public deposit;
    
    uint tokenPrice = 1000000000000000;//minimun ether in wei
    uint public hardCap = 300000000000000000000; //300 ether in wei
    
    uint public raisedAmount;
    uint public salesStart = now;
    uint public salesEnd = now + 604800; // one week
    
    uint public maxInvestment = 5000000000000000000;
    uint public minInvestment = 1000000000000000;
    
    enum State { beforeStart, running, afterStart, halted, afterEnd }
    State public icoState;
    
    event Invest(address investor, uint value, uint tokens);
    
    modifier onlyOwner{
        require(msg.sender == admin);
        _;
    }
    
    constructor(address payable _deposit) public{
        deposit = _deposit;
        admin   = msg.sender;
        icoState = State.beforeStart;
    }
     
    function halt() public onlyOwner{
        icoState = State.halted;
    } 
    
    function unHalt() public onlyOwner{
        icoState = State.running;
    }
    
    function changeDepositAddress(address payable newDopsit)public {
        deposit = newDopsit;
    }
    
    function getCurrentState() public view returns(State){
        if(icoState == State.halted){
            return State.halted;
        }else if(block.timestamp < salesStart){
            return State.beforeStart;
        }else if(block.timestamp >= salesStart && block.timestamp <=salesEnd){
            return State.running;
        }else{
            return State.afterEnd;
        }
    }
    
    function invest() payable public returns(bool){
        icoState = getCurrentState();
        require(icoState == State.running);
        
        require(msg.value >= minInvestment && msg.value >= maxInvestment);
        require(raisedAmount + msg.value <= hardCap);
        raisedAmount += msg.value;
        
        uint tokens = msg.value/tokenPrice;
        
        balances[msg.sender] += tokens;
        balances[founder] -= tokens;
        deposit.transfer(msg.value);
        emit Invest(msg.sender, msg.value, tokens);
        
        return true;
    }
    
    function () payable external {
        invest();
    }
    
    
    
}
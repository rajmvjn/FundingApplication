pragma solidity ^0.5.0;

contract fundRaising{
    mapping (address => uint) public contributers;
    address public fundAdmin;
    uint public noOfContributers;
    uint public minContribution;
    uint public deadline;
    uint public goal;
    
    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address => bool) voters;
    }
    
    Request[] public requests;
    
    uint public raisedAmount = 0;
    
    constructor(uint _goal, uint _deadline) public {
        goal = _goal;
        deadline = _deadline+now;
        
        fundAdmin = msg.sender;
        minContribution = 10;
    }
    
    modifier onlyAdmin(){
        require(msg.sender == fundAdmin);
        _;
    }
    
    
    function contribute() public payable{
        require(now < deadline);
        require(msg.value >= minContribution);
        
        if(contributers[msg.sender] == 0){
            noOfContributers++;
        }
        
        contributers[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }
    
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    
    function getRefund() public payable{
        require(now > deadline);
        require(raisedAmount < goal);
        require(contributers[msg.sender] > 0);
        
        address payable recipient = msg.sender;
        recipient.transfer(msg.value);
        contributers[msg.sender] = 0;
        raisedAmount -= msg.value;
    }    
    
    function createRequest(string memory _description, address payable _recipient, uint _value) public  onlyAdmin{
        Request memory newRequest = Request({
            description: _description,
            recipient: _recipient,
            value: _value,
            completed: false,
            noOfVoters:0
        });
        
        requests.push(newRequest);
    }
    
    function voteRequest(uint index) public {
        require(contributers[msg.sender] > 0);
        Request storage thisRequest = requests[index];
        require(thisRequest.voters[msg.sender] == false);
        
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }
    
    function makePayment(uint index) public onlyAdmin{
        Request storage thisRequest = requests[index];
        require(thisRequest.completed == false);
        require(thisRequest.noOfVoters > noOfContributers/2);//2 can be also dynamic
        thisRequest.recipient.transfer(thisRequest.value);
        
        thisRequest.completed = true;
        
    }
    
}
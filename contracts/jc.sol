pragma solidity 0.4.25;


contract Judge {
  //contract created 
  //initialzing base, interval, owner.
    uint public base;
    uint public interval;
    address public owner;

    event IsCalled (address _from, uint _time, uint _penalty);

    struct Misbehavior {
        address subject; //subject who performed the misbehavior;
        address object;// peer who suffered from the misbehavior
        string res;
        string action;    //action (e.g., "read", "write", "execute") of the misbehavior
        string misbehavior;//misbehavior
        uint time;//time of the Misbehavior occured
        uint penalty;//penalty (number of minitues blocked);
    }
    // creating the list of Misbehavior.
    
    mapping (address => Misbehavior[]) public misbehaviorList;

    constructor(uint _base, uint _interval) public {// run only once when the contarct will created first time.
        base = _base;
        interval = _interval;
        owner = msg.sender;
    }
    
    //this function will judge the misbehavior of the object on any subject.and calculate the penalty.and  
    function misbehaviourJudge (address _subject, address _object, 
        string _res, string _action, string _misbehavior, uint _time) public returns (uint penalty) {
        uint length = misbehaviorList[_subject].length + 1;
        uint n = length/interval;
        penalty = base**n;
        misbehaviorList[_subject].push(Misbehavior(_subject, _object, _res, _action, _misbehavior, _time, penalty));
        IsCalled(msg.sender, _time, penalty);
    }
    
// this function have all the misbehavior which are added,.
    function getLatestMisbehavior(address _key) public constant returns (address _subject, address _object,
        string _res, string _action, string _misbehavior, uint _time) {
        uint latest = misbehaviorList[_key].length - 1;
        _subject = misbehaviorList[_key][latest].subject;
        _object = misbehaviorList[_key][latest].object;
        _res = misbehaviorList[_key][latest].res;
        _action = misbehaviorList[_key][latest].action;
        _misbehavior = misbehaviorList[_key][latest].misbehavior;
        _time = misbehaviorList[_key][latest].time;
    }
    
    //this function will executed when there is need to distroy the JC
    function selfDestruct() public {
        if (msg.sender == owner) {
            selfdestruct(this);
        }
    }
}
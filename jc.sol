pragma solidity 0.4.25;


contract Judge {
    uint public base;
    uint public interval;
    address public owner;

    event IsCalled (address _from, uint _time, uint _penalty);

    struct Misbehavior {
        address subject; //subject who performed the misbehavior;
        address object;
        string res;
        string action;
        string misbehavior;
        uint time;
        uint penalty;
    }
    
    mapping (address => Misbehavior[]) public misbehaviorList;

    constructor(uint _base, uint _interval) public {
        base = _base;
        interval = _interval;
        owner = msg.sender;
    }
    
    function misbehaviourJudge (address _subject, address _object, 
        string _res, string _action, string _misbehavior, uint _time) public returns (uint penalty) {
        uint length = misbehaviorList[_subject].length + 1;
        uint n = length/interval;
        penalty = base**n;
        misbehaviorList[_subject].push(Misbehavior(_subject, _object, _res, _action, _misbehavior, _time, penalty));
        IsCalled(msg.sender, _time, penalty);
    }

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
    
    function selfDestruct() public {
        if (msg.sender == owner) {
            selfdestruct(this);
        }
    }
}
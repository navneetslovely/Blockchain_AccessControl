pragma solidity 0.4.25;


contract AccessControlMethod {
    //contract is created
    // address holds 20 bytes value
    address public owner;     // initialize the owner with address datatype--> public. can be access from anywhere.
    address public subject;   //  initialize the subject with address datatype--> public. can be access from anywhere.
    address public object;    // initialize the object with address datatype ---> public .access from anywhere.
    Judge public jc;

    event ReturnAccessResult (       // contain the result of the access Control,
      // runs only when ethier access is granted or revoked
        address indexed _from,       // retrieve the address(_from)
        string _errmsg,              // string erorr msg
        bool _result,                // boolean value y/n(yes / no)
        uint _time,                  // time stamp
        uint _penalty                // how much penalty
    );

        //(struct) Defineing the structure of Misbehavior. or we can say that defining the body of the Misbehavior
    struct Misbehaviour {
        string res;                 // resource on which the misbehavior is conducted
        string action;              //action (e.g., "read", "write", "execute") of the misbehavior
        string misbehavior;         //misbehavior
        uint time;                  //time of the misbehavior occured
        uint penalty;               //penalty opposed to the subject (number of minutes blocked)
    }

//defining body of the BehaviorItem
    struct BehaviorItem {           //for one resource
        Misbehaviour[] mbs;         //misbehavior list of the subject on a particular resource
        uint timeofUnblock;         //time when the resource is unblocked (0 if unblocked; otherwise, blocked)
    }

//body of PolicyItem
    struct PolicyItem {             //for one (resource, action) pair;
        bool isValued;              //for duplicate Check
        string permission;          //permission: "allow" or "deny"
        uint minInterval;           //minimum allowable interval (in seconds) between two successive requests
        uint toLR;                  //Time of Last Request
        uint noFR;                  //Number of frequent  Requests in a short period of tim
        uint threshold;             //threshold on NoFR, above which a misbehavior is suspected
        bool result;                //last access result
        uint8 err;                  //last err code
    }

        /* mapping is the key value pair data structure.which can be virtually initialized
        such a way that every key is pointed (mapped) toword the value */
    mapping (bytes32 => mapping(bytes32 => PolicyItem)) policies;
    //mapping (resource, action) =>PolicyCriteria for policy check
    mapping (bytes32 => BehaviorItem) behaviors;
    //mapping resource => BehaviorCriteria for behavior check

/*constructor runs only once when the contract is created */
    constructor(address _subject) public {          // user define constructor
        owner = msg.sender;// getting the address of owner(who first run deploy contract on blockchain)
        object = msg.sender;// getting the address of the object
        subject = _subject; // defining the public subject to the local subject(_subject)
    }

            /*convert string into bytes32. string uses large amount of gas and bytes32 use less amount gas.
            bytes32 is fixed-size byte-array. and its fits in a single word.
            string is dynamic sized type.*/
    function stringToBytes32(string _str) public constant returns (bytes32) { //type conversion string to bytes32
        bytes memory tempBytes = bytes(_str);
        bytes32 convertedBytes;
        if (0 == tempBytes.lenght) {
            return 0x0;
        }
        /*line assembly is way to write thw assembly language in solidity.
        for more on this :https://ethereum.stackexchange.com/question/9142/   */
        assembly {
            convertedBytes := mload(add(_str, 32))
            // mload is assembly language command to load the instruction into machine.
        }
        return convertedBytes;
    }

    function setJC(address _jc) public {
        if (owner == msg.sender) {
            jc = Judge(_jc);
        }  else
            revert();
    }

    function policyAdd(string _resource, string _action,
        string _permission, uint _minInterval, uint _thershold) public {
        bytes32 resource = stringToBytes32(_resource);
        bytes32 action = stringToBytes32(_action);
        if (msg.sender == owner) {
            if (policies[resource][action].isValued) revert();
            else {
                policies[resource][action].permission = _permission;
                policies[resource][action].minInterval = _minInterval;
                policies[resource][action].thershold = _thershold;
                policies[resource][action].toLR = 0;
                policies[resource][action].noFR = 0;
                policies[resource][action].isValued = true;
                policies[resource][action].result = false;
                behaviors[resource].timeofUnblock = 0;
            }
        }else
            revert();

    }

    function getPolicy(string _resource, string _action) public constant returns (string _permission,
        uint _minInterval,
        uint _thershold, uint _toLR,
        uint _noFR,
        bool _res,
        uint8 _errcode) {
        bytes32 resource = stringToBytes32(_resource);
        bytes32 action = stringToBytes32(_action);
        if (policies[resource][action].isValued) {
            _permission = policies[resource][action].permission;
            _minInterval = policies[resource][action].minInterval;
            _threshold = policies[resource][action].threshold;
            _noFR = policies[resource][action].noFR;
            _toLR = policies[resource][action].toLR;
            _res = policies[resource][action].result;
            _errcode = policies[resource][action].err;

        }        else
            revert();
    }

    function policyUpdate(string _resource, string _action, string _newPermission) public {
        bytes32 resource = stringToBytes32(_resource);
        bytes32 action = stringToBytes32(_action);
        if (policies[resource][action].isValued) {
            policies[resource][action].permission = _newPermission;
        }else
            revert();
    }

    function minIntervalUdate(string _resourse, string _action, uint _newMinInterval) public {
        bytes32 resource = stringToBytes32(_resourse);
        bytes32 action = stringToBytes32(_action);
        if (policies[resource][action].isValued) {
            policies[resource][action].minInterval = _newMinInterval;
        }else
            revert();
    }

    function thresholdUpdate(string _resource, string _action, uint _newThreshold) public {
        bytes32 resource = stringToBytes32(_resource);
        bytes32 action = stringToBytes32(_action);
        if (policies[resource][action].isValued) {
            policies[resource][action].threshold = _newThreshold;
        }        else
            revert();
    }

    function policyDelete(string _resource, string _action) public {
        bytes32 resource = stringToBytes32(_resource);
        bytes32 action = stringToBytes32(_action);
        if (msg.sender == owner) {
            if (policies[resource][action].isValued) {
                delete policies[resource][action];
            }else
                revert();
        }else
            revert();
    }

    function accessControl(string _resource, string _action, uint _time) public {
        bool policycheck = false;
        bool behaviorcheck = true;
        uint8 errcode = 0;
        uint penalty = 0;
        if (msg.sender == subject) {
            bytes32 resource = stringToBytes32(_resource);
            bytes32 action = stringToBytes32(_action);
            if (behaviors[resource].TimeofUnblock >= _time) {//still blocked state
                errcode = 1; //"Requests are blocked!"
            }   else {//unblocked state
                if (behaviors[resource].TimeofUnblock > 0) {
                    behaviors[resource].TimeofUnblock = 0;
                    policies[resource][action].NoFR = 0;
                    policies[resource][action].ToLR = 0;
                }//policy check
                if (keccak256("allow") == keccak256(policies[resource][action].permission)) {
                    policycheck = true;
                } else {
                    policycheck = false;
                }//behavior check
                if (_time - policies[resource][action].ToLR <= policies[resource][action].minInterval) {
                    policies[resource][action].NoFR++;
                    if (policies[resource][action].NoFR >= policies[resource][action].threshold) {
                        penalty = jc.misbehaviorJudge(subject, object, _resource, _action,
                        "Too frequent access!", _time);
                        behaviorcheck = false;
                        behaviors[resource].TimeofUnblock = _time + penalty * 1 minutes;
                        behaviors[resource].mbs.push(Misbehavior(_resource, _action,
                            "Too frequent access!", _time, penalty));//problem occurs when using array
                    }
                }  else {
                    policies[resource][action].NoFR = 0;
                }
                if (!policycheck && behaviorcheck) errcode = 2; //"Static Check failed!"
                if (policycheck && !behaviorcheck) errcode = 3; //"Misbehavior detected!"
                if (!policycheck && !behaviorcheck) errcode = 4; //"Static check failed! & Misbehavior detected!";
            }
            policies[resource][action].ToLR = _time;
        } else {
            errcode = 5; //"Wrong object or subject detected!";
        }
        policies[resource][action].result = policycheck && behaviorcheck;
        policies[resource][action].err = errcode;
        if (0 == errcode) ReturnAccessResult(msg.sender, "Access authorized!", true, _time, penalty);
        if (1 == errcode) ReturnAccessResult(msg.sender, "Requests are blocked!", false, _time, penalty);
        if (2 == errcode) ReturnAccessResult(msg.sender, "Static Check failed!", false, _time, penalty);
        if (3 == errcode) ReturnAccessResult(msg.sender, "Misbehavior detected!", false, _time, penalty);
        if (4 == errcode) ReturnAccessResult(msg.sender, "Static check failed! & Misbehavior detected!",
        false, _time, penalty);
        if (5 == errcode) ReturnAccessResult(msg.sender, "Wrong object or subject specified!", false, _time, enalty);
    }

    function getTimeofUnblock(string _resource) public constant returns (uint _penalty, uint _timeOfUnblock) {
        bytes32 resource= stringToBytes32(_resource);
        _timeOfUnblock = behaviors[resource].TimeofUnblock;
        uint li = behaviors[resource].mbs.lengthl;
        _penalty = behaviors[resource].mbs[li - 1].penalty;
    }

    function deleteACC() public {
        if (msg.sender == owner) {
            selfdestruct(this);
        }
    }
}


contract Judge {
    function misbehaviorJudge(address _subject,
        address _object,
        string _res, string _action,
        string misbehavior, uint _time) public returns (uint );
}

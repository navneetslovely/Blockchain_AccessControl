pragma solidity 0.4.25;


contract Register {
  
    struct Method {
        string scName;
        address subject;
        address object;
        address creator;
        address scAddress;
        bytes abi;
    }
    
    mapping (bytes32=> Method) public lookupTable;
  
    function stringToBytes32(string _str) public view returns (bytes32) {
        bytes memory tempBytes = bytes(_str);
        bytes32 convertedBytes;
        if (0 == tempBytes.length) {
            return 0x0;
        }
        assembly {
            convertedBytes := mload(add(_str, 32))
        }
        return convertedBytes;
    }
    
    function methodRegister(string _methodName, string _scname, address _subject, 
        address _object, address _creator, address _scAddress, bytes _abi) public {
        bytes32 newKey = stringToBytes32(_methodName);
        lookupTable[newKey].scName = _scname;
        lookupTable[newKey].subject = _subject;
        lookupTable[newKey].object = _object;
        lookupTable[newKey].creator = _creator;
        lookupTable[newKey].scAddress = _scAddress;
        lookupTable[newKey].abi = _abi; 
    }
    
    function methodScNameUpdate(string _methodName, string _scName) public {
        bytes32 key = stringToBytes32(_methodName);
        lookupTable[key].scName = _scName;
    }
    
    function methodAcAddressUpdate(string _methodName, address _scAddress) public {
        bytes32 key = stringToBytes32(_methodName);
        lookupTable[key].scAddress = _scAddress;
    }
    
    function methodAbiUpdate(string _methodName, bytes _abi) public {
        bytes32 key = stringToBytes32(_methodName);
        lookupTable[key].abi = _abi;
    }
    
    function methodNameUpdate(string _oldName, string _newName) public {
        bytes32 oldKey = stringToBytes32(_oldName);
        bytes32 newKey = stringToBytes32(_newName);
        lookupTable[newKey].scName = lookupTable[oldKey].scName;
        lookupTable[newKey].subject = lookupTable[oldKey].subject;
        lookupTable[newKey].object = lookupTable[oldKey].object;
        lookupTable[newKey].creator = lookupTable[oldKey].creator;
        lookupTable[newKey].scAddress = lookupTable[oldKey].scAddress;
        lookupTable[newKey].abi = lookupTable[oldKey].abi;
        delete lookupTable[oldKey];
    }
    
    function methodDelete(string _name) public {
        delete lookupTable[stringToBytes32(_name)];
    }
  
    function getContractAddr(string _methodName) public constant returns (address _scAddress) {
        bytes32 key = stringToBytes32(_methodName);
        _scAddress = lookupTable[key].scAddress;
    }
  
    function getContractAbi(string _methodName) public constant returns (bytes _abi) {
        bytes32 key = stringToBytes32(_methodName);
        _abi = lookupTable[key].abi;
    }
}
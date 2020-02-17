pragma solidity >=0.5.0 < 0.6.0;

import "./Ownable.sol";

contract CertVerify is Ownable {
    
    uint public maxAdmins;
    uint public adminIndex;
    uint public studentIndex;
    
    //require(maxAdmins <= 2, "Not more than 2");
    //assignmentStatus public status = assignmentStatus.Inactive;
    
    enum assignmentStatus { 
        Inactive,
        Pending,
        Completed
    }
    
    enum grades { 
        Good, 
        Great, 
        Outstanding, 
        Epic, 
        Legendary
    }
    
    struct Admin {
        bool authorized;
        uint Id;
    }
    
    struct Assignment {
        string link;
        bytes32 assignmentStatus;
    }
    
    struct Student {
        bytes32 firstName;
        bytes32 lastName;
        bytes32 commendation;
        bytes32 grades;
        uint16 assignmentIndex;
        bool active;
        string email;
        uint16 assignments;
    }
    
    mapping(address => Admin) public admins;
    mapping(uint => address) public adminsReverseMapping;
    mapping(uint => Student) public students;
    mapping(string => uint) public studentsReverseMapping;
    
    modifier onlyAdmins() {
        require(admins[msg.sender].authorized = true, "Only admins allowed");
        _;
    }
    
    modifier onlyNonOwnerAdmins(address _addr) {
        require(_addr != owner(), "only none-owner admin");
        _;
    }
    
    modifier onlyPermissibleAdminLimit() {
        require(adminIndex <= 1, "Maximum admins already");
        _;
    }
    
    //modifier onlyNonExistentStudents(string memory _email) {
   //     require(studentsReverseMapping[_email] != students[Student].email, "Email already exists");
   //     _;
   // }
   
   // modifier onlyValidStudents(string memory _email)  {
   //     require(studentsReverseMapping[_email] = true, "Email does not exist");
   //     _;
   // }
    
    constructor() public {
        maxAdmins = 2;
        _addAdmin(msg.sender);
    }
    
    function addAdmin(address _newAdmin) public onlyOwner onlyPermissibleAdminLimit {
        _addAdmin(_newAdmin);
    } 
    
    function _addAdmin(address _newAdmin) internal returns(string memory){
        Admin memory admin = admins[_newAdmin];
        if (admins[_newAdmin].authorized) {
            return "Already an admin";
        } else {
            admin.authorized = true;
        }
        adminsReverseMapping[adminIndex] = _newAdmin;
        adminIndex++;                                                                                             //safemath was not used
        //emit AdminAdded(address _newAdmin);
    }
    
    function removeAdmin(address _admin) public onlyOwner {
        require(_admin != owner(), "Cannot remove owner");
        _removeAdmin(_admin);
    } 
    
    function _removeAdmin(address _admin) public returns (string memory) {
        require(_admin != owner(), "Cannot remove owner");
        if (adminIndex < 2) {
            return "Cannot operate without admin";
        }
        if (admins[_admin].authorized = false) {
            return "Not an admin";
        } else {
            delete admins[_admin].Id;
        }
        adminIndex -= 1;
    }

}

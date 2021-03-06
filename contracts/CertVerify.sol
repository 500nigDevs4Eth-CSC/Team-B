pragma solidity ^0.5.0;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./SafeMath16.sol";

contract CertVerify is Ownable {
   
    using SafeMath for uint;
    using SafeMath16 for uint16;
    
    uint public maxAdmins;
    uint public adminIndex = 0;
    uint public studentIndex = 0;
    
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
    
    // Structs
    struct Admin {
        bool authorized;
        uint256 Id;
    }

    struct Assignment {
        string link;
        assignmentStatus status;
    }
    
    struct Student {
        bytes32 firstName;
        bytes32 lastName;
        bytes32 commendation;
        grades grade;
        uint16 assignmentIndex;
        bool active;
        string email;
        mapping(uint16 => Assignment) assignments;
    }

    // Mapping
    mapping(address => Admin) public admins;
    mapping(uint => address) public adminsReverseMapping;
    mapping(uint => Student) public students;
    mapping(string => uint) public studentsReverseMapping;

    // Events

    // AdminAdded Event
    event AdminAdded(address _newAdmin, uint indexed _maxAdminNum);
    // AdminRemoved Event
    event AdminRemoved(address _newAdmin, uint indexed adminIndex);
    // AdminLimitChanged Event
    event AdminLimitChanged(uint _newAdminLimit);
    // StudentAdded Event
    event StudentAdded(bytes32 _firstName, bytes32 _lastName, bytes32 _commendation, grades _grade, string _email);
    // StudentRemoved Event
    event StudentRemoved(string _email);
    // StudentNameUpdated Event
    event StudentNameUpdated(string _email, bytes32 _newFirstName, bytes32 _newLastName);
    // StudentCommendationUpdated Event
    event StudentCommendationUpdated(string _email, bytes32 _newCommendation);
    // StudentGradeUpdated Event
    event StudentGradeUpdated(string _email, grades _studentGrade);
    // StudentEmailUpdated Event
    event StudentEmailUpdated(string _oldEmail, string _newEmail);
    // AssignmentAdded Event
    event AssignmentAdded(string _email, string _assignmentLink, assignmentStatus _status, uint16 _assignmentIndex);
    // AssignmentUpdated Event
    event AssignmentUpdated(string _studentEmail, uint indexed _assignmentIndex, assignmentStatus _status);
    // OwnershipTransferred Event
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    // EtherDonated Event
    event EtherDonated(address indexed _addr, uint _value);
    // EtherWithdrawn Event
    event EtherWithdrawn(address indexed _addr, uint _value);

    // Modifiers
    // onlyAdmins Modifier
    modifier onlyAdmins() {
        require(admins[msg.sender].authorized = true, "Only admins allowed");
        _;
    }
    
    // onlyNonOwnerAdmins Modifier
    modifier onlyNonOwnerAdmins(address _addr) {
        require(admins[_addr].authorized = true, "Only admins allowed");
        require(_addr != owner(), "Only non-owner admin");
        _;
    }
    
    // onlyPermissibleAdminLimit Modifier
    modifier onlyPermissibleAdminLimit() {
        require(adminIndex <= maxAdmins, "Maximum admins already");
        _;
    }
    
    // onlyNonExistentStudents Modifier
    modifier onlyNonExistentStudents(string memory _email) {
        require(
            keccak256(
                abi.encodePacked(students[studentsReverseMapping[_email]].email)
            ) !=
                keccak256(abi.encodePacked(_email)),
            "Email already exist"
        );
        _;
    }
    
    // onlyValidStudents Modifier
    modifier onlyValidStudents(string memory _email) {
        require(
            keccak256(
                abi.encodePacked(students[studentsReverseMapping[_email]].email)
            ) ==
                keccak256(abi.encodePacked(_email)),
            "Email does not exist"
        );
        _;
    }

    // Constructor
    constructor() public {
        maxAdmins = 2;
        _addAdmin(msg.sender);
    }

    // Functions
    function addAdmin(
        address _newAdmin
        ) public onlyOwner onlyPermissibleAdminLimit
    {
        _addAdmin(_newAdmin);
    }

    function _addAdmin(
        address _newAdmin
        ) internal 
    {
        if(admins[_newAdmin].authorized == true) {
        } 
        else {
        admins[_newAdmin].authorized = true;
        } 
        Admin memory admin = admins[_newAdmin];
        admins[_newAdmin] = admin;
        adminsReverseMapping[adminIndex] = _newAdmin;
        adminIndex = adminIndex.add(1);
        // Trigger AdminAdded
        emit AdminAdded(_newAdmin, adminIndex);
    }

    function removeAdmin(
        address _admin
        ) public onlyOwner 
    {
        require(_admin != owner(), "Cannot remove owner");
        _removeAdmin(_admin);
    }

    function _removeAdmin(
        address _admin
        ) internal
    {
        require(adminIndex > 1, "Cannot operate without admin");
        if(admins[_admin].authorized == true){}
        adminsReverseMapping[adminIndex] = _admin;
        delete admins[_admin];
        adminIndex = adminIndex.sub(1);
        // Trigger AdminRemoved
        emit AdminRemoved(_admin, adminIndex);
    }

    function addStudent(
        bytes32 _firstName,
        bytes32 _lastName,
        bytes32 _commendation,
        grades _grade,
        string memory _email
        ) public onlyAdmins onlyNonExistentStudents(_email) 
    {
        Student storage student = students[studentIndex];
        student.assignmentIndex = 0;
        student.active = true;
        student.firstName = _firstName;
        student.lastName = _lastName;
        student.commendation = _commendation;
        student.grade = _grade;
        student.email = _email;
        studentsReverseMapping[_email] = studentIndex;
        studentIndex = studentIndex.add(1); 
        // Trigger StudentAdded
        emit StudentAdded(_firstName, _lastName, _commendation, _grade, _email);
    }

    function removeStudent(
        string memory _email
        ) public onlyAdmins onlyValidStudents(_email)
    {
        students[studentsReverseMapping[_email]].active = false;
        // Trigger StudentRemoved            
        emit StudentRemoved(_email);
    } 
    
    function changeAdminLimit(
        uint _newAdminLimit
        ) public 
    {
        require(_newAdminLimit > 1 && _newAdminLimit > adminIndex, "Cannot have lesser admins");
        maxAdmins = _newAdminLimit; 
        // Trigger AdminLimitChanged  
        emit AdminLimitChanged(maxAdmins);                
    }

    function changeStudentName(
        string memory _email, 
        bytes32 _newFirstName, 
        bytes32 _newLastName
        ) public onlyAdmins onlyValidStudents(_email)
    {
        students[studentsReverseMapping[_email]].firstName = _newFirstName;
        students[studentsReverseMapping[_email]].lastName = _newLastName; 
        // Trigger StudentNameUpdated  
        emit StudentNameUpdated(_email, _newFirstName, _newLastName);
    }

    function changeStudentCommendation(
        string memory _email, 
        bytes32 _newCommendation 
        ) public onlyAdmins onlyValidStudents(_email)
    {
        students[studentsReverseMapping[_email]].commendation = _newCommendation;
        // Trigger StudentCommendationUpdated
        emit StudentCommendationUpdated(_email, _newCommendation);
    }
    
    function changeStudentGrade(
        string memory _email, 
        grades _grade 
        ) public onlyAdmins onlyValidStudents(_email) 
    {
        students[studentsReverseMapping[_email]].grade = _grade;
        // Trigger StudentGradeUpdated
        emit StudentGradeUpdated(_email, _grade);

    }

    function changeStudentEmail(
        string memory _email, 
        string memory _newEmail
        ) public onlyAdmins onlyValidStudents(_email)
    {
        students[studentsReverseMapping[_email]].email = _newEmail;
        // Trigger StudentEmailUpdated
        emit StudentEmailUpdated(_email, _newEmail);
    }

    function transferOwnership(
        address _newOwner
        ) public onlyOwner 
    {
        _removeAdmin(msg.sender);
        _addAdmin(_newOwner);
        super.transferOwnership(_newOwner);
        // Trigger OwnershipTransferred
        emit OwnershipTransferred(msg.sender, _newOwner);

    }

    function renounceOwnership(
        ) public onlyOwner
    {
        _removeAdmin(msg.sender);
        super.renounceOwnership();
        // Trigger OwnershipTransferred
        emit OwnershipTransferred(msg.sender, address(0));
    }

    function _calcAndFetchAssignmentIndex(
        Student storage _student, 
        bool _isFinalProject
        ) internal returns(uint16 assignmentIndex) 
    {
        if (_isFinalProject == true) {
            return _student.assignmentIndex = 0;
        } else {
            return _student.assignmentIndex.add(1);
        } 
    }
    
    function addAssignment(
        string memory _email, 
        string memory _assignmentLink, 
        assignmentStatus _assignmentStatus, 
        bool _isFinalProject
        ) public onlyAdmins onlyValidStudents(_email) 
    {
        _calcAndFetchAssignmentIndex(students[studentsReverseMapping[_email]], _isFinalProject);
        students[studentsReverseMapping[_email]].assignments[students[studentsReverseMapping[_email]].assignmentIndex].link = _assignmentLink;
        students[studentsReverseMapping[_email]].assignments[students[studentsReverseMapping[_email]].assignmentIndex].status = _assignmentStatus;
        // Trigger AssignmentAdded
        emit AssignmentAdded(_email, _assignmentLink, _assignmentStatus, 
            _calcAndFetchAssignmentIndex(students[studentsReverseMapping[_email]], _isFinalProject));
    }
    
    function updateAssignmentStatus(
        string memory _email, 
        assignmentStatus _assignmentStatus, 
        bool _isFinalProject
        )public onlyAdmins onlyValidStudents(_email)
    {
        _calcAndFetchAssignmentIndex(students[studentsReverseMapping[_email]], _isFinalProject);
        students[studentsReverseMapping[_email]].assignments[students[studentsReverseMapping[_email]].assignmentIndex].status = _assignmentStatus;
        // Trigger AssignmentUpdated
        emit AssignmentUpdated(_email, _calcAndFetchAssignmentIndex(students[studentIndex], 
            _isFinalProject), _assignmentStatus);
    }
    
    function getAssignmentInfo (
        string memory _email, 
        uint16 _assignmentIndex
        ) public view onlyValidStudents(_email) returns(string memory assignmentLink, assignmentStatus status) 
    {
        require(students[studentsReverseMapping[_email]].assignmentIndex >= 0, 'Cannot be less than 0');
        require(_assignmentIndex <= students[studentsReverseMapping[_email]].assignmentIndex, 'Cannot be more than permissible limit');
        return(students[studentsReverseMapping[_email]].assignments[_assignmentIndex].link, 
            students[studentsReverseMapping[_email]].assignments[_assignmentIndex].status);
    }
    
    function donateEth(
        ) external payable 
    {
        if(msg.value < 0.005 ether) {
            revert('Cannot donate less than 0.005 ether');
        }
	// Trigger EtherDonated
        emit EtherDonated(address(this), msg.value);
    }
    
    function withdrawEth(
        ) public payable onlyOwner returns (bool success)
    {
        address payable _owner;
        uint bal;
        _owner = address(uint(owner()));
        bal = address(this).balance;
        _owner.transfer(bal);
	// Trigger EtherWithdrawn
        emit EtherWithdrawn(msg.sender, bal);
        return true;
    }
    
}
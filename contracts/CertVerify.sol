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
    
    struct Admin {
        bool authorized;
        uint Id;
    }

    struct Assignment {
        string link;
<<<<<<< HEAD
        assignmentStatus _assignmentStatus;
=======
        assignmentStatus status;
>>>>>>> 3bbeff810d3367e92b167e8eea7ce00f20477ef8
    }

    struct Student {
        bytes32 firstName;
        bytes32 lastName;
        bytes32 commendation;
        grades grade;
        uint16 assignmentIndex;
        bool active;
        string email;
<<<<<<< HEAD
        mapping(assignmentIndex => Assignment) assignments;
=======
        mapping(uint => Assignment) assignments;
>>>>>>> 3bbeff810d3367e92b167e8eea7ce00f20477ef8
    }

    mapping(address => Admin) public admins;
    mapping(uint256 => address) public adminsReverseMapping;
    mapping(uint256 => Student) public students;
    mapping(string => uint256) public studentsReverseMapping;

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
    
    event AdminAdded(address _newAdmin, uint indexed _maxAdminNum);
    event AdminRemoved(address _newAdmin, uint indexed adminIndex);
    event AdminLimitChanged(uint _newAdminLimit);
<<<<<<< HEAD
    event addStudent(string _email, bytes32 _firstName, bytes32 _lastName, bytes32 _commendation, grades _grades)
=======
    event StudentAdded(bytes32 _firstName, bytes32 _lastName, bytes32 _commendation, grades _grade, string _email);
>>>>>>> 3bbeff810d3367e92b167e8eea7ce00f20477ef8
    event StudentRemoved(string _email);
    event StudentNameUpdated(string _email, bytes32 _newFirstName, bytes32 _newLastName);
    event StudentCommendationUpdated(string _email, bytes32 _newCommendation);
    event StudentGradeUpdated(string _email, grades _studentGrade);
    event StudentEmailUpdated(string _oldEmail, string _newEmail);
    event AssignmentAdded(string _email, string _assignmentLink, assignmentStatus _status, uint16 _assignmentIndex);
    event AssignmentUpdated(string _studentEmail, uint indexed _assignmentIndex, string _status);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        maxAdmins = 2;
        _addAdmin(msg.sender);
    }

    function addAdmin(
        address _newAdmin
        ) public onlyOwner onlyPermissibleAdminLimit
    {
        _addAdmin(_newAdmin);
    }

    function _addAdmin(
        address _newAdmin
        ) internal returns (string memory) 
    {
        Admin memory admin = admins[_newAdmin];
        require(admins[_newAdmin].authorized = false, "Already an admin");
        admins[_newAdmin] = admin;
        adminsReverseMapping[adminIndex] = _newAdmin;
        adminIndex = adminIndex.add(1);
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
        ) internal returns (string memory) 
    {
        require(_admin != owner(), "Cannot remove owner");
        require(adminIndex > 1, "Cannot operate without admin");
        require(admins[_admin].authorized = true, "Not an admin");
        delete admins[_admin].Id;
        adminIndex = adminIndex.sub(1);
        emit AdminRemoved(_admin, adminIndex);
    }

    function addStudent(
        bytes32 _firstName,
        bytes32 _lastName,
        bytes32 _commendation,
<<<<<<< HEAD
        grades _grades,
=======
        grades _grade,
>>>>>>> 3bbeff810d3367e92b167e8eea7ce00f20477ef8
        string memory _email
        ) public onlyAdmins onlyNonExistentStudents(_email) 
    {
        Student memory student = students[studentIndex];
        student.firstName = _firstName;
        student.lastName = _lastName;
        student.commendation = _commendation;
        student.grade = _grade;
        student.email = _email;
        student.assignmentIndex = 0;
        student.active = true;
        studentsReverseMapping[_email] = studentIndex;
        studentIndex = studentIndex.add(1);
<<<<<<< HEAD
        emit addStudent(_firstName, _lastName, _commendation, _grades, _email);
        //emit StudentAdded
=======
        emit StudentAdded(_firstName, _lastName, _commendation, _grade, _email);
>>>>>>> 3bbeff810d3367e92b167e8eea7ce00f20477ef8
    }

    function removeStudent(
        string memory _email
        ) public onlyAdmins onlyValidStudents(_email)
    {
        Student memory student = students[studentIndex];
        studentsReverseMapping[_email] = studentIndex;
        student.active = false;
        studentIndex = studentIndex.sub(1);                           
        emit StudentRemoved(_email);
    }
    
    function changeAdminLimit(
        uint _newAdminLimit
        ) public 
    {
        require(_newAdminLimit > 1 && _newAdminLimit > adminIndex, "Cannot have lesser admins");
        maxAdmins = maxAdmins.add(_newAdminLimit); 
        emit AdminLimitChanged(maxAdmins);                
    }

    function changeStudentName(
        string memory _email, 
        bytes32 _newFirstName, 
        bytes32 _newLastName
        ) public onlyAdmins onlyValidStudents(_email)
    {
        studentsReverseMapping[_email] = studentIndex;
        Student memory student = students[studentIndex];
        student.firstName = _newFirstName;
        student.lastName = _newLastName; 
        emit StudentNameUpdated(_email, _newFirstName, _newLastName);
    }
    
    function changeStudentCommendation(
        string memory _email, 
        bytes32 _newCommendation 
        ) public onlyAdmins onlyValidStudents(_email)
    {
        studentsReverseMapping[_email] = studentIndex;
        Student memory student = students[studentIndex];
        student.commendation = _newCommendation;
        emit StudentCommendationUpdated(_email, _newCommendation);
    }
    
    function changeStudentGrade(
        string memory _email, 
        grades _grade 
        ) public onlyAdmins onlyValidStudents(_email) 
    {
        studentsReverseMapping[_email] = studentIndex;
        Student memory student = students[studentIndex];
        student.grade = _grade;
        emit StudentGradeUpdated(_email, _grade);

    }

    function changeStudentEmail(
        string memory _email, 
        string memory _newEmail
        ) public onlyAdmins onlyValidStudents(_email)
    {
        studentsReverseMapping[_email] = studentIndex;
        Student memory student = students[studentIndex];
        student.email = _newEmail;
        emit StudentEmailUpdated(_email, _newEmail);
    }

    function transferOwnership(address _newOwner) public onlyAdmins {
        removeAdmin(msg.sender);
        addAdmin(_newOwner);
        transferOwnership(_newOwner);
        emit OwnershipTransferred(msg.sender, _newOwner);

    }

    function renounceOwnership() public onlyAdmins{
        removeAdmin(msg.sender);
        renounceOwnership();
        //emit AdminRemoved(_newAdmin, _maxAdminNum);
    }

    function _calcAndFetchAssignmentIndex(
        Student storage _student, 
        bool _isFinalProject
        ) internal pure returns(uint16 assignmentIndex) 
    {
        Student memory student;
        if (_isFinalProject == true) {
            return student.assignmentIndex = 0;
        } else {
            return student.assignmentIndex.add(1);
        } 
    }
    
    function addAssignment(
        string memory _email, 
        string memory _assignmentLink, 
        assignmentStatus _status, 
        bool _isFinalProject
        ) public onlyAdmins onlyValidStudents(_email) 
    {
        studentsReverseMapping[_email] = studentIndex;
        _calcAndFetchAssignmentIndex(students[studentIndex], _isFinalProject);
        Assignment memory assignment;
        assignment.link = _assignmentLink;
        assignment.status =  _status;
        emit AssignmentAdded(_email, _assignmentLink, _status, _calcAndFetchAssignmentIndex(students[studentIndex], _isFinalProject));
        
    }

    function updateAssignmentStatus(
        string memory _email, 
        assignmentStatus _assignmentStatus, 
        bool isFinalProject
        )public onlyAdmins onlyValidStudents(_email)
    {
        studentsReverseMapping[_email] = studentIndex;
        Student memory student = students[studentIndex];
        _calcAndFetchAssignmentIndex(student, isFinalProject);

        Assignment._assignmentStatus = _assignmentStatus;
        emit AssignmentUpdated(_email, _assignmentIndex, _assignmentStatus);

    }

    function getAssignmentInfo (
        string memory _email, 
        uint16 _assignmentIndex
        ) public onlyValidStudents(_email) returns(string memory, string memory) 
    {
        return _getAssignmentInfo;
    }
    
    function _getAssignmentInfo (
        string memory _email, 
        uint16 _assignmentIndex
        ) internal onlyValidStudents(_email) returns(string memory assignmentLink) 
    {
        studentsReverseMapping[_email] = studentIndex;
        Student memory student = students[studentIndex];
        Assignment memory assignment;
        student.email = _email;
        student.assignmentIndex = _assignmentIndex;
        require(_assignmentIndex >= 0, 'Cannot be less than 0');
        require(_assignmentIndex <= assignmentList.length, 'Cannot be more than permissible limit');
        return assignment.link;
        return assignment.status;
    }
}

// Mock user profile data
class UserProfile {
  String firstName;
  String lastName;
  DateTime dob;
  String gender;
  double height;
  double weight;
  String bloodGroup;
  String address;
  String pincode;
  String state;
  String district;

  UserProfile({
    this.firstName = 'Athlete',
    this.lastName = 'User',
    required this.dob,
    this.gender = 'Male',
    this.height = 175.0, // cm
    this.weight = 70.0,  // kg
    this.bloodGroup = 'A+',
    this.address = '123 Test St',
    this.pincode = '110001',
    this.state = 'Delhi',
    this.district = 'Central Delhi',
  });

  double get bmi => weight / ((height / 100) * (height / 100));
  int get age => DateTime.now().year - dob.year;
}

// Mock assessment result data
class AssessmentResult {
  final String testType;
  final int score;
  final DateTime date;

  AssessmentResult({
    required this.testType,
    required this.score,
    required this.date,
  });
}

// Global mock data storage
UserProfile mockUser = UserProfile(dob: DateTime(1995, 1, 1));

List<AssessmentResult> mockResults = [
  AssessmentResult(testType: 'Vertical Jump', score: 45, date: DateTime(2025, 9, 15)),
  AssessmentResult(testType: 'Vertical Jump', score: 48, date: DateTime(2025, 9, 17)),
  AssessmentResult(testType: 'Sit-ups', score: 55, date: DateTime(2025, 9, 16)),
];
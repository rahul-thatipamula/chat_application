class UserModel {
  final String? id;             // Unique identifier for the user
  final String email;          // User's email address
  final String username;       // User's display name
  final String mobileNumber;   // User's mobile number  // List of friends' user IDs

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.mobileNumber,
    
  });

  // Factory method to create a UserModel from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      mobileNumber: json['mobileNumber'], // Add mobile number from JSON
  
    );
  }

  // Method to convert UserModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'mobileNumber': mobileNumber, // Include mobile number in JSON
      
    };
  }
}

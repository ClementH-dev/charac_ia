class User {
  final String username;
  final String? password;
  final String email;
  final String firstname;
  final String lastname;

  User({
    required this.username,
    required this.password,
    required this.email,
    required this.firstname,
    required this.lastname,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      password: json['password'],
      email: json['email'],
      firstname: json['firstname'],
      lastname: json['lastname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "password": password,
      "email": email,
      "firstname": firstname,
      "lastname": lastname,
    };
  }
}

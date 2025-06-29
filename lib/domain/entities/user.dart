class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  // Método para crear una instancia de User desde un JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(), // Convertir a String
      firstName: json['first_name'], // Mapea 'nombres' a 'firstName'
      lastName: json['last_name'], // Mapea 'apellidos' a 'lastName'
      email: json['email'], // Mapea 'email' a 'email'
      phone: json['phone'], // Mapea 'email' a 'email'
    );
  }

  // Método para convertir una instancia de User a un JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
    };
  }
}
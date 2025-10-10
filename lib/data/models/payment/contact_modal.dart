class Contact {
  final String id;
  final String name;
  final String? phoneNumber;
  final String? email;
  final String? imageUrl;

  const Contact({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.email,
    this.imageUrl,
  });
}
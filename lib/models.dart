class Service {
  final int id;
  final int companyId;
  final String name;
  final String description;
  final double price;

  Service({
    required this.id,
    required this.companyId,
    required this.name,
    required this.description,
    required this.price,
  });

  factory Service.fromJson(Map<String, dynamic> j) => Service(
        id: j['id'],
        companyId: j['companyId'],
        name: j['name'],
        description: j['description'],
        price: (j['price'] as num).toDouble(),
      );
}

class Company {
  final int id;
  final String name;
  final String registrationNumber;
  final List<Service> services;

  Company({
    required this.id,
    required this.name,
    required this.registrationNumber,
    required this.services,
  });

  factory Company.fromJson(Map<String, dynamic> j) => Company(
        id: j['id'],
        name: j['name'],
        registrationNumber: j['registrationNumber'],
        services: (j['services'] as List? ?? [])
            .map((s) => Service.fromJson(s))
            .toList(),
      );
}
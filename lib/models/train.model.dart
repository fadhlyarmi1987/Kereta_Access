class Train {
  final int id;
  final String code;
  final String name;
  final String serviceClass;
  final int carriageCount;

  Train({
    required this.id,
    required this.code,
    required this.name,
    required this.serviceClass,
    required this.carriageCount,
  });

  factory Train.fromJson(Map<String, dynamic> json) {
    return Train(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      serviceClass: json['service_class'],
      carriageCount: json['carriage_count'],
    );
  }
}

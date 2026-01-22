class CreateSubjectRequest {
  final String name;
  final String? description;

  CreateSubjectRequest({
    required this.name,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}

class UpdateSubjectRequest {
  final String name;
  final String? description;

  UpdateSubjectRequest({
    required this.name,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}

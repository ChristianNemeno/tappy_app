class CreateUnitRequest {
  final String title;
  final int orderIndex;
  final int courseId;

  CreateUnitRequest({
    required this.title,
    required this.orderIndex,
    required this.courseId,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'orderIndex': orderIndex,
      'courseId': courseId,
    };
  }
}

class UpdateUnitRequest {
  final String title;
  final int orderIndex;
  final int courseId;

  UpdateUnitRequest({
    required this.title,
    required this.orderIndex,
    required this.courseId,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'orderIndex': orderIndex,
      'courseId': courseId,
    };
  }
}

class ReorderUnitRequest {
  final int orderIndex;

  ReorderUnitRequest({required this.orderIndex});

  Map<String, dynamic> toJson() {
    return {
      'orderIndex': orderIndex,
    };
  }
}

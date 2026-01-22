class AssignQuizToUnitRequest {
  final int unitId;
  final int orderIndex;

  AssignQuizToUnitRequest({
    required this.unitId,
    required this.orderIndex,
  });

  Map<String, dynamic> toJson() {
    return {
      'unitId': unitId,
      'orderIndex': orderIndex,
    };
  }
}

class ReorderQuizRequest {
  final int orderIndex;

  ReorderQuizRequest({required this.orderIndex});

  Map<String, dynamic> toJson() {
    return {
      'orderIndex': orderIndex,
    };
  }
}

class StartQuizAttemptRequest {
  final int quizId;

  StartQuizAttemptRequest({required this.quizId});

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
    };
  }
}

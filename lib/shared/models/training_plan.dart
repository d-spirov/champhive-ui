int? jsonInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

class ExerciseImage {
  const ExerciseImage({
    required this.id,
    required this.exerciseId,
    required this.contentType,
    required this.sizeBytes,
    required this.position,
  });

  final String id;
  final String exerciseId;
  final String contentType;
  final int sizeBytes;
  final int position;

  factory ExerciseImage.fromJson(Map<String, dynamic> json) {
    return ExerciseImage(
      id: json['id']?.toString() ?? '',
      exerciseId: json['exerciseId']?.toString() ?? '',
      contentType: json['contentType'] as String? ?? 'image/jpeg',
      sizeBytes: jsonInt(json['sizeBytes']) ?? 0,
      position: jsonInt(json['position']) ?? 0,
    );
  }
}

class PlanExercise {
  const PlanExercise({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.position,
    required this.durationMinutes,
    this.purpose,
    this.description,
    this.videoUrl,
    this.repetitions,
    this.notes,
    this.images = const [],
  });

  final String id;
  final String exerciseId;
  final String exerciseName;
  final String? purpose;
  final String? description;
  final String? videoUrl;
  final int position;
  final int durationMinutes;
  final String? repetitions;
  final String? notes;
  final List<ExerciseImage> images;

  factory PlanExercise.fromJson(Map<String, dynamic> json) {
    final imagesRaw = json['images'];
    final images = <ExerciseImage>[];
    if (imagesRaw is List) {
      for (final item in imagesRaw) {
        if (item is Map) {
          images.add(ExerciseImage.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      images.sort((a, b) => a.position.compareTo(b.position));
    }
    return PlanExercise(
      id: json['id']?.toString() ?? '',
      exerciseId: json['exerciseId']?.toString() ?? '',
      exerciseName: json['exerciseName'] as String? ?? '',
      purpose: json['purpose'] as String?,
      description: json['description'] as String?,
      videoUrl: json['videoUrl'] as String?,
      position: jsonInt(json['position']) ?? 0,
      durationMinutes: jsonInt(json['durationMinutes']) ?? 0,
      repetitions: json['repetitions']?.toString(),
      notes: json['notes'] as String?,
      images: images,
    );
  }
}

class TrainingPlan {
  const TrainingPlan({
    required this.id,
    required this.clubId,
    required this.name,
    required this.durationMinutes,
    required this.totalExerciseMinutes,
    required this.authorUserId,
    this.sectionId,
    this.sectionName,
    this.teamId,
    this.teamName,
    this.description,
    this.exercises = const [],
    this.createdAtUtc,
    this.updatedAtUtc,
  });

  final String id;
  final String clubId;
  final String? sectionId;
  final String? sectionName;
  final String? teamId;
  final String? teamName;
  final String name;
  final String? description;
  final int durationMinutes;
  final int totalExerciseMinutes;
  final String authorUserId;
  final List<PlanExercise> exercises;
  final DateTime? createdAtUtc;
  final DateTime? updatedAtUtc;

  factory TrainingPlan.fromJson(Map<String, dynamic> json) {
    final exercisesRaw = json['exercises'];
    final exercises = <PlanExercise>[];
    if (exercisesRaw is List) {
      for (final item in exercisesRaw) {
        if (item is Map) {
          exercises.add(PlanExercise.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      exercises.sort((a, b) => a.position.compareTo(b.position));
    }
    return TrainingPlan(
      id: json['id']?.toString() ?? '',
      clubId: json['clubId']?.toString() ?? '',
      sectionId: json['sectionId']?.toString(),
      sectionName: json['sectionName'] as String?,
      teamId: json['teamId']?.toString(),
      teamName: json['teamName'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      durationMinutes: jsonInt(json['durationMinutes']) ?? 0,
      totalExerciseMinutes: jsonInt(json['totalExerciseMinutes']) ?? 0,
      authorUserId: json['authorUserId']?.toString() ?? '',
      exercises: exercises,
      createdAtUtc: DateTime.tryParse(json['createdAtUtc'] as String? ?? ''),
      updatedAtUtc: DateTime.tryParse(json['updatedAtUtc'] as String? ?? ''),
    );
  }
}

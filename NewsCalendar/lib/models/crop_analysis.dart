class CropAnalysis {
  final String id;
  final String? userId;
  final String imageName;
  final int? imageSize;
  final CropAnalysisContext? context;
  final CropAnalysisResult result;
  final String status; // 'pending', 'processing', 'completed', 'failed'
  final DateTime createdAt;
  final DateTime updatedAt;

  CropAnalysis({
    required this.id,
    this.userId,
    required this.imageName,
    this.imageSize,
    this.context,
    required this.result,
    this.status = 'processing',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'userId': userId,
      'imageName': imageName,
      'imageSize': imageSize,
      'context': context?.toJson(),
      'result': result.toJson(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CropAnalysis.fromJson(Map<String, dynamic> json) {
    try {
      return CropAnalysis(
        id: json['id'] ?? json['_id'] ?? '',
        userId: json['userId']?.toString(),
        imageName: json['imageName'] ?? '',
        imageSize: json['imageSize'] as int?,
        context: json['context'] != null
            ? CropAnalysisContext.fromJson(json['context'])
            : null,
        result: CropAnalysisResult.fromJson(json['result'] ?? {}),
        status: json['status'] ?? 'processing',
        createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
        updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.now(),
      );
    } catch (e) {
      throw FormatException('Failed to parse CropAnalysis: $e\nJSON: $json');
    }
  }

  static DateTime? _parseDateTime(dynamic date) {
    if (date is DateTime) return date;
    if (date == null) return null;

    try {
      if (date is String) {
        return DateTime.parse(date);
      }
      return null;
    } catch (e) {
      print('Failed to parse date: $date');
      return null;
    }
  }

  CropAnalysis copyWith({
    String? id,
    String? userId,
    String? imageName,
    int? imageSize,
    CropAnalysisContext? context,
    CropAnalysisResult? result,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CropAnalysis(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageName: imageName ?? this.imageName,
      imageSize: imageSize ?? this.imageSize,
      context: context ?? this.context,
      result: result ?? this.result,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CropAnalysis(id: $id, imageName: $imageName, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CropAnalysis && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class CropAnalysisContext {
  final String? imageType;
  final String? cropType;
  final String? observedProblem;
  final int? plantAge;
  final bool? recentWeatherEvent;

  CropAnalysisContext({
    this.imageType,
    this.cropType,
    this.observedProblem,
    this.plantAge,
    this.recentWeatherEvent,
  });

  Map<String, dynamic> toJson() {
    return {
      'imageType': imageType,
      'cropType': cropType,
      'observedProblem': observedProblem,
      'plantAge': plantAge,
      'recentWeatherEvent': recentWeatherEvent,
    };
  }

  factory CropAnalysisContext.fromJson(Map<String, dynamic> json) {
    return CropAnalysisContext(
      imageType: json['imageType'],
      cropType: json['cropType'],
      observedProblem: json['observedProblem'],
      plantAge: json['plantAge'] as int?,
      recentWeatherEvent: json['recentWeatherEvent'] as bool?,
    );
  }
}

class CropAnalysisResult {
  final bool success;
  final String diagnosis;
  final double confidence;
  final String disease;
  final String severity;
  final List<String> suggestions;
  final List<CropTreatment> treatment;
  final List<String> prevention;
  final List<String> references;
  final double? processingTime;
  final String? modelUsed;
  final String? errorMessage;

  CropAnalysisResult({
    required this.success,
    required this.diagnosis,
    required this.confidence,
    required this.disease,
    required this.severity,
    this.suggestions = const [],
    this.treatment = const [],
    this.prevention = const [],
    this.references = const [],
    this.processingTime,
    this.modelUsed,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'diagnosis': diagnosis,
      'confidence': confidence,
      'disease': disease,
      'severity': severity,
      'suggestions': suggestions,
      'treatment': treatment.map((t) => t.toJson()).toList(),
      'prevention': prevention,
      'references': references,
      'processingTime': processingTime,
      'modelUsed': modelUsed,
      'errorMessage': errorMessage,
    };
  }

  factory CropAnalysisResult.fromJson(Map<String, dynamic> json) {
    return CropAnalysisResult(
      success: json['success'] ?? false,
      diagnosis: json['diagnosis'] ?? '',
      confidence: (json['confidence'] is num)
          ? (json['confidence'] as num).toDouble()
          : 0.0,
      disease: json['disease'] ?? '',
      severity: json['severity'] ?? '',
      suggestions: json['suggestions'] is List
          ? List<String>.from(json['suggestions'])
          : [],
      treatment: json['treatment'] is List
          ? (json['treatment'] as List)
              .map((t) => CropTreatment.fromJson(t))
              .toList()
          : [],
      prevention: json['prevention'] is List
          ? List<String>.from(json['prevention'])
          : [],
      references: json['references'] is List
          ? List<String>.from(json['references'])
          : [],
      processingTime: json['processingTime'] != null
          ? (json['processingTime'] as num).toDouble()
          : null,
      modelUsed: json['modelUsed'],
      errorMessage: json['errorMessage'],
    );
  }
}

class CropTreatment {
  final String product;
  final String application;
  final String duration;

  CropTreatment({
    required this.product,
    required this.application,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'application': application,
      'duration': duration,
    };
  }

  factory CropTreatment.fromJson(Map<String, dynamic> json) {
    return CropTreatment(
      product: json['product'] ?? '',
      application: json['application'] ?? '',
      duration: json['duration'] ?? '',
    );
  }
}


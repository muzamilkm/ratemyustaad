class Teacher {
  final String id;
  final String name;
  final String department;
  final String institution;
  final String photoUrl;
  final double averageRating;
  final int reviewCount;
  final Map<String, dynamic> ratingBreakdown;
  final bool isVerified;

  Teacher({
    required this.id,
    required this.name,
    required this.department,
    required this.institution,
    this.photoUrl = '',
    this.averageRating = 0.0,
    this.reviewCount = 0,
    Map<String, dynamic>? ratingBreakdown,
    this.isVerified = false,
  }) : ratingBreakdown = ratingBreakdown ?? {
          'teaching': 0.0,
          'knowledge': 0.0,
          'approachability': 0.0,
          'grading': 0.0,
        };

  factory Teacher.fromMap(Map<String, dynamic> map, String documentId) {
    return Teacher(
      id: documentId,
      name: map['name'] ?? '',
      department: map['department'] ?? '',
      institution: map['institution'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      ratingBreakdown: Map<String, dynamic>.from(map['ratingBreakdown'] ?? {}),
      isVerified: map['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'department': department,
      'institution': institution,
      'photoUrl': photoUrl,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'ratingBreakdown': ratingBreakdown,
      'isVerified': isVerified,
    };
  }

  Teacher copyWith({
    String? name,
    String? department,
    String? institution,
    String? photoUrl,
    double? averageRating,
    int? reviewCount,
    Map<String, dynamic>? ratingBreakdown,
    bool? isVerified,
  }) {
    return Teacher(
      id: this.id,
      name: name ?? this.name,
      department: department ?? this.department,
      institution: institution ?? this.institution,
      photoUrl: photoUrl ?? this.photoUrl,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      ratingBreakdown: ratingBreakdown ?? this.ratingBreakdown,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
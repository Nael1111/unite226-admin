import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final DateTime createdAt;
  final bool writingEnabled;
  final int membersCount;
  final List<String> pinnedMessageIds;

  const Group({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.writingEnabled,
    required this.membersCount,
    required this.pinnedMessageIds,
  });

  factory Group.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Group(
      id: doc.id,
      name: d['name'] ?? '',
      description: d['description'] ?? '',
      createdBy: d['createdBy'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      writingEnabled: d['writingEnabled'] ?? true,
      membersCount: d['membersCount'] ?? 0,
      pinnedMessageIds: List<String>.from(d['pinnedMessageIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'createdBy': createdBy,
        'createdAt': FieldValue.serverTimestamp(),
        'writingEnabled': writingEnabled,
        'membersCount': membersCount,
        'pinnedMessageIds': pinnedMessageIds,
      };
}

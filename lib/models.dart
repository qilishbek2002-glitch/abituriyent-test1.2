import 'package:flutter/material.dart';

class Subject {
  final String id;
  final IconData icon;
  final Color color;
  const Subject(this.id, this.icon, this.color);
}

const List<Subject> kSubjects = [
  Subject('math', Icons.calculate, Color(0xFF3F51B5)),
  Subject('physics', Icons.bolt, Color(0xFFF57C00)),
  Subject('literature', Icons.menu_book, Color(0xFF8E24AA)),
  Subject('history', Icons.account_balance, Color(0xFF6D4C41)),
  Subject('biology', Icons.eco, Color(0xFF2E7D32)),
  Subject('chemistry', Icons.science, Color(0xFF00897B)),
  Subject('mothertongue', Icons.translate, Color(0xFFC62828)),
  Subject('informatics', Icons.computer, Color(0xFF1565C0)),
];

/// Test tuziladigan kitob (ilova ichidagi yoki foydalanuvchi yuklagan).
class Book {
  final String id;
  final String title;
  final String? assetPath;
  final String? filePath;
  final String? subjectId;
  const Book({
    required this.id,
    required this.title,
    this.assetPath,
    this.filePath,
    this.subjectId,
  });
}

/// Foydalanuvchi o'zi qo'shgan PDF.
/// [subjectId] null bo'lsa, "Shaxsiy kitob" bo'limiga tegishli;
/// aks holda shu fanning [kind] ('textbooks' yoki 'materials') bo'limiga.
class PersonalBook {
  final String id;
  final String title;
  final String path;
  final String? subjectId;
  final String? kind;
  const PersonalBook({
    required this.id,
    required this.title,
    required this.path,
    this.subjectId,
    this.kind,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'path': path,
        's': subjectId,
        'k': kind,
      };

  factory PersonalBook.fromJson(Map<String, dynamic> j) => PersonalBook(
        id: j['id'] as String,
        title: j['title'] as String,
        path: j['path'] as String,
        subjectId: j['s'] as String?,
        kind: j['k'] as String?,
      );
}

class Question {
  final String text;
  final List<String> options;
  final int answer;
  final String explanation;
  const Question({
    required this.text,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  Map<String, dynamic> toJson() =>
      {'q': text, 'o': options, 'a': answer, 'e': explanation};

  factory Question.fromJson(Map<String, dynamic> j) => Question(
        text: j['q'] as String,
        options: (j['o'] as List).map((e) => e.toString()).toList(),
        answer: j['a'] as int,
        explanation: (j['e'] ?? '') as String,
      );
}

class SavedTest {
  final String id;
  final String title;
  final int createdAt;
  final List<Question> questions;
  int bestPercent;
  int attempts;

  SavedTest({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.questions,
    this.bestPercent = 0,
    this.attempts = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        't': createdAt,
        'qs': questions.map((q) => q.toJson()).toList(),
        'b': bestPercent,
        'n': attempts,
      };

  factory SavedTest.fromJson(Map<String, dynamic> j) => SavedTest(
        id: j['id'] as String,
        title: j['title'] as String,
        createdAt: j['t'] as int,
        questions: (j['qs'] as List)
            .map((e) => Question.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        bestPercent: (j['b'] ?? 0) as int,
        attempts: (j['n'] ?? 0) as int,
      );
}

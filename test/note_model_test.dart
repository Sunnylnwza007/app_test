import 'package:flutter_test/flutter_test.dart';
import 'package:app_test/models/note.dart';
import 'package:app_test/services/notes_service.dart';
import 'package:app_test/utils/date_formatter.dart';

void main() {
  group('Note model', () {
    test('creates note with required fields', () {
      final now = DateTime.now();
      final note = Note(
        id: 'test-id',
        title: 'Test Note',
        content: '# Hello\nThis is a test.',
        createdAt: now,
        updatedAt: now,
      );
      expect(note.id, 'test-id');
      expect(note.title, 'Test Note');
      expect(note.isPinned, false);
      expect(note.tags, isEmpty);
    });

    test('serializes and deserializes correctly', () {
      final now = DateTime.now();
      final note = Note(
        id: 'test-id',
        title: 'Test Note',
        content: '**Bold** content',
        createdAt: now,
        updatedAt: now,
        tags: ['flutter', 'test'],
        isPinned: true,
      );
      final json = note.toJsonString();
      final restored = Note.fromJsonString(json);
      expect(restored.id, note.id);
      expect(restored.title, note.title);
      expect(restored.content, note.content);
      expect(restored.isPinned, note.isPinned);
      expect(restored.tags, note.tags);
    });

    test('copyWith creates modified copy', () {
      final now = DateTime.now();
      final note = Note(
        id: 'test-id',
        title: 'Original',
        content: 'Content',
        createdAt: now,
        updatedAt: now,
      );
      final copy = note.copyWith(title: 'Modified');
      expect(copy.id, note.id);
      expect(copy.title, 'Modified');
      expect(copy.content, note.content);
    });

    test('preview strips markdown formatting', () {
      final now = DateTime.now();
      final note = Note(
        id: 'id',
        title: 'Title',
        content: '# Heading\n**Bold** _italic_ `code`',
        createdAt: now,
        updatedAt: now,
      );
      expect(note.preview, isNotEmpty);
      expect(note.preview, isNot(contains('#')));
    });

    test('preview is truncated at 120 chars', () {
      final now = DateTime.now();
      final longContent = 'a' * 200;
      final note = Note(
        id: 'id',
        title: 'Title',
        content: longContent,
        createdAt: now,
        updatedAt: now,
      );
      expect(note.preview.length, lessThanOrEqualTo(123)); // 120 + '...'
    });

    test('equality based on id', () {
      final now = DateTime.now();
      final note1 = Note(
        id: 'same-id',
        title: 'Note 1',
        content: 'Content 1',
        createdAt: now,
        updatedAt: now,
      );
      final note2 = Note(
        id: 'same-id',
        title: 'Note 2',
        content: 'Content 2',
        createdAt: now,
        updatedAt: now,
      );
      expect(note1, equals(note2));
    });

    test('notes with different ids are not equal', () {
      final now = DateTime.now();
      final note1 = Note(
          id: 'id-1', title: 'N', content: '', createdAt: now, updatedAt: now);
      final note2 = Note(
          id: 'id-2', title: 'N', content: '', createdAt: now, updatedAt: now);
      expect(note1, isNot(equals(note2)));
    });
  });

  group('DateFormatter', () {
    test('returns "Just now" for very recent dates', () {
      final now = DateTime.now();
      expect(DateFormatter.relative(now), 'Just now');
    });

    test('returns minutes ago for dates within the hour', () {
      final date = DateTime.now().subtract(const Duration(minutes: 30));
      expect(DateFormatter.relative(date), '30m ago');
    });

    test('returns hours ago for dates within the day', () {
      final date = DateTime.now().subtract(const Duration(hours: 3));
      expect(DateFormatter.relative(date), '3h ago');
    });

    test('returns days ago for dates within the week', () {
      final date = DateTime.now().subtract(const Duration(days: 2));
      expect(DateFormatter.relative(date), '2d ago');
    });
  });

  group('NotesService', () {
    test('can be instantiated', () {
      final service = NotesService();
      expect(service, isNotNull);
      expect(service.isLoading, true);
    });

    test('searchQuery starts empty', () {
      final service = NotesService();
      expect(service.searchQuery, isEmpty);
    });

    test('setSearchQuery updates the query and notifies', () {
      final service = NotesService();
      var notified = false;
      service.addListener(() => notified = true);
      service.setSearchQuery('test query');
      expect(service.searchQuery, 'test query');
      expect(notified, true);
    });

    test('importNote returns false for invalid JSON', () async {
      final service = NotesService();
      final result = await service.importNote('not valid json');
      expect(result, false);
    });
  });
}

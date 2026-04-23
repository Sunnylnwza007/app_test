import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';

class NotesService extends ChangeNotifier {
  static const String _storageKey = 'notes_data';
  static const _uuid = Uuid();

  void _log(String message) {
    if (kDebugMode) debugPrint('[NotesService] $message');
  }

  final List<Note> _notes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  List<Note> get notes => _filteredNotes;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<Note> get _filteredNotes {
    final sorted = List<Note>.from(_notes)
      ..sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });

    if (_searchQuery.isEmpty) return sorted;

    final query = _searchQuery.toLowerCase();
    return sorted
        .where((n) =>
            n.title.toLowerCase().contains(query) ||
            n.content.toLowerCase().contains(query) ||
            n.tags.any((t) => t.toLowerCase().contains(query)))
        .toList();
  }

  int get totalNotes => _notes.length;

  NotesService() {
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_storageKey) ?? [];
      _notes.clear();
      for (final item in raw) {
        try {
          _notes.add(Note.fromJsonString(item));
        } catch (e) {
          _log('Failed to deserialize note: $e');
        }
      }
    } catch (e) {
      _log('Failed to load notes from storage: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _notes.map((n) => n.toJsonString()).toList();
      await prefs.setStringList(_storageKey, data);
    } catch (e) {
      _log('Failed to save notes to storage: $e');
      rethrow;
    }
  }

  Future<Note> createNote({String title = '', String content = ''}) async {
    final now = DateTime.now();
    final note = Note(
      id: _uuid.v4(),
      title: title.isNotEmpty ? title : 'Untitled',
      content: content,
      createdAt: now,
      updatedAt: now,
    );
    _notes.insert(0, note);
    await _saveNotes();
    notifyListeners();
    return note;
  }

  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note.copyWith(updatedAt: DateTime.now());
      await _saveNotes();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _saveNotes();
    notifyListeners();
  }

  Future<void> togglePin(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(isPinned: !_notes[index].isPinned);
      await _saveNotes();
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> importNote(String jsonString) async {
    try {
      final data = jsonDecode(jsonString);
      if (data is List) {
        for (final item in data) {
          final note = Note.fromJson(item as Map<String, dynamic>);
          final exists = _notes.any((n) => n.id == note.id);
          if (!exists) _notes.add(note);
        }
      } else if (data is Map<String, dynamic>) {
        final note = Note.fromJson(data);
        final exists = _notes.any((n) => n.id == note.id);
        if (!exists) _notes.add(note);
      }
      await _saveNotes();
      notifyListeners();
      return true;
    } catch (e) {
      _log('Failed to import note: $e');
      return false;
    }
  }

  String exportNotes() {
    return jsonEncode(_notes.map((n) => n.toJson()).toList());
  }
}

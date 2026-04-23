import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/notes_service.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../widgets/note_card.dart';
import '../widgets/sidebar.dart';
import '../widgets/responsive_layout.dart';
import 'note_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedNoteId;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _createNewNote() async {
    final service = context.read<NotesService>();
    final note = await service.createNote();
    setState(() => _selectedNoteId = note.id);
    if (!mounted) return;

    if (!ResponsiveLayout.isWide(context)) {
      _openMobileEditor(note);
    }
  }

  void _openMobileEditor(Note note) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<NotesService>(),
          child: NoteEditorScreen(note: note),
        ),
      ),
    );
  }

  void _selectNote(String id) {
    final service = context.read<NotesService>();
    final note = service.getNoteById(id);
    if (note == null) return;

    if (!ResponsiveLayout.isWide(context)) {
      _openMobileEditor(note);
    } else {
      setState(() => _selectedNoteId = id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final notesService = context.watch<NotesService>();
    final notes = notesService.notes;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.edit_note, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(AppConstants.appName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showMobileSearch(context),
          ),
          IconButton(
            icon: Icon(themeProvider.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: notesService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return NoteCard(
                      note: note,
                      isSelected: false,
                      onTap: () => _selectNote(note.id),
                      onDelete: () => _confirmDelete(context, note.id),
                      onTogglePin: () =>
                          notesService.togglePin(note.id),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewNote,
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    final notesService = context.watch<NotesService>();
    final selectedNote = _selectedNoteId != null
        ? notesService.getNoteById(_selectedNoteId!)
        : null;

    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            selectedNoteId: _selectedNoteId,
            onNewNote: _createNewNote,
            onNoteSelected: _selectNote,
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: selectedNote != null
                ? NoteEditorScreen(
                    key: ValueKey(selectedNote.id),
                    note: selectedNote,
                    isDesktop: true,
                  )
                : _buildWelcomePlaceholder(),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePlaceholder() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_note,
            size: 80,
            color: theme.iconTheme.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Select a note or create a new one',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.iconTheme.color?.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Press Ctrl+N or click "New Note" to start',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.iconTheme.color?.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewNote,
            icon: const Icon(Icons.add),
            label: const Text('Create Note'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add_outlined,
            size: 72,
            color: theme.iconTheme.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Your notebook is empty',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to create your first note',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showMobileSearch(BuildContext context) {
    final service = context.read<NotesService>();
    showSearch(
      context: context,
      delegate: _NoteSearchDelegate(service),
    );
  }

  void _confirmDelete(BuildContext context, String noteId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<NotesService>().deleteNote(noteId);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _NoteSearchDelegate extends SearchDelegate<String?> {
  final NotesService service;

  _NoteSearchDelegate(this.service);

  @override
  String get searchFieldLabel => 'Search notes...';

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    service.setSearchQuery(query);
    final notes = service.notes;

    if (notes.isEmpty) {
      return Center(
        child: Text(
          query.isEmpty ? 'Type to search' : 'No notes found',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          leading: const Icon(Icons.article_outlined),
          title: Text(note.title),
          subtitle: Text(note.preview, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () {
            service.setSearchQuery('');
            close(context, note.id);
          },
        );
      },
    );
  }
}

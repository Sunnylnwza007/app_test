import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/notes_service.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';

class AppSidebar extends StatelessWidget {
  final String? selectedNoteId;
  final VoidCallback onNewNote;
  final Function(String) onNoteSelected;

  const AppSidebar({
    super.key,
    this.selectedNoteId,
    required this.onNewNote,
    required this.onNoteSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      width: AppConstants.sidebarWidth,
      color: theme.appBarTheme.backgroundColor,
      child: Column(
        children: [
          _buildHeader(context, themeProvider),
          _buildNewNoteButton(context),
          _buildSearchBar(context),
          _buildNoteList(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeProvider themeProvider) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.edit_note, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            AppConstants.appName,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
              size: 20,
            ),
            onPressed: themeProvider.toggleTheme,
            tooltip: 'Toggle theme',
          ),
        ],
      ),
    );
  }

  Widget _buildNewNoteButton(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: ElevatedButton.icon(
        onPressed: onNewNote,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('New Note'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final service = context.read<NotesService>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: TextField(
        onChanged: service.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search notes...',
          prefixIcon: const Icon(Icons.search, size: 18),
          suffixIcon: context.watch<NotesService>().searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => service.setSearchQuery(''),
                )
              : null,
        ),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildNoteList(BuildContext context) {
    final theme = Theme.of(context);
    final notesService = context.watch<NotesService>();
    final notes = notesService.notes;

    return Expanded(
      child: notesService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.note_outlined,
                          size: 48, color: theme.iconTheme.color),
                      const SizedBox(height: 12),
                      Text(
                        notesService.searchQuery.isNotEmpty
                            ? 'No notes found'
                            : 'No notes yet',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return _NoteListTile(
                      note: note,
                      isSelected: note.id == selectedNoteId,
                      onTap: () => onNoteSelected(note.id),
                      onDelete: () => notesService.deleteNote(note.id),
                      onPin: () => notesService.togglePin(note.id),
                    );
                  },
                ),
    );
  }
}

class _NoteListTile extends StatelessWidget {
  final Note note;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onPin;

  const _NoteListTile({
    required this.note,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          dense: true,
          leading: Icon(
            note.isPinned ? Icons.push_pin : Icons.article_outlined,
            size: 18,
            color: note.isPinned ? colorScheme.primary : theme.iconTheme.color,
          ),
          title: Text(
            note.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? colorScheme.primary : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _formatDate(note.updatedAt),
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
            maxLines: 1,
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz, size: 16, color: theme.iconTheme.color),
            padding: EdgeInsets.zero,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pin',
                child: Row(children: [
                  Icon(
                      note.isPinned
                          ? Icons.push_pin_outlined
                          : Icons.push_pin,
                      size: 18),
                  const SizedBox(width: 8),
                  Text(note.isPinned ? 'Unpin' : 'Pin'),
                ]),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ]),
              ),
            ],
            onSelected: (v) {
              if (v == 'delete') onDelete();
              if (v == 'pin') onPin();
            },
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => DateFormatter.relative(date);
}

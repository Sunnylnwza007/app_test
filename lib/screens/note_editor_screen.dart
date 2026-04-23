import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/notes_service.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note note;
  final bool isDesktop;

  const NoteEditorScreen({
    super.key,
    required this.note,
    this.isDesktop = false,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isPreview = false;
  bool _hasChanges = false;
  late Note _currentNote;
  NotesService? _notesService;

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
    _titleController = TextEditingController(text: _currentNote.title);
    _contentController = TextEditingController(text: _currentNote.content);
    _titleController.addListener(_onChanged);
    _contentController.addListener(_onChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notesService = context.read<NotesService>();
  }

  @override
  void didUpdateWidget(NoteEditorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note.id != widget.note.id) {
      _saveImmediate();
      _currentNote = widget.note;
      _titleController.text = _currentNote.title;
      _contentController.text = _currentNote.content;
      _hasChanges = false;
      _isPreview = false;
    }
  }

  void _onChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  void _saveImmediate() {
    if (!_hasChanges) return;
    final service = _notesService;
    if (service == null) return;
    final updated = _currentNote.copyWith(
      title: _titleController.text.trim().isEmpty
          ? 'Untitled'
          : _titleController.text.trim(),
      content: _contentController.text,
    );
    service.updateNote(updated);
    _hasChanges = false;
  }

  Future<void> _save() async {
    if (!_hasChanges) return;
    final service = _notesService ?? context.read<NotesService>();
    final updated = _currentNote.copyWith(
      title: _titleController.text.trim().isEmpty
          ? 'Untitled'
          : _titleController.text.trim(),
      content: _contentController.text,
    );
    await service.updateNote(updated);
    if (mounted) setState(() => _hasChanges = false);
  }

  @override
  void dispose() {
    _saveImmediate();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _insertMarkdown(String prefix, String suffix) {
    final controller = _contentController;
    final selection = controller.selection;
    if (!selection.isValid) {
      controller.text += '$prefix$suffix';
      return;
    }
    final text = controller.text;
    final selectedText = selection.textInside(text);
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$prefix$selectedText$suffix',
    );
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + prefix.length + selectedText.length,
      ),
    );
  }

  void _insertAtLineStart(String prefix) {
    final controller = _contentController;
    final selection = controller.selection;
    final text = controller.text;
    if (!selection.isValid) {
      controller.text += '\n$prefix ';
      return;
    }
    final lineStart = text.lastIndexOf('\n', selection.start - 1) + 1;
    final newText = text.substring(0, lineStart) +
        prefix +
        ' ' +
        text.substring(lineStart);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
          offset: selection.start + prefix.length + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildToolbar(theme),
        Expanded(
          child: _isPreview ? _buildPreview(theme) : _buildEditor(theme),
        ),
      ],
    );
  }

  Widget _buildToolbar(ThemeData theme) {
    return Container(
      color: theme.appBarTheme.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          if (!widget.isDesktop)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                _save();
                Navigator.of(context).pop();
              },
              tooltip: 'Back',
            ),
          Expanded(
            child: TextField(
              controller: _titleController,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Note title...',
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
              onSubmitted: (_) => _save(),
            ),
          ),
          if (_hasChanges)
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save, size: 18),
              label: const Text('Save'),
            ),
          IconButton(
            icon: Icon(_isPreview ? Icons.edit : Icons.preview),
            onPressed: () => setState(() => _isPreview = !_isPreview),
            tooltip: _isPreview ? 'Edit' : 'Preview',
          ),
        ],
      ),
    );
  }

  Widget _buildEditor(ThemeData theme) {
    return Column(
      children: [
        _buildFormatBar(theme),
        Expanded(
          child: TextField(
            controller: _contentController,
            maxLines: null,
            expands: true,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              fontFamily: 'monospace',
            ),
            decoration: InputDecoration(
              hintText: 'Start writing in markdown...\n\n'
                  '# Heading\n**Bold** *Italic*\n- List item\n> Quote',
              border: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.all(16),
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.iconTheme.color?.withOpacity(0.4),
              ),
            ),
          ),
        ),
        _buildStatusBar(theme),
      ],
    );
  }

  Widget _buildFormatBar(ThemeData theme) {
    final buttons = [
      (icon: Icons.format_bold, label: 'Bold', action: () => _insertMarkdown('**', '**')),
      (icon: Icons.format_italic, label: 'Italic', action: () => _insertMarkdown('*', '*')),
      (icon: Icons.format_strikethrough, label: 'Strike', action: () => _insertMarkdown('~~', '~~')),
      (icon: Icons.code, label: 'Code', action: () => _insertMarkdown('`', '`')),
      (icon: Icons.format_quote, label: 'Quote', action: () => _insertAtLineStart('>')),
      (icon: Icons.format_list_bulleted, label: 'List', action: () => _insertAtLineStart('-')),
      (icon: Icons.format_list_numbered, label: 'Numbered', action: () => _insertAtLineStart('1.')),
      (icon: Icons.title, label: 'H1', action: () => _insertAtLineStart('#')),
      (icon: Icons.horizontal_rule, label: 'HR', action: () {
        final c = _contentController;
        c.text = '${c.text}\n---\n';
        c.selection = TextSelection.collapsed(offset: c.text.length);
      }),
    ];

    return Container(
      color: theme.cardTheme.color,
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: buttons
            .map(
              (b) => Tooltip(
                message: b.label,
                child: IconButton(
                  icon: Icon(b.icon, size: 18),
                  onPressed: b.action,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildPreview(ThemeData theme) {
    return Markdown(
      data: _contentController.text.isEmpty
          ? '*Nothing to preview yet...*'
          : _contentController.text,
      padding: const EdgeInsets.all(16),
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        p: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
        h1: theme.textTheme.headlineMedium,
        h2: theme.textTheme.titleLarge,
        h3: theme.textTheme.titleMedium,
        code: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          backgroundColor: theme.cardTheme.color,
        ),
        codeblockDecoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(8),
        ),
        blockquoteDecoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.08),
          borderLeft: BorderSide(color: theme.colorScheme.primary, width: 3),
        ),
      ),
    );
  }

  Widget _buildStatusBar(ThemeData theme) {
    final wordCount = _contentController.text.trim().isEmpty
        ? 0
        : _contentController.text.trim().split(RegExp(r'\s+')).length;
    final charCount = _contentController.text.length;

    return Container(
      color: theme.cardTheme.color,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(
            '$wordCount words · $charCount chars',
            style: theme.textTheme.bodySmall,
          ),
          const Spacer(),
          if (_hasChanges)
            Text(
              'Unsaved changes',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}

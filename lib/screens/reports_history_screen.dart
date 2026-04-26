import 'dart:io';

import 'package:burn_scan/services/report_service.dart';
import 'package:burn_scan/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';

class ReportsHistoryScreen extends StatefulWidget {
  const ReportsHistoryScreen({super.key});

  @override
  State<ReportsHistoryScreen> createState() => _ReportsHistoryScreenState();
}

class _ReportsHistoryScreenState extends State<ReportsHistoryScreen> {
  late Future<List<File>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Saved Reports',
      child: FutureBuilder<List<File>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _CenteredState(
              icon: Icons.folder_off_outlined,
              title: 'Unable to load reports',
              message: 'Please try again in a moment.',
              actionLabel: 'Retry',
              onPressed: _refresh,
            );
          }

          final reports = snapshot.data ?? const <File>[];
          if (reports.isEmpty) {
            return _CenteredState(
              icon: Icons.picture_as_pdf_outlined,
              title: 'No saved reports found',
              message:
                  'Generated PDF reports will appear here once they are saved on this device.',
              actionLabel: 'Refresh',
              onPressed: _refresh,
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return _ReportCard(
                  file: reports[index],
                  onOpen: () => _openReport(reports[index]),
                  onDelete: () => _confirmDelete(reports[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<List<File>> _loadReports() {
    return context.read<ReportService>().listSavedPdfReports();
  }

  Future<void> _refresh() async {
    setState(() {
      _reportsFuture = _loadReports();
    });
  }

  Future<void> _openReport(File file) async {
    final result = await OpenFilex.open(file.path);
    if (!mounted) {
      return;
    }
    if (result.type == ResultType.done) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.message.isEmpty
              ? 'Unable to open the selected report.'
              : result.message,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(File file) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete report?'),
          content: Text(
            'Remove "${file.uri.pathSegments.last}" from local storage?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await context.read<ReportService>().deleteReport(file);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report deleted.')),
    );
    _refresh();
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.file,
    required this.onOpen,
    required this.onDelete,
  });

  final File file;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final stat = file.statSync();
    final modified = DateFormat.yMMMd().add_jm().format(stat.modified);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F7FB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: Color(0xFFBE3E36),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.uri.pathSegments.last,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Modified $modified',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatBytes(stat.size),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<_ReportAction>(
                  onSelected: (value) {
                    switch (value) {
                      case _ReportAction.open:
                        onOpen();
                        break;
                      case _ReportAction.delete:
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _ReportAction.open,
                      child: ListTile(
                        leading: Icon(Icons.open_in_new),
                        title: Text('Open'),
                      ),
                    ),
                    PopupMenuItem(
                      value: _ReportAction.delete,
                      child: ListTile(
                        leading: Icon(Icons.delete_outline),
                        title: Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open'),
                ),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    final precision = size >= 10 || unitIndex == 0 ? 0 : 1;
    return '${size.toStringAsFixed(precision)} ${units[unitIndex]}';
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 82,
                width: 82,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7F8),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Icon(icon, size: 40, color: const Color(0xFF587275)),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ReportAction { open, delete }

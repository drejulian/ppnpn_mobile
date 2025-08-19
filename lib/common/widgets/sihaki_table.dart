import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppnpm_dpr/app/theme.dart';

// Model untuk konfigurasi kolom
class TableColumn {
  final String key;
  final String label;
  final double? width;
  final bool sortable;
  final TextAlign alignment;
  final bool expanded;
  final bool searchable; // Tambahan untuk search

  const TableColumn({
    required this.key,
    required this.label,
    this.width,
    this.sortable = true, // Default true untuk sorting
    this.alignment = TextAlign.left,
    this.expanded = true,
    this.searchable = true, // Default true untuk search
  });
}

// Model untuk konfigurasi action button
class TableAction {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;
  final IconData? icon;

  const TableAction({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.icon,
  });
}

// Enhanced Data Table Widget dengan Search, Pagination, dan Sorting
class EnhancedDataTable extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<TableColumn> columns;
  final String? title;
  final List<TableAction> Function(Map<String, dynamic> row)? actionBuilder;
  final bool showActions;
  final bool showBorder;
  final Color? headerColor;
  final TextStyle? headerTextStyle;
  final TextStyle? cellTextStyle;
  final Color? cardBackgroundColor;
  final bool showSearch;
  final bool showPagination;
  final int rowsPerPage;
  final String searchPlaceholder;

  const EnhancedDataTable({
    super.key,
    required this.data,
    required this.columns,
    this.title,
    this.actionBuilder,
    this.showActions = true,
    this.showBorder = true,
    this.headerColor,
    this.headerTextStyle,
    this.cellTextStyle,
    this.cardBackgroundColor = Colors.white,
    this.showSearch = true,
    this.showPagination = true,
    this.rowsPerPage = 10,
    this.searchPlaceholder = 'Cari data...',
  });

  @override
  ConsumerState<EnhancedDataTable> createState() => _EnhancedDataTableState();
}

class _EnhancedDataTableState extends ConsumerState<EnhancedDataTable> {
  String _searchQuery = '';
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  late List<Map<String, dynamic>> _filteredData;
  late List<Map<String, dynamic>> _sortedData;

  @override
  void initState() {
    super.initState();
    _updateData();
  }

  @override
  void didUpdateWidget(EnhancedDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _updateData();
    }
  }

  void _updateData() {
    _filteredData = _filterData();
    _sortedData = _sortData(_filteredData);
    // Reset pagination state if needed (PaginatedDataTable manages its own page)
  }

  List<Map<String, dynamic>> _filterData() {
    if (_searchQuery.isEmpty) {
      return List.from(widget.data);
    }

    return widget.data.where((row) {
      return widget.columns.any((column) {
        if (!column.searchable) return false;
        final value = row[column.key]?.toString().toLowerCase() ?? '';
        return value.contains(_searchQuery.toLowerCase());
      });
    }).toList();
  }

  List<Map<String, dynamic>> _sortData(List<Map<String, dynamic>> data) {
    if (_sortColumnIndex >= widget.columns.length) return data;

    final column = widget.columns[_sortColumnIndex];
    if (!column.sortable) return data;

    final sortedData = List<Map<String, dynamic>>.from(data);
    sortedData.sort((a, b) {
      final aValue = a[column.key]?.toString() ?? '';
      final bValue = b[column.key]?.toString() ?? '';

      // Try to parse as number for better numeric sorting
      final aNum = double.tryParse(aValue.replaceAll(',', ''));
      final bNum = double.tryParse(bValue.replaceAll(',', ''));

      int comparison;
      if (aNum != null && bNum != null) {
        comparison = aNum.compareTo(bNum);
      } else {
        comparison = aValue.compareTo(bValue);
      }

      return _sortAscending ? comparison : -comparison;
    });

    return sortedData;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _updateData();
    });
  }

  void _onSort(int columnIndex) {
    if (columnIndex >= widget.columns.length) return;
    if (!widget.columns[columnIndex].sortable) return;

    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }
      _sortedData = _sortData(_filteredData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Container(
      color: widget.cardBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          if (widget.title != null)
            Container(
              color: widget.cardBackgroundColor,
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.title!,
                style: theme.typographyRegular.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),

          // Search Bar
          if (widget.showSearch)
            Container(
              color: widget.cardBackgroundColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: widget.searchPlaceholder,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                onChanged: _onSearchChanged,
              ),
            ),

          // Data Info
          Container(
            color: widget.cardBackgroundColor,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              'Menampilkan ${_sortedData.length} dari ${widget.data.length} data',
              style: theme.typographyRegular.bodySmall.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),

          // Table
          if (widget.showPagination)
            _buildPaginatedTable(theme)
          else
            _buildSimpleTable(theme),
        ],
      ),
    );
  }

  Widget _buildPaginatedTable(dynamic theme) {
    List<DataColumn> dataColumns =
        widget.columns.asMap().entries.map((entry) {
          final index = entry.key;
          final col = entry.value;

          Widget labelWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  col.label,
                  style:
                      widget.headerTextStyle ??
                      theme.typographyRegular.bodySmall.copyWith(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
              ),
              if (col.sortable) ...[
                const SizedBox(width: 4),
                Icon(
                  _sortColumnIndex == index
                      ? (_sortAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward)
                      : Icons.unfold_more,
                  size: 16,
                  color: _sortColumnIndex == index ? Colors.blue : Colors.grey,
                ),
              ],
            ],
          );

          return DataColumn(
            label: col.expanded ? Expanded(child: labelWidget) : labelWidget,
            onSort:
                col.sortable
                    ? (columnIndex, ascending) => _onSort(index)
                    : null,
          );
        }).toList();

    // Tambahkan kolom aksi
    if (widget.showActions && widget.actionBuilder != null) {
      dataColumns.add(
        DataColumn(
          label: Expanded(
            child: Text(
              'Aksi',
              style:
                  widget.headerTextStyle ??
                  theme.typographyRegular.bodySmall.copyWith(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: widget.cardBackgroundColor,
      child: PaginatedDataTable(
        rowsPerPage: widget.rowsPerPage,
        availableRowsPerPage: const [5, 10, 20, 50],
        columns: dataColumns,
        source: _EnhancedDataSource(
          _sortedData,
          widget.columns,
          context,
          theme,
          widget.actionBuilder,
          widget.showActions,
          widget.cellTextStyle,
        ),
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        columnSpacing: 20,
        horizontalMargin: 10,
        showCheckboxColumn: false,
        headingRowColor:
            widget.headerColor != null
                ? WidgetStatePropertyAll(widget.headerColor!)
                : WidgetStatePropertyAll(Colors.grey[50]),
        dividerThickness: 1,
      ),
    );
  }

  Widget _buildSimpleTable(dynamic theme) {
    List<DataColumn> dataColumns =
        widget.columns.asMap().entries.map((entry) {
          final index = entry.key;
          final col = entry.value;

          Widget labelWidget = InkWell(
            onTap: col.sortable ? () => _onSort(index) : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    col.label,
                    style:
                        widget.headerTextStyle ??
                        theme.typographyRegular.bodySmall.copyWith(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                  ),
                ),
                if (col.sortable) ...[
                  const SizedBox(width: 4),
                  Icon(
                    _sortColumnIndex == index
                        ? (_sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward)
                        : Icons.unfold_more,
                    size: 16,
                    color:
                        _sortColumnIndex == index ? Colors.blue : Colors.grey,
                  ),
                ],
              ],
            ),
          );

          return DataColumn(
            label: col.expanded ? Expanded(child: labelWidget) : labelWidget,
          );
        }).toList();

    // Tambahkan kolom aksi
    if (widget.showActions && widget.actionBuilder != null) {
      dataColumns.add(
        DataColumn(
          label: Expanded(
            child: Text(
              'Aksi',
              style:
                  widget.headerTextStyle ??
                  theme.typographyRegular.bodySmall.copyWith(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: widget.cardBackgroundColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: dataColumns,
          rows: _sortedData.map((row) => _buildDataRow(row, theme)).toList(),
          border:
              widget.showBorder
                  ? TableBorder.all(color: Colors.grey.shade300, width: 1)
                  : null,
          headingRowColor:
              widget.headerColor != null
                  ? WidgetStatePropertyAll(widget.headerColor!)
                  : WidgetStatePropertyAll(Colors.grey[50]),
          dataRowColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.selected)) {
              return Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.08);
            }
            return widget.cardBackgroundColor;
          }),
          columnSpacing: 20,
          horizontalMargin: 12,
          showCheckboxColumn: false,
          dividerThickness: 1,
        ),
      ),
    );
  }

  DataRow _buildDataRow(Map<String, dynamic> row, dynamic theme) {
    List<DataCell> cells =
        widget.columns.map((column) {
          final value = row[column.key]?.toString() ?? '';

          return DataCell(
            column.width != null
                ? SizedBox(
                  width: column.width!,
                  child: Text(
                    value,
                    textAlign: column.alignment,
                    style:
                        widget.cellTextStyle ??
                        theme.typographyRegular.bodySmall.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                )
                : Text(
                  value,
                  textAlign: column.alignment,
                  style:
                      widget.cellTextStyle ??
                      theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
          );
        }).toList();

    // Tambahkan action cell
    if (widget.showActions && widget.actionBuilder != null) {
      final actions = widget.actionBuilder!(row);
      cells.add(
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children:
                actions.map((action) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: action.onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: action.backgroundColor,
                        foregroundColor: action.foregroundColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (action.icon != null) ...[
                            Icon(action.icon, size: 12),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            action.label,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      );
    }

    return DataRow(cells: cells);
  }
}

class _EnhancedDataSource extends DataTableSource {
  final List<Map<String, dynamic>> _data;
  final List<TableColumn> _columns;
  final BuildContext context;
  final dynamic theme;
  final List<TableAction> Function(Map<String, dynamic> row)? actionBuilder;
  final bool showActions;
  final TextStyle? cellTextStyle;

  _EnhancedDataSource(
    this._data,
    this._columns,
    this.context,
    this.theme,
    this.actionBuilder,
    this.showActions,
    this.cellTextStyle,
  );

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) {
      return null;
    }
    final row = _data[index];

    List<DataCell> cells =
        _columns.map((column) {
          final value = row[column.key]?.toString() ?? '';

          return DataCell(
            column.width != null
                ? SizedBox(
                  width: column.width!,
                  child: Text(
                    value,
                    textAlign: column.alignment,
                    style:
                        cellTextStyle ??
                        theme.typographyRegular.bodySmall.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                )
                : Text(
                  value,
                  textAlign: column.alignment,
                  style:
                      cellTextStyle ??
                      theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
          );
        }).toList();

    if (showActions && actionBuilder != null) {
      final actions = actionBuilder!(row);
      cells.add(
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children:
                actions.map((action) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: action.onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: action.backgroundColor,
                        foregroundColor: action.foregroundColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (action.icon != null) ...[
                            Icon(action.icon, size: 12),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            action.label,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      );
    }

    return DataRow(cells: cells);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}

// Keep the old widgets for backward compatibility
class GenericDataTable extends EnhancedDataTable {
  const GenericDataTable({
    super.key,
    required super.data,
    required super.columns,
    super.title,
    super.actionBuilder,
    super.showActions = true,
    super.showBorder = true,
    super.headerColor,
    super.headerTextStyle,
    super.cellTextStyle,
    super.cardBackgroundColor = Colors.white,
  }) : super(showSearch: false, showPagination: false);
}

class GenericPaginatedDataTable extends EnhancedDataTable {
  const GenericPaginatedDataTable({
    super.key,
    required super.data,
    required super.columns,
    super.title,
    super.rowsPerPage = 10,
    super.actionBuilder,
    super.showActions = true,
    super.cardBackgroundColor = Colors.white,
  }) : super(showSearch: false, showPagination: true);
}

// Helper functions untuk actions yang sering digunakan
class TableActionHelpers {
  static void showPrintConfirmation(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Konfirmasi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Cetak'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  static void showWhatsAppConfirmation(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Konfirmasi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Kirim'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

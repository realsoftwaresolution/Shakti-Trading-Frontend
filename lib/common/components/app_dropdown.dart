import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_web_rough_entry_system/app_theme.dart';

/// Item model for [AppDropdown].
class AppDropdownItem<T> {
  final T value;
  final String label;
  final Widget? icon;
  final Widget? trailing;
  final String? subtitle;
  final Widget? child;

  const AppDropdownItem({
    required this.value,
    required this.label,
    this.icon,
    this.trailing,
    this.subtitle,
    this.child,
  });
}

/// Advanced ERP Searchable Dropdown supporting both Single-Select and Multi-Select.
///
/// Features:
/// - Real-time filtering with an auto-focused search field.
/// - Full keyboard navigation:
///   - [ArrowDown] / [ArrowUp] scrolls and highlights items.
///   - [Space] toggles item selection in Multi-Select mode.
///   - [Enter] in Single-Select picks the highlighted item, closes, and moves to [nextFocusNode].
///   - [Enter] in Multi-Select confirms the selection, closes, and moves to [nextFocusNode].
///   - [Escape] closes the popup without changes.
/// - 100% backward compatible with legacy [DropdownMenuItem] lists.
class AppDropdown<T> extends StatefulWidget {
  final String? label;
  final T? value; // Single-select value
  final List<T>? selectedValues; // Multi-select values
  final List<DropdownMenuItem<T>>? items; // Backward-compatible legacy items
  final List<AppDropdownItem<T>>? dropdownItems; // Rich dropdown items
  final ValueChanged<T?>? onChanged; // Single-select change callback
  final ValueChanged<List<T>>? onMultiChanged; // Multi-select change callback
  final bool isMultiSelect;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final String? hintText;
  final bool isEnabled;
  final FormFieldValidator<T>? validator;
  final double? width;
  final Widget? prefixIcon;
  final bool showSearch;
  final String searchHint;
  final double maxHeight;
  final EdgeInsetsGeometry? contentPadding;
  final Widget Function(BuildContext context, T value)? selectedItemBuilder;
  final double? itemHeight;

  /// Optional width of the popup list. When larger than the field, the popup
  /// grows to this width (limited to the screen) - useful for table-like rows.
  final double? popupWidth;

  /// Optional fixed widget shown between the search bar and the item list,
  /// e.g. a column header row for table-like items.
  final Widget? popupHeader;

  const AppDropdown({
    super.key,
    this.label,
    this.value,
    this.selectedValues,
    this.items,
    this.dropdownItems,
    this.onChanged,
    this.onMultiChanged,
    this.isMultiSelect = false,
    this.focusNode,
    this.nextFocusNode,
    this.hintText,
    this.isEnabled = true,
    this.validator,
    this.width,
    this.prefixIcon,
    this.showSearch = true,
    this.searchHint = 'Search...',
    this.maxHeight = 280.0,
    this.contentPadding,
    this.selectedItemBuilder,
    this.itemHeight,
    this.popupWidth,
    this.popupHeader,
  });

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  final GlobalKey _triggerKey = GlobalKey();
  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode => widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  late final FocusNode _searchFocusNode;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  OverlayEntry? _overlayEntry;
  StateSetter? _overlaySetState;
  bool _isOpen = false;

  int _highlightedIndex = -1;
  String _searchQuery = '';
  List<AppDropdownItem<T>> _filteredItems = [];
  Set<T> _selectedMulti = {};

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode(onKeyEvent: _handleSearchKeyEvent);
    _effectiveFocusNode.addListener(_handleTriggerFocusChange);
    if (widget.isMultiSelect && widget.selectedValues != null) {
      _selectedMulti = widget.selectedValues!.toSet();
    }
  }

  @override
  void didUpdateWidget(covariant AppDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleTriggerFocusChange);
      _effectiveFocusNode.addListener(_handleTriggerFocusChange);
    }
    if (widget.isMultiSelect) {
      final newSet = widget.selectedValues?.toSet() ?? {};
      if (!setEquals(_selectedMulti, newSet)) {
        _selectedMulti = newSet;
      }
    }
  }

  @override
  void dispose() {
    _closeDropdown(restoreFocus: false);
    _effectiveFocusNode.removeListener(_handleTriggerFocusChange);
    _internalFocusNode?.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTriggerFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  String _extractText(Widget? w) {
    if (w == null) return '';
    if (w is Text) return w.data ?? '';
    if (w is Row) return w.children.map(_extractText).join(' ');
    if (w is Column) return w.children.map(_extractText).join(' ');
    if (w is Container) return _extractText(w.child);
    if (w is Padding) return _extractText(w.child);
    if (w is SizedBox) return _extractText(w.child);
    if (w is Expanded) return _extractText(w.child);
    if (w is Flexible) return _extractText(w.child);
    if (w is Align) return _extractText(w.child);
    if (w is Center) return _extractText(w.child);
    return '';
  }

  List<AppDropdownItem<T>> _resolveItems() {
    if (widget.dropdownItems != null) {
      return widget.dropdownItems!;
    }
    if (widget.items != null) {
      return widget.items!.map((m) {
        String label = '';
        if (m.child is Text) {
          label = (m.child as Text).data ?? '';
        } else {
          final extracted = _extractText(m.child).trim();
          final val = m.value?.toString() ?? '';
          label = extracted.isNotEmpty ? '$extracted $val' : val;
        }
        return AppDropdownItem<T>(
          value: m.value as T,
          label: label,
          child: m.child,
        );
      }).toList();
    }
    return [];
  }

  KeyEventResult _handleTriggerKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.arrowDown) {
      if (widget.isEnabled && !_isOpen) {
        _openDropdown();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handleSearchKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    // 1. Arrow Down: navigate down and scroll into view
    if (key == LogicalKeyboardKey.arrowDown) {
      if (_filteredItems.isNotEmpty) {
        final newIndex = (_highlightedIndex + 1).clamp(0, _filteredItems.length - 1);
        _updateHighlightedIndex(newIndex);
        _scrollToHighlighted();
      }
      return KeyEventResult.handled;
    }

    // 2. Arrow Up: navigate up and scroll into view
    if (key == LogicalKeyboardKey.arrowUp) {
      if (_filteredItems.isNotEmpty) {
        final newIndex = (_highlightedIndex - 1).clamp(0, _filteredItems.length - 1);
        _updateHighlightedIndex(newIndex);
        _scrollToHighlighted();
      }
      return KeyEventResult.handled;
    }

    // 3. Space Key: in Multi-Select, toggle highlighted item
    if (key == LogicalKeyboardKey.space) {
      if (widget.isMultiSelect) {
        if (_highlightedIndex >= 0 && _highlightedIndex < _filteredItems.length) {
          final item = _filteredItems[_highlightedIndex];
          _toggleMultiItem(item.value);
          return KeyEventResult.handled; // Swallow space so it doesn't get typed into the search query
        }
      }
      return KeyEventResult.ignored; // In single select, allows typing spaces in search query
    }

    // 4. Enter Key: select value and move to next field
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      if (widget.isMultiSelect) {
        _confirmMultiSelection();
        return KeyEventResult.handled;
      } else {
        if (_highlightedIndex >= 0 && _highlightedIndex < _filteredItems.length) {
          _selectSingleItem(_filteredItems[_highlightedIndex].value);
          return KeyEventResult.handled;
        }
      }
    }

    // 5. Escape Key: close dropdown
    if (key == LogicalKeyboardKey.escape) {
      _closeDropdown(restoreFocus: true);
      return KeyEventResult.handled;
    }

    // 6. Tab Key: select and advance focus
    if (key == LogicalKeyboardKey.tab) {
      if (widget.isMultiSelect) {
        _confirmMultiSelection();
      } else {
        if (_highlightedIndex >= 0 && _highlightedIndex < _filteredItems.length) {
          _selectSingleItem(_filteredItems[_highlightedIndex].value);
        } else {
          _closeDropdown(restoreFocus: false);
          widget.nextFocusNode?.requestFocus();
        }
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _updateHighlightedIndex(int index) {
    _highlightedIndex = index;
    if (_overlaySetState != null) {
      _overlaySetState!(() {});
    }
  }

  void _scrollToHighlighted() {
    if (!_scrollController.hasClients || _highlightedIndex < 0) return;
    final itemHeight = widget.itemHeight ?? 36.0;
    final targetOffset = _highlightedIndex * itemHeight;
    final currentOffset = _scrollController.offset;
    final viewportHeight = _scrollController.position.viewportDimension;

    if (targetOffset < currentOffset) {
      _scrollController.jumpTo(targetOffset);
    } else if (targetOffset + itemHeight > currentOffset + viewportHeight) {
      _scrollController.jumpTo(
        (targetOffset + itemHeight - viewportHeight).clamp(0.0, _scrollController.position.maxScrollExtent),
      );
    }
  }

  void _openDropdown() {
    if (!widget.isEnabled || _isOpen) return;

    final targetContext = _triggerKey.currentContext ?? context;
    final renderBox = targetContext.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

    final spaceBelow = screenSize.height - (offset.dy + size.height);
    final spaceAbove = offset.dy;
    final showAbove = spaceBelow < 200 && spaceAbove > spaceBelow;

    final double popupHeight = (showAbove ? spaceAbove - 24 : spaceBelow - 24).clamp(160.0, widget.maxHeight);
    double popupWidth = size.width < 220.0 ? 220.0 : size.width;
    if (widget.popupWidth != null && widget.popupWidth! > popupWidth) {
      popupWidth = widget.popupWidth!;
    }
    final double maxPopupWidth = screenSize.width - 24;
    if (popupWidth > maxPopupWidth) popupWidth = maxPopupWidth;

    double left = offset.dx;
    if (left + popupWidth > screenSize.width - 12) {
      left = (screenSize.width - popupWidth - 12).clamp(12.0, double.infinity);
    }

    _searchController.clear();
    _searchQuery = '';
    _filteredItems = _resolveItems();

    if (widget.isMultiSelect) {
      _selectedMulti = widget.selectedValues?.toSet() ?? {};
      _highlightedIndex = _filteredItems.isNotEmpty ? 0 : -1;
    } else {
      final curIndex = _filteredItems.indexWhere((it) => it.value == widget.value);
      _highlightedIndex = curIndex >= 0 ? curIndex : (_filteredItems.isNotEmpty ? 0 : -1);
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Dismiss barrier on outside click
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _closeDropdown(restoreFocus: true),
                child: const SizedBox.expand(),
              ),
            ),
            // Positioned popup
            Positioned(
              left: left,
              top: showAbove ? offset.dy - popupHeight - 4 : offset.dy + size.height + 4,
              width: popupWidth,
              height: popupHeight,
              child: Material(
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                color: AppColors.cardBg,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: StatefulBuilder(
                    builder: (context, setOverlayState) {
                      _overlaySetState = setOverlayState;
                      return _buildDropdownPopup(setOverlayState);
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });

    // Auto-focus the search field immediately upon opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_searchFocusNode.canRequestFocus) {
        _searchFocusNode.requestFocus();
        if (_highlightedIndex >= 0) {
          _scrollToHighlighted();
        }
      }
    });
  }

  void _closeDropdown({bool restoreFocus = false}) {
    if (!_isOpen) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _overlaySetState = null;
    if (widget.isMultiSelect && widget.onMultiChanged != null) {
      widget.onMultiChanged!(_selectedMulti.toList());
    }
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
      if (restoreFocus && _effectiveFocusNode.canRequestFocus) {
        _effectiveFocusNode.requestFocus();
      }
    }
  }

  void _selectSingleItem(T? val) {
    _closeDropdown(restoreFocus: false);
    if (widget.onChanged != null) {
      widget.onChanged!(val);
    }
    if (widget.nextFocusNode != null) {
      widget.nextFocusNode!.requestFocus();
    }
  }

  void _confirmMultiSelection() {
    _closeDropdown(restoreFocus: false);
    if (widget.onMultiChanged != null) {
      widget.onMultiChanged!(_selectedMulti.toList());
    }
    if (widget.nextFocusNode != null) {
      widget.nextFocusNode!.requestFocus();
    }
  }

  void _toggleMultiItem(T value, [StateSetter? setOverlayState]) {
    final setter = setOverlayState ?? _overlaySetState;
    if (setter != null) {
      setter(() {
        if (_selectedMulti.contains(value)) {
          _selectedMulti.remove(value);
        } else {
          _selectedMulti.add(value);
        }
      });
    } else {
      if (_selectedMulti.contains(value)) {
        _selectedMulti.remove(value);
      } else {
        _selectedMulti.add(value);
      }
    }
    if (widget.onMultiChanged != null) {
      widget.onMultiChanged!(_selectedMulti.toList());
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _onSearchChanged(String query, StateSetter setOverlayState) {
    setOverlayState(() {
      _searchQuery = query.toLowerCase().trim();
      final allItems = _resolveItems();
      if (_searchQuery.isEmpty) {
        _filteredItems = List.from(allItems);
      } else {
        _filteredItems = allItems.where((item) {
          return item.label.toLowerCase().contains(_searchQuery);
        }).toList();
      }
      _highlightedIndex = _filteredItems.isNotEmpty ? 0 : -1;
    });
    if (_filteredItems.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToHighlighted());
    }
  }

  Widget _buildDropdownPopup(StateSetter setOverlayState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Search Bar at Top
        if (widget.showSearch)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 1)),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.searchHint,
                hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                prefixIcon: Icon(Icons.search_rounded, size: 16, color: AppColors.textSecondary),
                prefixIconConstraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                suffixIcon: _searchController.text.isNotEmpty
                    ? InkWell(
                        onTap: () {
                          _searchController.clear();
                          _onSearchChanged('', setOverlayState);
                        },
                        child: Icon(Icons.close_rounded, size: 14, color: AppColors.textSecondary),
                      )
                    : null,
                suffixIconConstraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                filled: true,
                fillColor: AppColors.isDark ? AppColors.inputBg : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: AppColors.isDark ? AppColors.borderLight : AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: AppColors.isDark ? AppColors.borderLight : AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
              ),
              onChanged: (text) => _onSearchChanged(text, setOverlayState),
            ),
          ),

        // Optional fixed header (e.g. column titles)
        if (widget.popupHeader != null) widget.popupHeader!,

        // 2. Scrollable Item List
        Expanded(
          child: _filteredItems.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('No matches found', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _filteredItems.length,
                  itemExtent: widget.itemHeight ?? 36.0,
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    final isHighlighted = index == _highlightedIndex;
                    final isSelected = widget.isMultiSelect
                        ? _selectedMulti.contains(item.value)
                        : item.value == widget.value;

                    return InkWell(
                      onTap: () {
                        if (widget.isMultiSelect) {
                          _toggleMultiItem(item.value, setOverlayState);
                        } else {
                          _selectSingleItem(item.value);
                        }
                      },
                      onHover: (hovering) {
                        if (hovering && _highlightedIndex != index) {
                          setOverlayState(() {
                            _highlightedIndex = index;
                          });
                        }
                      },
                      child: Container(
                        height: widget.itemHeight ?? 36.0,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        color: isHighlighted
                            ? AppColors.primary.withValues(alpha: 0.10)
                            : (isSelected && !widget.isMultiSelect ? const Color(0xFFF1F5F9) : Colors.transparent),
                        child: Row(
                          children: [
                            if (widget.isMultiSelect) ...[
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: isSelected,
                                  onChanged: (_) => _toggleMultiItem(item.value, setOverlayState),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                                  activeColor: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (item.child != null)
                              Expanded(child: item.child!)
                            else ...[
                              if (item.icon != null) ...[
                                item.icon!,
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected || isHighlighted ? FontWeight.w600 : FontWeight.w500,
                                    color: isHighlighted
                                        ? AppColors.primary
                                        : (isSelected ? AppColors.textPrimary : AppColors.textPrimary),
                                  ),
                                ),
                              ),
                            ],
                            if (!widget.isMultiSelect && widget.popupHeader != null)
                              // Table-style list: always reserve the check-mark space so
                              // every row's columns line up with the header.
                              SizedBox(
                                width: 16,
                                child: isSelected
                                    ? Icon(Icons.check_rounded, size: 16, color: AppColors.primary)
                                    : null,
                              )
                            else if (!widget.isMultiSelect && isSelected)
                              Icon(Icons.check_rounded, size: 16, color: AppColors.primary),
                            if (item.trailing != null) item.trailing!,
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // 3. Multi-Select Bottom Footer Bar
        if (widget.isMultiSelect)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedMulti.length} selected',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                Row(
                  children: [
                    if (_selectedMulti.isNotEmpty)
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          setOverlayState(() {
                            _selectedMulti.clear();
                          });
                          if (widget.onMultiChanged != null) {
                            widget.onMultiChanged!([]);
                          }
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        child: Text('Clear', style: TextStyle(fontSize: 11, color: AppColors.danger)),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      onPressed: _confirmMultiSelection,
                      child: const Text('Done [Enter]', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTriggerContent() {
    final allItems = _resolveItems();

    Widget content;
    if (!widget.isMultiSelect) {
      if (widget.selectedItemBuilder != null && widget.value != null) {
        content = widget.selectedItemBuilder!(context, widget.value as T);
      } else {
        final matchingItem = allItems.where((it) => it.value == widget.value).firstOrNull;
        if (matchingItem != null && matchingItem.label.isNotEmpty) {
          content = Text(
            matchingItem.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          );
        } else {
          content = Text(
            widget.hintText ?? 'Select...',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          );
        }
      }
    } else {
      final selectedList = widget.selectedValues ?? _selectedMulti.toList();
      if (selectedList.isEmpty) {
        content = Text(
          widget.hintText ?? 'Select...',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        );
      } else {
        final labels = allItems.where((it) => selectedList.contains(it.value)).map((it) => it.label).toList();
        String displayText;
        if (labels.length <= 2) {
          displayText = labels.join(', ');
        } else {
          displayText = '${labels.take(2).join(', ')} (+${labels.length - 2} more)';
        }

        content = Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${labels.length}',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ],
        );
      }
    }

    return SizedBox(
      height: 20,
      child: Align(
        alignment: Alignment.centerLeft,
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasFocus = _effectiveFocusNode.hasFocus;

    Widget trigger = Focus(
      focusNode: _effectiveFocusNode,
      onKeyEvent: _handleTriggerKeyEvent,
      child: InkWell(
        key: _triggerKey,
        onTap: widget.isEnabled ? _openDropdown : null,
        borderRadius: BorderRadius.circular(6),
        child: InputDecorator(
          isFocused: hasFocus,
          isEmpty: false,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            filled: true,
            fillColor: widget.isEnabled
                ? (AppColors.isDark ? AppColors.inputBg : Colors.white)
                : (AppColors.isDark ? AppColors.inputBgDisabled : const Color(0xFFF1F5F9)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.isDark ? AppColors.borderLight : AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.isDark ? AppColors.borderLight : AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.isDark ? const Color(0xFF1E293B) : AppColors.border, width: 1),
            ),
            prefixIcon: widget.prefixIcon,
            prefixIconConstraints: widget.prefixIcon != null ? const BoxConstraints(minWidth: 32, minHeight: 32) : null,
            suffixIcon: Icon(
              _isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: widget.isEnabled ? AppColors.textSecondary : AppColors.textMuted,
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
          child: _buildTriggerContent(),
        ),
      ),
    );

    if (widget.label != null && widget.label!.isNotEmpty) {
      trigger = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 5),
          trigger,
        ],
      );
    }

    if (widget.width != null) {
      return SizedBox(width: widget.width, child: trigger);
    }

    return trigger;
  }
}

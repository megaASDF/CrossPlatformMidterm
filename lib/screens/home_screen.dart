import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/expense_list.dart';
import '../widgets/add_expense_fab.dart';
import '../widgets/expense_summary.dart';
import 'analytics_screen.dart';
import 'search_screen.dart';
import 'state_management_demo_screen.dart';
import 'expense_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _showFavoritesOnly = false;
  String _priorityFilter = 'all';
  String _sortBy = 'recent';
  bool _compact = true;
  bool _showOverview = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expenseNotifierProvider);
    final totalExpenses = ref.watch(totalExpensesProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: cs.inversePrimary,
        actions: [
          // Theme Toggle Button
          Consumer(
            builder: (context, ref, _) {
              final themeAsync = ref.watch(themeNotifierProvider);
              return themeAsync.maybeWhen(
                data: (themeMode) => IconButton(
                  icon: Icon(
                    themeMode == ThemeMode.dark 
                      ? Icons.light_mode 
                      : Icons.dark_mode,
                  ),
                  tooltip: themeMode == ThemeMode.dark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                  onPressed: () {
                    ref.read(themeNotifierProvider.notifier).toggleTheme();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          themeMode == ThemeMode.dark 
                            ? 'Switched to Light Mode' 
                            : 'Switched to Dark Mode'
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
          // Seed test data
          IconButton(
            tooltip: 'Seed test data',
            icon: const Icon(Icons.addchart),
            onPressed: _showSeedDialog,
          ),
          // Delete all
          IconButton(
            tooltip: 'Delete all expenses',
            icon: const Icon(Icons.delete_sweep),
            onPressed: _confirmDeleteAll,
          ),
          // Density toggle
          IconButton(
            tooltip: 'Toggle compact list',
            icon: Icon(_compact ? Icons.density_small : Icons.density_medium),
            onPressed: () => setState(() => _compact = !_compact),
          ),
          // Overview toggle
          IconButton(
            tooltip: _showOverview ? 'Hide overview' : 'Show overview',
            icon: Icon(_showOverview ? Icons.expand_less : Icons.expand_more),
            onPressed: () => setState(() => _showOverview = !_showOverview),
          ),
          // Search
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
          // Analytics
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
          ),
          // Demo only (removed comparison)
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu_book),
            tooltip: 'Demos',
            onSelected: (value) {
              switch (value) {
                case 'demo':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StateManagementDemoScreen()));
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'demo',
                child: Row(children: [Icon(Icons.auto_graph, size: 20), SizedBox(width: 8), Text('State Demo')]),
              ),
            ],
          ),
        ],
      ),
      body: expensesAsync.when(
        data: (expenses) => Column(
          children: [
            _buildOverview(expenses, totalExpenses, cs),
            Container(
              color: cs.surface,
              child: TabBar(
                controller: _tabController,
                labelColor: cs.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: cs.primary,
                tabs: [
                  Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.pending, size: 16), const SizedBox(width: 4),
                    Text('Unpaid (${_getUnpaidCount(expenses)})'),
                  ])),
                  Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.check_circle, size: 16), const SizedBox(width: 4),
                    Text('Paid (${_getPaidCount(expenses)})'),
                  ])),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildExpenseList(_getFilteredExpenses(expenses, false), 'No unpaid expenses! 🎉', Icons.pending_outlined),
                  _buildExpenseList(_getFilteredExpenses(expenses, true), 'No paid expenses yet.', Icons.check_circle_outline),
                ],
              ),
            ),
          ],
        ),
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading expenses...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error Loading Expenses',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(expenseNotifierProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: AddExpenseFab(
        onCreated: (isPaid) {
          if (!mounted) return;
          setState(() {
            // Ensure the new item shows
            _sortBy = 'recent';
            _showFavoritesOnly = false; // turn off favorites-only
            _priorityFilter = 'all';    // clear priority filter
          });
          _tabController.animateTo(isPaid ? 1 : 0);
        },
      ),
    );
  }

  // Dialog to choose seed amount and whether to clear existing
  void _showSeedDialog() {
    int count = 50;
    bool clearExisting = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Add Sample Expenses'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Generate random expenses from the last 6 months (up to today). Includes all priorities.'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Count:'),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: count,
                      items: const [
                        DropdownMenuItem(value: 20, child: Text('20')),
                        DropdownMenuItem(value: 50, child: Text('50')),
                        DropdownMenuItem(value: 100, child: Text('100')),
                        DropdownMenuItem(value: 200, child: Text('200')),
                      ],
                      onChanged: (v) => setStateDialog(() => count = v ?? 50),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Clear existing first'),
                  value: clearExisting,
                  onChanged: (v) => setStateDialog(() => clearExisting = v ?? false),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await ref.read(expenseNotifierProvider.notifier).seedTestExpenses(
                        count: count,
                        clearBefore: clearExisting,
                      );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added $count sample expenses')),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete All Expenses'),
        content: const Text('This will remove ALL expenses. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(expenseNotifierProvider.notifier).deleteAllExpenses();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All expenses deleted')));
              }
            },
            child: const Text('Delete All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(List<Expense> expenses, double totalExpenses, ColorScheme cs) {
    if (!_showOverview) {
      return Material(
        color: cs.surface,
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          title: Text('Overview & Filters', style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface)),
          subtitle: Text('Total: \$${totalExpenses.toStringAsFixed(2)}', style: TextStyle(color: cs.onSurfaceVariant)),
          trailing: const Icon(Icons.expand_more),
          onTap: () => setState(() => _showOverview = true),
        ),
      );
    }

    return Column(
      children: [
        ExpenseSummary(total: totalExpenses),
        _buildQuickFilters(context),
        _buildFavoritesRow(
          favorites: expenses.where((e) => e.isFavorite).take(10).toList(),
          cs: cs,
        ),
      ],
    );
  }

  // Filters UI (high contrast)
  Widget _buildQuickFilters(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final chipBg = cs.surfaceVariant.withOpacity(0.6);
    final chipSelectedBg = cs.primary;
    final chipText = cs.onSurface;
    final chipSelectedText = cs.onPrimary;
    final fieldFill = cs.surfaceVariant.withOpacity(0.35);
    final fieldText = cs.onSurface;
    final fieldHint = cs.onSurface.withOpacity(0.7);
    final iconColor = cs.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          FilterChip(
            backgroundColor: chipBg,
            selectedColor: chipSelectedBg,
            label: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(_showFavoritesOnly ? Icons.favorite : Icons.favorite_border, size: 16, color: _showFavoritesOnly ? chipSelectedText : Colors.red),
              const SizedBox(width: 4),
              Text(_showFavoritesOnly ? 'Favorites' : 'All', style: TextStyle(color: _showFavoritesOnly ? chipSelectedText : chipText, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
            selected: _showFavoritesOnly,
            onSelected: (_) => setState(() => _showFavoritesOnly = !_showFavoritesOnly),
            checkmarkColor: chipSelectedText,
          ),
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<String>(
              value: _priorityFilter,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: const OutlineInputBorder(),
                isDense: true,
                labelText: 'Priority Filter',
                labelStyle: TextStyle(color: fieldHint),
                floatingLabelStyle: TextStyle(color: fieldText),
                filled: true,
                fillColor: fieldFill,
              ),
              dropdownColor: cs.surface,
              iconEnabledColor: iconColor,
              style: TextStyle(fontSize: 13, color: fieldText),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                DropdownMenuItem(value: 'high', child: Text('High')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'low', child: Text('Low')),
              ],
              onChanged: (value) => setState(() => _priorityFilter = value!),
            ),
          ),
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              value: _sortBy,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: const OutlineInputBorder(),
                isDense: true,
                labelText: 'Sort By',
                labelStyle: TextStyle(color: fieldHint),
                floatingLabelStyle: TextStyle(color: fieldText),
                filled: true,
                fillColor: fieldFill,
              ),
              dropdownColor: cs.surface,
              iconEnabledColor: iconColor,
              style: TextStyle(fontSize: 13, color: fieldText),
              items: const [
                DropdownMenuItem(value: 'recent', child: Text('Most Recent')),
                DropdownMenuItem(value: 'priority', child: Text('Priority')),
              ],
              onChanged: (value) => setState(() => _sortBy = value!),
            ),
          ),
        ],
      ),
    );
  }

  // Favorites row — clickable to open details
  Widget _buildFavoritesRow({required List<Expense> favorites, required ColorScheme cs}) {
    if (favorites.isEmpty) return const SizedBox.shrink();
    final titleStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface);
    final subtitleStyle = TextStyle(fontSize: 11, color: cs.onSurface.withOpacity(0.7));

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        children: [
          Row(children: [
            Icon(Icons.favorite, color: Colors.red.shade400, size: 16),
            const SizedBox(width: 8),
            Text('Recent Favorites', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cs.onSurface)),
          ]),
          const SizedBox(height: 8),
          SizedBox(
            height: 88,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final e = favorites[index];
                return Container(
                  width: 170,
                  margin: EdgeInsets.only(right: index == favorites.length - 1 ? 0 : 8),
                  child: Card(
                    elevation: 1,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ExpenseDetailScreen(expenseId: e.id)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: _getCategoryColor(e.category).withOpacity(0.2),
                              child: Icon(_getCategoryIcon(e.category), size: 14, color: _getCategoryColor(e.category)),
                            ),
                            const SizedBox(width: 6),
                            Expanded(child: Text(e.title, style: titleStyle, overflow: TextOverflow.ellipsis)),
                            const Icon(Icons.favorite, color: Colors.red, size: 12),
                          ]),
                          const Spacer(),
                          Row(children: [
                            Text('\$${e.amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface)),
                            const Spacer(),
                            Text(e.category, style: subtitleStyle, overflow: TextOverflow.ellipsis),
                          ]),
                        ]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(List<Expense> expenses, String emptyMessage, IconData emptyIcon) {
    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(emptyMessage, style: TextStyle(fontSize: 16, color: Colors.grey[600]), textAlign: TextAlign.center),
          ],
        ),
      );
    }
    return ExpenseList(expenses: expenses, compact: _compact);
  }

  List<Expense> _getFilteredExpenses(List<Expense> allExpenses, bool isPaid) {
    List<Expense> filtered = allExpenses.where((expense) => expense.isPaid == isPaid).toList();
    if (_showFavoritesOnly) filtered = filtered.where((e) => e.isFavorite).toList();
    if (_priorityFilter != 'all') filtered = filtered.where((e) => e.priority == _priorityFilter).toList();

    if (_sortBy == 'priority') {
      final order = {'urgent': 0, 'high': 1, 'medium': 2, 'low': 3};
      filtered.sort((a, b) {
        final ap = order[a.priority] ?? 2;
        final bp = order[b.priority] ?? 2;
        if (ap != bp) return ap.compareTo(bp);
        return b.date.compareTo(a.date);
      });
    } else {
      filtered.sort((a, b) => b.date.compareTo(a.date));
    }
    return filtered;
  }

  int _getUnpaidCount(List<Expense> expenses) => _getFilteredExpenses(expenses, false).length;
  int _getPaidCount(List<Expense> expenses) => _getFilteredExpenses(expenses, true).length;

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Colors.orange;
      case 'transport': return Colors.blue;
      case 'shopping': return Colors.purple;
      case 'entertainment': return Colors.pink;
      case 'bills': return Colors.red;
      case 'healthcare': return Colors.green;
      case 'education': return Colors.teal;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Icons.restaurant;
      case 'transport': return Icons.directions_car;
      case 'shopping': return Icons.shopping_bag;
      case 'entertainment': return Icons.movie;
      case 'bills': return Icons.receipt;
      case 'healthcare': return Icons.local_hospital;
      case 'education': return Icons.school;
      default: return Icons.category;
    }
  }
}
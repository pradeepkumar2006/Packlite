import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/data.dart';

class SplittLiteScreen extends StatefulWidget {
  final Trip trip;
  const SplittLiteScreen({super.key, required this.trip});

  @override
  State<SplittLiteScreen> createState() => _SplittLiteScreenState();
}

class _SplittLiteScreenState extends State<SplittLiteScreen> {
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _paidBy = 'You';
  String _selectedCategory = 'Food';

  final Map<String, String> _categories = {
    'Food': 'Food',
    'Travel': 'Travel',
    'Stay': 'Stay',
    'Gear': 'Gear',
    'Misc': 'Misc',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
        ),
        title: const Text('SplittLite', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.analytics_outlined, color: Colors.black)),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 32),
                  const Text('HISTORY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, color: Colors.black38)),
                  const SizedBox(height: 16),
                  if (widget.trip.expenses.isEmpty)
                    _buildEmptyState()
                  else
                    ...widget.trip.expenses.reversed.map((e) => _buildExpenseItem(e)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseDialog,
        backgroundColor: Colors.black,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 40, offset: const Offset(0, 20)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TOTAL SPENT', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text('₹${widget.trip.totalSpent.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 42, letterSpacing: -1)),
          const SizedBox(height: 24),
          Row(
            children: [
              _summarySmall('YOU PAID', '₹${_calculateUserTotalPaid().toStringAsFixed(0)}'),
              const SizedBox(width: 32),
              _summarySmall('AVG / HEAD', '₹${(widget.trip.totalSpent / widget.trip.members.length).toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summarySmall(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
      ],
    );
  }

  Widget _buildExpenseItem(Expense e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PackLiteTheme.cardBorder, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: PackLiteTheme.background, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.receipt_long_rounded, color: Colors.black, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.description, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.2)),
                Text('${e.paidBy} paid • ${e.category}', style: TextStyle(color: PackLiteTheme.mutedText, fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${e.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black)),
              Text('₹${(e.amount/e.splitBetween.length).toStringAsFixed(0)} / head', style: TextStyle(color: PackLiteTheme.mutedText, fontSize: 10, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64),
      decoration: BoxDecoration(color: PackLiteTheme.background, borderRadius: BorderRadius.circular(32)),
      child: Column(
        children: [
          const Icon(Icons.receipt_long_rounded, size: 48, color: Colors.black12),
          const SizedBox(height: 16),
          Text('No expenses yet', style: TextStyle(color: PackLiteTheme.mutedText, fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 4),
          Text('Track your trip costs together.', style: TextStyle(color: PackLiteTheme.mutedText, fontSize: 13)),
        ],
      ),
    );
  }

  void _showAddExpenseDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
          ),
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
              const SizedBox(height: 24),
              TextField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g. Tea at roadside',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount (₹)',
                  hintText: '0',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('CATEGORY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black38)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.keys.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Tappable(
                      onTap: () => setModalState(() => _selectedCategory = cat),
                      child: Chip(
                        label: Text(cat, style: TextStyle(color: _selectedCategory == cat ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 12)),
                        backgroundColor: _selectedCategory == cat ? Colors.black : PackLiteTheme.background,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      ),
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('PAID BY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black38)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: widget.trip.members.map((m) => Tappable(
                  onTap: () => setModalState(() => _paidBy = m),
                  child: Chip(
                    label: Text(m, style: TextStyle(color: _paidBy == m ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 12)),
                    backgroundColor: _paidBy == m ? Colors.black : PackLiteTheme.background,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_descController.text.isNotEmpty && _amountController.text.isNotEmpty) {
                      final amount = double.tryParse(_amountController.text) ?? 0;
                      final newExpense = Expense(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        description: _descController.text,
                        amount: amount,
                        paidBy: _paidBy,
                        date: DateTime.now(),
                        splitBetween: widget.trip.members,
                        category: _selectedCategory,
                      );
                      setState(() {
                        widget.trip.expenses.add(newExpense);
                        _descController.clear();
                        _amountController.clear();
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Add Expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateUserTotalPaid() {
    return widget.trip.expenses.where((e) => e.paidBy == 'You').fold(0.0, (sum, e) => sum + e.amount);
  }
}

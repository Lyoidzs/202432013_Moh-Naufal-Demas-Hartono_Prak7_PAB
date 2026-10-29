
import 'package:flutter/material.dart';

void main() {
  runApp(const DompetkuApp());
}

class DompetkuApp extends StatelessWidget {
  const DompetkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dompetku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

// Model kategori tetap menggunakan struktur data sebelumnya.
class Category {
  const Category(this.name, this.imagePath);

  final String name;
  final String imagePath;
}

// Menambahkan kategori Kesehatan.
const categories = [
  Category('Makanan', 'assets/images/makanan.png'),
  Category('Transportasi', 'assets/images/transportasi.png'),
  Category('Belanja', 'assets/images/belanja.png'),
  Category('Hiburan', 'assets/images/hiburan.png'),
  Category('Kesehatan', 'assets/images/kesehatan.jpeg'),
];

// Model transaksi tetap menggunakan struktur data sebelumnya.
class Expense {
  Expense(this.title, this.amount, this.category);

  final String title;
  final double amount;
  final Category category;
}

// Format nominal Rupiah.
String formatRupiah(double value) {
  final digits = value.toStringAsFixed(0);
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    final sisa = digits.length - i;
    buffer.write(digits[i]);

    if (sisa > 1 && sisa % 3 == 1) {
      buffer.write('.');
    }
  }

  return 'Rp $buffer';
}

// Dashboard utama.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<Expense> _expenses = [
    Expense('Makan Siang', 25000, categories[0]),
    Expense('Ojek ke Kampus', 15000, categories[1]),
    Expense('Beli Buku', 85000, categories[2]),
    Expense('Nonton Bioskop', 50000, categories[3]),
    Expense('Kopi Susu', 18000, categories[0]),
  ];

  double get _total =>
      _expenses.fold(0, (sum, e) => sum + e.amount);

  Future<void> _openForm() async {
    final result = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddTransactionPage(),
      ),
    );

    // Tidak menambahkan transaksi jika formulir dibatalkan.
    if (result == null) return;

    setState(() {
      _expenses.add(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dompetku'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(
                icon: Icon(Icons.receipt_long),
                text: 'Transaksi',
              ),
              Tab(
                icon: Icon(Icons.category),
                text: 'Kategori',
              ),
              Tab(
                icon: Icon(Icons.person),
                text: 'Profil',
              ),
              Tab(
                icon: Icon(Icons.bar_chart),
                text: 'Statistik',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TransaksiTab(
              expenses: _expenses,
              total: _total,
            ),
            KategoriTab(expenses: _expenses),
            const ProfilTab(),
            StatistikTab(expenses: _expenses),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openForm,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// TAB TRANSAKSI.
class TransaksiTab extends StatelessWidget {
  const TransaksiTab({
    super.key,
    required this.expenses,
    required this.total,
  });

  final List<Expense> expenses;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: ListTile(
            leading: const Icon(
              Icons.account_balance_wallet,
              size: 36,
            ),
            title: const Text('Total Pengeluaran'),
            subtitle: Text(
              formatRupiah(total),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final e = expenses[index];

              return Card(
                child: ListTile(
                  leading: Image.asset(
                    e.category.imagePath,
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image);
                    },
                  ),
                  title: Text(e.title),
                  subtitle: Text(e.category.name),
                  trailing: Text(
                    formatRupiah(e.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// TAB KATEGORI menggunakan GridView.builder dua kolom.
class KategoriTab extends StatelessWidget {
  const KategoriTab({
    super.key,
    required this.expenses,
  });

  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final c = categories[index];

        final items = expenses
            .where((e) => e.category == c)
            .toList();

        final subtotal = items.fold<double>(
          0,
          (sum, e) => sum + e.amount,
        );

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.asset(
                    c.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image,
                        size: 40,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  c.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('${items.length} transaksi'),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(formatRupiah(subtotal)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// TAB PROFIL.
class ProfilTab extends StatelessWidget {
  const ProfilTab({super.key});

  static const coverUrl =
      'https://raw.githubusercontent.com/flutter/website/main/examples/layout/lakes/step6/images/lake.jpg';

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Image.network(
          coverUrl,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;

            return const SizedBox(
              height: 180,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox(
              height: 180,
              child: Center(
                child: Icon(Icons.broken_image, size: 48),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const Center(
          child: CircleAvatar(
            radius: 48,
            backgroundImage: AssetImage(
              'assets/images/avatar.png',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Moh Naufal Demas Hartono',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Text(
          'Institut Teknologi PLN',
          textAlign: TextAlign.center,
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.school),
                  title: Text('Program Studi'),
                  subtitle: Text('Sistem Informasi'),
                ),
                ListTile(
                  leading: Icon(Icons.book),
                  title: Text('Mata Kuliah'),
                  subtitle: Text('Pemrograman Aplikasi Bergerak'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// TAB STATISTIK menampilkan transaksi dengan nominal terbesar.
class StatistikTab extends StatelessWidget {
  const StatistikTab({
    super.key,
    required this.expenses,
  });

  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(
        child: Text('Belum ada transaksi.'),
      );
    }

    // Mencari transaksi dengan nominal paling besar.
    final terbesar = expenses.reduce(
      (a, b) => a.amount >= b.amount ? a : b,
    );

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_events,
                  size: 60,
                  color: Colors.amber,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pengeluaran Terbesar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Image.asset(
                  terbesar.category.imagePath,
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.broken_image,
                      size: 48,
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  terbesar.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text('Kategori: ${terbesar.category.name}'),
                const SizedBox(height: 16),
                Text(
                  formatRupiah(terbesar.amount),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// HALAMAN TAMBAH TRANSAKSI.
// Struktur formulir dan data tetap dipertahankan.
class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() =>
      _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  Category _selectedCategory = categories.first;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(
      _amountController.text.trim(),
    );

    Navigator.pop(
      context,
      Expense(
        _titleController.text.trim(),
        amount,
        _selectedCategory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul transaksi',
              ),
              validator: (v) {
                return v == null || v.trim().isEmpty
                    ? 'Judul wajib diisi'
                    : null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nominal',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Nominal wajib diisi';
                }

                final n = double.tryParse(v.trim());

                if (n == null || n <= 0) {
                  return 'Nominal harus angka > 0';
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Category>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategori',
              ),
              items: [
                for (final c in categories)
                  DropdownMenuItem(
                    value: c,
                    child: Row(
                      children: [
                        Image.asset(
                          c.imagePath,
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.broken_image,
                              size: 24,
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(c.name),
                      ],
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

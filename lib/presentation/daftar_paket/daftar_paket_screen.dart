import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'daftar_paket_provider.dart';
import '../beranda/beranda_provider.dart';
import '../../app/theme.dart';
import '../../utils/format_rupiah.dart';
import '../widgets/chip_risiko.dart';

class DaftarPaketScreen extends StatefulWidget {
  const DaftarPaketScreen({super.key});

  @override
  State<DaftarPaketScreen> createState() => _DaftarPaketScreenState();
}

class _DaftarPaketScreenState extends State<DaftarPaketScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = Provider.of<BerandaProvider>(context, listen: false).paketList;
    return ChangeNotifierProvider<DaftarPaketProvider>(
      create: (context) => DaftarPaketProvider()..inisialisasi(list),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Daftar Paket Kerja"),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list_alt),
                tooltip: "Saring Paket",
                onPressed: () => _tampilkanFilterBottomSheet(context),
              ),
            ],
          ),
          body: Consumer<DaftarPaketProvider>(
            builder: (context, provider, child) {
              final list = provider.filteredList;

              return Column(
                children: [
                  // Sticky Search Bar & Sort options
                  _buildSearchAndSortBar(context, provider),

                  // Active filters visual feedback
                  _buildActiveFiltersRow(provider),

                  // List of packets
                  Expanded(
                    child: list.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: list.length,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemBuilder: (context, index) {
                              final paket = list[index];
                              return _buildPaketCard(paket);
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSearchAndSortBar(BuildContext context, DaftarPaketProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Cari nama paket...",
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearchQuery("");
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (val) {
                    provider.setSearchQuery(val);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                label: "Tombol filter pengadaan",
                child: InkWell(
                  onTap: () => _tampilkanFilterBottomSheet(context),
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                      color: warnaLatarKartu,
                    ),
                    child: const Icon(Icons.tune_rounded, color: warnaPrimer, size: 22),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                "Urutkan:",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black45),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSortChip(provider, 0, "Nilai Terbesar"),
                      const SizedBox(width: 6),
                      _buildSortChip(provider, 1, "Nilai Terkecil"),
                      const SizedBox(width: 6),
                      _buildSortChip(provider, 2, "Nama A-Z"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(DaftarPaketProvider provider, int value, String label) {
    final isSelected = provider.selectedSort == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 11,
        ),
      ),
      selected: isSelected,
      selectedColor: warnaPrimer,
      backgroundColor: warnaLatarKartu,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      onSelected: (_) => provider.setSort(value),
    );
  }

  Widget _buildActiveFiltersRow(DaftarPaketProvider provider) {
    final bool hasSkpd = provider.selectedSkpd.isNotEmpty;
    final bool hasMetode = provider.selectedMetode.isNotEmpty;
    final bool hasTingkat = provider.selectedTingkat != -1;

    if (!hasSkpd && !hasMetode && !hasTingkat) return const SizedBox.shrink();

    String getTingkatLabel(int t) {
      if (t == 3) return "Perlu Perhatian Segera";
      if (t == 2) return "Tinggi";
      if (t == 1) return "Waspada";
      return "Wajar";
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            "Penyaringan:",
            style: TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.bold),
          ),
          if (hasSkpd)
            _buildActiveChip(
              "SKPD: ${provider.selectedSkpd}",
              () => provider.setSkpd(""),
            ),
          if (hasMetode)
            _buildActiveChip(
              "Metode: ${provider.selectedMetode}",
              () => provider.setMetode(""),
            ),
          if (hasTingkat)
            _buildActiveChip(
              "Tingkat: ${getTingkatLabel(provider.selectedTingkat)}",
              () => provider.setTingkat(-1),
            ),
          Semantics(
            label: "Reset semua filter",
            child: InkWell(
              onTap: () => provider.resetFilters(),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Text(
                  "Hapus Semua",
                  style: TextStyle(fontSize: 11, color: warnaKritis, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveChip(String label, VoidCallback onDeleted) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: warnaAksen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: warnaAksen.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 100),
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, color: warnaPrimer, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Semantics(
            label: "Hapus filter",
            child: GestureDetector(
              onTap: onDeleted,
              child: const Icon(Icons.close_rounded, size: 12, color: warnaPrimer),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaketCard(paket) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    paket.namaPaket,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: warnaPrimer,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                ChipRisiko(tingkat: paket.tingkatKejanggalan),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "SKPD: ${paket.namaSatuanKerja}",
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Metode: ${paket.metodePengadaan}",
                  style: const TextStyle(fontSize: 11, color: Colors.black38),
                ),
                Text(
                  formatRupiah(paket.totalNilai),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: warnaAksen,
                  ),
                ),
              ],
            ),
            if (paket.catatanKejanggalan.isNotEmpty) ...[
              const Divider(height: 16, thickness: 0.5),
              ...paket.catatanKejanggalan.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.circle, size: 6, color: warnaKritis),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            c,
                            style: const TextStyle(fontSize: 11, color: warnaKritis, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: Colors.black26),
          SizedBox(height: 12),
          Text(
            "Tidak Ada Paket Yang Sesuai",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          SizedBox(height: 4),
          Text(
            "Coba ubah kata pencarian atau bersihkan penyaringan.",
            style: TextStyle(fontSize: 12, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  void _tampilkanFilterBottomSheet(BuildContext outerContext) {
    final provider = Provider.of<DaftarPaketProvider>(outerContext, listen: false);

    showModalBottomSheet(
      context: outerContext,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Saring Data RUP",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: warnaPrimer),
                      ),
                      const Divider(height: 24),

                      // Dropdown SKPD
                      const Text("Satuan Kerja (SKPD)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: provider.selectedSkpd,
                        isExpanded: true,
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        items: provider.allSkpd.map((skpd) {
                          return DropdownMenuItem<String>(
                            value: skpd,
                            child: Text(
                              skpd.isEmpty ? "Semua SKPD" : skpd,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setModalState(() {
                            provider.setSkpd(val ?? "");
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Dropdown Metode
                      const Text("Metode Pengadaan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: provider.selectedMetode,
                        isExpanded: true,
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        items: provider.allMetode.map((m) {
                          return DropdownMenuItem<String>(
                            value: m,
                            child: Text(
                              m.isEmpty ? "Semua Metode" : m,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setModalState(() {
                            provider.setMetode(val ?? "");
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Dropdown Tingkat Kejanggalan
                      const Text("Tingkat Kejanggalan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        initialValue: provider.selectedTingkat,
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        items: [
                          const DropdownMenuItem<int>(value: -1, child: Text("Semua Tingkat", style: TextStyle(fontSize: 13))),
                          const DropdownMenuItem<int>(value: 3, child: Text("Perlu Perhatian Segera", style: TextStyle(fontSize: 13))),
                          const DropdownMenuItem<int>(value: 2, child: Text("Tinggi (Perlu Diperiksa)", style: TextStyle(fontSize: 13))),
                          const DropdownMenuItem<int>(value: 1, child: Text("Waspada (Pantau)", style: TextStyle(fontSize: 13))),
                          const DropdownMenuItem<int>(value: 0, child: Text("Wajar (Normal)", style: TextStyle(fontSize: 13))),
                        ],
                        onChanged: (val) {
                          setModalState(() {
                            provider.setTingkat(val ?? -1);
                          });
                        },
                      ),
                      const SizedBox(height: 32),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              child: const Text("Reset"),
                              onPressed: () {
                                setModalState(() {
                                  provider.resetFilters();
                                  _searchController.clear();
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              child: const Text("Terapkan"),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

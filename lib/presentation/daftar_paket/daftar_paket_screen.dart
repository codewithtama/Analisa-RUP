import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'daftar_paket_provider.dart';
import '../beranda/beranda_provider.dart';
import '../../app/theme.dart';
import '../../utils/format_rupiah.dart';
import '../../utils/export_service.dart';
import '../widgets/chip_risiko.dart';
import '../widgets/dialog_detail_paket.dart';

class DaftarPaketScreen extends StatefulWidget {
  final int? tingkatKejanggalan;
  const DaftarPaketScreen({super.key, this.tingkatKejanggalan});

  @override
  State<DaftarPaketScreen> createState() => _DaftarPaketScreenState();
}

class _DaftarPaketScreenState extends State<DaftarPaketScreen> {
  final TextEditingController _kodeRupController = TextEditingController();
  final TextEditingController _namaPaketController = TextEditingController();

  @override
  void dispose() {
    _kodeRupController.dispose();
    _namaPaketController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = Provider.of<BerandaProvider>(context, listen: false).paketList;
    return ChangeNotifierProvider<DaftarPaketProvider>(
      create: (context) => DaftarPaketProvider()..inisialisasi(list, tingkatKejanggalan: widget.tingkatKejanggalan),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: const Text("Daftar Paket Kerja"),
            elevation: 0,
            actions: [
              Consumer<DaftarPaketProvider>(
                builder: (context, provider, child) {
                  return IconButton(
                    icon: const Icon(Icons.download_rounded),
                    tooltip: 'Ekspor Data (Excel)',
                    onPressed: () async {
                      if (provider.filteredList.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tidak ada data untuk diekspor.')),
                        );
                        return;
                      }
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sedang mengekspor data...')),
                      );
                      
                      String filename = 'Ekspor_RUP_${DateTime.now().millisecondsSinceEpoch}';
                      String? path = await ExportService.exportToExcel(
                        provider.filteredList, 
                        filename
                      );
                      
                      if (context.mounted) {
                        if (path != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Berhasil diekspor, silakan pilih tempat menyimpan.')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Gagal mengekspor data.')),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ],
          ),
          body: Consumer<DaftarPaketProvider>(
            builder: (context, provider, child) {
              final visibleList = provider.visibleList;

              return Column(
                children: [
                  // New Filter ExpansionTile
                  _buildFilterExpansionTile(provider),

                  // Sort Options
                  _buildSortRow(provider),

                  // List of packets
                  Expanded(
                    child: visibleList.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: visibleList.length + (provider.hasMore ? 1 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemBuilder: (context, index) {
                              if (index < visibleList.length) {
                                final paket = visibleList[index];
                                return _buildPaketCard(paket);
                              } else {
                                return _buildLoadMoreWidget(provider);
                              }
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

  Widget _buildFilterExpansionTile(DaftarPaketProvider provider) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          title: const Text(
            "Filter data",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: warnaPrimer),
          ),
          subtitle: const Text(
            "Atur filter dan pencarian rup untuk memperbarui ringkasan dan tabel.",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildDropdown(
                  "Tahun Anggaran",
                  provider.selectedTahunAnggaran,
                  provider.allTahunAnggaran,
                  "Pilih Tahun",
                  (val) => provider.setTahunAnggaran(val ?? ""),
                ),
                _buildDropdown(
                  "Instansi",
                  provider.selectedInstansi,
                  provider.allInstansi,
                  "Pilih Instansi",
                  (val) => provider.setInstansi(val ?? ""),
                ),
                _buildDropdown(
                  "Satuan Kerja",
                  provider.selectedSatuanKerja,
                  provider.filteredSatuanKerjaList,
                  provider.selectedInstansi.isEmpty ? "Semua Satuan Kerja" : "Pilih Satuan Kerja",
                  (val) => provider.setSatuanKerja(val ?? ""),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildDropdown(
                  "Cara Pengadaan",
                  provider.selectedCaraPengadaan,
                  provider.allCaraPengadaan,
                  "Semua",
                  (val) => provider.setCaraPengadaan(val ?? ""),
                ),
                _buildDropdown(
                  "Sumber Dana",
                  provider.selectedSumberDana,
                  provider.allSumberDana,
                  "Semua sumber dana",
                  (val) => provider.setSumberDana(val ?? ""),
                ),
                _buildDropdown(
                  "Tingkat Risiko",
                  _mapTingkatToString(provider.selectedTingkatKejanggalan),
                  ["Semua", "Perlu Perhatian Segera", "Perlu Diperiksa", "Pantau", "Wajar"],
                  "Semua",
                  (val) => provider.setTingkatKejanggalan(_mapStringToTingkat(val ?? "")),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "RENTANG PAGU ANGGARAN",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${formatRupiah(provider.selectedMinBudget)} s/d ${formatRupiah(provider.selectedMaxBudget)}",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: warnaAksen),
            ),
            const SizedBox(height: 4),
            RangeSlider(
              activeColor: warnaAksen,
              inactiveColor: Colors.grey.shade200,
              min: provider.minBudgetLimit,
              max: provider.maxBudgetLimit,
              values: RangeValues(provider.selectedMinBudget, provider.selectedMaxBudget),
              onChanged: (values) {
                provider.setBudgetRange(values.start, values.end);
              },
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "PENCARIAN PAKET",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    "Kode RUP",
                    _kodeRupController,
                    (val) => provider.setSearchKodeRup(val),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: _buildTextField(
                    "Nama paket",
                    _namaPaketController,
                    (val) => provider.setSearchNamaPaket(val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  _kodeRupController.clear();
                  _namaPaketController.clear();
                  provider.resetFilters();
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Hapus Semua Filter"),
                style: TextButton.styleFrom(foregroundColor: warnaKritis),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, String hint, ValueChanged<String?> onChanged) {
    return SizedBox(
      width: 160, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value.isEmpty && items.isNotEmpty && items.contains("") ? "" : (value.isEmpty ? null : value),
                hint: Text(hint, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 20),
                items: items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item.isEmpty ? hint : item, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: label == "Kode RUP" ? "Kode RUP" : "Cari nama paket...",
            hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: warnaPrimer),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSortRow(DaftarPaketProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
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
      backgroundColor: Colors.white,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      onSelected: (_) => provider.setSort(value),
    );
  }

  Widget _buildPaketCard(paket) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => DialogDetailPaket.tampilkan(context, paket),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "RUP: ${paket.kodeRup.isEmpty ? '-' : paket.kodeRup}",
                      style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Instansi: ${paket.namaInstansi.isEmpty ? '-' : paket.namaInstansi}",
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "SKPD: ${paket.namaSatuanKerja}",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Cara: ${paket.caraPengadaan.isEmpty ? '-' : paket.caraPengadaan}",
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
                const Divider(height: 24, thickness: 0.5),
                ...paket.catatanKejanggalan.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
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

  Widget _buildLoadMoreWidget(DaftarPaketProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "Menampilkan ${provider.visibleList.length} dari ${provider.totalCount} paket",
            style: const TextStyle(fontSize: 12, color: Colors.black45),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              provider.loadMore();
            },
            child: const Text("Muat Lebih Banyak"),
          ),
        ],
      ),
    );
  }

  String _mapTingkatToString(int? tingkat) {
    switch (tingkat) {
      case 3:
        return "Perlu Perhatian Segera";
      case 2:
        return "Perlu Diperiksa";
      case 1:
        return "Pantau";
      case 0:
        return "Wajar";
      default:
        return "Semua";
    }
  }

  int? _mapStringToTingkat(String val) {
    switch (val) {
      case "Perlu Perhatian Segera":
        return 3;
      case "Perlu Diperiksa":
        return 2;
      case "Pantau":
        return 1;
      case "Wajar":
        return 0;
      default:
        return null;
    }
  }
}

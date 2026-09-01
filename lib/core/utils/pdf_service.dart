import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:flutter/services.dart';

class PdfService {
  static Future<void> printDokumen(Map<String, dynamic> dokumenData) async {
    final pdf = pw.Document();

    // Load logo image
    pw.MemoryImage? logoImage;
    try {
      final ByteData data = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(data.buffer.asUint8List());
    } catch (e) {
      // print('Failed to load logo: $e');
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(dokumenData, logoImage),
                pw.SizedBox(height: 30),
                _buildInfoSection(dokumenData),
                pw.SizedBox(height: 20),
                _buildItemTable(dokumenData),
                pw.Spacer(),
                _buildSignatures(),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${dokumenData['jenis_dokumen']}_${dokumenData['nomor_dokumen']}',
    );
  }

  static pw.Widget _buildHeader(Map<String, dynamic> data, pw.MemoryImage? logoImage) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (logoImage != null) ...[
              pw.Image(logoImage, width: 60, height: 60),
              pw.SizedBox(width: 16),
            ],
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PT JAKHI PASARIBAWA',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
                ),
                pw.Text('Logistik Navagreen', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                pw.Text('Jl. Industri No. 123, Yogyakarta', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              ],
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              data['jenis_dokumen']?.toUpperCase() ?? 'DOKUMEN',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
            ),
            pw.SizedBox(height: 4),
            pw.Text('NO: ${data['nomor_dokumen']}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.Text('TANGGAL: ${data['tanggal_buat']?.toString().split(' ')[0] ?? '-'}', style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInfoSection(Map<String, dynamic> data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Tujuan:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
              pw.SizedBox(height: 4),
              pw.Text(data['tujuan_pengiriman'] ?? '-', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Supir / Pengirim:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
              pw.SizedBox(height: 4),
              pw.Text(data['nama_supir'] ?? '-', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildItemTable(Map<String, dynamic> data) {
    // In our simplified system, one document has one item type for now.
    // If the system expands, this would iterate over a list of items.
    
    // For now we just use a placeholder text if we don't have the exact item details.
    // Ideally we would have 'nama_barang', 'kode_barang', 'jumlah' in the data.
    // Since laporan.php doesn't join with barang table right now, we might not have it.
    // But we'll try to show it if available, otherwise just general info.

    return pw.TableHelper.fromTextArray(
      headers: ['No', 'Kode Barang', 'Deskripsi Barang', 'Kuantitas', 'Keterangan'],
      data: [
        [
          '1',
          data['kode_barang'] ?? '-',
          data['nama_barang'] ?? '-',
          data['jumlah'] ?? '-',
          '-',
        ],
      ],
      border: pw.TableBorder.all(color: PdfColors.grey400),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.teal800),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.center,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
      },
    );
  }

  static pw.Widget _buildSignatures() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _signatureBox('Dibuat Oleh', '( Admin Logistik )'),
        _signatureBox('Dikirim Oleh', '( Supir / Kurir )'),
        _signatureBox('Diterima Oleh', '( Penerima )'),
      ],
    );
  }

  static pw.Widget _signatureBox(String title, String name) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 60),
        pw.Container(
          width: 100,
          decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1))),
        ),
        pw.SizedBox(height: 4),
        pw.Text(name, style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }
}

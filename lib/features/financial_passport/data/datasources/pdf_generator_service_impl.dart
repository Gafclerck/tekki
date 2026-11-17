import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tekki/features/financial_passport/domain/entities/signed_passport_payload_entity.dart';
import 'package:tekki/features/financial_passport/domain/services/pdf_generator_service.dart';

/// Implémentation concrète de [IPdfGeneratorService] produisant le document
/// vectoriel A4 certifié officiel aux couleurs de Tekki (#133E59, #FF7A41).
class PdfGeneratorServiceImpl implements IPdfGeneratorService {
  const PdfGeneratorServiceImpl();

  // Palette officielle Tekki
  static const PdfColor _primaryColor = PdfColor.fromInt(0xFF133E59);
  static const PdfColor _accentColor = PdfColor.fromInt(0xFFFF7A41);
  static const PdfColor _secondaryColor = PdfColor.fromInt(0xFF0D5942);
  static const PdfColor _backgroundColor = PdfColor.fromInt(0xFFF8FAFC);
  static const PdfColor _surfaceColor = PdfColor.fromInt(0xFFFFFFFF);
  static const PdfColor _borderColor = PdfColor.fromInt(0xFFCBD5E1);
  static const PdfColor _textPrimaryColor = PdfColor.fromInt(0xFF0F172A);
  static const PdfColor _textMutedColor = PdfColor.fromInt(0xFF64748B);

  @override
  Future<Uint8List> generatePassportPdf({
    required SignedPassportPayloadEntity payload,
    String? shopName,
    DateTime? emissionDate,
  }) async {
    final pdf = pw.Document(
      title: 'Attestation Passeport Financier Tekki - ${payload.shopId}',
      author: 'Tekki Tiers de Confiance',
      creator: 'Application Mobile Tekki',
    );

    final now = (emissionDate ?? DateTime.now()).toUtc();
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(now);
    final passport = payload.passport;
    final breakdown = passport.breakdown;
    final effectiveShopName = (shopName != null && shopName.trim().isNotEmpty)
        ? shopName.trim()
        : 'Établissement #${payload.shopId}';

    final hexSignature = _bytesToHex(payload.signature);
    final hexPublicKey = _bytesToHex(payload.publicKey);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // 1. En-tête officiel Tekki
              _buildHeader(formattedDate),
              pw.SizedBox(height: 12),

              // 2. Encadré Boutique & Établissement
              _buildMerchantCard(effectiveShopName, payload.shopId),
              pw.SizedBox(height: 12),

              // 3. Carte Héros Score Global & Série
              _buildScoreHero(
                passport.overallScore,
                passport.streak,
                passport.totalClosures,
              ),
              pw.SizedBox(height: 12),

              // 4. Grille des 4 Piliers de Notation
              _buildPillarsGrid(breakdown),
              pw.SizedBox(height: 12),

              // 5. Bloc Sécurité & QR Code Infalsifiable
              _buildSecurityAndQrBlock(
                payload.base45Payload,
                payload.visualPin,
                hexSignature,
                hexPublicKey,
              ),
              pw.Spacer(),

              // 6. Mentions Légales et Tiers de Confiance
              _buildLegalFooter(payload.shopId),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(String formattedDate) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'TEKKI',
              style: const pw.TextStyle(
                fontSize: 26,
                fontWeight: pw.FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            pw.Text(
              'PASSEPORT FINANCIER & NOTATION DE RÉPUTATION',
              style: const pw.TextStyle(
                fontSize: 8.5,
                fontWeight: pw.FontWeight.bold,
                color: _accentColor,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: pw.BoxDecoration(
            color: _backgroundColor,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            border: pw.Border.all(color: _secondaryColor, width: 1),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'CERTIFIÉ INFALSIFIABLE D2D',
                style: const pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: _secondaryColor,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Émis le $formattedDate UTC',
                style: const pw.TextStyle(fontSize: 8, color: _textMutedColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildMerchantCard(String shopName, String shopId) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: _backgroundColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: _borderColor, width: 0.8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'COMMERÇANT CERTIFIÉ',
                style: const pw.TextStyle(
                  fontSize: 7.5,
                  fontWeight: pw.FontWeight.bold,
                  color: _textMutedColor,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                shopName,
                style: const pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'IDENTIFIANT BOUTIQUE',
                style: const pw.TextStyle(
                  fontSize: 7.5,
                  fontWeight: pw.FontWeight.bold,
                  color: _textMutedColor,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                shopId,
                style: const pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: _textPrimaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildScoreHero(int overallScore, int streak, int totalClosures) {
    final ratingLabel = _getRatingLabel(overallScore);

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: const pw.BoxDecoration(
        color: _primaryColor,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 5,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'SCORE GLOBAL DE RÉPUTATION',
                  style: const pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      '$overallScore',
                      style: const pw.TextStyle(
                        fontSize: 34,
                        fontWeight: pw.FontWeight.bold,
                        color: _accentColor,
                      ),
                    ),
                    pw.Text(
                      ' / 100',
                      style: const pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: const pw.BoxDecoration(
                    color: _secondaryColor,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Text(
                    ratingLabel,
                    style: const pw.TextStyle(
                      fontSize: 8.5,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.Container(
            width: 1,
            height: 55,
            color: const PdfColor.fromInt(0x40FFFFFF),
            margin: const pw.EdgeInsets.symmetric(horizontal: 14),
          ),
          pw.Expanded(
            flex: 6,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text(
                      '🔥 Série active : ',
                      style: const pw.TextStyle(
                        fontSize: 9.5,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.Text(
                      '$streak jours consécutifs',
                      style: const pw.TextStyle(
                        fontSize: 9.5,
                        fontWeight: pw.FontWeight.bold,
                        color: _accentColor,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  children: [
                    pw.Text(
                      '📊 Clôtures (30j) : ',
                      style: const pw.TextStyle(
                        fontSize: 9.5,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.Text(
                      '$totalClosures clôtures validées',
                      style: const pw.TextStyle(
                        fontSize: 9.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  children: [
                    pw.Text(
                      '🛡️ Statut : ',
                      style: const pw.TextStyle(
                        fontSize: 9.5,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.Text(
                      'Passeport Officiel Actif',
                      style: const pw.TextStyle(
                        fontSize: 9.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPillarsGrid(dynamic breakdown) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DÉTAIL DES 4 PILIERS DE NOTATION OPÉRATIONNELLE',
          style: const pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: _primaryColor,
            letterSpacing: 0.5,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: _borderColor, width: 0.5),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: _backgroundColor),
              children: [
                _buildTableHeaderCell('Pilier Évalué'),
                _buildTableHeaderCell('Pondération'),
                _buildTableHeaderCell('Score / 100'),
                _buildTableHeaderCell('Contribution'),
              ],
            ),
            _buildTableRow(
              '1. Régularité des clôtures journalières',
              '35 %',
              '${breakdown.closureScore}',
              '${breakdown.closureContribution.toStringAsFixed(1)} pts',
            ),
            _buildTableRow(
              '2. Vélocité de recouvrement Karné Bor',
              '40 %',
              '${breakdown.debtScore}',
              '${breakdown.debtContribution.toStringAsFixed(1)} pts',
            ),
            _buildTableRow(
              '3. Stabilité géographique GPS anti-fraude',
              '15 %',
              '${breakdown.gpsScore}',
              '${breakdown.gpsContribution.toStringAsFixed(1)} pts',
            ),
            _buildTableRow(
              '4. Discipline d\'encaisse déclarée',
              '10 %',
              '${breakdown.cashScore}',
              '${breakdown.cashContribution.toStringAsFixed(1)} pts',
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
          color: _primaryColor,
        ),
      ),
    );
  }

  pw.TableRow _buildTableRow(
    String pillar,
    String weight,
    String score,
    String contribution,
  ) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
          child: pw.Text(
            pillar,
            style: const pw.TextStyle(fontSize: 8, color: _textPrimaryColor),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
          child: pw.Text(
            weight,
            style: const pw.TextStyle(fontSize: 8, color: _textMutedColor),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
          child: pw.Text(
            score,
            style: const pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
          child: pw.Text(
            contribution,
            style: const pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: _secondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSecurityAndQrBlock(
    String base45Payload,
    String visualPin,
    String hexSignature,
    String hexPublicKey,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _surfaceColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: _borderColor, width: 0.8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // QR Code vectoriel autonome
          pw.Container(
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: _borderColor, width: 1),
            ),
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: base45Payload,
              width: 105,
              height: 105,
            ),
          ),
          pw.SizedBox(width: 12),
          // Preuve cryptographique & PIN
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'PREUVE CRYPTOGRAPHIQUE ASYMÉTRIQUE',
                      style: const pw.TextStyle(
                        fontSize: 8.5,
                        fontWeight: pw.FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: const pw.BoxDecoration(
                        color: _accentColor,
                        borderRadius: pw.BorderRadius.all(
                          pw.Radius.circular(4),
                        ),
                      ),
                      child: pw.Text(
                        'PIN ANTI-REJEU : $visualPin',
                        style: const pw.TextStyle(
                          fontSize: 8.5,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Algorithme : Ed25519 (RFC 8032) • Sérialisation : CBOR • Encodage : Base45 (RFC 9285)',
                  style: const pw.TextStyle(
                    fontSize: 7,
                    color: _textMutedColor,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Clé Publique Boutique (32 octets hex) :',
                  style: const pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                pw.Text(
                  hexPublicKey,
                  style: const pw.TextStyle(
                    fontSize: 6.5,
                    color: _textPrimaryColor,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Empreinte de Signature Ed25519 (64 octets hex) :',
                  style: const pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                pw.Text(
                  _wrapHex(hexSignature, 48),
                  style: const pw.TextStyle(
                    fontSize: 6.5,
                    color: _textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildLegalFooter(String shopId) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(height: 0.8, color: _borderColor),
        pw.SizedBox(height: 6),
        pw.Text(
          'Tekki agit en tiers de confiance technologique indépendant. Aucun décaissement de prêt ni portage de risque de crédit n\'est effectué dans l\'application. '
          'Ce document atteste de la régularité et de la discipline de gestion du commerçant. Scannable et vérifiable hors-ligne d\'appareil à appareil '
          'sans connexion Internet par tout agent de crédit ou grossiste partenaire équipé de la solution de vérification Tekki.',
          style: const pw.TextStyle(
            fontSize: 6.8,
            color: _textMutedColor,
            lineSpacing: 1.2,
          ),
          textAlign: pw.TextAlign.justify,
        ),
      ],
    );
  }

  static String _getRatingLabel(int score) {
    if (score >= 80) return 'ÉLITE FINANCIÈRE';
    if (score >= 70) return 'CONFIRMÉ & TRÈS FIABLE';
    if (score >= 60) return 'RÉGULIER & SOLVABLE';
    return 'STANDARD';
  }

  static String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
  }

  static String _wrapHex(String hex, int wrapLength) {
    final buffer = StringBuffer();
    for (int i = 0; i < hex.length; i += wrapLength) {
      final end = (i + wrapLength < hex.length) ? i + wrapLength : hex.length;
      buffer.writeln(hex.substring(i, end));
    }
    return buffer.toString().trimRight();
  }
}

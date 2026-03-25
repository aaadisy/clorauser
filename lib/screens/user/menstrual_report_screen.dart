import 'dart:io';
import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:menstrual_cycle_widget/ui/calender_view/calender_date_utils.dart';
import 'package:menstrual_cycle_widget/utils/colors_utils.dart';
import 'package:menstrual_cycle_widget/utils/model/periods_date_range.dart';
import 'package:menstrual_cycle_widget/widget_languages/widget_base_language.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../../ads/facebook_ads_manager.dart';
import '../../extensions/new_colors.dart';
import '../../languageConfiguration/LanguageDataConstant.dart';
import '../../main.dart';
import '../../model/user/cycle_report_model.dart';
import 'package:open_file/open_file.dart';
import 'package:menstrual_cycle_widget/ui/model/phases_percentage.dart';

import '../../utils/app_common.dart';
import '../../utils/app_config.dart';
import '../../utils/app_constants.dart';

class MenstrualReportScreen extends StatefulWidget {
  const MenstrualReportScreen({super.key});

  @override
  State<MenstrualReportScreen> createState() => _MenstrualReportScreenState();
}

class _MenstrualReportScreenState extends State<MenstrualReportScreen> {
  Future<MenstrualCycleSummaryData?>? _cycleReportFuture;
  String today = DateFormat('dd-MM-yyyy').format(DateTime.now());

  String getAppUrlForDownload() {
    final String storeUrl = Theme.of(context).platform == TargetPlatform.iOS
        ? iOSLiveUrl!
        : androidLiveUrl!;
    return storeUrl;
  }

  Future<MenstrualCycleSummaryData?> getCycleReportData() async {
    try {
      Map<String, dynamic> reportData =
          await instance.getMenstrualCycleReportData(numberOfCycle: 5);

      MenstrualCycleSummaryData data =
          MenstrualCycleSummaryData.fromJson(reportData);

      return data;
    } catch (e) {
      printEraAppLogs('Error fetching cycle report: $e');
      return null;
    }
  }

  pw.Widget buildPdfDivider() {
    return pw.Divider(
      height: 1,
      thickness: 0.8,
      color: PdfColors.grey,
      borderStyle: pw.BorderStyle.solid,
    );
  }

  pw.Widget getPdfCycleHistoryView(
      int index, List<PeriodsDateRange> allPeriodRange) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        index == 0
            ? pw.Text(
                "${WidgetBaseLanguage.currentCycle}: ${allPeriodRange[index].cycleLength!} ${WidgetBaseLanguage.graphCycleDaysCycle}",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                  font: PdfFontHelper.getFontForLanguage(
                    getStringAsync(SELECTED_LANGUAGE_CODE),
                  ),
                ),
              )
            : pw.Text(
                "${allPeriodRange[index].cycleLength!} ${WidgetBaseLanguage.graphCycleDaysCycle}",
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                    font: PdfFontHelper.getFontForLanguage(
                      getStringAsync(SELECTED_LANGUAGE_CODE),
                    )),
              ),

        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 5),
          child: pw.SizedBox(
            height: 8,
            child: pw.Row(
              children: List.generate(
                allPeriodRange[index].cycleLength!,
                (inx) => pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 2),
                  child: pw.Container(
                    width: 8,
                    height: 8,
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(4), // 8/2 = 4
                      color: (inx > allPeriodRange[index].periodDuration!)
                          ? PdfColor.fromInt(0x26212121)
                          : PdfColor.fromRYB(
                              defaultMenstruationColor.r,
                              defaultMenstruationColor.b,
                              defaultMenstruationColor.g,
                              defaultMenstruationColor.a),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Date range text
        index != 0
            ? pw.Text(
                "${CalenderDateUtils.formatFirstDay(DateTime.parse(allPeriodRange[index].cycleStartDate!))} - ${CalenderDateUtils.formatFirstDay(DateTime.parse(allPeriodRange[index].cycleEndDate!))}",
                style: pw.TextStyle(
                    color: PdfColor.fromInt(0xA6212121),
                    fontSize: 10,
                    font: PdfFontHelper.getFontForLanguage(
                      getStringAsync(SELECTED_LANGUAGE_CODE),
                    )),
              )
            : pw.Text(
                "${CalenderDateUtils.formatFirstDay(DateTime.parse(allPeriodRange[index].cycleStartDate!))} - ${WidgetBaseLanguage.graphCycleNowTitle}",
                style: pw.TextStyle(
                    color: PdfColor.fromInt(0xA6212121),
                    fontSize: 10,
                    font: PdfFontHelper.getFontForLanguage(
                      getStringAsync(SELECTED_LANGUAGE_CODE),
                    )),
              ),

        // Spacer
        pw.SizedBox(height: 5),
      ],
    );
  }

  Widget buildFAB(BuildContext context) {
    return FutureBuilder<MenstrualCycleSummaryData?>(
      future: _cycleReportFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.hasError) {
          return const SizedBox.shrink();
        }

        return ExpandableFab(
          distance: 70,
          children: [
            FloatingActionButton(
              heroTag: 'download',
              onPressed: () =>
                  handleUserAction('download', context, snapshot.data, today),
              child: const Icon(Icons.download, color: Colors.white),
            ),
            FloatingActionButton(
              heroTag: 'share',
              onPressed: () =>
                  handleUserAction('share', context, snapshot.data, today),
              child: const Icon(Icons.share, color: Colors.white),
            ),
          ],
        );
      },
    );
  }

  Future<void> handleUserAction(String action, BuildContext context,
      MenstrualCycleSummaryData? cycleReport, String today) async {
    // Common PDF generation logic
    Future<Uint8List> generatePdf() async {
      return await _generatePdf(cycleReport, PdfPageFormat.a4);
    }

    // Share action
    Future<void> performShare() async {
      final pdfBytes = await generatePdf();
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'menstrual_report_$today.pdf',
      );
    }

    // Download action
    Future<void> performDownload() async {
      try {
        final pdfBytes = await generatePdf();
        final directory = await getApplicationDocumentsDirectory();
        final folderPath = '${directory.path}/Era Reports';
        final folder = Directory(folderPath);

        await folder.create(recursive: true);

        final filePath = '$folderPath/menstrual_report_$today.pdf';
        final file = File(filePath);
        await file.writeAsBytes(pdfBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language.ReportDownloadedSuccessfully),
                  Text(
                    'Location: $filePath',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: language.Open,
                onPressed: () async {
                  try {
                    if (await file.exists()) {
                      final result = await OpenFile.open(filePath);
                      if (result.type != ResultType.done) {
                        throw Exception(result.message);
                      }
                    } else {
                      throw Exception('File not found');
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Cannot open file: ${e.toString()}'),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download failed: ${e.toString()}'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }

    // Ad logic
    if (appStore.adsConfig?.adsconfigAccess ?? false) {
      FacebookAdsManager.showRewardedVideoAd(
        onRewardedVideoCompleted: () async {
          if (action == 'download') {
            await performDownload();
            logAnalyticsEvent(
                category: "download", action: "user_report_downloaded");
          } else if (action == 'share') {
            await performShare();
          }
        },
        onError: () async {
          if (action == 'download') {
            await performDownload();
          } else if (action == 'share') {
            await performShare();
          }
        },
      );
    } else {
      if (action == 'download') {
        await performDownload();
      } else if (action == 'share') {
        await performShare();
      }
    }
  }

  String getPhasePercentage(
      List<PhasePercentage>? phases, String englishPhaseName) {
    if (phases == null) return 'N/A';
    var phase = phases.firstWhere(
      (element) =>
          element.phaseName?.toLowerCase() == englishPhaseName.toLowerCase(),
      orElse: () => PhasePercentage(phaseName: '', percentage: null),
    );
    if (phase.percentage == null) {
      phase = phases.firstWhere(
        (element) => element.percentage != null,
        orElse: () => PhasePercentage(phaseName: '', percentage: null),
      );
    }

    return phase.percentage?.toStringAsFixed(0) ?? 'N/A';
  }

  Future<Uint8List> _generatePdf(MenstrualCycleSummaryData? cycleReport,
      final PdfPageFormat format) async {
    final pdf = pw.Document();
    final String formattedDate = DateFormat('MMMM d, y').format(DateTime.now());

    final keyMatrix = cycleReport?.keyMatrix;
    final predictionMatrix = cycleReport?.predictionMatrix;
    final symptomPatterns = cycleReport?.symptomsPatternsReport ?? [];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        textDirection:
            PdfFontHelper.isRtlLanguage(getStringAsync(SELECTED_LANGUAGE_CODE))
                ? pw.TextDirection.rtl
                : pw.TextDirection.ltr,
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 20),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
              ),
            ),
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Page ${context.pageNumber} of ${context.pagesCount}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                        font: PdfFontHelper.getFontForLanguage(
                          getStringAsync(SELECTED_LANGUAGE_CODE),
                        ),
                      ),
                    ),
                    pw.Text(
                      getStringAsync(SITE_COPYRIGHT),
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
              ],
            ),
          );
        },
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    language.HealthReport,
                    style: pw.TextStyle(
                        fontSize: 35,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.pinkAccent,
                        font: PdfFontHelper.getFontForLanguage(
                          getStringAsync(SELECTED_LANGUAGE_CODE),
                        )),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    "${language.Madeby} ${APP_NAME} ${language.application}",
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.black,
                      fontWeight: pw.FontWeight.normal,
                      font: PdfFontHelper.getFontForLanguage(
                        getStringAsync(SELECTED_LANGUAGE_CODE),
                      ),
                    ),
                  ),
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: "${language.ExportedOn} ",
                          style: pw.TextStyle(
                            fontSize: 12,
                            font: PdfFontHelper.getFontForLanguage(
                              getStringAsync(SELECTED_LANGUAGE_CODE),
                            ),
                          ),
                        ),
                        pw.TextSpan(
                          text: formattedDate,
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            font: PdfFontHelper.getFontForLanguage(
                              getStringAsync(SELECTED_LANGUAGE_CODE),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.BarcodeWidget(
                data: getAppUrlForDownload(),
                barcode: pw.Barcode.qrCode(),
                width: 80,
                height: 80,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.grey300,
                    width: 0.8,
                  ),
                  borderRadius: pw.BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          buildPdfDivider(),
          pw.SizedBox(height: 10),
          pw.Text(
            language.CyclePeriod,
            style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                font: PdfFontHelper.getFontForLanguage(
                  getStringAsync(SELECTED_LANGUAGE_CODE),
                )),
          ),
          pw.SizedBox(height: 10),
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: "${language.AverageCycleLength} ",
                  style: pw.TextStyle(
                    fontSize: 14,
                    font: PdfFontHelper.getFontForLanguage(
                      getStringAsync(SELECTED_LANGUAGE_CODE),
                    ),
                  ),
                ),
                pw.TextSpan(
                  text: "${keyMatrix?.avgCycleLength ?? 'N/A'} ",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    font: PdfFontHelper.getFontForLanguage(
                      getStringAsync(SELECTED_LANGUAGE_CODE),
                    ),
                  ),
                ),
                pw.TextSpan(
                  text: language.days,
                  style: pw.TextStyle(
                      fontSize: 14,
                      font: PdfFontHelper.getFontForLanguage(
                        getStringAsync(SELECTED_LANGUAGE_CODE),
                      )),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 5),
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: "${language.AveragePeriodLength} ",
                  style: pw.TextStyle(
                    fontSize: 14,
                    font: PdfFontHelper.getFontForLanguage(
                      getStringAsync(SELECTED_LANGUAGE_CODE),
                    ),
                  ),
                ),
                pw.TextSpan(
                  text: "${keyMatrix?.avgPeriodDuration ?? 'N/A'} ",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    font: PdfFontHelper.getFontForLanguage(
                      getStringAsync(SELECTED_LANGUAGE_CODE),
                    ),
                  ),
                ),
                pw.TextSpan(
                  text: language.days,
                  style: pw.TextStyle(
                      fontSize: 14,
                      font: PdfFontHelper.getFontForLanguage(
                        getStringAsync(SELECTED_LANGUAGE_CODE),
                      )),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 5),
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: "${language.PreviousCycleLength} ",
                  style: pw.TextStyle(
                    fontSize: 14,
                    font: PdfFontHelper.getFontForLanguage(
                      getStringAsync(SELECTED_LANGUAGE_CODE),
                    ),
                  ),
                ),
                pw.TextSpan(
                  text: "${keyMatrix?.prevCycleLength ?? 'N/A'} ",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    font: PdfFontHelper.getFontForLanguage(
                      getStringAsync(SELECTED_LANGUAGE_CODE),
                    ),
                  ),
                ),
                pw.TextSpan(
                  text: language.days,
                  style: pw.TextStyle(
                      fontSize: 14,
                      font: PdfFontHelper.getFontForLanguage(
                        getStringAsync(SELECTED_LANGUAGE_CODE),
                      )),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 5),
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: "${language.PreviousPeriodLength} ",
                  style: pw.TextStyle(
                    fontSize: 14,
                    font: PdfFontHelper.getFontForLanguage(
                      getStringAsync(SELECTED_LANGUAGE_CODE),
                    ),
                  ),
                ),
                pw.TextSpan(
                  text: "${keyMatrix?.prevPeriodDuration ?? 'N/A'} ",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    font: PdfFontHelper.getFontForLanguage(
                      getStringAsync(SELECTED_LANGUAGE_CODE),
                    ),
                  ),
                ),
                pw.TextSpan(
                  text: language.days,
                  style: pw.TextStyle(
                      fontSize: 14,
                      font: PdfFontHelper.getFontForLanguage(
                        getStringAsync(SELECTED_LANGUAGE_CODE),
                      )),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 5),
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: "${language.CycleRegularityScore} ",
                  style: pw.TextStyle(
                    fontSize: 14,
                    font: PdfFontHelper.getFontForLanguage(
                      getStringAsync(SELECTED_LANGUAGE_CODE),
                    ),
                  ),
                ),
                pw.TextSpan(
                  text:
                      "${keyMatrix?.cycleRegularityScore?.toStringAsFixed(1) ?? 'N/A'} ",
                  style: pw.TextStyle(
                    font: PdfFontHelper.getFontForLanguage(
                      getStringAsync(SELECTED_LANGUAGE_CODE),
                    ),
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.TextSpan(
                  text: "(${keyMatrix?.cycleRegularityScoreStatus ?? ''})",
                  style: pw.TextStyle(
                      fontSize: 14,
                      font: PdfFontHelper.getFontForLanguage(
                        getStringAsync(SELECTED_LANGUAGE_CODE),
                      )),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 5),
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: "${language.PeriodRegularityScore} ",
                  style: pw.TextStyle(
                      fontSize: 14,
                      font: PdfFontHelper.getFontForLanguage(
                        getStringAsync(SELECTED_LANGUAGE_CODE),
                      )),
                ),
                pw.TextSpan(
                  text:
                      "${keyMatrix?.periodRegularityScore?.toStringAsFixed(1) ?? 'N/A'} ",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    font: PdfFontHelper.getFontForLanguage(
                      getStringAsync(SELECTED_LANGUAGE_CODE),
                    ),
                  ),
                ),
                pw.TextSpan(
                  text: "(${keyMatrix?.periodRegularityScoreStatus ?? ''})",
                  style: pw.TextStyle(
                      fontSize: 14,
                      font: PdfFontHelper.getFontForLanguage(
                        getStringAsync(SELECTED_LANGUAGE_CODE),
                      )),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          buildPdfDivider(),
          pw.SizedBox(height: 10),
          pw.Text(
            language.Predictions,
            style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                font: PdfFontHelper.getFontForLanguage(
                  getStringAsync(SELECTED_LANGUAGE_CODE),
                )),
          ),
          pw.SizedBox(height: 10),
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: "${language.NextPeriodDay} ",
                  style: pw.TextStyle(
                      fontSize: 14,
                      font: PdfFontHelper.getFontForLanguage(
                        getStringAsync(SELECTED_LANGUAGE_CODE),
                      )),
                ),
                pw.TextSpan(
                  text: "${predictionMatrix?.nextPeriodDay ?? 'N/A'}",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 5),
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: "${language.NextOvulationDay} ",
                  style: pw.TextStyle(
                      fontSize: 14,
                      font: PdfFontHelper.getFontForLanguage(
                        getStringAsync(SELECTED_LANGUAGE_CODE),
                      )),
                ),
                pw.TextSpan(
                  text: "${predictionMatrix?.ovulationDay ?? 'N/A'}",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          buildPdfDivider(),
          pw.SizedBox(height: 10),
          pw.Text(
            language.cycleHistorySummary,
            style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                font: PdfFontHelper.getFontForLanguage(
                  getStringAsync(SELECTED_LANGUAGE_CODE),
                )),
          ),
          pw.SizedBox(height: 10),
          pw.ListView.builder(
            direction: pw.Axis.vertical,
            itemCount: cycleReport!.cycleSummary!.length,
            itemBuilder: (context, index) {
              return getPdfCycleHistoryView(index, cycleReport.cycleSummary!);
            },
          ),
          pw.SizedBox(height: 10),
          buildPdfDivider(),
          pw.SizedBox(height: 10),
          pw.Text(
            language.SymptomPatternsSummary,
            style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                font: PdfFontHelper.getFontForLanguage(
                  getStringAsync(SELECTED_LANGUAGE_CODE),
                )),
          ),
          pw.SizedBox(height: 10),
          symptomPatterns.isNotEmpty
              ? pw.Table(
                  border: pw.TableBorder.all(),
                  defaultVerticalAlignment:
                      pw.TableCellVerticalAlignment.middle,
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(language.Symptom,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                font: PdfFontHelper.getFontForLanguage(
                                  getStringAsync(SELECTED_LANGUAGE_CODE),
                                ),
                              ),
                              textAlign: pw.TextAlign.center),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(language.Menstrual,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                font: PdfFontHelper.getFontForLanguage(
                                  getStringAsync(SELECTED_LANGUAGE_CODE),
                                ),
                              ),
                              textAlign: pw.TextAlign.center),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(language.Follicular,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                font: PdfFontHelper.getFontForLanguage(
                                  getStringAsync(SELECTED_LANGUAGE_CODE),
                                ),
                              ),
                              textAlign: pw.TextAlign.center),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(language.Ovulation,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                font: PdfFontHelper.getFontForLanguage(
                                  getStringAsync(SELECTED_LANGUAGE_CODE),
                                ),
                              ),
                              textAlign: pw.TextAlign.center),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(language.Luteal,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                font: PdfFontHelper.getFontForLanguage(
                                  getStringAsync(SELECTED_LANGUAGE_CODE),
                                ),
                              ),
                              textAlign: pw.TextAlign.center),
                        ),
                      ],
                    ),
                    ...symptomPatterns.map(
                      (item) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(item.name ?? 'N/A',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                    font: PdfFontHelper.getFontForLanguage(
                                  getStringAsync(SELECTED_LANGUAGE_CODE),
                                ))),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                                '${getPhasePercentage(item.phases, "Menstrual")}%',
                                textAlign: pw.TextAlign.center),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                                '${getPhasePercentage(item.phases, "Follicular")}%',
                                textAlign: pw.TextAlign.center),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                                '${getPhasePercentage(item.phases, "Ovulation")}%',
                                textAlign: pw.TextAlign.center),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                                '${getPhasePercentage(item.phases, "Luteal")}%',
                                textAlign: pw.TextAlign.center),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : pw.Text(
                  language.NoSymptomPatternsAvailable,
                  style: pw.TextStyle(fontSize: 14, color: PdfColors.grey),
                ),
        ],
      ),
    );

    return Uint8List.fromList(await pdf.save());
  }

  @override
  void initState() {
    super.initState();
    _cycleReportFuture = getCycleReportData();
    PdfFontHelper.loadFonts();
    logScreenView("Menstrual Report screen");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: ExpandableFab.location,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              color: kPrimaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  10.height,
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          CupertinoIcons.back,
                          color: mainColorText,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          language.MenstrualReport,
                          style: boldTextStyle(
                            size: textFontSize_18,
                            weight: FontWeight.w500,
                            color: mainColorText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  10.height,
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: context.width(),
                decoration: const BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: FutureBuilder<MenstrualCycleSummaryData?>(
                  future: _cycleReportFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: Loader());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          language.ErrorLoadingReportData,
                          style: primaryTextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final cycleReport = snapshot.data;

                    return PdfPreview(
                      allowPrinting: false,
                      canChangePageFormat: false,
                      useActions: false,
                      allowSharing: true,
                      canDebug: false,
                      loadingWidget: Loader(),
                      pdfFileName: "Menstrual Cycle Report - $today",
                      pdfPreviewPageDecoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(),
                      ),
                      build: (format) => _generatePdf(cycleReport, format),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: buildFAB(context),
    );
  }
}

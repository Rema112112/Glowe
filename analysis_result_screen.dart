import 'package:flutter/material.dart';
import 'scan_controller.dart'; // Relative path avoids package name errors

enum AnalysisType { text, barcode, imageOcr }

class AnalysisResultScreen extends StatefulWidget {
  final String queryOrText;
  final bool isProductName;
  final AnalysisType type;

  const AnalysisResultScreen({
    super.key,
    required this.queryOrText,
    this.isProductName = false,
    this.type = AnalysisType.text,
  });

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  final ScanController _scanController = ScanController();

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _analysisData;

  @override
  void initState() {
    super.initState();
    _fetchAnalysis();
  }

  Future<void> _fetchAnalysis() async {
    try {
      final result = await _scanController.analyzeIngredients(
        widget.queryOrText,
      );

      if (mounted) {
        setState(() {
          _analysisData = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffffbee),
      appBar: AppBar(
        backgroundColor: const Color(0xfffffbee),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xff2d4a43)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            color: Color(0xff2d4a43),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  String _getAppBarTitle() {
    switch (widget.type) {
      case AnalysisType.barcode:
        return 'Barcode Analysis';
      case AnalysisType.imageOcr:
        return 'Label Scan Analysis';
      case AnalysisType.text:
      default:
        return 'Analysis Result';
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xffa68cb5)),
            SizedBox(height: 16),
            Text(
              'Analyzing skin compatibility...',
              style: TextStyle(
                color: Color(0xff2d4a43),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffa68cb5),
                ),
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _fetchAnalysis();
                },
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final data = _analysisData ?? {};
    final List skinTypes = data['suitableSkinTypes'] ?? [];
    final List ingredients = data['ingredients'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xffe0e0e0), width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['productName'] ?? 'Scanned Product',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff2d4a43),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Overall Compatibility',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: Color(0xfff3edf7),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${data['compatibilityScore'] ?? 0}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xffa68cb5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Best Suited For',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff2d4a43),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skinTypes
                .map(
                  (type) => Chip(
                    label: Text(
                      type.toString(),
                      style: const TextStyle(
                        color: Color(0xff2d4a43),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: const Color(0xfff3edf7),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Safety & Sensitivity Assessment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff2d4a43),
            ),
          ),
          const SizedBox(height: 12),
          _buildSafetyBadge(
            icon: Icons.spa_outlined,
            title: data['sensitiveSkinSafe'] == true
                ? 'Sensitive Skin Suitable'
                : 'Sensitive Skin Caution',
            subtitle:
                data['sensitiveSkinNote'] ?? 'No sensitivity notes recorded.',
            color: data['sensitiveSkinSafe'] == true
                ? const Color(0xff4a7c59)
                : const Color(0xffd97706),
          ),
          const SizedBox(height: 10),
          _buildSafetyBadge(
            icon: Icons.child_friendly_outlined,
            title: data['pregnancySafe'] == true
                ? 'Pregnancy Safe'
                : 'Pregnancy Caution',
            subtitle:
                data['pregnancyNote'] ?? 'No pregnancy warnings reported.',
            color: data['pregnancySafe'] == true
                ? const Color(0xff4a7c59)
                : const Color(0xffd97706),
          ),
          const SizedBox(height: 10),
          if (data['medicationCaution'] == true) ...[
            _buildSafetyBadge(
              icon: Icons.medication_outlined,
              title: 'Medication Caution',
              subtitle:
                  data['medicationNote'] ??
                  'Caution recommended with topical prescriptions.',
              color: const Color(0xffd97706),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 10),
          const Text(
            'Key Ingredients',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff2d4a43),
            ),
          ),
          const SizedBox(height: 12),
          ...ingredients.map(
            (ing) => _buildIngredientTile(
              ing['name'] ?? 'Unknown',
              ing['effect'] ?? 'No description available',
              ing['status'] ?? 'Safe',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyBadge({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientTile(String name, String effect, String status) {
    Color badgeColor;
    Color textColor;

    switch (status) {
      case 'Caution':
        badgeColor = const Color(0xfffef3c7);
        textColor = const Color(0xffb45309);
        break;
      case 'Harmful':
        badgeColor = const Color(0xfffee2e2);
        textColor = const Color(0xffdc2626);
        break;
      case 'Safe':
      default:
        badgeColor = const Color(0xffe6f4ea);
        textColor = const Color(0xff137333);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe0e0e0), width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2d4a43),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  effect,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

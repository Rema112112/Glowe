import 'dart:io';
import 'package:flutter/material.dart';
import 'scan_controller.dart';

class SkinAnalysisResultScreen extends StatefulWidget {
  final File imageFile;

  const SkinAnalysisResultScreen({super.key, required this.imageFile});

  @override
  State<SkinAnalysisResultScreen> createState() =>
      _SkinAnalysisResultScreenState();
}

class _SkinAnalysisResultScreenState extends State<SkinAnalysisResultScreen> {
  final ScanController _scanController = ScanController();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _skinData;

  @override
  void initState() {
    super.initState();
    _fetchSkinAnalysis();
  }

  Future<void> _fetchSkinAnalysis() async {
    try {
      final result = await _scanController.analyzeSkin(widget.imageFile);
      if (mounted) {
        setState(() {
          _skinData = result;
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
        title: const Text(
          'Skin Analysis Result',
          style: TextStyle(
            color: Color(0xff2d4a43),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
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
              'Analyzing skin image & building routine...',
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
                  _fetchSkinAnalysis();
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

    final data = _skinData ?? {};

    // Safely extract values supporting both snake_case and camelCase
    final explanation =
        data['skinAnalysisExplanation'] ??
        data['skin_analysis_explanation'] ??
        'Analysis completed.';

    final conditions =
        (data['detectedConditions'] ?? data['detected_conditions'] ?? {})
            as Map;
    final routine =
        (data['routineRecommendations'] ??
                data['routine_recommendations'] ??
                {})
            as Map;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Diagnosis Overview Card
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.face_retouching_natural,
                      color: Color(0xffa68cb5),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Dermatological Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2d4a43),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  explanation.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. Detected Conditions Grid/Badges
          const Text(
            'Detected Skin Conditions',
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
            children: conditions.entries.map((entry) {
              return Chip(
                avatar: const Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: Color(0xff4a7c59),
                ),
                label: Text(
                  '${entry.key.toString().toUpperCase()}: ${entry.value}',
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
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // 3. 5-Step Routine Recommendations
          const Text(
            'Recommended 5-Step Routine',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff2d4a43),
            ),
          ),
          const SizedBox(height: 12),

          _buildRoutineStep(
            stepNumber: '1',
            title: 'Cleanser',
            stepData: routine['cleanser'],
            icon: Icons.water_drop_outlined,
          ),
          _buildRoutineStep(
            stepNumber: '2',
            title: 'Toner',
            stepData: routine['toner'],
            icon: Icons.clean_hands_outlined,
          ),
          _buildRoutineStep(
            stepNumber: '3',
            title: 'Serum',
            stepData: routine['serum'],
            icon: Icons.science_outlined,
          ),
          _buildRoutineStep(
            stepNumber: '4',
            title: 'Moisturizer',
            stepData: routine['moisturizer'],
            icon: Icons.spa_outlined,
          ),
          _buildRoutineStep(
            stepNumber: '5',
            title: 'Sunscreen',
            stepData: routine['sunscreen'],
            icon: Icons.wb_sunny_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineStep({
    required String stepNumber,
    required String title,
    required dynamic stepData,
    required IconData icon,
  }) {
    if (stepData == null || stepData is! Map) {
      return const SizedBox.shrink();
    }

    final productType =
        stepData['productTypeName'] ?? stepData['product_type_name'] ?? title;
    final reason = stepData['reason'] ?? '';
    final List ingredients =
        stepData['keyIngredients'] ?? stepData['key_ingredients'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffe0e0e0), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xfff3edf7),
            child: Icon(icon, color: const Color(0xffa68cb5)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step $stepNumber: $productType',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xff2d4a43),
                  ),
                ),
                if (reason.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    reason,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
                if (ingredients.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Key Ingredients: ${ingredients.join(", ")}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xffa68cb5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

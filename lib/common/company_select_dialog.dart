import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:real_web_rough_entry_system/common/components/diamond_image_data.dart';
import 'package:real_web_rough_entry_system/common/components/diamond_logo.dart';
import 'package:real_web_rough_entry_system/common/components/diamond_sparkle_painter.dart';
import 'package:real_web_rough_entry_system/common/widgets.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompanySelectionDialog extends StatefulWidget {
  final bool isSwitchCompany;

  const CompanySelectionDialog({super.key, required this.isSwitchCompany});

  @override
  State<CompanySelectionDialog> createState() => _CompanySelectionDialogState();
}

class _CompanySelectionDialogState extends State<CompanySelectionDialog> {
  late final DefaultController _controller;
  late int _selectedCompanyCode;
  final FocusNode _proceedFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<DefaultController>()
        ? Get.find<DefaultController>()
        : Get.put(DefaultController());
    _selectedCompanyCode = _controller.companyCode.value != 0
        ? _controller.companyCode.value
        : 3;
    _ensureCompaniesLoaded();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _proceedFocus.requestFocus();
    });
  }

  Future<void> _ensureCompaniesLoaded() async {
    if (_controller.companies.isEmpty) {
      await _controller.getCompanies();
      if (mounted) {
        setState(() {
          if (_controller.companies.isNotEmpty) {
            final exists = _controller.companies
                .any((c) => c.companyCode == _selectedCompanyCode);
            if (!exists) {
              _selectedCompanyCode =
                  _controller.companies.first.companyCode ?? 3;
            }
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _proceedFocus.dispose();
    super.dispose();
  }

  Future<void> _handleProceed() async {
    final int codeToSave = _selectedCompanyCode != 0 ? _selectedCompanyCode : 3;
    _controller.companyCode.value = codeToSave;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('companyCode', codeToSave);

    if (_controller.menuList.isEmpty) {
      await _controller.getMenuList();
    }

    if (widget.isSwitchCompany) {
      Get.back();
    } else {
      Get.offAllNamed('/MainScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.zero,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.15),
              radius: 1.35,
              colors: [
                Color(0xFF132752), // Glowing royal navy center
                Color(0xFF09142B), // Deep sapphire
                Color(0xFF030712), // Darkest outer space vignette
              ],
              stops: [0.0, 0.50, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // 1. Ambient Diamond Sparkles in Background
              Positioned.fill(
                child: CustomPaint(
                  painter: DiamondSparklePainter(),
                ),
              ),

              // 2. Large Soft Ambient Backlight Glow
              Center(
                child: Container(
                  width: 900,
                  height: 580,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.22),
                        blurRadius: 90,
                        spreadRadius: 20,
                      ),
                      BoxShadow(
                        color: const Color(0xFF06B6D4).withValues(alpha: 0.12),
                        blurRadius: 120,
                        spreadRadius: 40,
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Main Split-Card Container
              LayoutBuilder(
                builder: (context, constraints) {
                  final double screenW = constraints.maxWidth;
                  final double screenH = constraints.maxHeight;
                  final bool isWideScreen = screenW >= 850 && screenH >= 540;

                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Container(
                        width: isWideScreen ? min(960, screenW - 32) : min(460, screenW - 24),
                        constraints: BoxConstraints(
                          minHeight: isWideScreen ? 585 : 540,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.20),
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.65),
                              blurRadius: 50,
                              offset: const Offset(0, 22),
                            ),
                            BoxShadow(
                              color: const Color(0xFF1D4ED8).withValues(alpha: 0.25),
                              blurRadius: 40,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: isWideScreen
                            ? IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Left Hero Panel: Abhinandan Diamond System Highlights & Luxury Diamond
                                    Expanded(
                                      flex: 5,
                                      child: _buildLeftHeroSection(),
                                    ),
                                    // Right Panel: Select Company Branch Form
                                    Expanded(
                                      flex: 5,
                                      child: _buildRightCompanySelectSection(compact: false),
                                    ),
                                  ],
                                ),
                              )
                            : _buildRightCompanySelectSection(compact: true),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Left Hero Panel: Ultra-luxury deep midnight card with photorealistic diamond and glowing tiles
  Widget _buildLeftHeroSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF060D1E), // Deepest dark midnight
            Color(0xFF0F2044), // Rich sapphire navy
            Color(0xFF091429), // Midnight blue base
          ],
        ),
      ),
      child: Stack(
        children: [
          // Ambient sapphire radial aura behind the diamond
          Positioned(
            right: 20,
            bottom: 40,
            width: 280,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3B82F6).withValues(alpha: 0.35),
                    const Color(0xFF1D4ED8).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // Photorealistic Diamond Image Visual at Bottom-Right
          Positioned(
            right: -10,
            bottom: -15,
            width: 325,
            height: 325,
            child: ShaderMask(
              shaderCallback: (bounds) {
                return const RadialGradient(
                  center: Alignment(0.48, 0.48),
                  radius: 0.88,
                  colors: [
                    Colors.black,
                    Colors.black87,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.65, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: Image.memory(
                kDiamondLuxuryBytes,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),

          // Content Layer on Top of Diamond Visual
          Padding(
            padding: const EdgeInsets.fromLTRB(36, 36, 32, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                // Top Brand Mark: Diamond Logo + Abhinandan DIAMOND
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF60A5FA).withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: DiamondLogo.lightOnDark(size: 42),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shakti',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            shadows: [
                              Shadow(
                                color: Color(0xFF1E3A8A),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'T R A D I N G',
                          style: TextStyle(
                            color: Color(0xFF67E8F9), // Glowing Cyan
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 5.2,
                            shadows: [
                              Shadow(
                                color: Color(0xFF06B6D4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Subtitle Badge: ── ERP System ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF38BDF8),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF38BDF8),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Operating Branches',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // System Description
                Text(
                  'Choose your operating company branch to access live inventory, sales, and financial records. Powered by Realsoft Solutions.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.80),
                    fontSize: 12.5,
                    height: 1.48,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 26),

                // Feature Item 1: Active Branch Isolation
                _buildCrazyFeatureTile(
                  icon: Icons.apartment_rounded,
                  accentColor: const Color(0xFF06B6D4),
                  title: 'Branch Control',
                  subtitle: 'Multi-company data isolation & unified reporting',
                ),
                const SizedBox(height: 14),

                // Feature Item 2: Multi-Location Operations
                _buildCrazyFeatureTile(
                  icon: Icons.hub_rounded,
                  accentColor: const Color(0xFF818CF8),
                  title: 'Multi-Location Operations',
                  subtitle: 'Surat head office & trading branches',
                ),
                const SizedBox(height: 14),

                // Feature Item 3: Secure Session
                _buildCrazyFeatureTile(
                  icon: Icons.verified_user_rounded,
                  accentColor: const Color(0xFF10B981),
                  title: 'Secure Session',
                  subtitle: 'Role-based branch permissions & live balances',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Feature Item Card with frosted glass gradient and glowing icon badge
  Widget _buildCrazyFeatureTile({
    required IconData icon,
    required Color accentColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withValues(alpha: 0.30),
                  accentColor.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.50),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.25),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.70),
                    fontSize: 11.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Right Form Section: Company Selection & Preview Card
  Widget _buildRightCompanySelectSection({required bool compact}) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 26 : 40,
        vertical: compact ? 28 : 34,
      ),
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
            _handleProceed();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D4ED8).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF1D4ED8).withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.business_rounded,
                    color: Color(0xFF1D4ED8),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isSwitchCompany ? 'Switch Company' : 'Select Company',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Choose the operating company branch',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isSwitchCompany)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22, color: Color(0xFF64748B)),
                    onPressed: () => Get.back(),
                    splashRadius: 20,
                  ),
              ],
            ),
            const SizedBox(height: 18),

            // Divider
            const Divider(color: Color(0xFFE2E8F0), thickness: 1),
            const SizedBox(height: 20),

            // Dropdown & Preview
            Obx(() {
              final bool isLoading = _controller.isLoadingCompanies.value &&
                  _controller.companies.isEmpty;

              if (isLoading) {
                return Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D4ED8)),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Loading company branches...',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final companies = _controller.companies;
              final availableList = companies.isNotEmpty
                  ? companies.toList()
                  : [getCompanyDetails(3)];

              final int currentVal = availableList.any((e) => e.companyCode == _selectedCompanyCode)
                  ? _selectedCompanyCode
                  : (availableList.first.companyCode ?? 3);

              final details = availableList.firstWhere(
                (e) => e.companyCode == currentVal,
                orElse: () => getCompanyDetails(currentVal),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dropdown Label
                  const Text(
                    'Operating Branch',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Dropdown Button
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: currentVal,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        items: availableList.map((company) {
                          final int code = company.companyCode ?? 3;
                          final String name = (company.companyName != null && company.companyName!.trim().isNotEmpty)
                              ? company.companyName!
                              : 'Abhinandan Diamond';
                          return DropdownMenuItem<int>(
                            value: code,
                            child: Row(
                              children: [
                                const Icon(Icons.apartment_rounded, size: 19, color: Color(0xFF1D4ED8)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F172A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCompanyCode = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Company Details Card Preview
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (details.mobileno != null && details.mobileno!.trim().isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.phone_rounded, size: 15, color: Color(0xFF1D4ED8)),
                              const SizedBox(width: 8),
                              Text(
                                details.mobileno!,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (details.address != null && details.address!.trim().isNotEmpty) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_rounded, size: 15, color: Color(0xFF1D4ED8)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  details.address!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF475569),
                                    height: 1.35,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ] else if (details.mobileno == null || details.mobileno!.trim().isEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 8),
                              Text(
                                'Operating Branch Code: $currentVal',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 26),

            // Proceed Button
            Container(
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E40AF), // Deep Royal Blue
                    Color(0xFF2563EB), // Vibrant Blue
                    Color(0xFF3B82F6), // Bright Accent
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.40),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                focusNode: _proceedFocus,
                autofocus: true,
                onPressed: _handleProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.isSwitchCompany ? 'Confirm Switch' : 'Proceed to ERP',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Enter',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Press Enter to continue',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

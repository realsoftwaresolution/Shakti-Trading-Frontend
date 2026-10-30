import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:real_web_rough_entry_system/common/components/diamond_image_data.dart';
import 'package:real_web_rough_entry_system/common/components/diamond_logo.dart';
import 'package:real_web_rough_entry_system/common/components/diamond_sparkle_painter.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final TextEditingController usernameController = TextEditingController(text: 'A');
  final TextEditingController passwordController = TextEditingController(text: 'A');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  late final DefaultController _controller;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<DefaultController>()
        ? Get.find<DefaultController>()
        : Get.put(DefaultController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _usernameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _controller.login(
        usernameController.text.trim(),
        passwordController.text.trim(),
      );
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
                                    // Left Hero Panel
                                    Expanded(
                                      flex: 5,
                                      child: _buildLeftHeroSection(),
                                    ),
                                    // Right Sign In Form
                                    Expanded(
                                      flex: 5,
                                      child: _buildRightLoginFormSection(compact: false),
                                    ),
                                  ],
                                ),
                              )
                            : _buildRightLoginFormSection(compact: true),
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
          // Subtle background grid glow or radial aura
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
                // Top Brand Mark: Diamond Logo + Shakti DIAMOND
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
                        'ERP System',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // System Description
                Text(
                  'A complete solution for diamond business operations and inventory management. Developed and powered by Realsoft Solutions.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.80),
                    fontSize: 12.5,
                    height: 1.48,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 26),

                // Feature Item 1: Streamline Operations (Cyan Accent)
                _buildCrazyFeatureTile(
                  icon: Icons.bar_chart_rounded,
                  accentColor: const Color(0xFF06B6D4),
                  title: 'Streamline Operations',
                  subtitle: 'Purchase, Rough Entry, Polish Sales & Invoicing',
                ),
                const SizedBox(height: 14),

                // Feature Item 2: Memo & Lot Control (Indigo Accent)
                _buildCrazyFeatureTile(
                  icon: Icons.swap_horiz_rounded,
                  accentColor: const Color(0xFF818CF8),
                  title: 'Increase Efficiency',
                  subtitle: 'Outward Memo Issues, Receives & Live Stock',
                ),
                const SizedBox(height: 14),

                // Feature Item 3: Secure & Reliable (Emerald Accent)
                _buildCrazyFeatureTile(
                  icon: Icons.verified_user_rounded,
                  accentColor: const Color(0xFF10B981),
                  title: 'Secure & Reliable',
                  subtitle: 'Real-time Party Ledgers, Payments & Reports',
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

  /// Right Sign In Form Section (with Realsoft Presents Header, Inputs, and Sign In action)
  Widget _buildRightLoginFormSection({required bool compact}) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 26 : 40,
        vertical: compact ? 28 : 34,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Realsoft Solutions Logo & Branding
            Center(
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D4ED8).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1D4ED8).withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: SvgPicture.asset(
                      "assets/images/logo.svg",
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF1D4ED8), // Royal Blue
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Realsoft Solutions',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Software For Your Business',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. ── Presents ── Divider
            const Row(
              children: [
                Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    'Presents',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
              ],
            ),
            const SizedBox(height: 14),

            // 3. Shakti Diamond Logo Badge
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DiamondLogo.blueOnLight(size: 38),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shakti',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Text(
                            'T R A D I N G',
                            style: TextStyle(
                              color: Color(0xFF1D4ED8),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3.8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'ERP System',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // 4. Username Field
            const Text(
              'Username',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: usernameController,
              focusNode: _usernameFocus,
              textInputAction: TextInputAction.next,
              autofocus: true,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: 'Enter your username',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20, color: Color(0xFF64748B)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1D4ED8), width: 1.8),
                ),
              ),
              onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your username';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // 5. Password Field
            const Text(
              'Password',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: passwordController,
              focusNode: _passwordFocus,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: 'Enter your password',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: Color(0xFF64748B)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: const Color(0xFF64748B),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1D4ED8), width: 1.8),
                ),
              ),
              onFieldSubmitted: (_) => _handleLogin(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),

            // 6. Vibrant Glowing Sign In Button with loading state
            Obx(
              () => Container(
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
                  onPressed: _controller.isLoading.value ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login_rounded, size: 19),
                            SizedBox(width: 8),
                            Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 7. Footer Attribution
            Center(
              child: Column(
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      children: [
                        TextSpan(text: 'Developed by '),
                        TextSpan(
                          text: 'Realsoft Solutions',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'For Shakti Trading',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

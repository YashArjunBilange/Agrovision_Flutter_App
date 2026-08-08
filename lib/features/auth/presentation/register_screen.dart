import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/errors/failure.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _talukaController = TextEditingController();
  final _villageController = TextEditingController();
  final _landAcresController = TextEditingController(text: '1.0');

  final String _selectedState = 'Maharashtra';
  String _selectedDistrict = 'Pune';
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _maharashtraDistricts = [
    'Ahmednagar',
    'Akola',
    'Amravati',
    'Chhatrapati Sambhajinagar (Aurangabad)',
    'Beed',
    'Bhandara',
    'Buldhana',
    'Chandrapur',
    'Dhule',
    'Gadchiroli',
    'Gondia',
    'Hingoli',
    'Jalgaon',
    'Jalna',
    'Kolhapur',
    'Latur',
    'Mumbai City',
    'Mumbai Suburban',
    'Nagpur',
    'Nanded',
    'Nandurbar',
    'Nashik',
    'Dharashiv (Osmanabad)',
    'Palghar',
    'Parbhani',
    'Pune',
    'Raigad',
    'Ratnagiri',
    'Sangli',
    'Satara',
    'Sindhudurg',
    'Solapur',
    'Thane',
    'Wardha',
    'Washim',
    'Yavatmal',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _talukaController.dispose();
    _villageController.dispose();
    _landAcresController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final currentLocale = ref.read(appLocaleProvider);
    final landAcres = double.tryParse(_landAcresController.text.trim()) ?? 1.0;

    try {
      await ref.read(authStateProvider.notifier).register(
            fullName: _fullNameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
            password: _passwordController.text,
            preferredLanguage: currentLocale.languageCode,
            stateName: _selectedState,
            district: _selectedDistrict,
            taluka: _talukaController.text.trim().isNotEmpty ? _talukaController.text.trim() : null,
            village: _villageController.text.trim().isNotEmpty ? _villageController.text.trim() : null,
            totalLandAcres: landAcres,
          );

      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e is Failure) {
            _errorMessage = e.message;
          } else {
            _errorMessage = e.toString();
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(appLocaleProvider);
    final isMr = currentLocale.languageCode == 'mr';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMr ? 'शेतकरी नोंदणी' : 'Farmer Registration',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageButton('EN', 'en', !isMr),
                const SizedBox(width: 4),
                _buildLanguageButton('मराठी', 'mr', isMr),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Heading Info
                    Text(
                      isMr ? 'आपल्या शेताची माहिती जोडा' : 'Create Your Farmer Account',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isMr
                          ? 'मक्याच्या पिकाचे योग्य व्यवस्थापन आणि AI मार्गदर्शनासाठी'
                          : 'Get personalized maize crop advisory and disease alerts',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Error Message Banner
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: AppColors.error, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Full Name
                    TextFormField(
                      controller: _fullNameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: isMr ? 'पूर्ण नाव *' : 'Full Name *',
                        hintText: isMr ? 'उदा. रमेश ज्ञानोबा पाटील' : 'e.g. Ramesh Patil',
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 2) {
                          return isMr ? 'कृपया आपले पूर्ण नाव टाका' : 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Mobile Number
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: isMr ? 'मोबाईल क्रमांक (10 अंक) *' : 'Mobile Number *',
                        hintText: '9876543210',
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 10) {
                          return isMr ? 'वैध 10-अंकी मोबाईल नंबर टाका' : 'Enter valid 10-digit mobile number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email (Optional)
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: isMr ? 'ईमेल (पर्यायी)' : 'Email (Optional)',
                        hintText: 'farmer@example.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: isMr ? 'पासवर्ड (किमान 6 अक्षरे) *' : 'Password (min 6 characters) *',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return isMr ? 'पासवर्ड किमान 6 अक्षरांचा असावा' : 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      isMr ? 'शेताचे स्थान व तपशील' : 'Farm Location & Details',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),

                    // District Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDistrict,
                      decoration: InputDecoration(
                        labelText: isMr ? 'जिल्हा *' : 'District *',
                        prefixIcon: const Icon(Icons.location_city),
                      ),
                      items: _maharashtraDistricts.map((district) {
                        return DropdownMenuItem(
                          value: district,
                          child: Text(district),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDistrict = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Taluka & Village Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _talukaController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: isMr ? 'तालुका' : 'Taluka',
                              hintText: isMr ? 'उदा. बारामती' : 'e.g. Baramati',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _villageController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: isMr ? 'गाव' : 'Village',
                              hintText: isMr ? 'उदा. माळेगाव' : 'e.g. Malegaon',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Total Land in Acres
                    TextFormField(
                      controller: _landAcresController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: isMr ? 'एकूण जमीन क्षेत्र (एकर) *' : 'Total Land (Acres) *',
                        hintText: '2.5',
                        prefixIcon: const Icon(Icons.landscape),
                      ),
                      validator: (value) {
                        if (value == null || double.tryParse(value) == null) {
                          return isMr ? 'वैध एकर संख्या टाका' : 'Enter valid acres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // Register Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isMr ? 'नोंदणी पूर्ण करा' : 'Complete Registration',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Back to Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isMr ? 'आधीच खाते आहे?' : 'Already have an account?',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        ),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Text(
                            isMr ? 'लॉग इन करा' : 'Log In',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(String label, String code, bool isSelected) {
    return InkWell(
      onTap: () {
        ref.read(appLocaleProvider.notifier).state = Locale(code);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.dividerLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primaryDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

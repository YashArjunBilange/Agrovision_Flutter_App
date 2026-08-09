import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/errors/failure.dart';
import '../domain/farm_model.dart';
import '../providers/farm_provider.dart';
import 'map_polygon_picker_screen.dart';

class AddEditFarmDialog extends ConsumerStatefulWidget {
  final FarmModel? farmToEdit;

  const AddEditFarmDialog({super.key, this.farmToEdit});

  static Future<void> show(BuildContext context, {FarmModel? farmToEdit}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditFarmDialog(farmToEdit: farmToEdit),
    );
  }

  @override
  ConsumerState<AddEditFarmDialog> createState() => _AddEditFarmDialogState();
}

class _AddEditFarmDialogState extends ConsumerState<AddEditFarmDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _acresController;
  late final TextEditingController _surveyController;
  late final TextEditingController _talukaController;
  late final TextEditingController _villageController;
  late final TextEditingController _latController;
  late final TextEditingController _longController;
  late final TextEditingController _phController;
  late final TextEditingController _notesController;

  late String _selectedDistrict;
  late String _selectedSoilType;
  late String _selectedIrrigation;
  late String _selectedWaterSource;
  late bool _isPrimary;
  bool _isLoading = false;
  String? _errorMessage;

  String? _polygonGeojson;
  double? _areaSqm;
  double? _areaHectares;
  double? _perimeterMeters;
  double? _lengthMeters;
  double? _widthMeters;

  final List<String> _districts = [
    'Ahmednagar', 'Akola', 'Amravati', 'Chhatrapati Sambhajinagar (Aurangabad)',
    'Beed', 'Bhandara', 'Buldhana', 'Chandrapur', 'Dhule', 'Gadchiroli',
    'Gondia', 'Hingoli', 'Jalgaon', 'Jalna', 'Kolhapur', 'Latur',
    'Mumbai City', 'Mumbai Suburban', 'Nagpur', 'Nanded', 'Nandurbar',
    'Nashik', 'Dharashiv (Osmanabad)', 'Palghar', 'Parbhani', 'Pune',
    'Raigad', 'Ratnagiri', 'Sangli', 'Satara', 'Sindhudurg', 'Solapur',
    'Thane', 'Wardha', 'Washim', 'Yavatmal',
  ];

  final List<Map<String, String>> _soilTypes = [
    {'en': 'Black Cotton (Regur)', 'mr': 'काळी कसदार माती (रेगूर)', 'val': 'Black Cotton'},
    {'en': 'Medium Black', 'mr': 'मध्यम काळी माती', 'val': 'Medium Black'},
    {'en': 'Red Loam', 'mr': 'तांबडी पोयटा माती', 'val': 'Red Loam'},
    {'en': 'Sandy Loam', 'mr': 'वालुकामय पोयटा माती', 'val': 'Sandy Loam'},
    {'en': 'Alluvial', 'mr': 'गाळाची सुपीक जमीन', 'val': 'Alluvial'},
    {'en': 'Clay Loam', 'mr': 'चिकण पोयटा माती', 'val': 'Clay Loam'},
  ];

  final List<Map<String, String>> _irrigationTypes = [
    {'en': 'Drip Irrigation', 'mr': 'ठिबक सिंचन', 'val': 'Drip'},
    {'en': 'Sprinkler', 'mr': 'तुषार सिंचन', 'val': 'Sprinkler'},
    {'en': 'Flood / Furrow', 'mr': 'पाटपाणी / सरी पद्धत', 'val': 'Flood'},
    {'en': 'Rainfed (Dryland)', 'mr': 'कोरडवाहू (केवळ पाऊस)', 'val': 'Rainfed'},
  ];

  final List<Map<String, String>> _waterSources = [
    {'en': 'Borewell', 'mr': 'कूपनलिका (बोअरवेल)', 'val': 'Borewell'},
    {'en': 'Open Well', 'mr': 'विहीर', 'val': 'Well'},
    {'en': 'Canal', 'mr': 'कालवा / नदी उपसा', 'val': 'Canal'},
    {'en': 'Farm Pond (Shet-tale)', 'mr': 'शेततळे', 'val': 'Farm Pond'},
    {'en': 'Rain Only', 'mr': 'फक्त पावसाचे पाणी', 'val': 'Rainfed'},
  ];

  @override
  void initState() {
    super.initState();
    final f = widget.farmToEdit;
    _nameController = TextEditingController(text: f?.name ?? '');
    _acresController = TextEditingController(text: f != null ? f.areaAcres.toString() : '2.0');
    _surveyController = TextEditingController(text: f?.surveyNumber ?? '');
    _talukaController = TextEditingController(text: f?.taluka ?? '');
    _villageController = TextEditingController(text: f?.village ?? '');
    _latController = TextEditingController(text: f?.latitude?.toString() ?? '18.5204');
    _longController = TextEditingController(text: f?.longitude?.toString() ?? '73.8567');
    _phController = TextEditingController(text: f?.soilPh?.toString() ?? '');
    _notesController = TextEditingController(text: f?.notes ?? '');

    _selectedDistrict = f?.district ?? 'Pune';
    if (!_districts.contains(_selectedDistrict)) _selectedDistrict = 'Pune';

    _selectedSoilType = f?.soilType ?? 'Black Cotton';
    _selectedIrrigation = f?.irrigationType ?? 'Drip';
    _selectedWaterSource = f?.waterSource ?? 'Well';
    _isPrimary = f?.isPrimary ?? false;

    _polygonGeojson = f?.polygonGeojson;
    _areaSqm = f?.areaSqm;
    _areaHectares = f?.areaHectares;
    _perimeterMeters = f?.perimeterMeters;
    _lengthMeters = f?.lengthMeters;
    _widthMeters = f?.widthMeters;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _acresController.dispose();
    _surveyController.dispose();
    _talukaController.dispose();
    _villageController.dispose();
    _latController.dispose();
    _longController.dispose();
    _phController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final data = {
      'name': _nameController.text.trim(),
      'area_acres': double.tryParse(_acresController.text.trim()) ?? 1.0,
      'survey_number': _surveyController.text.trim().isNotEmpty ? _surveyController.text.trim() : null,
      'district': _selectedDistrict,
      'taluka': _talukaController.text.trim().isNotEmpty ? _talukaController.text.trim() : null,
      'village': _villageController.text.trim().isNotEmpty ? _villageController.text.trim() : null,
      'latitude': double.tryParse(_latController.text.trim()),
      'longitude': double.tryParse(_longController.text.trim()),
      'soil_type': _selectedSoilType,
      'soil_ph': double.tryParse(_phController.text.trim()),
      'irrigation_type': _selectedIrrigation,
      'water_source': _selectedWaterSource,
      'is_primary': _isPrimary,
      'notes': _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      'polygon_geojson': _polygonGeojson,
      'area_sqm': _areaSqm,
      'area_hectares': _areaHectares,
      'perimeter_meters': _perimeterMeters,
      'length_meters': _lengthMeters,
      'width_meters': _widthMeters,
    };

    try {
      if (widget.farmToEdit == null) {
        await ref.read(farmsProvider.notifier).addFarm(data);
      } else {
        await ref.read(farmsProvider.notifier).updateFarm(widget.farmToEdit!.id, data);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e is Failure ? e.message : e.toString();
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
    final isMr = ref.watch(appLocaleProvider).languageCode == 'mr';
    final isEdit = widget.farmToEdit != null;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Bar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.grass_rounded, color: AppColors.primaryGreen, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isEdit
                        ? (isMr ? 'शेताची माहिती संपादित करा' : 'Edit Farm Plot')
                        : (isMr ? 'नवीन शेत जोडा' : 'Add New Farm Plot'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24),

            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ),
              const SizedBox(height: 12),
            ],

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Farm Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: isMr ? 'शेताचे नाव / खूण *' : 'Farm / Plot Name *',
                        hintText: isMr ? 'उदा. मुख्य शेत / गट क्र. ४२' : 'e.g. Main Farm / Gat 42',
                        prefixIcon: const Icon(Icons.label_outline),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? (isMr ? 'कृपया शेताचे नाव टाका' : 'Please enter farm name')
                          : null,
                    ),
                    const SizedBox(height: 14),

                    // Map Polygon Picker Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.of(context).push<PolygonResult>(
                          MaterialPageRoute(
                            builder: (context) => MapPolygonPickerScreen(
                              initialGeojson: _polygonGeojson,
                            ),
                          ),
                        );

                        if (result != null) {
                          setState(() {
                            _polygonGeojson = result.geojson;
                            _latController.text = result.latitude.toStringAsFixed(6);
                            _longController.text = result.longitude.toStringAsFixed(6);
                            _acresController.text = result.areaAcres.toStringAsFixed(2);
                            _areaSqm = result.areaSqm;
                            _areaHectares = result.areaHectares;
                            _perimeterMeters = result.perimeterMeters;
                            _lengthMeters = result.lengthMeters;
                            _widthMeters = result.widthMeters;
                          });
                        }
                      },
                      icon: const Icon(Icons.map_rounded),
                      label: Text(
                        _polygonGeojson != null
                            ? (isMr ? 'नकाशावर शेत संपादित करा' : 'Edit Farm on Map')
                            : (isMr ? 'नकाशावर शेत निवडा' : 'Draw Farm on Map'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (_polygonGeojson != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        isMr
                            ? '✅ नकाशावरून माहिती घेतली'
                            : '✅ Location and Area mapped successfully',
                        style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 14),

                    // Area & Survey Number Row
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _acresController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: isMr ? 'क्षेत्र (एकर) *' : 'Area (Acres) *',
                              hintText: '2.5',
                              prefixIcon: const Icon(Icons.square_foot),
                            ),
                            validator: (v) => (v == null || double.tryParse(v) == null)
                                ? (isMr ? 'वैध एकर टाका' : 'Enter valid acres')
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _surveyController,
                            decoration: InputDecoration(
                              labelText: isMr ? 'गट / सर्व्हे क्र.' : 'Survey / Gat No.',
                              hintText: '42/A',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // District Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDistrict,
                      decoration: InputDecoration(
                        labelText: isMr ? 'जिल्हा *' : 'District *',
                        prefixIcon: const Icon(Icons.location_city),
                      ),
                      items: _districts
                          .map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 14))))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedDistrict = v!),
                    ),
                    const SizedBox(height: 14),

                    // Taluka & Village Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _talukaController,
                            decoration: InputDecoration(
                              labelText: isMr ? 'तालुका' : 'Taluka',
                              hintText: isMr ? 'बारामती' : 'Baramati',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _villageController,
                            decoration: InputDecoration(
                              labelText: isMr ? 'गाव' : 'Village',
                              hintText: isMr ? 'माळेगाव' : 'Malegaon',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Soil & Irrigation Section Title
                    Text(
                      isMr ? 'जमीन व सिंचन तपशील' : 'Soil & Water Profile',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryGreen),
                    ),
                    const SizedBox(height: 8),

                    // Soil Type Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSoilType,
                      decoration: InputDecoration(
                        labelText: isMr ? 'मातीचा प्रकार *' : 'Soil Type *',
                        prefixIcon: const Icon(Icons.layers_outlined),
                      ),
                      items: _soilTypes.map((s) {
                        return DropdownMenuItem(
                          value: s['val'],
                          child: Text(isMr ? s['mr']! : s['en']!, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedSoilType = v!),
                    ),
                    const SizedBox(height: 14),

                    // Irrigation Method Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedIrrigation,
                      decoration: InputDecoration(
                        labelText: isMr ? 'सिंचन पद्धत *' : 'Irrigation Type *',
                        prefixIcon: const Icon(Icons.water_drop_outlined),
                      ),
                      items: _irrigationTypes.map((i) {
                        return DropdownMenuItem(
                          value: i['val'],
                          child: Text(isMr ? i['mr']! : i['en']!, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedIrrigation = v!),
                    ),
                    const SizedBox(height: 14),

                    // Water Source Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedWaterSource,
                      decoration: InputDecoration(
                        labelText: isMr ? 'पाण्याचा स्रोत *' : 'Water Source *',
                        prefixIcon: const Icon(Icons.opacity),
                      ),
                      items: _waterSources.map((w) {
                        return DropdownMenuItem(
                          value: w['val'],
                          child: Text(isMr ? w['mr']! : w['en']!, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedWaterSource = v!),
                    ),
                    const SizedBox(height: 14),

                    // Primary Active Checkbox
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        isMr ? 'हे मुख्य सक्रिय शेत म्हणून निवडा' : 'Set as Active Primary Farm',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        isMr ? 'हवामान, कीड रोग व AI सल्ला या शेतानुसार दिसेल' : 'Weather & AI advice will target this farm',
                        style: const TextStyle(fontSize: 12),
                      ),
                      value: _isPrimary,
                      activeTrackColor: AppColors.primaryGreen,
                      onChanged: (val) => setState(() => _isPrimary = val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      isEdit
                          ? (isMr ? 'बदल जतन करा' : 'Save Changes')
                          : (isMr ? 'शेत जतन करा' : 'Save Farm Plot'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:payfussion/presentations/widgets/auth_widgets/credential_text_field.dart';
import 'governement_pay_fee_screen.dart';


class GovtService {
  final String name;
  final String agency;
  final String emoji;
  final Color backgroundColor;
  final String inputLabel;
  final String inputHint;
  final bool hasInfoIcon;
  final String? infoText;

  GovtService({
    required this.name,
    required this.agency,
    required this.emoji,
    required this.backgroundColor,
    required this.inputLabel,
    required this.inputHint,
    this.hasInfoIcon = false,
    this.infoText,
  });
}

class GovernmentFeesScreen extends StatefulWidget {
  const GovernmentFeesScreen({Key? key}) : super(key: key);

  @override
  State<GovernmentFeesScreen> createState() => _GovernmentFeesScreenState();
}

class _GovernmentFeesScreenState extends State<GovernmentFeesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<GovtService> _services = [
    GovtService(
      name: 'Passport Fees',
      agency: 'U.S. Department of State',
      emoji: '🛂',
      backgroundColor: Colors.blue.shade50,
      inputLabel: 'Passport Application Number',
      inputHint: '123456789',
    ),
    GovtService(
      name: 'USCIS Application Fees',
      agency: 'U.S. Citizenship & Immigration',
      emoji: '🏛️',
      backgroundColor: Colors.green.shade50,
      inputLabel: 'Receipt Number',
      inputHint: 'IOE1234567890',
    ),
    GovtService(
      name: 'IRS Tax Payment',
      agency: 'Internal Revenue Service',
      emoji: '💰',
      backgroundColor: Colors.red.shade50,
      inputLabel: 'SSN / Tax ID',
      inputHint: '123-45-6789',
    ),
    GovtService(
      name: 'DMV Vehicle Registration',
      agency: 'Department of Motor Vehicles',
      emoji: '🚗',
      backgroundColor: Colors.yellow.shade50,
      inputLabel: 'Vehicle License Plate',
      inputHint: 'ABC1234',
    ),
    GovtService(
      name: 'Traffic Violation Fines',
      agency: 'Local Traffic Court',
      emoji: '🚦',
      backgroundColor: Colors.orange.shade50,
      inputLabel: 'Citation Number',
      inputHint: '1234567890123456',
      hasInfoIcon: true,
      infoText: 'Tap on information icon for tutorial on how to see your "Citation Number"',
    ),
    GovtService(
      name: 'National Park Passes',
      agency: 'National Park Service',
      emoji: '🏞️',
      backgroundColor: Colors.teal.shade50,
      inputLabel: 'Pass ID Number',
      inputHint: 'NP123456789',
    ),
    GovtService(
      name: 'TSA PreCheck Fee',
      agency: 'Transportation Security Admin',
      emoji: '✈️',
      backgroundColor: Colors.indigo.shade50,
      inputLabel: 'Known Traveler Number',
      inputHint: '123456789',
    ),
    GovtService(
      name: 'Social Security Services',
      agency: 'Social Security Administration',
      emoji: '👥',
      backgroundColor: Colors.purple.shade50,
      inputLabel: 'Social Security Number',
      inputHint: '123-45-6789',
    ),
    GovtService(
      name: 'FOIA Request Fees',
      agency: 'Various Federal Agencies',
      emoji: '📄',
      backgroundColor: Colors.pink.shade50,
      inputLabel: 'Request Tracking Number',
      inputHint: 'FOIA-2024-123456',
    ),
    GovtService(
      name: 'Federal Court Filing Fees',
      agency: 'U.S. Federal Courts',
      emoji: '⚖️',
      backgroundColor: Colors.grey.shade50,
      inputLabel: 'Case Number',
      inputHint: '1:24-cv-12345',
    ),
    GovtService(
      name: 'Medicare Premium Payment',
      agency: 'Centers for Medicare & Medicaid',
      emoji: '🏥',
      backgroundColor: Colors.blue.shade50,
      inputLabel: 'Medicare Number',
      inputHint: '1AB2-CD3-EF45',
    ),
    GovtService(
      name: 'Small Business Filing Fees',
      agency: 'Small Business Administration',
      emoji: '🏢',
      backgroundColor: Colors.green.shade50,
      inputLabel: 'Business EIN',
      inputHint: '12-3456789',
    ),
  ];

  List<GovtService> get _filteredServices {
    if (_searchQuery.isEmpty) {
      return _services;
    }
    return _services.where((service) {
      return service.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          service.agency.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pay Govt. Fees',
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppTextFormField(
              controller: _searchController,
              helpText: 'Search',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },

            ),
          ),

          // Services List
          Expanded(
            child: ListView.builder(
              itemCount: _filteredServices.length,
              itemBuilder: (BuildContext context, index) {
                final service = _filteredServices[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GovernementPayFeeScreen(service: service),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children: [
                        // Icon Container
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: service.backgroundColor,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Center(
                            child: Text(
                              service.emoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Service Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                service.agency,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Arrow Icon
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey[400],
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
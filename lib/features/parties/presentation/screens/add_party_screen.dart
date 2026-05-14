import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/party_providers.dart';

class AddPartyScreen extends ConsumerStatefulWidget {
  const AddPartyScreen({super.key});

  @override
  ConsumerState<AddPartyScreen> createState() => _AddPartyScreenState();
}

class _AddPartyScreenState extends ConsumerState<AddPartyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _cashBalanceType = 'Dr';
  String _goldBalanceType = 'Dr';
  String _diamondBalanceType = 'Dr';

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _gstinController = TextEditingController();
  final _addressController = TextEditingController();
  final _cashBalanceController = TextEditingController();
  final _goldBalanceController = TextEditingController();
  final _diamondBalanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    _gstinController.dispose();
    _addressController.dispose();
    _cashBalanceController.dispose();
    _goldBalanceController.dispose();
    _diamondBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFBF7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6B5800)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add New Party',
          style: GoogleFonts.montserrat(
            color: const Color(0xFF6B5800),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2EFE8), // Light cream
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: const Color(0xFFDCA73A), // Gold color from image
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelColor: const Color(0xFF4A3E1F),
                  unselectedLabelColor: const Color(0xFF6B5800).withOpacity(0.7),
                  labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'Customer'),
                    Tab(text: 'Vendor'),
                  ],
                ),
              ),
            ),
            
            // Form
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            label: 'Full Name *',
                            hint: 'e.g. Ramesh Jewellers',
                            prefixIcon: Icons.person_outline,
                            controller: _nameController,
                          ),
                          const SizedBox(height: 16),
                          _buildPhoneField(controller: _phoneController),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Business Name (Optional)',
                            hint: 'Trading name',
                            controller: _businessNameController,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'GSTIN (Optional)',
                            hint: '15-DIGIT ALPHANUMERIC',
                            controller: _gstinController,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Address',
                            hint: 'Complete billing/shipping address',
                            maxLines: 3,
                            controller: _addressController,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Opening Balance Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Opening Balance',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Initialize ledger accounts for this party.',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: Column(
                            children: [
                               _buildBalanceField(
                                label: 'Cash Balance (INR)',
                                hint: '0.00',
                                prefixText: '₹',
                                balanceType: _cashBalanceType,
                                controller: _cashBalanceController,
                                onTypeChanged: (val) => setState(() => _cashBalanceType = val),
                              ),
                              const SizedBox(height: 20),
                              _buildBalanceField(
                                label: 'Fine Gold (g)',
                                hint: '0.000',
                                balanceType: _goldBalanceType,
                                controller: _goldBalanceController,
                                onTypeChanged: (val) => setState(() => _goldBalanceType = val),
                              ),
                              const SizedBox(height: 20),
                              _buildBalanceField(
                                label: 'Diamond (ct)',
                                hint: '0.000',
                                balanceType: _diamondBalanceType,
                                controller: _diamondBalanceController,
                                onTypeChanged: (val) => setState(() => _diamondBalanceType = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Save Button
            Container(
              padding: const EdgeInsets.all(16.0),
              color: const Color(0xFFFDFBF7),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: Consumer(
                  builder: (context, ref, child) {
                    final partyState = ref.watch(partyNotifierProvider);
                    
                    return ElevatedButton.icon(
                      onPressed: partyState.isLoading ? null : () async {
                        if (_nameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter party name')),
                          );
                          return;
                        }
                        
                        if (_phoneController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter phone number')),
                          );
                          return;
                        }

                        final double cash = double.tryParse(_cashBalanceController.text) ?? 0.0;
                        final double gold = double.tryParse(_goldBalanceController.text) ?? 0.0;
                        final double diamond = double.tryParse(_diamondBalanceController.text) ?? 0.0;

                        final success = await ref.read(partyNotifierProvider.notifier).createParty(
                          name: _nameController.text.trim(),
                          type: _tabController.index == 0 ? 'Customer' : 'Vendor',
                          phone: _phoneController.text.trim(),
                          address: _addressController.text.trim(),
                          email: '', // Not in UI yet
                          cashBalance: _cashBalanceType == 'Dr' ? cash : -cash,
                          goldBalance: _goldBalanceType == 'Dr' ? gold : -gold,
                          diamondBalance: _diamondBalanceType == 'Dr' ? diamond : -diamond,
                        );

                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Party saved successfully')),
                          );
                          Navigator.pop(context);
                        } else if (partyState.error != null && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(partyState.error!)),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF755E0B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: partyState.isLoading 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Icon(Icons.save, color: Colors.white, size: 20),
                      label: Text(
                        partyState.isLoading ? 'Saving...' : 'Save Party',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    IconData? prefixIcon,
    int maxLines = 1,
    TextEditingController? controller,
  }) {
    List<TextSpan> labelSpans = [];
    if (label.contains('*')) {
      final parts = label.split('*');
      labelSpans.add(TextSpan(text: parts[0]));
      labelSpans.add(const TextSpan(text: '*', style: TextStyle(color: Colors.red)));
    } else if (label.contains('(Optional)')) {
      final parts = label.split('(Optional)');
      labelSpans.add(TextSpan(text: parts[0]));
      labelSpans.add(TextSpan(text: '(Optional)', style: GoogleFonts.montserrat(color: Colors.grey[500], fontWeight: FontWeight.w600)));
    } else {
      labelSpans.add(TextSpan(text: label));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
            children: labelSpans,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0D8C3)),
          ),
          child: TextField(
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: Colors.grey[400])
                  : null,
            ),
            controller: controller,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField({TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
            children: const [
              TextSpan(text: 'Phone Number '),
              TextSpan(text: '*', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0D8C3)),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFF2EFE8),
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+91',
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Container(
                width: 1,
                color: const Color(0xFFE0D8C3),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '10-digit number',
                    hintStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceField({
    required String label,
    required String hint,
    String? prefixText,
    required String balanceType,
    required ValueChanged<String> onTypeChanged,
    TextEditingController? controller,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            Text(
              'Dr / Cr',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF8A7311),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0D8C3)),
          ),
          child: Row(
            children: [
              if (prefixText != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    prefixText,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
                    contentPadding: EdgeInsets.only(
                      bottom: 4,
                      left: prefixText == null ? 16 : 0,
                    ),
                  ),
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.unfold_more, size: 20, color: Colors.grey[400]),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => onTypeChanged(balanceType == 'Dr' ? 'Cr' : 'Dr'),
                child: Container(
                  width: 56,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2EFE8),
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(7)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    balanceType,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4A3E1F),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

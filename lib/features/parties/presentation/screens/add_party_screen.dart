import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/party_providers.dart';

class AddPartyScreen extends ConsumerStatefulWidget {
  const AddPartyScreen({super.key});

  @override
  ConsumerState<AddPartyScreen> createState() => _AddPartyScreenState();
}

class _AddPartyScreenState extends ConsumerState<AddPartyScreen> {
  String _transactionType = 'IN';
  String _category = 'Money';
  bool _isSaved = false;

  String _cashBalanceType = 'Dr';
  String _goldBalanceType = 'Dr';
  String _diamondBalanceType = 'Dr';

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cashBalanceController = TextEditingController();
  final _goldBalanceController = TextEditingController();
  final _diamondBalanceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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
            // Form
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // IN / OUT Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4EDE4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTransactionTypeButton(
                              title: 'IN (Receive)',
                              icon: Icons.arrow_downward,
                              selectedColor: const Color(0xFF8A7311),
                              isSelected: _transactionType == 'IN',
                              onTap: () => setState(() => _transactionType = 'IN'),
                            ),
                          ),
                          Expanded(
                            child: _buildTransactionTypeButton(
                              title: 'OUT (Give)',
                              icon: Icons.arrow_upward,
                              selectedColor: Colors.black87,
                              isSelected: _transactionType == 'OUT',
                              onTap: () => setState(() => _transactionType = 'OUT'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
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
                            label: 'Address',
                            hint: 'Complete billing/shipping address',
                            maxLines: 3,
                            controller: _addressController,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Category Toggle
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Category',
                        style: GoogleFonts.montserrat(
                          fontSize: 13, 
                          fontWeight: FontWeight.w600, 
                          color: Colors.black87
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4EDE4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _buildCategoryButton('Money'),
                          _buildCategoryButton('Gold'),
                          _buildCategoryButton('Diamond'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Balance Fields based on Category
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
                          if (_category == 'Money')
                            _buildBalanceField(
                              label: 'Cash Balance (INR)',
                              hint: '0.00',
                              prefixText: '₹',
                              balanceType: _cashBalanceType,
                              controller: _cashBalanceController,
                              onTypeChanged: (val) => setState(() => _cashBalanceType = val),
                            ),
                          if (_category == 'Gold')
                            _buildBalanceField(
                              label: 'Fine Gold (g)',
                              hint: '0.000',
                              balanceType: _goldBalanceType,
                              controller: _goldBalanceController,
                              onTypeChanged: (val) => setState(() => _goldBalanceType = val),
                            ),
                          if (_category == 'Diamond')
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
                      onPressed: (partyState.isLoading || _isSaved) ? null : () async {
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
                          type: _transactionType == 'IN' ? 'Customer' : 'Vendor',
                          phone: _phoneController.text.trim(),
                          address: _addressController.text.trim(),
                          email: '', 
                          cashBalance: _cashBalanceType == 'Dr' ? cash : -cash,
                          goldBalance: _goldBalanceType == 'Dr' ? gold : -gold,
                          diamondBalance: _diamondBalanceType == 'Dr' ? diamond : -diamond,
                        );

                        if (success && mounted) {
                          setState(() => _isSaved = true);
                          await Future.delayed(const Duration(milliseconds: 800));
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        } else if (partyState.error != null && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(partyState.error!)),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSaved ? Colors.green : const Color(0xFF755E0B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: _isSaved 
                          ? const Icon(Icons.check_circle, color: Colors.white, size: 20, key: ValueKey('check'))
                          : (partyState.isLoading 
                              ? const SizedBox(
                                  key: ValueKey('loading'),
                                  width: 20, 
                                  height: 20, 
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                )
                              : const Icon(Icons.save, color: Colors.white, size: 20, key: ValueKey('save'))),
                      ),
                      label: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _isSaved ? 'Saved!' : (partyState.isLoading ? 'Saving...' : 'Save Party'),
                          key: ValueKey(_isSaved ? 'saved_text' : (partyState.isLoading ? 'saving_text' : 'save_text')),
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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

  Widget _buildTransactionTypeButton({
    required String title,
    required IconData icon,
    required Color selectedColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? selectedColor : Colors.black54, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.montserrat(
                color: isSelected ? selectedColor : Colors.black54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    final isSelected = _category == category;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _category = category),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              category,
              style: GoogleFonts.montserrat(
                color: isSelected ? const Color(0xFF8A7311) : Colors.black54,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
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

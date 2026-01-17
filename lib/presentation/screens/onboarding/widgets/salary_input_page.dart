import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';

class SalaryInputPage extends StatefulWidget {
  final double initialSalary;
  final ValueChanged<double> onSalaryChanged;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const SalaryInputPage({
    super.key,
    required this.initialSalary,
    required this.onSalaryChanged,
    required this.onBack,
    required this.onNext,
  });

  @override
  State<SalaryInputPage> createState() => _SalaryInputPageState();
}

class _SalaryInputPageState extends State<SalaryInputPage> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialSalary > 0 ? _formatNumber(widget.initialSalary.toInt().toString()) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatNumber(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) return '';

    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && (digitsOnly.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(digitsOnly[i]);
    }
    return buffer.toString();
  }

  double _parseNumber(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    return double.tryParse(digitsOnly) ?? 0;
  }

  void _onTextChanged(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    final formatted = _formatNumber(digitsOnly);

    if (formatted != value) {
      final cursorOffset = formatted.length - value.length;
      final newCursorPosition = _controller.selection.baseOffset + cursorOffset;

      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(
          offset: newCursorPosition.clamp(0, formatted.length),
        ),
      );
    }

    widget.onSalaryChanged(_parseNumber(formatted));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.payments_outlined,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Укажите ваш оклад',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Сумма до вычета налогов',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const Spacer(),
          _buildSalaryInput(),
          const SizedBox(height: 12),
          Text(
            'Вы сможете изменить это в настройках',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const Spacer(flex: 2),
          _buildButtons(),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSalaryInput() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d ]')),
        LengthLimitingTextInputFormatter(15),
      ],
      decoration: InputDecoration(
        hintText: '0',
        hintStyle: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.4),
        ),
        suffixText: 'руб.',
        suffixStyle: TextStyle(
          fontSize: 16,
          color: Colors.white.withOpacity(0.7),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      onChanged: _onTextChanged,
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: widget.onBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Назад',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: widget.onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryPurple,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Далее',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

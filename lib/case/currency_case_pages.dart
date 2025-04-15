import 'package:flutter/material.dart';
import 'package:will_widget_playground/utils/currency_formatter_w.dart';

class CurrencyExamplesPage extends StatefulWidget {
  const CurrencyExamplesPage({super.key});

  @override
  State<CurrencyExamplesPage> createState() => _CurrencyExamplesPageState();
}

class _CurrencyExamplesPageState extends State<CurrencyExamplesPage> {
  late CurrencyFormatW euroSettings;
  @override
  void initState() {
    euroSettings = CurrencyFormatW(
      code: 'eur',
      symbol: '€',
      symbolSide: SymbolSide.left,
      thousandSeparator: '.',
      decimalSeparator: ',',
      symbolSeparator: '',
    );

    String formatted = CurrencyFormatterW.format(1910.9347, euroSettings);
    String compact = CurrencyFormatterW.format(1910.5, euroSettings, decimal: 1);
    String intEnd = CurrencyFormatterW.format(1910.0, euroSettings, decimal: 1);
    String threeDecimal = CurrencyFormatterW.format(1910.0, euroSettings, enforceDecimals: true);

    debugPrint(formatted);
    debugPrint(compact);
    debugPrint(intEnd);
    debugPrint(threeDecimal);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("货币化合集")),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            _buildExampleSection("货币化"),

          ],
        ),
      ),
    );
  }

  Widget _buildExampleSection(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(title,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800])),
    );
  }
}

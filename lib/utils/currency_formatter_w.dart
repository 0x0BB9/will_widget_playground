import 'dart:io';

import 'package:intl/intl.dart';

String get localeName => Platform.localeName;

abstract class CurrencyFormatterW {
  static const Map<int, String> _letters = {
    1000000000000: 'T',
    1000000000: 'B',
    1000000: 'M',
    1000: 'K'
  };

  /// Format [amount] using the [settings] of a currency.
  ///
  ///
  /// [decimal] is the number of decimal places used when rounding.
  /// e.g. `'$ 45.5'` (1 decimal place), `'$ 45.52'` (2 decimal places).
  ///
  /// If [showThousandSeparator] is set to `false`, the thousand separator won't be shown.
  /// e.g. `'$ 1200'`instead of `'$ 1,200'`.
  ///
  /// If [enforceDecimals] is set to `true`, decimals will be shown even if it is an integer.
  /// e.g. `'$ 5.00'` instead of `'$ 5'`.
  static String format(
    amount,
    CurrencyFormatW settings, {
    int decimal = 1,
    showThousandSeparator = true,
    enforceDecimals = false,
  }) {
    amount = double.parse('$amount');
    late String number;
    String letter = '';

    number = amount.toStringAsFixed(decimal);
    if (!enforceDecimals &&
        double.parse(number) == double.parse(number).round()) {
      number = double.parse(number).round().toString();
    }
    number = number.replaceAll('.', settings.decimalSeparator);
    if (showThousandSeparator) {
      String oldNum = number.split(settings.decimalSeparator)[0];
      number = number.contains(settings.decimalSeparator)
          ? settings.decimalSeparator +
              number.split(settings.decimalSeparator)[1]
          : '';
      for (int i = 0; i < oldNum.length; i++) {
        number = oldNum[oldNum.length - i - 1] + number;
        if ((i + 1) % 3 == 0 &&
            i < oldNum.length - (oldNum.startsWith('-') ? 2 : 1)) {
          number = settings.thousandSeparator + number;
        }
      }
    }

    switch (settings.symbolSide) {
      case SymbolSide.left:
        return '${settings.symbol}${settings.symbolSeparator}$number$letter';
      case SymbolSide.right:
        return '$number$letter${settings.symbolSeparator}${settings.symbol}';
      default:
        return '$number$letter';
    }
  }

  /// Parse a formatted string to a number.
  static num parse(String input, CurrencyFormatW settings) {
    String txt = input
        .replaceFirst(settings.thousandSeparator, '')
        .replaceFirst(settings.decimalSeparator, '.')
        .replaceFirst(settings.symbol, '')
        .replaceFirst(settings.symbolSeparator, '')
        .trim();

    int multiplicator = 1;
    for (int mult in _letters.keys) {
      final String letter = _letters[mult]!;
      if (txt.endsWith(letter)) {
        txt = txt.replaceFirst(letter, '');
        multiplicator = mult;
        break;
      }
    }

    return num.parse(txt) * multiplicator;
  }


  /// List that contains the [CurrencyFormatW] from major currencies.
  static const List<CurrencyFormatW> majorsList = [
    CurrencyFormatW.usd,
    CurrencyFormatW.eur,
    CurrencyFormatW.jpy,
    CurrencyFormatW.gbp,
    CurrencyFormatW.chf,
    CurrencyFormatW.cny,
    CurrencyFormatW.sek,
    CurrencyFormatW.krw,
    CurrencyFormatW.inr,
    CurrencyFormatW.rub,
    CurrencyFormatW.zar,
    CurrencyFormatW.tryx,
    CurrencyFormatW.pln,
    CurrencyFormatW.thb,
    CurrencyFormatW.idr,
    CurrencyFormatW.huf,
    CurrencyFormatW.czk,
    CurrencyFormatW.ils,
    CurrencyFormatW.php,
    CurrencyFormatW.myr,
    CurrencyFormatW.ron
  ];
}


/// This class contains the formatting settings for a currency.
class CurrencyFormatW {
  /// Abbreviation of the currency in lowercase. e.g. 'usd'
  final String? code;

  /// Symbol of the currency. e.g. '€'
  final String symbol;

  /// Whether the symbol is shown before or after the money value, or if it is not shown at all.
  /// e.g. $ 125 ([SymbolSide.left]) or 125 € ([SymbolSide.right]).
  final SymbolSide symbolSide;

  final String? _thousandSeparator;

  final String? _decimalSeparator;

  /// Character(s) between the number and the currency symbol. e.g. $ 9.10 (`' '`) or $9.10 (`''`).
  /// It defaults to a normal space (`' '`).
  final String symbolSeparator;

  const CurrencyFormatW({
    required this.symbol,
    this.code,
    this.symbolSide = SymbolSide.left,
    String? thousandSeparator,
    String? decimalSeparator,
    this.symbolSeparator = ' ',
  })  : _thousandSeparator = thousandSeparator,
        _decimalSeparator = decimalSeparator;

  /// Thousand separator. e.g. 1,000,000 (`','`) or 1.000.000 (`'.'`). It can be set to any desired [String].
  /// It defaults to `','` for [SymbolSide.left] and to `'.'` for [SymbolSide.right].
  String get thousandSeparator =>
      _thousandSeparator ?? (symbolSide == SymbolSide.left ? ',' : '.');

  /// Decimal separator. e.g. 9.10 (`'.'`) or 9,10 (`','`). It can be set to any desired [String].
  /// It defaults to `'.'` for [SymbolSide.left] and to `','` for [SymbolSide.right].
  String get decimalSeparator =>
      _decimalSeparator ?? (symbolSide == SymbolSide.left ? '.' : ',');

  /// Returns the same [CurrencyFormatW] but with some changed parameters.
  CurrencyFormatW copyWith({
    String? code,
    String? symbol,
    SymbolSide? symbolSide,
    String? thousandSeparator,
    String? decimalSeparator,
    String? symbolSeparator,
  }) =>
      CurrencyFormatW(
        code: code ?? this.code,
        symbol: symbol ?? this.symbol,
        symbolSide: symbolSide ?? this.symbolSide,
        thousandSeparator: thousandSeparator ?? this.thousandSeparator,
        decimalSeparator: decimalSeparator ?? this.decimalSeparator,
        symbolSeparator: symbolSeparator ?? this.symbolSeparator,
      );

  /// Get the [CurrencyFormatW] of a currency using its symbol.
  static CurrencyFormatW? fromSymbol(
    String symbol, [
    List<CurrencyFormatW> currencies = CurrencyFormatterW.majorsList,
  ]) {
    if (currencies.any((c) => c.symbol == symbol)) {
      return currencies.firstWhere((c) => c.symbol == symbol);
    }
    return null;
  }

  /// Get the [CurrencyFormatW] of a currency using its abbreviation.
  static CurrencyFormatW? fromCode(
    String code, [
    List<CurrencyFormatW> currencies = CurrencyFormatterW.majorsList,
  ]) {
    if (currencies.any((c) => c.code?.toLowerCase() == code.toLowerCase())) {
      return currencies
          .firstWhere((c) => c.code?.toLowerCase() == code.toLowerCase());
    }
    return null;
  }

  /// Get the [CurrencyFormatW] of a currency using its locale.
  ///
  /// If [locale] is not specified, the local currency will be used.
  ///
  /// If [currencies] is not specified, the majors list will be used.
  ///
  /// ```dart
  /// // Get the local currency with a custom currencies list.
  /// CurrencyFormat? local = CurrencyFormat.fromLocale(null, myCurrencies);
  /// ```
  static CurrencyFormatW? fromLocale([
    String? locale,
    List<CurrencyFormatW> currencies = CurrencyFormatterW.majorsList,
  ]) =>
      fromSymbol(
        NumberFormat.simpleCurrency(locale: locale ?? localeName)
            .currencySymbol,
      );

  /// Get the [CurrencyFormatW] of the local currency.
  static CurrencyFormatW? get local => fromSymbol(localSymbol);

  /// Get the symbol of the local currency.
  static String get localSymbol =>
      NumberFormat.simpleCurrency(locale: localeName).currencySymbol;

  /// The [CurrencyFormatW] of the US Dollar.
  static const CurrencyFormatW usd =
      CurrencyFormatW(code: 'usd', symbol: '\$', symbolSide: SymbolSide.left);

  /// The [CurrencyFormatW] of the Euro.
  static const CurrencyFormatW eur =
      CurrencyFormatW(code: 'eur', symbol: '€', symbolSide: SymbolSide.right);

  /// The [CurrencyFormatW] of the Japanese Yen.
  static const CurrencyFormatW jpy =
      CurrencyFormatW(code: 'jpy', symbol: '¥', symbolSide: SymbolSide.left);

  /// The [CurrencyFormatW] of the British Pound.
  static const CurrencyFormatW gbp =
      CurrencyFormatW(code: 'gbp', symbol: '£', symbolSide: SymbolSide.left);

  /// The [CurrencyFormatW] of the Swiss Franc.
  static const CurrencyFormatW chf =
      CurrencyFormatW(code: 'chf', symbol: 'fr', symbolSide: SymbolSide.right);

  /// The [CurrencyFormatW] of the Chinese Yuan.
  static const CurrencyFormatW cny =
      CurrencyFormatW(code: 'cny', symbol: '元', symbolSide: SymbolSide.left);

  /// The [CurrencyFormatW] of the Swedish Krona.
  static const CurrencyFormatW sek =
      CurrencyFormatW(code: 'sek', symbol: 'kr', symbolSide: SymbolSide.right);

  /// The [CurrencyFormatW] of the South Korean Won.
  static const CurrencyFormatW krw =
      CurrencyFormatW(code: 'krw', symbol: '₩', symbolSide: SymbolSide.left);

  /// The [CurrencyFormatW] of the Indian Rupee.
  static const CurrencyFormatW inr =
      CurrencyFormatW(code: 'inr', symbol: '₹', symbolSide: SymbolSide.left);

  /// The [CurrencyFormatW] of the Russian Ruble.
  static const CurrencyFormatW rub =
      CurrencyFormatW(code: 'rub', symbol: '₽', symbolSide: SymbolSide.right);

  /// The [CurrencyFormatW] of the South African Rand.
  static const CurrencyFormatW zar =
      CurrencyFormatW(code: 'zar', symbol: 'R', symbolSide: SymbolSide.left);

  /// The [CurrencyFormatW] of the Turkish Lira.
  static const CurrencyFormatW tryx =
      CurrencyFormatW(code: 'tryx', symbol: '₺', symbolSide: SymbolSide.left);

  /// The [CurrencyFormatW] of the Polish Zloty.
  static const CurrencyFormatW pln =
      CurrencyFormatW(code: 'pln', symbol: 'zł', symbolSide: SymbolSide.right);

  /// The [CurrencyFormatW] of the Thai Baht.
  static const CurrencyFormatW thb =
      CurrencyFormatW(code: 'thb', symbol: '฿', symbolSide: SymbolSide.left);

  /// The [CurrencyFormatW] of the Indonesian Rupiah.
  static const CurrencyFormatW idr =
      CurrencyFormatW(code: 'idr', symbol: 'Rp', symbolSide: SymbolSide.left);

  /// The [CurrencyFormatW] of the Hungarian Forint.
  static const CurrencyFormatW huf =
      CurrencyFormatW(code: 'huf', symbol: 'Ft', symbolSide: SymbolSide.right);

  /// The [CurrencyFormatW] of the Czech Koruna.
  static const CurrencyFormatW czk =
      CurrencyFormatW(code: 'czk', symbol: 'Kč', symbolSide: SymbolSide.right);

  /// The [CurrencyFormatW] of the Israeli New Shekel.
  static const CurrencyFormatW ils =
      CurrencyFormatW(code: 'ils', symbol: '₪', symbolSide: SymbolSide.left);

  /// The [CurrencyFormatW] of the Philippine Peso.
  static const CurrencyFormatW php =
      CurrencyFormatW(code: 'php', symbol: '₱', symbolSide: SymbolSide.left);

  /// The [CurrencyFormatW] of the Malaysian Ringgit.
  static const CurrencyFormatW myr =
      CurrencyFormatW(code: 'myr', symbol: 'RM', symbolSide: SymbolSide.left);

  /// The [CurrencyFormatW] of the Romanian Leu.
  static const CurrencyFormatW ron =
      CurrencyFormatW(code: 'ron', symbol: 'L', symbolSide: SymbolSide.right);

  @override
  String toString() =>
      'CurrencyFormat<${CurrencyFormatterW.format(9999.99, this)}>';

  @override
  operator ==(other) =>
      other is CurrencyFormatW &&
      other.symbol == symbol &&
      other.symbolSide == symbolSide &&
      other.thousandSeparator == thousandSeparator &&
      other.decimalSeparator == decimalSeparator &&
      other.symbolSeparator == symbolSeparator;

  @override
  int get hashCode =>
      symbol.hashCode ^
      symbolSide.hashCode ^
      thousandSeparator.hashCode ^
      decimalSeparator.hashCode ^
      symbolSeparator.hashCode;
}

/// Enumeration for the three possibilities when writing the currency symbol.
enum SymbolSide { left, right, none }

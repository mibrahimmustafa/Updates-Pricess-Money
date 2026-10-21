/// Strongly-typed enum representing every tradeable metal asset in the pool.
enum MetalCode {
  gold('XAU', 'Gold', isPreciousMetal: true, supportsGramPricing: true),
  silver('XAG', 'Silver', isPreciousMetal: true, supportsGramPricing: true),
  platinum('XPT', 'Platinum', isPreciousMetal: true, supportsGramPricing: true),
  palladium('XPD', 'Palladium', isPreciousMetal: true, supportsGramPricing: true),
  copper('HG', 'Copper', isPreciousMetal: false, supportsGramPricing: true),
  bitcoin('BTC', 'Bitcoin', isPreciousMetal: false, supportsGramPricing: false),
  ethereum('ETH', 'Ethereum', isPreciousMetal: false, supportsGramPricing: false);

  const MetalCode(
    this.symbol,
    this.englishName, {
    required this.isPreciousMetal,
    required this.supportsGramPricing,
  });

  /// The API symbol string used by gold-api.com (e.g. 'XAU', 'XAG').
  final String symbol;

  /// English display name.
  final String englishName;

  /// True for precious metals: gold, silver, platinum, palladium.
  final bool isPreciousMetal;

  /// True when per-gram pricing makes physical sense (precious metals + copper).
  /// False for crypto assets (BTC, ETH) which are priced per whole coin.
  final bool supportsGramPricing;

  /// Looks up a [MetalCode] by its [symbol] string.
  /// Returns null if the symbol is not recognized.
  static MetalCode? fromSymbol(String symbol) {
    for (final code in MetalCode.values) {
      if (code.symbol == symbol) return code;
    }
    return null;
  }

  /// Alias for [fromSymbol].
  static MetalCode? fromCode(String code) => fromSymbol(code);
}

import 'package:shared_preferences/shared_preferences.dart';

/// Persists the player's total token balance across races.
class TokenWalletRepository {
  static const _key = 'tokens_total';

  Future<int> balance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  Future<int> addTokens(int amount) async {
    if (amount <= 0) return balance();
    final prefs = await SharedPreferences.getInstance();
    final next = (prefs.getInt(_key) ?? 0) + amount;
    await prefs.setInt(_key, next);
    return next;
  }

  Future<bool> spendTokens(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_key) ?? 0;
    if (current < amount) return false;
    await prefs.setInt(_key, current - amount);
    return true;
  }
}

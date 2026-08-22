import 'package:shared_preferences/shared_preferences.dart';

import '../../data/race_content.dart';
import '../models/race_models.dart';
import 'token_wallet.dart';

class WingUpgradeResult {
  const WingUpgradeResult({
    required this.progress,
    required this.success,
    this.reason,
  });
  final WorldWingProgress progress;
  final bool success;
  final String? reason;
}

class WingProgressionRepository {
  WingProgressionRepository({TokenWalletRepository? wallet})
    : wallet = wallet ?? TokenWalletRepository();

  final TokenWalletRepository wallet;

  Future<WorldWingProgress> load(String worldId) async {
    final prefs = await SharedPreferences.getInstance();
    return WorldWingProgress(
      worldId: worldId,
      wingLevel: prefs.getInt('wing_$worldId') ?? 1,
      bossCleared: prefs.getBool('boss_$worldId') ?? false,
    );
  }

  /// Spends tokens from the wallet and persists the wing upgrade atomically.
  /// Fails (without spending) if already max level or the wallet can't afford it.
  Future<WingUpgradeResult> upgrade(String worldId) async {
    final current = await load(worldId);
    if (current.wingLevel >= 10) {
      return WingUpgradeResult(
        progress: current,
        success: false,
        reason: 'Wing is already at max level',
      );
    }
    final next = wingLevels()[current.wingLevel];
    final spent = await wallet.spendTokens(next.cost);
    if (!spent) {
      return WingUpgradeResult(
        progress: current,
        success: false,
        reason: 'Not enough tokens',
      );
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('wing_$worldId', current.wingLevel + 1);
    final updated = WorldWingProgress(
      worldId: worldId,
      wingLevel: current.wingLevel + 1,
      bossCleared: current.bossCleared,
    );
    return WingUpgradeResult(progress: updated, success: true);
  }

  Future<void> markBossCleared(String worldId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('boss_$worldId', true);
  }
}

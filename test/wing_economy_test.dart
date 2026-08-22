import 'package:flutter_test/flutter_test.dart';
import 'package:paper_plane_flight/src/game/systems/token_wallet.dart';
import 'package:paper_plane_flight/src/game/systems/wing_progression.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TokenWalletRepository', () {
    test('starts at zero and accumulates deposits', () async {
      final wallet = TokenWalletRepository();
      expect(await wallet.balance(), 0);
      expect(await wallet.addTokens(40), 40);
      expect(await wallet.addTokens(15), 55);
    });

    test(
      'spendTokens fails without sufficient balance and leaves it unchanged',
      () async {
        final wallet = TokenWalletRepository();
        await wallet.addTokens(100);
        expect(await wallet.spendTokens(500), isFalse);
        expect(await wallet.balance(), 100);
        expect(await wallet.spendTokens(100), isTrue);
        expect(await wallet.balance(), 0);
      },
    );
  });

  group('WingProgressionRepository', () {
    test('new world starts at wing level 1 with boss locked', () async {
      final repo = WingProgressionRepository();
      final progress = await repo.load('sky_islands');
      expect(progress.wingLevel, 1);
      expect(progress.bossCleared, isFalse);
      expect(progress.bossUnlocked, isFalse);
    });

    test(
      'upgrade fails and spends nothing when tokens are insufficient',
      () async {
        final wallet = TokenWalletRepository();
        final repo = WingProgressionRepository(wallet: wallet);
        final result = await repo.upgrade('sky_islands');
        expect(result.success, isFalse);
        expect(await wallet.balance(), 0);
        expect((await repo.load('sky_islands')).wingLevel, 1);
      },
    );

    test('upgrade spends the exact cost and advances the wing level', () async {
      final wallet = TokenWalletRepository();
      final repo = WingProgressionRepository(wallet: wallet);
      await wallet.addTokens(1000);
      final result = await repo.upgrade('sky_islands');
      expect(result.success, isTrue);
      expect(result.progress.wingLevel, 2);
      expect(await wallet.balance(), 1000 - 288); // 120 + 2*2*42
    });

    test(
      'boss unlocks only once wing level reaches 10 and stays cleared once marked',
      () async {
        final wallet = TokenWalletRepository();
        final repo = WingProgressionRepository(wallet: wallet);
        await wallet.addTokens(1000000);
        for (var i = 0; i < 9; i++) {
          await repo.upgrade('sky_islands');
        }
        final maxed = await repo.load('sky_islands');
        expect(maxed.wingLevel, 10);
        expect(maxed.bossUnlocked, isTrue);

        await repo.markBossCleared('sky_islands');
        final cleared = await repo.load('sky_islands');
        expect(cleared.bossCleared, isTrue);
        expect(cleared.bossUnlocked, isFalse);
      },
    );
  });
}

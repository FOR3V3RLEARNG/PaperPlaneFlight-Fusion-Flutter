import 'package:flutter_test/flutter_test.dart';
import 'package:paper_plane_flight/src/game/rival_race_game.dart';
import 'package:paper_plane_flight/src/game/systems/race_director.dart';

void main() {
  test('rival AI power state is isolated from player power state', () {
    final game = RivalRaceGame(
      playerName: 'YAALON',
      playerCharacterId: 'yaalon',
      rivalName: 'UZZIAH',
      rivalCharacterId: 'uzziah',
      worldId: 'sky_islands',
      wingLevel: 1,
      bossRace: false,
      onFinished: (_) {},
    );

    expect(identical(game.playerPowers, game.rivalPowers), isFalse);
    game.rivalPowers.first.cooldown = 4;
    expect(game.playerPowers.first.cooldown, 0);
  });

  test('race director holds target position between decision ticks', () {
    final director = RaceDirector(42);
    final first = director.update(
      dt: 1,
      playerProgress: .2,
      rivalProgress: .2,
      powerReady: true,
      boss: false,
    );
    final second = director.update(
      dt: .1,
      playerProgress: .2,
      rivalProgress: .2,
      powerReady: true,
      boss: false,
    );

    expect(second.targetX, first.targetX);
    expect(second.targetY, first.targetY);
  });
}

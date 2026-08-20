import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerProgress {
  const PlayerProgress({
    required this.level,
    required this.xp,
    required this.stars,
    required this.gems,
    required this.bestScore,
    required this.totalDistanceKm,
    required this.completedMissions,
  });

  final int level;
  final int xp;
  final int stars;
  final int gems;
  final int bestScore;
  final double totalDistanceKm;
  final int completedMissions;

  PlayerProgress copyWith({
    int? level,
    int? xp,
    int? stars,
    int? gems,
    int? bestScore,
    double? totalDistanceKm,
    int? completedMissions,
  }) {
    return PlayerProgress(
      level: level ?? this.level,
      xp: xp ?? this.xp,
      stars: stars ?? this.stars,
      gems: gems ?? this.gems,
      bestScore: bestScore ?? this.bestScore,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      completedMissions: completedMissions ?? this.completedMissions,
    );
  }
}

class PlayerProgressController extends Notifier<PlayerProgress> {
  @override
  PlayerProgress build() {
    return const PlayerProgress(
      level: 24,
      xp: 6250,
      stars: 12840,
      gems: 435,
      bestScore: 36950,
      totalDistanceKm: 128.6,
      completedMissions: 9,
    );
  }

  void recordFlight({required int score, required double distanceKm, required int stars}) {
    state = state.copyWith(
      xp: state.xp + (score ~/ 12),
      stars: state.stars + stars,
      bestScore: score > state.bestScore ? score : state.bestScore,
      totalDistanceKm: state.totalDistanceKm + distanceKm,
    );
  }
}

final playerProgressProvider =
    NotifierProvider<PlayerProgressController, PlayerProgress>(PlayerProgressController.new);

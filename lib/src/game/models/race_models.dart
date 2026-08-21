enum PilotMood { focused, laughing, fistPump, shocked, ducking, frustrated, celebrating }
enum RacePowerType { fireBurst, distortionPulse, slowWindField }
enum RacePosition { first, second }

class RacerStats {
  const RacerStats({required this.speed, required this.handling, required this.lift, required this.stability, required this.boost, required this.durability});
  final double speed, handling, lift, stability, boost, durability;
}

class WingLevel {
  const WingLevel({required this.level, required this.speedBonus, required this.handlingBonus, required this.liftBonus, required this.stabilityBonus, required this.visualTier, required this.cost});
  final int level;
  final double speedBonus, handlingBonus, liftBonus, stabilityBonus;
  final int visualTier;
  final int cost;
}

class WorldWingProgress {
  const WorldWingProgress({required this.worldId, required this.wingLevel, required this.bossCleared});
  final String worldId;
  final int wingLevel;
  final bool bossCleared;
  bool get bossUnlocked => wingLevel >= 10 && !bossCleared;
}

class RacePowerState {
  RacePowerState(this.type, {this.charges = 1, this.cooldown = 0});
  final RacePowerType type;
  int charges;
  double cooldown;
  bool get ready => charges > 0 && cooldown <= 0;
}

class RaceResult {
  const RaceResult({required this.playerWon, required this.playerTime, required this.rivalTime, required this.score, required this.tokens, required this.worldId, required this.bossRace});
  final bool playerWon;
  final double playerTime, rivalTime;
  final int score, tokens;
  final String worldId;
  final bool bossRace;
}

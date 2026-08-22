import '../game/models/race_models.dart';

class RaceWorld {
  const RaceWorld({
    required this.id,
    required this.name,
    required this.bossName,
    required this.bossTitle,
    required this.weather,
    required this.bossPower,
  });
  final String id, name, bossName, bossTitle, weather;
  final RacePowerType bossPower;
}

const raceWorlds = <RaceWorld>[
  RaceWorld(
    id: 'sky_islands',
    name: 'Sky Islands',
    bossName: 'Aero Rex',
    bossTitle: 'Rainbow Gate Champion',
    weather: 'bright thermals + mist',
    bossPower: RacePowerType.slowWindField,
  ),
  RaceWorld(
    id: 'blue_mountain',
    name: 'Blue Mountain Run',
    bossName: 'Misty',
    bossTitle: 'Jamaica Ridge Rider',
    weather: 'tropical ridge mist + trade wind',
    bossPower: RacePowerType.distortionPulse,
  ),
  RaceWorld(
    id: 'gibraltar',
    name: 'Gibraltar Wind Gate',
    bossName: 'Levanter',
    bossTitle: 'Rock Wind Master',
    weather: 'cliff rotor + sea mist',
    bossPower: RacePowerType.slowWindField,
  ),
  RaceWorld(
    id: 'bermuda',
    name: 'Bermuda Triangle',
    bossName: 'Vortex',
    bossTitle: 'Storm Compass',
    weather: 'electrical mist + cyclone current',
    bossPower: RacePowerType.distortionPulse,
  ),
  RaceWorld(
    id: 'gulf_route',
    name: 'Gulf Cargo Route',
    bossName: 'Sirocco',
    bossTitle: 'Heat-Haze Ace',
    weather: 'heat haze + sea breeze',
    bossPower: RacePowerType.fireBurst,
  ),
  RaceWorld(
    id: 'frozen_jetstream',
    name: 'Frozen Jetstream',
    bossName: 'Frostwing',
    bossTitle: 'Aurora Sprinter',
    weather: 'snow + jetstream',
    bossPower: RacePowerType.slowWindField,
  ),
  RaceWorld(
    id: 'night_city',
    name: 'Night Sky City',
    bossName: 'Neon Kite',
    bossTitle: 'Tower Circuit Boss',
    weather: 'urban haze + electrical rain',
    bossPower: RacePowerType.distortionPulse,
  ),
  RaceWorld(
    id: 'cosmic',
    name: 'Cosmic Current',
    bossName: 'Nova Fold',
    bossTitle: 'Singularity Champion',
    weather: 'solar wind + asteroid stream',
    bossPower: RacePowerType.fireBurst,
  ),
];

List<WingLevel> wingLevels() => List.generate(10, (i) {
  final level = i + 1;
  return WingLevel(
    level: level,
    speedBonus: (level - 1) * 0.018,
    handlingBonus: (level - 1) * 0.022,
    liftBonus: (level - 1) * 0.020,
    stabilityBonus: (level - 1) * 0.024,
    visualTier: level <= 2
        ? 1
        : level <= 4
        ? 2
        : level <= 6
        ? 3
        : level <= 8
        ? 4
        : level == 9
        ? 5
        : 6,
    cost: level == 1 ? 0 : 120 + (level * level * 42),
  );
});

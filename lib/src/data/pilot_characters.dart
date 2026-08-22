import 'package:flutter/material.dart';

import '../game/models/race_models.dart';

enum PilotSpecies { human, pinkCat, monkey, duo }

class PilotCharacterDefinition {
  const PilotCharacterDefinition({
    required this.id,
    required this.name,
    required this.callSign,
    required this.species,
    required this.primary,
    required this.secondary,
    required this.skin,
    required this.hair,
    required this.personality,
    required this.signaturePower,
    this.availableByDefault = true,
    this.licenseNote,
  });

  final String id;
  final String name;
  final String callSign;
  final PilotSpecies species;
  final Color primary;
  final Color secondary;
  final Color skin;
  final Color hair;
  final String personality;
  final RacePowerType signaturePower;
  final bool availableByDefault;
  final String? licenseNote;
}

const pilotCharacters = <PilotCharacterDefinition>[
  PilotCharacterDefinition(
    id: 'yaalon',
    name: 'YAALON',
    callSign: 'Wind Heart',
    species: PilotSpecies.human,
    primary: Color(0xFF00DDF4),
    secondary: Color(0xFF1D72FF),
    skin: Color(0xFFB96F45),
    hair: Color(0xFF121820),
    personality:
        'Fearless, curious and first to fist-pump through a rainbow gate.',
    signaturePower: RacePowerType.distortionPulse,
  ),
  PilotCharacterDefinition(
    id: 'uzziah',
    name: 'UZZIAH',
    callSign: 'Sky Prince',
    species: PilotSpecies.human,
    primary: Color(0xFF7B61FF),
    secondary: Color(0xFFFFC14D),
    skin: Color(0xFF8F5438),
    hair: Color(0xFF1B1110),
    personality:
        'Calm under pressure, then explosive when the final sprint begins.',
    signaturePower: RacePowerType.slowWindField,
  ),
  PilotCharacterDefinition(
    id: 'nails',
    name: 'NAILS',
    callSign: 'Hard Fold',
    species: PilotSpecies.human,
    primary: Color(0xFF8795A3),
    secondary: Color(0xFFFF7043),
    skin: Color(0xFF9B654B),
    hair: Color(0xFF1A1A1A),
    personality:
        'Tough, daring and happiest skimming debris at impossible angles.',
    signaturePower: RacePowerType.fireBurst,
  ),
  PilotCharacterDefinition(
    id: 'wild_brats',
    name: 'WILD BRATS',
    callSign: 'Double Trouble',
    species: PilotSpecies.duo,
    primary: Color(0xFF42DE8B),
    secondary: Color(0xFFFFB347),
    skin: Color(0xFFBA784E),
    hair: Color(0xFF3A231B),
    personality:
        'A noisy two-kid cockpit crew that laughs louder as the weather gets worse.',
    signaturePower: RacePowerType.distortionPulse,
  ),
  PilotCharacterDefinition(
    id: 'granny',
    name: 'GRANNY',
    callSign: 'Old School Ace',
    species: PilotSpecies.human,
    primary: Color(0xFFE9D8B7),
    secondary: Color(0xFF55C7D9),
    skin: Color(0xFFC58A68),
    hair: Color(0xFFE7E7E7),
    personality:
        'Looks relaxed, reads the wind perfectly and laughs when younger racers panic.',
    signaturePower: RacePowerType.slowWindField,
  ),
  PilotCharacterDefinition(
    id: 'george_monkey',
    name: 'GEORGE',
    callSign: 'Sky Monkey',
    species: PilotSpecies.monkey,
    primary: Color(0xFF8B5B3F),
    secondary: Color(0xFF00CFEA),
    skin: Color(0xFFC8895C),
    hair: Color(0xFF5A3527),
    personality:
        'An original mischievous sky monkey who ducks, grins and grabs every risky boost.',
    signaturePower: RacePowerType.fireBurst,
  ),
  PilotCharacterDefinition(
    id: 'rose_panther',
    name: 'ROSE PANTHER',
    callSign: 'Velvet Velocity',
    species: PilotSpecies.pinkCat,
    primary: Color(0xFFFF79B5),
    secondary: Color(0xFF8E6CFF),
    skin: Color(0xFFFFA6CC),
    hair: Color(0xFFFF79B5),
    personality:
        'A sleek original pink-cat racer built for graceful overtakes and distortion tricks.',
    signaturePower: RacePowerType.distortionPulse,
  ),
  PilotCharacterDefinition(
    id: 'pink_panther_licensed',
    name: 'PINK PANTHER',
    callSign: 'Licensed Character Slot',
    species: PilotSpecies.pinkCat,
    primary: Color(0xFFFF8FC5),
    secondary: Color(0xFF201B33),
    skin: Color(0xFFFFA7D0),
    hair: Color(0xFFFF8FC5),
    personality: 'Reserved integration slot for the exact licensed character.',
    signaturePower: RacePowerType.distortionPulse,
    availableByDefault: false,
    licenseNote:
        'Requires permission/licensing from the rights holder before commercial distribution.',
  ),
];

PilotCharacterDefinition pilotById(String id) => pilotCharacters.firstWhere(
  (pilot) => pilot.id == id,
  orElse: () => pilotCharacters.first,
);

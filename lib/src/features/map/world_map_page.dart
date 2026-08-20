import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../widgets/glass_surface.dart';

class WorldMapPage extends StatelessWidget {
  const WorldMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 22),
            sliver: SliverToBoxAdapter(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('SKY ATLAS', style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 6),
                    Text(
                      'A spatial world map: every destination remains visible, and deeper levels open from the place you touched.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: FlightColors.muted),
                    ),
                    const SizedBox(height: 18),
                    _WorldMapCanvas(onLevelSelected: (String id) => context.push('/map/level/$id')),
                    const SizedBox(height: 18),
                    const _WorldCards(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorldMapCanvas extends StatelessWidget {
  const _WorldMapCanvas({required this.onLevelSelected});

  final ValueChanged<String> onLevelSelected;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      highlight: true,
      padding: EdgeInsets.zero,
      child: AspectRatio(
        aspectRatio: MediaQuery.sizeOf(context).width < 720 ? .86 : 1.75,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final nodes = <_NodeData>[
              const _NodeData('1-1', .15, .76, 'Launch', true),
              const _NodeData('1-2', .31, .62, 'Cloud Gate', true),
              const _NodeData('1-3', .49, .48, 'Ring Canyon', true),
              const _NodeData('1-4', .66, .32, 'Wind Garden', false),
              const _NodeData('1-5', .83, .20, 'Storm Crown', false),
            ];
            return Stack(
              children: <Widget>[
                const Positioned.fill(child: CustomPaint(painter: _WorldMapPainter())),
                for (final node in nodes)
                  Positioned(
                    left: node.x * constraints.maxWidth - 30,
                    top: node.y * constraints.maxHeight - 30,
                    child: Hero(
                      tag: 'world-node-${node.id}',
                      child: _WorldNode(
                        data: node,
                        onTap: node.unlocked ? () => onLevelSelected(node.id) : null,
                      ),
                    ),
                  ),
                Positioned(
                  left: 18,
                  top: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: FlightColors.deepNavy.withValues(alpha: .72),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('SKY ISLANDS • 72%'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NodeData {
  const _NodeData(this.id, this.x, this.y, this.label, this.unlocked);

  final String id;
  final double x;
  final double y;
  final String label;
  final bool unlocked;
}

class _WorldNode extends StatelessWidget {
  const _WorldNode({required this.data, required this.onTap});

  final _NodeData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      label: '${data.label}, level ${data.id}${onTap == null ? ', locked' : ''}',
      child: Material(
        color: onTap != null ? FlightColors.skyBlue : FlightColors.nightBlue,
        shape: CircleBorder(
          side: BorderSide(
            color: onTap != null ? FlightColors.aeroCyan : FlightColors.muted.withValues(alpha: .3),
            width: 2,
          ),
        ),
        elevation: 8,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: 60,
            child: Center(
              child: onTap != null
                  ? Text(data.id, style: const TextStyle(fontWeight: FontWeight.w800))
                  : const Icon(Icons.lock_rounded, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorldMapPainter extends CustomPainter {
  const _WorldMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF082757), Color(0xFF0C4F91), Color(0xFF67C7E8)],
        ).createShader(rect),
    );

    for (var i = 0; i < 9; i++) {
      final x = size.width * (.08 + (i * .121) % .88);
      final y = size.height * (.12 + (i % 4) * .20);
      final r = size.shortestSide * (.028 + (i % 3) * .012);
      final p = Paint()..color = Colors.white.withValues(alpha: .07 + (i % 2) * .04);
      canvas.drawCircle(Offset(x, y), r, p);
      canvas.drawCircle(Offset(x + r * .8, y + 2), r * .7, p);
    }

    final points = <Offset>[
      Offset(size.width * .15, size.height * .76),
      Offset(size.width * .31, size.height * .62),
      Offset(size.width * .49, size.height * .48),
      Offset(size.width * .66, size.height * .32),
      Offset(size.width * .83, size.height * .20),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final controlX = (previous.dx + current.dx) / 2;
      path.cubicTo(controlX, previous.dy, controlX, current.dy, current.dx, current.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = FlightColors.aeroCyan.withValues(alpha: .62),
    );

    for (var i = 0; i < 5; i++) {
      final center = Offset(size.width * (.16 + i * .17), size.height * (.25 + (i % 2) * .27));
      final w = size.width * .13;
      final h = size.height * .08;
      final island = Path()
        ..moveTo(center.dx - w * .5, center.dy)
        ..quadraticBezierTo(center.dx, center.dy - h, center.dx + w * .5, center.dy)
        ..lineTo(center.dx, center.dy + h * 1.45)
        ..close();
      final hue = 150 + i * 8;
      canvas.drawPath(island, Paint()..color = HSVColor.fromAHSV(.55, hue.toDouble(), .45, .72).toColor());
    }

    final storm = Offset(size.width * .82, size.height * .20);
    for (var i = 0; i < 4; i++) {
      final radius = size.shortestSide * (.05 + i * .025);
      canvas.drawCircle(
        storm,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = FlightColors.violet.withValues(alpha: .24 - i * .035),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WorldCards extends StatelessWidget {
  const _WorldCards();

  @override
  Widget build(BuildContext context) {
    const items = <(String, String, Color, IconData)>[
      ('Sky Islands', 'Easy • wind reading', FlightColors.leafGreen, Icons.cloud_outlined),
      ('Crystal Peaks', 'Hard • precision gaps', FlightColors.skyBlue, Icons.landscape_outlined),
      ('Stormfront', 'Expert • turbulence', FlightColors.violet, Icons.thunderstorm_outlined),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: <Widget>[
        for (final item in items)
          SizedBox(
            width: MediaQuery.sizeOf(context).width < 600 ? double.infinity : 260,
            child: GlassSurface(
              child: Row(
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: item.$3.withValues(alpha: .16), shape: BoxShape.circle),
                    child: Icon(item.$4, color: item.$3),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(item.$1, style: Theme.of(context).textTheme.titleMedium),
                        Text(item.$2, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

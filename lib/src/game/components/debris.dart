import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';

class DebrisComponent extends PositionComponent {
  DebrisComponent({required super.position,required this.kind,required this.drift}) : super(size:Vector2.all(kind=='asteroid'?40:26),anchor:Anchor.center,priority:18);
  final String kind; final double drift; double phase=0; bool nearMissAwarded=false;
  @override void update(double dt){super.update(dt);phase+=dt;x+=math.sin(phase*2.6)*drift*dt;y+=150*dt;angle+=dt*(kind == 'kite' ? .7 : 1.8);}
  @override void render(Canvas canvas){super.render(canvas);switch(kind){case 'leaf':canvas.drawOval(Rect.fromCenter(center:Offset(size.x/2,size.y/2),width:size.x*.8,height:size.y*.38),Paint()..color=const Color(0xFF69B76B));break;case 'kite':final p=Path()..moveTo(size.x/2,1)..lineTo(size.x-2,size.y/2)..lineTo(size.x/2,size.y-2)..lineTo(2,size.y/2)..close();canvas.drawPath(p,Paint()..color=const Color(0xFFFFB347));break;case 'asteroid':canvas.drawCircle(Offset(size.x/2,size.y/2),size.x*.44,Paint()..color=const Color(0xFF5C6072));canvas.drawCircle(Offset(size.x*.35,size.y*.38),4,Paint()..color=const Color(0xFF393C48));break;default:canvas.drawRect(Rect.fromCenter(center:Offset(size.x/2,size.y/2),width:size.x*.7,height:size.y*.28),Paint()..color=const Color(0xFFE8F2FF));}}
}

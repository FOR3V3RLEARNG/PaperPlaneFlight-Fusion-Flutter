import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'components/debris.dart';
import 'components/power_fx.dart';
import 'components/racer_plane.dart';
import 'components/token_pickup.dart';
import 'models/race_models.dart';
import 'systems/race_director.dart';

class RaceHudState {
  const RaceHudState({required this.progress,required this.position,required this.gap,required this.integrity,required this.rivalIntegrity,required this.tokens,required this.score,required this.wingLevel,required this.powerCharges,required this.banner});
  final double progress,gap,integrity,rivalIntegrity;final RacePosition position;final int tokens,score,wingLevel,powerCharges;final String banner;
}

class RivalRaceGame extends FlameGame {
  RivalRaceGame({required this.playerName,required this.playerCharacterId,required this.rivalName,required this.rivalCharacterId,required this.worldId,required this.wingLevel,this.rivalWingLevel=1,required this.bossRace,required this.onFinished});
  final String playerName,playerCharacterId,rivalName,rivalCharacterId,worldId;final int wingLevel,rivalWingLevel;final bool bossRace;final void Function(RaceResult) onFinished;
  late RacerPlaneComponent player;late RacerPlaneComponent rival;late RaceDirector director;
  final ValueNotifier<RaceHudState> hud=ValueNotifier(const RaceHudState(progress:0,position:RacePosition.first,gap:0,integrity:100,rivalIntegrity:100,tokens:0,score:0,wingLevel:1,powerCharges:3,banner:'READY'));
  final Vector2 input=Vector2.zero();
  final List<RacePowerState> powers=[RacePowerState(RacePowerType.fireBurst,charges:2),RacePowerState(RacePowerType.distortionPulse,charges:1),RacePowerState(RacePowerType.slowWindField,charges:1)];
  late final math.Random rng=math.Random(worldId.hashCode+wingLevel+(bossRace?99:0));
  double elapsed=0,playerProgress=0,rivalProgress=0,spawnTimer=.5,tokenSpawnTimer=1.4,bannerTimer=2;int tokens=0,score=0;bool done=false;

  @override Future<void> onLoad() async {await super.onLoad();director=RaceDirector(worldId.hashCode+wingLevel);player=RacerPlaneComponent(racerName:playerName,characterId:playerCharacterId,playerControlled:true,wingLevel:wingLevel,position:Vector2(size.x*.38,size.y*.72));rival=RacerPlaneComponent(racerName:rivalName,characterId:rivalCharacterId,playerControlled:false,wingLevel:bossRace?10:rivalWingLevel,position:Vector2(size.x*.66,size.y*.64));add(player);add(rival);}
  @override Color backgroundColor()=>const Color(0xFF07549A);
  void setInput(double x,double y)=>input.setValues(x.clamp(-1,1).toDouble(),y.clamp(-1,1).toDouble());void clearInput()=>input.setZero();

  @override void update(double dt){super.update(dt);if(done)return;elapsed+=dt;bannerTimer-=dt;for(final p in powers){p.cooldown=math.max(0,p.cooldown-dt).toDouble();}
    final wingScale=1+(wingLevel-1)*.018;final control=1+(wingLevel-1)*.022;player.velocity.x+=input.x*690*control*dt;player.velocity.y+=input.y*520*control*dt;player.velocity*=math.max(0,1-dt*4.5).toDouble();player.position+=player.velocity*dt;player.x=player.x.clamp(35,size.x-35).toDouble();player.y=player.y.clamp(size.y*.18,size.y*.86).toDouble();player.angle+=(player.velocity.x/180*.48-player.angle)*math.min(1,dt*7).toDouble();
    final d=director.update(dt:dt,playerProgress:playerProgress,rivalProgress:rivalProgress,powerReady:powers.any((p)=>p.ready),boss:bossRace);final target=Vector2(size.x*d.targetX,size.y*d.targetY);final delta=target-rival.position;rival.position+=delta*math.min(1,dt*(bossRace?2.7:2.15)).toDouble();rival.angle+=(delta.x/160*.38-rival.angle)*math.min(1,dt*5).toDouble();if(d.boost){rival.boost=.8;rival.react(PilotMood.laughing);}if(d.usePower)useRivalPower();
    final playerSpeed=(.0108*wingScale)*(player.slow>0?.66:1)*(player.boost>0?1.34:1);final rivalSpeed=(bossRace?.0122:.0104)*(rival.slow>0?.68:1)*(rival.boost>0?1.30:1);playerProgress=(playerProgress+playerSpeed*dt).clamp(0,1).toDouble();rivalProgress=(rivalProgress+rivalSpeed*dt).clamp(0,1).toDouble();
    spawnTimer-=dt;if(spawnTimer<=0){spawnDebris();spawnTimer=.65+rng.nextDouble()*.55;}
    tokenSpawnTimer-=dt;if(tokenSpawnTimer<=0){spawnToken();tokenSpawnTimer=1.7+rng.nextDouble()*1.4;}
    for(final c in children.toList()){if(c is DebrisComponent){if(c.y>size.y+50){c.removeFromParent();continue;}checkDebris(c);}if(c is PowerProjectile)checkProjectile(c);if(c is TokenPickupComponent){if(c.y>size.y+50){c.removeFromParent();continue;}checkTokenPickup(c);}}
    if(playerProgress>=1||rivalProgress>=1)finishRace();updateHud();
  }
  void spawnDebris(){final kinds=worldId=='cosmic'?['asteroid','asteroid','scrap']:worldId=='sky_islands'?['leaf','kite','scrap']:['kite','scrap','leaf','asteroid'];final k=kinds[rng.nextInt(kinds.length)];add(DebrisComponent(position:Vector2(35+rng.nextDouble()*(size.x-70),-30),kind:k,drift:18+rng.nextDouble()*45));}
  void spawnToken(){add(TokenPickupComponent(position:Vector2(35+rng.nextDouble()*(size.x-70),-30)));}
  void checkTokenPickup(TokenPickupComponent t){if((player.position-t.position).length<34){t.removeFromParent();collectToken();player.react(PilotMood.laughing);showBanner('TOKEN +1');}}
  void checkDebris(DebrisComponent d){for(final racer in [player,rival]){if((racer.position-d.position).length<32){d.removeFromParent();racer.integrity=(racer.integrity-(bossRace?17:13)).clamp(0,100).toDouble();racer.react(PilotMood.shocked);if(racer==player){score=math.max(0,score-60);showBanner('DEBRIS HIT');}else{showBanner('RIVAL CLIPPED');}break;}else if((racer.position-d.position).length<55&&d.y>racer.y){if(racer==player){score+=45;showBanner('CLOSE CALL +45');player.react(PilotMood.laughing);}}}}
  void collectToken(){tokens++;score+=20;}
  void boostPlayer(){player.boost=1.05;player.react(PilotMood.fistPump);showBanner('TURBO!');}
  void usePower(RacePowerType type){final p=powers.firstWhere((e)=>e.type==type);if(!p.ready)return;p.charges--;p.cooldown=3.2;add(PowerProjectile(position:player.position.clone()..y-=40,type:type,fromPlayer:true));player.react(PilotMood.fistPump);showBanner(switch(type){RacePowerType.fireBurst=>'FIRE BURST',RacePowerType.distortionPulse=>'DISTORTION PULSE',RacePowerType.slowWindField=>'SLOW FIELD'});}
  void useRivalPower(){final p=powers.firstWhere((e)=>e.ready,orElse:()=>powers.first);if(!p.ready)return;p.cooldown=4.0;add(PowerProjectile(position:rival.position.clone()..y+=38,type:p.type,fromPlayer:false));}
  void checkProjectile(PowerProjectile p){final target=p.fromPlayer?rival:player;if((p.position-target.position).length<40){p.removeFromParent();switch(p.type){case RacePowerType.fireBurst:target.integrity=(target.integrity-18).clamp(0,100).toDouble();target.react(PilotMood.frustrated);break;case RacePowerType.distortionPulse:target.distortion=2.2;target.react(PilotMood.shocked);break;case RacePowerType.slowWindField:target.slow=2.8;target.react(PilotMood.frustrated);break;}showBanner(p.fromPlayer?'POWER HIT!':'RIVAL POWER HIT');}}
  void showBanner(String s){bannerTimer=1.5;hud.value=RaceHudState(progress:playerProgress,position:playerProgress>=rivalProgress?RacePosition.first:RacePosition.second,gap:(playerProgress-rivalProgress).abs(),integrity:player.integrity,rivalIntegrity:rival.integrity,tokens:tokens,score:score,wingLevel:wingLevel,powerCharges:powers.fold(0,(a,b)=>a+b.charges),banner:s);}
  void updateHud(){final pos=playerProgress>=rivalProgress?RacePosition.first:RacePosition.second;if(pos==RacePosition.first&&hud.value.position==RacePosition.second){player.react(PilotMood.fistPump);showBanner('OVERTAKE!');}hud.value=RaceHudState(progress:playerProgress,position:pos,gap:(playerProgress-rivalProgress).abs(),integrity:player.integrity,rivalIntegrity:rival.integrity,tokens:tokens,score:score,wingLevel:wingLevel,powerCharges:powers.fold(0,(a,b)=>a+b.charges),banner:bannerTimer>0?hud.value.banner:'');}
  void finishRace(){if(done)return;done=true;final win=playerProgress>=rivalProgress;player.react(win?PilotMood.celebrating:PilotMood.frustrated);rival.react(win?PilotMood.frustrated:PilotMood.celebrating);pauseEngine();Future<void>.delayed(const Duration(milliseconds:650),()=>onFinished(RaceResult(playerWon:win,playerTime:elapsed,rivalTime:elapsed+(win ? .35 : -.35),score:score+(win?800:200),tokens:tokens,worldId:worldId,bossRace:bossRace)));}
  @override void render(Canvas c){final rect=Offset.zero&Size(size.x,size.y);c.drawRect(rect,Paint()..shader=const LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Color(0xFF07549A),Color(0xFF45B9E4),Color(0xFFC5F5FF)]).createShader(rect));for(var i=0;i<8;i++){final y=((elapsed*80+i*150)% (size.y+180))-100;c.drawCircle(Offset((i*93)%math.max(1,size.x.toInt()).toDouble(),y),55+(i%3)*20,Paint()..color=const Color(0xFFFFFFFF).withValues(alpha:.08));}super.render(c);}
  @override void onDispose(){hud.dispose();super.onDispose();}
}

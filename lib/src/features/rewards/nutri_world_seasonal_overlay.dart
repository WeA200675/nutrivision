import 'dart:math';
import 'package:flutter/material.dart';
import 'nutri_world.dart';

class NutriWorldSeasonalOverlay extends StatefulWidget {
  const NutriWorldSeasonalOverlay({super.key, required this.state});
  final NutriWorldState state;
  @override State<NutriWorldSeasonalOverlay> createState()=>_NutriWorldSeasonalOverlayState();
}
class _NutriWorldSeasonalOverlayState extends State<NutriWorldSeasonalOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  @override void initState(){super.initState();controller=AnimationController(vsync:this,duration:const Duration(seconds:8))..repeat();}
  @override void dispose(){controller.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>IgnorePointer(child:CustomPaint(painter:_SeasonPainter(DateTime.now(),controller,widget.state),size:Size.infinite));
}
class _SeasonPainter extends CustomPainter {
  _SeasonPainter(this.date,this.animation,this.state); final DateTime date; final Animation<double> animation; final NutriWorldState state;
  @override void paint(Canvas c,Size s){final winter=date.month==12||date.month<=2;final autumn=date.month>=10&&date.month<=11;final spring=date.month==3||date.month==4;final christmas=date.month==12;final easter=spring;final p=Paint()..strokeCap=StrokeCap.round;final r=Random(24);
    if(winter){p.color=Colors.white.withValues(alpha:.75);for(var i=0;i<70;i++){final x=r.nextDouble()*s.width;final y=((r.nextDouble()*s.height)+animation.value*80)%s.height;c.drawCircle(Offset(x,y),1.5+r.nextDouble()*3,p);}}
    final healthy=state.garden+state.tree+state.path+state.pond+state.kitchen+state.pantry>=6;
    if(!healthy){p.color=const Color(0xFF71849A).withValues(alpha:.48);for(var i=0;i<3;i++)c.drawOval(Rect.fromLTWH(150+i*270,145+(i%2)*35,190,46),p);}
    p.color=const Color(0xFF2389A7);for(var i=0;i<state.pond.clamp(0,6);i++){final x=680+((animation.value*180+i*47)%240);final y=450+(i%3)*22;c.drawOval(Rect.fromLTWH(x,y,22,10),p);}
    if(autumn){p.color=const Color(0xFFD88945).withValues(alpha:.85);for(var i=0;i<28;i++){final x=(r.nextDouble()*s.width+animation.value*40)%s.width;final y=(r.nextDouble()*s.height+animation.value*50)%s.height;c.drawOval(Rect.fromLTWH(x,y,7,12),p);}}
    if(!winter){p.color=const Color(0xFF5BA45B).withValues(alpha:.55);for(var i=0;i<45;i++){final x=r.nextDouble()*s.width;final y=s.height*.7+r.nextDouble()*s.height*.25;c.drawLine(Offset(x,y),Offset(x+sin(animation.value*2*pi+i)*8,y-10),p);}}
    if(christmas){p.color=const Color(0xFFFFD76A);for(var i=0;i<10;i++)c.drawCircle(Offset(80+i*28,110),4,p);}
    if(easter){p.color=Colors.pinkAccent.withValues(alpha:.9);for(var i=0;i<7;i++)c.drawOval(Rect.fromLTWH(120+i*35,s.height*.72+(i%2)*8,13,19),p);}
  }
  @override bool shouldRepaint(covariant _SeasonPainter old)=>true;
}

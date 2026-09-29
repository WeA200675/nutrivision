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
  _SeasonPainter(this.date,this.animation,this.state):super(repaint:animation); final DateTime date; final Animation<double> animation; final NutriWorldState state;
  @override void paint(Canvas c,Size s){final winter=date.month==12||date.month<=2;final autumn=date.month>=10&&date.month<=11;final spring=date.month==3||date.month==4;final christmas=date.month==12;final easter=spring;final p=Paint()..strokeCap=StrokeCap.round;final r=Random(24);
    if(winter){p.color=Colors.white.withValues(alpha:.75);for(var i=0;i<70;i++){final x=r.nextDouble()*s.width;final y=((r.nextDouble()*s.height)+animation.value*80)%s.height;c.drawCircle(Offset(x,y),1.5+r.nextDouble()*3,p);}}
    final healthy=state.garden+state.tree+state.path+state.pond+state.kitchen+state.pantry>=6;
    if(!healthy){p.color=const Color(0xFF71849A).withValues(alpha:.48);for(var i=0;i<3;i++)c.drawOval(Rect.fromLTWH(150+i*270,145+(i%2)*35,190,46),p);}
    // Fish are drawn as recognizable silhouettes inside the lower lake area.
    final fishCount=max(3,state.pond.clamp(0,6));
    // The lake occupies the lower centre of the illustration; keep all fish
    // well below the garden path and inside the visible water.
    final pondLeft=s.width*.08, pondTop=s.height*.76;
    final pondWidth=s.width*.78, pondHeight=s.height*.18;
    for(var i=0;i<fishCount;i++){
      final direction=i.isEven?1.0:-1.0;
      final phase=(animation.value*pondWidth*direction+i*137)%pondWidth;
      final x=pondLeft+(direction>0?phase:pondWidth-phase);
      final y=pondTop+(i%4)*(pondHeight/5);
      final fish=Paint()..color=(i.isEven?const Color(0xFFE97850):const Color(0xFFE7B24C)).withValues(alpha:.98);
      final body=Rect.fromLTWH(x,y,38,17);
      c.drawOval(body,fish);
      final tailX=direction>0?x-10:x+48;
      final tail=Path()..moveTo(tailX,y+8.5)..lineTo(tailX+(direction>0?-12:12),y-1)..lineTo(tailX+(direction>0?-12:12),y+18)..close();
      c.drawPath(tail,fish);
      final eyeX=direction>0?x+30:x+8;
      c.drawCircle(Offset(eyeX,y+5),2.4,Paint()..color=Colors.white);
      c.drawCircle(Offset(eyeX,y+5),1.1,Paint()..color=const Color(0xFF17324D));
      c.drawOval(Rect.fromLTWH(x+15,y-4,12,8),Paint()..color=fish.color.withValues(alpha:.75));
    }
    if(autumn){p.color=const Color(0xFFD88945).withValues(alpha:.85);for(var i=0;i<28;i++){final x=(r.nextDouble()*s.width+animation.value*40)%s.width;final y=(r.nextDouble()*s.height+animation.value*50)%s.height;c.drawOval(Rect.fromLTWH(x,y,7,12),p);}}
    if(!winter){p.color=const Color(0xFF5BA45B).withValues(alpha:.55);for(var i=0;i<45;i++){final x=r.nextDouble()*s.width;final y=s.height*.7+r.nextDouble()*s.height*.25;c.drawLine(Offset(x,y),Offset(x+sin(animation.value*2*pi+i)*8,y-10),p);}}
    if(christmas){p.color=const Color(0xFFFFD76A);for(var i=0;i<10;i++)c.drawCircle(Offset(80+i*28,110),4,p);}
    if(easter){p.color=Colors.pinkAccent.withValues(alpha:.9);for(var i=0;i<7;i++)c.drawOval(Rect.fromLTWH(120+i*35,s.height*.72+(i%2)*8,13,19),p);}
  }
  @override bool shouldRepaint(covariant _SeasonPainter old)=>true;
}


import 'package:flutter/material.dart';
import 'user_profile.dart';

class ProfileScreen extends StatefulWidget { const ProfileScreen({super.key, this.initial, this.onSaved}); final UserProfile? initial; final ValueChanged<UserProfile>? onSaved; @override State<ProfileScreen> createState()=>_ProfileScreenState(); }
class _ProfileScreenState extends State<ProfileScreen> {
  final height=TextEditingController(), weight=TextEditingController(), age=TextEditingController(), loss=TextEditingController(text:'0.5'); BiologicalSex sex=BiologicalSex.unspecified; double activity=1.4;
  @override void initState(){super.initState(); final p=widget.initial; if(p!=null){height.text='${p.heightCm}';weight.text='${p.weightKg}';age.text='${p.age}';loss.text='${p.targetLossKgPerWeek}';sex=p.sex;activity=p.activityFactor;}}
  @override void dispose(){for(final c in [height,weight,age,loss])c.dispose();super.dispose();}
  double? n(TextEditingController c)=>double.tryParse(c.text.replaceAll(',','.'));
  @override Widget build(BuildContext context){final h=n(height),w=n(weight),a=n(age),l=n(loss); final valid=h!=null&&w!=null&&a!=null&&l!=null&&h>0&&w>0&&a>0&&l>=0; final p=valid?UserProfile(heightCm:h!,weightKg:w!,age:a!.round(),sex:sex,activityFactor:activity,targetLossKgPerWeek:l!):null; return Scaffold(appBar:AppBar(title:const Text('Mein Profil')),body:ListView(padding:const EdgeInsets.all(16),children:[_field('Größe (cm)',height),_field('Gewicht (kg)',weight),_field('Alter',age),DropdownButtonFormField(value:sex,decoration:const InputDecoration(labelText:'Berechnungsangabe'),items:const [DropdownMenuItem(value:BiologicalSex.female,child:Text('Weiblich')),DropdownMenuItem(value:BiologicalSex.male,child:Text('Männlich')),DropdownMenuItem(value:BiologicalSex.unspecified,child:Text('Keine Angabe'))],onChanged:(v)=>setState(()=>sex=v??BiologicalSex.unspecified)),DropdownButtonFormField(value:activity,decoration:const InputDecoration(labelText:'Aktivitätsniveau'),items:const [DropdownMenuItem(value:1.2,child:Text('Wenig aktiv')),DropdownMenuItem(value:1.4,child:Text('Leicht aktiv')),DropdownMenuItem(value:1.6,child:Text('Mittel aktiv')),DropdownMenuItem(value:1.8,child:Text('Sehr aktiv'))],onChanged:(v)=>setState(()=>activity=v??1.4)),_field('Abnahmeziel (kg pro Woche)',loss),if(p!=null)Card(child:Padding(padding:const EdgeInsets.all(16),child:Text('BMI ${p.bmi.toStringAsFixed(1)}\nErhaltungsbedarf ca. ${p.maintenanceCalories.round()} kcal\nStartziel ca. ${p.safeDailyCalories.round()} kcal pro Tag'))),const SizedBox(height:16),FilledButton(onPressed:p==null?null:(){ widget.onSaved?.call(p); Navigator.pop(context,p); },child:const Text('Profil speichern'))]));}
  Widget _field(String label, TextEditingController c) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      onChanged: (_) => setState(() {}),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
    ),
  );
}

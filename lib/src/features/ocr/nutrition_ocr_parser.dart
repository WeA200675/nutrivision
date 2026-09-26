class NutritionOcrValues { const NutritionOcrValues({this.kcal,this.kj,this.protein,this.carbs,this.fat,this.sugar,this.salt}); final double? kcal,kj,protein,carbs,fat,sugar,salt; }
class NutritionOcrParser {
  NutritionOcrValues parse(String text) { final t=text.toLowerCase().replaceAll(',', '.'); double? find(List<String> labels)=>_match(t,labels); return NutritionOcrValues(kcal:find(['kcal','calories','kalorien']),kj:find(['kj','kilojoule']),protein:find(['protein','eiweiß','eweiss']),carbs:find(['carbohydrate','kohlenhydrate','carbs']),fat:find(['fat','fett']),sugar:find(['sugar','zucker']),salt:find(['salt','salz'])); }
  double? _match(String text,List<String> labels){for(final label in labels){final m=RegExp('${RegExp.escape(label)}[^0-9]{0,15}([0-9]+(?:\\.[0-9]+)?)').firstMatch(text);if(m!=null)return double.tryParse(m.group(1)!);}return null;}
}

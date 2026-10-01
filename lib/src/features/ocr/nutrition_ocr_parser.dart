class NutritionOcrValues { const NutritionOcrValues({this.kcal,this.kj,this.protein,this.carbs,this.fat,this.sugar,this.salt}); final double? kcal,kj,protein,carbs,fat,sugar,salt; }
class NutritionOcrParser {
  NutritionOcrValues parse(String text) { final t=text.toLowerCase().replaceAll(',', '.'); double? find(List<String> labels)=>_match(t,labels); return NutritionOcrValues(kcal:find(['kcal','calories','kalorien']),kj:find(['kj','kilojoule']),protein:find(['protein','eiweiß','eweiss']),carbs:find(['carbohydrate','kohlenhydrate','carbs']),fat:find(['fat','fett']),sugar:find(['sugar','zucker']),salt:find(['salt','salz'])); }
  double? _match(String text,List<String> labels){for(final label in labels){final escaped=RegExp.escape(label);final before=RegExp('([0-9]+(?:\\.[0-9]+)?)\\s*$escaped').firstMatch(text);if(before!=null)return double.tryParse(before.group(1)!);final after=RegExp('$escaped[^0-9]{0,15}([0-9]+(?:\\.[0-9]+)?)').firstMatch(text);if(after!=null)return double.tryParse(after.group(1)!);}return null;}
}


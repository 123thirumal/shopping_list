import 'dart:ui';
enum CategoriesType {vegetables,fruit,meat,dairy,carbs,sweets,spices,convenience,hygiene,other}


class CategoryModel{
  const CategoryModel(this.catName,this.catColor);


  final String catName;
  final Color catColor;
}
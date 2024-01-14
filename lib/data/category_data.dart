import 'package:flutter/material.dart';

import 'package:shopping_list_app/models/category_model.dart';

const categories = {
  CategoriesType.vegetables: CategoryModel(
    'Vegetables',
    Color.fromARGB(255, 0, 255, 128),
  ),
  CategoriesType.fruit: CategoryModel(
    'Fruit',
    Color.fromARGB(255, 145, 255, 0),
  ),
  CategoriesType.meat: CategoryModel(
    'Meat',
    Color.fromARGB(255, 255, 102, 0),
  ),
  CategoriesType.dairy: CategoryModel(
    'Dairy',
    Color.fromARGB(255, 0, 208, 255),
  ),
  CategoriesType.carbs: CategoryModel(
    'Carbs',
    Color.fromARGB(255, 0, 60, 255),
  ),
  CategoriesType.sweets: CategoryModel(
    'Sweets',
    Color.fromARGB(255, 255, 149, 0),
  ),
  CategoriesType.spices: CategoryModel(
    'Spices',
    Color.fromARGB(255, 255, 187, 0),
  ),
  CategoriesType.convenience: CategoryModel(
    'Convenience',
    Color.fromARGB(255, 191, 0, 255),
  ),
  CategoriesType.hygiene: CategoryModel(
    'Hygiene',
    Color.fromARGB(255, 149, 0, 255),
  ),
  CategoriesType.other: CategoryModel(
    'Other',
    Color.fromARGB(255, 0, 225, 255),
  ),
};
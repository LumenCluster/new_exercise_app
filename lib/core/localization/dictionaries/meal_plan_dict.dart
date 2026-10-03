/// Static UI strings for MealPlanScreen, MealDetailScreen and
/// ShoppingListScreen. Meal names/ingredients from the AI-generated plan
/// are NOT translated here — only fixed chrome (titles, buttons, labels).
const Map<String, Map<String, String>> mealPlanDict = {
  'meal_plan_ingredients_title': {'en': 'Ingredients', 'es': 'Ingredientes', 'fr': 'Ingrédients', 'de': 'Zutaten', 'hi': 'सामग्री'},
  'meal_plan_instructions_title': {'en': 'Instructions', 'es': 'Instrucciones', 'fr': 'Instructions', 'de': 'Anleitung', 'hi': 'निर्देश'},

  'meal_detail_macros': {'en': 'MACRO NUTRIENTS', 'es': 'MACRONUTRIENTES', 'fr': 'MACRONUTRIMENTS', 'de': 'MAKRONÄHRSTOFFE', 'hi': 'मैक्रो पोषक तत्व'},
  'meal_detail_protein': {'en': 'Protein {g}g', 'es': 'Proteína {g}g', 'fr': 'Protéines {g}g', 'de': 'Protein {g}g', 'hi': 'प्रोटीन {g}g'},
  'meal_detail_carbs': {'en': 'Carbs {g}g', 'es': 'Carbos {g}g', 'fr': 'Glucides {g}g', 'de': 'Kohlenhydrate {g}g', 'hi': 'कार्ब्स {g}g'},
  'meal_detail_fat': {'en': 'Fat {g}g', 'es': 'Grasa {g}g', 'fr': 'Lipides {g}g', 'de': 'Fett {g}g', 'hi': 'वसा {g}g'},
  'meal_detail_items': {'en': '{n} items', 'es': '{n} artículos', 'fr': '{n} éléments', 'de': '{n} Zutaten', 'hi': '{n} सामग्री'},
  'meal_detail_quick_instructions': {'en': 'Quick Instructions', 'es': 'Instrucciones Rápidas', 'fr': 'Instructions Rapides', 'de': 'Kurzanleitung', 'hi': 'त्वरित निर्देश'},
  'meal_detail_log_meal': {'en': 'Log This Meal', 'es': 'Registrar Esta Comida', 'fr': 'Enregistrer ce Repas', 'de': 'Mahlzeit Erfassen', 'hi': 'यह भोजन दर्ज करें'},
  'meal_detail_logged': {'en': 'Meal Logged', 'es': 'Comida Registrada', 'fr': 'Repas Enregistré', 'de': 'Mahlzeit Erfasst', 'hi': 'भोजन दर्ज हुआ'},

  'meal_plan_today_title': {'en': "Today's Meal Plan", 'es': 'Plan de Comidas de Hoy', 'fr': 'Plan de Repas du Jour', 'de': 'Heutiger Essensplan', 'hi': 'आज की भोजन योजना'},
  'meal_plan_daily_target': {'en': 'Daily target: {kcal} kcal  •  P {p}g  •  C {c}g  •  F {f}g', 'es': 'Objetivo diario: {kcal} kcal  •  P {p}g  •  C {c}g  •  G {f}g', 'fr': 'Objectif quotidien : {kcal} kcal  •  P {p}g  •  G {c}g  •  L {f}g', 'de': 'Tagesziel: {kcal} kcal  •  P {p}g  •  K {c}g  •  F {f}g', 'hi': 'दैनिक लक्ष्य: {kcal} kcal  •  P {p}g  •  C {c}g  •  F {f}g'},
  'meal_plan_image_failed': {'en': 'Image failed to generate', 'es': 'No se pudo generar la imagen', 'fr': "Échec de la génération de l'image", 'de': 'Bild konnte nicht erstellt werden', 'hi': 'छवि तैयार नहीं हो सकी'},
  'meal_plan_tap_to_retry': {'en': 'Tap to retry', 'es': 'Toca para reintentar', 'fr': 'Appuyez pour réessayer', 'de': 'Zum Wiederholen tippen', 'hi': 'पुनः प्रयास करने के लिए टैप करें'},

  'meal_plan_shopping_list_title': {'en': 'Shopping List', 'es': 'Lista de Compras', 'fr': 'Liste de Courses', 'de': 'Einkaufsliste', 'hi': 'खरीदारी सूची'},
  'meal_plan_shopping_generate_error': {'en': "Couldn't generate this week's recipes.", 'es': 'No se pudieron generar las recetas de esta semana.', 'fr': "Impossible de générer les recettes de cette semaine.", 'de': 'Die Rezepte für diese Woche konnten nicht erstellt werden.', 'hi': 'इस सप्ताह की रेसिपी तैयार नहीं हो सकीं।'},
  'meal_plan_no_ingredients_yet': {'en': 'No ingredients yet.', 'es': 'Aún no hay ingredientes.', 'fr': "Pas encore d'ingrédients.", 'de': 'Noch keine Zutaten.', 'hi': 'अभी तक कोई सामग्री नहीं है।'},
  'meal_plan_used_in_one_meal': {'en': 'Used in {count} meal', 'es': 'Usado en {count} comida', 'fr': 'Utilisé dans {count} repas', 'de': 'Verwendet in {count} Mahlzeit', 'hi': '{count} भोजन में उपयोग किया गया'},
  'meal_plan_used_in_many_meals': {'en': 'Used in {count} meals', 'es': 'Usado en {count} comidas', 'fr': 'Utilisé dans {count} repas', 'de': 'Verwendet in {count} Mahlzeiten', 'hi': '{count} भोजनों में उपयोग किया गया'},
};

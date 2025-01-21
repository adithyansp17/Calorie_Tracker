import 'package:calorie_tracker/db_helper.dart';
import 'package:calorie_tracker/food_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:intl/intl.dart';

class AddFoodForm extends StatefulWidget {
  const AddFoodForm({super.key});

  @override
  AddFoodFormState createState() => AddFoodFormState();
}

class AddFoodFormState extends State<AddFoodForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController gramController = TextEditingController();
  DateTime? _selectedDate;
  final gemini = Gemini.instance;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Add Food Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Food Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a food name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: gramController,
            decoration: const InputDecoration(
              labelText: 'Gram',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the quantity in g';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectedDate == null
                      ? 'No Date Chosen!'
                      : 'Date: ${_selectedDate!.day} ${DateFormat('MMMM').format(_selectedDate!)} ${_selectedDate!.year}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      print(pickedDate);
                      _selectedDate = pickedDate;
                    });
                  }
                },
                child: const Text('Choose Date'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 20),
                          Text(
                            'Adding, please wait...',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                );

                final food = FoodModel(
                  name: _nameController.text,
                  calories: await getCalorie(
                      _nameController.text.trim(), gramController.text.trim()),
                  imagePath: 'path/to/default/image',
                  date: _selectedDate ?? DateTime.now(),
                );
                saveToDB(food);
                Navigator.of(context).pop();
                Navigator.of(context).pop(food);
              }
            },
            child: const Text('Add Food'),
          ),
        ],
      ),
    );
  }

  void saveToDB(FoodModel food) async {
    final dbHelper = FoodDatabase();
    await dbHelper.insertFood(food);
  }

  Future<double> getCalorie(String foodName, String gram) async {
    if (foodName.isEmpty) return 0;
    try {
      String question = "How many calories are in $gram of $foodName?";
      List<Part> prompt = [Part.text(question)];

      final event = await gemini.prompt(
        parts: prompt,
      );

      String response = event?.content?.parts?.fold(
            "",
            (previous, current) {
              if (current is TextPart) {
                return "$previous ${current.text}";
              } else {
                return previous;
              }
            },
          ) ??
          "";
      print('${'*' * 30} $response');
      double calorieValue = _extractCalorieValue(response);
      return calorieValue;
    } catch (e) {
      print("Error while getting calorie value: $e");
      return 0.0;
    }
  }

  double _extractCalorieValue(String response) {
    try {
      final match = RegExp(r'(\d+\.?\d*)\s*calories').firstMatch(response);
      if (match != null) {
        return double.parse(match.group(1)!);
      } else {
        throw Exception("No calorie value found in the response");
      }
    } catch (e) {
      print("Error extracting calorie value: $e");
      return 0.0;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

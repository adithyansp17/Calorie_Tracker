import 'package:calorie_tracker/add_new_food.dart';
import 'package:calorie_tracker/constant.dart';
import 'package:calorie_tracker/db_helper.dart';
import 'package:calorie_tracker/food_list.dart';
import 'package:calorie_tracker/food_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalorieTracker extends StatefulWidget {
  const CalorieTracker({super.key});

  @override
  State<CalorieTracker> createState() => _CalorieTrackerState();
}

class _CalorieTrackerState extends State<CalorieTracker> {
  List<FoodModel> foodList = [];
  double totalCalories = 0;
  String message = '';

  @override
  void initState() {
    super.initState();
    getFoodList();
  }

  String getMonth() {
    DateTime now = DateTime.now();
    return DateFormat('MMMM').format(now);
  }

  void getFoodList() async {
    final dhHelper = FoodDatabase();
    foodList = await dhHelper.getAllFoods();
    totalCal();
  }

  void totalCal() {
    totalCalories = 0;
    for (var item in foodList) {
      totalCalories = totalCalories + item.calories;
    }
    double diff = Constant.goal - totalCalories;
    if (diff <= 0) {
      message = "You have reached today's goal";
    } else {
      message = 'You are $diff calories \n away from your goal';
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constant.appTitle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.pink,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: Colors.pink.shade400,
            width: 500,
            child: Column(
              children: [
                Text(
                  '${today.day} ${getMonth()}',
                  style: const TextStyle(fontSize: 30, color: Colors.white),
                ),
                const SizedBox(
                  height: 10,
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        value: totalCalories / Constant.goal,
                        strokeWidth: 15,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                        backgroundColor: Colors.pink.shade200,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Goal",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          Constant.goal.toString(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          "KCal",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: foodList.length,
              itemBuilder: (context, index) {
                final food = foodList[index];

                return Dismissible(
                  key: Key(food.name),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    setState(() {
                      foodList.removeAt(index);
                    });

                    final db = FoodDatabase();
                    await db.deleteFood(food.name, food.date);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${food.name} has been deleted'),
                      ),
                    );
                    getFoodList();
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: FoodItemRow(
                    name: food.name,
                    calories: food.calories,
                    icon: Icons.fastfood,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (BuildContext context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                child: const AddFoodForm(),
              );
            },
          );
          if (res != null) {
            getFoodList();
          }
        },
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add),
      ),
    );
  }
}

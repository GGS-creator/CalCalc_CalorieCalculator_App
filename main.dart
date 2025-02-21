// There are 2 widgets being created each time and the data
//is not being saved in save preferences.
//Try replacing the each week food with the code of veg foods
//Or if it does not work just fuck it dont need to post the weeklyfoods in
//the app Done
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(CalCalcApp());
}

class CalCalcApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CalCalc',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController stepsController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  String caloriesLost = '';
  String stepsNeeded='';
  int totalCalories = 0;
  List<Map<String, dynamic>> vegFoodItems = [];
  List<Map<String, dynamic>> nonVegFoodItems = [];
  List<Map<String,dynamic>>widgetList=[];
  List<Map<String,dynamic>>weeklyFoodData=[];
   void convertStepsToCalories() {
    final int steps = int.tryParse(stepsController.text) ?? 0;
    final double calories = (steps / 1000) * 35;
    setState(() {
      caloriesLost = calories.toStringAsFixed(2); // Keeps two decimal places
    });
  }
  void convertCaloriesToSteps(){
    final double calories=double.tryParse(caloriesController.text) ?? 0;
    final int steps=((calories/35)*1000).toInt();
    setState((){
      stepsNeeded=steps.toString();
    });
  }
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('vegFoodItems', jsonEncode(vegFoodItems));
    await prefs.setString('nonVegFoodItems', jsonEncode(nonVegFoodItems));
    await prefs.setInt('totalCalories', totalCalories);
    await prefs.setString('weeksDietWidgets',jsonEncode(widgetList));

    await prefs.setString('weeklyFoodData',jsonEncode(weeklyFoodData));
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      vegFoodItems = (jsonDecode(prefs.getString('vegFoodItems') ?? '[]') as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      nonVegFoodItems = (jsonDecode(prefs.getString('nonVegFoodItems') ?? '[]') as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      totalCalories = prefs.getInt('totalCalories') ?? 0;
      String? savedWidgets = prefs.getString('weeksDietWidgets');
      if (savedWidgets != null) {
        widgetList = List<Map<String, dynamic>>.from(json.decode(savedWidgets));
      }
      String? savedWeeklyFoodData = prefs.getString('weeklyFoodData');
    if (savedWeeklyFoodData != null) {
      weeklyFoodData = (
        jsonDecode(savedWeeklyFoodData).map((key, value) => MapEntry(key, List<Map<String, dynamic>>.from(value)))
      );
    }
    });
  }
  
  // Save widgets to SharedPreferences
  Future<void> _saveWidgets() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('weeksDietWidgets', json.encode(widgetList));
  }

  void _createNewWidget(String name, int calories) {
    setState(() {
      widgetList.add({'name': name, 'calories': calories});
    });
    _saveWidgets(); // Save the updated widget list to SharedPreferences
  }

  
  void _resetCalories() {
    setState(() {
      totalCalories = 0;
    });
    _saveData();
  }

  void _addCalories(int calories) {
    setState(() {
      totalCalories += calories;
    });
    _saveData();
  }

  void _addVegFoodItem(Map<String, dynamic> foodItem) {
    setState(() {
      vegFoodItems.add(foodItem);
    });
    _saveData();
  }

  void _addNonVegFoodItem(Map<String, dynamic> foodItem) {
    setState(() {
      nonVegFoodItems.add(foodItem);
    });
    _saveData();
  }

  void _deleteVegFoodItem(int index) {
    setState(() {
      vegFoodItems.removeAt(index);
    });
    _saveData();
  }

  void _deleteNonVegFoodItem(int index) {
    setState(() {
      nonVegFoodItems.removeAt(index);
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CalCalc'),
      ),
      
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Menu', style: TextStyle(color: Colors.white)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.lightGreen],
                ),
              ),
            ),
              ListTile(
                title:Text('Search foods'),
                leading:Icon(Icons.search, color: Colors.green),
                onTap:(){
                  showSearch(
                    context:context,
                    delegate: FoodSearchDelegate(addCalories:_addCalories),

                    );
                },
                ),
            
            ListTile(
              leading: Icon(Icons.home, color: Colors.green),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.emoji_food_beverage, color: Colors.green),
              title: Text('Veg Foods'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VegFoodsPage(
                      addCalories: _addCalories,
                      vegFoodItems: vegFoodItems,
                      addVegFoodItem: _addVegFoodItem,
                      deleteVegFoodItem: _deleteVegFoodItem,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.restaurant, color: Colors.green),
              title: Text('Non-Veg Foods'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NonVegFoodsPage(
                      addCalories: _addCalories,
                      nonVegFoodItems: nonVegFoodItems,
                      addNonVegFoodItem: _addNonVegFoodItem,
                      deleteNonVegFoodItem: _deleteNonVegFoodItem,
                    ),
                  ),
                );
              },
            ),
            ListTile(
  leading: Icon(Icons.calendar_today,color: Colors.green,),
  title: Text('Weeks Diet'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeeksDietPage( // Navigate to the widget
          addCalories: _addCalories,
          //createNewWidget: _createNewWidget, // Assuming you also have this function
        ),
      ),
    );
  },
),

            ListTile(
              leading: Icon(Icons.gamepad, color: Colors.green),
              title: Text('Game'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GamePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.document_scanner, color: Colors.green),
              title: Text('About app'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder:(context)=>AboutAppPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child:Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Image.asset(
                'icons/homescreen_logo.png',
                height:300,
                width:300,
              ),
            ),
            SizedBox(height: 20),
            Text(
            'What is the Keto Diet?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'The ketogenic diet is a high-fat, adequate-protein, low-carbohydrate diet that forces the body to burn fats rather than carbohydrates. It has several health benefits including weight loss, improved health markers, and enhanced mental clarity.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
            Text(
              'Total Calories Eaten: $totalCalories',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
          
              ),
            ),
            SizedBox(height:20),
            ElevatedButton(
              onPressed: _resetCalories,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 250, 250, 250), // Reverted to original color
              ),
              child: Text('Reset Calories'),
            ),
            SizedBox(height:30),
            Text(
              'CalCalc converter',
              style: TextStyle(fontSize:24,fontWeight:FontWeight.bold,
              color:Colors.white,),
            
            ),
            SizedBox(height:16),
            TextField(
              controller:stepsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter steps walked',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: convertStepsToCalories,
              child: Text('Convert'),
            ),
            SizedBox(height: 16),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Calories Lost',
              ),
              controller: TextEditingController(text: caloriesLost),
            ),
            SizedBox(height: 32),
            TextField(
              controller: caloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter calories to burn',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: convertCaloriesToSteps,
              child: Text('Convert to Steps'),
            ),
            SizedBox(height: 16),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Steps Needed',
              ),
              controller: TextEditingController(text: stepsNeeded),
            ),
            // ******************************
            SizedBox(height:16),
            GridView.count(
              crossAxisCount:2,
              crossAxisSpacing:8,
              mainAxisSpacing:8,
              childAspectRatio:2.5,
              shrinkWrap: true,
              children:[
            GestureDetector(
              onTap:(){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder:(content)=>SouthIndianFoodsPage(addCalories: _addCalories),
                  ),
                  );
              },
              child:Container(
                  decoration:BoxDecoration(
                    borderRadius:BorderRadius.circular(8.0),
                    image:DecorationImage(
                      image: AssetImage('icons/dosa.jpg'),
                      fit:BoxFit.cover,
                      ),
                  ),
                
                alignment:Alignment.center,
                  child:Text(
                    'South Indian',
                    style:TextStyle(
                      fontSize:14,
                      color:Colors.white,
                      fontWeight:FontWeight.bold,
                      shadows:[
                        Shadow(
                          offset:Offset(1.0,1.0),
                          blurRadius:3.0,
                          color:Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
              onTap:(){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder:(content)=>NorthIndianFoodsPage(addCalories: _addCalories),
                  ),
                  );
              },
              child:Container(
                  decoration:BoxDecoration(
                    borderRadius:BorderRadius.circular(8.0),
                    image:DecorationImage(
                      image: AssetImage('icons/roti.jpg'),
                      fit:BoxFit.cover,
                      ),
                  ),
                
                alignment:Alignment.center,
                  child:Text(
                    'North Indian menu',
                    style:TextStyle(
                      fontSize:14,
                      color:Colors.white,
                      fontWeight:FontWeight.bold,
                      shadows:[
                        Shadow(
                          offset:Offset(1.0,1.0),
                          blurRadius:3.0,
                          color:Colors.black,
                        ),
                      ],
                    ),
                    
                  ),
                ),
              ),
              GestureDetector(
              onTap:(){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder:(content)=>McDonaldsPage(addCalories: _addCalories),
                  ),
                  );
              },
              child:Container(
                  decoration:BoxDecoration(
                    borderRadius:BorderRadius.circular(8.0),
                    image:DecorationImage(
                      image: AssetImage('icons/burger.jpg'),
                      fit:BoxFit.cover,
                      ),
                  ),
                
                alignment:Alignment.center,
                  child:Text(
                    'Mc Donalds',
                    style:TextStyle(
                      fontSize:14,
                      color:Colors.white,
                      fontWeight:FontWeight.bold,
                      shadows:[
                        Shadow(
                          offset:Offset(1.0,1.0),
                          blurRadius:3.0,
                          color:Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
              onTap:(){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder:(content)=>BurgerkingPage(addCalories: _addCalories),
                  ),
                  );
              },
              child:Container(
                  decoration:BoxDecoration(
                    borderRadius:BorderRadius.circular(8.0),
                    image:DecorationImage(
                      image: AssetImage('icons/burger2.jpg'),
                      fit:BoxFit.cover,
                      ),
                  ),
                
                alignment:Alignment.center,
                  child:Text(
                    'Burger King',
                    style:TextStyle(
                      fontSize:14,
                      color:Colors.white,
                      fontWeight:FontWeight.bold,
                      shadows:[
                        Shadow(
                          offset:Offset(1.0,1.0),
                          blurRadius:3.0,
                          color:Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
              onTap:(){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder:(content)=>ItalianFoodsPage(addCalories: _addCalories),
                  ),
                  );
              },
              child:Container(
                  decoration:BoxDecoration(
                    borderRadius:BorderRadius.circular(8.0),
                    image:DecorationImage(
                      image: AssetImage('icons/italian.jpg'),
                      fit:BoxFit.cover,
                      ),
                  ),
                
                alignment:Alignment.center,
                  child:Text(
                    'Italian Food',
                    style:TextStyle(
                      fontSize:14,
                      color:Colors.white,
                      fontWeight:FontWeight.bold,
                      shadows:[
                        Shadow(
                          offset:Offset(1.0,1.0),
                          blurRadius:3.0,
                          color:Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
              onTap:(){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder:(content)=>ChineseFoodsPage(addCalories: _addCalories),
                  ),
                  );
              },
              child:Container(
                  decoration:BoxDecoration(
                    borderRadius:BorderRadius.circular(8.0),
                    image:DecorationImage(
                      image: AssetImage('icons/chinese.jpg'),
                      fit:BoxFit.cover,
                      ),
                  ),
                
                alignment:Alignment.center,
                  child:Text(
                    'Chinese food',
                    style:TextStyle(
                      fontSize:14,
                      color:Colors.white,
                      fontWeight:FontWeight.bold,
                      shadows:[
                        Shadow(
                          offset:Offset(1.0,1.0),
                          blurRadius:3.0,
                          color:Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
              onTap:(){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder:(content)=>MexicanFoodsPage(addCalories: _addCalories),
                  ),
                  );
              },
              child:Container(
                  decoration:BoxDecoration(
                    borderRadius:BorderRadius.circular(8.0),
                    image:DecorationImage(
                      image: AssetImage('icons/taco.jpg'),
                      fit:BoxFit.cover,
                      ),
                  ),
                
                alignment:Alignment.center,
                  child:Text(
                    'Mexican Food',
                    style:TextStyle(
                      fontSize:14,
                      color:Colors.white,
                      fontWeight:FontWeight.bold,
                      shadows:[
                        Shadow(
                          offset:Offset(1.0,1.0),
                          blurRadius:3.0,
                          color:Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
              onTap:(){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder:(content)=>DominosFoodsPage(addCalories: _addCalories),
                  ),
                  );
              },
              child:Container(
                  decoration:BoxDecoration(
                    borderRadius:BorderRadius.circular(8.0),
                    image:DecorationImage(
                      image: AssetImage('icons/pizza.jpg'),
                      fit:BoxFit.cover,
                      ),
                  ),
                
                alignment:Alignment.center,
                  child:Text(
                    'Dominos Pizza',
                    style:TextStyle(
                      fontSize:14,
                      color:Colors.white,
                      fontWeight:FontWeight.bold,
                      shadows:[
                        Shadow(
                          offset:Offset(1.0,1.0),
                          blurRadius:3.0,
                          color:Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
              onTap:(){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder:(content)=>KFCFoodsPage(addCalories: _addCalories),
                  ),
                  );
              },
              child:Container(
                  decoration:BoxDecoration(
                    borderRadius:BorderRadius.circular(8.0),
                    image:DecorationImage(
                      image: AssetImage('icons/chicken.jpg'),
                      fit:BoxFit.cover,
                      ),
                  ),
                
                alignment:Alignment.center,
                  child:Text(
                    'KFC',
                    style:TextStyle(
                      fontSize:14,
                      color:Colors.white,
                      fontWeight:FontWeight.bold,
                      shadows:[
                        Shadow(
                          offset:Offset(1.0,1.0),
                          blurRadius:3.0,
                          color:Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
              onTap:(){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder:(content)=>TacoBellFoodsPage(addCalories: _addCalories),
                  ),
                  );
              },
              child:Container(
                  decoration:BoxDecoration(
                    borderRadius:BorderRadius.circular(8.0),
                    image:DecorationImage(
                      image: AssetImage('icons/tacobell.jpg'),
                      fit:BoxFit.cover,
                      ),
                  ),
                
                alignment:Alignment.center,
                  child:Text(
                    'Taco Bell',
                    style:TextStyle(
                      fontSize:14,
                      color:Colors.white,
                      fontWeight:FontWeight.bold,
                      shadows:[
                        Shadow(
                          offset:Offset(1.0,1.0),
                          blurRadius:3.0,
                          color:Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              ],
            ),
              ],
            ),
        ),
      ),
        );     
  }
}
class VegFoodsPage extends StatelessWidget {
  final Function(int) addCalories;
  final List<Map<String, dynamic>> vegFoodItems;
  final Function(Map<String, dynamic>) addVegFoodItem;
  final Function(int) deleteVegFoodItem;

  VegFoodsPage({
    required this.addCalories,
    required this.vegFoodItems,
    required this.addVegFoodItem,
    required this.deleteVegFoodItem,
  });

  final TextEditingController foodNameController = TextEditingController();
  final TextEditingController foodCaloriesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Veg Foods'),
      ),
      body: Container(
        color: Colors.lightBlue,
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.5,
                ),
                itemCount: vegFoodItems.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      addCalories(vegFoodItems[index]['calories']);
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                    content: Text(
                        '${vegFoodItems[index]['name']} added! ${vegFoodItems[index]['calories']} calories',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                    backgroundColor: Colors.lightGreen,
                    duration: Duration(seconds: 1),
                    behavior:SnackBarBehavior.floating,
                      ),
                  );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                vegFoodItems[index]['name'],
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.white),
                            onPressed: () {
                              deleteVegFoodItem(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: foodNameController,
                    decoration: InputDecoration(labelText: 'Food Name'),
                  ),
                  TextField(
                    controller: foodCaloriesController,
                    decoration: InputDecoration(labelText: 'Calories'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      String foodName = foodNameController.text;
                      int foodCalories = int.tryParse(foodCaloriesController.text) ?? 0;
                      addVegFoodItem({'name': foodName, 'calories': foodCalories});
                      foodNameController.clear();
                      foodCaloriesController.clear();
                    },
                    child: Text('Add Food'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NonVegFoodsPage extends StatelessWidget {
  final Function(int) addCalories;
  final List<Map<String, dynamic>> nonVegFoodItems;
  final Function(Map<String, dynamic>) addNonVegFoodItem;
  final Function(int) deleteNonVegFoodItem;

  NonVegFoodsPage({
    required this.addCalories,
    required this.nonVegFoodItems,
    required this.addNonVegFoodItem,
    required this.deleteNonVegFoodItem,
  });

  final TextEditingController foodNameController = TextEditingController();
  final TextEditingController foodCaloriesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Non-Veg Foods'),
      ),
      body: Container(
        color: Colors.lightBlue,
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.5,
                ),
                itemCount: nonVegFoodItems.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      addCalories(nonVegFoodItems[index]['calories']);
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                    content: Text(
                        '${nonVegFoodItems[index]['name']} added! ${nonVegFoodItems[index]['calories']} calories',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                    backgroundColor: Colors.lightGreen,
                    duration: Duration(seconds: 1),
                    behavior:SnackBarBehavior.floating,
                      ),
                  );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                nonVegFoodItems[index]['name'],
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.white),
                            onPressed: () {
                              deleteNonVegFoodItem(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: foodNameController,
                    decoration: InputDecoration(labelText: 'Food Name'),
                  ),
                  TextField(
                    controller: foodCaloriesController,
                    decoration: InputDecoration(labelText: 'Calories'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      String foodName = foodNameController.text;
                      int foodCalories = int.tryParse(foodCaloriesController.text) ?? 0;
                      addNonVegFoodItem({'name': foodName, 'calories': foodCalories});
                      foodNameController.clear();
                      foodCaloriesController.clear();
                    },
                    child: Text('Add Food'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}
// class FlappyBirdGame extends StatefulWidget {
//   @override
//   _FlappyBirdGameState createState() => _FlappyBirdGameState();
// }

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double birdY = 0.0;
  double time = 0.0;
  double height = 0.0;
  double initialHeight = 0.0;
  bool gameHasStarted = false;
  static const double birdHeight = 0.1; // Height of the bird

  void jump() {
    if (!gameHasStarted) return;

    setState(() {
      time = 0;
      initialHeight = birdY;
    });
  }

  void startGame() {
    gameHasStarted = true;
    _controller.forward();
  }

  void resetGame() {
    setState(() {
      birdY = 0.0;
      time = 0.0;
      height = 0.0;
      initialHeight = 0.0;
      gameHasStarted = false;
    });
    _controller.stop();
  }

  bool birdIsDead() {
    return birdY > 1 - birdHeight || birdY < -1; // Check if bird hits ground or top
  }

  bool birdWins() {
    return birdY < -0.9 && birdY > -1.0; // Adjust this as per your health box height
  }

  void showGameOverDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                resetGame();
                Navigator.of(context).pop();
              },
              child: Text('Replay'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1))
      ..addListener(() {
        setState(() {
          time += 0.02; // Increment time
          height = -4.9 * time * time + 2.8 * time; // Physics equation
          birdY = initialHeight - height; // Bird's new position

          // Check if the bird hits the ground or the ceiling
          if (birdIsDead()) {
            _controller.stop();
            showGameOverDialog('You Lost!');
          } else if (birdWins()) {
            _controller.stop();
            showGameOverDialog('You Won!');
          }
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CalCalc Motivation Game'),
      ),
      body: GestureDetector(
        onTap: gameHasStarted ? jump : startGame,
        child: Stack(
          children: <Widget>[
            // Bird with sticker
            AnimatedContainer(
              alignment: Alignment(0, birdY),
              duration: Duration(milliseconds: 0),
              color: const Color.fromARGB(255, 97, 165, 220), // Sky color
              child: Container(
                height: 50,
                width: 50,
                color:const Color.fromARGB(255,6,185,65)
              ),
            ),
            // Bottom Temptation bar
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 30,
                width: 200,
                color: Colors.red,
                child: Center(
                  child: Text(
                    'Temptation',
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                ),
              ),
            ),
            // Top Health bar
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                color: const Color.fromARGB(255, 28, 226, 68), // Health bar color
                width: 200,
                height: 30,
                child: Center(
                  child: Text(
                    'Health',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ),
            // Start message
            !gameHasStarted
                ? Align(
                    alignment: Alignment.center,
                    child: Text(
                      'TAP TO START',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
class McDonaldsPage extends StatelessWidget {
  final Function(int) addCalories;
  final List<Map<String, dynamic>> mcDonaldsItems = [
    {'name': 'Veg Surprise Burger', 'calories': 313.44},
    {'name': 'McAloo Tikki Burger', 'calories': 370}, 
    {'name': 'McSpicy Paneer Burger', 'calories': 354.44},
    {'name': 'Maharaja Mac', 'calories': 675},
    {'name': 'Chicken Maharaja Mac Burger', 'calories': 444.44},
    {'name': 'McChicken Burger', 'calories': 344.44},
    {'name': 'Filet-O-Fish Burger', 'calories': 344.44},
    {'name': 'Veg McWrap', 'calories': 344.44},
    {'name': 'Chicken McWrap', 'calories': 394.44},
    {'name': 'French Fries (Medium)', 'calories': 320},
    {'name': 'French Fries (Large)', 'calories': 420},
    {'name': 'Chicken McNuggets (4 pieces)', 'calories': 170},
    {'name': 'Chicken McNuggets (6 pieces)', 'calories': 250},
    {'name': 'Chicken McNuggets (9 pieces)', 'calories': 380},
    {'name': 'McFlurry with M&M\'s', 'calories': 300},
    {'name': 'McFlurry with Oreo', 'calories': 320},
    {'name': 'McFlurry with Cadbury Dairy Milk', 'calories': 340},
    {'name': 'Soft Serve Cone', 'calories': 140},
    {'name': 'Soft Serve Cup', 'calories': 170},
    {'name': 'McShake (Strawberry)', 'calories': 240},
    {'name': 'McShake (Chocolate)', 'calories': 260},
    {'name': 'McShake (Vanilla)', 'calories': 240},
    {'name': 'McCafe Coffee', 'calories': 5},
    {'name': 'McCafe Tea', 'calories': 10},
    {'name': 'Egg McMuffin','calories':300},
    {'name': 'Sausage McMuffin','calories':350},
    {'name': 'Veg McMuffin','calories':250},
    {'name': 'Big Breakfast','calories':550},
    {'name': 'Hotcakes','calories':250},
    {'name': 'Hash Browns','calories':150},
    {'name': 'Coke small','calories':150},
    {'name': 'Coke Classic','calories':60},
    {'name': 'Coke Large','calories':362},
  ];

  McDonaldsPage({required this.addCalories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('McDonald\'s Menu'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.blue, // Background color for the McDonald’s menu
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Two widgets per row
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.5, // Size ratio for small widgets
          ),
          itemCount: mcDonaldsItems.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                addCalories(mcDonaldsItems[index]['calories']!.toInt());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${mcDonaldsItems[index]['name']} added! ${mcDonaldsItems[index]['calories']} calories',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                    backgroundColor: Colors.lightGreen,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.lightGreen, // Small-sized blue widgets
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          mcDonaldsItems[index]['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
class BurgerkingPage extends StatelessWidget {
  final Function(int) addCalories;
  final List<Map<String, dynamic>> burgerkingItems = [
    {'name': 'Crispy Veg', 'calories': 426.7},
    {'name': 'BK Veggie', 'calories': 444.7}, 
    {'name': 'Whopper', 'calories': 642.7},
    {'name': 'Chicken Whopper', 'calories': 642.7},
    {'name': 'Mutton Whopper', 'calories': 642.7},
    {'name': 'Impossible Whopper', 'calories': 642.7},
    {'name': 'Chicken Sandwich', 'calories': 444.7},
    {'name': 'Mutton Sandwich', 'calories': 444.7},
    {'name': 'Veg Sandwich', 'calories': 426.7},
    {'name': 'Chicken Tenders (4 pieces)', 'calories': 240},
    {'name': 'Chicken Tenders (6 pieces)', 'calories': 360},
    {'name': 'Chicken Tenders (9 pieces)', 'calories': 540},
    {'name': 'French Fries (Medium)', 'calories': 320},
    {'name': 'French Fries (Large)', 'calories': 420},
    {'name': 'Soft Serve Cone', 'calories': 140},
    {'name': 'Soft Serve Cup', 'calories': 170},
    {'name': 'King Shake (Strawberry)', 'calories': 240},
    {'name': 'King Shake (Chocolate)', 'calories': 260},
    {'name': 'King Shake (Vanilla)', 'calories': 240},
    {'name': 'BK Breakfast Meal', 'calories': 550},
    {'name': 'Veg Breakfast Meal', 'calories': 450},
    {'name': 'Egg Meal', 'calories': 350},
    {'name': 'Sausage Meal', 'calories': 400},
    {'name': 'Hash Browns', 'calories': 150},
  ];

  BurgerkingPage({required this.addCalories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Burger King\'s Menu'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.blue,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Two widgets per row
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.5, // Size ratio for small widgets
          ),
          itemCount: burgerkingItems.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                addCalories(burgerkingItems[index]['calories']!.toInt());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${burgerkingItems[index]['name']} added! ${burgerkingItems[index]['calories']} calories',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                    backgroundColor: Colors.lightGreen,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.lightGreen, // Small-sized blue widgets
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          burgerkingItems[index]['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
class SouthIndianFoodsPage extends StatelessWidget {
  final Function(int) addCalories;
  final List<Map<String, dynamic>> southIndianItems = [
    {'name': 'Idli', 'calories': 58},
    {'name': 'Dosa', 'calories': 168},
    {'name': 'Vada', 'calories': 97},
    {'name': 'Sambar', 'calories': 90},
    {'name': 'Upma', 'calories': 192},
    {'name': 'Pongal', 'calories': 204},
    {'name': 'Uttapam', 'calories': 90},
    {'name': 'Rasam', 'calories': 40},
    {'name': 'Rice', 'calories': 130},
    {'name': 'Coconut Chutney', 'calories': 75},
    {'name': 'Parotta', 'calories': 300},
    {'name': 'Curd Rice', 'calories': 150},
    {'name': 'Lemon Rice', 'calories': 200},
    {'name': 'Biryani', 'calories': 350},
    {'name': 'Puri', 'calories': 101},
    {'name': 'Payasam', 'calories': 250},
    {'name': 'Idli', 'calories': 39},
{'name': 'Vada', 'calories': 97}, 
{'name': 'Khara Bath', 'calories': 200}, 
{'name': 'Kesari Bath', 'calories': 220}, 
{'name': 'Chow Chow Bath', 'calories': 420}, 
{'name': 'Rava Idli', 'calories': 85}, 
{'name': 'Rice Bath', 'calories': 250}, 
{'name': 'Poori', 'calories': 101}, 
{'name': 'Buns', 'calories': 200}, 
{'name': 'Curd Vada', 'calories': 150}, 
{'name': 'Pongal', 'calories': 204}, 
{'name': 'Bisibele Bath', 'calories': 300}, 
{'name': 'Bajji', 'calories': 150}, 
{'name': 'Pakoda', 'calories': 150}, 
{'name': 'Bonda Soup', 'calories': 180}, 
{'name': 'Maddur Vada', 'calories': 175}, 
{'name': 'Gulab Jamun', 'calories': 150}, 
{'name': 'Halwa', 'calories': 300}, 
{'name': 'Masala Dosa', 'calories': 168}, 
{'name': 'Plain Dosa', 'calories': 120}, 
{'name': 'Set Dosa', 'calories': 230}, 
{'name': 'Onion Dosa', 'calories': 150}, 
{'name': 'Onion Masala Dosa', 'calories': 210}, 
{'name': 'Rava Dosa', 'calories': 180}, 
{'name': 'Rava Masala Dosa', 'calories': 220}, 
{'name': 'Rava Onion Dosa', 'calories': 190}, 
{'name': 'Rava Onion Masala Dosa', 'calories': 250}, 
{'name': 'Paper Masala Dosa', 'calories': 200}, 
{'name': 'Paper Plain Dosa', 'calories': 170}, 
{'name': 'Butter Masala Dosa', 'calories': 250}, 
{'name': 'Butter Plain Dosa', 'calories': 220}, 
{'name': 'Open Butter Masala', 'calories': 270}, 
{'name': 'Ghee Roast Masala', 'calories': 300}, 
{'name': 'Ghee Roast Plain', 'calories': 270}, 
{'name': 'South Indian Meals', 'calories': 600},


  ];

  SouthIndianFoodsPage({required this.addCalories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('South Indian Foods'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.blue, // Changed color to differentiate
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Two widgets per row
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.5, // Size ratio for small widgets
          ),
          itemCount: southIndianItems.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                addCalories(southIndianItems[index]['calories']!.toInt());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${southIndianItems[index]['name']} added! ${southIndianItems[index]['calories']} calories',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                    backgroundColor: Colors.lightGreen,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.lightGreen, // Small-sized blue widgets
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          southIndianItems[index]['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
class NorthIndianFoodsPage extends StatelessWidget {
  final Function(int) addCalories;
  final List<Map<String, dynamic>> northIndianItems = [
    {'name': 'Paneer Butter Masala', 'calories': 400},
    {'name': 'Butter Naan', 'calories': 250},
    {'name': 'Dal Makhani', 'calories': 320},
    {'name': 'Chole Bhature', 'calories': 450},
    {'name': 'Aloo Paratha', 'calories': 290},
    {'name': 'Rajma Chawal', 'calories': 360},
    {'name': 'Palak Paneer', 'calories': 280},
    {'name': 'Chicken Tikka', 'calories': 280},
    {'name': 'Mutton Rogan Josh', 'calories': 400},
    {'name': 'Kofta Curry', 'calories': 320},
    {'name': 'Biryani', 'calories': 450},
    {'name': 'Samosa', 'calories': 262},
    {'name': 'Tandoori Roti', 'calories': 120},
    {'name': 'Pav Bhaji', 'calories': 400},
    {'name': 'Gulab Jamun', 'calories': 143},
    {'name': 'Lassi', 'calories': 250},
    {'name': 'Dal Tadka', 'calories': 180},
{'name': 'Dal Palak', 'calories': 200},
{'name': 'Plain Palak', 'calories': 120},
{'name': 'Palak Paneer Masala', 'calories': 320},
{'name': 'Green Peas Masala', 'calories': 150},
{'name': 'Aloo Gobi Masala', 'calories': 210},
{'name': 'Aloo Palak Masala', 'calories': 230},
{'name': 'Capsicum Masala', 'calories': 190},
{'name': 'Veg Hyderabadi', 'calories': 280},
{'name': 'Mixed Veg Curry', 'calories': 210},
{'name': 'Paneer Butter Masala', 'calories': 400},
{'name': 'Paneer Tikka Masala', 'calories': 350},
{'name': 'Paneer Mutter Masala', 'calories': 330},
{'name': 'Paneer Kadai', 'calories': 300},
{'name': 'Kaju Masala', 'calories': 400},
{'name': 'Kaju Paneer Masala', 'calories': 420},
{'name': 'Baby Corn Masala', 'calories': 180},
{'name': 'Mushroom Masala', 'calories': 170},
{'name': 'Veg Kadai', 'calories': 240},
{'name': 'Aloo Jeera Dry', 'calories': 150},
{'name': 'Roti Special', 'calories': 120},
{'name': 'Roti', 'calories': 100},
{'name': 'Butter Roti', 'calories': 120},
{'name': 'Naan', 'calories': 240},
{'name': 'Butter Naan', 'calories': 250},
{'name': 'Garlic Naan', 'calories': 260},
{'name': 'Butter Garlic Naan', 'calories': 280},
{'name': 'Kulcha', 'calories': 220},
{'name': 'Butter Kulcha', 'calories': 240},
{'name': 'Veg Parota', 'calories': 210},
{'name': 'Aloo Parota', 'calories': 290},
{'name': 'Paneer Parota', 'calories': 310},
{'name': 'Veg Palav', 'calories': 250},
{'name': 'Peas Palav', 'calories': 230},
{'name': 'Mushroom Biryani', 'calories': 320},
{'name': 'Paneer Biryani', 'calories': 350},
{'name': 'Handi Biryani', 'calories': 400},
{'name': 'Mughlai Biryani', 'calories': 420},
{'name': 'Veg Hyderabadi Biryani', 'calories': 360},
{'name': 'Palak Paneer Biryani', 'calories': 350},
{'name': 'Ghee Rice', 'calories': 300},
{'name': 'Jeera Rice', 'calories': 240},
{'name': 'Palak Rice', 'calories': 220},
{'name': 'Dal Kichadi', 'calories': 280},

  ];

  NorthIndianFoodsPage({required this.addCalories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('North Indian Foods'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.blue, // Changed color to differentiate
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Two widgets per row
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.5, // Size ratio for small widgets
          ),
          itemCount: northIndianItems.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                addCalories(northIndianItems[index]['calories']!.toInt());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${northIndianItems[index]['name']} added! ${northIndianItems[index]['calories']} calories',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                    backgroundColor: Colors.lightGreen,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.lightGreen, // Small-sized blue widgets
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          northIndianItems[index]['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
class ItalianFoodsPage extends StatelessWidget {
  final Function(int) addCalories;
  final List<Map<String, dynamic>> italianItems = [
    {'name': 'Margherita Pizza', 'calories': 300},
    {'name': 'Pasta Alfredo', 'calories': 450},
    {'name': 'Lasagna', 'calories': 600},
    {'name': 'Focaccia Bread', 'calories': 200},
    {'name': 'Tiramisu', 'calories': 350},
    {'name': 'Risotto', 'calories': 400},
    {'name': 'Bruschetta', 'calories': 150},
    {'name': 'Carbonara', 'calories': 500},
    {'name': 'Minestrone Soup', 'calories': 200},
    {'name': 'Gelato', 'calories': 250},
    {'name': 'Caprese Salad', 'calories': 180},
    {'name': 'Gnocchi', 'calories': 300},
  ];

  ItalianFoodsPage({required this.addCalories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Italian Foods'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.blue,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.5,
          ),
          itemCount: italianItems.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                addCalories(italianItems[index]['calories']!.toInt());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${italianItems[index]['name']} added! ${italianItems[index]['calories']} calories',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                    backgroundColor: Colors.lightGreen,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.lightGreen,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          italianItems[index]['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
class ChineseFoodsPage extends StatelessWidget {
  final Function(int) addCalories;
  final List<Map<String, dynamic>> chineseItems = [
    {'name': 'Sweet and Sour Chicken', 'calories': 400},
    {'name': 'Spring Rolls', 'calories': 200},
    {'name': 'Kung Pao Chicken', 'calories': 500},
    {'name': 'Chow Mein', 'calories': 450},
    {'name': 'Fried Rice', 'calories': 350},
    {'name': 'Dumplings', 'calories': 150},
    {'name': 'Peking Duck', 'calories': 600},
    {'name': 'Hot and Sour Soup', 'calories': 150},
    {'name': 'Mapo Tofu', 'calories': 300},
    {'name': 'Szechuan Beef', 'calories': 500},
    {'name': 'Lo Mein', 'calories': 400},
    {'name': 'Egg Rolls', 'calories': 250},
    {'name': 'BABY CORN MANCHURIAN', 'calories': 190},
{'name': 'BABY CORN CHILLI', 'calories': 210},
{'name': 'BABY CORN PEPPER DRY', 'calories': 180},
{'name': 'GOBI MANCHURIAN', 'calories': 220},
{'name': 'GOBI CHILLI', 'calories': 240},
{'name': 'GOBI 65', 'calories': 250},
{'name': 'MUSHROOM MANCHURIAN', 'calories': 200},
{'name': 'MASHROOM CHILLI', 'calories': 220},
{'name': 'MASHROOM PEPPER DRY', 'calories': 180},
{'name': 'MASHROOM 65', 'calories': 250},
{'name': 'PANEER MANCHURIAN', 'calories': 270},
{'name': 'PANEER CHILLI', 'calories': 290},
{'name': 'PANEER PEPPER DRY', 'calories': 260},
{'name': 'PANEER 65', 'calories': 310},
{'name': 'MASHROOM KABAB', 'calories': 150},
{'name': 'O PANEER KABAB', 'calories': 320},
{'name': 'VEG FRIED RICE', 'calories': 330},
{'name': 'VEG NOODLES', 'calories': 300},
{'name': 'BABY CORN FRIED RICE', 'calories': 350},
{'name': 'MUSHROOM FRIED RICE', 'calories': 340},
{'name': 'PANEER FRIED RICE', 'calories': 370},
{'name': 'SCHEZWAN FRIED RICE', 'calories': 380},
{'name': 'PANEER SCHEZWAN FRIED RICE', 'calories': 400},
{'name': 'MUSHROOM SCHEZWAN FRIED RICE', 'calories': 390},
{'name': 'PANEER NOODLES', 'calories': 360},
{'name': 'SCHEZWAN NOODLES', 'calories': 370},
{'name': 'PANEER SCHEZWAN NOODLES', 'calories': 390},
{'name': 'MUSHROOM SCHEZWAL NOODLES', 'calories': 380},
{'name': 'GOBI FRIED RICE', 'calories': 350},

  ];

  ChineseFoodsPage({required this.addCalories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chinese Foods'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.blue,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.5,
          ),
          itemCount: chineseItems.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                addCalories(chineseItems[index]['calories']!.toInt());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${chineseItems[index]['name']} added! ${chineseItems[index]['calories']} calories',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                    backgroundColor: Colors.lightGreen,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.lightGreen,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          chineseItems[index]['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
class MexicanFoodsPage extends StatelessWidget {
  final Function(int) addCalories;
  final List<Map<String, dynamic>> mexicanItems = [
    {'name': 'Tacos', 'calories': 300},
    {'name': 'Burrito', 'calories': 500},
    {'name': 'Quesadilla', 'calories': 450},
    {'name': 'Guacamole', 'calories': 200},
    {'name': 'Nachos', 'calories': 400},
    {'name': 'Enchiladas', 'calories': 600},
    {'name': 'Chimichanga', 'calories': 700},
    {'name': 'Fajitas', 'calories': 350},
    {'name': 'Tamales', 'calories': 400},
    {'name': 'Churros', 'calories': 350},
    {'name': 'Salsa', 'calories': 50},
    {'name': 'Tortilla Chips', 'calories': 300},
  ];

  MexicanFoodsPage({required this.addCalories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mexican Foods'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.blue,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.5,
          ),
          itemCount: mexicanItems.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                addCalories(mexicanItems[index]['calories']!.toInt());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${mexicanItems[index]['name']} added! ${mexicanItems[index]['calories']} calories',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                    backgroundColor: Colors.lightGreen,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.lightGreen,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          mexicanItems[index]['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
class DominosFoodsPage extends StatelessWidget {
  final Function(int) addCalories;
  final List<Map<String, dynamic>> dominosItems = [
    {'name': 'Pepperoni Pizza (slice)', 'calories': 150},
    {'name': 'Margherita Pizza (slice)', 'calories': 120},
    {'name': 'Farmhouse Pizza (slice)', 'calories': 130},
    {'name': 'Garlic Bread', 'calories': 200},
    {'name': 'Stuffed Garlic Bread', 'calories': 220},
    {'name': 'Chicken Wings', 'calories': 80},
    {'name': 'Choco Lava Cake', 'calories': 170},
    {'name': 'Veggie Paradise Pizza (slice)', 'calories': 140},
    {'name': 'Paneer Makhani Pizza (slice)', 'calories': 160},
  ];

  DominosFoodsPage({required this.addCalories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Domino\'s Foods'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.blue,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.5,
          ),
          itemCount: dominosItems.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                addCalories(dominosItems[index]['calories']!.toInt());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${dominosItems[index]['name']} added! ${dominosItems[index]['calories']} calories',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                    backgroundColor: Colors.lightGreen,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.lightGreen,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          dominosItems[index]['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
class KFCFoodsPage extends StatelessWidget {
  final Function(int) addCalories;
  final List<Map<String, dynamic>> kfcItems = [
    {'name': 'Fried Chicken (piece)', 'calories': 220},
    {'name': 'Zinger Burger', 'calories': 450},
    {'name': 'Popcorn Chicken', 'calories': 300},
    {'name': 'Chicken Wings (piece)', 'calories': 150},
    {'name': 'Veggie Burger', 'calories': 350},
    {'name': 'Chicken Strips', 'calories': 120},
    {'name': 'French Fries (regular)', 'calories': 300},
    {'name': 'Chocolate Cake', 'calories': 280},
  ];

  KFCFoodsPage({required this.addCalories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KFC Foods'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.blue,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.5,
          ),
          itemCount: kfcItems.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                addCalories(kfcItems[index]['calories']!.toInt());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${kfcItems[index]['name']} added! ${kfcItems[index]['calories']} calories',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                    backgroundColor: Colors.lightGreen,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.lightGreen,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          kfcItems[index]['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
class TacoBellFoodsPage extends StatelessWidget {
  final Function(int) addCalories;
  final List<Map<String, dynamic>> tacoBellItems = [
    {'name': 'Crunchy Taco', 'calories': 170},
    {'name': 'Soft Taco', 'calories': 200},
    {'name': 'Burrito', 'calories': 350},
    {'name': 'Cheesy Gordita Crunch', 'calories': 400},
    {'name': 'Chalupa', 'calories': 300},
    {'name': 'Quesadilla', 'calories': 450},
    {'name': 'Nachos', 'calories': 350},
    {'name': 'Mexican Pizza', 'calories': 500},
    {'name': 'Cinnamon Twists', 'calories': 170},
    {'name': 'Cheesy Roll-Up', 'calories': 180},
  ];

  TacoBellFoodsPage({required this.addCalories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Taco Bell Foods'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.blue,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.5,
          ),
          itemCount: tacoBellItems.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                addCalories(tacoBellItems[index]['calories']!.toInt());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${tacoBellItems[index]['name']} added! ${tacoBellItems[index]['calories']} calories',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                    backgroundColor: Colors.lightGreen,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.lightGreen,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          tacoBellItems[index]['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AboutAppPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About CalCalc'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.lightBlue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Image.asset(
                'icons/background_tree.jpg',
                height:300,
                width:300,
              ),
            ),
            Text(
              'CalCalc App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'CalCalc is an application that helps users track their calorie intake, '
              'provides detailed information about various food items, and also includes a fun game '
              'to keep users motivated. The app offers various features like converting steps walked '
              'into calories lost and allows users to track both vegetarian and non-vegetarian food items.'
              'The calories for the food items are close to the accurate number of calories for the specific food items but some may be innacurate and CalCalc or the developer cannot be held accountable.'
              'Made by GG.'
            ),
            SizedBox(height: 20),
            Text(
              'Key Features:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text('- Calorie tracking'),
            Text('- Food categories like Veg, Non-Veg, and more'),
            Text('- Step-to-calorie converter'),
            Text('- Integrated mini-games'),
          ],
        ),
      ),
    );
  }
}
class FoodSearchDelegate extends SearchDelegate {
  final Function(int) addCalories;
  
  FoodSearchDelegate({required this.addCalories});

  // Sample list of all available food items for search
  final List<Map<String, dynamic>> allFoods = [
    
    {'name': 'Crispy Veg', 'calories': 426.7},
    {'name': 'BK Veggie', 'calories': 444.7}, 
    {'name': 'Whopper', 'calories': 642.7},
    {'name': 'Chicken Whopper', 'calories': 642.7},
    {'name': 'Mutton Whopper', 'calories': 642.7},
    {'name': 'Impossible Whopper', 'calories': 642.7},
    {'name': 'Chicken Sandwich', 'calories': 444.7},
    {'name': 'Mutton Sandwich', 'calories': 444.7},
    {'name': 'Veg Sandwich', 'calories': 426.7},
    {'name': 'Chicken Tenders (4 pieces)', 'calories': 240},
    {'name': 'Chicken Tenders (6 pieces)', 'calories': 360},
    {'name': 'Chicken Tenders (9 pieces)', 'calories': 540},
    {'name': 'French Fries (Medium)', 'calories': 320},
    {'name': 'French Fries (Large)', 'calories': 420},
    {'name': 'Soft Serve Cone', 'calories': 140},
    {'name': 'Soft Serve Cup', 'calories': 170},
    {'name': 'King Shake (Strawberry)', 'calories': 240},
    {'name': 'King Shake (Chocolate)', 'calories': 260},
    {'name': 'King Shake (Vanilla)', 'calories': 240},
    {'name': 'BK Breakfast Meal', 'calories': 550},
    {'name': 'Veg Breakfast Meal', 'calories': 450},
    {'name': 'Egg Meal', 'calories': 350},
    {'name': 'Sausage Meal', 'calories': 400},
    {'name': 'Hash Browns', 'calories': 150},
 
{'name': 'Veg Surprise Burger', 'calories': 313.44},
    {'name': 'McAloo Tikki Burger', 'calories': 370}, 
    {'name': 'McSpicy Paneer Burger', 'calories': 354.44},
    {'name': 'Maharaja Mac', 'calories': 675},
    {'name': 'Chicken Maharaja Mac Burger', 'calories': 444.44},
    {'name': 'McChicken Burger', 'calories': 344.44},
    {'name': 'Filet-O-Fish Burger', 'calories': 344.44},
    {'name': 'Veg McWrap', 'calories': 344.44},
    {'name': 'Chicken McWrap', 'calories': 394.44},
    {'name': 'French Fries (Medium)', 'calories': 320},
    {'name': 'French Fries (Large)', 'calories': 420},
    {'name': 'Chicken McNuggets (4 pieces)', 'calories': 170},
    {'name': 'Chicken McNuggets (6 pieces)', 'calories': 250},
    {'name': 'Chicken McNuggets (9 pieces)', 'calories': 380},
    {'name': 'McFlurry with M&M\'s', 'calories': 300},
    {'name': 'McFlurry with Oreo', 'calories': 320},
    {'name': 'McFlurry with Cadbury Dairy Milk', 'calories': 340},
    {'name': 'Soft Serve Cone', 'calories': 140},
    {'name': 'Soft Serve Cup', 'calories': 170},
    {'name': 'McShake (Strawberry)', 'calories': 240},
    {'name': 'McShake (Chocolate)', 'calories': 260},
    {'name': 'McShake (Vanilla)', 'calories': 240},
    {'name': 'McCafe Coffee', 'calories': 5},
    {'name': 'McCafe Tea', 'calories': 10},
    {'name': 'Egg McMuffin','calories':300},
    {'name': 'Sausage McMuffin','calories':350},
    {'name': 'Veg McMuffin','calories':250},
    {'name': 'Big Breakfast','calories':550},
    {'name': 'Hotcakes','calories':250},
    {'name': 'Hash Browns','calories':150},
    {'name': 'Coke small','calories':150},
    {'name': 'Coke Classic','calories':60},
    {'name': 'Coke Large','calories':362},

{'name': 'Idli', 'calories': 58},
    {'name': 'Dosa', 'calories': 168},
    {'name': 'Vada', 'calories': 97},
    {'name': 'Sambar', 'calories': 90},
    {'name': 'Upma', 'calories': 192},
    {'name': 'Pongal', 'calories': 204},
    {'name': 'Uttapam', 'calories': 90},
    {'name': 'Rasam', 'calories': 40},
    {'name': 'Rice', 'calories': 130},
    {'name': 'Coconut Chutney', 'calories': 75},
    {'name': 'Parotta', 'calories': 300},
    {'name': 'Curd Rice', 'calories': 150},
    {'name': 'Lemon Rice', 'calories': 200},
    {'name': 'Biryani', 'calories': 350},
    {'name': 'Puri', 'calories': 101},
    {'name': 'Payasam', 'calories': 250},
    {'name': 'Idli', 'calories': 39},
{'name': 'Vada', 'calories': 97}, 
{'name': 'Khara Bath', 'calories': 200}, 
{'name': 'Kesari Bath', 'calories': 220}, 
{'name': 'Chow Chow Bath', 'calories': 420}, 
{'name': 'Rava Idli', 'calories': 85}, 
{'name': 'Rice Bath', 'calories': 250}, 
{'name': 'Poori', 'calories': 101}, 
{'name': 'Buns', 'calories': 200}, 
{'name': 'Curd Vada', 'calories': 150}, 
{'name': 'Pongal', 'calories': 204}, 
{'name': 'Bisibele Bath', 'calories': 300}, 
{'name': 'Bajji', 'calories': 150}, 
{'name': 'Pakoda', 'calories': 150}, 
{'name': 'Bonda Soup', 'calories': 180}, 
{'name': 'Maddur Vada', 'calories': 175}, 
{'name': 'Gulab Jamun', 'calories': 150}, 
{'name': 'Halwa', 'calories': 300}, 
{'name': 'Masala Dosa', 'calories': 168}, 
{'name': 'Plain Dosa', 'calories': 120}, 
{'name': 'Set Dosa', 'calories': 230}, 
{'name': 'Onion Dosa', 'calories': 150}, 
{'name': 'Onion Masala Dosa', 'calories': 210}, 
{'name': 'Rava Dosa', 'calories': 180}, 
{'name': 'Rava Masala Dosa', 'calories': 220}, 
{'name': 'Rava Onion Dosa', 'calories': 190}, 
{'name': 'Rava Onion Masala Dosa', 'calories': 250}, 
{'name': 'Paper Masala Dosa', 'calories': 200}, 
{'name': 'Paper Plain Dosa', 'calories': 170}, 
{'name': 'Butter Masala Dosa', 'calories': 250}, 
{'name': 'Butter Plain Dosa', 'calories': 220}, 
{'name': 'Open Butter Masala', 'calories': 270}, 
{'name': 'Ghee Roast Masala', 'calories': 300}, 
{'name': 'Ghee Roast Plain', 'calories': 270}, 
{'name': 'South Indian Meals', 'calories': 600},

{'name': 'Paneer Butter Masala', 'calories': 400},
    {'name': 'Butter Naan', 'calories': 250},
    {'name': 'Dal Makhani', 'calories': 320},
    {'name': 'Chole Bhature', 'calories': 450},
    {'name': 'Aloo Paratha', 'calories': 290},
    {'name': 'Rajma Chawal', 'calories': 360},
    {'name': 'Palak Paneer', 'calories': 280},
    {'name': 'Chicken Tikka', 'calories': 280},
    {'name': 'Mutton Rogan Josh', 'calories': 400},
    {'name': 'Kofta Curry', 'calories': 320},
    {'name': 'Biryani', 'calories': 450},
    {'name': 'Samosa', 'calories': 262},
    {'name': 'Tandoori Roti', 'calories': 120},
    {'name': 'Pav Bhaji', 'calories': 400},
    {'name': 'Gulab Jamun', 'calories': 143},
    {'name': 'Lassi', 'calories': 250},
    {'name': 'Dal Tadka', 'calories': 180},
{'name': 'Dal Palak', 'calories': 200},
{'name': 'Plain Palak', 'calories': 120},
{'name': 'Palak Paneer Masala', 'calories': 320},
{'name': 'Green Peas Masala', 'calories': 150},
{'name': 'Aloo Gobi Masala', 'calories': 210},
{'name': 'Aloo Palak Masala', 'calories': 230},
{'name': 'Capsicum Masala', 'calories': 190},
{'name': 'Veg Hyderabadi', 'calories': 280},
{'name': 'Mixed Veg Curry', 'calories': 210},
{'name': 'Paneer Butter Masala', 'calories': 400},
{'name': 'Paneer Tikka Masala', 'calories': 350},
{'name': 'Paneer Mutter Masala', 'calories': 330},
{'name': 'Paneer Kadai', 'calories': 300},
{'name': 'Kaju Masala', 'calories': 400},
{'name': 'Kaju Paneer Masala', 'calories': 420},
{'name': 'Baby Corn Masala', 'calories': 180},
{'name': 'Mushroom Masala', 'calories': 170},
{'name': 'Veg Kadai', 'calories': 240},
{'name': 'Aloo Jeera Dry', 'calories': 150},
{'name': 'Roti Special', 'calories': 120},
{'name': 'Roti', 'calories': 100},
{'name': 'Butter Roti', 'calories': 120},
{'name': 'Naan', 'calories': 240},
{'name': 'Butter Naan', 'calories': 250},
{'name': 'Garlic Naan', 'calories': 260},
{'name': 'Butter Garlic Naan', 'calories': 280},
{'name': 'Kulcha', 'calories': 220},
{'name': 'Butter Kulcha', 'calories': 240},
{'name': 'Veg Parota', 'calories': 210},
{'name': 'Aloo Parota', 'calories': 290},
{'name': 'Paneer Parota', 'calories': 310},
{'name': 'Veg Palav', 'calories': 250},
{'name': 'Peas Palav', 'calories': 230},
{'name': 'Mushroom Biryani', 'calories': 320},
{'name': 'Paneer Biryani', 'calories': 350},
{'name': 'Handi Biryani', 'calories': 400},
{'name': 'Mughlai Biryani', 'calories': 420},
{'name': 'Veg Hyderabadi Biryani', 'calories': 360},
{'name': 'Palak Paneer Biryani', 'calories': 350},
{'name': 'Ghee Rice', 'calories': 300},
{'name': 'Jeera Rice', 'calories': 240},
{'name': 'Palak Rice', 'calories': 220},
{'name': 'Dal Kichadi', 'calories': 280},

{'name': 'Margherita Pizza', 'calories': 300},
    {'name': 'Pasta Alfredo', 'calories': 450},
    {'name': 'Lasagna', 'calories': 600},
    {'name': 'Focaccia Bread', 'calories': 200},
    {'name': 'Tiramisu', 'calories': 350},
    {'name': 'Risotto', 'calories': 400},
    {'name': 'Bruschetta', 'calories': 150},
    {'name': 'Carbonara', 'calories': 500},
    {'name': 'Minestrone Soup', 'calories': 200},
    {'name': 'Gelato', 'calories': 250},
    {'name': 'Caprese Salad', 'calories': 180},
    {'name': 'Gnocchi', 'calories': 300},

{'name': 'Sweet and Sour Chicken', 'calories': 400},
    {'name': 'Spring Rolls', 'calories': 200},
    {'name': 'Kung Pao Chicken', 'calories': 500},
    {'name': 'Chow Mein', 'calories': 450},
    {'name': 'Fried Rice', 'calories': 350},
    {'name': 'Dumplings', 'calories': 150},
    {'name': 'Peking Duck', 'calories': 600},
    {'name': 'Hot and Sour Soup', 'calories': 150},
    {'name': 'Mapo Tofu', 'calories': 300},
    {'name': 'Szechuan Beef', 'calories': 500},
    {'name': 'Lo Mein', 'calories': 400},
    {'name': 'Egg Rolls', 'calories': 250},
    {'name': 'BABY CORN MANCHURIAN', 'calories': 190},
{'name': 'BABY CORN CHILLI', 'calories': 210},
{'name': 'BABY CORN PEPPER DRY', 'calories': 180},
{'name': 'GOBI MANCHURIAN', 'calories': 220},
{'name': 'GOBI CHILLI', 'calories': 240},
{'name': 'GOBI 65', 'calories': 250},
{'name': 'MUSHROOM MANCHURIAN', 'calories': 200},
{'name': 'MASHROOM CHILLI', 'calories': 220},
{'name': 'MASHROOM PEPPER DRY', 'calories': 180},
{'name': 'MASHROOM 65', 'calories': 250},
{'name': 'PANEER MANCHURIAN', 'calories': 270},
{'name': 'PANEER CHILLI', 'calories': 290},
{'name': 'PANEER PEPPER DRY', 'calories': 260},
{'name': 'PANEER 65', 'calories': 310},
{'name': 'MASHROOM KABAB', 'calories': 150},
{'name': 'O PANEER KABAB', 'calories': 320},
{'name': 'VEG FRIED RICE', 'calories': 330},
{'name': 'VEG NOODLES', 'calories': 300},
{'name': 'BABY CORN FRIED RICE', 'calories': 350},
{'name': 'MUSHROOM FRIED RICE', 'calories': 340},
{'name': 'PANEER FRIED RICE', 'calories': 370},
{'name': 'SCHEZWAN FRIED RICE', 'calories': 380},
{'name': 'PANEER SCHEZWAN FRIED RICE', 'calories': 400},
{'name': 'MUSHROOM SCHEZWAN FRIED RICE', 'calories': 390},
{'name': 'PANEER NOODLES', 'calories': 360},
{'name': 'SCHEZWAN NOODLES', 'calories': 370},
{'name': 'PANEER SCHEZWAN NOODLES', 'calories': 390},
{'name': 'MUSHROOM SCHEZWAL NOODLES', 'calories': 380},
{'name': 'GOBI FRIED RICE', 'calories': 350},

{'name': 'Tacos', 'calories': 300},
    {'name': 'Burrito', 'calories': 500},
    {'name': 'Quesadilla', 'calories': 450},
    {'name': 'Guacamole', 'calories': 200},
    {'name': 'Nachos', 'calories': 400},
    {'name': 'Enchiladas', 'calories': 600},
    {'name': 'Chimichanga', 'calories': 700},
    {'name': 'Fajitas', 'calories': 350},
    {'name': 'Tamales', 'calories': 400},
    {'name': 'Churros', 'calories': 350},
    {'name': 'Salsa', 'calories': 50},
    {'name': 'Tortilla Chips', 'calories': 300},

{'name': 'Pepperoni Pizza (slice)', 'calories': 150},
    {'name': 'Margherita Pizza (slice)', 'calories': 120},
    {'name': 'Farmhouse Pizza (slice)', 'calories': 130},
    {'name': 'Garlic Bread', 'calories': 200},
    {'name': 'Stuffed Garlic Bread', 'calories': 220},
    {'name': 'Chicken Wings', 'calories': 80},
    {'name': 'Choco Lava Cake', 'calories': 170},
    {'name': 'Veggie Paradise Pizza (slice)', 'calories': 140},
    {'name': 'Paneer Makhani Pizza (slice)', 'calories': 160},

{'name': 'Fried Chicken (piece)', 'calories': 220},
    {'name': 'Zinger Burger', 'calories': 450},
    {'name': 'Popcorn Chicken', 'calories': 300},
    {'name': 'Chicken Wings (piece)', 'calories': 150},
    {'name': 'Veggie Burger', 'calories': 350},
    {'name': 'Chicken Strips', 'calories': 120},
    {'name': 'French Fries (regular)', 'calories': 300},
    {'name': 'Chocolate Cake', 'calories': 280},

{'name': 'Crunchy Taco', 'calories': 170},
    {'name': 'Soft Taco', 'calories': 200},
    {'name': 'Burrito', 'calories': 350},
    {'name': 'Cheesy Gordita Crunch', 'calories': 400},
    {'name': 'Chalupa', 'calories': 300},
    {'name': 'Quesadilla', 'calories': 450},
    {'name': 'Nachos', 'calories': 350},
    {'name': 'Mexican Pizza', 'calories': 500},
    {'name': 'Cinnamon Twists', 'calories': 170},
    {'name': 'Cheesy Roll-Up', 'calories': 180},

    // Add more foods from both Veg and Non-Veg lists
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = allFoods.where((food) => food['name'].toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final food = results[index];
        return ListTile(
          title: Text(food['name']),
          subtitle: Text('${food['calories']} calories'),
          onTap: () {
            addCalories(food['calories']);
            close(context, null); // Close search after selecting
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allFoods.where((food) => food['name'].toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final food = suggestions[index];
        return ListTile(
          title: Text(food['name']),
          onTap: () {
            query = food['name'];
            showResults(context);
          },
        );
      },
    );
  }
}
class WeeksDietPage extends StatefulWidget {
  final Function(int) addCalories;

  WeeksDietPage({required this.addCalories});

  @override
  _WeeksDietPageState createState() => _WeeksDietPageState();
}

class _WeeksDietPageState extends State<WeeksDietPage> {
  // List of days for the week
  final List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  // Store food data for each day
  Map<String, List<Map<String, dynamic>>> weeklyFoodData = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };

  @override
  void initState() {
    super.initState();
    _loadAllDaysData(); // Load all days data when the screen is initialized
  }

  // Load all days data from SharedPreferences
  Future<void> _loadAllDaysData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (String day in daysOfWeek) {
      String? savedData = prefs.getString(day);
      if (savedData != null) {
        setState(() {
          weeklyFoodData[day] = List<Map<String, dynamic>>.from(jsonDecode(savedData));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weeks Diet'),
      ),
      body: Container(
        color: Colors.lightBlueAccent,
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 widgets per column
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 2, // Adjust to fit 2 items per column
                ),
                itemCount: daysOfWeek.length, // One widget for each day of the week
                itemBuilder: (context, index) {
                  String day = daysOfWeek[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the DayFoodsPage when a day is clicked
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DayFoodsPage(
                            day: day,
                            foodItems: weeklyFoodData[day]!,
                            addCalories: widget.addCalories,
                            addFoodItem: (foodItem) {
                              setState(() {
                                weeklyFoodData[day]!.add(foodItem);
                              });
                              _saveDataForDay(day); // Save food data for that day
                            },
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Save the food data for a specific day in SharedPreferences
  Future<void> _saveDataForDay(String day) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(weeklyFoodData[day]);
    await prefs.setString(day, jsonString); // Save data for the specific day
  }
}

class DayFoodsPage extends StatefulWidget {
  final String day;
  final List<Map<String, dynamic>> foodItems;
  final Function(int) addCalories;
  final Function(Map<String, dynamic>) addFoodItem;

  DayFoodsPage({
    required this.day,
    required this.foodItems,
    required this.addCalories,
    required this.addFoodItem,
  });

  @override
  _DayFoodsPageState createState() => _DayFoodsPageState();
}

class _DayFoodsPageState extends State<DayFoodsPage> {
  final TextEditingController foodNameController = TextEditingController();
  final TextEditingController foodCaloriesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.day} Foods'),
      ),
      body: Container(
        color: Colors.lightBlue,
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.5,
                ),
                itemCount: widget.foodItems.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      widget.addCalories(widget.foodItems[index]['calories']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${widget.foodItems[index]['name']} added! ${widget.foodItems[index]['calories']} calories',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Colors.lightGreen,
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                widget.foodItems[index]['name'],
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                widget.foodItems.removeAt(index); // Remove the item
                                _saveDataForDay(); // Save updated list
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: foodNameController,
                    decoration: InputDecoration(labelText: 'Food Name'),
                  ),
                  TextField(
                    controller: foodCaloriesController,
                    decoration: InputDecoration(labelText: 'Calories'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      String foodName = foodNameController.text;
                      int foodCalories = int.tryParse(foodCaloriesController.text) ?? 0;

                      // Add new food item to the list
                      Map<String, dynamic> newFoodItem = {'name': foodName, 'calories': foodCalories};
                      widget.addFoodItem(newFoodItem);

                      // Update the food items list
                      

                      _saveDataForDay(); // Save updated data
                      
                      foodNameController.clear();
                      foodCaloriesController.clear();
                    },
                    child: Text('Add Food'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Save the food data for the specific day in SharedPreferences
  Future<void> _saveDataForDay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String day = widget.day;
    String jsonString = jsonEncode(widget.foodItems);
    await prefs.setString(day, jsonString); // Save data for the specific day
  }
}

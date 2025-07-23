import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 

import 'firebase_options.dart';

import 'medicinebox_screen.dart';
import 'wristband_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Care Hub', 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), 
        useMaterial3: true, 
      ),
      
      initialRoute: '/', 
      routes: {
        '/': (context) => const HomePage(), 
        '/medicineBox': (context) => const MedicineBoxScreen(), 
        '/wristband': (context) => const WristbandScreen(), 
      },
      debugShowCheckedModeBanner: false, 
    );
  }
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        
        child: Column(          
          children: [
            Expanded(              
              child: Center(                
                child: Text(
                  'Smart Care Hub', 
                  style: TextStyle(
                    fontSize: 32, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.deepPurple, 
                  ),
                ),
              ),
            ),
            Padding(              
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Row(                
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                children: [                  
                  _buildOptionCard(
                    context,
                    icon: Icons.medical_services, // Icon representing medicine.
                    label: 'Medicine Box', // Text label for the option.
                    onTap: () {                      
                      Navigator.pushNamed(context, '/medicineBox');
                    },
                  ),                  
                  _buildOptionCard(
                    context,
                    icon: Icons.favorite, // Icon representing a heart (common for health/wearables).
                    label: 'Wristband', // Text label for the option.
                    onTap: () {                      
                      Navigator.pushNamed(context, '/wristband');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildOptionCard(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(      
      onTap: onTap, 
      borderRadius: BorderRadius.circular(16.0), 
      child: Card(     
        
        elevation: 4, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), 
        ),
        child: Container(          
          width: MediaQuery.of(context).size.width * 0.4, 
          padding: const EdgeInsets.all(20.0), 
          child: Column(            
            mainAxisSize: MainAxisSize.min, 
            children: [
              Icon(
                icon, // The icon to display.
                size: 50, // Large icon size.
                color: Colors.deepPurple, 
              ),
              const SizedBox(height: 10), 
              Text(
                label, 
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.w600, 
                  color: Colors.black87, 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

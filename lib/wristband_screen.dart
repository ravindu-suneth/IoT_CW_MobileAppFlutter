import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; 
class WristbandScreen extends StatefulWidget {
  const WristbandScreen({super.key});

  @override
  State<WristbandScreen> createState() => _WristbandScreenState();
}

class _WristbandScreenState extends State<WristbandScreen> {
  
  final DatabaseReference _heartRateRef =
      FirebaseDatabase.instance.ref('wristBand/heartRate');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wristband'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Smart Care Hub',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Smart Care Hub - Wristband Data',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              Expanded(
                child: Center(
                  child: StreamBuilder<DatabaseEvent>(
                    stream: _heartRateRef.onValue, 
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                        final int heartRate = snapshot.data!.snapshot.value as int;

                        
                        bool showSos = heartRate < 60 || heartRate > 100;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (showSos) 
                              Column(
                                children: const [
                                  Text(
                                    'SOS',
                                    style: TextStyle(
                                      fontSize: 48, 
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red, 
                                    ),
                                  ),
                                  SizedBox(height: 10), 
                                ],
                              ),
                            Text(
                              'Current Heart Rate: $heartRate BPM',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const Text(
                          'Current Heart Rate: N/A BPM',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

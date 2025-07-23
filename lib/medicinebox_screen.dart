import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class MedicineBoxScreen extends StatefulWidget {
  const MedicineBoxScreen({super.key});

  @override
  State<MedicineBoxScreen> createState() => _MedicineBoxScreenState();
}

class _MedicineBoxScreenState extends State<MedicineBoxScreen> {  
  final CollectionReference _medicinesCollection =
      FirebaseFirestore.instance.collection('medicines');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Box'),
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
                'Smart Care Hub - Medicine Box',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _medicinesCollection.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No medicine doses found.'));
                    }

                    final List<DocumentSnapshot> documents = snapshot.data!.docs;
                    documents.sort((a, b) => a.id.compareTo(b.id));

                    return ListView.separated(
                      itemCount: documents.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final doc = documents[index];
                        final data = doc.data() as Map<String, dynamic>;

                        final String doseName = data['medicineName'] ?? 'Dose ${index + 1}';
                        final String nextDose = data['nextDose'] ?? 'N/A';
                        final String lastDose = data['lastDose'] ?? 'N/A';

                        
                        final int statusValue = data['status'] ?? 1; 
                        final String statusText = statusValue == 1 ? 'Pending' : 'Taken';

                        return _buildDoseCard(
                          context,
                          docId: doc.id,
                          doseName: doseName,
                          nextDoseTime: nextDose,
                          lastDoseTime: lastDose,
                          status: statusText,
                          onEdit: () => _showEditDialog(context, doc.id, data),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildDoseCard(
    BuildContext context, {
    required String docId,
    required String doseName,
    required String nextDoseTime,
    required String lastDoseTime,
    required String status,
    required VoidCallback onEdit,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  doseName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: onEdit,
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'Next Dose: $nextDoseTime',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last Dose: $lastDoseTime',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: $status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: status == 'Taken' ? Colors.green.shade700 : Colors.orange.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  void _showEditDialog(BuildContext context, String docId, Map<String, dynamic> currentData) {
    final TextEditingController medicineNameController =
        TextEditingController(text: currentData['medicineName'] ?? '');
    final TextEditingController nextDoseController =
        TextEditingController(text: currentData['nextDose'] ?? '');
    final TextEditingController lastDoseController =
        TextEditingController(text: currentData['lastDose'] ?? '');

    
    int initialStatusValue = currentData['status'] ?? 1; 
    String selectedStatus = initialStatusValue == 1 ? 'Pending' : 'Taken';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Dose Details'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: medicineNameController,
                      decoration: const InputDecoration(labelText: 'Dose Name'),
                    ),
                    TextField(
                      controller: nextDoseController,
                      decoration: const InputDecoration(labelText: 'Next Dose Time'),
                    ),
                    TextField(
                      controller: lastDoseController,
                      decoration: const InputDecoration(labelText: 'Last Dose Time'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: <String>['Pending', 'Taken'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedStatus = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    
                    final int newFirestoreStatus = selectedStatus == 'Pending' ? 1 : 0;

                    final updatedData = {
                      'medicineName': medicineNameController.text.trim(),
                      'nextDose': nextDoseController.text.trim(),
                      'lastDose': lastDoseController.text.trim(),
                      'status': newFirestoreStatus, 
                    };

                    try {
                      await _medicinesCollection.doc(docId).update(updatedData);
                      Navigator.of(dialogContext).pop();
                    } catch (e) {
                      print('Error updating document: $e');
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

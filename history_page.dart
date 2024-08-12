import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  HistoryPage({super.key});

  final List<Map<String, dynamic>> visitedDoctors = [
    {
      'name': 'Dr. John Doe',
      'specialization': 'Cardiologist',
      'hospitalName': 'City Hospital',
      'date': DateTime(2023, 8, 15),
      'rating': 4.5,
    },
    {
      'name': 'Dr. Jane Smith',
      'specialization': 'Dermatologist',
      'hospitalName': 'Central Clinic',
      'date': DateTime(2023, 7, 22),
      'rating': 5.0,
    },
    {
      'name': 'Dr. Mike Johnson',
      'specialization': 'Pediatrician',
      'hospitalName': 'St. Mary\'s Hospital',
      'date': DateTime(2023, 6, 10),
      'rating': 4.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.blue[100]!, Colors.blue[300]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Visit History',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                    shadows: const [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.white,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: visitedDoctors.length,
                  itemBuilder: (context, index) {
                    final doctor = visitedDoctors[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: InkWell(
                          onTap: () => _showDetailsDialog(context, doctor),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.blue[800],
                                      child: Text(
                                        doctor['name'][0],
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doctor['name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            doctor['specialization'],
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      doctor['hospitalName'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue[800],
                                      ),
                                    ),
                                    Text(
                                      DateFormat('MMM d, yyyy')
                                          .format(doctor['date']),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.amber, size: 20),
                                    const SizedBox(width: 4),
                                    Text(
                                      doctor['rating'].toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Visit Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Doctor: ${doctor['name']}'),
              const SizedBox(height: 8),
              Text('Specialization: ${doctor['specialization']}'),
              const SizedBox(height: 8),
              Text('Hospital: ${doctor['hospitalName']}'),
              const SizedBox(height: 8),
              Text(
                  'Date: ${DateFormat('MMMM d, yyyy').format(doctor['date'])}'),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Rating: '),
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  Text('${doctor['rating']}'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Book Again'),
              onPressed: () {
                Navigator.of(context).pop();
                // Implement rebooking logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Rebooking ${doctor['name']}...')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

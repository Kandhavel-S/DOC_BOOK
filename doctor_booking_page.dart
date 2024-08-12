import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class DoctorBookingPage extends StatefulWidget {
  const DoctorBookingPage({super.key});

  @override
  State<DoctorBookingPage> createState() => _DoctorBookingPageState();
}

class _DoctorBookingPageState extends State<DoctorBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final placeController = TextEditingController();
  final specializationController = TextEditingController();
  final timeController = TextEditingController();
  List<Map<String, dynamic>> doctorResults =
      []; // Updated to Map for easier manipulation
  bool isLoading = false;
  String errorMessage = '';
  Map<int, bool> bookingStatus = {};
  Map<int, int?> tokenNumbers = {}; // To store token numbers for each doctor

  Future<void> findDoctors() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      doctorResults = [];
    });

    final String place = placeController.text;
    final String specialization = specializationController.text;
    final String time = timeController.text;

    final url = Uri.parse(
        'http://192.168.137.1:5000/predict'); // Update with your server's IP address or domain

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'place': place,
          'specialization': specialization,
          'time': time,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        setState(() {
          doctorResults = results
              .map((e) => e as Map<String, dynamic>)
              .toList(); // Cast to Map for easier manipulation
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data. Please try again.';
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error: $error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void bookAppointment(int index) {
    final tokenNumber = Random().nextInt(12) + 1;
    setState(() {
      bookingStatus[index] = true;
      tokenNumbers[index] =
          tokenNumber; // Store the token number for the doctor
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Appointment booked successfully! Your token number is $tokenNumber.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.network(
            'https://plus.unsplash.com/premium_photo-1668487827037-7b88850dea9c?q=80&w=2012&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Book a Doctor',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 13, 1, 1)
                              .withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                              placeController, 'Place', Icons.place),
                          const SizedBox(height: 16),
                          _buildTextField(specializationController,
                              'Specialization', Icons.medical_services),
                          const SizedBox(height: 16),
                          _buildTextField(timeController, 'Time (HH:MM:SS)',
                              Icons.access_time),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: findDoctors,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 110, 163, 223),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              child: Text('Find Doctors',
                                  style: TextStyle(fontSize: 18)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (isLoading)
                            const CircularProgressIndicator()
                          else if (errorMessage.isNotEmpty)
                            Text(errorMessage,
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 37, 47, 179)))
                          else if (doctorResults.isEmpty)
                            const Text('No results found.')
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: doctorResults.length,
                              itemBuilder: (context, index) {
                                final doctor = doctorResults[index];
                                int? tokenNumber = tokenNumbers[
                                    index]; // Retrieve the token number for the doctor
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    title: Text(
                                        'Doctor: ${doctor['doctor_name']}'),
                                    subtitle: Text(
                                        'Hospital: ${doctor['hospital_name']}\n'
                                        'Specialization: ${doctor['specialization']}\n'
                                        'Qualification: ${doctor['qualification']}\n'
                                        'Token Number: ${tokenNumber != null ? tokenNumber.toString() : 'N/A'}'), // Display token number here
                                    trailing: bookingStatus[index] == true
                                        ? const Icon(Icons.check_circle,
                                            color: Colors.green)
                                        : ElevatedButton(
                                            onPressed: () =>
                                                bookAppointment(index),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                            ),
                                            child: const Text('Book'),
                                          ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String labelText, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color.fromARGB(255, 46, 46, 172)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter $labelText';
        }
        return null;
      },
    );
  }
}

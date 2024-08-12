import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HospitalsPage extends StatefulWidget {
  const HospitalsPage({super.key});

  @override
  State<HospitalsPage> createState() => _HospitalsPageState();
}

class _HospitalsPageState extends State<HospitalsPage> {
  final TextEditingController _locationController = TextEditingController();
  List<String> _hospitals = [];
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _getHospitals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.137.1:5000/hospitals'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'location': _locationController.text,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          _hospitals = List<String>.from(result['hospitals']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _hospitals = [];
          _isLoading = false;
          _errorMessage = 'Failed to load hospitals. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _hospitals = [];
        _isLoading = false;
        _errorMessage = 'An error occurred: $e';
      });
      print('An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Search'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://plus.unsplash.com/premium_photo-1673953509975-576678fa6710?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 64,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Enter location',
                      labelStyle: const TextStyle(color: Colors.deepPurple),
                      fillColor: Colors.white.withOpacity(0.8),
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.deepPurpleAccent),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.deepPurple),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _getHospitals,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 5,
                    ),
                    child: Text(_isLoading ? 'Loading...' : 'Find Hospitals'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white.withOpacity(0.7),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                        ? Center(child: Text(_errorMessage))
                        : _hospitals.isEmpty
                            ? const Center(child: Text('No hospitals found'))
                            : ListView.builder(
                                itemCount: _hospitals.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                    child: ListTile(
                                      title: Text(_hospitals[index],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      tileColor: Colors.grey[100],
                                      onTap: () {
                                        // Handle tap event here
                                      },
                                    ),
                                  );
                                },
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

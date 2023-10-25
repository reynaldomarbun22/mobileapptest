import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

void main() => runApp(const MyApp());

class Contact {
  final String id;
  String firstName;
  String lastName;
  String email;
  String dob;

  Contact({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email = "",
    this.dob = "",
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( debugShowCheckedModeBanner: false,
      home: ContactListScreen(),
    );
  }
}

class ContactListScreen extends StatefulWidget {
  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<Contact> contacts = [];

  Future<void> _loadContacts() async {
  try {
    final jsonData = await rootBundle.loadString('lib/assets/data.json');
    final List<dynamic> jsonList = json.decode(jsonData);
    final List<Contact> loadedContacts = jsonList
        .map((contact) => Contact(
              id: contact['id'],
              firstName: contact['firstName'],
              lastName: contact['lastName'],
              email: contact['email'] ?? '',
              dob: contact['dob'] ?? '',
            ))
        .toList();

    setState(() {
      contacts = loadedContacts;
    });
  } catch (e) {
    print('Error loading contacts: $e');
  }
}

  @override
  void initState() {
    _loadContacts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact List'),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _loadContacts,
        child: GridView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return CircleAvatar(
      backgroundColor: Colors.orange,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${contacts[index].firstName} ${contacts[index].lastName}', textAlign: TextAlign.center,style: const TextStyle(color: Colors.blueAccent),),
         
        ],
      ),
    );
      }, 
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0, 
        mainAxisSpacing: 8.0, 
      ),
    ),
  ),
    );
  }
}

class ContactEditScreen extends StatefulWidget {
  final Contact contact;
  final Function(Contact) onSave;

  const ContactEditScreen({super.key, required this.contact,required this.onSave});

  @override
  // ignore: library_private_types_in_public_api
  _ContactEditScreenState createState() => _ContactEditScreenState();
}

class _ContactEditScreenState extends State<ContactEditScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  @override
  void initState() {
    firstNameController.text = widget.contact.firstName;
    lastNameController.text = widget.contact.lastName;
    emailController.text = widget.contact.email;
    dobController.text = widget.contact.dob;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Contact'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: dobController,
                decoration: const InputDecoration(labelText: 'Date of Birth'),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.contact.firstName = firstNameController.text;
                  widget.contact.lastName = lastNameController.text;
                  widget.contact.email = emailController.text;
                  widget.contact.dob = dobController.text;
                  widget.onSave(widget.contact);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

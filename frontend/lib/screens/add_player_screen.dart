import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({super.key});

  @override
  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  int? _selectedTeam;
  List<dynamic> teams = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    try {
      final loadedTeams = await ApiService.getTeams();
      setState(() {
        teams = loadedTeams;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load teams: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        await ApiService.addPlayer({
          'name': _nameController.text,
          'age': int.parse(_ageController.text),
          'team_id': _selectedTeam,
        });
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add player: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
        }
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ADD PLAYER')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Player Name',
                  labelStyle: const TextStyle(color: Color(0xFF39FF14)),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF39FF14))),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _ageController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Age',
                  labelStyle: const TextStyle(color: Color(0xFF39FF14)),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF39FF14))),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter age' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: _selectedTeam,
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Team',
                  labelStyle: const TextStyle(color: Color(0xFF39FF14)),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF39FF14))),
                ),
                items: teams.map<DropdownMenuItem<int>>((team) {
                  return DropdownMenuItem<int>(
                    value: team['team_id'],
                    child: Text(team['team_name']),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedTeam = value),
                validator: (value) => value == null ? 'Select a team' : null,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF39FF14),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 10,
                  shadowColor: const Color(0xFF39FF14).withOpacity(0.5),
                ),
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Text('SAVE PLAYER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

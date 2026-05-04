import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  late Future<List<dynamic>> futureSelection;
  List<dynamic> sports = [];
  String? selectedSportId;

  @override
  void initState() {
    super.initState();
    futureSelection = ApiService.getSelection();
    _loadSports();
  }

  Future<void> _loadSports() async {
    final loadedSports = await ApiService.getSports();
    setState(() {
      sports = loadedSports;
    });
  }

  void refreshList() {
    setState(() {
      futureSelection = ApiService.getSelection(sportId: selectedSportId != null ? int.parse(selectedSportId!) : null);
    });
  }

  Color _getStatusColor(String status) {
    if (status == 'Selected') return const Color(0xFF39FF14); // Neon Green
    if (status == 'Not Selected') return Colors.redAccent;
    return Colors.amber; // Pending
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQUAD'),
        actions: [
          if (sports.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: DropdownButton<String>(
                value: selectedSportId,
                dropdownColor: Theme.of(context).primaryColor,
                style: const TextStyle(color: Color(0xFF39FF14), fontWeight: FontWeight.bold),
                iconEnabledColor: const Color(0xFF39FF14),
                hint: const Text('All Sports', style: TextStyle(color: Colors.white54)),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Sports')),
                  ...sports.map((s) => DropdownMenuItem<String>(
                        value: s['sport_id'].toString(),
                        child: Text(s['sport_name'].toString().toUpperCase()),
                      )),
                ],
                onChanged: (val) {
                  setState(() {
                    selectedSportId = val;
                    refreshList();
                  });
                },
              ),
            )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureSelection,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF39FF14)));
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No data found'));

          final selections = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: selections.length,
            itemBuilder: (context, index) {
              final selection = selections[index];
              final String status = selection['selection_status'];
              final Color statusColor = _getStatusColor(status);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.white10,
                    child: ClipOval(
                        child: Image.network(
                          'https://api.dicebear.com/7.x/notionists/png?seed=${selection['player_id']}',
                          errorBuilder: (c, e, s) => Icon(Icons.person, color: statusColor),
                        ),
                    ),
                  ),
                  title: Text(selection['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(selection['event_name'], style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: statusColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.0),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

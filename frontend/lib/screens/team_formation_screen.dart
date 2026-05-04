import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import 'player_detail_screen.dart';
import 'dart:ui';

class TeamFormationScreen extends StatefulWidget {
  const TeamFormationScreen({super.key});

  @override
  State<TeamFormationScreen> createState() => _TeamFormationScreenState();
}

class _TeamFormationScreenState extends State<TeamFormationScreen> {
  String? _selectedSport;
  List<dynamic> _sports = [];
  List<dynamic> _allPlayers = [];
  List<dynamic?> _pitchPlayers = List.filled(11, null);
  String _selectedRole = 'ALL';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final sportsData = await ApiService.getSports();
      setState(() {
        _sports = sportsData;
        _selectedSport = appState.selectedSportPreference;
      });
      _fetchAllPlayers();
    } catch (e) {
      print('Formation load error: $e');
    }
  }

  Future<void> _fetchAllPlayers() async {
    if (_selectedSport == null) return;
    setState(() => _isLoading = true);
    try {
      final sport = _sports.firstWhere((s) => s['sport_name'] == _selectedSport);
      final data = await ApiService.getPlayers(sportId: sport['sport_id']);
      setState(() {
        _allPlayers = data;
        _selectedRole = 'ALL'; // Reset role filter when sport changes
        _isLoading = false;
      });
      _smartBuild(); // Default to smart build on load
    } catch (e) {
      print('Fetch all players error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _smartBuild() {
    // Sort by a mock "Performance Score" (Impact + Accuracy placeholder)
    final sorted = List.from(_allPlayers);
    sorted.sort((a, b) => (b['player_id'] % 20).compareTo(a['player_id'] % 20)); // Mock standings logic
    setState(() {
      for (int i = 0; i < _pitchPlayers.length && i < sorted.length; i++) {
        _pitchPlayers[i] = sorted[i];
      }
    });
  }

  String _getSportBg() {
    final s = _selectedSport?.toString().toUpperCase() ?? 'FOOTBALL';
    if (s.contains('FOOTBALL')) return 'assets/images/football_bg.jpg';
    if (s.contains('CRICKET')) return 'assets/images/cricket_bg.jpg';
    if (s.contains('F1')) return 'assets/images/f1_bg.jpg';
    if (s.contains('BASKETBALL')) return 'assets/images/basketball_bg.jpg';
    if (s.contains('TENNIS')) return 'assets/images/tennis_bg.jpg';
    if (s.contains('BADMINTON')) return 'assets/images/badminton_bg.jpg';
    if (s.contains('HOCKEY')) return 'assets/images/hockey_bg.jpg';
    if (s.contains('MOTOGP')) return 'assets/images/motogp_bg.jpg';
    if (s.contains('SWIMMING')) return 'assets/images/swimming_bg.jpg';
    return 'assets/images/sports_bg.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1, 
              child: Image.asset(
                _getSportBg(),
                fit: BoxFit.cover,
                key: ValueKey(_selectedSport),
              ),
            ),
          ),
          // Subtle gradient overlay to ensure text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.4), Colors.black.withOpacity(0.9)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildModernAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildSportSelector(),
                        const SizedBox(height: 30),
                        _buildActionRow(),
                        const SizedBox(height: 40),
                        if (_isLoading)
                          const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator()))
                        else
                          _buildPitchView(),
                        const SizedBox(height: 40),
                        _buildRoleSelector(),
                        const SizedBox(height: 20),
                        _buildSquadBench(),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('STRATEGIC SQUAD', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 2)),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 24, bottom: 20),
      ),
    );
  }

  Widget _buildTacticalBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [appState.primaryColor.withOpacity(0.05), Colors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildSportSelector() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _sports.length,
        itemBuilder: (context, i) {
          final s = _sports[i]['sport_name'];
          final isSel = _selectedSport == s;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedSport = s);
              _fetchAllPlayers();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: isSel ? appState.primaryColor : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                boxShadow: isSel ? [BoxShadow(color: appState.primaryColor.withOpacity(0.3), blurRadius: 15)] : [],
              ),
              child: Center(
                child: Text(s.toUpperCase(), style: GoogleFonts.outfit(color: isSel ? Colors.black : Colors.white24, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
              ),
            ),
          );
        },
      ),
    );
  }

  List<String> _getRolesForSport() {
    final s = _selectedSport?.toUpperCase() ?? '';
    if (s.contains('CRICKET')) return ['ALL', 'BATSMAN', 'BOWLER', 'WK'];
    if (s.contains('FOOTBALL')) return ['ALL', 'FORWARD', 'MIDFIELDER', 'DEFENDER', 'GK'];
    if (s.contains('BASKETBALL')) return ['ALL', 'GUARD', 'FORWARD', 'CENTER'];
    return ['ALL'];
  }

  Widget _buildRoleSelector({VoidCallback? onChanged}) {
    final roles = _getRolesForSport();
    if (roles.length <= 1) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FILTER BY POSITION', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 12),
        SizedBox(
          height: 35,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: roles.length,
            itemBuilder: (context, i) {
              final r = roles[i];
              final isSel = _selectedRole == r;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedRole = r);
                  if (onChanged != null) onChanged();
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: isSel ? appState.primaryColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSel ? appState.primaryColor : Colors.white10),
                  ),
                  child: Center(
                    child: Text(r, style: GoogleFonts.outfit(color: isSel ? appState.primaryColor : Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton('SMART BUILD', Icons.auto_fix_high, _smartBuild),
        _buildActionButton('CLEAR PITCH', Icons.delete_outline, () => setState(() => _pitchPlayers = List.filled(11, null))),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: appState.primaryColor, size: 16),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildPitchView() {
    return Container(
      height: 500,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Opacity(
                opacity: 0.5, // Increased from 0.3
                child: Image.asset(
                  _getSportBg(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          CustomPaint(
            size: Size.infinite,
            painter: PitchPainter(appState.primaryColor, _selectedSport ?? ''),
          ),
          ..._buildDynamicNodes(),
        ],
      ),
    );
  }

  List<Widget> _buildDynamicNodes() {
    final s = _selectedSport?.toString().toUpperCase() ?? 'FOOTBALL';
    if (s.contains('CRICKET')) {
      return [
        _buildPlayerNode(0.5, 0.4, 0, 'BATTER 1'),
        _buildPlayerNode(0.5, 0.6, 1, 'BATTER 2'),
        _buildPlayerNode(0.5, 0.2, 2, 'BOWLER'),
        _buildPlayerNode(0.5, 0.8, 3, 'WK'),
        _buildPlayerNode(0.2, 0.45, 4, 'SLIP'),
        _buildPlayerNode(0.8, 0.3, 5, 'COVER'),
        _buildPlayerNode(0.7, 0.7, 6, 'MID WKT'),
        _buildPlayerNode(0.2, 0.7, 7, 'FINE LEG'),
        _buildPlayerNode(0.8, 0.8, 8, 'THIRD MAN'),
        _buildPlayerNode(0.2, 0.2, 9, 'MID OFF'),
        _buildPlayerNode(0.8, 0.2, 10, 'MID ON'),
      ];
    } else if (s.contains('BASKETBALL')) {
      return [
        _buildPlayerNode(0.5, 0.85, 0, 'PG'),
        _buildPlayerNode(0.2, 0.6, 1, 'SG'),
        _buildPlayerNode(0.8, 0.6, 2, 'SF'),
        _buildPlayerNode(0.35, 0.35, 3, 'PF'),
        _buildPlayerNode(0.65, 0.35, 4, 'C'),
      ];
    } else if (s.contains('F1') || s.contains('MOTOGP')) {
      return [
        _buildPlayerNode(0.2, 0.2, 0, 'POLE'),
        _buildPlayerNode(0.5, 0.1, 1, 'P2'),
        _buildPlayerNode(0.8, 0.3, 2, 'P3'),
        _buildPlayerNode(0.8, 0.6, 3, 'P4'),
        _buildPlayerNode(0.5, 0.85, 4, 'P5'),
        _buildPlayerNode(0.2, 0.6, 5, 'P6'),
      ];
    } else if (s.contains('SWIMMING')) {
      return [
        _buildPlayerNode(0.5, 0.15, 0, 'LANE 1'),
        _buildPlayerNode(0.5, 0.3, 1, 'LANE 2'),
        _buildPlayerNode(0.5, 0.45, 2, 'LANE 3'),
        _buildPlayerNode(0.5, 0.6, 3, 'LANE 4'),
        _buildPlayerNode(0.5, 0.75, 4, 'LANE 5'),
        _buildPlayerNode(0.5, 0.9, 5, 'LANE 6'),
      ];
    } else if (s.contains('TENNIS') || s.contains('BADMINTON')) {
      return [
        _buildPlayerNode(0.5, 0.8, 0, 'PLAYER 1'),
        _buildPlayerNode(0.5, 0.2, 1, 'PLAYER 2'),
      ];
    } else {
      // Default: Football / Hockey
      return [
        _buildPlayerNode(0.5, 0.85, 0, 'GK'),
        _buildPlayerNode(0.2, 0.7, 1, 'LB'),
        _buildPlayerNode(0.4, 0.7, 2, 'CB'),
        _buildPlayerNode(0.6, 0.7, 3, 'CB'),
        _buildPlayerNode(0.8, 0.7, 4, 'RB'),
        _buildPlayerNode(0.3, 0.5, 5, 'CM'),
        _buildPlayerNode(0.5, 0.5, 6, 'CDM'),
        _buildPlayerNode(0.7, 0.5, 7, 'CM'),
        _buildPlayerNode(0.2, 0.3, 8, 'LW'),
        _buildPlayerNode(0.5, 0.2, 9, 'ST'),
        _buildPlayerNode(0.8, 0.3, 10, 'RW'),
      ];
    }
  }

  Widget _buildPlayerNode(double x, double y, int index, String positionLabel) {
    final player = _pitchPlayers[index];
    return Align(
      alignment: Alignment(x * 2 - 1, y * 2 - 1),
      child: GestureDetector(
        onTap: () {
          // Auto-set role filter based on node label
          final label = positionLabel.toUpperCase();
          if (label.contains('BOWLER')) _selectedRole = 'BOWLER';
          else if (label.contains('BATTER')) _selectedRole = 'BATSMAN';
          else if (label.contains('WK')) _selectedRole = 'WK';
          else if (label.contains('GK')) _selectedRole = 'GK';
          else if (label.contains('ST') || label.contains('LW') || label.contains('RW')) _selectedRole = 'FORWARD';
          else if (label.contains('CB') || label.contains('LB') || label.contains('RB')) _selectedRole = 'DEFENDER';
          else if (label.contains('CM') || label.contains('CDM')) _selectedRole = 'MIDFIELDER';
          else if (label.contains('PG') || label.contains('SG')) _selectedRole = 'GUARD';
          else if (label.contains('PF') || label.contains('SF')) _selectedRole = 'FORWARD';
          else if (label.contains('C')) _selectedRole = 'CENTER';
          
          _showSelectionSheet(index);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 65,
              height: 65,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: player != null ? appState.primaryColor : Colors.white10, width: 2),
                boxShadow: player != null ? [BoxShadow(color: appState.primaryColor.withOpacity(0.2), blurRadius: 10)] : [],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipOval(
                    child: player != null 
                      ? Image.network(
                          'https://api.dicebear.com/7.x/notionists/png?seed=${player['player_id']}', 
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(Icons.person, color: Colors.white24),
                        )
                      : Container(color: Colors.white.withOpacity(0.02)),
                  ),
                  if (player == null)
                    Text(positionLabel, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (player != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10), border: Border.all(color: appState.primaryColor.withOpacity(0.3))),
                  child: Column(
                    children: [
                      Text(player['name'].toString().split(' ').last.toUpperCase(), style: GoogleFonts.outfit(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                      Text('$positionLabel • IMP: ${85 + (player['player_id'] % 15)}', style: GoogleFonts.outfit(color: appState.primaryColor, fontSize: 6, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSelectionSheet(int pitchIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D0D0D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(builder: (context, setSheetState) {
            final filtered = _allPlayers.where((p) => _selectedRole == 'ALL' || p['role'] == _selectedRole).toList();
            return Column(
              children: [
                Text('SELECT ELITE LEGEND', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 15),
                _buildRoleSelector(onChanged: () => setSheetState(() {})),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final p = filtered[i];
                      final isPicked = _pitchPlayers.contains(p);
                      return ListTile(
                        onTap: isPicked ? null : () {
                          setState(() => _pitchPlayers[pitchIndex] = p);
                          Navigator.pop(context);
                        },
                        leading: CircleAvatar(
                          backgroundColor: Colors.white10,
                          child: ClipOval(
                            child: Image.network(
                              'https://api.dicebear.com/7.x/notionists/png?seed=${p['player_id']}',
                              errorBuilder: (c, e, s) => const Icon(Icons.person, color: Colors.white24),
                            ),
                          ),
                        ),
                        title: Text(p['name'], style: GoogleFonts.outfit(color: isPicked ? Colors.white24 : Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('${p['nationality']} • ${p['team_name']}', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('IMPACT', style: GoogleFonts.outfit(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold)),
                            Text('${85.0 + (p['player_id'] % 15)}.0', style: GoogleFonts.outfit(color: appState.primaryColor, fontSize: 14, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  Widget _buildSquadBench() {
    final filtered = _allPlayers.where((p) => _selectedRole == 'ALL' || p['role'] == _selectedRole).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AVAILABLE SCOUTS', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 20),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final p = filtered[i];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 15),
                decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 25, 
                      backgroundColor: Colors.white10,
                      child: ClipOval(
                        child: Image.network(
                          'https://api.dicebear.com/7.x/notionists/png?seed=${p['player_id']}',
                          errorBuilder: (c, e, s) => const Icon(Icons.person, color: Colors.white24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(p['name'].toString().split(' ').last, style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    Text('IMP: ${85 + (p['player_id'] % 15)}', style: GoogleFonts.outfit(color: appState.primaryColor, fontSize: 8, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PitchPainter extends CustomPainter {
  final Color primaryColor;
  final String sport;
  PitchPainter(this.primaryColor, this.sport);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = primaryColor.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 2.5;
    final fillPaint = Paint()..color = primaryColor.withOpacity(0.05)..style = PaintingStyle.fill;
    final name = sport.toUpperCase();
    
    if (name.contains('CRICKET')) {
      // Cricket Oval
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width/2, size.height/2), width: size.width - 20, height: size.height - 40), paint);
      // Inner Circle (30 yard)
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width/2, size.height/2), width: size.width * 0.6, height: size.height * 0.5), paint..strokeWidth = 1..color = Colors.white24);
      // Pitch Rectangle
      canvas.drawRect(Rect.fromCenter(center: Offset(size.width/2, size.height/2), width: 40, height: 120), fillPaint);
      canvas.drawRect(Rect.fromCenter(center: Offset(size.width/2, size.height/2), width: 40, height: 120), paint..strokeWidth=2);
      // Creases
      canvas.drawLine(Offset(size.width/2 - 20, size.height/2 - 45), Offset(size.width/2 + 20, size.height/2 - 45), paint);
      canvas.drawLine(Offset(size.width/2 - 20, size.height/2 + 45), Offset(size.width/2 + 20, size.height/2 + 45), paint);
    } else if (name.contains('BASKETBALL')) {
      // Full Basketball Court
      final rect = Rect.fromLTWH(20, 20, size.width - 40, size.height - 40);
      canvas.drawRect(rect, paint);
      canvas.drawLine(Offset(20, size.height/2), Offset(size.width - 20, size.height/2), paint);
      canvas.drawCircle(Offset(size.width/2, size.height/2), 50, paint);
      
      // Top Key & 3-Point
      canvas.drawRect(Rect.fromLTWH(size.width/2 - 60, 20, 120, 100), paint);
      canvas.drawArc(Rect.fromLTWH(20, 20, size.width - 40, 200), 0, 3.14159, false, paint);
      
      // Bottom Key & 3-Point
      canvas.drawRect(Rect.fromLTWH(size.width/2 - 60, size.height - 120, 120, 100), paint);
      canvas.drawArc(Rect.fromLTWH(20, size.height - 220, size.width - 40, 200), 3.14159, 3.14159, false, paint);
    } else if (name.contains('F1') || name.contains('MOTOGP')) {
      // Curved Race Track
      final path = Path()
        ..moveTo(size.width * 0.15, size.height * 0.15)
        ..cubicTo(size.width * 0.8, size.height * 0.05, size.width * 0.9, size.height * 0.3, size.width * 0.8, size.height * 0.45)
        ..cubicTo(size.width * 0.6, size.height * 0.6, size.width * 0.9, size.height * 0.7, size.width * 0.8, size.height * 0.85)
        ..cubicTo(size.width * 0.5, size.height * 0.95, size.width * 0.1, size.height * 0.9, size.width * 0.15, size.height * 0.6)
        ..cubicTo(size.width * 0.2, size.height * 0.4, size.width * 0.4, size.height * 0.5, size.width * 0.4, size.height * 0.3)
        ..cubicTo(size.width * 0.4, size.height * 0.15, size.width * 0.2, size.height * 0.1, size.width * 0.15, size.height * 0.15)
        ..close();
      canvas.drawPath(path, paint..strokeWidth = 30..color = primaryColor.withOpacity(0.1)); // Track width
      canvas.drawPath(path, Paint()..color = Colors.white.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 2); // Racing line
    } else if (name.contains('TENNIS') || name.contains('BADMINTON')) {
      // Net-Divided Court
      final rect = Rect.fromLTWH(40, 20, size.width - 80, size.height - 40);
      canvas.drawRect(rect, paint);
      // Net
      canvas.drawLine(Offset(20, size.height/2), Offset(size.width - 20, size.height/2), paint..color=primaryColor..strokeWidth=4);
      // Service lines
      canvas.drawLine(Offset(40, size.height * 0.25), Offset(size.width - 40, size.height * 0.25), paint..strokeWidth=2);
      canvas.drawLine(Offset(40, size.height * 0.75), Offset(size.width - 40, size.height * 0.75), paint);
      // Center line
      canvas.drawLine(Offset(size.width/2, size.height * 0.25), Offset(size.width/2, size.height * 0.75), paint);
    } else if (name.contains('SWIMMING')) {
      // Swimming Pool Lanes
      final rect = Rect.fromLTWH(20, 20, size.width - 40, size.height - 40);
      canvas.drawRect(rect, paint..color = Colors.blue.withOpacity(0.4)..style = PaintingStyle.fill);
      canvas.drawRect(rect, paint..style = PaintingStyle.stroke..color = Colors.cyan);
      for (int i = 1; i <= 7; i++) {
        double yPos = 20 + (i * (size.height - 40) / 8);
        canvas.drawLine(Offset(20, yPos), Offset(size.width - 20, yPos), paint..color = Colors.white38..strokeWidth = 2);
      }
    } else {
      // Default: Football / Hockey Pitch
      final rect = Rect.fromLTWH(20, 20, size.width - 40, size.height - 40);
      canvas.drawRect(rect, paint);
      canvas.drawLine(Offset(20, size.height/2), Offset(size.width - 20, size.height/2), paint);
      canvas.drawCircle(Offset(size.width/2, size.height/2), 60, paint);
      canvas.drawRect(Rect.fromLTWH(size.width/2 - 80, 20, 160, 90), paint);
      canvas.drawRect(Rect.fromLTWH(size.width/2 - 80, size.height - 110, 160, 90), paint);
      // Penalty arcs
      canvas.drawArc(Rect.fromLTWH(size.width/2 - 40, 90, 80, 40), 0, 3.14159, false, paint);
      canvas.drawArc(Rect.fromLTWH(size.width/2 - 40, size.height - 130, 80, 40), 3.14159, 3.14159, false, paint);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

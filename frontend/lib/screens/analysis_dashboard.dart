import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import 'player_detail_screen.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';

class AnalysisDashboard extends StatefulWidget {
  const AnalysisDashboard({super.key});

  @override
  State<AnalysisDashboard> createState() => _AnalysisDashboardState();
}

class _AnalysisDashboardState extends State<AnalysisDashboard> {
  String _selectedSport = 'Football';
  final List<String> _sports = ['Football', 'Cricket', 'F1', 'Tennis', 'Basketball', 'Badminton', 'Hockey', 'MotoGP', 'Swimming'];
  List<dynamic> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedSport = appState.selectedSportPreference;
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() => _isLoading = true);
    try {
      final sports = await ApiService.getSports();
      final sport = sports.firstWhere((s) => s['sport_name'].toString().toUpperCase() == _selectedSport.toUpperCase(), orElse: () => sports.first);
      final players = await ApiService.getPlayers(sportId: sport['sport_id']);
      
      final list = players.map((p) => {
        'id': p['player_id'],
        'name': p['name'],
        'score': 85 + (p['player_id'] % 15),
        'team': p['team_name']
      }).toList();
      
      list.sort((dynamic a, dynamic b) => (b['score'] as int).compareTo(a['score'] as int));
      
      setState(() {
        _leaderboard = list;
        _isLoading = false;
      });
    } catch (e) {
      print('Leaderboard error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPerformers = _leaderboard.take(3).toList();
    final restOfField = _leaderboard.skip(3).toList();

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
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              _buildSliverHeader(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildSportTabs(),
                      const SizedBox(height: 30),
                      if (!_isLoading) ...[
                        _buildPodiumArena(topPerformers),
                        const SizedBox(height: 40),
                        _buildManagementSection(),
                        const SizedBox(height: 40),
                        _buildLeaderboardList(restOfField),
                      ] else 
                        const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator())),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('GLOBAL LEADERSHIP', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 3)),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 24, bottom: 20),
      ),
    );
  }

  Widget _buildSportTabs() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _sports.length,
        itemBuilder: (context, i) {
          final s = _sports[i];
          final isSel = _selectedSport == s;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedSport = s);
              _fetchLeaderboard();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: isSel ? appState.primaryColor : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                boxShadow: isSel ? [BoxShadow(color: appState.primaryColor.withOpacity(0.3), blurRadius: 10)] : [],
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

  Widget _buildPodiumArena(List<dynamic> performers) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // perspective
        ..rotateX(-0.1), // slight tilt
      alignment: FractionalOffset.center,
      child: Container(
        height: 320,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A).withOpacity(0.8),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: appState.primaryColor.withOpacity(0.1),
              blurRadius: 50,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: MeshFloorPainter(appState.primaryColor),
              ),
            ),
            Positioned(
              left: -20, top: 20,
              child: Opacity(
                opacity: 0.6,
                child: Image.asset('assets/images/3d_graphics.png', height: 100),
              ),
            ),
            Positioned(
              right: -10, bottom: 40,
              child: Opacity(
                opacity: 0.4,
                child: Transform.rotate(
                  angle: 0.5,
                  child: Image.asset('assets/images/3d_graphics.png', height: 80),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (performers.length > 1) _buildPodiumMember(performers[1], 2, 100, const Color(0xFFBC13FE)),
                if (performers.length > 0) _buildPodiumMember(performers[0], 1, 140, appState.primaryColor),
                if (performers.length > 2) _buildPodiumMember(performers[2], 3, 70, const Color(0xFF00E5FF)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumMember(dynamic player, int rank, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => PlayerDetailScreen(playerId: player['id']))),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 15)],
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://api.dicebear.com/7.x/notionists/png?seed=${player['player_id']}', 
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Icon(Icons.person, color: color),
                  )
                ),
              ),
              Positioned(
                bottom: -5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                  child: Text('#$rank', style: GoogleFonts.outfit(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text(player['name'].toString().split(' ').last.toUpperCase(), style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 10),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withOpacity(0.1), color.withOpacity(0.3)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(player['score'].toString(), style: GoogleFonts.outfit(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
              Text('PTS', style: GoogleFonts.outfit(color: color.withOpacity(0.5), fontSize: 8, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardList(List<dynamic> field) {
    return Column(
      children: field.asMap().entries.map((entry) {
        final i = entry.key + 4;
        final p = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
            children: [
              Text(i < 10 ? '0$i' : '$i', style: GoogleFonts.outfit(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.w900)),
              const SizedBox(width: 20),
              Container(
                width: 45, height: 45,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white10)),
                child: ClipOval(
                  child: Image.network(
                    'https://api.dicebear.com/7.x/notionists/png?seed=${p['player_id']}', 
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(Icons.person, color: Colors.white24),
                  )
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['name'].toString().toUpperCase(), style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                    Text(p['team'] ?? 'ELITE SQUAD', style: GoogleFonts.outfit(color: appState.primaryColor, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
              ),
              Text(p['score'].toString(), style: GoogleFonts.outfit(color: appState.primaryColor, fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_forward_ios, color: Colors.white10, size: 12),
                ],
              ),
            ),
          ),
        ),
      ).animate().fade(duration: 400.ms, delay: (100 * entry.key).ms).slideX(begin: 0.1, end: 0);
    }).toList(),
    );
  }

  String _getSportBg() {
    final s = _selectedSport.toString().toUpperCase();
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

  Widget _buildManagementSection() {
    return Row(
      children: [
        Expanded(child: _buildActionCard('REGISTER ATHLETE', Icons.person_add_alt_1, const Color(0xFFBC13FE), _showAddPlayerDialog)),
        const SizedBox(width: 20),
        Expanded(child: _buildActionCard('EXPAND LEAGUE', Icons.add_chart_rounded, const Color(0xFF00E5FF), _showAddSportDialog)),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 15),
            Text(title, style: GoogleFonts.outfit(color: color, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  void _showAddPlayerDialog() {
    final nameCtrl = TextEditingController();
    final natCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('REGISTER NEW ATHLETE', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(nameCtrl, 'Full Name'),
            const SizedBox(height: 15),
            _buildTextField(natCtrl, 'Nationality'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBC13FE)),
            onPressed: () async {
              await ApiService.addPlayer({
                'name': nameCtrl.text,
                'nationality': natCtrl.text,
                'team_id': 1,
              });
              Navigator.pop(ctx);
              _fetchLeaderboard();
            },
            child: const Text('REGISTER'),
          ),
        ],
      ),
    );
  }

  void _showAddSportDialog() {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('EXPAND GLOBAL LEAGUE', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
        content: _buildTextField(nameCtrl, 'Sport Name (e.g. Golf)'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF)),
            onPressed: () async {
              await ApiService.addSport({
                'name': nameCtrl.text,
                'icon': 'sports_soccer'
              });
              Navigator.pop(ctx);
              _fetchLeaderboard(); // Fixed to call existing method
            },
            child: const Text('EXPAND'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white24),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
      ),
    );
  }
}

class MeshFloorPainter extends CustomPainter {
  final Color color;
  MeshFloorPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    final glowPaint = Paint()
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final double step = 25.0;
    
    // Vertical lines with perspective
    for (double i = 0; i <= size.width; i += step) {
      final xOffset = (i - size.width/2) * 0.5;
      canvas.drawLine(Offset(i, 0), Offset(i + xOffset, size.height), paint);
      canvas.drawLine(Offset(i, 0), Offset(i + xOffset, size.height), glowPaint);
    }
    
    // Horizontal lines with acceleration
    for (double i = 0; i <= size.height; i += step) {
      final ratio = i / size.height;
      final y = i * (1 + ratio * 0.5); // Accel toward bottom
      if (y > size.height) break;
      
      paint.color = color.withOpacity(0.02 + (ratio * 0.15));
      glowPaint.color = color.withOpacity(ratio * 0.05);
      
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

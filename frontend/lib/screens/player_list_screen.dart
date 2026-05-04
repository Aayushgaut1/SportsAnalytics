import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import 'player_detail_screen.dart';
import 'dart:ui';

class PlayerListScreen extends StatefulWidget {
  const PlayerListScreen({super.key});

  @override
  State<PlayerListScreen> createState() => _PlayerListScreenState();
}

class _PlayerListScreenState extends State<PlayerListScreen> {
  List<dynamic> _players = [];
  List<dynamic> _sports = [];
  String? _selectedSport;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    appState.addListener(_update);
  }

  void _update() => setState(() {});

  Future<void> _loadData() async {
    try {
      final sportsData = await ApiService.getSports();
      setState(() {
        _sports = sportsData;
        _selectedSport = appState.selectedSportPreference;
      });
      _fetchPlayers();
    } catch (e) {
      print('Error loading initial data: $e');
    }
  }

  Future<void> _fetchPlayers() async {
    setState(() => _isLoading = true);
    try {
      final sport = _sports.firstWhere((s) => s['sport_name'] == _selectedSport);
      final data = await ApiService.getPlayers(sportId: sport['sport_id']);
      setState(() {
        _players = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching players: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          if (_players.isNotEmpty) _buildHeroBackground(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildModernAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildSportFilter(),
                      const SizedBox(height: 20),
                      if (_isLoading) 
                        const Padding(padding: EdgeInsets.all(100), child: CircularProgressIndicator())
                      else 
                        _buildPlayerGrid(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBackground() {
    return Positioned(
      top: 0, right: 0, left: 0,
      height: 450,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [appState.primaryColor.withOpacity(0.2), Colors.black],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(_getSportBg(), fit: BoxFit.cover, key: ValueKey(_selectedSport)),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: HeaderMeshPainter(appState.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: HeaderMeshPainter(appState.primaryColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('PROFESSIONAL', style: GoogleFonts.outfit(color: appState.primaryColor, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 5)),
                  Text('LEGENDS', style: GoogleFonts.outfit(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: 2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportFilter() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _sports.length,
        itemBuilder: (context, i) {
          final s = _sports[i]['sport_name'];
          final isSel = _selectedSport == s;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedSport = s);
              _fetchPlayers();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              decoration: BoxDecoration(
                color: isSel ? appState.primaryColor : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
                boxShadow: isSel ? [BoxShadow(color: appState.primaryColor.withOpacity(0.4), blurRadius: 15)] : [],
              ),
              child: Center(
                child: Text(s.toUpperCase(), style: GoogleFonts.outfit(color: isSel ? Colors.black : Colors.white60, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayerGrid() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _players.length,
      itemBuilder: (context, i) {
        final p = _players[i];
        final sportName = _selectedSport ?? 'Sports';
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => PlayerDetailScreen(playerId: p['player_id']))),
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(color: appState.primaryColor.withOpacity(0.05), blurRadius: 20, spreadRadius: -10)
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                children: [
                  // CARD BACKGROUND IMAGE
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.7, // Increased from 0.4
                      child: Image.asset(
                        _getCardBg(sportName),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // GRADIENT OVERLAY
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.black.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        // PLAYER AVATAR
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: appState.primaryColor.withOpacity(0.3), width: 2),
                            boxShadow: [BoxShadow(color: appState.primaryColor.withOpacity(0.2), blurRadius: 15)],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              'https://api.dicebear.com/7.x/notionists/png?seed=${p['player_id']}',
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Icon(Icons.person, color: appState.primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(p['nationality'].toString().toUpperCase(), style: GoogleFonts.outfit(color: appState.primaryColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
                              const SizedBox(height: 5),
                              Text(p['name'], style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 5),
                              Text(p['team_name'] ?? 'Free Agent', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        _buildMiniStat('STR', '${80 + (p['player_id'] % 20)}'),
                        _buildMiniStat('SPD', '${75 + (p['player_id'] % 25)}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getCardBg(String sport) {
    final s = sport.toUpperCase();
    if (s.contains('FOOTBALL')) return 'assets/images/football_bg.jpg';
    if (s.contains('CRICKET')) return 'assets/images/cricket_bg.jpg';
    if (s.contains('F1')) return 'assets/images/f1_bg.jpg';
    if (s.contains('BASKETBALL')) return 'assets/images/basketball_bg.jpg';
    if (s.contains('HOCKEY')) return 'assets/images/hockey_bg.jpg';
    if (s.contains('SWIMMING')) return 'assets/images/swimming_bg.jpg';
    if (s.contains('TENNIS')) return 'assets/images/tennis_bg.jpg';
    if (s.contains('BADMINTON')) return 'assets/images/badminton_bg.jpg';
    if (s.contains('MOTOGP')) return 'assets/images/motogp_bg.jpg';
    return 'assets/images/sports_bg.jpg';
  }

  Widget _buildRankBadge(int rank) {
    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
      child: Center(
        child: Text('#$rank', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
class HeaderMeshPainter extends CustomPainter {
  final Color color;
  HeaderMeshPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.1)..style = PaintingStyle.stroke..strokeWidth = 1;
    for (var i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), paint);
    }
    for (var i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), paint);
    }
    // Add some glow circles
    final glowPaint = Paint()..color = color.withOpacity(0.05)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.3), 100, glowPaint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

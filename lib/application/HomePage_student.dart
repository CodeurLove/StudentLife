import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduria/application/clubs_page.dart';
import 'package:eduria/application/panneau_club.dart';
import 'package:eduria/application/init_admin_passwords.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final Color burgundy = const Color(0xFF8B2323);
  final Color darkBlue = const Color(0xFF3B448F);
  final Color lavenderBg = const Color(0xFFFFF3FE);
  final TextStyle juraBold =
      const TextStyle(fontFamily: 'Jura', fontWeight: FontWeight.bold);

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  String _firstname = '';
  List<Map<String, dynamic>> _myClubs = [];
  List<Map<String, dynamic>> _events = [];
  int _totalMembers = 0;
  String? _nextEvent;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = _auth.currentUser!.uid;

    // Charger le prénom
    final userDoc = await _db.collection('users').doc(uid).get();
    _firstname = userDoc.data()?['firstname'] ?? '';

    // Charger les clubs de l'étudiant
// Charger les clubs de l'étudiant
    final memberships = await _db
        .collection('memberships')
        .where('userId', isEqualTo: uid)
        .get();

    List<Map<String, dynamic>> clubs = [];
    for (var m in memberships.docs) {
      final memberClubId = m.data()['clubId'];

      // Chercher par le champ clubid (pas l'ID du document)
      final clubSnap = await _db
          .collection('clubs')
          .where('clubid', isEqualTo: memberClubId)
          .limit(1)
          .get();

      if (clubSnap.docs.isNotEmpty) {
        final clubData = clubSnap.docs.first.data();
        final membersSnap = await _db
            .collection('memberships')
            .where('clubId', isEqualTo: memberClubId)
            .get();
        clubs.add({
          ...clubData,
          'memberCount': membersSnap.docs.length,
        });
      }
    }

    // Charger les événements à venir
    final now = Timestamp.now();
    List<Map<String, dynamic>> events = [];

    if (clubs.isNotEmpty) {
      for (var club in clubs) {
        final eventsSnap = await _db
            .collection('events')
            .where('clubId', isEqualTo: club['clubId'])
            .where('eventDate', isGreaterThan: now)
            .orderBy('eventDate')
            .get();
        for (var e in eventsSnap.docs) {
          events.add(e.data());
        }
      }
      events.sort((a, b) =>
          (a['eventDate'] as Timestamp).compareTo(b['eventDate'] as Timestamp));
    }

    // Prochain événement
    String? nextEvent;
    if (events.isNotEmpty) {
      final date = (events.first['eventDate'] as Timestamp).toDate();
      nextEvent = "${date.day} ${_monthName(date.month)} ${date.year}";
    }

    setState(() {
      _myClubs = clubs;
      _events = events;
      _nextEvent = nextEvent;
    });
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc'
    ];
    return months[month];
  }

  String _getClubEmoji(String clubId) {
    const emojis = {
      'anglais': '🇬🇧',
      'finances': '💰',
      'juristes': '⚖️',
      'communication': '📡',
      'foot_garcon': '⚽',
      'foot_fille': '⚽',
      'arts_martiaux': '🥋',
      'atletisme': '🏃',
      'volley': '🏐',
      'basket': '🏀',
      'petanque': '🎯',
      'danse': '💃',
      'theatre': '🎭',
      'stylisme': '👗',
      'orchestre': '🎻',
      'musique': '🎵',
      'cartes': '🃏',
      'echecs': '♟️',
      'informatique': '💻',
    };
    return emojis[clubId] ?? '🏆';
  }

  String _daysUntil(Timestamp ts) {
    final diff = ts.toDate().difference(DateTime.now()).inDays;
    if (diff == 0) return "Aujourd'hui";
    return "Dans $diff Jours";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lavenderBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildStatsRow(),
              const SizedBox(height: 25),
              _buildMyClubs(),
              const SizedBox(height: 25),
              _buildEvents(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    // BOUTON TEMPORAIRE - à supprimer après utilisation
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: darkBlue.withOpacity(0.1),
          child: Icon(Icons.person, color: darkBlue, size: 30),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bienvenue $_firstname !",
                style: juraBold.copyWith(fontSize: 18, color: darkBlue)),
            Text("Ravis De Vous Revoir !",
                style: TextStyle(
                    fontFamily: 'Jura',
                    fontSize: 13,
                    color: darkBlue.withOpacity(0.5))),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: darkBlue.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: darkBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.group_outlined, color: darkBlue, size: 22),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tu Fait Partie De",
                        style: TextStyle(
                            fontFamily: 'Jura',
                            fontSize: 8,
                            color: darkBlue.withOpacity(0.5))),
                    Text("${_myClubs.length} Clubs",
                        style:
                            juraBold.copyWith(fontSize: 14, color: darkBlue)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: burgundy.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: burgundy.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.calendar_today_outlined,
                      color: burgundy, size: 22),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Prochain Even.",
                        style: TextStyle(
                            fontFamily: 'Jura',
                            fontSize: 7,
                            color: darkBlue.withOpacity(0.5))),
                    Text(_nextEvent ?? "Aucun",
                        style:
                            juraBold.copyWith(fontSize: 12, color: burgundy)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyClubs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Mes Clubs",
            style: juraBold.copyWith(fontSize: 18, color: darkBlue)),
        const SizedBox(height: 15),
        _myClubs.isEmpty
            ? _buildJoinClubButton()
            : Row(
                children: _myClubs
                    .map((club) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildClubCard(club),
                          ),
                        ))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildJoinClubButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ClubsPage()),
          );
          _loadData(); // Recharge les données au retour
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text("Intégrer un club",
            style: juraBold.copyWith(fontSize: 16, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: burgundy,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Widget _buildClubCard(Map<String, dynamic> club) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: darkBlue.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(_getClubEmoji(club['clubid'] ?? ''),
              style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(club['name'] ?? '',
              style: juraBold.copyWith(fontSize: 13, color: darkBlue),
              textAlign: TextAlign.center),
          Text("${club['memberCount']} Membres",
              style: TextStyle(
                  fontFamily: 'Jura',
                  fontSize: 11,
                  color: darkBlue.withOpacity(0.5))),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PanneauClubPage(
                      clubId: club['clubid'] ?? '',
                      clubName: club['name'] ?? '',
                      clubEmoji: _getClubEmoji(club['clubid'] ?? ''),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: burgundy,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Text("Voir",
                  style: juraBold.copyWith(fontSize: 13, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Évènements À Venir",
                style: juraBold.copyWith(fontSize: 18, color: darkBlue)),
            TextButton(
              onPressed: () {},
              child: Text("Voir Tout >",
                  style: juraBold.copyWith(fontSize: 13, color: burgundy)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _events.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "Pas d'évènements organisés pour l'instant",
                    style: TextStyle(
                        fontFamily: 'Jura',
                        color: darkBlue.withOpacity(0.4),
                        fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Column(
                children: _events
                    .take(3)
                    .map((event) => _buildEventCard(event))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final date = (event['eventDate'] as Timestamp).toDate();
    final Color cardColor = burgundy.withOpacity(0.08);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: darkBlue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Date
          Container(
            width: 45,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text("${date.day}",
                    style: juraBold.copyWith(fontSize: 18, color: burgundy)),
                Text(_monthName(date.month).toUpperCase(),
                    style: TextStyle(
                        fontFamily: 'Jura', fontSize: 10, color: burgundy)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event['title'] ?? '',
                    style: juraBold.copyWith(fontSize: 14, color: darkBlue)),
                if (event['location'] != null)
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 12, color: darkBlue.withOpacity(0.5)),
                      Text(event['location'],
                          style: TextStyle(
                              fontFamily: 'Jura',
                              fontSize: 11,
                              color: darkBlue.withOpacity(0.5))),
                    ],
                  ),
                if (event['time'] != null)
                  Row(
                    children: [
                      Icon(Icons.access_time_outlined,
                          size: 12, color: darkBlue.withOpacity(0.5)),
                      Text(event['time'],
                          style: TextStyle(
                              fontFamily: 'Jura',
                              fontSize: 11,
                              color: darkBlue.withOpacity(0.5))),
                    ],
                  ),
              ],
            ),
          ),
          // Badge jours restants
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _daysUntil(event['eventDate']) == "Aujourd'hui"
                  ? burgundy
                  : darkBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _daysUntil(event['eventDate']),
              style: juraBold.copyWith(
                  fontSize: 11,
                  color: _daysUntil(event['eventDate']) == "Aujourd'hui"
                      ? Colors.white
                      : darkBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: darkBlue.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.home_rounded, color: burgundy, size: 28)),
          IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClubsPage()),
                );
                _loadData(); // Recharge les données au retour
              },
              icon: Icon(Icons.search,
                  color: darkBlue.withOpacity(0.4), size: 26)),
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.explore_outlined,
                  color: darkBlue.withOpacity(0.4), size: 26)),
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications_outlined,
                  color: darkBlue.withOpacity(0.4), size: 26)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduria/application/clubs_page.dart';
import 'package:eduria/application/panneau_club.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final Color burgundy = const Color(0xFF8B2323);
  final Color darkBlue = const Color(0xFF3B448F);
  final Color lavenderBg = const Color(0xFFFFF3FE);
  final TextStyle juraBold =
      const TextStyle(fontFamily: 'Jura', fontWeight: FontWeight.bold);

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  String _firstname = '';
  String _adminClubId = ''; // le club dont il est admin
  List<Map<String, dynamic>> _myClubs = [];
  List<Map<String, dynamic>> _events = [];
  String? _nextEvent;
  bool _loading = true;

  final GlobalKey _menuKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = _auth.currentUser!.uid;

    final userDoc = await _db.collection('users').doc(uid).get();
    _firstname = userDoc.data()?['firstname'] ?? '';
    _adminClubId = userDoc.data()?['clubId'] ?? '';

    // Charger les clubs de l'admin (comme un étudiant)
    final memberships = await _db
        .collection('memberships')
        .where('userId', isEqualTo: uid)
        .get();

    List<Map<String, dynamic>> clubs = [];
    for (var m in memberships.docs) {
      final memberClubId = m.data()['clubId'];
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

    // Charger les événements de tous ses clubs
    final now = Timestamp.now();
    List<Map<String, dynamic>> events = [];
    for (var club in clubs) {
      final eventsSnap = await _db
          .collection('events')
          .where('clubId', isEqualTo: club['clubid'])
          .get();
      for (var e in eventsSnap.docs) {
        final data = e.data();
        if ((data['eventDate'] as Timestamp).compareTo(now) > 0) {
          events.add(data);
        }
      }
    }
    events.sort((a, b) =>
        (a['eventDate'] as Timestamp).compareTo(b['eventDate'] as Timestamp));

    String? nextEvent;
    if (events.isNotEmpty) {
      final date = (events.first['eventDate'] as Timestamp).toDate();
      nextEvent = "${date.day} ${_monthName(date.month)} ${date.year}";
    }

    setState(() {
      _myClubs = clubs;
      _events = events;
      _nextEvent = nextEvent;
      _loading = false;
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

  String _daysUntil(Timestamp ts) {
    final diff = ts.toDate().difference(DateTime.now()).inDays;
    if (diff == 0) return "Aujourd'hui";
    return "Dans $diff Jours";
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

  void _showAdminMenu() {
    final RenderBox button =
        _menuKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          onTap: () =>
              Future.delayed(Duration.zero, () => _showCreateEventDialog()),
          child: Row(children: [
            Icon(Icons.add_circle_outline, color: darkBlue, size: 20),
            const SizedBox(width: 10),
            Text("Créer un évènement",
                style: TextStyle(fontFamily: 'Jura', color: darkBlue)),
          ]),
        ),
        PopupMenuItem(
          onTap: () => Future.delayed(Duration.zero, () => _showMembersList()),
          child: Row(children: [
            Icon(Icons.people_outline, color: darkBlue, size: 20),
            const SizedBox(width: 10),
            Text("Liste des membres",
                style: TextStyle(fontFamily: 'Jura', color: darkBlue)),
          ]),
        ),
        PopupMenuItem(
          onTap: () =>
              Future.delayed(Duration.zero, () => _showDeleteEventDialog()),
          child: Row(children: [
            Icon(Icons.delete_outline, color: Colors.red, size: 20),
            const SizedBox(width: 10),
            Text("Supprimer un évènement",
                style: TextStyle(fontFamily: 'Jura', color: Colors.red)),
          ]),
        ),
        PopupMenuItem(
          onTap: () =>
              Future.delayed(Duration.zero, () => _showEditEventDialog()),
          child: Row(children: [
            Icon(Icons.edit_outlined, color: darkBlue, size: 20),
            const SizedBox(width: 10),
            Text("Modifier un évènement",
                style: TextStyle(fontFamily: 'Jura', color: darkBlue)),
          ]),
        ),
      ],
    );
  }

  void _showCreateEventDialog() {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final timeController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Créer un évènement",
              style: juraBold.copyWith(color: darkBlue)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(titleController, "Titre de l'évènement"),
                const SizedBox(height: 10),
                _dialogField(locationController, "Lieu"),
                const SizedBox(height: 10),
                _dialogField(timeController, "Heure (ex: 15h-17h)"),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null)
                      setStateDialog(() => selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: darkBlue.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: darkBlue, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          selectedDate != null
                              ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                              : "Choisir une date",
                          style: TextStyle(fontFamily: 'Jura', color: darkBlue),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler",
                  style: TextStyle(fontFamily: 'Jura', color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty || selectedDate == null)
                  return;
                final docRef = _db.collection('events').doc();
                await docRef.set({
                  'eventId': docRef.id,
                  'clubId': _adminClubId,
                  'title': titleController.text.trim(),
                  'location': locationController.text.trim(),
                  'time': timeController.text.trim(),
                  'eventDate': Timestamp.fromDate(selectedDate!),
                  'type': 'event',
                  'createdAt': Timestamp.now(),
                });
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("✅ Évènement créé !"),
                    backgroundColor: Colors.green));
              },
              style: ElevatedButton.styleFrom(backgroundColor: burgundy),
              child: Text("Créer",
                  style: juraBold.copyWith(color: Colors.white, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  void _showMembersList() async {
    final membersSnap = await _db
        .collection('memberships')
        .where('clubId', isEqualTo: _adminClubId)
        .get();

    List<Map<String, dynamic>> members = [];
    for (var m in membersSnap.docs) {
      final userDoc =
          await _db.collection('users').doc(m.data()['userId']).get();
      if (userDoc.exists) members.add(userDoc.data()!);
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            Text("Membres du club", style: juraBold.copyWith(color: darkBlue)),
        content: SizedBox(
          width: double.maxFinite,
          child: members.isEmpty
              ? Text("Aucun membre pour l'instant.",
                  style: TextStyle(fontFamily: 'Jura', color: darkBlue))
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: members.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: darkBlue.withOpacity(0.1)),
                  itemBuilder: (_, i) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: darkBlue.withOpacity(0.1),
                      child: Icon(Icons.person, color: darkBlue),
                    ),
                    title: Text(members[i]['firstname'] ?? '',
                        style: TextStyle(fontFamily: 'Jura', color: darkBlue)),
                    subtitle: Text(members[i]['email'] ?? '',
                        style: TextStyle(
                            fontFamily: 'Jura',
                            fontSize: 11,
                            color: darkBlue.withOpacity(0.5))),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Fermer",
                style: TextStyle(fontFamily: 'Jura', color: burgundy)),
          ),
        ],
      ),
    );
  }

  void _showDeleteEventDialog() async {
    final eventsSnap = await _db
        .collection('events')
        .where('clubId', isEqualTo: _adminClubId)
        .get();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Supprimer un évènement",
            style: juraBold.copyWith(color: Colors.red)),
        content: SizedBox(
          width: double.maxFinite,
          child: eventsSnap.docs.isEmpty
              ? Text("Aucun évènement.",
                  style: TextStyle(fontFamily: 'Jura', color: darkBlue))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: eventsSnap.docs.length,
                  itemBuilder: (_, i) {
                    final event = eventsSnap.docs[i].data();
                    return ListTile(
                      title: Text(event['title'] ?? '',
                          style:
                              TextStyle(fontFamily: 'Jura', color: darkBlue)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await eventsSnap.docs[i].reference.delete();
                          Navigator.pop(context);
                          _loadData();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("🗑️ Évènement supprimé"),
                                  backgroundColor: Colors.red));
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Fermer",
                style: TextStyle(fontFamily: 'Jura', color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showEditEventDialog() async {
    final eventsSnap = await _db
        .collection('events')
        .where('clubId', isEqualTo: _adminClubId)
        .get();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Modifier un évènement",
            style: juraBold.copyWith(color: darkBlue)),
        content: SizedBox(
          width: double.maxFinite,
          child: eventsSnap.docs.isEmpty
              ? Text("Aucun évènement.",
                  style: TextStyle(fontFamily: 'Jura', color: darkBlue))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: eventsSnap.docs.length,
                  itemBuilder: (_, i) {
                    final event = eventsSnap.docs[i].data();
                    return ListTile(
                      title: Text(event['title'] ?? '',
                          style:
                              TextStyle(fontFamily: 'Jura', color: darkBlue)),
                      trailing: Icon(Icons.edit, color: darkBlue, size: 20),
                      onTap: () {
                        Navigator.pop(context);
                        _showEditForm(eventsSnap.docs[i]);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Fermer",
                style: TextStyle(fontFamily: 'Jura', color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showEditForm(DocumentSnapshot doc) {
    final event = doc.data() as Map<String, dynamic>;
    final titleController = TextEditingController(text: event['title']);
    final locationController = TextEditingController(text: event['location']);
    final timeController = TextEditingController(text: event['time']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Modifier l'évènement",
            style: juraBold.copyWith(color: darkBlue)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(titleController, "Titre"),
            const SizedBox(height: 10),
            _dialogField(locationController, "Lieu"),
            const SizedBox(height: 10),
            _dialogField(timeController, "Heure"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler",
                style: TextStyle(fontFamily: 'Jura', color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await doc.reference.update({
                'title': titleController.text.trim(),
                'location': locationController.text.trim(),
                'time': timeController.text.trim(),
              });
              Navigator.pop(context);
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("✅ Évènement modifié !"),
                  backgroundColor: Colors.green));
            },
            style: ElevatedButton.styleFrom(backgroundColor: burgundy),
            child: Text("Enregistrer",
                style: juraBold.copyWith(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: TextStyle(fontFamily: 'Jura', color: darkBlue),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(fontFamily: 'Jura', color: darkBlue.withOpacity(0.4)),
        filled: true,
        fillColor: lavenderBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: darkBlue.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: darkBlue.withOpacity(0.2)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: lavenderBg,
        body: Center(child: CircularProgressIndicator(color: burgundy)),
      );
    }

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
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
        ),
        // Seule différence avec la page étudiant : bouton 3 points
        IconButton(
          key: _menuKey,
          onPressed: _showAdminMenu,
          icon: Icon(Icons.more_vert, color: darkBlue, size: 28),
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
            ? SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ClubsPage()),
                    );
                    _loadData();
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text("Intégrer un club",
                      style:
                          juraBold.copyWith(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: burgundy,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              )
            : Row(
                children: _myClubs.map((club) {
                  final isAdminClub = club['clubid'] == _adminClubId;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildClubCard(club, isAdminClub),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildClubCard(Map<String, dynamic> club, bool isAdminClub) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
            color: isAdminClub
                ? burgundy.withOpacity(0.4)
                : darkBlue.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(_getClubEmoji(club['clubid'] ?? ''),
              style: const TextStyle(fontSize: 38)),
          const SizedBox(height: 8),
          Text(club['name'] ?? '',
              style: juraBold.copyWith(fontSize: 12, color: darkBlue),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text("${club['memberCount']} Membres",
              style: TextStyle(
                  fontFamily: 'Jura',
                  fontSize: 11,
                  color: darkBlue.withOpacity(0.5))),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PanneauClubPage(
                    clubId: club['clubid'] ?? '',
                    clubName: club['name'] ?? '',
                    clubEmoji: _getClubEmoji(club['clubid'] ?? ''),
                    isAdmin: isAdminClub,
                  ),
                ),
              ),
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
          Container(
            width: 45,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: burgundy.withOpacity(0.08),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event['title'] ?? '',
                    style: juraBold.copyWith(fontSize: 14, color: darkBlue)),
                if (event['location'] != null &&
                    event['location'].toString().isNotEmpty)
                  Row(children: [
                    Icon(Icons.location_on_outlined,
                        size: 12, color: darkBlue.withOpacity(0.5)),
                    Text(event['location'],
                        style: TextStyle(
                            fontFamily: 'Jura',
                            fontSize: 11,
                            color: darkBlue.withOpacity(0.5))),
                  ]),
                if (event['time'] != null &&
                    event['time'].toString().isNotEmpty)
                  Row(children: [
                    Icon(Icons.access_time_outlined,
                        size: 12, color: darkBlue.withOpacity(0.5)),
                    Text(event['time'],
                        style: TextStyle(
                            fontFamily: 'Jura',
                            fontSize: 11,
                            color: darkBlue.withOpacity(0.5))),
                  ]),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: darkBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_daysUntil(event['eventDate']),
                style: juraBold.copyWith(fontSize: 11, color: darkBlue)),
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
                    context, MaterialPageRoute(builder: (_) => ClubsPage()));
                _loadData();
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

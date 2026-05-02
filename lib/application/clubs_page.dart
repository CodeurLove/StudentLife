import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClubsPage extends StatefulWidget {
  const ClubsPage({super.key});

  @override
  State<ClubsPage> createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  final Color burgundy = const Color(0xFF8B2323);
  final Color darkBlue = const Color(0xFF3B448F);
  final Color lavenderBg = const Color(0xFFFFF3FE);
  final TextStyle juraBold =
      const TextStyle(fontFamily: 'Jura', fontWeight: FontWeight.bold);

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String _selectedCategory = 'Tous';
  String _search = '';
  List<String> _myClubIds = [];
  bool _loadingMemberships = true;

  final List<Map<String, dynamic>> _allClubs = [
    {
      'clubId': 'anglais',
      'name': "Club d'Anglais",
      'category': 'Académie',
      'description': 'Perfectionnez votre anglais',
      'schedule': 'Mar, Jeu - 16h',
      'emoji': '🇬🇧'
    },
    {
      'clubId': 'finances',
      'name': 'Club Finances',
      'category': 'Académie',
      'description': 'Finance et économie',
      'schedule': 'Mer - 15h',
      'emoji': '💰'
    },
    {
      'clubId': 'juristes',
      'name': 'Club Juristes',
      'category': 'Académie',
      'description': 'Droit et justice',
      'schedule': 'Lun - 16h',
      'emoji': '⚖️'
    },
    {
      'clubId': 'communication',
      'name': 'Club Communication',
      'category': 'Académie',
      'description': 'Médias et communication',
      'schedule': 'Ven - 15h',
      'emoji': '📡'
    },
    {
      'clubId': 'foot_garcon',
      'name': 'Club Foot Garçons',
      'category': 'Sport',
      'description': 'Football masculin UCAO',
      'schedule': 'Mar, Ven - 17h',
      'emoji': '⚽'
    },
    {
      'clubId': 'foot_fille',
      'name': 'Club Foot Filles',
      'category': 'Sport',
      'description': 'Football féminin UCAO',
      'schedule': 'Mar, Ven - 17h',
      'emoji': '⚽'
    },
    {
      'clubId': 'arts_martiaux',
      'name': 'Arts Martiaux',
      'category': 'Sport',
      'description': 'Discipline et combat',
      'schedule': 'Lun, Mer - 17h',
      'emoji': '🥋'
    },
    {
      'clubId': 'atletisme',
      'name': 'Athlétisme',
      'category': 'Sport',
      'description': 'Course et performance',
      'schedule': 'Mer, Sam - 7h',
      'emoji': '🏃'
    },
    {
      'clubId': 'volley',
      'name': 'Volley Mixte',
      'category': 'Sport',
      'description': 'Volley-ball mixte UCAO',
      'schedule': 'Jeu, Sam - 16h',
      'emoji': '🏐'
    },
    {
      'clubId': 'basket',
      'name': 'Club De Basket',
      'category': 'Sport',
      'description': 'Passion, Esprit D\'équipe',
      'schedule': 'Jeu, Dim - 14h',
      'emoji': '🏀'
    },
    {
      'clubId': 'petanque',
      'name': 'Pétanque',
      'category': 'Sport',
      'description': 'Précision et stratégie',
      'schedule': 'Sam - 15h',
      'emoji': '🎯'
    },
    {
      'clubId': 'danse',
      'name': 'Club Danse',
      'category': 'Culture',
      'description': 'Expression et rythme',
      'schedule': 'Mer, Ven - 17h',
      'emoji': '💃'
    },
    {
      'clubId': 'theatre',
      'name': 'Théâtre',
      'category': 'Culture',
      'description': 'Art dramatique et scène',
      'schedule': 'Mar, Jeu - 17h',
      'emoji': '🎭'
    },
    {
      'clubId': 'stylisme',
      'name': 'Stylisme Modélisme',
      'category': 'Culture',
      'description': 'Mode et création',
      'schedule': 'Sam - 10h',
      'emoji': '👗'
    },
    {
      'clubId': 'orchestre',
      'name': 'Orchestre',
      'category': 'Culture',
      'description': 'Musique classique et moderne',
      'schedule': 'Mer - 17h',
      'emoji': '🎻'
    },
    {
      'clubId': 'musique',
      'name': 'Club Musique',
      'category': 'Culture',
      'description': 'Chant et instruments',
      'schedule': 'Ven - 17h',
      'emoji': '🎵'
    },
    {
      'clubId': 'cartes',
      'name': 'Club De Cartes',
      'category': 'Culture',
      'description': 'Stratégie et jeux de cartes',
      'schedule': 'Jeu - 16h',
      'emoji': '🃏'
    },
    {
      'clubId': 'Echecs',
      'name': 'Club D\'Echecs',
      'category': 'Culture',
      'description': 'Stratégie et jeux d\'échecs',
      'schedule': 'Lun - 16h',
      'emoji': '♟️'
    },
    {
      'clubId': 'informatique',
      'name': 'Club Informatique',
      'category': 'Académie',
      'description': 'Programmation et technologie',
      'schedule': 'Jeu - 17h',
      'emoji': '💻'
    },
    {
      'clubId': 'jeux_video',
      'name': 'Club de Jeux Vidéo',
      'category': 'Culture',
      'description': 'Jeux vidéo et gaming',
      'schedule': 'Sam - 15h',
      'emoji': '🎮'
    },
  ];

  final List<String> _categories = ['Tous', 'Sport', 'Culture', 'Académie'];

  @override
  void initState() {
    super.initState();
    _loadMyMemberships();
    _initClubsInFirestore();
  }

  Future<void> _initClubsInFirestore() async {
    for (var club in _allClubs) {
      final doc = await _db.collection('clubs').doc(club['clubid']).get();
      if (!doc.exists) {
        await _db.collection('clubs').doc(club['clubid']).set({
          'clubid': club['clubId'],
          'name': club['name'],
          'category': club['category'],
          'description': club['description'],
          'schedule': club['schedule'],
          'logoUrl': '',
          'adminUid': '',
          'responsableContact': '',
          'createdAt': Timestamp.now(),
        });
      }
    }
  }

  Future<void> _loadMyMemberships() async {
    final uid = _auth.currentUser!.uid;
    final snap = await _db
        .collection('memberships')
        .where('userId', isEqualTo: uid)
        .get();
    setState(() {
      _myClubIds = snap.docs.map((d) => d.data()['clubId'] as String).toList();
      _loadingMemberships = false;
    });
  }

  Future<void> _toggleMembership(String clubId) async {
    final uid = _auth.currentUser!.uid;

    if (_myClubIds.contains(clubId)) {
      // Se désinscrire
      final snap = await _db
          .collection('memberships')
          .where('userId', isEqualTo: uid)
          .where('clubId', isEqualTo: clubId)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        await _db.collection('memberships').doc(snap.docs.first.id).delete();
      }
      setState(() => _myClubIds.remove(clubId));
    } else {
      // Vérifier la limite de 2 clubs
      if (_myClubIds.length >= 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Vous ne pouvez rejoindre que 2 clubs maximum.",
                style: TextStyle(fontFamily: 'Jura')),
            backgroundColor: burgundy,
          ),
        );
        return;
      }
      // S'inscrire
      final docRef = _db.collection('memberships').doc();
      await docRef.set({
        'membershipId': docRef.id,
        'userId': uid,
        'clubId': clubId,
        'joinedAt': Timestamp.now(),
      });
      setState(() => _myClubIds.add(clubId));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Inscription réussie !",
              style: TextStyle(fontFamily: 'Jura')),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<int> _getMemberCount(String clubId) async {
    final snap = await _db
        .collection('memberships')
        .where('clubId', isEqualTo: clubId)
        .get();
    return snap.docs.length;
  }

  List<Map<String, dynamic>> get _filteredClubs {
    return _allClubs.where((club) {
      final matchCategory =
          _selectedCategory == 'Tous' || club['category'] == _selectedCategory;
      final matchSearch =
          club['name'].toString().toLowerCase().contains(_search.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lavenderBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Clubs",
                      style: juraBold.copyWith(fontSize: 28, color: darkBlue)),
                  Text("Découvrez Tous Les Clubs De UCAO",
                      style: TextStyle(
                          fontFamily: 'Jura',
                          fontSize: 13,
                          color: darkBlue.withOpacity(0.5))),
                  const SizedBox(height: 15),
                  // Barre de recherche
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: darkBlue.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search,
                            color: darkBlue.withOpacity(0.4), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (val) => setState(() => _search = val),
                            style:
                                TextStyle(fontFamily: 'Jura', color: darkBlue),
                            decoration: InputDecoration(
                              hintText: 'Rechercher Un Club...',
                              hintStyle: TextStyle(
                                  fontFamily: 'Jura',
                                  color: darkBlue.withOpacity(0.4),
                                  fontSize: 14),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Catégories
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final cat = _categories[i];
                        final selected = _selectedCategory == cat;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? burgundy : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: selected
                                      ? burgundy
                                      : darkBlue.withOpacity(0.2)),
                            ),
                            child: Text(cat,
                                style: juraBold.copyWith(
                                    fontSize: 13,
                                    color: selected ? Colors.white : darkBlue)),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            // Liste des clubs
            Expanded(
              child: _loadingMemberships
                  ? Center(child: CircularProgressIndicator(color: burgundy))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                      itemCount: _filteredClubs.length,
                      itemBuilder: (_, i) => _buildClubCard(_filteredClubs[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClubCard(Map<String, dynamic> club) {
    final clubId = club['clubId'] as String;
    final isInscrit = _myClubIds.contains(clubId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: darkBlue.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
              color: darkBlue.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          // Emoji / Logo
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: lavenderBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(club['emoji'] ?? '🏆',
                  style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 12),
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(club['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: juraBold.copyWith(fontSize: 14, color: darkBlue)),
                Text(club['description'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'Jura',
                        fontSize: 11,
                        color: darkBlue.withOpacity(0.5))),
                const SizedBox(height: 5),
                FutureBuilder<int>(
                  future: _getMemberCount(clubId),
                  builder: (_, snap) {
                    final count = snap.data ?? 0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.group_outlined,
                                size: 13, color: darkBlue.withOpacity(0.5)),
                            const SizedBox(width: 3),
                            Text("$count Membres",
                                style: TextStyle(
                                    fontFamily: 'Jura',
                                    fontSize: 11,
                                    color: darkBlue.withOpacity(0.5))),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.access_time_outlined,
                                size: 13, color: darkBlue.withOpacity(0.5)),
                            const SizedBox(width: 3),
                            Text(club['schedule'],
                                style: TextStyle(
                                    fontFamily: 'Jura',
                                    fontSize: 11,
                                    color: darkBlue.withOpacity(0.5))),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Bouton
          GestureDetector(
            onTap: () => _toggleMembership(clubId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isInscrit
                    ? Colors.green.withOpacity(0.1)
                    : darkBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isInscrit
                        ? Colors.green.withOpacity(0.3)
                        : darkBlue.withOpacity(0.15)),
              ),
              child: Text(
                isInscrit ? "Inscrit" : "S'inscrire",
                style: juraBold.copyWith(
                    fontSize: 12, color: isInscrit ? Colors.green : darkBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

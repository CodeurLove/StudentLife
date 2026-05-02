import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> initAdminPasswords() async {
  final db = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> adminPasswords = [
    {
      'docId': 'admin_anglais',
      'passwordHash': 'UCAO@Anglais2025',
      'label': "Admin Club d'Anglais",
      'clubId': 'anglais'
    },
    {
      'docId': 'admin_finances',
      'passwordHash': 'UCAO@Finance2025',
      'label': 'Admin Club Finances',
      'clubId': 'finances'
    },
    {
      'docId': 'admin_juristes',
      'passwordHash': 'UCAO@Juriste2025',
      'label': 'Admin Club Juristes',
      'clubId': 'juristes'
    },
    {
      'docId': 'admin_communication',
      'passwordHash': 'UCAO@Comm2025',
      'label': 'Admin Club Communication',
      'clubId': 'communication'
    },
    {
      'docId': 'admin_foot_garcon',
      'passwordHash': 'UCAO@FootG2025',
      'label': 'Admin Club Foot Garçons',
      'clubId': 'foot_garcon'
    },
    {
      'docId': 'admin_foot_fille',
      'passwordHash': 'UCAO@FootF2025',
      'label': 'Admin Club Foot Filles',
      'clubId': 'foot_fille'
    },
    {
      'docId': 'admin_arts_martiaux',
      'passwordHash': 'UCAO@Karate2025',
      'label': 'Admin Arts Martiaux',
      'clubId': 'arts_martiaux'
    },
    {
      'docId': 'admin_atletisme',
      'passwordHash': 'UCAO@Athle2025',
      'label': 'Admin Athlétisme',
      'clubId': 'atletisme'
    },
    {
      'docId': 'admin_volley',
      'passwordHash': 'UCAO@Volley2025',
      'label': 'Admin Volley Mixte',
      'clubId': 'volley'
    },
    {
      'docId': 'admin_basket',
      'passwordHash': 'UCAO@Basket2025',
      'label': 'Admin Club Basket',
      'clubId': 'basket'
    },
    {
      'docId': 'admin_petanque',
      'passwordHash': 'UCAO@Petanq2025',
      'label': 'Admin Pétanque',
      'clubId': 'petanque'
    },
    {
      'docId': 'admin_danse',
      'passwordHash': 'UCAO@Danse2025',
      'label': 'Admin Club Danse',
      'clubId': 'danse'
    },
    {
      'docId': 'admin_theatre',
      'passwordHash': 'UCAO@Theatre2025',
      'label': 'Admin Théâtre',
      'clubId': 'theatre'
    },
    {
      'docId': 'admin_stylisme',
      'passwordHash': 'UCAO@Style2025',
      'label': 'Admin Stylisme Modélisme',
      'clubId': 'stylisme'
    },
    {
      'docId': 'admin_orchestre',
      'passwordHash': 'UCAO@Orchest2025',
      'label': 'Admin Orchestre',
      'clubId': 'orchestre'
    },
    {
      'docId': 'admin_musique',
      'passwordHash': 'UCAO@Musique2025',
      'label': 'Admin Club Musique',
      'clubId': 'musique'
    },
    {
      'docId': 'admin_cartes',
      'passwordHash': 'UCAO@Cartes2025',
      'label': 'Admin Club De Cartes',
      'clubId': 'cartes'
    },
    {
      'docId': 'admin_echecs',
      'passwordHash': 'UCAO@Echecs2025',
      'label': 'Admin Club d’Échecs',
      'clubId': 'Echecs'
    },
    {
      'docId': 'admin_informatique',
      'passwordHash': 'UCAO@Info2025',
      'label': 'Admin Club Informatique',
      'clubId': 'informatique'
    },
  ];

  for (var admin in adminPasswords) {
    await db.collection('adminpassword').doc(admin['docId']).set({
      'docId': admin['docId'],
      'passwordHash': admin['passwordHash'],
      'label': admin['label'],
      'clubId': admin['clubId'],
      'createdAt': Timestamp.now(),
    });
    print('✅ Créé : ${admin['label']}');
  }

  print('🎉 Tous les mots de passe admin sont créés !');
}

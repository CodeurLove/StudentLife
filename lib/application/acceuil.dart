import 'package:flutter/material.dart'; // Import du package Flutter pour l'UI
import 'package:google_fonts/google_fonts.dart'; // Import pour utiliser des polices Google Fonts
import 'package:sidebarx/sidebarx.dart'; // Import du package SidebarX pour la barre latérale
import 'package:eduria/application/langue.dart'; // Import de la page de paramètres de langue
import 'package:flutter_locales/flutter_locales.dart'; // Import pour la gestion des langues/locales
import 'package:eduria/widget/propos.dart'; // Import de la page "À propos"

// Déclaration du widget principal de la page d'accueil
class HomePage extends StatefulWidget {
  const HomePage({super.key}); // Constructeur avec clé optionnelle

  @override
  State<HomePage> createState() =>
      _HomePageState(); // Création de l'état associé
}

// Classe d'état pour HomePage
class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // Permet d'utiliser un TabController
  late TabController _tabController; // Contrôleur pour les onglets (tabs)
  final _sidebarController = SidebarXController(
      selectedIndex: 0,
      extended:
          true); // Contrôleur pour la barre latérale, index initial à 0, étendue

  // Définition des couleurs utilisées dans l'application
  final Color primaryColor = const Color(0xFFA079FF); // Couleur principale
  final Color backgroundColor = const Color(0xFFF5F2FF); // Couleur de fond
  final Color textColor = const Color(0xFF3F3A54); // Couleur du texte principal

  int _lastSelectedIndex = 0; // Dernier index sélectionné dans la sidebar

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2,
        vsync: this); // Initialisation du contrôleur d'onglets avec 2 onglets

    // Ajout d'un écouteur sur la barre latérale pour gérer la navigation
    _sidebarController.addListener(() {
      final index =
          _sidebarController.selectedIndex; // Récupère l'index sélectionné

      if (index == _lastSelectedIndex)
        return; // Si l'index n'a pas changé, on ne fait rien

      _lastSelectedIndex = index; // Mise à jour de l'index sélectionné

      if (index < 2) {
        _tabController
            .animateTo(index); // Si l'index est 0 ou 1, on change d'onglet
      } else if (index == 2) {
        // Si l'index est 2, on ouvre la page des paramètres de langue
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LanguageSettingsPage()),
        ).then((_) {
          // Quand on revient, on remet la sélection sur l'onglet courant
          _sidebarController.selectIndex(_tabController.index);
          _lastSelectedIndex = _tabController.index;
        });
      } else if (index == 3) {
      } else if (index == 4) {
        // Si l'index est 4, on ouvre la page "À propos"
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const aboutPage()),
        ).then((_) {
          // Quand on revient, on remet la sélection sur l'onglet courant
          _sidebarController.selectIndex(_tabController.index);
          _lastSelectedIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // Libère les ressources du TabController
    _sidebarController.dispose(); // Libère les ressources du SidebarController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Structure principale de la page
      backgroundColor: backgroundColor, // Couleur de fond
      drawer: SidebarX(
        // Barre latérale de navigation
        controller: _sidebarController, // Contrôleur de la sidebar
        theme: SidebarXTheme(
          // Thème de la sidebar
          margin: const EdgeInsets.all(12), // Marge autour de la sidebar
          decoration: BoxDecoration(
            color: primaryColor, // Couleur de fond de la sidebar
            borderRadius: BorderRadius.circular(16), // Coins arrondis
          ),
          textStyle: GoogleFonts.poppins(
            color: Colors.white70, // Couleur du texte non sélectionné
            fontSize: 13,
          ),
          selectedTextStyle: GoogleFonts.poppins(
            color: Colors.black, // Couleur du texte sélectionné
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          selectedItemDecoration: BoxDecoration(
            color: Colors.white, // Fond de l'élément sélectionné
            borderRadius: BorderRadius.circular(10),
          ),
          iconTheme: const IconThemeData(
              color: Colors.white60, size: 18), // Icônes non sélectionnées
          selectedIconTheme: const IconThemeData(
              color: Colors.black, size: 18), // Icônes sélectionnées
          itemPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 10), // Espacement des éléments
        ),
        extendedTheme:
            const SidebarXTheme(width: 220), // Largeur de la sidebar étendue
        headerBuilder: (context, extended) =>
            const SizedBox(height: 100), // Espace en haut de la sidebar
        footerBuilder: (context, extended) => const Padding(
          // Pied de page de la sidebar
          padding: EdgeInsets.all(12.0),
          child: Text('© Eduria',
              style:
                  TextStyle(color: Colors.white38, fontSize: 11)), // Copyright
        ),
        items: [
          // Liste des éléments de la sidebar
          SidebarXItem(
            icon: Icons.home,
            label: Locales.string(context, 'home'), // Accueil
          ),
          SidebarXItem(
            icon: Icons.school,
            label: Locales.string(context, 'assessments'), // Évaluations
          ),
          SidebarXItem(
            icon: Icons.translate,
            label: Locales.string(context, 'language'), // Langue
          ),
          SidebarXItem(
            icon: Icons.logout,
            label: Locales.string(context, 'logout'), // Déconnexion
          ),
          SidebarXItem(
              icon: Icons.info,
              label: Locales.string(context, 'about')), // À propos
          SidebarXItem(
              icon: Icons.leaderboard,
              label: Locales.string(context, 'ranking')), // Classement
        ],
      ),
      appBar: AppBar(
        automaticallyImplyLeading: true, // Affiche le bouton menu si nécessaire
        backgroundColor: backgroundColor, // Couleur de fond de l'appbar
        elevation: 0, // Pas d'ombre sous l'appbar
        title: LocaleText(
          'welcome', // Titre localisé
          style: GoogleFonts.istokWeb(
            fontSize: 22,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController, // Contrôleur des onglets
          labelColor: primaryColor, // Couleur de l'onglet sélectionné
          unselectedLabelColor:
              textColor, // Couleur des onglets non sélectionnés
          indicatorColor: primaryColor, // Couleur de l'indicateur d'onglet
          tabs: [
            Tab(
                icon: const Icon(Icons.menu_book),
                child: Text(
                    Locales.string(context, 'coursesession'))), // Onglet cours
            const Tab(
                icon: Icon(Icons.edit_note),
                child: LocaleText('exercisesession')), // Onglet exercices
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController, // Contrôleur des vues d'onglets
        children: [
          _buildTabContent(
            icon: Icons.menu_book,
            title: Locales.string(context, 'learnatyourpace'),
            subtitle: Locales.string(context, 'importCourse'),
          ), // Contenu du premier onglet
          _buildTabContent(
            icon: Icons.edit_note,
            title: Locales.string(context, 'testknowledge'),
            subtitle: Locales.string(context, 'receiveexercises'),
          ), // Contenu du deuxième onglet
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Action lors du clic sur le bouton flottant
          final _formKey = GlobalKey<FormState>(); // Clé du formulaire
          final TextEditingController _nameController =
              TextEditingController(); // Contrôleur du champ nom
          final TextEditingController _descriptionController =
              TextEditingController(); // Contrôleur du champ description

          // Affiche une boîte de dialogue pour créer une session
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)), // Coins arrondis
                title: Center(
                  child: Text(
                    Locales.string(context, 'createsession'), // Titre localisé
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
                content: Form(
                  key: _formKey, // Clé du formulaire
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // Prend le moins de place possible
                    children: [
                      TextFormField(
                        controller: _nameController, // Contrôleur du nom
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.title), // Icône devant le champ
                          labelText: Locales.string(
                              context, 'sessionname'), // Label localisé
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Ce champ est requis'
                            : null, // Validation du champ
                      ),
                      const SizedBox(height: 15), // Espace vertical
                      TextFormField(
                        controller:
                            _descriptionController, // Contrôleur de la description
                        maxLines: 3, // Champ multi-lignes
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.description),
                          labelText:
                              Locales.string(context, 'sessiondescription'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Ce champ est requis'
                            : null, // Validation du champ
                      ),
                      const SizedBox(height: 25),
                      Align(
                        alignment: Alignment.centerRight, // Bouton à droite
                        child: TextButton.icon(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Si le formulaire est valide
                              // Traitement à ajouter ici (ex: création de la session)
                              Navigator.pop(
                                  context); // Ferme la boîte de dialogue
                            }
                          },
                          icon: const Icon(Icons.check), // Icône de validation
                          label: LocaleText('startsession'), // Texte localisé
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA079FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        label: LocaleText('createsession'), // Texte du bouton flottant
        icon: const Icon(Icons.add), // Icône du bouton flottant
        backgroundColor: primaryColor, // Couleur du bouton flottant
      ),
    );
  }

  // Méthode pour construire le contenu de chaque onglet
  Widget _buildTabContent(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 30.0), // Marge horizontale
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centrage vertical
          children: [
            Icon(icon, size: 80, color: textColor), // Icône principale
            const SizedBox(height: 20),
            Text(
              title, // Titre de l'onglet
              style: GoogleFonts.istokWeb(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle, // Sous-titre de l'onglet
              style: GoogleFonts.istokWeb(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

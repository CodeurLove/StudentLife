import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:eduria/application/langue.dart';
import 'package:flutter_locales/flutter_locales.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _sidebarController =
      SidebarXController(selectedIndex: 0, extended: true);

  final Color primaryColor = const Color(0xFFA079FF);
  final Color backgroundColor = const Color(0xFFF5F2FF);
  final Color textColor = const Color(0xFF3F3A54);

  int _lastSelectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _sidebarController.addListener(() {
      final index = _sidebarController.selectedIndex;

      if (index == _lastSelectedIndex) return;
      _lastSelectedIndex = index;

      if (index < 2) {
        _tabController.animateTo(index);
      } else if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LanguageSettingsPage()),
        ).then((_) {
          // Quand on revient depuis la page Langue, on remet l’index visuel sur la bonne tab
          _sidebarController.selectIndex(_tabController.index);
          _lastSelectedIndex = _tabController.index;
        });
      } else if (index == 3) {
        // TODO: Add logout logic
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sidebarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: SidebarX(
        controller: _sidebarController,
        theme: SidebarXTheme(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 13,
          ),
          selectedTextStyle: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          selectedItemDecoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          iconTheme: const IconThemeData(color: Colors.white60, size: 18),
          selectedIconTheme: const IconThemeData(color: Colors.black, size: 18),
          itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        extendedTheme: const SidebarXTheme(width: 220),
        headerBuilder: (context, extended) => const SizedBox(height: 100),
        footerBuilder: (context, extended) => const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text('© Eduria',
              style: TextStyle(color: Colors.white38, fontSize: 11)),
        ),
        items: [
          SidebarXItem(
            icon: Icons.home,
            label: Locales.string(context, 'home'),
          ),
          SidebarXItem(
            icon: Icons.school,
            label: Locales.string(context, 'assessments'),
          ),
          SidebarXItem(
            icon: Icons.translate,
            label: Locales.string(context, 'language'),
          ),
          SidebarXItem(
            icon: Icons.logout,
            label: Locales.string(context, 'logout'),
          ),
          SidebarXItem(
              icon: Icons.info, label: Locales.string(context, 'about')),
          SidebarXItem(
              icon: Icons.leaderboard,
              label: Locales.string(context, 'ranking')),
        ],
      ),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: backgroundColor,
        elevation: 0,
        title: LocaleText(
          'welcome',
          style: GoogleFonts.istokWeb(
            fontSize: 22,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: textColor,
          indicatorColor: primaryColor,
          tabs: [
            Tab(
                icon: const Icon(Icons.menu_book),
                child: Text(Locales.string(context, 'coursesession'))),
            const Tab(
                icon: Icon(Icons.edit_note),
                child: LocaleText('exercisesession')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent(
            icon: Icons.menu_book,
            title: Locales.string(context, 'learnatyourpace'),
            subtitle: Locales.string(context, 'importCourse'),
          ),
          _buildTabContent(
            icon: Icons.edit_note,
            title: Locales.string(context, 'testknowledge'),
            subtitle: Locales.string(context, 'receiveexercises'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final _formKey = GlobalKey<FormState>();
          final TextEditingController _nameController = TextEditingController();
          final TextEditingController _descriptionController =
              TextEditingController();

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Center(
                  child: Text(
                    Locales.string(context, 'createsession'),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
                content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.title),
                          labelText: Locales.string(context, 'sessionname'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Ce champ est requis'
                            : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.description),
                          labelText:
                              Locales.string(context, 'sessiondescription'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Ce champ est requis'
                            : null,
                      ),
                      const SizedBox(height: 25),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Traitement à ajouter ici
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Séance créée !')),
                              );
                            }
                          },
                          icon: const Icon(Icons.check),
                          label: LocaleText('startsession'),
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
        label: LocaleText('createsession'),
        icon: const Icon(Icons.add),
        backgroundColor: primaryColor,
      ),
    );
  }

  Widget _buildTabContent(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: textColor),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.istokWeb(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: GoogleFonts.istokWeb(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

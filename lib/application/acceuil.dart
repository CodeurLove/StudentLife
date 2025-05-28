import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:eduria/application/langue.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _sidebarController.addListener(() {
      final index = _sidebarController.selectedIndex;
      if (index < 2) {
        _tabController.animateTo(index);
      } else if (index == 2) {
        // Action paramètres
      } else if (index == 3) {
        // Action déconnexion
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Déconnexion...')),
        );
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
            color: const Color(0xFFA079FF),
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
        headerBuilder: (context, extended) {
          return Padding(
            padding: const EdgeInsets.all(38.0),
          );
        },
        footerBuilder: (context, extended) => const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            '© Eduria',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ),
        items: [
          SidebarXItem(
            icon: Icons.home,
            label: '  Home',
            onTap: () {
              _sidebarController.selectIndex(0);
            },
          ),
          SidebarXItem(
            icon: Icons.school,
            label: '  assessments',
            onTap: () {
              _sidebarController.selectIndex(1);
            },
          ),
          SidebarXItem(
            icon: Icons.translate,
            label: '  Language',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LanguageSettingsPage(),
                  ));
              //changeLanguage(context);
            },
          ),
          SidebarXItem(
            icon: Icons.logout,
            label: '  disconnects',
          ),
          SidebarXItem(
            icon: Icons.info,
            label: '  About',
          ),
          SidebarXItem(icon: Icons.leaderboard, label: '  ranking'),
        ],
      ),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Welcome to Eduria',
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
          tabs: const [
            Tab(icon: Icon(Icons.menu_book), text: 'Course session'),
            Tab(icon: Icon(Icons.edit_note), text: 'Exercise session'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent(
            icon: Icons.menu_book,
            title: 'Learn at your own pace',
            subtitle:
                'Import a course and the AI will explain it step by step.',
          ),
          _buildTabContent(
            icon: Icons.edit_note,
            title: 'Test your knowledge',
            subtitle: 'Receive tailored and corrected exercises.',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Action de création de séance
        },
        label: const Text('Create a new session'),
        icon: const Icon(Icons.add),
        backgroundColor: primaryColor,
      ),
    );
  }

  Widget _buildTabContent({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
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
              style: GoogleFonts.istokWeb(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

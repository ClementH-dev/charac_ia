import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../controller/universe_controller.dart';
import '../models/universe.dart';
import 'characters_list.dart';

class UniversListPage extends StatefulWidget {
  @override
  _UniversListPageState createState() => _UniversListPageState();
}

class _UniversListPageState extends State<UniversListPage> {
  final UniverseController controller = UniverseController();
  late Future<void> _fetchUniverses;
  bool _isCreatingUniverse = false;

  @override
  void initState() {
    super.initState();
    _fetchUniverses = controller.getAllUniverses();
  }

  void _showAddUniverseDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Text(
                'Créer un nouvel univers',
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nom',
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]!),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.orangeAccent),
                        ),
                      ),
                    ),
                    if (_isCreatingUniverse)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                                strokeWidth: 2.5,
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              'Création en cours...',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Annuler', style: TextStyle(color: Colors.white)),
                  onPressed: _isCreatingUniverse ? null : () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                  ),
                  child: Text('Créer', style: TextStyle(color: Colors.white)),
                  onPressed: _isCreatingUniverse
                      ? null
                      : () async {
                    final universeName = nameController.text.trim();

                    if (universeName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Le nom de l\'univers ne peut pas être vide')),
                      );
                      return;
                    }

                    // Activer l'indicateur de chargement
                    setState(() {
                      _isCreatingUniverse = true;
                    });

                    try {
                      await controller.createUniverse(universeName);

                      // Fermer le dialogue
                      Navigator.of(context).pop();

                      // Rafraîchir la liste des univers
                      this.setState(() {
                        _isCreatingUniverse = false;
                        _fetchUniverses = controller.getAllUniverses();
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Univers créé avec succès!')),
                      );
                    } catch (e) {
                      // Désactiver l'indicateur de chargement en cas d'erreur
                      setState(() {
                        _isCreatingUniverse = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur lors de la création de l\'univers: ${e.toString()}')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Univers'),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.orangeAccent),
            onPressed: _showAddUniverseDialog,
            tooltip: 'Ajouter un univers',
          ),
        ],
      ),
      body: FutureBuilder(
        future: _fetchUniverses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(child: Text(controller.errorMessage!));
          }

          final List<Universe> universes = controller.universes;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Choix dynamique du nombre de colonnes
                int crossAxisCount = constraints.maxWidth > 900
                    ? 4
                    : constraints.maxWidth > 600
                    ? 3
                    : 2;

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 3 / 2,
                  ),
                  itemCount: universes.length,
                  itemBuilder: (context, index) {
                    final universe = universes[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CharactersListPage(
                              universeName: universe.name,
                              universeId: universe.id,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.grey[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            universe.imageUrl != null
                                ? CachedNetworkImage(
                              imageUrl: universe.imageUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                color: Colors.black12,
                                child: Icon(Icons.broken_image, color: Colors.white),
                              ),
                            )
                                : Container(
                              color: Colors.black12,
                              child: Icon(Icons.image_not_supported, color: Colors.white),
                            ),
                            Container(
                              alignment: Alignment.bottomCenter,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                                ),
                              ),
                              child: Text(
                                universe.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      // Bouton flottant pour ajouter un univers (alternative au bouton dans l'AppBar)
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUniverseDialog,
        backgroundColor: Colors.orangeAccent,
        child: Icon(Icons.add),
        tooltip: 'Ajouter un univers',
      ),
    );
  }
}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:charac_ia/screens/chat.dart';
import 'package:flutter/material.dart';
import '../controller/character_controller.dart';
import '../models/character.dart';

class CharactersListPage extends StatefulWidget {
  final String universeName;
  final int universeId;

  CharactersListPage({
    required this.universeName,
    required this.universeId,
  });

  @override
  _CharactersListPageState createState() => _CharactersListPageState();
}

class _CharactersListPageState extends State<CharactersListPage> {
  final CharacterController controller = CharacterController();
  late Future<void> _fetchCharacters;
  bool _isCreatingChar = false;

  @override
  void initState() {
    super.initState();
    _fetchCharacters = controller.getCharactersByUniverse(widget.universeId)
        .then((_) => controller.loadUserConversations())
        .then((_) => controller.loadLastMessagesForConversations());
  }

  void _showAddCharacterDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
        context: context,
        builder: (BuildContext context){
          return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  backgroundColor: Colors.grey[900],
                  title: Text(
                    'Créer un nouveau personnage',
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
                            )
                          ),
                        ),
                        if(_isCreatingChar)
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
                        onPressed: _isCreatingChar ? null : () => Navigator.of(context).pop(),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                      ),
                      child: Text('Créer', style: TextStyle(color: Colors.white)),
                      onPressed: _isCreatingChar
                          ? null
                          : () async {
                        final characterName = nameController.text.trim();

                        if(characterName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Le nom du personnage ne peut pas être vide')),
                          );
                          return;
                        }

                        // Activer le chargement
                        setState(() {
                          _isCreatingChar = true;
                        });

                        try {
                          await controller.createCharacter(characterName, widget.universeId);

                          // Fermer le dialogue
                          Navigator.of(context).pop();

                          // Rafraichir la liste des personages
                          this.setState(() {
                            _isCreatingChar = false;
                            _fetchCharacters = controller.getCharactersByUniverse(widget.universeId);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Personnage créer avec succès!'))
                          );
                        } catch (e){
                          setState(() {
                            _isCreatingChar = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur lors de la création du personnage'))
                          );
                        }
                      },
                    )
                  ],
                );
              }
          );
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personnages de ${widget.universeName}'),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.orangeAccent),
            onPressed: _showAddCharacterDialog,
            tooltip: 'Ajouter un personnage',
          ),
        ],
      ),
      body: FutureBuilder(
        future: _fetchCharacters,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(child: Text(controller.errorMessage!));
          }

          final List<Character> characters = controller.characters;

          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: characters.length,
            separatorBuilder: (_, __) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              final character = characters[index];

              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                tileColor: Colors.grey[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[800],
                  child: ClipOval(
                    child: character.imageUrl != null
                        ? CachedNetworkImage(
                      imageUrl: character.imageUrl!,
                      width: 56, // 2 * radius
                      height: 56,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CircularProgressIndicator(strokeWidth: 2),
                      errorWidget: (context, url, error) => Icon(Icons.person, color: Colors.white),
                    )
                        : Icon(Icons.person, color: Colors.white),
                  ),
                ),
                title: Text(
                  character.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  controller.lastMessages[character.id]?.content ??
                      "Commencer une conversation avec ${character.name}",
                style: TextStyle(color: Colors.grey[400]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),


                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        characterName: character.name,
                        characterImage: character.image,
                        conversationId: character.conversationId,
                        characterId: character.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCharacterDialog,
        backgroundColor: Colors.orangeAccent,
        child: Icon(Icons.add),
        tooltip: 'Ajouter un personnage',
      ),
    );
  }
}

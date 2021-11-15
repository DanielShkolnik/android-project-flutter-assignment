import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'auth_repository.dart';
import 'database.dart';
import 'profile_bar.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthRepository.instance(),
      child:  App(),
    ),
  );
}


class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Scaffold(
            body: Center(
                child: Text(snapshot.error.toString(),
                    textDirection: TextDirection.ltr)));
      }
      if (snapshot.connectionState == ConnectionState.done) {
        return MyApp();
      }
      return Center(child: CircularProgressIndicator());
        },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //final wordPair = WordPair.random(); // Add this line.
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.black,
        ),
      ),
      home: RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  //final _suggestions = generateWordPairs().take(10).toList();
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18);

  final ScrollController listViewController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthRepository> (builder: (context, auth, child)
    {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Startup Name Generator'),
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: _pushSaved,
              tooltip: 'Saved Suggestions',
            ),
            IconButton(
              icon: auth.status == Status.Authenticated ? const Icon(
                  Icons.exit_to_app) : const Icon(
                  Icons.login),
              onPressed: auth.status == Status.Authenticated ? _pushLogout  : _pushLogin,
              tooltip: 'Saved Suggestions',
            ),
          ],
        ),
          body: Stack(
            children: (Provider.of<AuthRepository>(context, listen: false).status == Status.Authenticated) ? [_buildSuggestions(), _buildSnappingSheet()] : [_buildSuggestions()],
          ),
      );
    });
  }


  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.star : Icons.star,
        color: alreadySaved ? Colors.yellow : null,
        semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
            DatabaseService().removeSavedSuggestions(Provider.of<AuthRepository>(context, listen: false).user?.uid, pair);
          } else {
            _saved.add(pair);
            DatabaseService().updateSavedSuggestions(Provider.of<AuthRepository>(context, listen: false).user?.uid, _saved.toList());
          }
        });
      },
    );
  }

  Widget _buildSuggestions()  {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return const Divider();
          }
          final int index = i ~/ 2;

          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }

          return _buildRow(_suggestions[index]);
        }
    );
  }

  Widget _buildSnappingSheet()  {
    return SnappingSheetWidget(Provider.of<AuthRepository>(context, listen: false).user?.email, Provider.of<AuthRepository>(context, listen: false).user?.uid);
  }


  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _saved.map(
                (pair) {
                  return Dismissible(
                      key: Key(pair.asPascalCase),
                      child: ListTile(
                        title: Text(
                          pair.asPascalCase,
                          style: _biggerFont,
                        ),
                      ),
                      background: Container(
                        color: Colors.deepPurple,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: const [
                              Icon(Icons.delete, color: Colors.white),
                              Text('Delete Suggestion', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      confirmDismiss: (DismissDirection direction) async {
                        return showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Delete Suggestion'),
                              content: Text('Are you sure you want to delete $pair from your saved suggestions?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: (){
                                    setState(() {
                                      _saved.remove(pair);
                                      DatabaseService().removeSavedSuggestions(Provider.of<AuthRepository>(context, listen: false).user?.uid, pair);
                                    });
                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                        );
                      }
                  );
                });
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  void _pushLogin() {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => LoginScreen()) ).then((value) => setState((){
            DatabaseService().pushSavedSuggestionsFromCloud(Provider.of<AuthRepository>(context, listen: false).user?.uid, _suggestions, _saved, value);
            DatabaseService().updateSavedSuggestions(Provider.of<AuthRepository>(context, listen: false).user?.uid, _saved.toList());
          }));
  }

  void _pushLogout() {
    AuthRepository.instance().signOut();
    const snackBar = SnackBar(content: Text('Successfully logged out'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    _saved.clear();
  }

}



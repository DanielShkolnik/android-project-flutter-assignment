import 'package:english_words/english_words.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DatabaseService{

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  void updateSavedSuggestions(String? userID, List<WordPair> saved){
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    if(userID != null){
      users.doc(userID).update({"saved_suggestions": FieldValue.arrayUnion(saved.map((e) => "${e.first}_${e.second}").toList())});
    }
  }


  void removeSavedSuggestions(String? userID, WordPair pair){
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    if(userID != null){
      users.doc(userID).update({"saved_suggestions": FieldValue.arrayRemove(["${pair.first}_${pair.second}"])});
    }
  }

/*
  void syncSavedSuggestions(String? userID, List<WordPair> suggestions, Set<WordPair> saved) async{
    DocumentSnapshot snapshot = await users.doc(userID).get();
    List savedSuggestions;
    if(snapshot.data != null){
      try{
        savedSuggestions = snapshot["saved_suggestions"];
        List<WordPair> savedList = savedSuggestions.map((e) => WordPair(e.split("_")[0], e.split("_")[1])).toList();
        saved.addAll(savedList);
        savedList.forEach((element) {
          if(!suggestions.contains(element)){
            suggestions.insert(0, element);
          }
        });
      }
      on StateError catch (_) {
        users.doc(userID).set({"saved_suggestions": FieldValue.arrayUnion([])});
      }
    }
    DatabaseService().updateSavedSuggestions(userID, saved.toList());
  }
*/

  Future<List<WordPair>> pullSavedSuggestionsFromCloud(String? userID) async{
    DocumentSnapshot snapshot = await users.doc(userID).get();
    List savedSuggestions;
    if(snapshot.data != null){
      try{
        savedSuggestions = snapshot["saved_suggestions"];
        return savedSuggestions.map((e) => WordPair(e.split("_")[0], e.split("_")[1])).toList();
          }
      on StateError catch (_) {
        users.doc(userID).set({"saved_suggestions": FieldValue.arrayUnion([])});
      }
    }
    return [];
  }

  void pushSavedSuggestionsFromCloud(String? userID, List<WordPair> suggestions, Set<WordPair> saved, List<WordPair> savedListFromCloud) async{

      saved.addAll(savedListFromCloud);
      savedListFromCloud.forEach((element) {
        if(!suggestions.contains(element)){
          suggestions.insert(0, element);
        }
      });

    DatabaseService().updateSavedSuggestions(userID, saved.toList());
  }

}

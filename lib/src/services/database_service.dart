import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<void> saveData(String path, Map<String, dynamic> data) async {
    await _dbRef.child(path).push().set(data);
  }

  Future<void> updateData(String path, Map<String, dynamic> data) async {
    await _dbRef.child(path).update(data);
  }

  Future<void> deleteData(String path) async {
    await _dbRef.child(path).remove();
  }

  DatabaseReference getDataStream(String path) {
    return _dbRef.child(path);
  }

  // get all items under a path
  Future<DataSnapshot> getDataList(String path) async {
    return await _dbRef.child(path).get();
  }

  // get a single item under a path
  Future<DataSnapshot> getData(String path) async {
    return await _dbRef.child(path).get();
  }
}

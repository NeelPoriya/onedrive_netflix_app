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

  // delete data with filter
  Future<void> deleteDataWithFilter(
      String path, String key, dynamic value) async {
    await _dbRef
        .child(path)
        .orderByChild(key)
        .equalTo(value)
        .get()
        .then((snapshot) {
      (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
        _dbRef.child(path).child(key).remove();
      });
    });
  }

  DatabaseReference getDataStream(String path) {
    return _dbRef.child(path);
  }

  // get data stream with filter
  Query getDataStreamWithFilter(String path, String key, dynamic value) {
    return _dbRef.child(path).orderByChild(key).equalTo(value);
  }

  // get all items under a path
  Future<DataSnapshot> getDataList(String path) async {
    return await _dbRef.child(path).get();
  }

  // get a single item under a path
  Future<DataSnapshot> getData(String path) async {
    return await _dbRef.child(path).get();
  }

  // get item with filter
  Future<DataSnapshot> getDataWithFilter(
      String path, String key, dynamic value) async {
    return await _dbRef.child(path).orderByChild(key).equalTo(value).get();
  }
}

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue,
    ),
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _ch = false;
  String _title = "";
  String _code = "";

  showcontent(message) {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Hello'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: [
                new Text(message),
              ],
            ),
          ),
          actions: [
            new FlatButton(
              child: new Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  createData() {
    if (_title != "") {
      final now = new DateTime.now();
      String docName = (int.parse(DateFormat('H').format(now)) +
              int.parse(DateFormat('m').format(now)) +
              int.parse(DateFormat('s').format(now)) +
              int.parse(DateFormat('d').format(now)) +
              int.parse(DateFormat('M').format(now)) +
              int.parse(DateFormat('y').format(now)))
          .toString();
      DocumentReference documentReference =
          Firestore.instance.collection(("tasks")).document(docName);
      Map<String, dynamic> task = {"title": _title, "isFinished": _ch};
      documentReference.setData(task).whenComplete(() {
        showcontent("Created !!!");
      });
    }
  }

//  Future<bool> readData(docName) async {
//    await Firestore.instance
//        .collection('tasks')
//        .where("document_id", isEqualTo: docName)
//        .getDocuments()
//        .then((event) {
//      if (event.documents.isNotEmpty) {
////        Map<String, dynamic> documentData = event.documents.single.data;//if it is a single document
//        return true;
//      } else {
//        return false;
//      }
//    }).catchError((e) => print("error fetching data: $e"));

//  }

  updateData(docName) async {


    if (docName != "") {
      DocumentReference documentReference =
      Firestore.instance.collection(("tasks")).document(docName);
      documentReference.get().then((data) {
        try {
          if(data.data['title']!="")
          {
            DocumentReference documentReference =
            Firestore.instance.collection(("tasks")).document(docName);
            Map<String, dynamic> task = {"title": _title, "isFinished": _ch};
            documentReference.setData(task).whenComplete(() {
              showcontent("Updated !!!");
            });
          }
        } catch (e) {
          showcontent("Not Valid Code !!!");
        }
      });
    }


  }

  deleteData(docName) {
    if (docName != "") {
      DocumentReference documentReference =
          Firestore.instance.collection(("tasks")).document(docName);
      documentReference.get().then((data) {
        try {
          if(data.data['title']!="")
            {
              DocumentReference documentReference =
              Firestore.instance.collection(("tasks")).document(docName);
              documentReference.delete().whenComplete(() {
                showcontent("Deleted !!!");
              });
            }
        } catch (e) {
          showcontent("Not Valid Code !!!");
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ToDo"),
      ),
      body: ListView(children: <Widget>[
        Padding(
          padding: EdgeInsets.all(16.0),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: "Title",
              fillColor: Colors.white,
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0)),
            ),
            onChanged: (String name) {
              setState(() {
                _title = name;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center, //Center Row contents horizontally,
          children: <Widget>[
            Text('Task is Finished'),
            Radio(
              value: true,
              groupValue: _ch,
              onChanged: (bool value) {
                setState(() {
                  _ch = value;
                });
              },
            ),
            Text("Task isn't Finished"),
            Radio(
              value: false,
              groupValue: _ch,
              onChanged: (bool value) {
                setState(() {
                  _ch = value;
                });
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center, //Center Row contents horizontally,
          children: <Widget>[
            RaisedButton(
              child: Text(
                'Create',
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.green,
              onPressed: () {
                createData();
              },
            ),
            SizedBox(
              width: 15,
            ),
            RaisedButton(
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.red,
                onPressed: () {
                  deleteData(_code);
                }),
          ],
        ),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center, //Center Row contents horizontally,
          children: <Widget>[
            RaisedButton(
              child: Text(
                'Update',
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.orange,
              onPressed: () {
                updateData(_code);
              },
            ),
            SizedBox(
              width: 15,
            ),
//            RaisedButton(
//              child: Text(
//                'Read',
//                style: TextStyle(color: Colors.white),
//              ),
//              color: Colors.blue,
//              onPressed: () {
//                readData(_code);
//              },
//            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text("code"),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text("Title"),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text("is Finished"),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        StreamBuilder(
          stream: Firestore.instance.collection("tasks").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot documentSnap =
                        snapshot.data.documents[index];
                    return Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Text(documentSnap.documentID.toString()),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Text(documentSnap["title"]),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Text(documentSnap["isFinished"].toString()),
                          ),
                        ),
                      ],
                    );
                  });
            } else {
              return Align(
                child: CircularProgressIndicator(),
                alignment: FractionalOffset.bottomCenter,
              );
            }
          },
        ),
        SizedBox(
          height: 80,
        ),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: "Enter Code for Delete / Update ",
              fillColor: Colors.white,
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0)),
            ),
            onChanged: (String code) {
              setState(() {
                _code = code;
              });
            },
          ),
        ),
      ]),
    );
  }
}

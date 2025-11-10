import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

// Assuming these are your project's constant and DB files.
// Make sure the import paths are correct for your project structure.
import '../../../constants.dart';
import '../categoryDB.dart';
import '../categoryDBModel.dart';

class Download extends StatefulWidget {
  @override
  State<Download> createState() => _DownloadState();
}

class _DownloadState extends State<Download> {
  DB db = DB();
  List<CategoryModel> data = [];
  bool fetchingData = true;

  @override
  void initState() {
    // It's good practice to call super.initState() first.
    super.initState();
    db = DB();
    // Moved getData() call here to ensure it runs once when the widget is initialized.
    getData();
  }

  Future<void> getData() async {
    // You don't need to return the data here, just update the state.
    var fetchedData = await db.getData();
    // Using Timer is a way to simulate delay, but for real data fetching,
    // you can just setState directly after getting the data.
    if (mounted) { // Check if the widget is still in the tree
      setState(() {
        data = fetchedData;
        fetchingData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kLightGold,
      // Using a simple check for fetchingData at the top level simplifies the widget tree.
      body: fetchingData
          ? Center(child: CircularProgressIndicator())
          : data.isEmpty
          ? Center(
        child: Text(
          "Downloaded Images Empty".toUpperCase(),
          style: TextStyle(
              color: kTerracotta, fontStyle: FontStyle.italic),
        ),
      )
          : GridView.count(
        padding: EdgeInsets.all(6),
        crossAxisSpacing: 10,
        mainAxisSpacing: 7,
        crossAxisCount: 2,
        // This makes the grid items taller, which can also help prevent overflow
        // by giving the content more space to begin with. Adjust as needed.
        childAspectRatio: (size.width / 2) / (size.height / 2.5),
        children: List.generate(data.length, (index) {
          final url = data[index];
          // WRAP THE COLUMN WITH SingleChildScrollView TO FIX THE OVERFLOW
          return SingleChildScrollView(
            child: Column(
              children: [
                Image.file(
                  File(url.url),
                  fit: BoxFit.cover,
                  height: size.height * 17.2 / 100,
                  width: double.infinity,
                  errorBuilder: (BuildContext context,
                      Object exception, StackTrace? stackTrace) {
                    return SizedBox(
                      height: size.height * 17.2 / 100,
                      child: Center(
                        child: Icon(
                          Icons.error,
                          size: 40,
                          color: kGold,
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  // The height here is maintained, but if it overflows, the parent
                  // SingleChildScrollView will handle it.
                  height: size.height * 10 / 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kGold,
                  ),
                  // Using a SizedBox to ensure the button fills the container
                  child: SizedBox.expand(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, // Inherit color from container
                        shadowColor: Colors.transparent, // No shadow
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero), // Sharp corners
                      ),
                      child: Text("Delete",
                          style: TextStyle(
                              color: kDarkBrown,
                              fontStyle: FontStyle.italic)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: kWhite,
                            title: Row(
                              children: [
                                Icon(Icons.delete, color: kBrown),
                                Text("\tDelete",
                                    style: TextStyle(color: kBrown)),
                              ],
                            ),
                            content: Text(
                                "This image will be permanently deleted.",
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: kTerracotta)),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                                child: Text("Cancel",
                                    style: TextStyle(color: kBrown)),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  deleteCategory(index);
                                  // Pop the dialog
                                  Navigator.of(ctx).pop();
                                },
                                child: Text("Delete",
                                    style: TextStyle(color: kBrown)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void deleteCategory(int index) async {
    // It's good practice to handle potential errors.
    try {
      await db.deleteData(data[index].id!!);
      if (mounted) {
        setState(() {
          data.removeAt(index);
        });
      }
    } catch (e) {
      // Handle or log the error appropriately
      print("Error deleting data: $e");
    }
  }
}

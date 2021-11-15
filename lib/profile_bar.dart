import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'firebase_api.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'dart:ui';




class Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Placeholder(
        color: Colors.green[200]!,
      ),
    );
  }
}



class GrabbingWidget extends StatelessWidget {
  String? email;

  GrabbingWidget(String? email, {Key? key}): email = email, super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(blurRadius: 25, color: Colors.black.withOpacity(0.2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0, top: 8, right: 10, bottom: 8),
              child: Text("Welcome back, ${this.email}", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black)),
            ),
          ),
          Expanded(flex: 2, child: IconButton(icon: Icon(Icons.keyboard_arrow_up, color: Colors.black), onPressed: () {},)),
        ],
      ),
    );
  }
}


class SnappingSheetWidget extends StatefulWidget {
  String? email;
  String? uid;

  SnappingSheetWidget(String? email, String? uid, {Key? key}) : email = email, uid = uid, super(key: key);

  @override
  _SnappingSheetWidgetState createState() => _SnappingSheetWidgetState(this.email, this.uid);
}

class _SnappingSheetWidgetState extends State<SnappingSheetWidget> {
  String? email;
  String? uid;
  SnappingSheetController snappingSheetController = SnappingSheetController();
  bool isBlur = false;

  _SnappingSheetWidgetState(String? email, String? uid) : email = email, uid = uid;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: (this.isBlur == true) ? 5.0 : 0,
        sigmaY: (this.isBlur == true) ? 5.0 : 0,
      ),
      child: SnappingSheet(
        //child: Background(),
        controller: this.snappingSheetController,
        lockOverflowDrag: true,
        onSheetMoved: (sheetPositionData) {
          if(sheetPositionData.pixels <=  40){
            setState(() {
              this.isBlur = false;
            });
            }
          else{
            setState(() {
              this.isBlur = true;
            });
          }
        },
        snappingPositions: [
          SnappingPosition.factor(
            positionFactor: 0.0,
            snappingCurve: Curves.easeOutExpo,
            snappingDuration: Duration(seconds: 1),
            grabbingContentOffset: GrabbingContentOffset.top,
          ),
          SnappingPosition.factor(
            snappingCurve: Curves.elasticOut,
            snappingDuration: Duration(milliseconds: 1750),
            positionFactor: 0.25,
          ),
          SnappingPosition.factor(
            grabbingContentOffset: GrabbingContentOffset.bottom,
            snappingCurve: Curves.easeInExpo,
            snappingDuration: Duration(seconds: 1),
            positionFactor: 1,
          ),
        ],
        grabbing: GestureDetector(child: GrabbingWidget(this.email), onTap: (){
          if (this.snappingSheetController.currentSnappingPosition.grabbingContentOffset !=  GrabbingContentOffset.top){
            this.snappingSheetController.snapToPosition(SnappingPosition.factor(
              positionFactor: 0.0,
              snappingCurve: Curves.easeOutExpo,
              snappingDuration: Duration(seconds: 1),
              grabbingContentOffset: GrabbingContentOffset.top,
            ));
          }
          else{
            this.snappingSheetController.snapToPosition(SnappingPosition.factor(
              snappingCurve: Curves.elasticOut,
              snappingDuration: Duration(milliseconds: 1750),
              positionFactor: 0.25,
            ));
          }
          },),
        grabbingHeight: 75,
        sheetAbove: null,
        sheetBelow: SnappingSheetContent(
          draggable: true,
          //childScrollController: listViewController,
          child: SnappingSheetContentWidget(this.email, this.uid),
        ),
      ),
    );
  }
}





class SnappingSheetContentWidget extends StatefulWidget {
  String? email;
  String? uid;
  SnappingSheetContentWidget(String? email, String? uid, {Key? key}): email = email, uid = uid, super(key: key);

  @override
  _SnappingSheetContentWidgetState createState() => _SnappingSheetContentWidgetState(this.email, this.uid);
}

class _SnappingSheetContentWidgetState extends State<SnappingSheetContentWidget> {
  String? email;
  File? file;
  String? uid;

  _SnappingSheetContentWidgetState(String? email,  String? uid): email = email, uid = uid;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Row(children: [
            Column(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                backgroundColor: Colors.deepPurple,
                radius: 50,
                child: FutureBuilder(
                  future: downloadFile(),
                  builder: (context, AsyncSnapshot<dynamic> snapShot) {
                    return CircleAvatar(
                    backgroundColor: Colors.cyan[100],
                    backgroundImage: (snapShot.data != null) ? NetworkImage(snapShot.data!) : null,
                    radius: 45,
                  );},
                ),
            ),
              ),],),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(children: [ Text("${this.email}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),],),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(children: [ ElevatedButton(onPressed: (){
                    selectFile().then((value) {
                      if(value == true){
                        uploadFile();
                      }
                      else{
                        const snackBar = SnackBar(content: Text('No image selected'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    });
                    }, child: Text("Change avatar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)))],),
                ),
              ],
            ),
          ],),
        )
    );
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return false;
    final path = result.files.single.path!;

    setState(() => file = File(path));
    return true;
  }

  Future uploadFile() async {
    if (file == null) return;

    final destination = 'users/${this.uid}';

    await FirebaseApi.uploadFile(destination, file!);

    setState(() {

    });

  }

  Future downloadFile() async {
    String? url = await FirebaseApi.getUrl(this.uid);
    return url;
  }

}


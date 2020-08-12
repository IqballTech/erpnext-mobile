import 'package:flutter/material.dart';

import '../config/frappe_icons.dart';
import '../config/palette.dart';
import '../utils/backend_service.dart';
import '../utils/enums.dart';
import '../utils/helpers.dart';
import '../widgets/frappe_button.dart';
import '../screens/file_picker.dart';
import '../widgets/card_list_tile.dart';

class Attachments extends StatefulWidget {
  final String doctype;
  final String name;
  final Map docInfo;
  final Function callback;

  Attachments({
    @required this.doctype,
    @required this.name,
    @required this.docInfo,
    this.callback,
  });

  @override
  _AttachmentsState createState() => _AttachmentsState();
}

class _AttachmentsState extends State<Attachments> {
  Future _futureVal;
  BackendService backendService;

  @override
  void initState() {
    super.initState();
    backendService = BackendService(context);

    _futureVal =
        Future.delayed(Duration(seconds: 0), () => {"docinfo": widget.docInfo});
  }

  void _refresh() {
    setState(() {
      _futureVal = backendService.getDocinfo(widget.doctype, widget.name);
    });
  }

  List<Widget> _generateChildren(List l) {
    var children = l.map<Widget>((attachment) {
      var file = attachment["file_name"];
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: CardListTile(
          color: Palette.fieldBgColor,
          onTap: () {
            downloadFile(attachment["file_url"]);
          },
          title: Text(file),
          trailing: IconButton(
            icon: Icon(Icons.close),
            onPressed: () async {
              await backendService.removeAttachment(
                widget.doctype,
                widget.name,
                attachment["name"],
              );
              _refresh();
              widget.callback();
              showSnackBar('Attachment removed', context);
            },
          ),
        ),
      );
    }).toList();

    children.add(
      Align(
        alignment: Alignment.centerLeft,
        child: FrappeIconButton(
          buttonType: ButtonType.secondary,
          onPressed: () async {
            var nav = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return CustomFilePicker(
                    callback: widget.callback,
                    doctype: widget.doctype,
                    name: widget.name,
                  );
                },
              ),
            );

            if (nav == true) {
              _refresh();
            }
          },
          icon: FrappeIcons.small_add,
        ),
      ),
    );

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureVal,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var docInfo = snapshot.data["docinfo"];
          return Column(
            children: _generateChildren(docInfo["attachments"]),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

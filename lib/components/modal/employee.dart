import 'package:enta_mobile/models/overtime/request.dart';
import 'package:flutter/material.dart';

import '../../models/leave/request.dart';
import '../../utils/data.dart';
import '../avatar.dart';

class EmployeeModal extends StatefulWidget {
  final int type;
  const EmployeeModal({Key? key, required this.type}) : super(key: key);

  @override
  State<EmployeeModal> createState() => _EmployeeModalState();
}

class _EmployeeModalState extends State<EmployeeModal> {
  int numSelected = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onClick({required int i}) {
    UIData.dummyEmployee[i].isSelected = !UIData.dummyEmployee[i].isSelected!;
    var x = UIData.dummyEmployee.where((element) => element.isSelected == true);
    numSelected = x.length;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "List Employee".toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        Theme.of(context).primaryTextTheme.subtitle1!.fontSize,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).iconTheme.color,
                  ),
                )
              ],
            ),
          ),
          const Divider(
            height: 0,
          ),
          Expanded(
            child: ListView.separated(
                padding: const EdgeInsets.all(0),
                itemCount: UIData.dummyEmployee.length,
                separatorBuilder: (BuildContext context, int i) {
                  return const Divider(
                    height: 0,
                  );
                },
                itemBuilder: (BuildContext context, int i) {
                  return ListTile(
                    dense: true,
                    horizontalTitleGap: 2,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    onTap: () {
                      onClick(i: i);
                    },
                    leading: AvatarWidget(
                      url: UIData.dummyEmployee[i].photoUrl,
                      width: 30,
                      height: 30,
                    ),
                    title: Text(
                      UIData.dummyEmployee[i].employeeId.toString(),
                      style: TextStyle(
                        fontSize: Theme.of(context)
                            .primaryTextTheme
                            .subtitle1!
                            .fontSize,
                      ),
                    ),
                    subtitle: Text(
                      UIData.dummyEmployee[i].name!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: Theme.of(context)
                            .primaryTextTheme
                            .subtitle2!
                            .fontSize,
                      ),
                    ),
                    trailing: Checkbox(
                      value: UIData.dummyEmployee[i].isSelected ?? false,
                      onChanged: (bool? value) {
                        onClick(i: i);
                      },
                    ),
                  );
                }),
          ),
          const Divider(
            height: 0,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                if (widget.type == 0) {
                  List<OvertimeEmployeeRequestModel> result = [];
                  var x = UIData.dummyEmployee
                      .where((element) => element.isSelected == true);
                  if (x != null) {
                    for (var element in x) {
                      result.add(
                        OvertimeEmployeeRequestModel(
                          id: DateTime.now().millisecondsSinceEpoch,
                          employee: element,
                          date: [],
                        ),
                      );
                    }
                  }
                  Navigator.pop(context, result);
                } else {
                  List<LeaveEmployeeRequestModel> result = [];
                  var x = UIData.dummyEmployee
                      .where((element) => element.isSelected == true);
                  if (x != null) {
                    for (var element in x) {
                      result.add(
                        LeaveEmployeeRequestModel(
                          id: DateTime.now().millisecondsSinceEpoch,
                          employee: element,
                          date: [],
                        ),
                      );
                    }
                  }
                  Navigator.pop(context, result);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Confirm"),
                  Visibility(
                    visible: numSelected > 0 ? true : false,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text("($numSelected Selected)"),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

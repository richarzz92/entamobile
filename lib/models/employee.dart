class EmployeeModel {
  int? employeeId;
  String? name, photoUrl;
  bool? isSelected = false;

  EmployeeModel({this.employeeId, this.name, this.photoUrl, this.isSelected});

  EmployeeModel.fromMap(Map<String, dynamic> map) {
    employeeId = map['employee_id'];
    name = map['name'];
    photoUrl = map['photo_url'];
  }
}

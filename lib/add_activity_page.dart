import 'package:flutter/material.dart';

class AddActivity extends StatefulWidget {
  const AddActivity({Key? key}) : super(key: key);

  @override
  State<AddActivity> createState() => _AddActivityState();
}

class _AddActivityState extends State<AddActivity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
      children: [
        SizedBox(height: 25),
        Text(
          "Add your activity",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        SizedBox(
          height: 25,
        ),
        DropDownSports(),
      ],
    )));
  }
}

class DropDownSports extends StatefulWidget {
  const DropDownSports({Key? key}) : super(key: key);

  @override
  State<DropDownSports> createState() => _DropDownSportsState();
}

class _DropDownSportsState extends State<DropDownSports> {
  String? dropdownValue;
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Text("Sport", style: TextStyle(fontWeight: FontWeight.bold)),
        Container(
            margin: EdgeInsets.all(15),
            child: DropdownButtonFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.black12,
              ),
              dropdownColor: Color.fromRGBO(225, 225, 225, 1),
              items: <String>[
                'Tennis',
                'Swimming',
                'Soccer',
                'Basketball',
                'Other'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
            ))
      ],
    ));
  }
}

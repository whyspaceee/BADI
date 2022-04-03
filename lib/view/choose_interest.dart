import 'package:flutter/material.dart';
import 'package:sports_buddy/theme.dart';

class SelectSportsPage extends StatelessWidget {
  final List<String> sportList = [
    'Soccer',
    'Tennis',
    'Volleyball',
    'Swimming',
    'Basketball',
    'Others'
  ];
  SelectSportsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
                margin: EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(height: 25),
                    Container(
                        height: MediaQuery.of(context).size.height / 1.5,
                        width: MediaQuery.of(context).size.width,
                        child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 2.6,
                                    mainAxisSpacing: 15,
                                    crossAxisSpacing: 15),
                            itemCount: sportList.length,
                            itemBuilder: (context, index) {
                              return SportSelectWidget(sportList[index]);
                            })),
                    InkWell(
                      //uses the provider to sign in using the AuthService class,
                      onTap: () async {
                        Navigator.of(context).pushNamed('/mainMenu');
                      },
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      child: Ink(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: orange1,
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Continue",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ))));
  }
}

class SportSelectWidget extends StatefulWidget {
  String title;
  SportSelectWidget(this.title);

  @override
  State<SportSelectWidget> createState() => _SportSelectStateWidget();
}

class _SportSelectStateWidget extends State<SportSelectWidget> {
  bool? isEnabled = false;
  bool? filled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: !filled! ? Colors.transparent : blue1,
            border: Border.all(
              width: 3,
              color: blue1,
            ),
            borderRadius: BorderRadius.circular(20)),
        child: CheckboxListTile(
          title: Text(widget.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.2,
                color: filled! ? Colors.white : blue1,
              )),
          activeColor: blue1,
          value: isEnabled,
          onChanged: (val) => {
            setState(
              () => {
                isEnabled = val,
                filled = val,
              },
            )
          },
        ));
  }
}

import 'package:flutter/material.dart';

class RightPanel extends StatelessWidget {
  const RightPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
        ),
        color: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 15.0,
                left: 15.0,
                right: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Znajomi',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.person_add),
                  ),
                ],
              ),
            ),
            Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    'online - 2',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ),
                ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        child: Icon(
                          Icons.person,
                          color: Colors.grey.shade50,
                        ),
                        backgroundColor: Colors.grey.shade300,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 14,
                          width: 14,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  title: Text('Janusz Biznesu'),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.chat),
                  ),
                ),
                ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        child: Icon(
                          Icons.person,
                          color: Colors.grey.shade50,
                        ),
                        backgroundColor: Colors.grey.shade300,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 14,
                          width: 14,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  title: Text('Janusz Biznesu'),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.chat),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 15.0,
                    left: 15.0,
                    right: 15.0,
                  ),
                  child: Text(
                    'offline - 2',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ),
                ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        child: Icon(
                          Icons.person,
                          color: Colors.grey.shade50,
                        ),
                        backgroundColor: Colors.grey.shade300,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 14,
                          width: 14,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  title: Text('Janusz Biznesu'),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.chat),
                  ),
                ),
                ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        child: Icon(
                          Icons.person,
                          color: Colors.grey.shade50,
                        ),
                        backgroundColor: Colors.grey.shade300,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 14,
                          width: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  title: Text('Janusz Biznesu'),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.chat),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

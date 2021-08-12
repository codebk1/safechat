import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/friends/friends.dart';

class FriendsPanel extends StatelessWidget {
  const FriendsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<FriendsCubit>().getFriends();

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
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/add-friend'),
                    icon: Icon(Icons.person_add),
                  ),
                ],
              ),
            ),
            Divider(),
            BlocBuilder<FriendsCubit, FriendsState>(
              builder: (context, state) {
                return state.listStatus == ListStatus.loading
                    ? Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: Colors.grey.shade300,
                        ),
                      )
                    : Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
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
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () =>
                                    context.read<FriendsCubit>().getFriends(),
                                child: state.friends.length == 0
                                    ? Center(
                                        child: Text(
                                          'Brak znajomych',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2,
                                        ),
                                      )
                                    : ListView.builder(
                                        physics: BouncingScrollPhysics(),
                                        itemCount: state.friends.length + 1,
                                        itemBuilder: (
                                          BuildContext context,
                                          int index,
                                        ) {
                                          if (index == 0)
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 15.0,
                                                left: 15.0,
                                                right: 15.0,
                                              ),
                                              child: Text(
                                                'oczekujące',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2,
                                              ),
                                            );

                                          final friend =
                                              state.friends[index - 1];

                                          return ListTile(
                                            leading: Stack(
                                              children: [
                                                CircleAvatar(
                                                  child: Icon(
                                                    Icons.person,
                                                    color: Colors.grey.shade50,
                                                  ),
                                                  backgroundColor:
                                                      Colors.grey.shade300,
                                                ),
                                                if (friend.state !=
                                                        FriendState.NEW &&
                                                    friend.state !=
                                                        FriendState.PENDING)
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
                                            title: friend.state ==
                                                    FriendState.PENDING
                                                ? Text(
                                                    '${friend.email}',
                                                  )
                                                : Text(
                                                    '${friend.firstName} ${friend.lastName}',
                                                  ),
                                            trailing: friend.state ==
                                                    FriendState.NEW
                                                ? Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        onPressed: () {},
                                                        icon: Icon(
                                                          Icons.check_circle,
                                                          color: Colors
                                                              .green.shade800,
                                                        ),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {},
                                                        icon: Icon(
                                                          Icons.cancel,
                                                          color: Colors
                                                              .red.shade800,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : IconButton(
                                                    onPressed: () {},
                                                    icon: Icon(friend.state ==
                                                            FriendState.PENDING
                                                        ? Icons.cancel
                                                        : Icons.chat),
                                                  ),
                                          );
                                        }),
                              ),
                            ),
                          ],
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class HomeBottomTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          //height: MediaQuery.of(context).size.height * 0.7,
          margin: EdgeInsets.only(top: 55),
          child: CustomScrollView(
            primary: false,
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverGrid.count(
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  crossAxisCount: 2,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/chamadas');
                      },
                      child: Container(
                          padding: const EdgeInsets.only(top: 40),
                          color: Colors.red[900],
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.notifications_active,
                                size: 50,
                                color: Colors.white,
                              ),
                              Text("Chamadas",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          )),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/servicos');
                      },
                      child: Container(
                          padding: const EdgeInsets.only(top: 40),
                          color: Colors.red[900],
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.build,
                                size: 50,
                                color: Colors.white,
                              ),
                              Text("Serviços",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          )),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/mapa');
                      },
                      child: Container(
                          padding: const EdgeInsets.only(top: 40),
                          color: Colors.red[900],
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.map,
                                size: 50,
                                color: Colors.white,
                              ),
                              Text("Mapa",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          )),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/calendario');
                      },
                      child: Container(
                          padding: const EdgeInsets.only(top: 40),
                          color: Colors.red[900],
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.event_note,
                                size: 50,
                                color: Colors.white,
                              ),
                              Text("Agenda",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          )),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/clientes');
                      },
                      child: Container(
                          padding: const EdgeInsets.only(top: 40),
                          color: Colors.red[900],
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.business,
                                size: 50,
                                color: Colors.white,
                              ),
                              Text("Clientes",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          )),
                    ),
                    Container(
                        padding: const EdgeInsets.only(top: 40),
                        color: Colors.red[900],
                        child: Column(
                          children: <Widget>[
                            Icon(
                              Icons.mail_outline,
                              size: 50,
                              color: Colors.white,
                            ),
                            Text("Comunicados",
                                style: TextStyle(color: Colors.white)),
                          ],
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

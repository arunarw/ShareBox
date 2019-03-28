import 'package:flutter/material.dart';
import 'dart:io';
// import 'dart:async';

import 'package:mdns2/mdns.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  State createState() {
    return _MyAppState();
  }
}

const String discovery_service = "_http._tcp";

class _MyAppState extends State<MyApp> {
  List items = [];
  DiscoveryCallbacks discoveryCallbacks;
  bool isRun = false;

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  initState() {
    super.initState();

    discoveryCallbacks = new DiscoveryCallbacks(
      onDiscovered: (ServiceInfo info) {
        //print("Discovered ${info.toString()}");
        // setState((){
        //   items.insert(0, "DISCOVERY: Discovered ${info.toString()}");
        // });
      },
      onDiscoveryStarted: () {
        //print("Discovery started");
        // setState((){items.insert(0, "DISCOVERY: Discovery Running");});
      },
      onDiscoveryStopped: () {
        //print("Discovery stopped");
        //setState((){items.insert(0, "DISCOVERY: Discovery Not Running");});
      },
      onResolved: (ServiceInfo info) {
        // print("Resolved Service ${info.toString()}");
        List newitem = [info.name, info.host, info.port, info.type];
        //print(info.name);
        setState(() {
          if (!items.contains(newitem[0])) {
            items.add(newitem);
          }
        });
      },
    );
    // items.add("Starting mDNS for service [$discovery_service]");
    //print("Starting mDNS service");
  }

  runDiscovery(String serviceType, bool state) {
    Mdns mdns = new Mdns(discoveryCallbacks: discoveryCallbacks);
    //print("Changing service state to "+state.toString());
    if (state) {
      setState(() {
        items = [];
      });
      mdns.startDiscovery(serviceType);
    } else {
      mdns.stopDiscovery();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShareBox Connect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "ShareBox Connect",
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
          elevation: 0.4,
        ),
        drawer: appDrawer(),
        body: Container(
            child: Column(
          children: <Widget>[
            Text("Searching...!"),
            Expanded(
              child: ListView.builder(
                itemBuilder: (BuildContext context, i) => InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.black12,
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.live_tv,
                            size: 30.0,
                            color: Colors.grey,
                          ),
                          title: Text(
                            items[i][0],
                            //"ShareBox",
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.black54,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text("http:/" +
                              items[i][1] +
                              ":" +
                              items[i][2].toString()),
                          dense: false,
                        ),
                      ),
                      onTap: () {
                        _launchURL("http:/" +
                            items[i][1] +
                            ":" +
                            items[i][2].toString());
                      },
                    ),
                itemCount: items.length,
              ),
            ),
          ],
        )),
        floatingActionButton: FloatingActionButton(
          backgroundColor: isRun ? Colors.redAccent : Colors.blueAccent,
          elevation: 2,
          onPressed: () {
            setState(() {
              isRun = !isRun;
            });
            runDiscovery(discovery_service, isRun);
          },
          tooltip: '',
          child: isRun ? Icon(Icons.stop) : Icon(Icons.search),
        ),
      ),
    );
  }
}

Widget appDrawer() {
  return Drawer(
    child: Column(
      children: <Widget>[
        AppBar(
          elevation: 0.0,
          title: Text(
            "Menu",
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
          automaticallyImplyLeading: false,
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app, color: Colors.blueGrey),
          title: Text(
            "Exit",
            style:
                TextStyle(fontWeight: FontWeight.w700, color: Colors.blueGrey),
          ),
          onTap: () {
            print("Quitting sharebox");
            exit(0);
          },
        ),
      ],
    ),
  );
}

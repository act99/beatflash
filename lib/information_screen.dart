import 'package:flutter/material.dart';

class InformationScreen extends StatefulWidget {
  @override
  _InformationScreenState createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        body: SafeArea(
          child: TabBarView(
            children: <Widget>[
              KoreanInfo(),
              EnglishInfo(),
            ],
          ),
        ),
        bottomNavigationBar: Bottom(),
      ),
    );
  }
}

class KoreanInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;
    return Center(
      child: Column(
        children: <Widget>[
          Container(
            child: Text(
              '공지사항',
              style: TextStyle(fontSize: width * 0.064),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: height * 0.07),
            child: Text('***앱을 켜 놓은 상태에서만 사용이 가능합니다***.'),
          ),
          Container(
            margin: EdgeInsets.only(top: height * 0.03),
            child: Text('안드로이드 정책으로 인해'),
          ),
          Container(
            margin: EdgeInsets.only(top: height * 0.01),
            child: Text('1분 이상 앱이 활성화되지 않으면 인식이 종료됩니다.'),
          ),
          Container(
            margin: EdgeInsets.only(top: height * 0.07),
            child: Text(
              '사용방법',
              style: TextStyle(fontSize: width * 0.064),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: height * 0.03),
            child: Text('1. 본 앱은 주변 노래 소리와 비트, 데시벨에 맞추어'),
          ),
          Container(
            child: Text('플래시가 켜지는 앱입니다.'),
          ),
          Container(
            margin: EdgeInsets.only(top: height * 0.01),
            child: Text('2. 스타트 버튼을 누르면 인식이 시작됩니다.'),
          ),
          Container(
            margin: EdgeInsets.only(top: height * 0.01),
            child: Text('3. 핸드폰으로 노래를 틀어 사용할 수 있습니다.'),
          ),
          Container(
            margin: EdgeInsets.only(top: height * 0.01),
            child: Text('4. 공연장, 클럽, 노래방에서 사용할 수 있습니다.'),
          ),
          Container(
            margin: EdgeInsets.only(top: height * 0.01),
            child: Text('5. 코로나가 잘 마무리 되면'),
          ),
          Container(
            margin: EdgeInsets.only(top: height * 0.01),
            child: Text('공연장과 클럽, 회식자리에서 사용하세요.'),
          ),
        ],
      ),
    );
  }
}

class EnglishInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;
    return Center(
      child: Column(
        children: <Widget>[
          Container(
            child: Text(
              'Notice',
              style: TextStyle(fontSize: height * 0.028),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: height * 0.07),
            child: Text('**This app can only be used when turned on.**.'),
          ),
          Container(
            child: Text('(Due to Android policy)'),
          ),
          Container(
            margin: EdgeInsets.only(top: height * 0.01),
            child: Text('If the app is not activated for more than 1 minute.'),
          ),
          Container(
            child: Text('the sound recognition ends.'),
          ),
          Container(
            margin: EdgeInsets.only(top: height * 0.07),
            child: Text(
              'How to use',
              style: TextStyle(fontSize: height * 0.028),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: height * 0.03),
            child: Text('1. This app is an app that turns on the flash'),
          ),
          Container(
            child: Text('by recognizing the sound(song,beat)'),
          ),
          Container(
            margin: EdgeInsets.only(top: height * 0.01),
            child: Text("2. Pressing the start button activates "),
          ),
          Container(
            margin: EdgeInsets.only(top: height * 0.01),
            child: Text("the sound recognition function."),
          ),
          Container(
            margin: EdgeInsets.only(top: height * 0.01),
            child: Text("3. You can use it with the phone's song sound."),
          ),
          Container(
            margin: EdgeInsets.only(top: height * 0.01),
            child: Text('4. You can use it in concert halls and clubs.'),
          ),
          Container(
            margin: EdgeInsets.only(top: height * 0.01),
            child: Text('5. Use it in concert halls and clubs'),
          ),
          Container(
            margin: EdgeInsets.only(top: height * 0.01),
            child: Text('when the COVID-19 situation is over.'),
          ),
        ],
      ),
    );
  }
}

class Bottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;
    return Container(
      color: Colors.black,
      child: Container(
        margin: EdgeInsets.only(bottom: height * 0.1),
        height: height * 0.1,
        child: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.transparent,
          tabs: <Widget>[
            Tab(
              child: Text(
                '한국어',
                style: TextStyle(fontSize: height * 0.028),
              ),
            ),
            Tab(
              child: Text(
                'English',
                style: TextStyle(fontSize: height * 0.028),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

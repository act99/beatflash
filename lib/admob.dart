import 'package:firebase_admob/firebase_admob.dart';

class AdmobManager {
  BannerAd _bannerAd;

  String appID = 'ca-app-pub-6660347485032552~2809297873';
  String bannerID = 'ca-app-pub-6660347485032552/9183134530';
  // String bannerID = BannerAd.testAdUnitId;

  static MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['게임', '옷', '페이스북', '운동', '신발', '금융', '자산', '배달', '쇼핑몰'],
  );

  init() async {
    FirebaseAdMob.instance.initialize(appId: appID);
    _bannerAd = createBannerAd();
  }

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerID,
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event is $event");
      },
    );
  }

  showBannerAd() {
    _bannerAd
      ..load()
      ..show();
  }

  disposeBannerAd() {
    _bannerAd.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AdMob Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const AdHomePage(),
    );
  }
}

class AdHomePage extends StatefulWidget {
  const AdHomePage({super.key});

  @override
  State<AdHomePage> createState() => _AdHomePageState();
}

class _AdHomePageState extends State<AdHomePage> {
  // ---------------- BANNER ----------------
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;

  // ---------------- INTERSTITIAL ----------------
  InterstitialAd? _interstitialAd;

  // ---------------- REWARDED ----------------
  RewardedAd? _rewardedAd;

  int coins = 0;

  @override
  void initState() {
    super.initState();
    _loadBanner();
    _loadInterstitial();
    _loadRewarded();
  }

  // ================= BANNER =================
  void _loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() => _bannerLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  // ================= INTERSTITIAL =================
  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showInterstitial() {
    if (_interstitialAd == null) return;

    _interstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _loadInterstitial();
          },
        );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  // ================= REWARDED =================
  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
        },
      ),
    );
  }

  void _showRewarded() {
    if (_rewardedAd == null) return;

    _rewardedAd!.fullScreenContentCallback =
        FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _loadRewarded();
          },
        );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        setState(() {
          coins += reward.amount.toInt();
        });
      },
    );

    _rewardedAd = null;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AdMob Demo Dashboard"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // Coins Card
            Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.monetization_on,
                    color: Colors.amber, size: 40),
                title: const Text("Reward Coins"),
                subtitle: Text("$coins coins earned"),
              ),
            ),

            const SizedBox(height: 20),

            // Buttons Section
            _adButton(
              "Show Interstitial Ad",
              Icons.fullscreen,
              Colors.red,
              _showInterstitial,
            ),

            const SizedBox(height: 12),

            _adButton(
              "Watch Rewarded Ad (+Coins)",
              Icons.emoji_events,
              Colors.green,
              _showRewarded,
            ),

            const SizedBox(height: 20),

            const Divider(),

            const Text(
              "Banner Ad (Bottom)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const Spacer(),

            // Banner Ad
            if (_bannerLoaded && _bannerAd != null)
              SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }

  // Button widget
  Widget _adButton(
      String text,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
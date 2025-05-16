import 'package:new_tuneflow/core/common/models/models.dart';

const String baseUrl = 'https://www.jiosaavn.com/api.php';
const String apiBaseUrl = 'music.alhn.dev';
const String authApiBaseUrl = 'notify.alhn.dev';
const String imageBaseUrl = 'https://music.alhn.dev';
const String webSocketBaseUrl = 'wss://music.alhn.dev';
const String defaultPersonAvatar = '/uploads/person.png';

const String appVersion = '1.4.4';
const int buildNumber = 44;
const String appName = 'TuneFlow';
const String emailAddress = 'support@tuneflow.info';
const String igLink = 'https://instagram.com/tuneflow.musicapp';
const String wtspChannel =
    'https://whatsapp.com/channel/0029VbA0Ppi77qVWgybi6b1s';
const String tgChannel = 'https://t.me/tuneflowvibe';
const String playStoreLink =
    'https://play.google.com/store/apps/details?id=com.tuneflow';

Map<String, String> defaultParams = {
  '_format': 'json',
  '_marker': '0',
  'ctx': 'web6dot0',
  'api_version': '4',
};

List<LanguageModel> languageList = [
  LanguageModel(id: 1, name: 'Hindi', key: 'hindi'),
  LanguageModel(id: 2, name: 'English', key: 'english'),
  LanguageModel(id: 3, name: 'Bengali', key: 'bengali'),
  LanguageModel(id: 4, name: 'Telugu', key: 'telugu'),
  LanguageModel(id: 5, name: 'Marathi', key: 'marathi'),
  LanguageModel(id: 6, name: 'Tamil', key: 'tamil'),
  LanguageModel(id: 7, name: 'Urdu', key: 'urdu'),
  LanguageModel(id: 8, name: 'Gujarati', key: 'gujarati'),
  LanguageModel(id: 9, name: 'Malayalam', key: 'malayalam'),
  LanguageModel(id: 10, name: 'Kannada', key: 'kannada'),
  LanguageModel(id: 11, name: 'Punjabi', key: 'punjabi'),
  LanguageModel(id: 12, name: 'Assamese', key: 'assamese'),
  LanguageModel(id: 13, name: 'Odia', key: 'odia'),
  LanguageModel(id: 14, name: 'Rajasthani', key: 'rajasthani'),
  LanguageModel(id: 15, name: 'Bhojpuri', key: 'bhojpuri'),
  LanguageModel(id: 16, name: 'Maithili', key: 'maithili'),
  LanguageModel(id: 17, name: 'Konkani', key: 'konkani'),
  LanguageModel(id: 18, name: 'Sindhi', key: 'sindhi'),
  LanguageModel(id: 19, name: 'Dogri', key: 'dogri'),
  LanguageModel(id: 20, name: 'Nepali', key: 'nepali'),
  LanguageModel(id: 21, name: 'Haryanvi', key: 'haryanvi'),
];

List faqList = [
  {
    'question': 'What is $appName?',
    'answer':
        '$appName is a powerful and intuitive music player app that allows you to stream and manage your music seamlessly. It features advanced playback options, customizable themes, and a user-friendly interface designed for music enthusiasts.',
  },
  {
    'question': 'How do I download and install $appName?',
    'answer':
        'You can download $appName from the Google Play Store. Simply search for "$appName" in the Play Store, click "Install or Get" and the app will be downloaded and installed on your device.',
  },
  {
    'question': 'Can I create and manage playlists in $appName?',
    'answer':
        'Yes! $appName allows you to create, edit, and manage your playlists with ease. You can add or remove songs and even share your playlists with friends.',
  },
  {
    'question': 'How can I bookmark my favorite artists?',
    'answer':
        'To bookmark your favorite artists, simply tap on the artist\'s profile in $appName and click the "Bookmark" icon. This will add the artist to your bookmarked list for quick access.',
  },
  {
    'question': 'Does $appName work offline?',
    'answer':
        'Yes, $appName allows you to download your favorite songs for offline listening. You can enjoy your music anytime, even without an internet connection.',
  },
  {
    'question': 'How do I report a bug or request a feature?',
    'answer':
        'If you encounter a bug or have a feature request, you can report it directly within the app. Go to "Settings" > "Contact us". Alternatively, you can email our support team at $emailAddress.',
  },
  {
    'question': 'Can I sync my music across multiple devices?',
    'answer':
        'Yes, $appName supports cloud sync, allowing you to sync your playlists, favorites, and music preferences across multiple devices. Just sign in with your account, and your data will be synced automatically.',
  },
  {
    'question': 'How do I contact customer support?',
    'answer':
        'You can contact our customer support team by emailing $emailAddress. We’re here to help with any questions or issues you may have.',
  },
  {
    'question': 'How do I update $appName?',
    'answer':
        '$appName regularly receives updates to improve performance and add new features. To ensure you have the latest version, enable automatic updates in the Google Play Store, or manually check for updates by visiting $appName’s page on the Play Store Store.',
  },
];

List aboutUsContent = [
  'Unlimited Streaming: Access a diverse range of songs across various genres and languages, allowing you to discover new music and enjoy your favorites.',
  'Offline Listening: Download your preferred tracks in multiple quality options for offline listening, ensuring uninterrupted enjoyment even without an internet connection.',
  'Personalized Playlists: Create custom playlists tailored to your musical tastes and preferences, making it easier to organize and enjoy your music library.',
  'Multi-Language Support: $appName supports multiple languages, enabling users from different regions to navigate the app effortlessly and enjoy music in their preferred language.',
];

class DashItemsKey {
  static const String quickstart = 'com.tuneflow.quickstart';
  static const String monthlypass = 'com.tuneflow.monthlypass';
  static const String month3boostt = 'com.tuneflow.3monthboostt';
  static const String month6power = 'com.tuneflow.6monthpower';
  static const String fullyearmastery = 'com.tuneflow.fullyearmastery';
}

List reportReasons = [
  {'title': 'Spam', 'subTitle': 'Unwanted promotional content or irrelevant.'},
  {
    'title': 'Inappropriate Content',
    'subTitle':
        'Offensive, sexual, explicit, violent, hate speech, or harassment.',
  },
  {'title': 'Misinformation', 'subTitle': 'False or misleading information.'},
  {
    'title': 'Copyright Violation',
    'subTitle': ' Unauthorized use of someone else\'s content.',
  },
  {
    'title': 'Harassment or Bullying ',
    'subTitle': 'Direct targeting, trolling, or discomforting behavior.',
  },
  {
    'title': 'Privacy Violation',
    'subTitle': 'Sharing personal information or unauthorized photos/videos.',
  },
  {
    'title': 'Self-Harm or Harm to Others',
    'subTitle': 'Suicide, self-harm, or violent threats.',
  },
  {
    'title': 'Illegal Activity',
    'subTitle': 'Promotion of drugs, hacking, or illegal acts.',
  },
  {
    'title': 'Off-Topic Content',
    'subTitle': 'Content that doesn’t align with the platform\'s guidelines.',
  },
  {'title': 'Other', 'subTitle': 'Any other reason for reporting'},
];

List<Map> socialCardContent = [
  {
    'title': 'Join TuneFlow WhatsApp Channel!',
    'des':
        'Get instant updates, new features & special announcements. Tap to join now!',
    'link': wtspChannel,
  },
  {
    'title': 'Follow TuneFlow on Instagram!',
    'des':
        'Discover new features, updates & exciting announcements. Follow now!',
    'link': igLink,
  },
  {
    'title': 'Rate Us on Play Store!',
    'des':
        'Your support helps us improve! Drop a 5 star rating & share your feedback!',
    'link': playStoreLink,
  },
  {
    'title': 'Join TuneFlow Telegram Channel!',
    'des':
        'Stay updated with the latest features, app updates & exclusive offers. Tap to join!',
    'link': tgChannel,
  },
];

List<String> deleteAccountReasons = [
  'I have multiple accounts.',
  'I no longer use TuneFlow.',
  'I am not satisfied with the app.',
  'I found a better alternative.',
  'Privacy concerns.',
  'I am facing technical issues.',
  'I want to start fresh with a new account.',
  'Other.',
];

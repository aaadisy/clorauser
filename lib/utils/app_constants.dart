// Shared Pref
const IS_FIRST_TIME = 'IS_FIRST_TIME';
const FIRSTNAME = "FIRSTNAME";
const LASTNAME = "LASTNAME";
const EMAIL = "EMAIL";
const PASSWORD = "PASSWORD";
const PLAYER_ID = 'PLAYER_ID';
const USERNAME = "USERNAME";
const IS_SUBSCRIBE = 'IS_SUBSCRIBE';
const IS_REMEMBER = 'IS_REMEMBER';
const SUBSCRIPTION_DETAIL = 'SUBSCRIPTION_DETAIL';
const DISPLAY_NAME = "DISPLAY_NAME";
const PHONE_NUMBER = "PHONE_NUMBER";
const IS_PLAYING = "IS_PLAYING";
const TOKEN = "TOKEN";
const USER_PROFILE_IMG = "USER_PROFILE_IMG";
const USER_ID = "USER_ID";
const IS_LOGIN = "IS_LOGIN";
const COUNTRY_CODE = 'COUNTRY_CODE';
const FACEBOOK_URL = "FACEBOOK_URL";
const INSTAGRAM_URL = "INSTAGRAM_URL";
const TWITTER_URL = "TWITTER_URL";
const LINKED_URL = "LINKED_URL";
const SITE_NAME = "SITE_NAME";
const SITE_EMAIL = "SITE_EMAIL";
const SITE_DESCRIPTION = "SITE_DESCRIPTION";
const SITE_COPYRIGHT = "SITE_COPYRIGHT";
const CONTACT_EMAIL = "CONTACT_EMAIL";
const HELP_SUPPORT = "HELP_SUPPORT";
const CONTACT_NUMBER = "CONTACT_NUMBER";
const HELP_SUPPORT_URL = "HELP_SUPPORT_URL";
const Doctor = 'doctor';
const ANONYMOUS = "anonymous_user";
const APP_USER = "app_user";
const USER_TYPE = "user_type";
const APP_VERSION = "app_version";
const APP_SOURCE = "app_source";
const USER_MODEL_DATA = 'user_model_data';

const PAID = "paid";
const FREE = "free";
const YEARLY = "yearly";
const MONTHLY = "monthly";
const IS_USER_COMPLETED_QUE = "IS_USER_COMPLETED_QUE";
const String IS_USER_SIGNED_UP = 'is_user_signed_up';
const HOUR_INDEX = "HOUR_INDEX";
const MINUTE_INDEX = "MINUTE_INDEX";
const TEST_TIME = "TEST_TIME";
const GOAL = "GOAL";
const CYCLE_LENGTH = "CYCLE_LENGTH";
const PERIOD_LENGTH = "PERIOD_LENGTH";
const LUTEAL_PHASE = "LUTEAK_PHASE";
const PERIOD_START_DATE = "PERIOD_START_DATE";

const FONT_SIZE_PREF = 'FONT_SIZE_PREF';

const SYMPTOMS = "SYMPTOMS";

///Doctor key
const DR_EMAIL = "DR_EMAIL";
const DR_PASSWORD = "DR_PASSWORD";
const DR_NAME = 'DR_NAME';
const DR_DESC = 'DR_DESC';
const DR_TAGLINE = 'DR_TAGLINE';
const DR_PROFILE_IMG = "DR_PROFILE_IMG";
const DR_CAREER = "DR_CAREER";
const DR_EDUCATION = "DR_EDUCATION";
const DR_AWARDS = "DR_AWARDS";
const DR_EXPERTISE = "DR_EXPERTISE";
const DR_COLLECTION = 'DR_COLLECTION';

const LoginTypeGoogle = 'gmail';
const LoginTypeOTP = 'mobile';
const LoginUser = 'user';
const statusActive = 'active';

const TermsCondition = "termsCondition";
const CurrencySymbol = "currencySymbol";
const CurrencyCode = "currencyCode";
const CurrencyPosition = "currencyPosition";
// const OneSignalAppID = "oneSignalAppID";
// const OnesignalRestApiKey = "onesignalRestApiKey";
const AdmobBannerId = "admobBannerId";
const AdmobInterstitialId = "admobInterstitialId";
const AdmobBannerIdIos = "admobBannerIdIos";
const AdmobInterstitialIdIos = "admobInterstitialIdIos";
const ChatGptApiKey = "chatGptApiKey";
const PrivacyPolicy = "privacyPolicy";
const subscriptions = "subscription_system";

const SUPPORT_EMAIL = "SUPPORT_EMAIL";
const SUPPORT_CONTACT = "SUPPORT_CONTACT";
const SUPPORT_URL = "SUPPORT_URL";

/* view type */
const STORY_VIEW = 0;
const VIDEO = 1;
const CATEGORIES = 2;
const VIDEO_COURSE = 3;
const BLOG_COURSE = 4;
const PODCAST = 5;
const BLOG = 6;
const INSIGHT_TEXT = 7;
const QUESTION_ANSWER = 8;

// REGION START  KEYS
const MESSAGES_COLLECTION = "messages";
const USER_COLLECTION = "users";
const CONTACT_COLLECTION = "contacts";
//END

// pass lock start
const IS_PASS_LOCK_SET = 'IS_PASS_LOCK_SET';
final KEY_LAST_KNOWN_APP_LIFECYCLE_STATE = 'LAST_KNOWN_APP_LIFECYCLE_STATE';
final KEY_APP_BACKGROUND_TIME = 'APP_BACKGROUND_TIME';
final DEFAULT_PIN_LENGTH = 4;
const IS_FINGERPRINT_LOCK_SET = 'IS_FINGERPRINT_LOCK_SET';
const IS_AUTHENTICATED = 'IS_AUTHENTICATED';
// pass lock end
//REGION FIREBASE  KEYS
const KEY_BLOCKED_TO = "blocked_to";
const KEY_CASE_SEARCH = "case_search";
const KEY_IS_PRESENT = "is_present";
const KEY_LAST_SEEN = "last_seen";
const UID = "UID";
const KEY_PHONE_NUMBER = "phone_number";
const KEY_LAST_MESSAGE_TIME = "last_message_time";
const KEY_ID = "id";
const KEY_SENDER_ID = "sender_id";
const KEY_RECEIVER_ID = "receiver_id";
const KEY_MESSAGE = "message";
const KEY_IS_MESSAGE_READ = "is_message_read";
const KEY_PROFILE_IMAGE = "profile_image";
const KEY_MESSAGE_TYPE = "message_type";
const KEY_FIREBASE_CREATED_AT = "firebase_created_at";
const KEY_FIREBASE_UPDATED_AT = "firebase_updated_at";
const KEY_ADDED_ON = "added_on";
const KEY_STATUS = "status";
const KEY_PLAYER_ID = "player_id";
const KEY_UID = "uid";
const KEY_PIN = "pin";
const KEY_EMAIL = "email";
const KEY_PHOTO_URL = "photo_url";
const KEY_QUESTION_DATA = "question_data";
const KEY_REMINDER_DATA = "reminder_data";
const DEFAULT_CYCLE_LENGTH = 28;
const DEFAULT_PERIOD_LENGTH = 5;
const PER_PAGE_CHAT_COUNT = 50;
const chatMsgRadius = 12.0;
const EXCEPTION_NO_USER_FOUND = "EXCEPTION_NO_USER_FOUND";
const CURRENT_USER_CYCLE_DAY = "CURRENT_USER_CYCLE_DAY";
const CURRENT_USER_PREGNANCY_WEEK = "CURRENT_USER_PREGNANCY_WEEK";
const TEXT = "TEXT";
const IMAGE = "IMAGE";
int mChatFontSize = 16;
const TYPE_IMAGE = "image";
const TYPE_TEXT = "text";

enum MessageType { TEXT, IMAGE }

const SENDER = "sender";
const RECEIVER = "receiver";
const SEARCH_KEY = "Search";
const CHAT_DATA_IMAGES = "chatImages";
const IS_ENTER_KEY = "IS_ENTER_KEY";
const SELECTED_WALLPAPER = "SELECTED_WALLPAPER";
const CHAT_NOTIFICATION_COUNT = "CHAT_NOTIFICATION_COUNT";
//indexed for reminders

// background notification alarm manager
const EVENTS_KEY = "fetch_events";
const CHECK_SCHEDULE_DATA = "CHECK_SCHEDULE_DATA";
const TASK_MEDITATION = 1;
const TASK_MEDICINE = 2;
const TASK_DAILY_LOG = 3;
const TASK_TRACKING_REMINDER = 4;
const TASK_PERIOD_REMINDER = 5;
const TASK_FERTILITY_REMINDER = 6;
const TASK_OVULATION_REMINDER = 7;

// const REVENUE_CAT_KEY = "revenueCatKey";

/// Subscription
const SUBSCRIPTION_DATA = "subscription_data";
const SUBSCRIPTION_FEATURES = "subscription_features";

const USER_SECURITY_PIN = "USER_SECURITY_PIN";
const IS_USER_LOCATION_UPDATED = "IS_USER_LOCATION_UPDATED";
const IS_SHOW_WARNING_DIALOG = 'IS_SHOW_WARNING_DIALOG';

const PERIOD_REMINDER = "PERIOD_REMINDER";
const FERTILITY_REMINDER = "FERTILITY_REMINDER";
const OVULATION_REMINDER = "OVULATION_REMINDER";

const LANG_LAST_UPDATED = "LANG_LAST_UPDATED";
const INSIGHT_STORY_IMAGE_DURATION = 5;

const LAST_DATA_SYNC_DATETIME = "LAST_DATA_SYNC_DATETIME";
const IS_BACKUP_ENABLED = "IS_BACKUP_ENABLED";
const IS_BACKUP_POP_DISPLAYED = "IS_BACKUP_POP_DISPLAYED";
const IS_UPDATE_POP_DISMISSED = "IS_UPDATE_POP_DISMISSED";

const PLAY_STORE = "Play Store";
const GOOGLE_PACKAGE_INSTALLER = "Google Package installer";
const RUSTORE = "RuStore";
const LOCAL_SOURCE = "Local Source";
const AMAZON_STORE = "Amazon Store";
const HUAWEI_APP_GALLERY = "Huawei App Gallery";
const SAMSUNG_GALAXY_STORE = "Samsung Galaxy Store";
const SAMSUNG_SMART_SWITCH_MOBILE = "Samsung Smart Switch Mobile";
const XIAOMI_GET_APPS = "Xiaomi Get Apps";
const OPPO_APP_MARKET = "Oppo App Market";
const VIVO_APP_STORE = "Vivo App Store";
const OTHER_SOURCE = "Other Source";
const APP_STORE = "App Store";
const TEST_FLIGHT = "Test Flight";
const UNKNOWN_SOURCE = "Unknown Source";
const NEWLY_GENERATED_PIN = "NEWLY_GENERATED_PIN";

/// GRAPHS
const GRAPH_HEIGHT = 240.00;

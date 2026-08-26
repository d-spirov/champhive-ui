// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'TeamHive';

  @override
  String get team => 'Takım';

  @override
  String get hive => 'Kovan';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get confirmPassword => 'Şifreyi onayla';

  @override
  String get firstName => 'Ad';

  @override
  String get lastName => 'Soyad';

  @override
  String get phone => 'Telefon';

  @override
  String get logIn => 'Giriş yap';

  @override
  String get signUp => 'Kayıt ol';

  @override
  String get logOut => 'Çıkış yap';

  @override
  String get dontHaveAccount => 'Hesabın yok mu? ';

  @override
  String get alreadyHaveAccount => 'Zaten hesabın var mı? ';

  @override
  String get pleaseEnterEmail => 'Lütfen e-postanı gir';

  @override
  String get pleaseEnterValidEmail => 'Lütfen geçerli bir e-posta gir';

  @override
  String get pleaseEnterPassword => 'Lütfen şifreni gir';

  @override
  String get pleaseEnterFirstName => 'Lütfen adını gir';

  @override
  String get pleaseEnterLastName => 'Lütfen soyadını gir';

  @override
  String get pleaseConfirmPassword => 'Lütfen şifreni onayla';

  @override
  String get passwordsDoNotMatch => 'Şifreler eşleşmiyor';

  @override
  String get passwordMinLength => 'Şifre en az 8 karakter olmalı';

  @override
  String get loginFailed => 'Giriş başarısız. Bilgilerini kontrol et.';

  @override
  String get faceIdSignInPrompt => 'Giriş için Face ID kullan';

  @override
  String get signInWithFaceId => 'Face ID ile giriş yap';

  @override
  String get registrationFailed => 'Kayıt başarısız. Lütfen tekrar dene.';

  @override
  String get myClubs => 'Kulüplerim';

  @override
  String get noClubsYet => 'Henüz hiçbir kulübe üye değilsin.';

  @override
  String get home => 'Ana sayfa';

  @override
  String get teams => 'Takımlar';

  @override
  String get players => 'Oyuncular';

  @override
  String get members => 'Üyeler';

  @override
  String get events => 'Etkinlikler';

  @override
  String get schedule => 'Program';

  @override
  String get calendar => 'Takvim';

  @override
  String get attendance => 'Yoklama';

  @override
  String get messages => 'Mesajlar';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get payments => 'Ödemeler';

  @override
  String get statistics => 'İstatistikler';

  @override
  String get more => 'Daha fazla';

  @override
  String get settings => 'Ayarlar';

  @override
  String get helpSupport => 'Yardım ve destek';

  @override
  String get myAccount => 'Hesabım';

  @override
  String get appearance => 'Görünüm';

  @override
  String get language => 'Dil';

  @override
  String get aboutApp => 'ChampHive hakkında';

  @override
  String get moreManagement => 'Yönetim';

  @override
  String get moreAccount => 'Hesap';

  @override
  String get moreSupport => 'Destek';

  @override
  String get retry => 'Yeniden dene';

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'İptal';

  @override
  String get create => 'Oluştur';

  @override
  String get search => 'Ara';

  @override
  String get comingSoon => 'Yakında';

  @override
  String comingSoonNamed(String label) {
    return '$label yakında';
  }

  @override
  String get sessionExpired => 'Oturumun sona erdi. Lütfen tekrar giriş yap.';

  @override
  String get signInToContinue => 'Devam etmek için giriş yap';

  @override
  String get selectClub => 'Bir kulüp seç';

  @override
  String get selectClubFirst => 'Önce bir kulüp seç';

  @override
  String get noData => 'Henüz veri yok';

  @override
  String get pullToRefresh => 'Yenilemek için çek';

  @override
  String get dismiss => 'Kapat';

  @override
  String get continueAction => 'Devam';

  @override
  String get refresh => 'Yenile';

  @override
  String get history => 'Geçmiş';

  @override
  String get report => 'Rapor';

  @override
  String get overview => 'Özet';

  @override
  String get info => 'Bilgi';

  @override
  String get notes => 'Notlar';

  @override
  String get note => 'Not';

  @override
  String get optionalNote => 'İsteğe bağlı not';

  @override
  String get location => 'Konum';

  @override
  String get title => 'Başlık';

  @override
  String get type => 'Tür';

  @override
  String get scope => 'Kapsam';

  @override
  String get when => 'Ne zaman';

  @override
  String get repeat => 'Tekrar';

  @override
  String get duration => 'Süre';

  @override
  String get amount => 'Tutar';

  @override
  String get bank => 'Banka';

  @override
  String get importMethod => 'İçe aktar';

  @override
  String get member => 'Üye';

  @override
  String get payment => 'Ödeme';

  @override
  String get chat => 'Sohbet';

  @override
  String get session => 'Seans';

  @override
  String get club => 'Kulüp';

  @override
  String get status => 'Durum';

  @override
  String get timezone => 'Saat dilimi';

  @override
  String get contact => 'İletişim';

  @override
  String get gender => 'Cinsiyet';

  @override
  String get dateOfBirth => 'Doğum tarihi';

  @override
  String get registrationNumber => 'Kayıt no';

  @override
  String get shirtNumber => 'Forma numarası';

  @override
  String shirtNumberValue(String number) {
    return 'Forma #$number';
  }

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get languageEnglish => 'İngilizce';

  @override
  String get languageMacedonian => 'Makedonca';

  @override
  String get languageSerbian => 'Sırpça';

  @override
  String get languageItalian => 'İtalyanca';

  @override
  String get languageBosnian => 'Boşnakça';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageSystem => 'Sistem dili';

  @override
  String get newMessage => 'Yeni mesaj';

  @override
  String get newSchedule => 'Yeni program';

  @override
  String get markAllRead => 'Tümünü okundu işaretle';

  @override
  String get recordPayment => 'Ödeme kaydet';

  @override
  String get profile => 'Profil';

  @override
  String get saveProfile => 'Profili kaydet';

  @override
  String get changePassword => 'Şifreyi değiştir';

  @override
  String get outstanding => 'Ödenmemiş';

  @override
  String get cash => 'Nakit';

  @override
  String get myFees => 'Aidatlarım';

  @override
  String get membership => 'Üyelik';

  @override
  String get revenue => 'Gelir';

  @override
  String get exploreDemo => 'Demo arayüzü keşfet';

  @override
  String get tagline => 'Takımın. Tek yer.';

  @override
  String get continueWithGoogle => 'Google ile devam et';

  @override
  String get continueWithApple => 'Apple ile devam et';

  @override
  String get signInWithEmail => 'E-posta ile giriş yap';

  @override
  String get orDivider => 'VEYA';

  @override
  String get newToChampHive => 'ChampHive’da yeni misin? ';

  @override
  String get createAccount => 'Hesap oluştur!';

  @override
  String get accountsViaInviteNote =>
      'Hesaplar genellikle davetle oluşturulur. Kayıt bu API’de yalnızca operatörlere açık olabilir.';

  @override
  String get coachFallback => 'Antrenör';

  @override
  String get goodMorning => 'Günaydın';

  @override
  String get goodAfternoon => 'İyi günler';

  @override
  String get goodEvening => 'İyi akşamlar';

  @override
  String get yourTeams => 'Takımların';

  @override
  String get yourClubs => 'Kulüplerin';

  @override
  String get upcoming => 'Yaklaşan';

  @override
  String get recentActivity => 'Son hareketler';

  @override
  String get nextMatch => 'Sonraki maç';

  @override
  String get tbd => 'Belirlenecek';

  @override
  String get nothingOnScheduleToday =>
      'Bugün programda bir şey yok. Göz atmak için Takvim’i aç.';

  @override
  String get nothingTodayNextUp => 'Bugün yok — sıradaki';

  @override
  String get couldNotLoadClubs => 'Kulüpler yüklenemedi';

  @override
  String get couldNotLoadSchedule => 'Program yüklenemedi';

  @override
  String get couldNotLoadEvents => 'Etkinlikler yüklenemedi';

  @override
  String get couldNotLoadTeams => 'Takımlar yüklenemedi';

  @override
  String get couldNotLoadMembers => 'Üyeler yüklenemedi';

  @override
  String get couldNotLoadMember => 'Üye yüklenemedi';

  @override
  String get couldNotLoadRoster => 'Kadro yüklenemedi';

  @override
  String get couldNotLoadSession => 'Seans yüklenemedi';

  @override
  String get couldNotLoadReport => 'Rapor yüklenemedi';

  @override
  String get couldNotLoadHistory => 'Geçmiş yüklenemedi';

  @override
  String get couldNotLoadConversations => 'Sohbetler yüklenemedi';

  @override
  String get couldNotLoadChat => 'Sohbet yüklenemedi';

  @override
  String get couldNotLoadPeople => 'Kişiler yüklenemedi';

  @override
  String get couldNotLoadNotifications => 'Bildirimler yüklenemedi';

  @override
  String get couldNotLoadMore => 'Daha fazlası yüklenemedi';

  @override
  String get couldNotLoadObligations => 'Yükümlülükler yüklenemedi';

  @override
  String get couldNotLoadPayments => 'Ödemeler yüklenemedi';

  @override
  String get couldNotLoadFees => 'Aidatların yüklenemedi';

  @override
  String get couldNotLoadClub => 'Kulüp yüklenemedi';

  @override
  String get couldNotLoadMembershipStats => 'Üyelik istatistikleri yüklenemedi';

  @override
  String get couldNotLoadRevenueStats => 'Gelir istatistikleri yüklenemedi';

  @override
  String get couldNotCreateSchedule => 'Program oluşturulamadı';

  @override
  String get couldNotSaveStatus => 'Durum kaydedilemedi';

  @override
  String get couldNotSaveAttendance => 'Yoklama kaydedilemedi';

  @override
  String get couldNotSendMessage => 'Mesaj gönderilemedi';

  @override
  String get couldNotOpenConversation => 'Sohbet açılamadı';

  @override
  String get couldNotMarkAsRead => 'Okundu olarak işaretlenemedi';

  @override
  String get couldNotRecordPayment => 'Ödeme kaydedilemedi';

  @override
  String get signInToCreateSchedule =>
      'Program öğeleri oluşturmak için giriş yap';

  @override
  String get signInToOpenChat => 'Canlı sohbeti açmak için giriş yap';

  @override
  String get signInToSeeNotifications =>
      'Bildirimlerini görmek için giriş yap.';

  @override
  String get signInToManagePayments =>
      'Kulüp ödemelerini yönetmek için giriş yap.';

  @override
  String get signInToSeeFees => 'Aidatlarını görmek için giriş yap.';

  @override
  String get signInToSeeStats =>
      'Kulüp üyelik ve gelir analizini görmek için giriş yap.';

  @override
  String get signInToLoadTeams =>
      'Kulüp takımlarını API’den yüklemek için giriş yap.';

  @override
  String get selectClubToViewTeams => 'Takımları görmek için bir kulüp seç.';

  @override
  String get selectClubToViewMembers => 'Üyeleri görmek için bir kulüp seç.';

  @override
  String get selectClubToViewCharges => 'Borçları görmek için bir kulüp seç.';

  @override
  String get selectClubToViewPayments => 'Ödemeleri görmek için bir kulüp seç.';

  @override
  String get selectClubToViewMembershipStats =>
      'Üyelik istatistiklerini görmek için bir kulüp seç.';

  @override
  String get selectClubToViewRevenueStats =>
      'Gelir istatistiklerini görmek için bir kulüp seç.';

  @override
  String get noClubSelected => 'Kulüp seçilmedi.';

  @override
  String get noEventsOnThisDay => 'Bu günde etkinlik yok.';

  @override
  String get demoSchedule => 'Demo program';

  @override
  String get noTeamsYet => 'Bu kulüpte henüz takım yok.';

  @override
  String get tapToOpenRoster => 'Kadroyu açmak için dokun';

  @override
  String get noMembersFound => 'Bu kulüp için üye bulunamadı.';

  @override
  String get searchMembers => 'Üye ara';

  @override
  String get searchMessages => 'Mesaj ara';

  @override
  String get searchPeople => 'Kişi ara';

  @override
  String get noConversations => 'Sohbet yok.';

  @override
  String get noConversationsYet => 'Henüz sohbet yok.';

  @override
  String get noMessagesYet => 'Henüz mesaj yok.';

  @override
  String get messageDeleted => 'Mesaj silindi';

  @override
  String get yesterday => 'Dün';

  @override
  String get noMatches => 'Eşleşme yok.';

  @override
  String get noAdultsToMessage =>
      'Mesaj atılacak yetişkin henüz yok.\nKişiler kulüp kadrosu ve takım sohbetlerinden burada görünür.';

  @override
  String get sayHello => 'Merhaba de';

  @override
  String get messageHint => 'Mesaj';

  @override
  String get readOnly => 'Salt okunur';

  @override
  String get systemMessage => 'Sistem';

  @override
  String get cannotSendInChannel => 'Bu kanalda gönderemezsin';

  @override
  String get couldNotLoadOlder => 'Daha eskiler yüklenemedi';

  @override
  String get noNotificationsYet => 'Henüz bildirim yok.';

  @override
  String get loadMore => 'Daha fazla yükle';

  @override
  String get nothingOutstanding => 'Ödenmemiş borç yok.';

  @override
  String get noPaymentsYet => 'Henüz kayıtlı ödeme yok.';

  @override
  String get noOpenFamilyFees => 'Açık aile aidatı yok.';

  @override
  String get noFeeHistoryYet => 'Henüz aidat geçmişi yok.';

  @override
  String get openCharges => 'Açık borçlar';

  @override
  String get youOwe => 'Borcun';

  @override
  String get paymentReference => 'Ödeme referansı';

  @override
  String get mixedCurrencies => 'Karışık para birimleri';

  @override
  String get noFamilyMembersLinked => 'Bağlı aile üyesi yok';

  @override
  String copiedLabel(String label) {
    return '$label kopyalandı';
  }

  @override
  String get memberId => 'Üye kimliği';

  @override
  String get pasteMemberIdHint => 'Açık borç yok — üye kimliğini yapıştır';

  @override
  String get notesOptional => 'Notlar (isteğe bağlı)';

  @override
  String get savePayment => 'Ödemeyi kaydet';

  @override
  String get pickAMember => 'Bir üye seç';

  @override
  String get enterValidAmount => 'Geçerli bir tutar gir';

  @override
  String openListedSummary(int open, int total) {
    return '$open açık · $total listelendi';
  }

  @override
  String membersCountLabel(int count) {
    return '$count üye';
  }

  @override
  String get titleRequired => 'Başlık gerekli';

  @override
  String get pickATeam => 'Bir takım seç';

  @override
  String createdNamed(String title) {
    return '“$title” oluşturuldu';
  }

  @override
  String get purposeOptional => 'Amaç (isteğe bağlı)';

  @override
  String get locationOptional => 'Konum (isteğe bağlı)';

  @override
  String get titleHintTraining => 'örn. U14 antrenman';

  @override
  String get wholeClub => 'Tüm kulüp';

  @override
  String get noTeamsCreateOrClub =>
      'Bu kulüpte takım yok. Önce bir takım oluştur veya Tüm kulüp’ü kullan.';

  @override
  String get duration45 => '45 dk';

  @override
  String get duration60 => '60 dk';

  @override
  String get duration75 => '75 dk';

  @override
  String get duration90 => '90 dk';

  @override
  String get duration2h => '2 saat';

  @override
  String get duration3h => '3 saat';

  @override
  String get oneOff => 'Tek seferlik';

  @override
  String get weekly => 'Haftalık';

  @override
  String get daily => 'Günlük';

  @override
  String get numberOfOccurrences => 'Tekrar sayısı';

  @override
  String get requestRsvp => 'RSVP iste';

  @override
  String get requestRsvpSubtitle => 'Aileler katılımı önceden onaylayabilir';

  @override
  String get eventTypeTraining => 'Antrenman';

  @override
  String get eventTypeMatch => 'Maç';

  @override
  String get eventTypeClubEvent => 'Kulüp etkinliği';

  @override
  String get eventTypeTournament => 'Turnuva';

  @override
  String get eventTypeEvent => 'Etkinlik';

  @override
  String get statusPresent => 'Geldi';

  @override
  String get statusAbsent => 'Gelmedi';

  @override
  String get statusLate => 'Geç kaldı';

  @override
  String get statusExcused => 'Mazeretli';

  @override
  String get statusUnmarked => 'İşaretlenmedi';

  @override
  String get takeAttendance => 'Yoklama al';

  @override
  String get roster => 'Kadro';

  @override
  String rosterCount(int count) {
    return 'Kadro ($count)';
  }

  @override
  String get summary => 'Özet';

  @override
  String get reloadRoster => 'Kadroyu yeniden yükle';

  @override
  String get saveRemaining => 'Kalanı kaydet';

  @override
  String get skipNote => 'Notu atla';

  @override
  String get tapMemberToMark =>
      'İşaretlemek için bir üyeye dokun — durum hemen sunucuya kaydedilir';

  @override
  String noMembersOnRoster(String scope) {
    return '$scope kadrosunda üye yok.';
  }

  @override
  String get thisSession => 'bu seans';

  @override
  String get attendanceLocked => 'Bu seans için yoklama kilitli.';

  @override
  String get sessionCanceled => 'Bu seans iptal edildi.';

  @override
  String get unmarkedCannotBeSaved =>
      'İşaretlenmemiş kayıt kaydedilemez — önce bir durum seç.';

  @override
  String get allMarksAlreadySaved => 'Tüm işaretler zaten kaydedildi.';

  @override
  String rsvpStatus(String status) {
    return 'RSVP: $status';
  }

  @override
  String markNamed(String name) {
    return '$name işaretle';
  }

  @override
  String get optionalNoteSynced =>
      'İsteğe bağlı not (işaretle birlikte senkronize)';

  @override
  String get attendanceReport => 'Yoklama raporu';

  @override
  String get openWindow => 'Açık pencere';

  @override
  String get past => 'Geçmiş';

  @override
  String get noSessionsInWindow => 'Şu anda yoklama penceresinde seans yok.';

  @override
  String get noPastSessions => 'Henüz geçmiş seans yok.';

  @override
  String get attendanceSynced => 'Yoklama senkronize edildi';

  @override
  String get attendancePartiallySynced => 'Yoklama kısmen senkronize edildi';

  @override
  String get marksSentToPlatform => 'İşaretler kulüp platformuna gönderildi.';

  @override
  String marksAppliedRejected(int applied, int rejected) {
    return '$applied uygulandı · $rejected reddedildi';
  }

  @override
  String get superseded => 'geçersiz kılındı';

  @override
  String get backToSession => 'Seansa dön';

  @override
  String get viewReport => 'Raporu gör';

  @override
  String get attendanceHistory => 'Yoklama geçmişi';

  @override
  String get trainingLocation => 'Antrenman yeri';

  @override
  String get active => 'Aktif';

  @override
  String get season => 'Sezon';

  @override
  String get noMembersOnTeamRoster => 'Bu takım kadrosunda üye yok.';

  @override
  String get noUpcomingSessionsForTeam => 'Bu takım için yaklaşan seans yok.';

  @override
  String get playerProfile => 'Oyuncu profili';

  @override
  String get noProfileDetailsYet => 'Henüz profil detayı yok.';

  @override
  String get notAssignedToTeam => 'Bir takıma atanmadı.';

  @override
  String get noNotesYet => 'Henüz not yok.';

  @override
  String get demoNotes => 'Demo notlar';

  @override
  String get canceled => 'İptal edildi';

  @override
  String get loadingAttendanceStatus => 'Yoklama durumu yükleniyor…';

  @override
  String get loadRosterAndMark => 'Kadroyu yükle ve üyeleri işaretle';

  @override
  String get viewLockedReport => 'Bu kilitli seansın raporunu gör';

  @override
  String get rosterWithStatuses =>
      'Geldi / geç kaldı / gelmedi / mazeretli kadrosu';

  @override
  String get pastAndOpenSessions => 'Yoklama için geçmiş ve açık seanslar';

  @override
  String get refreshAttendanceStatus => 'Yoklama durumunu yenile';

  @override
  String marksAcceptedUntil(String date, String time) {
    return 'İşaretler $date · $time tarihine kadar kabul edilir';
  }

  @override
  String clubStatsTitle(String name) {
    return '$name istatistikleri';
  }

  @override
  String get noMembershipData => 'Üyelik verisi yok.';

  @override
  String get noRevenueData => 'Gelir verisi yok.';

  @override
  String get noTrendDataYet => 'Henüz eğilim verisi yok.';

  @override
  String get noRevenueTrendYet => 'Henüz gelir eğilimi yok.';

  @override
  String asOfDate(String date) {
    return '$date itibarıyla';
  }

  @override
  String asOfDateCurrency(String date, String currency) {
    return '$date itibarıyla · $currency';
  }

  @override
  String get activeNow => 'Şu an aktif';

  @override
  String get onTheBooks => 'Kayıtlarda';

  @override
  String get joined12Mo => 'Katılan (12 ay)';

  @override
  String get left12Mo => 'Ayrılan (12 ay)';

  @override
  String get unenrolledNoTeam => 'Kayıtsız (takımsız)';

  @override
  String get collected => 'Tahsil edilen';

  @override
  String get expected => 'Beklenen';

  @override
  String get collectionRate => 'Tahsilat oranı';

  @override
  String get membersBilled => 'Faturalanan üyeler';

  @override
  String get inDebt => 'Borçlu';

  @override
  String get waived => 'Affedilen';

  @override
  String get monthlyEnrollment => 'Aylık kayıt';

  @override
  String get agingOutstanding => 'Vadesi (ödenmemiş)';

  @override
  String get monthlyTrend => 'Aylık eğilim';

  @override
  String get byTeam => 'Takıma göre';

  @override
  String get bySection => 'Bölüme göre';

  @override
  String get notDue => 'Vadesi gelmedi';

  @override
  String get days1To30 => '1–30 gün';

  @override
  String get days31To60 => '31–60 gün';

  @override
  String get days61To90 => '61–90 gün';

  @override
  String get days90Plus => '90+ gün';

  @override
  String activeCount(int count) {
    return '$count aktif';
  }

  @override
  String joinedLeftDelta(int joined, int left) {
    return '+$joined / −$left';
  }

  @override
  String owedAmount(String amount) {
    return '$amount borçlu';
  }

  @override
  String membersOwed(int count, String amount) {
    return '$count üye · $amount borçlu';
  }

  @override
  String get yourRoles => 'Rollerin';

  @override
  String get useThisClub => 'Bu kulübü kullan';

  @override
  String clubSelected(String name) {
    return '$name seçildi';
  }

  @override
  String get namesRequired => 'Ad ve soyad gerekli';

  @override
  String get profileSaved => 'Profil kaydedildi';

  @override
  String get saveFailed => 'Kaydetme başarısız';

  @override
  String get enterCurrentAndNewPassword => 'Mevcut ve yeni şifreyi gir';

  @override
  String get newPasswordsDoNotMatch => 'Yeni şifreler eşleşmiyor';

  @override
  String get newPasswordMinLength => 'Yeni şifre en az 8 karakter olmalı';

  @override
  String get passwordChangedSessionsSignedOut =>
      'Şifre değiştirildi. Diğer oturumlar kapatıldı.';

  @override
  String get couldNotChangePassword => 'Şifre değiştirilemedi';

  @override
  String get clubsAndRoles => 'Kulüpler ve roller';

  @override
  String get noRoleGrants => 'Bu hesapta atanmış rol yok.';

  @override
  String get currentPassword => 'Mevcut şifre';

  @override
  String get newPassword => 'Yeni şifre';

  @override
  String get passwordRequirementsHint =>
      '≥8 karakter, büyük, küçük harf ve rakam';

  @override
  String get confirmNewPassword => 'Yeni şifreyi onayla';

  @override
  String get emailVerified => 'E-posta doğrulandı';

  @override
  String get verificationPending => 'Doğrulama bekleniyor';

  @override
  String get emailNotVerified => 'E-posta doğrulanmadı';

  @override
  String get platformRoot => 'Platform kökü';

  @override
  String joinedMonthYear(String when) {
    return '$when katıldı';
  }

  @override
  String get overdue => 'vadesi geçmiş';

  @override
  String get voided => 'iptal edildi';

  @override
  String get voidLabel => 'iptal';

  @override
  String get relationshipSelf => 'kendisi';

  @override
  String get relationshipGuardian => 'veli';

  @override
  String get attendanceCanceledClosed => 'İptal edildi — yoklama kapalı';

  @override
  String get attendanceOpen => 'Yoklama açık';

  @override
  String get attendanceLockedShort => 'Yoklama kilitli';

  @override
  String get age => 'Yaş';

  @override
  String get pendingConsents => 'Bekleyen onaylar';

  @override
  String get noPendingConsents => 'Seni bekleyen onay yok.';

  @override
  String get familyMembers => 'Aile';

  @override
  String get noFamilyMembers => 'Bu hesaba bağlı aile üyesi yok.';

  @override
  String get notificationPreferences => 'Bildirim tercihleri';

  @override
  String get noNotificationPreferences =>
      'Kullanılabilir e-posta bildirim tercihi yok.';

  @override
  String get prefsLoadFailed => 'Tercihler yüklenemedi';

  @override
  String get familyLoadFailed => 'Aile yüklenemedi';

  @override
  String get consentsLoadFailed => 'Onaylar yüklenemedi';

  @override
  String get grantConsent => 'Onayla';

  @override
  String get consentGrantedSnack => 'Onay verildi';

  @override
  String get consentGrantFailed => 'Onay verilemedi';

  @override
  String consentVersion(int version) {
    return 'Sürüm $version';
  }

  @override
  String get consentReasonNeverGranted => 'Henüz verilmedi';

  @override
  String get consentReasonWithdrawn => 'Daha önce geri çekildi';

  @override
  String get consentReasonNewVersion => 'Yeni sürüm mevcut';

  @override
  String get consentReasonOther => 'İşlem gerekli';

  @override
  String get reviewAndGrantConsent => 'İncele ve onayla';

  @override
  String consentForMember(String name) {
    return '$name için onay';
  }

  @override
  String get enrolled => 'Kayıtlı';

  @override
  String get notEnrolled => 'Kayıtlı değil';

  @override
  String get consentOk => 'Onay tamam';

  @override
  String get consentMissing => 'Onay eksik';

  @override
  String get channelEmail => 'E-posta';

  @override
  String channelOther(String channel) {
    return '$channel';
  }

  @override
  String get preferenceDefault => 'Varsayılan';

  @override
  String get changePhoto => 'Fotoğrafı değiştir';

  @override
  String get changeYourPhoto => 'Fotoğrafını değiştir';

  @override
  String changeChildPhoto(String name) {
    return '$name adlı kişinin fotoğrafını değiştir';
  }

  @override
  String get takePhoto => 'Fotoğraf çek';

  @override
  String get chooseFromLibrary => 'Galeriden seç';

  @override
  String get removePhoto => 'Fotoğrafı kaldır';

  @override
  String get photoUpdated => 'Fotoğraf güncellendi';

  @override
  String get photoRemoved => 'Fotoğraf kaldırıldı';

  @override
  String get photoUpdateFailed => 'Fotoğraf güncellenemedi';

  @override
  String get photoNeedLinkedMember =>
      'Bu giriş bir üye kaydına bağlı değil. Aşağıdan bir aile üyesinin fotoğrafını değiştir veya profilini aç.';

  @override
  String get photoSelectClubFirst => 'Önce bir kulüp seç, sonra tekrar dene.';

  @override
  String get photoNoPermission => 'Bu fotoğrafı değiştirme iznin yok.';

  @override
  String get documents => 'Belgeler';

  @override
  String get yourDocuments => 'Belgelerin';

  @override
  String clubDocumentsTitle(String club) {
    return '$club belgeleri';
  }

  @override
  String get complianceOverview => 'Özet';

  @override
  String get reviewQueue => 'İnceleme';

  @override
  String get noDocumentsPending => 'İnceleme bekleyen belge yok.';

  @override
  String get noComplianceMembers => 'Herkes uygun.';

  @override
  String get complianceValid => 'Geçerli';

  @override
  String get complianceExpiring => 'Süresi doluyor';

  @override
  String get complianceMissing => 'Eksik';

  @override
  String get complianceUnknown => 'Bilinmiyor';

  @override
  String get requirementRequired => 'Zorunlu';

  @override
  String get requirementOptional => 'İsteğe bağlı';

  @override
  String get uploadDocument => 'Yükle';

  @override
  String get choosePdf => 'PDF veya dosya seç';

  @override
  String get issuedOn => 'Düzenleme tarihi';

  @override
  String get issuedOnHint =>
      'Sertifikada basılı bir tarih varsa ekle; süre o günden sayılır.';

  @override
  String get expiresOn => 'Son geçerlilik';

  @override
  String expiresOnDate(String date) {
    return '$date tarihinde doluyor';
  }

  @override
  String get documentPending => 'İncelemede';

  @override
  String get documentVerified => 'Onaylandı';

  @override
  String get documentRejected => 'Reddedildi';

  @override
  String get documentAwaitingUpload => 'Yükleme başladı';

  @override
  String get viewDocument => 'Görüntüle';

  @override
  String get deleteDocument => 'Sil';

  @override
  String get verifyDocument => 'Onayla';

  @override
  String get rejectDocument => 'Reddet';

  @override
  String get rejectionReason => 'Aileye gerekçe';

  @override
  String get askFamily => 'Aileden iste';

  @override
  String familyAsked(int count) {
    return '$count aile hesabına soruldu';
  }

  @override
  String get familyAlreadyAsked => 'Bugün zaten soruldu';

  @override
  String get documentUploaded => 'Belge yüklendi — inceleme bekleniyor';

  @override
  String get uploadFailed => 'Belge yüklenemedi';

  @override
  String get couldNotLoadCompliance => 'Belgeler yüklenemedi';

  @override
  String get signInToSeeDocuments => 'Belgeleri yönetmek için giriş yap';

  @override
  String get contentViewAudited => 'Bu dosyayı açmak kaydedilir';

  @override
  String get noRequirements => 'Bu üye için belge şartı yok.';

  @override
  String get confirmDeleteDocument => 'Bu belge kaldırılsın mı?';

  @override
  String get rejectReasonRequired => 'Neden reddedildiğini yaz';

  @override
  String get documentVerifiedSnack => 'Belge onaylandı';

  @override
  String get documentRejectedSnack => 'Belge reddedildi';

  @override
  String get documentDeleted => 'Belge kaldırıldı';

  @override
  String get documentTooLarge => 'Dosya 15 MB veya daha küçük olmalı';

  @override
  String get couldNotOpenDocument => 'Dosya açılamadı';

  @override
  String get aboutTagline => 'Yönet. İlham ver. Birlikte kazanın.';

  @override
  String get aboutIntro =>
      'ChampHive, spor kulüpleri, antrenörler ve ebeveynler için hepsi bir arada platformdur. Takımların düzenli kalmasına, daha iyi iletişim kurmasına ve her sporcuyu geliştirmesine yardımcı oluruz.';

  @override
  String aboutVersion(String version) {
    return 'Sürüm $version';
  }

  @override
  String get aboutMissionTitle => 'Misyonumuz';

  @override
  String get aboutMissionSubtitle =>
      'Spor takımlarının tam potansiyellerine ulaşmasına güç katıyoruz.';

  @override
  String get aboutMissionBody =>
      'Her kulüp, sahadaki enerjiye yakışan araçları hak eder.\n\nChampHive, antrenörlerin ve ebeveynlerin üzerindeki idari yükü azaltmak için var; böylece daha fazla zaman antrenmana, gelişime ve takımı oluşturan insanlara kalır. Gerçek kulüp hayatına göre tasarlıyoruz: yoğun akşamlar, karışık yaş grupları ve önemseyen gönüllüler.';

  @override
  String get aboutTeamsTitle => 'Takımlar için tasarlandı';

  @override
  String get aboutTeamsSubtitle =>
      'Antrenörler, oyuncular ve ebeveynler düşünülerek tasarlandı.';

  @override
  String get aboutTeamsBody =>
      'Antrenörler, oyuncular, ebeveynler ve kulüp personeli aynı sezonun net bir görünümüne ihtiyaç duyar — üç ayrı uygulamaya değil.\n\nChampHive bu rollere göre kuruldu. Antrenman, yoklama, mesajlar, ödemeler ve belgeler tek yerde kalır; her kişi için doğru erişimle.';

  @override
  String get aboutPrivacyTitle => 'Verilerin önemli';

  @override
  String get aboutPrivacySubtitle =>
      'Gizlilik ve veri güvenliğini ciddiye alıyoruz.';

  @override
  String get aboutPrivacyBody =>
      'Kulüp verisi bir üründen çok bir güvendir.\n\nFotoğraflar, belgeler ve kişisel bilgiler kulübünün ve rolünün kapsamında kalır. ChampHive büyürken gizlilik ve güvenliği ciddiye alıyoruz ve yalnızca kulübün çalışması için gerekeni topluyoruz.';

  @override
  String get aboutMadeWith => 'Hazırlayan';

  @override
  String get aboutMadeBy => 'Codeantech';

  @override
  String get aboutCodeantechBlurb =>
      'Codeantech, işletmelerin ve toplulukların teknolojiyle büyümesine yardımcı olan dijital çözümler üretir.';

  @override
  String aboutCopyright(String year) {
    return '© $year Codeantech. Tüm hakları saklıdır.';
  }

  @override
  String get aboutCouldNotOpenWebsite => 'Web sitesi açılamadı';

  @override
  String get sessionDetails => 'Seans ayrıntıları';

  @override
  String get sessionDetailsSubtitle =>
      'API’den başlık, saat, konum ve diğer alanlar';

  @override
  String get sessionDetailsIntro =>
      'Bu seans için kaydedilen ayrıntılar bunlardır.';

  @override
  String get purpose => 'Amaç';

  @override
  String get coaches => 'Antrenörler';

  @override
  String get trainingPlan => 'Antrenman planı';

  @override
  String get section => 'Bölüm';

  @override
  String get statusScheduled => 'Planlandı';

  @override
  String get statusMoved => 'Taşındı';

  @override
  String get statusCompleted => 'Tamamlandı';

  @override
  String get rsvpYes => 'İstendi';

  @override
  String get rsvpNo => 'İstenmedi';

  @override
  String get originallyScheduled => 'Orijinal';

  @override
  String durationMinutes(int minutes) {
    return '$minutes dk';
  }

  @override
  String get pickTrainingPlan => 'Antrenman planı (isteğe bağlı)';

  @override
  String get noTrainingPlan => 'Antrenman planı yok';

  @override
  String get noTrainingPlansYet => 'Bu kulüpte henüz antrenman planı yok.';

  @override
  String get couldNotLoadTrainingPlan => 'Antrenman planı yüklenemedi';

  @override
  String get trainingPlanExercises => 'Egzersizler';

  @override
  String trainingPlanDurationSummary(String session, String drills) {
    return '$session seans · $drills egzersiz';
  }

  @override
  String repetitionsValue(String count) {
    return '$count tekrar';
  }

  @override
  String get watchVideo => 'Videoyu izle';

  @override
  String get exercises => 'Egzersizler';

  @override
  String get noCoachesYet => 'Henüz antrenör atanmadı';

  @override
  String get noTrainingPlanAttached => 'Bu seansa antrenman planı eklenmedi';

  @override
  String get noExercisesInPlan => 'Bu planda henüz egzersiz yok';

  @override
  String get rsvpNotRequestedLabel => 'RSVP istenmedi';
}

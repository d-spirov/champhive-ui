// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Macedonian (`mk`).
class AppLocalizationsMk extends AppLocalizations {
  AppLocalizationsMk([String locale = 'mk']) : super(locale);

  @override
  String get appTitle => 'ChampHive';

  @override
  String get team => 'Тим';

  @override
  String get hive => 'Кошница';

  @override
  String get email => 'Е-пошта';

  @override
  String get password => 'Лозинка';

  @override
  String get confirmPassword => 'Потврди лозинка';

  @override
  String get firstName => 'Име';

  @override
  String get lastName => 'Презиме';

  @override
  String get phone => 'Телефон';

  @override
  String get logIn => 'Најави се';

  @override
  String get signUp => 'Регистрирај се';

  @override
  String get logOut => 'Одјави се';

  @override
  String get dontHaveAccount => 'Немаш профил? ';

  @override
  String get alreadyHaveAccount => 'Веќе имаш профил? ';

  @override
  String get pleaseEnterEmail => 'Внеси ја својата е-пошта';

  @override
  String get pleaseEnterValidEmail => 'Внеси валидна е-пошта';

  @override
  String get pleaseEnterPassword => 'Внеси ја својата лозинка';

  @override
  String get pleaseEnterFirstName => 'Внеси го своето име';

  @override
  String get pleaseEnterLastName => 'Внеси го своето презиме';

  @override
  String get pleaseConfirmPassword => 'Потврди ја лозинката';

  @override
  String get passwordsDoNotMatch => 'Лозинките не се совпаѓаат';

  @override
  String get passwordMinLength => 'Лозинката мора да има најмалку 8 знаци';

  @override
  String get loginFailed => 'Најавата не успеа. Провери ги податоците.';

  @override
  String get faceIdSignInPrompt => 'Користете Face ID за најава';

  @override
  String get signInWithFaceId => 'Најава со Face ID';

  @override
  String get registrationFailed =>
      'Регистрацијата не успеа. Обиди се повторно.';

  @override
  String get myClubs => 'Мои клубови';

  @override
  String get noClubsYet => 'Сè уште не си член на ниеден клуб.';

  @override
  String get home => 'Почетна';

  @override
  String get teams => 'Тимови';

  @override
  String get players => 'Играчи';

  @override
  String get members => 'Членови';

  @override
  String get events => 'Настани';

  @override
  String get schedule => 'Распоред';

  @override
  String get calendar => 'Календар';

  @override
  String get attendance => 'Присуство';

  @override
  String get messages => 'Пораки';

  @override
  String get notifications => 'Известувања';

  @override
  String get payments => 'Плаќања';

  @override
  String get statistics => 'Статистика';

  @override
  String get more => 'Повеќе';

  @override
  String get settings => 'Поставки';

  @override
  String get helpSupport => 'Помош и поддршка';

  @override
  String get myAccount => 'Мој профил';

  @override
  String get appearance => 'Изглед';

  @override
  String get language => 'Јазик';

  @override
  String get aboutApp => 'За ChampHive';

  @override
  String get moreManagement => 'Управување';

  @override
  String get moreAccount => 'Сметка';

  @override
  String get moreSupport => 'Поддршка';

  @override
  String get retry => 'Обиди се повторно';

  @override
  String get save => 'Зачувај';

  @override
  String get cancel => 'Откажи';

  @override
  String get create => 'Креирај';

  @override
  String get search => 'Пребарај';

  @override
  String get comingSoon => 'Наскоро';

  @override
  String comingSoonNamed(String label) {
    return '$label наскоро';
  }

  @override
  String get sessionExpired => 'Сесијата истече. Најави се повторно.';

  @override
  String get signInToContinue => 'Најави се за да продолжиш';

  @override
  String get selectClub => 'Избери клуб';

  @override
  String get selectClubFirst => 'Прво избери клуб';

  @override
  String get noData => 'Сè уште нема податоци';

  @override
  String get pullToRefresh => 'Повлечи за освежување';

  @override
  String get dismiss => 'Отфрли';

  @override
  String get continueAction => 'Продолжи';

  @override
  String get refresh => 'Освежи';

  @override
  String get history => 'Историја';

  @override
  String get report => 'Извештај';

  @override
  String get overview => 'Преглед';

  @override
  String get info => 'Инфо';

  @override
  String get notes => 'Белешки';

  @override
  String get note => 'Белешка';

  @override
  String get optionalNote => 'Опционална белешка';

  @override
  String get location => 'Локација';

  @override
  String get title => 'Наслов';

  @override
  String get type => 'Тип';

  @override
  String get scope => 'Опсег';

  @override
  String get when => 'Кога';

  @override
  String get repeat => 'Повторување';

  @override
  String get duration => 'Времетраење';

  @override
  String get amount => 'Износ';

  @override
  String get bank => 'Банка';

  @override
  String get importMethod => 'Увоз';

  @override
  String get member => 'Член';

  @override
  String get payment => 'Плаќање';

  @override
  String get chat => 'Разговор';

  @override
  String get session => 'Сесија';

  @override
  String get club => 'Клуб';

  @override
  String get status => 'Статус';

  @override
  String get timezone => 'Временска зона';

  @override
  String get contact => 'Контакт';

  @override
  String get gender => 'Пол';

  @override
  String get dateOfBirth => 'Датум на раѓање';

  @override
  String get registrationNumber => 'Регистарски бр.';

  @override
  String get shirtNumber => 'Број на дрес';

  @override
  String shirtNumberValue(String number) {
    return 'Дрес #$number';
  }

  @override
  String get themeLight => 'Светла';

  @override
  String get themeDark => 'Темна';

  @override
  String get themeSystem => 'Системска';

  @override
  String get languageEnglish => 'Англиски';

  @override
  String get languageMacedonian => 'Македонски';

  @override
  String get languageSerbian => 'Српски';

  @override
  String get languageItalian => 'Италијански';

  @override
  String get languageBosnian => 'Босански';

  @override
  String get languageTurkish => 'Турски';

  @override
  String get languageSystem => 'Системски јазик';

  @override
  String get newMessage => 'Нова порака';

  @override
  String get newSchedule => 'Нов распоред';

  @override
  String get markAllRead => 'Означи ги сите како прочитани';

  @override
  String get recordPayment => 'Евидентирај плаќање';

  @override
  String get profile => 'Профил';

  @override
  String get saveProfile => 'Зачувај профил';

  @override
  String get changePassword => 'Промени лозинка';

  @override
  String get outstanding => 'Неплатено';

  @override
  String get cash => 'Готовина';

  @override
  String get myFees => 'Мои обврски';

  @override
  String get membership => 'Членство';

  @override
  String get revenue => 'Приходи';

  @override
  String get exploreDemo => 'Истражи демо интерфејс';

  @override
  String get tagline => 'Твојот тим. Едно место.';

  @override
  String get continueWithGoogle => 'Продолжи со Google';

  @override
  String get continueWithApple => 'Продолжи со Apple';

  @override
  String get signInWithEmail => 'Најави се со е-пошта';

  @override
  String get orDivider => 'ИЛИ';

  @override
  String get newToChampHive => 'Нов на ChampHive? ';

  @override
  String get createAccount => 'Креирај профил!';

  @override
  String get accountsViaInviteNote =>
      'Профилите обично се создаваат преку покана. Регистрацијата може да биде само за оператори на овој API.';

  @override
  String get coachFallback => 'Тренер';

  @override
  String get goodMorning => 'Добро утро';

  @override
  String get goodAfternoon => 'Добар ден';

  @override
  String get goodEvening => 'Добра вечер';

  @override
  String get yourTeams => 'Твои тимови';

  @override
  String get yourClubs => 'Твои клубови';

  @override
  String get upcoming => 'Претстојни';

  @override
  String get recentActivity => 'Неодамнешна активност';

  @override
  String get nextMatch => 'Следен натпревар';

  @override
  String get tbd => 'Ќе се одреди';

  @override
  String get nothingOnScheduleToday =>
      'Нема ништо во распоредот денес. Отвори Календар за преглед.';

  @override
  String get nothingTodayNextUp => 'Ништо денес — следно';

  @override
  String get couldNotLoadClubs => 'Не можеа да се вчитаат клубовите';

  @override
  String get couldNotLoadSchedule => 'Не можеше да се вчита распоредот';

  @override
  String get couldNotLoadEvents => 'Не можеа да се вчитаат настаните';

  @override
  String get couldNotLoadTeams => 'Не можеа да се вчитаат тимовите';

  @override
  String get couldNotLoadMembers => 'Не можеа да се вчитаат членовите';

  @override
  String get couldNotLoadMember => 'Не можеше да се вчита членот';

  @override
  String get couldNotLoadRoster => 'Не можеше да се вчита составот';

  @override
  String get couldNotLoadSession => 'Не можеше да се вчита сесијата';

  @override
  String get couldNotLoadReport => 'Не можеше да се вчита извештајот';

  @override
  String get couldNotLoadHistory => 'Не можеше да се вчита историјата';

  @override
  String get couldNotLoadConversations => 'Не можеа да се вчитаат разговорите';

  @override
  String get couldNotLoadChat => 'Не можеше да се вчита разговорот';

  @override
  String get couldNotLoadPeople => 'Не можеа да се вчитаат луѓето';

  @override
  String get couldNotLoadNotifications =>
      'Не можеа да се вчитаат известувањата';

  @override
  String get couldNotLoadMore => 'Не можеше да се вчита повеќе';

  @override
  String get couldNotLoadObligations => 'Не можеа да се вчитаат обврските';

  @override
  String get couldNotLoadPayments => 'Не можеа да се вчитаат плаќањата';

  @override
  String get couldNotLoadFees => 'Не можеа да се вчитаат твоите обврски';

  @override
  String get couldNotLoadClub => 'Не можеше да се вчита клубот';

  @override
  String get couldNotLoadMembershipStats =>
      'Не можеше да се вчита статистиката за членство';

  @override
  String get couldNotLoadRevenueStats =>
      'Не можеше да се вчита статистиката за приходи';

  @override
  String get couldNotCreateSchedule => 'Не можеше да се креира распоред';

  @override
  String get couldNotSaveStatus => 'Не можеше да се зачува статусот';

  @override
  String get couldNotSaveAttendance => 'Не можеше да се зачува присуството';

  @override
  String get couldNotSendMessage => 'Не можеше да се испрати пораката';

  @override
  String get couldNotOpenConversation => 'Не можеше да се отвори разговорот';

  @override
  String get couldNotMarkAsRead => 'Не можеше да се означи како прочитано';

  @override
  String get couldNotRecordPayment => 'Не можеше да се евидентира плаќањето';

  @override
  String get signInToCreateSchedule =>
      'Најави се за да креираш ставки во распоредот';

  @override
  String get signInToOpenChat => 'Најави се за да отвориш жив разговор';

  @override
  String get signInToSeeNotifications =>
      'Најави се за да ги видиш известувањата.';

  @override
  String get signInToManagePayments =>
      'Најави се за да ги управуваш плаќањата на клубот.';

  @override
  String get signInToSeeFees => 'Најави се за да ги видиш твоите обврски.';

  @override
  String get signInToSeeStats =>
      'Најави се за да ја видиш аналитиката за членство и приходи.';

  @override
  String get signInToLoadTeams =>
      'Најави се за да ги вчиташ тимовите на клубот од API.';

  @override
  String get selectClubToViewTeams => 'Избери клуб за да ги видиш тимовите.';

  @override
  String get selectClubToViewMembers => 'Избери клуб за да ги видиш членовите.';

  @override
  String get selectClubToViewCharges =>
      'Избери клуб за да ги видиш задолжувањата.';

  @override
  String get selectClubToViewPayments =>
      'Избери клуб за да ги видиш плаќањата.';

  @override
  String get selectClubToViewMembershipStats =>
      'Избери клуб за статистика за членство.';

  @override
  String get selectClubToViewRevenueStats =>
      'Избери клуб за статистика за приходи.';

  @override
  String get noClubSelected => 'Не е избран клуб.';

  @override
  String get noEventsOnThisDay => 'Нема настани на овој ден.';

  @override
  String get demoSchedule => 'Демо распоред';

  @override
  String get noTeamsYet => 'Сè уште нема тимови во овој клуб.';

  @override
  String get tapToOpenRoster => 'Допри за да го отвориш составот';

  @override
  String get noMembersFound => 'Не се пронајдени членови за овој клуб.';

  @override
  String get searchMembers => 'Пребарај членови';

  @override
  String get searchMessages => 'Пребарај пораки';

  @override
  String get searchPeople => 'Пребарај луѓе';

  @override
  String get noConversations => 'Нема разговори.';

  @override
  String get noConversationsYet => 'Сè уште нема разговори.';

  @override
  String get noMessagesYet => 'Сè уште нема пораки.';

  @override
  String get messageDeleted => 'Пораката е избришана';

  @override
  String get yesterday => 'Вчера';

  @override
  String get noMatches => 'Нема совпаѓања.';

  @override
  String get noAdultsToMessage =>
      'Сè уште нема возрасни за пораки.\nЛуѓето се појавуваат овде од персоналот на клубот и тимските разговори.';

  @override
  String get sayHello => 'Кажи здраво';

  @override
  String get messageHint => 'Порака';

  @override
  String get readOnly => 'Само за читање';

  @override
  String get systemMessage => 'Систем';

  @override
  String get cannotSendInChannel => 'Не можеш да испраќаш во овој канал';

  @override
  String get couldNotLoadOlder => 'Не можеа да се вчитаат постарите';

  @override
  String get noNotificationsYet => 'Сè уште нема известувања.';

  @override
  String get loadMore => 'Вчитај повеќе';

  @override
  String get nothingOutstanding => 'Нема неплатени обврски.';

  @override
  String get noPaymentsYet => 'Сè уште нема евидентирани плаќања.';

  @override
  String get noOpenFamilyFees => 'Нема отворени семејни обврски.';

  @override
  String get noFeeHistoryYet => 'Сè уште нема историја на обврски.';

  @override
  String get openCharges => 'Отворени задолжувања';

  @override
  String get youOwe => 'Должиш';

  @override
  String get paymentReference => 'Референца за плаќање';

  @override
  String get mixedCurrencies => 'Мешани валути';

  @override
  String get noFamilyMembersLinked => 'Нема поврзани членови на семејството';

  @override
  String copiedLabel(String label) {
    return 'Копирано $label';
  }

  @override
  String get memberId => 'ID на член';

  @override
  String get pasteMemberIdHint =>
      'Нема отворени задолжувања — залепи ID на член';

  @override
  String get notesOptional => 'Белешки (опционално)';

  @override
  String get savePayment => 'Зачувај плаќање';

  @override
  String get pickAMember => 'Избери член';

  @override
  String get enterValidAmount => 'Внеси валиден износ';

  @override
  String openListedSummary(int open, int total) {
    return '$open отворени · $total наведени';
  }

  @override
  String membersCountLabel(int count) {
    return '$count член(ови)';
  }

  @override
  String get titleRequired => 'Насловот е задолжителен';

  @override
  String get pickATeam => 'Избери тим';

  @override
  String createdNamed(String title) {
    return 'Креирано „$title“';
  }

  @override
  String get purposeOptional => 'Цел (опционално)';

  @override
  String get locationOptional => 'Локација (опционално)';

  @override
  String get titleHintTraining => 'на пр. тренинг U14';

  @override
  String get titleHintTesting => 'на пр. физичко тестирање U14';

  @override
  String get wholeClub => 'Цел клуб';

  @override
  String get noTeamsCreateOrClub =>
      'Нема тимови во овој клуб. Прво креирај тим или користи Цел клуб.';

  @override
  String get duration45 => '45 мин';

  @override
  String get duration60 => '60 мин';

  @override
  String get duration75 => '75 мин';

  @override
  String get duration90 => '90 мин';

  @override
  String get duration2h => '2 часа';

  @override
  String get duration3h => '3 часа';

  @override
  String get oneOff => 'Еднократно';

  @override
  String get weekly => 'Неделно';

  @override
  String get daily => 'Дневно';

  @override
  String get numberOfOccurrences => 'Број на повторувања';

  @override
  String get requestRsvp => 'Барај RSVP';

  @override
  String get requestRsvpSubtitle =>
      'Семејствата можат однапред да го потврдат присуството';

  @override
  String get eventTypeTraining => 'Тренинг';

  @override
  String get eventTypeMatch => 'Натпревар';

  @override
  String get eventTypeClubEvent => 'Клубски настан';

  @override
  String get eventTypeTournament => 'Турнир';

  @override
  String get eventTypeTesting => 'Тестирање';

  @override
  String get eventTypeEvent => 'Настан';

  @override
  String get statusPresent => 'Присутен';

  @override
  String get statusAbsent => 'Отсутен';

  @override
  String get statusLate => 'Доцни';

  @override
  String get statusExcused => 'Оправдан';

  @override
  String get statusUnmarked => 'Неозначен';

  @override
  String get takeAttendance => 'Евидентирај присуство';

  @override
  String get roster => 'Состав';

  @override
  String rosterCount(int count) {
    return 'Состав ($count)';
  }

  @override
  String get summary => 'Резиме';

  @override
  String get reloadRoster => 'Превчитај состав';

  @override
  String get saveRemaining => 'Зачувај преостанати';

  @override
  String get skipNote => 'Прескокни белешка';

  @override
  String get tapMemberToMark =>
      'Допри член за означување — статусот веднаш се зачувува на серверот';

  @override
  String noMembersOnRoster(String scope) {
    return 'Нема членови во составот за $scope.';
  }

  @override
  String get thisSession => 'оваа сесија';

  @override
  String get attendanceLocked => 'Присуството е заклучено за оваа сесија.';

  @override
  String get sessionCanceled => 'Оваа сесија е откажана.';

  @override
  String get unmarkedCannotBeSaved =>
      'Неозначеното не може да се зачува — прво избери статус.';

  @override
  String get allMarksAlreadySaved => 'Сите ознаки веќе се зачувани.';

  @override
  String rsvpStatus(String status) {
    return 'RSVP: $status';
  }

  @override
  String markNamed(String name) {
    return 'Означи $name';
  }

  @override
  String get optionalNoteSynced =>
      'Опционална белешка (синхронизирана со ознаката)';

  @override
  String get attendanceReport => 'Извештај за присуство';

  @override
  String get openWindow => 'Отворен период';

  @override
  String get past => 'Минати';

  @override
  String get noSessionsInWindow =>
      'Моментално нема сесии во периодот за присуство.';

  @override
  String get noPastSessions => 'Сè уште нема минати сесии.';

  @override
  String get attendanceSynced => 'Присуството е синхронизирано';

  @override
  String get attendancePartiallySynced =>
      'Присуството е делумно синхронизирано';

  @override
  String get marksSentToPlatform =>
      'Ознаките се испратени до клубската платформа.';

  @override
  String marksAppliedRejected(int applied, int rejected) {
    return '$applied применети · $rejected одбиени';
  }

  @override
  String get superseded => 'заменето';

  @override
  String get backToSession => 'Назад кон сесијата';

  @override
  String get viewReport => 'Види извештај';

  @override
  String get attendanceHistory => 'Историја на присуство';

  @override
  String get trainingLocation => 'Локација на тренинг';

  @override
  String get active => 'Активен';

  @override
  String get season => 'Сезона';

  @override
  String get noMembersOnTeamRoster => 'Нема членови во составот на овој тим.';

  @override
  String get noUpcomingSessionsForTeam => 'Нема претстојни сесии за овој тим.';

  @override
  String get teamChat => 'Тимски разговор';

  @override
  String get couldNotOpenTeamChat => 'Тимскиот разговор сè уште не е достапен.';

  @override
  String get quickActions => 'Брзи акции';

  @override
  String get addEvent => 'Додај настан';

  @override
  String get nextUp => 'Следно';

  @override
  String get viewAll => 'Види сè';

  @override
  String get viewDetails => 'Детали';

  @override
  String get viewAllMembers => 'Сите членови';

  @override
  String get details => 'Детали';

  @override
  String get ageGroup => 'Возрасна група';

  @override
  String playersCount(int count) {
    return '$count играчи';
  }

  @override
  String seasonNamed(String label) {
    return 'Сезона $label';
  }

  @override
  String goingAwaiting(int going, int awaiting) {
    return '$going доаѓаат • $awaiting чекаат';
  }

  @override
  String get noSessionToTakeAttendance =>
      'Нема претстоен термин за евиденција.';

  @override
  String get playerProfile => 'Профил на играч';

  @override
  String get noProfileDetailsYet => 'Сè уште нема детали за профилот.';

  @override
  String get notAssignedToTeam => 'Не е распореден во тим.';

  @override
  String get noNotesYet => 'Сè уште нема белешки.';

  @override
  String get demoNotes => 'Демо белешки';

  @override
  String get canceled => 'Откажано';

  @override
  String get loadingAttendanceStatus => 'Се вчитува статусот на присуство…';

  @override
  String get loadRosterAndMark => 'Вчитај состав и означи членови';

  @override
  String get viewLockedReport => 'Види го извештајот за оваа заклучена сесија';

  @override
  String get rosterWithStatuses =>
      'Состав со присутен / доцни / отсутен / оправдан';

  @override
  String get pastAndOpenSessions => 'Минати и отворени сесии за присуство';

  @override
  String get refreshAttendanceStatus => 'Освежи статус на присуство';

  @override
  String marksAcceptedUntil(String date, String time) {
    return 'Ознаки се прифаќаат до $date · $time';
  }

  @override
  String clubStatsTitle(String name) {
    return 'Статистика за $name';
  }

  @override
  String get noMembershipData => 'Нема податоци за членство.';

  @override
  String get noRevenueData => 'Нема податоци за приходи.';

  @override
  String get noTrendDataYet => 'Сè уште нема податоци за тренд.';

  @override
  String get noRevenueTrendYet => 'Сè уште нема тренд на приходи.';

  @override
  String asOfDate(String date) {
    return 'Заклучно со $date';
  }

  @override
  String asOfDateCurrency(String date, String currency) {
    return 'Заклучно со $date · $currency';
  }

  @override
  String get activeNow => 'Активни сега';

  @override
  String get onTheBooks => 'Во евиденција';

  @override
  String get joined12Mo => 'Приклучени (12 мес.)';

  @override
  String get left12Mo => 'Заминати (12 мес.)';

  @override
  String get unenrolledNoTeam => 'Незапишани (без тим)';

  @override
  String get collected => 'Наплатено';

  @override
  String get expected => 'Очекувано';

  @override
  String get collectionRate => 'Стапка на наплата';

  @override
  String get membersBilled => 'Задолжени членови';

  @override
  String get inDebt => 'Во долг';

  @override
  String get waived => 'Ослободено';

  @override
  String get monthlyEnrollment => 'Месечно запишување';

  @override
  String get agingOutstanding => 'Стареење (неплатено)';

  @override
  String get monthlyTrend => 'Месечен тренд';

  @override
  String get byTeam => 'По тим';

  @override
  String get bySection => 'По секција';

  @override
  String get notDue => 'Недостасано';

  @override
  String get days1To30 => '1–30 дена';

  @override
  String get days31To60 => '31–60 дена';

  @override
  String get days61To90 => '61–90 дена';

  @override
  String get days90Plus => '90+ дена';

  @override
  String activeCount(int count) {
    return '$count активни';
  }

  @override
  String joinedLeftDelta(int joined, int left) {
    return '+$joined / −$left';
  }

  @override
  String owedAmount(String amount) {
    return 'должи $amount';
  }

  @override
  String membersOwed(int count, String amount) {
    return '$count членови · должат $amount';
  }

  @override
  String get yourRoles => 'Твои улоги';

  @override
  String get useThisClub => 'Користи го овој клуб';

  @override
  String clubSelected(String name) {
    return '$name е избран';
  }

  @override
  String get namesRequired => 'Името и презимето се задолжителни';

  @override
  String get profileSaved => 'Профилот е зачуван';

  @override
  String get saveFailed => 'Зачувувањето не успеа';

  @override
  String get enterCurrentAndNewPassword => 'Внеси тековна и нова лозинка';

  @override
  String get newPasswordsDoNotMatch => 'Новите лозинки не се совпаѓаат';

  @override
  String get newPasswordMinLength =>
      'Новата лозинка мора да има најмалку 8 знаци';

  @override
  String get passwordChangedSessionsSignedOut =>
      'Лозинката е променета. Другите сесии се одјавени.';

  @override
  String get couldNotChangePassword => 'Не можеше да се промени лозинката';

  @override
  String get clubsAndRoles => 'Клубови и улоги';

  @override
  String get noRoleGrants => 'Нема доделени улоги на овој профил.';

  @override
  String get currentPassword => 'Тековна лозинка';

  @override
  String get newPassword => 'Нова лозинка';

  @override
  String get passwordRequirementsHint =>
      '≥8 знаци со голема, мала буква и цифра';

  @override
  String get confirmNewPassword => 'Потврди нова лозинка';

  @override
  String get emailVerified => 'Е-поштата е потврдена';

  @override
  String get verificationPending => 'Потврдата е во тек';

  @override
  String get emailNotVerified => 'Е-поштата не е потврдена';

  @override
  String get platformRoot => 'Платформски root';

  @override
  String joinedMonthYear(String when) {
    return 'Приклучен $when';
  }

  @override
  String get overdue => 'задоцнето';

  @override
  String get voided => 'поништено';

  @override
  String get voidLabel => 'поништено';

  @override
  String get relationshipSelf => 'себе';

  @override
  String get relationshipGuardian => 'старател';

  @override
  String get attendanceCanceledClosed => 'Откажано — присуството е затворено';

  @override
  String get attendanceOpen => 'Присуството е отворено';

  @override
  String get attendanceLockedShort => 'Присуството е заклучено';

  @override
  String get age => 'Возраст';

  @override
  String get pendingConsents => 'Согласности на чекање';

  @override
  String get noPendingConsents => 'Нема согласности што ве чекаат.';

  @override
  String get familyMembers => 'Семејство';

  @override
  String get noFamilyMembers =>
      'Нема членови на семејството поврзани со оваа сметка.';

  @override
  String get notificationPreferences => 'Преференци за известувања';

  @override
  String get noNotificationPreferences =>
      'Нема достапни преференци за е-пошта.';

  @override
  String get prefsLoadFailed => 'Не можеа да се вчитаат преференциите';

  @override
  String get familyLoadFailed => 'Не можеа да се вчита семејството';

  @override
  String get consentsLoadFailed => 'Не можеа да се вчитаат согласностите';

  @override
  String get grantConsent => 'Одобри';

  @override
  String get consentGrantedSnack => 'Согласноста е одобрена';

  @override
  String get consentGrantFailed => 'Не можеше да се одобри согласноста';

  @override
  String consentVersion(int version) {
    return 'Верзија $version';
  }

  @override
  String get consentReasonNeverGranted => 'Сè уште не е одобрена';

  @override
  String get consentReasonWithdrawn => 'Претходно повлечена';

  @override
  String get consentReasonNewVersion => 'Достапна е нова верзија';

  @override
  String get consentReasonOther => 'Потребна е акција';

  @override
  String get reviewAndGrantConsent => 'Прегледај и одобри';

  @override
  String consentForMember(String name) {
    return 'Согласност за $name';
  }

  @override
  String get enrolled => 'Запишан';

  @override
  String get notEnrolled => 'Не е запишан';

  @override
  String get consentOk => 'Согласност ОК';

  @override
  String get consentMissing => 'Нема согласност';

  @override
  String get channelEmail => 'Е-пошта';

  @override
  String channelOther(String channel) {
    return '$channel';
  }

  @override
  String get preferenceDefault => 'Стандардно';

  @override
  String get changePhoto => 'Промени фотографија';

  @override
  String get changeYourPhoto => 'Промени ја својата фотографија';

  @override
  String changeChildPhoto(String name) {
    return 'Промени ја фотографијата на $name';
  }

  @override
  String get takePhoto => 'Сликај';

  @override
  String get chooseFromLibrary => 'Избери од галерија';

  @override
  String get removePhoto => 'Отстрани фотографија';

  @override
  String get photoUpdated => 'Фотографијата е ажурирана';

  @override
  String get photoRemoved => 'Фотографијата е отстранета';

  @override
  String get photoUpdateFailed => 'Фотографијата не можеше да се ажурира';

  @override
  String get photoNeedLinkedMember =>
      'Оваа најава не е поврзана со член. Промени ја фотографијата на член од семејството подолу, или отвори го нивниот профил.';

  @override
  String get photoSelectClubFirst =>
      'Прво избери клуб, па обидете се повторно.';

  @override
  String get photoNoPermission =>
      'Немаш дозвола да ја промениш оваа фотографија.';

  @override
  String get documents => 'Документи';

  @override
  String get yourDocuments => 'Твои документи';

  @override
  String clubDocumentsTitle(String club) {
    return 'Документи — $club';
  }

  @override
  String get complianceOverview => 'Преглед';

  @override
  String get reviewQueue => 'За проверка';

  @override
  String get noDocumentsPending => 'Нема документи за проверка.';

  @override
  String get noComplianceMembers => 'Сè е во ред.';

  @override
  String get complianceValid => 'Важечко';

  @override
  String get complianceExpiring => 'Истекува';

  @override
  String get complianceMissing => 'Недостасува';

  @override
  String get complianceUnknown => 'Непознато';

  @override
  String get requirementRequired => 'Задолжително';

  @override
  String get requirementOptional => 'Изборно';

  @override
  String get uploadDocument => 'Прикачи';

  @override
  String get choosePdf => 'Избери PDF или датотека';

  @override
  String get issuedOn => 'Датум на издавање';

  @override
  String get issuedOnHint =>
      'Ако уверението има печатен датум, внеси го за рокот да се смета од тој ден.';

  @override
  String get expiresOn => 'Датум на истек';

  @override
  String expiresOnDate(String date) {
    return 'Истекува $date';
  }

  @override
  String get documentPending => 'На проверка';

  @override
  String get documentVerified => 'Потврдено';

  @override
  String get documentRejected => 'Одбиено';

  @override
  String get documentAwaitingUpload => 'Прикачувањето е започнато';

  @override
  String get viewDocument => 'Отвори';

  @override
  String get deleteDocument => 'Избриши';

  @override
  String get verifyDocument => 'Потврди';

  @override
  String get rejectDocument => 'Одбиј';

  @override
  String get rejectionReason => 'Образложение за семејството';

  @override
  String get askFamily => 'Побарај од семејството';

  @override
  String familyAsked(int count) {
    return 'Испратено до $count семеен налог';
  }

  @override
  String get familyAlreadyAsked => 'Веќе побарано денес';

  @override
  String get documentUploaded => 'Документот е прикачен — чека проверка';

  @override
  String get uploadFailed => 'Документот не можеше да се прикачи';

  @override
  String get couldNotLoadCompliance => 'Документите не можеа да се вчитаат';

  @override
  String get signInToSeeDocuments => 'Најави се за да ги управуваш документите';

  @override
  String get contentViewAudited => 'Отворањето на оваа датотека се евидентира';

  @override
  String get noRequirements => 'Нема барања за документи за овој член.';

  @override
  String get confirmDeleteDocument => 'Да се отстрани овој документ?';

  @override
  String get rejectReasonRequired => 'Наведи зошто е одбиено';

  @override
  String get documentVerifiedSnack => 'Документот е потврден';

  @override
  String get documentRejectedSnack => 'Документот е одбиен';

  @override
  String get documentDeleted => 'Документот е отстранет';

  @override
  String get documentTooLarge => 'Датотеката мора да биде 15 MB или помала';

  @override
  String get couldNotOpenDocument => 'Датотеката не можеше да се отвори';

  @override
  String get aboutTagline => 'Менаџирај. Инспирирај. Победувајте заедно.';

  @override
  String get aboutIntro =>
      'ChampHive е се-во-едно платформа за спортски клубови, тренери и родители. Им помагаме на тимовите да бидат организирани, подобро да комуницираат и да го развиваат секој спортист.';

  @override
  String aboutVersion(String version) {
    return 'Верзија $version';
  }

  @override
  String get aboutMissionTitle => 'Нашата мисија';

  @override
  String get aboutMissionSubtitle =>
      'Им помагаме на спортските тимови да го достигнат својот полн потенцијал.';

  @override
  String get aboutMissionBody =>
      'Секој клуб заслужува алатки што одговараат на енергијата на теренот.\n\nChampHive постои за да ја тргне администрацијата од тренерите и родителите, за повеќе време да оди на тренинзи, развој и луѓето што го прават тимот. Градиме за вистинскиот клупски живот — зафатени вечери, мешани возрасти и волонтери на кои им е гајле.';

  @override
  String get aboutTeamsTitle => 'Направено за тимови';

  @override
  String get aboutTeamsSubtitle =>
      'Дизајнирано со тренери, играчи и родители на ум.';

  @override
  String get aboutTeamsBody =>
      'Тренерите, играчите, родителите и клупскиот кадар треба јасен преглед на истата сезона — не три различни апликации.\n\nChampHive е изграден околу тие улоги. Тренинзи, присуство, пораки, плаќања и документи се на едно место, со правилен пристап за секоја личност.';

  @override
  String get aboutPrivacyTitle => 'Твоите податоци се важни';

  @override
  String get aboutPrivacySubtitle =>
      'Приватноста и безбедноста на податоците ги земаме сериозно.';

  @override
  String get aboutPrivacyBody =>
      'Клупските податоци се доверба, не производ.\n\nФотографиите, документите и личните податоци остануваат во рамки на твојот клуб и твојата улога. Приватноста и безбедноста ги земаме сериозно додека ChampHive расте, и собираме само она што му треба на клубот за да работи.';

  @override
  String get aboutMadeWith => 'Направено со';

  @override
  String get aboutMadeBy => 'од Codeantech';

  @override
  String get aboutCodeantechBlurb =>
      'Codeantech гради дигитални решенија што им помагаат на бизнисите и заедниците да растат преку технологија.';

  @override
  String aboutCopyright(String year) {
    return '© $year Codeantech. Сите права се задржани.';
  }

  @override
  String get aboutCouldNotOpenWebsite =>
      'Веб-страницата не можеше да се отвори';

  @override
  String get sessionDetails => 'Детали за сесијата';

  @override
  String get sessionDetailsSubtitle =>
      'Наслов, време, локација и други полиња од API';

  @override
  String get sessionDetailsIntro => 'Ова се деталите зачувани за оваа сесија.';

  @override
  String get purpose => 'Цел';

  @override
  String get coaches => 'Тренери';

  @override
  String get trainingPlan => 'План за тренинг';

  @override
  String get section => 'Секција';

  @override
  String get statusScheduled => 'Закажано';

  @override
  String get statusMoved => 'Преместено';

  @override
  String get statusCompleted => 'Завршено';

  @override
  String get rsvpYes => 'Побарано';

  @override
  String get rsvpNo => 'Не е побарано';

  @override
  String get originallyScheduled => 'Првично';

  @override
  String durationMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String get pickTrainingPlan => 'План за тренинг (опционално)';

  @override
  String get noTrainingPlan => 'Без план за тренинг';

  @override
  String get noTrainingPlansYet =>
      'Сè уште нема планови за тренинг во овој клуб.';

  @override
  String get couldNotLoadTrainingPlan =>
      'Планот за тренинг не можеше да се вчита';

  @override
  String get trainingPlanExercises => 'Вежби';

  @override
  String trainingPlanDurationSummary(String session, String drills) {
    return '$session сесија · $drills вежби';
  }

  @override
  String repetitionsValue(String count) {
    return '$count повторувања';
  }

  @override
  String get watchVideo => 'Гледај видео';

  @override
  String get exercises => 'Вежби';

  @override
  String get noCoachesYet => 'Сè уште нема доделени тренери';

  @override
  String get noTrainingPlanAttached =>
      'Нема прикачен план за тренинг на оваа сесија';

  @override
  String get noExercisesInPlan => 'Овој план сè уште нема вежби';

  @override
  String get rsvpNotRequestedLabel => 'Не е побарано RSVP';

  @override
  String get sport => 'Спорт';

  @override
  String get pickTestSet => 'Сет тестови';

  @override
  String get noTestSetsYet =>
      'Сè уште нема сетови тестови во овој клуб. Креирајте еден за да закажете ден за тестирање.';

  @override
  String get couldNotLoadTestSets => 'Сетовите тестови не можеа да се вчитаат';

  @override
  String get createTestSet => 'Креирај сет тестови';

  @override
  String get testSetName => 'Име на сетот';

  @override
  String get testSetNameRequired => 'Внесете име на сетот';

  @override
  String get pickMetrics => 'Станици (метрики)';

  @override
  String get pickAtLeastOneMetric => 'Изберете барем една метрика';

  @override
  String get testSetRequired =>
      'Изберете сет тестови. Денот за тестирање мора да каже кои метрики се мерат.';

  @override
  String get testSet => 'Сет тестови';

  @override
  String get couldNotLoadTestingDay =>
      'Денот за тестирање не можеше да се вчита';

  @override
  String get couldNotCreateTestSet => 'Сетот тестови не можеше да се креира';

  @override
  String get pickASport => 'Изберете спорт';

  @override
  String get noSportsForTestSets =>
      'Овој клуб сè уште нема спортови. Прво додајте секција.';

  @override
  String get noMetricsForSport => 'Нема метрики за овој спорт.';

  @override
  String stationCount(int count) {
    return '$count станици';
  }

  @override
  String get noStationsInTestSet => 'Овој сет сè уште нема станици';

  @override
  String get retiredStation => 'Повлечена';

  @override
  String get recordResults => 'Внеси резултати';

  @override
  String get recordResultsSubtitle => 'Внесете броеви за секоја станица';

  @override
  String get recordStation => 'Внес на станица';

  @override
  String get saveResults => 'Зачувај резултати';

  @override
  String get resultsSaved => 'Резултатите се зачувани';

  @override
  String someResultsFailed(int failed, int total) {
    return '$failed од $total не се зачувани';
  }

  @override
  String recordedOf(int done, int total) {
    return '$done од $total внесени';
  }

  @override
  String get noPlayersOnTestingDay => 'Нема состав на овој ден за тестирање.';

  @override
  String get stationRetiredCannotRecord =>
      'Оваа станица е повлечена и не прима нови вредности.';

  @override
  String get madeLabel => 'Погодени';

  @override
  String get attemptedLabel => 'Обиди';

  @override
  String get releaseResults => 'Објави резултати';

  @override
  String get resultsReleased =>
      'Резултатите се објавени во историјата на играчот';

  @override
  String get couldNotRecordResults => 'Резултатите не можеа да се зачуваат';

  @override
  String get noValuesToSave => 'Внесете барем една вредност пред зачувување.';

  @override
  String get teamRequiredForRecording =>
      'Внесувањето бара ден за тестирање врзан за тим.';

  @override
  String get tapStationToRecord =>
      'Допрете станица за да внесете броеви за составот.';

  @override
  String get noDraftsToRelease =>
      'Сè уште нема што да се објави. Прво зачувајте ги резултатите.';

  @override
  String get performance => 'Перформанси';

  @override
  String get noPerformanceYet =>
      'Сè уште нема објавени мерења. Внесете ден за тестирање, потоа Објави резултати.';

  @override
  String previousResult(String value) {
    return 'беше $value';
  }

  @override
  String get resultsThisSession => 'Броеви на оваа сесија';

  @override
  String get releaseResultsHint =>
      'Зачувувањето на станица ги остава броевите тука како нацрти. Објавата ги испраќа на картичката Перформанси на секој играч.';

  @override
  String get couldNotLoadPerformance => 'Перформансите не можеа да се вчитаат';

  @override
  String resultsReleasedCount(int count) {
    return 'Објавени $count мерења на профили';
  }
}

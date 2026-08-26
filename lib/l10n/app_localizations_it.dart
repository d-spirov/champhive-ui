// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'TeamHive';

  @override
  String get team => 'Squadra';

  @override
  String get hive => 'Alveare';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Conferma password';

  @override
  String get firstName => 'Nome';

  @override
  String get lastName => 'Cognome';

  @override
  String get phone => 'Telefono';

  @override
  String get logIn => 'Accedi';

  @override
  String get signUp => 'Registrati';

  @override
  String get logOut => 'Esci';

  @override
  String get dontHaveAccount => 'Non hai un account? ';

  @override
  String get alreadyHaveAccount => 'Hai già un account? ';

  @override
  String get pleaseEnterEmail => 'Inserisci la tua email';

  @override
  String get pleaseEnterValidEmail => 'Inserisci un\'email valida';

  @override
  String get pleaseEnterPassword => 'Inserisci la tua password';

  @override
  String get pleaseEnterFirstName => 'Inserisci il tuo nome';

  @override
  String get pleaseEnterLastName => 'Inserisci il tuo cognome';

  @override
  String get pleaseConfirmPassword => 'Conferma la password';

  @override
  String get passwordsDoNotMatch => 'Le password non corrispondono';

  @override
  String get passwordMinLength => 'La password deve avere almeno 8 caratteri';

  @override
  String get loginFailed => 'Accesso non riuscito. Controlla le credenziali.';

  @override
  String get faceIdSignInPrompt => 'Usa Face ID per accedere';

  @override
  String get signInWithFaceId => 'Accedi con Face ID';

  @override
  String get registrationFailed => 'Registrazione non riuscita. Riprova.';

  @override
  String get myClubs => 'I miei club';

  @override
  String get noClubsYet => 'Non sei ancora membro di nessun club.';

  @override
  String get home => 'Inizio';

  @override
  String get teams => 'Squadre';

  @override
  String get players => 'Giocatori';

  @override
  String get members => 'Membri';

  @override
  String get events => 'Eventi';

  @override
  String get schedule => 'Programma';

  @override
  String get calendar => 'Calendario';

  @override
  String get attendance => 'Presenze';

  @override
  String get messages => 'Messaggi';

  @override
  String get notifications => 'Notifiche';

  @override
  String get payments => 'Pagamenti';

  @override
  String get statistics => 'Statistiche';

  @override
  String get more => 'Altro';

  @override
  String get settings => 'Impostazioni';

  @override
  String get helpSupport => 'Aiuto e supporto';

  @override
  String get myAccount => 'Il mio account';

  @override
  String get appearance => 'Aspetto';

  @override
  String get language => 'Lingua';

  @override
  String get aboutApp => 'Informazioni su ChampHive';

  @override
  String get moreManagement => 'Gestione';

  @override
  String get moreAccount => 'Account';

  @override
  String get moreSupport => 'Supporto';

  @override
  String get retry => 'Riprova';

  @override
  String get save => 'Salva';

  @override
  String get cancel => 'Annulla';

  @override
  String get create => 'Crea';

  @override
  String get search => 'Cerca';

  @override
  String get comingSoon => 'Prossimamente';

  @override
  String comingSoonNamed(String label) {
    return '$label in arrivo';
  }

  @override
  String get sessionExpired => 'La sessione è scaduta. Accedi di nuovo.';

  @override
  String get signInToContinue => 'Accedi per continuare';

  @override
  String get selectClub => 'Seleziona un club';

  @override
  String get selectClubFirst => 'Seleziona prima un club';

  @override
  String get noData => 'Nessun dato ancora';

  @override
  String get pullToRefresh => 'Scorri per aggiornare';

  @override
  String get dismiss => 'Chiudi';

  @override
  String get continueAction => 'Continua';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get history => 'Cronologia';

  @override
  String get report => 'Rapporto';

  @override
  String get overview => 'Panoramica';

  @override
  String get info => 'Info';

  @override
  String get notes => 'Note';

  @override
  String get note => 'Nota';

  @override
  String get optionalNote => 'Nota facoltativa';

  @override
  String get location => 'Luogo';

  @override
  String get title => 'Titolo';

  @override
  String get type => 'Tipo';

  @override
  String get scope => 'Ambito';

  @override
  String get when => 'Quando';

  @override
  String get repeat => 'Ripeti';

  @override
  String get duration => 'Durata';

  @override
  String get amount => 'Importo';

  @override
  String get bank => 'Banca';

  @override
  String get importMethod => 'Importa';

  @override
  String get member => 'Membro';

  @override
  String get payment => 'Pagamento';

  @override
  String get chat => 'Chat';

  @override
  String get session => 'Sessione';

  @override
  String get club => 'Club';

  @override
  String get status => 'Stato';

  @override
  String get timezone => 'Fuso orario';

  @override
  String get contact => 'Contatto';

  @override
  String get gender => 'Genere';

  @override
  String get dateOfBirth => 'Data di nascita';

  @override
  String get registrationNumber => 'N. di registrazione';

  @override
  String get shirtNumber => 'Numero maglia';

  @override
  String shirtNumberValue(String number) {
    return 'Maglia #$number';
  }

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageMacedonian => 'Macedone';

  @override
  String get languageSerbian => 'Serbo';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageBosnian => 'Bosniaco';

  @override
  String get languageTurkish => 'Turco';

  @override
  String get languageSystem => 'Lingua di sistema';

  @override
  String get newMessage => 'Nuovo messaggio';

  @override
  String get newSchedule => 'Nuovo programma';

  @override
  String get markAllRead => 'Segna tutto come letto';

  @override
  String get recordPayment => 'Registra pagamento';

  @override
  String get profile => 'Profilo';

  @override
  String get saveProfile => 'Salva profilo';

  @override
  String get changePassword => 'Cambia password';

  @override
  String get outstanding => 'In sospeso';

  @override
  String get cash => 'Contanti';

  @override
  String get myFees => 'Le mie quote';

  @override
  String get membership => 'Iscrizione';

  @override
  String get revenue => 'Entrate';

  @override
  String get exploreDemo => 'Esplora l\'interfaccia demo';

  @override
  String get tagline => 'La tua squadra. Un solo posto.';

  @override
  String get continueWithGoogle => 'Continua con Google';

  @override
  String get continueWithApple => 'Continua con Apple';

  @override
  String get signInWithEmail => 'Accedi con e-mail';

  @override
  String get orDivider => 'O';

  @override
  String get newToChampHive => 'Nuovo su ChampHive? ';

  @override
  String get createAccount => 'Crea un account!';

  @override
  String get accountsViaInviteNote =>
      'Gli account di solito si creano tramite invito. La registrazione può essere riservata agli operatori su questa API.';

  @override
  String get coachFallback => 'Allenatore';

  @override
  String get goodMorning => 'Buongiorno';

  @override
  String get goodAfternoon => 'Buon pomeriggio';

  @override
  String get goodEvening => 'Buonasera';

  @override
  String get yourTeams => 'Le tue squadre';

  @override
  String get yourClubs => 'I tuoi club';

  @override
  String get upcoming => 'In arrivo';

  @override
  String get recentActivity => 'Attività recente';

  @override
  String get nextMatch => 'Prossima partita';

  @override
  String get tbd => 'Da definire';

  @override
  String get nothingOnScheduleToday =>
      'Niente in programma oggi. Apri Calendario per sfogliare.';

  @override
  String get nothingTodayNextUp => 'Niente oggi — prossimo';

  @override
  String get couldNotLoadClubs => 'Impossibile caricare i club';

  @override
  String get couldNotLoadSchedule => 'Impossibile caricare il programma';

  @override
  String get couldNotLoadEvents => 'Impossibile caricare gli eventi';

  @override
  String get couldNotLoadTeams => 'Impossibile caricare le squadre';

  @override
  String get couldNotLoadMembers => 'Impossibile caricare i membri';

  @override
  String get couldNotLoadMember => 'Impossibile caricare il membro';

  @override
  String get couldNotLoadRoster => 'Impossibile caricare la rosa';

  @override
  String get couldNotLoadSession => 'Impossibile caricare la sessione';

  @override
  String get couldNotLoadReport => 'Impossibile caricare il report';

  @override
  String get couldNotLoadHistory => 'Impossibile caricare la cronologia';

  @override
  String get couldNotLoadConversations =>
      'Impossibile caricare le conversazioni';

  @override
  String get couldNotLoadChat => 'Impossibile caricare la chat';

  @override
  String get couldNotLoadPeople => 'Impossibile caricare le persone';

  @override
  String get couldNotLoadNotifications => 'Impossibile caricare le notifiche';

  @override
  String get couldNotLoadMore => 'Impossibile caricare altro';

  @override
  String get couldNotLoadObligations => 'Impossibile caricare le obbligazioni';

  @override
  String get couldNotLoadPayments => 'Impossibile caricare i pagamenti';

  @override
  String get couldNotLoadFees => 'Impossibile caricare le tue quote';

  @override
  String get couldNotLoadClub => 'Impossibile caricare il club';

  @override
  String get couldNotLoadMembershipStats =>
      'Impossibile caricare le statistiche di iscrizione';

  @override
  String get couldNotLoadRevenueStats =>
      'Impossibile caricare le statistiche delle entrate';

  @override
  String get couldNotCreateSchedule => 'Impossibile creare il programma';

  @override
  String get couldNotSaveStatus => 'Impossibile salvare lo stato';

  @override
  String get couldNotSaveAttendance => 'Impossibile salvare le presenze';

  @override
  String get couldNotSendMessage => 'Impossibile inviare il messaggio';

  @override
  String get couldNotOpenConversation => 'Impossibile aprire la conversazione';

  @override
  String get couldNotMarkAsRead => 'Impossibile segnare come letto';

  @override
  String get couldNotRecordPayment => 'Impossibile registrare il pagamento';

  @override
  String get signInToCreateSchedule => 'Accedi per creare voci del programma';

  @override
  String get signInToOpenChat => 'Accedi per aprire la chat dal vivo';

  @override
  String get signInToSeeNotifications => 'Accedi per vedere le tue notifiche.';

  @override
  String get signInToManagePayments =>
      'Accedi per gestire i pagamenti del club.';

  @override
  String get signInToSeeFees => 'Accedi per vedere le tue quote.';

  @override
  String get signInToSeeStats =>
      'Accedi per vedere le analisi di iscrizione e entrate del club.';

  @override
  String get signInToLoadTeams =>
      'Accedi per caricare le squadre del club dall\'API.';

  @override
  String get selectClubToViewTeams =>
      'Seleziona un club per vedere le squadre.';

  @override
  String get selectClubToViewMembers =>
      'Seleziona un club per vedere i membri.';

  @override
  String get selectClubToViewCharges =>
      'Seleziona un club per vedere gli addebiti.';

  @override
  String get selectClubToViewPayments =>
      'Seleziona un club per vedere i pagamenti.';

  @override
  String get selectClubToViewMembershipStats =>
      'Seleziona un club per vedere le statistiche di iscrizione.';

  @override
  String get selectClubToViewRevenueStats =>
      'Seleziona un club per vedere le statistiche delle entrate.';

  @override
  String get noClubSelected => 'Nessun club selezionato.';

  @override
  String get noEventsOnThisDay => 'Nessun evento in questo giorno.';

  @override
  String get demoSchedule => 'Programma demo';

  @override
  String get noTeamsYet => 'Nessuna squadra in questo club ancora.';

  @override
  String get tapToOpenRoster => 'Tocca per aprire la rosa';

  @override
  String get noMembersFound => 'Nessun membro trovato per questo club.';

  @override
  String get searchMembers => 'Cerca membri';

  @override
  String get searchMessages => 'Cerca messaggi';

  @override
  String get searchPeople => 'Cerca persone';

  @override
  String get noConversations => 'Nessuna conversazione.';

  @override
  String get noConversationsYet => 'Nessuna conversazione ancora.';

  @override
  String get noMessagesYet => 'Nessun messaggio ancora.';

  @override
  String get messageDeleted => 'Messaggio eliminato';

  @override
  String get yesterday => 'Ieri';

  @override
  String get noMatches => 'Nessun risultato.';

  @override
  String get noAdultsToMessage =>
      'Nessun adulto a cui scrivere ancora.\nLe persone appaiono qui dallo staff del club e dalle chat della squadra.';

  @override
  String get sayHello => 'Di\' ciao';

  @override
  String get messageHint => 'Messaggio';

  @override
  String get readOnly => 'Solo lettura';

  @override
  String get systemMessage => 'Sistema';

  @override
  String get cannotSendInChannel => 'Non puoi inviare in questo canale';

  @override
  String get couldNotLoadOlder => 'Impossibile caricare i messaggi precedenti';

  @override
  String get noNotificationsYet => 'Nessuna notifica ancora.';

  @override
  String get loadMore => 'Carica altro';

  @override
  String get nothingOutstanding => 'Niente in sospeso.';

  @override
  String get noPaymentsYet => 'Nessun pagamento registrato ancora.';

  @override
  String get noOpenFamilyFees => 'Nessuna quota familiare aperta.';

  @override
  String get noFeeHistoryYet => 'Nessuna cronologia delle quote ancora.';

  @override
  String get openCharges => 'Addebiti aperti';

  @override
  String get youOwe => 'Devi';

  @override
  String get paymentReference => 'Riferimento pagamento';

  @override
  String get mixedCurrencies => 'Valute miste';

  @override
  String get noFamilyMembersLinked => 'Nessun membro della famiglia collegato';

  @override
  String copiedLabel(String label) {
    return 'Copiato $label';
  }

  @override
  String get memberId => 'ID membro';

  @override
  String get pasteMemberIdHint =>
      'Nessun addebito aperto — incolla l\'ID membro';

  @override
  String get notesOptional => 'Note (facoltative)';

  @override
  String get savePayment => 'Salva pagamento';

  @override
  String get pickAMember => 'Scegli un membro';

  @override
  String get enterValidAmount => 'Inserisci un importo valido';

  @override
  String openListedSummary(int open, int total) {
    return '$open aperti · $total elencati';
  }

  @override
  String membersCountLabel(int count) {
    return '$count membro/i';
  }

  @override
  String get titleRequired => 'Il titolo è obbligatorio';

  @override
  String get pickATeam => 'Scegli una squadra';

  @override
  String createdNamed(String title) {
    return 'Creato “$title”';
  }

  @override
  String get purposeOptional => 'Scopo (facoltativo)';

  @override
  String get locationOptional => 'Luogo (facoltativo)';

  @override
  String get titleHintTraining => 'es. allenamento U14';

  @override
  String get wholeClub => 'Tutto il club';

  @override
  String get noTeamsCreateOrClub =>
      'Nessuna squadra in questo club. Crea prima una squadra o usa Tutto il club.';

  @override
  String get duration45 => '45 min';

  @override
  String get duration60 => '60 min';

  @override
  String get duration75 => '75 min';

  @override
  String get duration90 => '90 min';

  @override
  String get duration2h => '2 ore';

  @override
  String get duration3h => '3 ore';

  @override
  String get oneOff => 'Una tantum';

  @override
  String get weekly => 'Settimanale';

  @override
  String get daily => 'Giornaliero';

  @override
  String get numberOfOccurrences => 'Numero di occorrenze';

  @override
  String get requestRsvp => 'Richiedi RSVP';

  @override
  String get requestRsvpSubtitle =>
      'Le famiglie possono confermare la presenza in anticipo';

  @override
  String get eventTypeTraining => 'Allenamento';

  @override
  String get eventTypeMatch => 'Partita';

  @override
  String get eventTypeClubEvent => 'Evento del club';

  @override
  String get eventTypeTournament => 'Torneo';

  @override
  String get eventTypeEvent => 'Evento';

  @override
  String get statusPresent => 'Presente';

  @override
  String get statusAbsent => 'Assente';

  @override
  String get statusLate => 'In ritardo';

  @override
  String get statusExcused => 'Giustificato';

  @override
  String get statusUnmarked => 'Non contrassegnato';

  @override
  String get takeAttendance => 'Registra le presenze';

  @override
  String get roster => 'Rosa';

  @override
  String rosterCount(int count) {
    return 'Rosa ($count)';
  }

  @override
  String get summary => 'Riepilogo';

  @override
  String get reloadRoster => 'Ricarica rosa';

  @override
  String get saveRemaining => 'Salva rimanenti';

  @override
  String get skipNote => 'Salta nota';

  @override
  String get tapMemberToMark =>
      'Tocca un membro per contrassegnare — lo stato viene salvato subito sul server';

  @override
  String noMembersOnRoster(String scope) {
    return 'Nessun membro nella rosa per $scope.';
  }

  @override
  String get thisSession => 'questa sessione';

  @override
  String get attendanceLocked =>
      'Le presenze sono bloccate per questa sessione.';

  @override
  String get sessionCanceled => 'Questa sessione è stata annullata.';

  @override
  String get unmarkedCannotBeSaved =>
      'Non contrassegnato non può essere salvato — scegli prima uno stato.';

  @override
  String get allMarksAlreadySaved =>
      'Tutte le contrassegnature sono già salvate.';

  @override
  String rsvpStatus(String status) {
    return 'RSVP: $status';
  }

  @override
  String markNamed(String name) {
    return 'Contrassegna $name';
  }

  @override
  String get optionalNoteSynced =>
      'Nota facoltativa (sincronizzata con la contrassegnatura)';

  @override
  String get attendanceReport => 'Report presenze';

  @override
  String get openWindow => 'Finestra aperta';

  @override
  String get past => 'Passate';

  @override
  String get noSessionsInWindow =>
      'Nessuna sessione nella finestra delle presenze al momento.';

  @override
  String get noPastSessions => 'Nessuna sessione passata ancora.';

  @override
  String get attendanceSynced => 'Presenze sincronizzate';

  @override
  String get attendancePartiallySynced => 'Presenze parzialmente sincronizzate';

  @override
  String get marksSentToPlatform =>
      'Le contrassegnature sono state inviate alla piattaforma del club.';

  @override
  String marksAppliedRejected(int applied, int rejected) {
    return '$applied applicate · $rejected rifiutate';
  }

  @override
  String get superseded => 'sostituito';

  @override
  String get backToSession => 'Torna alla sessione';

  @override
  String get viewReport => 'Vedi report';

  @override
  String get attendanceHistory => 'Cronologia presenze';

  @override
  String get trainingLocation => 'Luogo dell\'allenamento';

  @override
  String get active => 'Attivo';

  @override
  String get season => 'Stagione';

  @override
  String get noMembersOnTeamRoster =>
      'Nessun membro nella rosa di questa squadra.';

  @override
  String get noUpcomingSessionsForTeam =>
      'Nessuna sessione in arrivo per questa squadra.';

  @override
  String get playerProfile => 'Profilo giocatore';

  @override
  String get noProfileDetailsYet => 'Nessun dettaglio del profilo ancora.';

  @override
  String get notAssignedToTeam => 'Non assegnato a una squadra.';

  @override
  String get noNotesYet => 'Nessuna nota ancora.';

  @override
  String get demoNotes => 'Note demo';

  @override
  String get canceled => 'Annullato';

  @override
  String get loadingAttendanceStatus => 'Caricamento stato presenze…';

  @override
  String get loadRosterAndMark => 'Carica la rosa e contrassegna i membri';

  @override
  String get viewLockedReport => 'Vedi il report di questa sessione bloccata';

  @override
  String get rosterWithStatuses =>
      'Rosa con presente / in ritardo / assente / giustificato';

  @override
  String get pastAndOpenSessions => 'Sessioni passate e aperte per le presenze';

  @override
  String get refreshAttendanceStatus => 'Aggiorna stato presenze';

  @override
  String marksAcceptedUntil(String date, String time) {
    return 'Contrassegnature accettate fino al $date · $time';
  }

  @override
  String clubStatsTitle(String name) {
    return 'Statistiche di $name';
  }

  @override
  String get noMembershipData => 'Nessun dato di iscrizione.';

  @override
  String get noRevenueData => 'Nessun dato sulle entrate.';

  @override
  String get noTrendDataYet => 'Nessun dato di tendenza ancora.';

  @override
  String get noRevenueTrendYet => 'Nessuna tendenza delle entrate ancora.';

  @override
  String asOfDate(String date) {
    return 'Al $date';
  }

  @override
  String asOfDateCurrency(String date, String currency) {
    return 'Al $date · $currency';
  }

  @override
  String get activeNow => 'Attivi ora';

  @override
  String get onTheBooks => 'In evidenza';

  @override
  String get joined12Mo => 'Iscritti (12 mesi)';

  @override
  String get left12Mo => 'Usciti (12 mesi)';

  @override
  String get unenrolledNoTeam => 'Non iscritti (senza squadra)';

  @override
  String get collected => 'Incassato';

  @override
  String get expected => 'Previsto';

  @override
  String get collectionRate => 'Tasso di riscossione';

  @override
  String get membersBilled => 'Membri fatturati';

  @override
  String get inDebt => 'In debito';

  @override
  String get waived => 'Esonerato';

  @override
  String get monthlyEnrollment => 'Iscrizioni mensili';

  @override
  String get agingOutstanding => 'Invecchiamento (in sospeso)';

  @override
  String get monthlyTrend => 'Tendenza mensile';

  @override
  String get byTeam => 'Per squadra';

  @override
  String get bySection => 'Per sezione';

  @override
  String get notDue => 'Non scaduto';

  @override
  String get days1To30 => '1–30 giorni';

  @override
  String get days31To60 => '31–60 giorni';

  @override
  String get days61To90 => '61–90 giorni';

  @override
  String get days90Plus => '90+ giorni';

  @override
  String activeCount(int count) {
    return '$count attivi';
  }

  @override
  String joinedLeftDelta(int joined, int left) {
    return '+$joined / −$left';
  }

  @override
  String owedAmount(String amount) {
    return 'deve $amount';
  }

  @override
  String membersOwed(int count, String amount) {
    return '$count membri · devono $amount';
  }

  @override
  String get yourRoles => 'I tuoi ruoli';

  @override
  String get useThisClub => 'Usa questo club';

  @override
  String clubSelected(String name) {
    return '$name selezionato';
  }

  @override
  String get namesRequired => 'Nome e cognome sono obbligatori';

  @override
  String get profileSaved => 'Profilo salvato';

  @override
  String get saveFailed => 'Salvataggio non riuscito';

  @override
  String get enterCurrentAndNewPassword =>
      'Inserisci la password attuale e quella nuova';

  @override
  String get newPasswordsDoNotMatch => 'Le nuove password non corrispondono';

  @override
  String get newPasswordMinLength =>
      'La nuova password deve avere almeno 8 caratteri';

  @override
  String get passwordChangedSessionsSignedOut =>
      'Password modificata. Le altre sessioni sono state disconnesse.';

  @override
  String get couldNotChangePassword => 'Impossibile cambiare la password';

  @override
  String get clubsAndRoles => 'Club e ruoli';

  @override
  String get noRoleGrants => 'Nessun ruolo assegnato a questo account.';

  @override
  String get currentPassword => 'Password attuale';

  @override
  String get newPassword => 'Nuova password';

  @override
  String get passwordRequirementsHint =>
      '≥8 caratteri con maiuscola, minuscola e cifra';

  @override
  String get confirmNewPassword => 'Conferma nuova password';

  @override
  String get emailVerified => 'Email verificata';

  @override
  String get verificationPending => 'Verifica in sospeso';

  @override
  String get emailNotVerified => 'Email non verificata';

  @override
  String get platformRoot => 'Root piattaforma';

  @override
  String joinedMonthYear(String when) {
    return 'Iscritto $when';
  }

  @override
  String get overdue => 'scaduto';

  @override
  String get voided => 'annullato';

  @override
  String get voidLabel => 'annullato';

  @override
  String get relationshipSelf => 'se stesso';

  @override
  String get relationshipGuardian => 'tutore';

  @override
  String get attendanceCanceledClosed => 'Annullato — presenze chiuse';

  @override
  String get attendanceOpen => 'Presenze aperte';

  @override
  String get attendanceLockedShort => 'Presenze bloccate';

  @override
  String get age => 'Età';

  @override
  String get pendingConsents => 'Consensi in sospeso';

  @override
  String get noPendingConsents => 'Nessun consenso in attesa.';

  @override
  String get familyMembers => 'Famiglia';

  @override
  String get noFamilyMembers =>
      'Nessun membro della famiglia collegato a questo account.';

  @override
  String get notificationPreferences => 'Preferenze di notifica';

  @override
  String get noNotificationPreferences =>
      'Nessuna preferenza e-mail disponibile.';

  @override
  String get prefsLoadFailed => 'Impossibile caricare le preferenze';

  @override
  String get familyLoadFailed => 'Impossibile caricare la famiglia';

  @override
  String get consentsLoadFailed => 'Impossibile caricare i consensi';

  @override
  String get grantConsent => 'Concedi';

  @override
  String get consentGrantedSnack => 'Consenso concesso';

  @override
  String get consentGrantFailed => 'Impossibile concedere il consenso';

  @override
  String consentVersion(int version) {
    return 'Versione $version';
  }

  @override
  String get consentReasonNeverGranted => 'Non ancora concesso';

  @override
  String get consentReasonWithdrawn => 'Precedentemente ritirato';

  @override
  String get consentReasonNewVersion => 'Nuova versione disponibile';

  @override
  String get consentReasonOther => 'Azione richiesta';

  @override
  String get reviewAndGrantConsent => 'Rivedi e concedi';

  @override
  String consentForMember(String name) {
    return 'Consenso per $name';
  }

  @override
  String get enrolled => 'Iscritto';

  @override
  String get notEnrolled => 'Non iscritto';

  @override
  String get consentOk => 'Consenso OK';

  @override
  String get consentMissing => 'Consenso mancante';

  @override
  String get channelEmail => 'E-mail';

  @override
  String channelOther(String channel) {
    return '$channel';
  }

  @override
  String get preferenceDefault => 'Predefinito';

  @override
  String get changePhoto => 'Cambia foto';

  @override
  String get changeYourPhoto => 'Cambia la tua foto';

  @override
  String changeChildPhoto(String name) {
    return 'Cambia la foto di $name';
  }

  @override
  String get takePhoto => 'Scatta foto';

  @override
  String get chooseFromLibrary => 'Scegli dalla libreria';

  @override
  String get removePhoto => 'Rimuovi foto';

  @override
  String get photoUpdated => 'Foto aggiornata';

  @override
  String get photoRemoved => 'Foto rimossa';

  @override
  String get photoUpdateFailed => 'Impossibile aggiornare la foto';

  @override
  String get documents => 'Documenti';

  @override
  String get yourDocuments => 'I tuoi documenti';

  @override
  String clubDocumentsTitle(String club) {
    return 'Documenti $club';
  }

  @override
  String get complianceOverview => 'Panoramica';

  @override
  String get reviewQueue => 'Da revisionare';

  @override
  String get noDocumentsPending => 'Niente in attesa di revisione.';

  @override
  String get noComplianceMembers => 'Tutto in regola.';

  @override
  String get complianceValid => 'Valido';

  @override
  String get complianceExpiring => 'In scadenza';

  @override
  String get complianceMissing => 'Mancante';

  @override
  String get complianceUnknown => 'Sconosciuto';

  @override
  String get requirementRequired => 'Obbligatorio';

  @override
  String get requirementOptional => 'Facoltativo';

  @override
  String get uploadDocument => 'Carica';

  @override
  String get choosePdf => 'Scegli PDF o file';

  @override
  String get issuedOn => 'Data di emissione';

  @override
  String get issuedOnHint =>
      'Se il certificato ha una data stampata, aggiungila: la scadenza parte da quel giorno.';

  @override
  String get expiresOn => 'Data di scadenza';

  @override
  String expiresOnDate(String date) {
    return 'Scade il $date';
  }

  @override
  String get documentPending => 'In revisione';

  @override
  String get documentVerified => 'Verificato';

  @override
  String get documentRejected => 'Rifiutato';

  @override
  String get documentAwaitingUpload => 'Caricamento avviato';

  @override
  String get viewDocument => 'Apri';

  @override
  String get deleteDocument => 'Elimina';

  @override
  String get verifyDocument => 'Verifica';

  @override
  String get rejectDocument => 'Rifiuta';

  @override
  String get rejectionReason => 'Motivo per la famiglia';

  @override
  String get askFamily => 'Chiedi alla famiglia';

  @override
  String familyAsked(int count) {
    return 'Richiesta inviata a $count account famiglia';
  }

  @override
  String get familyAlreadyAsked => 'Già chiesto oggi';

  @override
  String get documentUploaded => 'Documento caricato — in attesa di revisione';

  @override
  String get uploadFailed => 'Impossibile caricare il documento';

  @override
  String get couldNotLoadCompliance => 'Impossibile caricare i documenti';

  @override
  String get signInToSeeDocuments => 'Accedi per gestire i documenti';

  @override
  String get contentViewAudited => 'L’apertura di questo file viene registrata';

  @override
  String get noRequirements => 'Nessun documento richiesto per questo membro.';

  @override
  String get confirmDeleteDocument => 'Rimuovere questo documento?';

  @override
  String get rejectReasonRequired => 'Spiega perché è stato rifiutato';

  @override
  String get documentVerifiedSnack => 'Documento verificato';

  @override
  String get documentRejectedSnack => 'Documento rifiutato';

  @override
  String get documentDeleted => 'Documento rimosso';

  @override
  String get documentTooLarge => 'Il file deve essere da 15 MB o meno';

  @override
  String get couldNotOpenDocument => 'Impossibile aprire il file';
}

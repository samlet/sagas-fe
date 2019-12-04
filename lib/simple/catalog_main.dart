import 'package:catalog/app_config.dart';
import 'package:catalog/brokers/MesageReceiver.dart';
import 'package:catalog/charts/chart_list.dart';
import 'package:catalog/common/localization.dart';
import 'package:catalog/contacts/contacts_demo.dart';
import 'package:catalog/dashboard/dashboard_page.dart';
import 'package:catalog/forms/add_edit_screen.dart';
//import 'package:catalog/forms/date_and_time_picker_demo.dart';
import 'package:catalog/forms/dynamic_picker.dart';
import 'package:catalog/forms/keys.dart';
import 'package:catalog/forms/localization.dart';
import 'package:catalog/forms/receiver_model.dart';
import 'package:catalog/forms/schedule_bloc.dart';
import 'package:catalog/forms/send_money_page.dart';
import 'package:catalog/forms/text_form_field_demo.dart';
import 'package:catalog/listings/history_page.dart';
import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import 'package:catalog/authentication/authentication.dart';
import 'package:catalog/splash/splash.dart';
import 'package:catalog/login/login.dart';
import 'package:catalog/home/home.dart';
import 'package:catalog/common/common.dart';

import 'package:sagas_meta/sagas_bloc.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Transition transition) {
    print(transition);
  }

  @override
  void onError(Object error, StackTrace stacktrace) {
    print(error);
  }
}

void main() {
  BlocSupervisor().delegate = SimpleBlocDelegate();
  runApp(App(userRepository: UserRepository(), receiver:MessageReceiver()));
}

class App extends StatefulWidget {
  final UserRepository userRepository;
  final MessageReceiver receiver;

  App({Key key, @required this.userRepository,
    @required this.receiver}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  AuthenticationBloc _authenticationBloc;
  CommonSrvBloc _srvBloc;
  SrvClient _client;
  UserRepository get _userRepository => widget.userRepository;
  // Initialize app settings from the default configuration.
  bool _showPerformanceOverlay = defaultConfig.showPerformanceOverlay;

  @override
  void initState() {
    _authenticationBloc = AuthenticationBloc(userRepository: _userRepository);
    _authenticationBloc.dispatch(AppStarted());
    _client=new SrvClient(client:Client());
    _srvBloc=CommonSrvBloc(client: _client);

    //+
    widget.receiver.init();
    //+

    super.initState();
  }

  @override
  void dispose() {
    _authenticationBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /*
    return BlocProvider<AuthenticationBloc>(
      bloc: _authenticationBloc,
    */
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<AuthenticationBloc>(bloc: _authenticationBloc),
        BlocProvider<CommonSrvBloc>(bloc: _srvBloc),
      ],
      child: MaterialApp(
        title: 'Sagas Blues',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
        ),
        localizationsDelegates: [
          ArchSampleLocalizationsDelegate(),
          FlutterBlocLocalizationsDelegate(),
        ],
        home: BlocBuilder<AuthenticationEvent, AuthenticationState>(
          bloc: _authenticationBloc,
          builder: (BuildContext context, AuthenticationState state) {
            // return HomePage();
            // return DateAndTimePickerDemo(scheduleRepository:ScheduleRepository());
            // return SendMoneyPage(receiver: receivers[0]);
            return DashboardPage();
            // return HistoryPage();

            /*
            return AddEditScreen(
              key: ArchSampleKeys.addTodoScreen,
              onSave: (task, note) {
//                todosBloc.dispatch(
//                  AddTodo(Todo(task, note: note)),
//                );

                print('save it.');
              },
              isEditing: false,
            );
            */

            /* charts
            return ChartList(
              showPerformanceOverlay: _showPerformanceOverlay,
              onShowPerformanceOverlayChanged: (bool value) {
                setState(() {
                  _showPerformanceOverlay = value;
                });
              },
            );
            */

            // return DateAndTimePickerDemo();
            // return TextFormFieldDemo();
            // return ContactsDemo();
            /*
            if (state is AuthenticationUninitialized) {
              return SplashPage();
            }
            if (state is AuthenticationAuthenticated) {
              return HomePage();
            }
            if (state is AuthenticationUnauthenticated) {
              return LoginPage(userRepository: _userRepository);
            }
            if (state is AuthenticationLoading) {
              return LoadingIndicator();
            }
            */
          },
        ),
      ),
    );
  }
}

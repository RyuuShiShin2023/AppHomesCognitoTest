import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

final userPool =
    CognitoUserPool("ap-northeast-1_gR9vT2KF9", "3ropnok81guejmfv7vi5uuslba");

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _accountController =
      TextEditingController(text: "ss.ryuu@mi-asahi.co.jp");
  final _pwdController = TextEditingController(text: "qwerty123456");
  final _authCodeController = TextEditingController();
  bool _showAuthCodeInputArea = false;
  CognitoUserSession? session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cognito Demo",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: TextField(
                    controller: _accountController,
                    decoration: const InputDecoration(
                      hintText: "Input Account",
                      hintStyle: TextStyle(
                        fontSize: 14,
                      ),
                      icon: Icon(
                        Icons.account_box,
                        size: 18,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: TextField(
                    controller: _pwdController,
                    decoration: const InputDecoration(
                      hintText: "Input Password",
                      hintStyle: TextStyle(
                        fontSize: 14,
                      ),
                      icon: Icon(
                        Icons.lock,
                        size: 18,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _showAuthCodeInputArea,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextField(
                      controller: _authCodeController,
                      decoration: const InputDecoration(
                        hintText: "Input Auth Code",
                        hintStyle: TextStyle(
                          fontSize: 14,
                        ),
                        icon: Icon(
                          Icons.verified_user,
                          size: 18,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              !_showAuthCodeInputArea
                  ? Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 14)),
                        onPressed: () async {
                          // send auth code
                          final email = _accountController.text;
                          final pwd = _pwdController.text;
                          try {
                            final data = await userPool.signUp(
                              email,
                              pwd,
                              userAttributes: [
                                AttributeArg(name: "email", value: email)
                              ],
                            );

                            debugPrint(data.toString());
                            setState(() {
                              _showAuthCodeInputArea = true;
                            });
                          } catch (e) {
                            debugPrint(e.toString());
                          }
                        },
                        child: const Text("Register"),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 14)),
                        onPressed: () async {
                          final email = _accountController.text;
                          final code = _authCodeController.text;
                          try {
                            final data = await CognitoUser(email, userPool)
                                .confirmRegistration(code);

                            debugPrint(data.toString());
                          } catch (e) {
                            debugPrint(e.toString());
                          }
                        },
                        child: const Text("Vertify"),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 14)),
                  onPressed: () async {
                    final email = _accountController.text;
                    final pwd = _pwdController.text;
                    final cognitoUser = CognitoUser(email, userPool);
                    final authDetails = AuthenticationDetails(
                      username: email,
                      password: pwd,
                    );
                    try {
                      session = await cognitoUser.authenticateUser(authDetails);
                      debugPrint("session get ok");
                    } on CognitoUserNewPasswordRequiredException {
                      debugPrint("handle New Password challenge");
                      // handle New Password challenge
                    } on CognitoUserMfaRequiredException {
                      debugPrint("handle SMS_MFA challenge");
                      // handle SMS_MFA challenge
                    } on CognitoUserSelectMfaTypeException {
                      debugPrint("handle SELECT_MFA_TYPE challenge");
                      // handle SELECT_MFA_TYPE challenge
                    } on CognitoUserMfaSetupException {
                      debugPrint("handle MFA_SETUP challenge");
                      // handle MFA_SETUP challenge
                    } on CognitoUserTotpRequiredException {
                      debugPrint("handle SOFTWARE_TOKEN_MFA challenge");
                      // handle SOFTWARE_TOKEN_MFA challenge
                    } on CognitoUserCustomChallengeException {
                      debugPrint("handle CUSTOM_CHALLENGE challenge");
                      // handle CUSTOM_CHALLENGE challenge
                    } on CognitoUserConfirmationNecessaryException {
                      debugPrint("handle User Confirmation Necessary");
                      // handle User Confirmation Necessary
                    } on CognitoClientException {
                      /* 1.The account is not existed 
                         2.Account is unconfirmed status
                      */
                      debugPrint(
                          "handle Wrong Username and Password and Cognito Client");
                    } catch (e) {
                      debugPrint(e.toString());
                    }
                    debugPrint(
                        "access token\n${session?.getAccessToken().getJwtToken()}");
                    debugPrint(
                        "id token\n${session?.getIdToken().getJwtToken()}");
                    debugPrint(
                        "refresh token\n${session?.getRefreshToken()?.token}");
                  },
                  child: const Text("Login"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 14)),
                  onPressed: () async {
                    final credentials = CognitoCredentials(
                      "ap-northeast-1:0870ddcf-bbd7-457a-8d4e-3999e6cf8198",
                      userPool,
                    );
                    await credentials
                        .getAwsCredentials(session?.getIdToken().getJwtToken());
                    // debugPrint("access key id:\n${credentials.accessKeyId}");
                    // debugPrint(
                    //     "secret access key:\n${credentials.secretAccessKey}");
                    // debugPrint("session token:\n${credentials.sessionToken}");
                    final awsSigV4Client = AwsSigV4Client(
                      credentials.accessKeyId!,
                      credentials.secretAccessKey!,
                      "https://pjfk0guqbc.execute-api.ap-northeast-1.amazonaws.com/test/user_info",
                      region: "ap-northeast-1",
                      sessionToken: credentials.sessionToken,
                    );

                    final signedRequest = SigV4Request(
                      awsSigV4Client,
                      method: "GET",
                      path: "",
                    );
                    // Map<String, String> map = Map.identity();
                    // for (MapEntry<String, String?> item
                    //     in signedRequest.headers!.entries) {
                    //   if (item.value != null) {
                    //     debugPrint("key: ${item.key}");
                    //     debugPrint("value: ${item.value!}");
                    //     map[item.key] = item.value!;
                    //   }
                    // }
                    http.Response response;
                    try {
                      response = await http.get(Uri.parse(signedRequest.url!),
                          headers: Map.from({
                            "Authorization":
                                session!.getIdToken().getJwtToken(),
                          }));
                      debugPrint(response.body);
                    } catch (e) {
                      debugPrint("error \n${e.toString()}");
                    }
                  },
                  child: const Text("Login Token"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

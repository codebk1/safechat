import 'package:safechat/utils/form_helper.dart';
import 'package:safechat/utils/validator.dart';

class ConfirmPassword extends FormItem<String> {
  const ConfirmPassword({required String value, required this.password})
      : super(value);

  final String password;

  @override
  List<Validator> get validators => [
        RequiredValidator(errorText: 'Hasło jest wymagane.'),
        MatchValidator(password, 'Podane hasła różnią się.'),
      ];
}

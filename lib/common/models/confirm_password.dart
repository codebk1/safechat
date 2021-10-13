import 'package:safechat/common/models/password.dart';
import 'package:safechat/utils/form_helper.dart';
import 'package:safechat/utils/validator.dart';

class ConfirmPassword extends FormItem<String> {
  const ConfirmPassword({required this.password, String value = ''})
      : super(value);

  final Password password;

  @override
  List<Validator> get validators => [
        RequiredValidator(errorText: 'Hasło jest wymagane.'),
        MatchValidator(password.value, 'Podane hasła różnią się.'),
      ];
}

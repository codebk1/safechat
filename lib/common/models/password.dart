import 'package:safechat/utils/form_helper.dart';
import 'package:safechat/utils/validator.dart';

class Password extends FormItem<String> {
  const Password(String value) : super(value);
  const Password.init() : super.blank('');

  @override
  List<Validator> get validators => [
        RequiredValidator(errorText: 'Hasło jest wymagane.'),
      ];
}

import 'package:safechat/utils/form_helper.dart';
import 'package:safechat/utils/validator.dart';

class Email extends FormItem<String> {
  const Email(String value) : super(value);

  @override
  List<Validator> get validators => [
        RequiredValidator(errorText: 'Email jest wymagany.'),
        EmailValidator(),
      ];
}

import 'package:safechat/utils/form_helper.dart';
import 'package:safechat/utils/validator.dart';

class FirstName extends FormItem<String> {
  const FirstName(String value) : super(value);

  @override
  List<Validator> get validators => [
        RequiredValidator(errorText: 'Imię jest wymagane.'),
      ];
}

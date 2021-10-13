import 'package:safechat/utils/form_helper.dart';
import 'package:safechat/utils/validator.dart';

class LastName extends FormItem<String> {
  const LastName(String value) : super(value);

  @override
  List<Validator> get validators => [
        RequiredValidator(errorText: 'Nazwisko jest wymagane.'),
      ];
}

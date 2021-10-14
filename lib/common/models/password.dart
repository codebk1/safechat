import 'package:safechat/utils/form_helper.dart';
import 'package:safechat/utils/validator.dart';

class Password extends FormItem<String> {
  const Password(String value, {this.restrict = false}) : super(value);

  final bool restrict;

  @override
  List<Validator> get validators => [
        RequiredValidator(errorText: 'Hasło jest wymagane.'),
        if (restrict) ...[
          PatternValidator(
            r'^.*[A-Z]',
            errorText: 'Wymagana przynajmniej 1 duża litera.',
          ),
          PatternValidator(
            r'^.*[a-z]',
            errorText: 'Wymagana przynajmniej 1 mała litera.',
          ),
          PatternValidator(
            r'^.*[0-9]',
            errorText: 'Wymagana przynajmniej 1 cyfra.',
          ),
          PatternValidator(
            r'^.*?[!@#\$&*~]',
            errorText: 'Wymagany przynajmniej 1 znak specjalny.',
          ),
          MinLengthValidator(8),
        ]
      ];
}

import 'package:safechat/utils/form_helper.dart';
import 'package:safechat/utils/validator.dart';

class Email extends FormItem<String> {
  const Email(String value) : super(value);
  const Email.init() : super.blank('');

  @override
  List<Validator> get validators => [
        RequiredValidator(errorText: 'Email jest wymagany.'),
        EmailValidator(),
      ];
}

// class Email extends FormzInput<String, String> {
//   const Email.pure() : super.pure('');
//   const Email.dirty(String? value) : super.dirty(value ?? '');

//   List<Validator> get validators => [
//         RequiredValidator(errorText: 'Email jest wymagany.'),
//         EmailValidator(),
//       ];

//   @override
//   String? validator(String value) {
//     return MultiValidator(validators).call(value);
//   }
// }

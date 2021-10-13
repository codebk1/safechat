import 'package:safechat/utils/form_helper.dart';
import 'package:safechat/utils/validator.dart';

class Name extends FormItem<String> {
  const Name(value) : super(value);

  @override
  List<Validator> get validators =>
      [RequiredValidator(errorText: 'Nazwa jest wymagana.')];
}

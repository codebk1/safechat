import 'package:safechat/utils/utils.dart';

class Name extends FormItem<String> {
  const Name(value) : super(value);

  @override
  List<Validator> get validators =>
      [RequiredValidator(errorText: 'Nazwa jest wymagana.')];
}

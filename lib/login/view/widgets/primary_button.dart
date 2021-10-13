import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/login/cubit/login_cubit.dart';
import 'package:safechat/utils/utils.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          return InkWell(
            borderRadius: BorderRadius.circular(5.0),
            onTap: () {
              context.read<LoginCubit>().submit();
            },
            child: SizedBox(
              height: 60.0,
              child: Center(
                child: state.formStatus.isLoading
                    ? Transform.scale(
                        scale: 0.6,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        ),
                      )
                    : Text(
                        'Zaloguj',
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                              color: Colors.white,
                            ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

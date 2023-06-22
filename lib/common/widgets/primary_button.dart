import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    Key? key,
    required this.label,
    required this.onTap,
    required this.isLoading,
  }) : super(key: key);

  final String label;
  final Function onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(5.0),
        onTap: () => !isLoading ? onTap.call() : null,
        child: SizedBox(
          height: 60.0,
          child: Center(
            child: isLoading
                ? Transform.scale(
                    scale: 0.6,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  )
                : Text(
                    label,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Colors.white,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}

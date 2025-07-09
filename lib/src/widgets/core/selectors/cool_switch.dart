import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widgetbook_example/src/widgets/core/selectors/states/cool_switch_cubit.dart';

import '../../../statemanagement/DisposableStatelessWidget.dart';

class CoolSwitch extends DisposableStatelessWidget {
   CoolSwitch({this.initialValue = false, super.key});

  final bool initialValue;
  late final CoolSwitchCubit _cubit;

  @override
  void onDispose() {
    _cubit.onDispose();
    super.onDispose();
  }

  bool get value => _cubit.value;

  @override
  Widget build(BuildContext context) {
    _cubit = CoolSwitchCubit(initialValue: initialValue);

    return BlocProvider<CoolSwitchCubit>.value(
      value: _cubit,
      child: BlocBuilder<CoolSwitchCubit, CoolSwitchState>(
        builder: (context, state) {
          return Switch(
            value: (state is SwitchToggleState) ? state.value : false,
            onChanged: _cubit.onValueChange,
          );
        },
      ),
    );
  }
}

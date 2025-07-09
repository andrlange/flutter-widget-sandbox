import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../statemanagement/callback_definitions.dart';
export '../../../../statemanagement/callback_definitions.dart';
part 'cool_switch_state.dart';

class CoolSwitchCubit extends Cubit<CoolSwitchState> {
  CoolSwitchCubit({this.initialValue = false, this.onValueChange})
    : super(SwitchToggleState(value: initialValue));

  final bool initialValue;
  final BoolCallBack? onValueChange;
  bool? _value;

  void onSwitching(bool checked) {
    _value = checked;
    if (onValueChange!= null) onValueChange!(checked);
    emit(SwitchToggleState(value: checked));
  }

  bool get value => _value?? initialValue;


  void onDispose() {
    print('CoolSwitchCubit disposed');
  }
}

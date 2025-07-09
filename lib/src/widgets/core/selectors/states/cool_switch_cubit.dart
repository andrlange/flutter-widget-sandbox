import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'cool_switch_state.dart';

class CoolSwitchCubit extends Cubit<CoolSwitchState> {
  CoolSwitchCubit({this.initialValue = false})
    : super(SwitchToggleState(value: initialValue));

  final bool initialValue;
  bool? _value;

  void onValueChange(bool checked) {
    _value = checked;
    emit(SwitchToggleState(value: checked));
  }

  bool get value => _value?? initialValue;


  void onDispose() {
    print('CoolSwitchCubit disposed');
  }
}

part of 'cool_switch_cubit.dart';

sealed class CoolSwitchState extends Equatable {
  const CoolSwitchState();

  @override
  List<Object> get props => [];
}

final class SwitchToggleState extends CoolSwitchState {
   final bool value;
   const SwitchToggleState({required this.value});

   @override
   List<Object> get props => [value];
}

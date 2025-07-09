part of 'cool_radio_group_cubit.dart';

sealed class CoolRadioGroupState extends Equatable {
  const CoolRadioGroupState();

  @override
  List<Object> get props => [];
}

final class CoolRadioGroupValue<T> extends CoolRadioGroupState {

   const CoolRadioGroupValue({required this.newValue});
   final T newValue;

   @override
   List<Object> get props => [?newValue];
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'cool_radio_group_state.dart';

class CoolRadioGroupCubit<T> extends Cubit<CoolRadioGroupState> {
  CoolRadioGroupCubit(T initialValue)
    : super(CoolRadioGroupValue(newValue: initialValue));

  Future<void> dispose() async {
    debugPrint('CoolRadioGroupCubit disposing');

    super.close();
  }

  void setValue(T newValue) {
    emit(CoolRadioGroupValue(newValue: newValue));
  }
}

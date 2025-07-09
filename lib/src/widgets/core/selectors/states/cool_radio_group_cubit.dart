import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'cool_radio_group_state.dart';

class CoolRadioGroupCubit<T> extends Cubit<CoolRadioGroupState> {
  CoolRadioGroupCubit(T initialValue)
    : super(CoolRadioGroupValue(newValue: initialValue));

  Future<void> dispose() async {
    debugPrint('CoolRadioGroupCubit disposing');

    await super.close();
  }

  void setValue(T? newValue) {

    emit(CoolRadioGroupValue(newValue: _convertNull(newValue)));
  }

  Object _convertNull(T? value) {
    final type = T.runtimeType;
    switch(type){
      case String:
        return value?? '';
      case int:
        return value?? 0;
      case double:
        return value?? 0.0;
      default:
        return value?? '';
    }
  }
}

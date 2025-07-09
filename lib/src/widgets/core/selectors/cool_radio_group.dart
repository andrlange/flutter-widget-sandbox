import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/src/statemanagement/disposer.dart';
import '/src/translation/translation_extension.dart';
import '/src/widgets/core/selectors/states/cool_radio_group_cubit.dart';

class CoolRadioGroup<T> extends StatelessWidget {

  const CoolRadioGroup({
    super.key,
    required this.options,
    required this.initialValue,
    this.clearable = false,
  });
  final Map<String, T> options;
  final T initialValue;
  final bool clearable;

  @override
  Widget build(BuildContext context) {
    final cubit = CoolRadioGroupCubit<T>(initialValue);
    return BlocProvider.value(
      value: cubit,
      child: _CoolRadioGroup(
        options: options,
        cubit: cubit,
        initialValue: initialValue,
        clearable: clearable,
      ),
    );
  }
}

class _CoolRadioGroup<T> extends StatelessWidget {

  const _CoolRadioGroup({
    super.key,
    required this.options,
    required this.cubit,
    required this.initialValue,
    this.clearable = false,
  });
  final Map<String, T> options;
  final CoolRadioGroupCubit<T> cubit;
  final T initialValue;
  final bool clearable;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    final disposer = Disposer(dispose: cubit.dispose);

    return BlocBuilder<CoolRadioGroupCubit<T>, CoolRadioGroupState>(
      builder: (context, state) {
        T? groupValue;
        if(state is CoolRadioGroupValue){
          groupValue = state.newValue as T;
        }

        children.clear();
        options.forEach(
              (label, value) =>
              children.add(
                _buildRadioTile(value, groupValue, label),
              ),
        );
        if(clearable) {
          children.add(
          IconButton(
            onPressed: () =>cubit.setValue(null),
            icon: const Icon(Icons.clear),
          ));
        }
        children.add(disposer);


        return Column(children: children);
      },
    );
  }

  Widget _buildRadioTile(T value, T? groupValue, String label) {
    return ListTile(
      title: Text(label.trSync()),
      leading: Radio<T>(
        value: value,
        groupValue: groupValue?? '' as T,

        onChanged: cubit.setValue,
      ),
    );
  }
}

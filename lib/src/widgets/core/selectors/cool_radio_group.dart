import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/src/internationalization/translation_extension.dart';
import '/src/statemanagement/disposer.dart';
import '/src/widgets/core/selectors/states/cool_radio_group_cubit.dart';

class CoolRadioGroup<T> extends StatelessWidget {
  final Map<String, T> options;
  final T initialValue;

  const CoolRadioGroup({
    super.key,
    required this.options,
    required this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    final CoolRadioGroupCubit cubit = CoolRadioGroupCubit(initialValue);
    return BlocProvider.value(
      value: cubit,
      child: _CoolRadioGroup(
        options: options,
        cubit: cubit,
        initialValue: initialValue,
      ),
    );
  }
}

class _CoolRadioGroup<T> extends StatelessWidget {
  final Map<String, T> options;
  final CoolRadioGroupCubit cubit;
  final T initialValue;

  const _CoolRadioGroup({
    super.key,
    required this.options,
    required this.cubit,
    required this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];
    final Disposer disposer = Disposer(dispose: cubit.dispose);

    return BlocBuilder<CoolRadioGroupCubit, CoolRadioGroupState>(
      builder: (context, state) {
        T? groupValue;
        if(state is CoolRadioGroupValue){
          groupValue = state.newValue;
        }

        children.clear();
        options.forEach(
              (label, value) =>
              children.add(
                _buildRadioTile(value, groupValue, label),
              ),
        );
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
        groupValue: groupValue,

        onChanged: cubit.setValue,
      ),
    );
  }
}

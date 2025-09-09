import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chiken_odyssey/features/global/widgets/custom_app_bar.dart';
import 'package:chiken_odyssey/features/settings_screen/bloc/settings_bloc.dart';
import 'package:chiken_odyssey/features/settings_screen/bloc/settings_state.dart';
import 'package:chiken_odyssey/features/settings_screen/bloc/settings_event.dart';
import 'package:chiken_odyssey/features/settings_screen/widgets/settings_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsScreenView();
  }
}

class SettingsScreenView extends StatelessWidget {
  const SettingsScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<SettingsBloc, SettingsState>(
          listener: (context, state) {
            // Показываем ошибку если она есть
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const CustomAppBar(title: 'Settings'),
                const SizedBox(height: 20),
                const Divider(),

                // Показываем индикатор загрузки во время инициализации
                if (state.isLoading && !state.isInitialized)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text('Initializing audio...'),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // Настройка музыки
                  SettingsCard(
                    title: 'Music',
                    value: state.isMusicEnabled,
                    onChanged: state.isLoading
                        ? null // Отключаем переключатель во время загрузки
                        : (val) {
                            context.read<SettingsBloc>().add(
                              ToggleMusic(val),
                            );
                          },
                  ),

                  const Divider(),

                  // Настройка звуковых эффектов
                  SettingsCard(
                    title: 'Sound FX',
                    value: state.isSoundFXEnabled,
                    onChanged: state.isLoading
                        ? null // Отключаем переключатель во время загрузки
                        : (val) {
                            context.read<SettingsBloc>().add(
                              ToggleSoundFX(val),
                            );
                          },
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/admin/admin_bloc.dart';
import '../../blocs/admin/admin_event.dart';
import '../../blocs/admin/admin_state.dart';
import '../../widgets/admin/admin_sidebar.dart';
import '../../widgets/admin/admin_app_bar.dart';
import '../../widgets/admin/dashboard_content.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sol sidebar - navigasyon
          const AdminSidebar(),

          // Ana içerik
          Expanded(
            child: Column(
              children: [
                // Üst bar - kullanıcı, bildirimler
                const AdminAppBar(),

                // İçerik alanı
                Expanded(
                  child: BlocBuilder<AdminBloc, AdminState>(
                    builder: (context, state) {
                      if (state is AdminLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (state is DashboardStatsLoaded) {
                        return DashboardContent(stats: state.stats);
                      } else if (state is AdminError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Hata: ${state.message}'),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<AdminBloc>().add(const LoadDashboardStats());
                                },
                                child: const Text('Tekrar Dene'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Initial state - load dashboard stats
                        context.read<AdminBloc>().add(const LoadDashboardStats());
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
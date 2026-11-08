import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/usuario_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  List<Usuario> _usuarios = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  Future<void> _carregarUsuarios() async {
    final db = ref.read(databaseProvider);
    final lista = await db.listarUsuarios();
    setState(() {
      _usuarios = lista;
      _carregando = false;
    });
  }

  void _entrar(Usuario usuario) {
    ref.read(usuarioAtualProvider.notifier).state = usuario;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.keyboard, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Text('TypeMaster', style: AppTextStyles.headline1),
                ],
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 48),
              Text('Quem está digitando?', style: AppTextStyles.headline2)
                  .animate(delay: 100.ms).fadeIn().slideX(begin: -0.1, end: 0),
              const SizedBox(height: 8),
              Text('Selecione seu perfil para continuar',
                  style: AppTextStyles.body)
                  .animate(delay: 150.ms).fadeIn(),
              const SizedBox(height: 32),
              Expanded(
                child: _carregando
                    ? const Center(child: CircularProgressIndicator())
                    : _usuarios.isEmpty
                        ? _semUsuarios()
                        : _listaUsuarios(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/cadastro'),
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text('Novo usuário'),
                ),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _semUsuarios() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('Nenhum usuário cadastrado', style: AppTextStyles.body),
          const SizedBox(height: 8),
          Text('Cadastre-se para começar!',
              style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _listaUsuarios() {
    return ListView.builder(
      itemCount: _usuarios.length,
      itemBuilder: (context, i) {
        final u = _usuarios[i];
        return _UserCard(usuario: u, onTap: () => _entrar(u))
            .animate(delay: Duration(milliseconds: 100 + i * 80))
            .fadeIn()
            .slideX(begin: 0.1, end: 0);
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  final Usuario usuario;
  final VoidCallback onTap;

  const _UserCard({required this.usuario, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: usuario.cor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: usuario.cor.withValues(alpha: 0.5)),
                  ),
                  child: Center(
                    child: Text(
                      usuario.iniciais,
                      style: AppTextStyles.headline3.copyWith(color: usuario.cor),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(usuario.nome, style: AppTextStyles.headline3),
                      const SizedBox(height: 2),
                      Text(
                        '${usuario.totalSessoes} sessões  •  ${usuario.totalMinutos} min',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

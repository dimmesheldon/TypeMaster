import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/usuario_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  String _corSelecionada = '#6C63FF';
  bool _salvando = false;

  static const _cores = [
    '#6C63FF', '#00D9FF', '#00E676', '#FFAA00',
    '#FF3D71', '#FF6B6B', '#4ECDC4', '#45B7D1',
    '#96CEB4', '#FF9A9E', '#A18CD1', '#FFECD2',
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    try {
      final db = ref.read(databaseProvider);
      final usuario = Usuario(
        nome: _nomeController.text.trim(),
        avatarCor: _corSelecionada,
      );
      final id = await db.criarUsuario(usuario);
      final criado = usuario.copyWith(id: id);
      ref.read(usuarioAtualProvider.notifier).state = criado;
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar usuário: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
                      icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Text('Novo Usuário', style: AppTextStyles.headline2),
                  ],
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 40),

                // Avatar preview
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: _hexToColor(_corSelecionada).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: _hexToColor(_corSelecionada),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _hexToColor(_corSelecionada).withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _nomeController.text.isEmpty ? '?' : _iniciais(_nomeController.text),
                        style: AppTextStyles.display.copyWith(
                          color: _hexToColor(_corSelecionada),
                          fontSize: 36,
                        ),
                      ),
                    ),
                  ),
                ).animate(delay: 100.ms).scale().fadeIn(),

                const SizedBox(height: 40),

                Text('Seu nome', style: AppTextStyles.label.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 1,
                )),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nomeController,
                  autofocus: true,
                  style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Digite seu nome completo',
                    prefixIcon: Icon(Icons.person_outline, color: AppColors.textMuted),
                  ),
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.trim().length < 2) {
                      return 'Nome deve ter pelo menos 2 caracteres';
                    }
                    return null;
                  },
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: 32),
                Text('Escolha uma cor', style: AppTextStyles.label.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 1,
                )),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _cores.map((cor) {
                    final selecionada = cor == _corSelecionada;
                    return GestureDetector(
                      onTap: () => setState(() => _corSelecionada = cor),
                      child: AnimatedContainer(
                        duration: 200.ms,
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _hexToColor(cor),
                          shape: BoxShape.circle,
                          border: selecionada
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: selecionada
                              ? [BoxShadow(
                                  color: _hexToColor(cor).withValues(alpha: 0.5),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                )]
                              : null,
                        ),
                        child: selecionada
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ).animate(delay: 250.ms).fadeIn(),

                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _salvando ? null : _cadastrar,
                    child: _salvando
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Criar Perfil'),
                  ),
                ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    final val = int.tryParse('FF$h', radix: 16) ?? 0xFF6C63FF;
    return Color(val);
  }

  String _iniciais(String nome) {
    final partes = nome.trim().split(' ');
    if (partes.length == 1) return partes[0].substring(0, 1).toUpperCase();
    return '${partes[0][0]}${partes.last[0]}'.toUpperCase();
  }
}

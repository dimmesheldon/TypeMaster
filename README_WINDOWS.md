# TypeMaster — Guia de Teste no Windows

**Versão:** 1.0.0  
**Repositório:** https://github.com/dimmesheldon/TypeMaster  
**Plataformas:** macOS · Windows · Linux

---

## 1. Instalar o Flutter no Windows

1. Acesse https://flutter.dev/docs/get-started/install/windows  
2. Baixe o SDK e extraia para `C:\flutter`  
3. Adicione `C:\flutter\bin` ao PATH do sistema  
4. Instale o **Visual Studio 2022** (Community grátis) com o workload **"Desktop development with C++"** — obrigatório para builds Windows  
5. No PowerShell: `flutter doctor` → resolva qualquer aviso que aparecer

---

## 2. Clonar o repositório

```powershell
git clone https://github.com/dimmesheldon/TypeMaster.git
cd TypeMaster
flutter pub get
```

---

## 3. Executar em modo desenvolvimento

```powershell
flutter run -d windows
```

---

## 4. Gerar o instalador Windows (`.exe` ou `.msix`)

### Opção A — executável simples (pasta)
```powershell
flutter build windows --release
# Resultado em: build\windows\x64\runner\Release\
# Copie essa pasta inteira para qualquer PC Windows (sem instalação)
```

### Opção B — pacote MSIX (instalador clicável)
```powershell
# Adicionar a dependência no pubspec.yaml:
#   msix: ^3.16.8
flutter pub add msix --dev

# No pubspec.yaml, adicionar:
# msix_config:
#   display_name: TypeMaster
#   publisher_display_name: Escola de Informática
#   identity_name: com.typemaster.app
#   msix_version: 1.0.0.0
#   logo_path: assets/images/mao_esquerda.png

flutter pub run msix:create
# Gera: build\windows\x64\runner\Release\typemaster.msix
```

---

## 5. Layout de teclado no Windows

O Windows usa layout **ABNT2** por padrão nos teclados brasileiros.  
Ao abrir o app, vá em **Configurações** (ícone de engrenagem na barra lateral) e selecione:

| Situação | Opção a escolher |
|---|---|
| Teclado físico ABNT2 (ç na tecla própria) | **Brasileiro (ABNT2)** |
| Teclado americano com "U.S. International" | **Americano com acentos (Brasileiro – Pro)** |
| Teclado americano puro (Option+E para acentos) | **Americano puro (U.S. / ABC)** |

---

## 6. Diferenças entre macOS e Windows

| Item | macOS | Windows |
|---|---|---|
| Acentos (layout Brasileiro–Pro) | `'` + letra | `'` + letra (igual) |
| ç | Option + C ou tecla ç | AltGr + C ou tecla ç |
| Som do teclado | `audioplayers_darwin` | `audioplayers` |
| Banco de dados | SQLite via sqflite | SQLite via sqflite |
| Fonte | Poppins bundlada em assets/ | Poppins bundlada em assets/ |

> **Nota:** O app é 100% offline. Não faz nenhuma requisição de rede.

---

## 7. Estrutura do projeto

```
lib/
  core/
    database/        ← SQLite (sqflite)
    models/          ← Usuario, SessaoDigitacao, SessaoMouse
    providers/       ← Riverpod (estado global)
    router/          ← GoRouter
    services/        ← SoundService, SettingsService
    theme/           ← AppColors, AppTextStyles
  data/
    keyboard/        ← layouts ABNT2, Brasileiro–Pro, Americano
    lessons/         ← conteúdo das 16 lições de digitação
  features/
    auth/            ← Splash, Login, Cadastro
    home/            ← Dashboard com stats
    typing/          ← Menu, Lição, Teste de Velocidade + widgets
    mouse/           ← Menu + 5 desafios
    settings/        ← Layout do teclado + som
    statistics/      ← Gráficos fl_chart
assets/
  google_fonts/      ← Poppins e RobotoMono (bundlados, sem rede)
  images/            ← Mãos 3D (guia de dedos)
```

---

## 8. Dependências principais

| Pacote | Versão | Uso |
|---|---|---|
| flutter_riverpod | 2.5.1 | Gerenciamento de estado |
| go_router | 14.3.0 | Navegação |
| sqflite | 2.4.1 | Banco de dados SQLite |
| shared_preferences | 2.5.3 | Preferências (layout, som) |
| fl_chart | 0.69.2 | Gráficos de estatísticas |
| flutter_animate | 4.5.2 | Animações |
| audioplayers | 6.5.0 | Som do teclado |
| google_fonts | 6.3.3 | Fontes (lidas de assets/) |

---

## 9. Problemas comuns no Windows

### "flutter: command not found"
→ Verifique se `C:\flutter\bin` está no PATH e reabra o terminal.

### Build falha com erro de compilação C++
→ Certifique-se de que o Visual Studio 2022 está instalado com o workload **"Desktop development with C++"**.

### App abre mas sem som
→ Normal em algumas configurações de Windows sem drivers de áudio. O app funciona normalmente; o som é opcional.

### Fontes não aparecem
→ Os arquivos `.ttf` precisam estar em `assets/google_fonts/`. Verifique se o `git clone` os trouxe.

---

## 10. Instalador macOS (.pkg)

O arquivo `TypeMaster-1.0.0.pkg` está em:
```
build/macos/TypeMaster-1.0.0.pkg
```
Instala o `typemaster.app` diretamente em `/Applications`.  
Para distribuir: copie o `.pkg` para um pendrive ou compartilhe via rede.

> **Nota sobre assinatura:** O `.pkg` não está assinado com certificado Apple Developer.  
> Para abrir no macOS: clique com botão direito → "Abrir" → "Abrir mesmo assim".  
> Ou execute: `sudo spctl --master-disable` (temporário) antes de instalar.

---

*Gerado em 08/11/2026 — TypeMaster v1.0.0*

// Conteúdo das lições para todos os níveis

class Licao {
  final String nivel;
  final int subNivel;
  final String titulo;
  final String descricao;
  final String instrucao;
  final List<String> textos;
  final List<String> teclasEnfoque; // teclas destacadas no teclado virtual
  final int duracaoSegundos;
  final int wpmMeta;
  final int precisaoMinima;

  const Licao({
    required this.nivel,
    required this.subNivel,
    required this.titulo,
    required this.descricao,
    required this.instrucao,
    required this.textos,
    this.teclasEnfoque = const [],
    this.duracaoSegundos = 60,
    this.wpmMeta = 20,
    this.precisaoMinima = 85,
  });
}

class BancoLicoes {
  static const List<Licao> todas = [
    // ═══════════════════════════════════════════════════════════════════════════
    // INICIANTE
    // ═══════════════════════════════════════════════════════════════════════════

    Licao(
      nivel: 'iniciante',
      subNivel: 1,
      titulo: 'Posição Base',
      descricao: 'Aprenda a posicionar os dedos na fileira do meio',
      instrucao: 'Coloque os dedos nas teclas F e J (marcadas com relevo). '
          'Mão esquerda: A-S-D-F. Mão direita: J-K-L-Ç.',
      textos: [
        'asd fgh jkl',
        'asdf jkl; asd jkl',
        'fdsa lkj; fdsa lkj',
        'aaaa ssss dddd ffff jjjj kkkk llll',
        'as df jk ls fd ja sk dl fa sj dk al',
        'fala sala kala jala dala asas lala',
        'sad gas has had fall all hall jad',
        'ada alla fada cada jaga saga hada',
      ],
      teclasEnfoque: ['a', 's', 'd', 'f', 'j', 'k', 'l', 'ç'],
      wpmMeta: 10,
      precisaoMinima: 85,
    ),

    Licao(
      nivel: 'iniciante',
      subNivel: 2,
      titulo: 'Teclas E e I',
      descricao: 'Adicione E e I à fileira do meio',
      instrucao: 'Dedo médio esquerdo vai até o E. Dedo médio direito vai até o I.',
      textos: [
        'dei fei sei lei',
        'fiel leal seal real',
        'die sie lie fie fie',
        'ele ela ele ela ele',
        'ideia ideias série séries',
        'lei lei lei lei lei lei',
        'fiel fiel leal ideal real geal',
        'se de le ke je he fe ele ela eles',
        'vida dica fica liga fica diga fica',
        'ideal real fiel leal série ídolo',
      ],
      teclasEnfoque: ['e', 'i', 'a', 's', 'd', 'f', 'j', 'k', 'l'],
      wpmMeta: 15,
      precisaoMinima: 85,
    ),

    Licao(
      nivel: 'iniciante',
      subNivel: 3,
      titulo: 'Linha Superior',
      descricao: 'Aprenda a linha Q-W-E-R-T-Y-U-I-O-P',
      instrucao: 'Os dedos sobem da posição base para a linha superior. '
          'Volte sempre à posição base!',
      textos: [
        'quero tudo poder',
        'tipo rota pulo tipo',
        'quer ter por que',
        'que por ter rua',
        'para todo tipo rota',
        'rio porto tipo rota quer',
        'você porta tipo quero tudo rota',
        'partir pular torque porta rota',
        'quero poder trabalhar aqui hoje',
        'porta roupa toque para tipo rota',
      ],
      teclasEnfoque: ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
      wpmMeta: 18,
      precisaoMinima: 85,
    ),

    Licao(
      nivel: 'iniciante',
      subNivel: 4,
      titulo: 'Linha Inferior + Todas as Letras',
      descricao: 'Complete o alfabeto com Z-X-C-V-B-N-M',
      instrucao: 'Os dedos descem da posição base para a linha inferior. '
          'Prática completa com todas as letras.',
      textos: [
        'vez bem com vez',
        'bom nada vez com',
        'com vez bom nada vez',
        'mesmo bonito cabeça bem',
        'você mesmo bonito cabeça',
        'bola cama dança nova voz',
        'zebra vaca xícara nuvem mapa',
        'boa notícia chegou com bom humor',
        'vida nova começa com boas escolhas',
        'zumbi xerife vaca bola cama dança nova',
      ],
      teclasEnfoque: ['z', 'x', 'c', 'v', 'b', 'n', 'm'],
      wpmMeta: 20,
      precisaoMinima: 85,
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // MÉDIO
    // ═══════════════════════════════════════════════════════════════════════════

    Licao(
      nivel: 'medio',
      subNivel: 1,
      titulo: 'Palavras Comuns',
      descricao: 'Pratique com as palavras mais usadas em português',
      instrucao: 'Foque na precisão. Velocidade vem com o treino.',
      textos: [
        'o de um para com em não uma os mais',
        'se por mas ao ele das do como bem',
        'que são tem já ou foi há dois me',
        'dia mês ano vida hoje casa mundo rua',
        'tempo forma parte lugar pessoa nova grande',
        'cada vez mais gente trabalhando junto aqui',
        'bom dia como você está hoje espero bem',
        'trabalho escola família amigo cidade país mundo',
        'fazer poder querer tentar conseguir aprender crescer',
        'ontem hoje amanhã sempre nunca talvez certamente',
      ],
      wpmMeta: 25,
      precisaoMinima: 88,
    ),

    Licao(
      nivel: 'medio',
      subNivel: 2,
      titulo: 'Pontuação',
      descricao: 'Adicione vírgulas, pontos e ponto-e-vírgula',
      instrucao: 'Use o dedo mínimo direito para pontuação. Não tire os olhos da tela!',
      textos: [
        'Olá, como vai você?',
        'Bem, obrigado. E você?',
        'Hoje, dia bonito. Sol brilha forte.',
        'Eu gosto de: café, pão e frutas.',
        'Vamos trabalhar; é importante hoje.',
        'Casa, família e saúde: o essencial.',
        'Sim, claro! Pode contar comigo, amigo.',
        'Ele disse: "Preciso de ajuda urgente."',
        'Estudar, praticar e melhorar é o caminho.',
        'Bom dia! Tudo bem por aí? Espero que sim.',
      ],
      teclasEnfoque: [',', '.', ';', ':'],
      wpmMeta: 28,
      precisaoMinima: 88,
    ),

    Licao(
      nivel: 'medio',
      subNivel: 3,
      titulo: 'Números e Símbolos',
      descricao: 'Pratique a linha dos números',
      instrucao: 'Mão esquerda cobre os números 1-5; mão direita cobre 6-0.',
      textos: [
        '123 456 789 0',
        'Número 1: importante',
        '2024 foi um ano de mudanças',
        'Ligue para: (11) 9999-8888',
        'Preço: R\$ 29,90 e R\$ 15,50',
        'Senha: Ab123! (8 caracteres)',
        'De 8h00 às 18h30 trabalhamos',
        '1 + 1 = 2; 3 x 4 = 12; 10 / 2 = 5',
        'Turma 3B: 25 alunos, sala 102',
        'Versão 2.1.3 lançada em 05/11/2024',
      ],
      teclasEnfoque: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
      wpmMeta: 30,
      precisaoMinima: 88,
    ),

    Licao(
      nivel: 'medio',
      subNivel: 4,
      titulo: 'Texto Misto com Acentos',
      descricao: 'Pratique textos reais com acentuação completa',
      instrucao: 'Foque nos acentos e letras especiais do português.',
      textos: [
        'O Brasil é um país de grande biodiversidade.',
        'São Paulo é a maior cidade do Brasil.',
        'Você consegue digitar com precisão?',
        'A língua portuguesa tem muitos acentos: á, é, í, ó, ú, ã, õ.',
        'Educação é o caminho para o crescimento.',
        'Através da tecnologia, podemos aprender mais.',
        'A informática é essencial no mundo moderno.',
        'Ciência e tecnologia andam juntas no século 21.',
        'O computador facilitou nossa vida de inúmeras formas.',
        'Aprender a digitar corretamente é uma habilidade valiosa.',
      ],
      wpmMeta: 35,
      precisaoMinima: 88,
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // AVANÇADO
    // ═══════════════════════════════════════════════════════════════════════════

    Licao(
      nivel: 'avancado',
      subNivel: 1,
      titulo: 'Textos Longos',
      descricao: 'Pratique com parágrafos completos',
      instrucao: 'Mantenha ritmo constante. Precisão em primeiro lugar.',
      textos: [
        'A revolução digital transformou completamente nossa maneira de trabalhar, estudar e nos comunicar com outras pessoas ao redor do mundo.',
        'O desenvolvimento de habilidades tecnológicas se tornou fundamental para todos os profissionais do século XXI, independente da área de atuação.',
        'Dominar a digitação é uma competência básica que aumenta significativamente a produtividade de qualquer pessoa que trabalha com computador diariamente.',
        'Programas de inclusão digital têm ajudado milhares de brasileiros a conquistar novas oportunidades no mercado de trabalho cada vez mais competitivo.',
        'As escolas de informática desempenham papel crucial na formação de cidadãos preparados para os desafios do mercado de trabalho contemporâneo.',
      ],
      wpmMeta: 40,
      precisaoMinima: 90,
    ),

    Licao(
      nivel: 'avancado',
      subNivel: 2,
      titulo: 'Código e Programação',
      descricao: 'Digite trechos de código com símbolos especiais',
      instrucao: 'Programadores precisam digitar caracteres especiais com precisão.',
      textos: [
        'print("Olá, Mundo!")',
        'var nome = "João Silva";',
        'if (idade >= 18) { console.log("Maior de idade"); }',
        'function calcular(a, b) { return a + b; }',
        'SELECT * FROM usuarios WHERE ativo = true;',
        'git commit -m "feat: adiciona login de usuário"',
        'float media = (nota1 + nota2) / 2.0f;',
        '// TODO: implementar verificação de erro',
        '#include <stdio.h>\nint main() { return 0; }',
        'const URL = "https://api.example.com/v1/users";',
      ],
      teclasEnfoque: ['(', ')', '{', '}', '=', '/', '\\', '"', '\'', '_', '-'],
      wpmMeta: 35,
      precisaoMinima: 90,
    ),

    Licao(
      nivel: 'avancado',
      subNivel: 3,
      titulo: 'Texto Rápido Misto',
      descricao: 'Alterne entre letras maiúsculas, números e símbolos',
      instrucao: 'Use Shift com precisão. Mantenha velocidade constante.',
      textos: [
        'João enviou um e-mail para Maria em 15/03/2024.',
        'O relatório Q3-2024 mostrou crescimento de 12,5%.',
        'Senha: Escola@2024! (mínimo 8 caracteres)',
        'CPF: 123.456.789-00 — CNPJ: 12.345.678/0001-90',
        'Contato: (11) 3456-7890 ou info@empresa.com.br',
        'Versão 3.14.1 — corrige bug #2847 e #2851',
        'IMPORTANTE: prazo até 31/12/2024 às 23h59',
        'Ref.: Proposta No. 2024/0589-A -- valor R\$ 1.500,00',
        'Sr. Dr. Paulo R. Almeida Jr. — CRM-SP 123456',
        'URL: https://www.escola.edu.br/alunos?turma=3B&ano=2024',
      ],
      wpmMeta: 45,
      precisaoMinima: 90,
    ),

    Licao(
      nivel: 'avancado',
      subNivel: 4,
      titulo: 'Textos Especializados',
      descricao: 'Textos técnicos e especializados',
      instrucao: 'Aplique toda a técnica aprendida em textos complexos.',
      textos: [
        'O algoritmo de busca binária tem complexidade O(log n), sendo mais eficiente que a busca linear O(n) para grandes conjuntos de dados.',
        'Inteligência artificial e machine learning estão revolucionando setores como saúde, educação, transporte e finanças no Brasil e no mundo.',
        'A Lei Geral de Proteção de Dados (LGPD) estabelece regras claras sobre coleta, armazenamento e uso de dados pessoais pelas empresas.',
        'Redes neurais convolucionais (CNNs) são amplamente utilizadas em visão computacional para reconhecimento de imagens e vídeos em tempo real.',
        'O protocolo HTTPS garante comunicação segura usando criptografia SSL/TLS, protegendo dados transmitidos entre cliente e servidor.',
      ],
      wpmMeta: 50,
      precisaoMinima: 92,
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // HARDCORE
    // ═══════════════════════════════════════════════════════════════════════════

    Licao(
      nivel: 'hardcore',
      subNivel: 1,
      titulo: 'Velocidade Máxima',
      descricao: 'Pressão de tempo — 30 segundos por texto',
      instrucao: 'VELOCIDADE é o foco. Mínimo de 60 WPM. SEM pausas!',
      textos: [
        'O rápido lobo marrom pula sobre o preguiçoso cão.',
        'Programar é uma arte que combina lógica criatividade e dedicação constante.',
        'Velocidade e precisão são as duas metas do digitador profissional moderno.',
        'A prática diária de digitação acelera o desenvolvimento da memória muscular.',
        'Quanto mais você pratica mais seus dedos aprendem o caminho das teclas.',
      ],
      duracaoSegundos: 30,
      wpmMeta: 60,
      precisaoMinima: 92,
    ),

    Licao(
      nivel: 'hardcore',
      subNivel: 2,
      titulo: 'Texto Aleatório Longo',
      descricao: 'Textos imprevisíveis em alta velocidade',
      instrucao: 'Sem descanso! Foco total. 60+ WPM com 95% de precisão.',
      textos: [
        'Xeque-mate! O rei ficou encurralado após a jogada brilhante do cavaleiro branco posicionado estrategicamente no centro do tabuleiro.',
        'Fotossíntese é o processo pelo qual plantas verdes convertem luz solar em energia química usando gás carbônico e água para produzir glicose.',
        'Hipopótamo-anão é uma espécie criticamente ameaçada que vive exclusivamente nas florestas úmidas da África Ocidental, especialmente na Libéria.',
        'Supercalifragilisticexpialidócio é uma palavra inventada que simboliza algo maravilhoso e fantástico além de qualquer descrição possível.',
        'Pneumoultramicroscopicossilicovulcanoconiótico é considerada a maior palavra da língua portuguesa com cinquenta e seis letras no total.',
      ],
      duracaoSegundos: 45,
      wpmMeta: 65,
      precisaoMinima: 92,
    ),

    Licao(
      nivel: 'hardcore',
      subNivel: 3,
      titulo: 'Código em Alta Velocidade',
      descricao: 'Código real com todos os símbolos',
      instrucao: 'Código sem erros. Precisão máxima. SEM desculpas!',
      textos: [
        'function quickSort(arr) { if (arr.length <= 1) return arr; const pivot = arr[Math.floor(arr.length / 2)]; }',
        'SELECT u.nome, COUNT(p.id) AS total FROM usuarios u LEFT JOIN pedidos p ON u.id = p.user_id GROUP BY u.id;',
        'docker run -d -p 8080:80 --name meu_app -e DB_HOST=localhost -v /data:/app/data nginx:latest',
        'git log --oneline --graph --all --decorate | head -20 && git status --short',
        'curl -X POST https://api.example.com/v2/auth -H "Content-Type: application/json" -d \'{"user":"admin","pass":"S3cr3t!"}\'',
      ],
      duracaoSegundos: 60,
      wpmMeta: 55,
      precisaoMinima: 95,
    ),

    Licao(
      nivel: 'hardcore',
      subNivel: 4,
      titulo: 'Desafio Final',
      descricao: 'O teste definitivo do digitador mestre',
      instrucao: 'TUDO misturado. 70+ WPM. 95%+ precisão. Prove que você é TypeMaster!',
      textos: [
        'Sr. Dr. Joao M. Silva (CRM-SP: 12345-6) -- Consulta as 14h30 do dia 05/12/2024. Convenio: Unimed Gold (No. 789-012-345). Procedimento: Tomografia 3D -- R\$ 850,00.',
        'ERRO #404: Recurso não encontrado em https://api.empresa.com.br/v3/usuarios/987654?formato=json&token=eyJhbGciOiJIUzI1NiJ9',
        'config.yml: host: "db.prod.local", port: 5432, user: "admin", password: "P@ss#2024!", pool: { min: 2, max: 20, timeout: 30000 }',
        'Formulas: E=mc2, F=ma, PV=nRT, pH=-log[H+], velocidade=distancia/tempo.',
        'Chmod 755 /var/www/html && chown -R www-data:www-data /var/www && systemctl restart nginx && tail -f /var/log/nginx/error.log',
      ],
      duracaoSegundos: 60,
      wpmMeta: 70,
      precisaoMinima: 95,
    ),
  ];

  static Licao? buscar(String nivel, int subNivel) {
    try {
      return todas.firstWhere(
        (l) => l.nivel == nivel && l.subNivel == subNivel,
      );
    } catch (_) {
      return null;
    }
  }

  static List<Licao> porNivel(String nivel) {
    return todas.where((l) => l.nivel == nivel).toList();
  }
}

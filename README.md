# B&S Vistoria Veicular - Sistema de Gestão Financeira

Sistema de gestão financeira desenvolvido para a B&S Vistoria Veicular, permitindo o controle de contas a receber, contas a pagar e geração de relatórios financeiros.

## 🚀 Tecnologias Utilizadas

- Flutter (Frontend)
- Supabase (Backend e Banco de Dados)
- PostgreSQL (Banco de Dados)
- Riverpod (Gerenciamento de Estado)
- Go Router (Navegação)

## 📋 Funcionalidades

### 1. Autenticação
- Login com e-mail e senha
- Integração com Supabase Auth

### 2. Contas a Receber
- Cadastro de recebimentos
- Registro de provisões
- Listagem e exclusão de contas
- Filtros por período

### 3. Contas a Pagar
- Cadastro de despesas
- Registro de provisões
- Listagem e exclusão de contas
- Filtros por período

### 4. Relatórios Financeiros
- Filtro por período
- Total de entradas e saídas
- Saldo final
- Detalhamento de movimentações

## 🛠️ Configuração do Ambiente

1. Clone o repositório:
```bash
git clone https://github.com/seu-usuario/bs-vistoria-veicular.git
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Configure as variáveis de ambiente:
- Crie um arquivo `.env` na raiz do projeto
- Adicione as credenciais do Supabase:
```
SUPABASE_URL=sua_url_do_supabase
SUPABASE_ANON_KEY=sua_chave_anonima_do_supabase
```

4. Execute o projeto:
```bash
flutter run
```

## 📱 Plataformas Suportadas

- Web
- Desktop (Windows, macOS, Linux)
- Mobile (Android, iOS)

## 🎨 Design

O sistema utiliza um design moderno e profissional com as seguintes características:

- Cores predominantes:
  - Amarelo (primária)
  - Preto (texto e contraste)
  - Branco (fundos limpos e seções)

- Efeitos visuais:
  - Transições suaves
  - Animações em botões e listas
  - Layout responsivo

## 📊 Banco de Dados

O sistema utiliza o Supabase com PostgreSQL, contendo as seguintes tabelas:

### Usuários
```sql
CREATE TABLE usuarios (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(150) UNIQUE NOT NULL,
  senha VARCHAR(255) NOT NULL
);
```

### Contas a Receber
```sql
CREATE TABLE contas_receber (
  id SERIAL PRIMARY KEY,
  descricao TEXT NOT NULL,
  valor NUMERIC(10, 2) NOT NULL,
  forma_pagamento VARCHAR(50),
  data_recebimento DATE,
  tipo VARCHAR(20) CHECK (tipo IN ('entrada', 'provisao')),
  contato_cliente VARCHAR(100),
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Contas a Pagar
```sql
CREATE TABLE contas_pagar (
  id SERIAL PRIMARY KEY,
  descricao TEXT NOT NULL,
  valor NUMERIC(10, 2) NOT NULL,
  forma_pagamento VARCHAR(50),
  data_pagamento DATE,
  tipo VARCHAR(20) CHECK (tipo IN ('pago', 'provisao')),
  fornecedor VARCHAR(100),
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.  teste

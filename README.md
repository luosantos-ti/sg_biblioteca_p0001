Esse é um projeto que criei para estudar e praticar modelagem de dados na prática.  
A ideia foi simular a migração de uma biblioteca digital (fictícia) que antes usava planilhas e agora precisa de um banco de dados relacional bem estruturado.

O foco foi aprender e aplicar:
- criação do modelo lógico
- DER
- tabelas com PK, FK e campos de auditoria
- relacionamento N:M entre livros e autores
- consultas SQL para responder perguntas reais de negócio

---

O que tem no projeto

Modelo lógico + DER**
Com os principais relacionamentos:
- Book ↔ Publisher (1:N)  
- User ↔ Loan (1:N)  
- Book ↔ Loan (1:N)  
- Author ↔ Book (N:M via `book_author`)
  
---

Scripts SQL (DDL)
Tabelas disponíveis:
- `author`
- `publisher`
- `users`
- `book`
- `loan`
- `book_author`

---

Todas já com chaves primárias, estrangeiras, controle de auditoria e tipos adequados.

Queries de análise
Incluí algumas consultas úteis, como:
- livros atrasados (overdue)
- autores mais emprestados
- livros com múltiplos autores
- histórico de usuários inativos
- tempo médio de retenção por editora

---

Ambiente Python (opcional)
Adicionei um pequeno passo a passo para criar um ambiente virtual e rodar um script de seed usando:
- SQLAlchemy  
- PyMySQL  
- Cryptography  

Nada muito complexo, só para facilitar a inserção de dados fictícios.

Obs: Para que o seed funcione, é necessário ter um schema criado no Workbench e que no topo do arquivo de seed, as configurações para conexão ao banco de dados estejam de acordo com o que foi previamente configurado localmente, tal como admin, senha, nome_do_banco.

Licença:
Projeto aberto para estudo e consulta.

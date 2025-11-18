# Verificador de Força de Senha em Assembly MIPS

## Descrição

Programa modular em Assembly MIPS que verifica a força de uma senha baseado em múltiplos critérios de segurança. O programa exibe visualmente quais critérios foram atendidos e uma representação gráfica da força geral da senha.

## Estrutura do Projeto

O projeto é dividido em múltiplos módulos para facilitar manutenção e compreensão:

- **main.asm**: Arquivo principal que orquestra o programa, lê entrada do usuário e coordena as verificações
- **check_uppercase.asm**: Verifica se a senha contém pelo menos um caractere maiúsculo (A-Z)
- **check_lowercase.asm**: Verifica se a senha contém pelo menos um caractere minúsculo (a-z)
- **check_special.asm**: Verifica se a senha contém pelo menos um caractere especial
- **check_length.asm**: Verifica se a senha tem pelo menos 8 caracteres
- **check_repetition.asm**: Verifica se nenhum caractere se repete mais de duas vezes
- **display_strength.asm**: Exibe visualmente a força da senha baseada nos critérios atendidos
- **utils.asm**: Funções utilitárias reutilizáveis (strlen, remove_newline)

## Critérios de Verificação

O programa verifica os seguintes critérios:

1. **Maiúscula**: Pelo menos um caractere maiúsculo (A-Z)
2. **Minúscula**: Pelo menos um caractere minúsculo (a-z)
3. **Caractere Especial**: Pelo menos um caractere especial (!@#$%^&*()_+-=[]{}|;:,.<>?/~`)
4. **Comprimento**: Mínimo de 8 caracteres
5. **Repetição**: Nenhum caractere se repete mais de duas vezes

## Níveis de Força

A força da senha é calculada baseada no número de critérios atendidos:

- **0-1 critérios**: MUITO FRACA [█░░░░░░░░] 0-20%
- **2 critérios**: FRACA [██░░░░░░░] 21-40%
- **3 critérios**: MÉDIA [████░░░░░] 41-60%
- **4 critérios**: FORTE [██████░░░] 61-80%
- **5 critérios**: MUITO FORTE [█████████░] 81-100%

## Convenção de Chamada MIPS

O programa segue a convenção padrão do MIPS:

- **Argumentos**: `$a0`, `$a1`, `$a2`, `$a3`
- **Valores de retorno**: `$v0`, `$v1`
- **Registradores salvos**: `$s0-$s7` (devem ser salvos na pilha se usados)
- **Registradores temporários**: `$t0-$t9` (não precisam ser salvos)
- **Endereço de retorno**: `$ra` (deve ser salvo na pilha se a função chama outras)

## Gerenciamento de Pilha

Todas as sub-rotinas seguem o protocolo correto de gerenciamento de pilha:

1. **Salvar registradores** antes de usar (`$ra`, `$s0-$s7`)
2. **Alocar espaço** na pilha (`addi $sp, $sp, -N`)
3. **Restaurar registradores** antes de retornar
4. **Desalocar espaço** da pilha (`addi $sp, $sp, N`)

## Como Compilar e Executar

### ⚠️ IMPORTANTE: Qual arquivo usar?

**Use o arquivo `verificador_senha_completo.asm`** - Este é o arquivo consolidado que contém todo o código necessário em um único arquivo.

O arquivo `main.asm` é apenas para referência modular e requer outros arquivos que não estão incluídos automaticamente.

### Usando MARS (MIPS Assembler and Runtime Simulator)

1. Abra o MARS
2. **Abra o arquivo `verificador_senha_completo.asm`** (NÃO o main.asm)
3. Compile (Assemble) - Pressione F3 ou clique em "Assemble"
4. Execute (Run) - Pressione F5 ou clique em "Run"
5. Digite sua senha quando solicitado

### Usando SPIM

1. Abra o SPIM
2. **Carregue o arquivo `verificador_senha_completo.asm`**
3. Execute o programa
4. Digite sua senha quando solicitado

### Nota sobre arquivos modulares

Se você quiser usar a versão modular (`main.asm`), você precisaria:
- Abrir todos os arquivos `.asm` no MARS simultaneamente
- Ou usar um sistema de includes (que o MARS não suporta nativamente)
- Por isso, recomendamos usar `verificador_senha_completo.asm`

## Exemplo de Uso

```
Digite sua senha: MinhaSenh@123

=== FORÇA DA SENHA ===

Critérios verificados:
----------------------------------------
[X] Maiúscula
[X] Minúscula
[X] Caractere Especial
[X] Mínimo 8 caracteres
[X] Sem repetição excessiva
----------------------------------------

FORÇA: MUITO FORTE [█████████░] 81-100%
```

## Tratamento de Erros

O programa trata os seguintes casos de erro:

- **Senha vazia**: Exibe mensagem de erro e encerra
- **Entrada inválida**: Validação básica de entrada

## Características Técnicas

- **Modularização**: Código dividido em múltiplos arquivos para facilitar manutenção
- **Reutilização**: Funções utilitárias compartilhadas
- **Gerenciamento de pilha**: Implementação correta do protocolo de pilha
- **Convenção de chamada**: Seguimento rigoroso da convenção MIPS
- **Documentação**: Código comentado e documentado

## Notas de Implementação

- O programa assume que a entrada do usuário termina com newline (`\n`)
- A remoção do newline é feita automaticamente
- A verificação de repetição é O(n²) no pior caso, mas eficiente para senhas normais
- Caracteres especiais são verificados através de intervalos ASCII


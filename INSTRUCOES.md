# Instruções de Uso - Verificador de Força de Senha

## Estrutura do Projeto

O projeto está organizado em dois formatos:

### 1. Versão Modular (Arquivos Separados)
- `main.asm` - Programa principal
- `check_uppercase.asm` - Verificação de maiúsculas
- `check_lowercase.asm` - Verificação de minúsculas
- `check_special.asm` - Verificação de caracteres especiais
- `check_length.asm` - Verificação de comprimento
- `check_repetition.asm` - Verificação de repetição
- `display_strength.asm` - Exibição da força
- `utils.asm` - Funções utilitárias

### 2. Versão Consolidada (Arquivo Único)
- `verificador_senha_completo.asm` - Todos os módulos em um único arquivo

## Como Usar

### ⚠️ IMPORTANTE: Use `verificador_senha_completo.asm`

**SEMPRE use o arquivo `verificador_senha_completo.asm`** - Este é o arquivo completo e funcional.

### Opção 1: MARS (MIPS Assembler and Runtime Simulator) - RECOMENDADO

1. Abra o MARS
2. File → Open → Selecione `verificador_senha_completo.asm`
3. Assemble (F3 ou botão "Assemble")
4. Run (F5 ou botão "Run")
5. Digite sua senha quando solicitado no console

### Opção 2: SPIM

1. Abra o SPIM
2. File → Load → Selecione `verificador_senha_completo.asm`
3. Execute o programa
4. Digite sua senha quando solicitado

### Sobre os outros arquivos

- `main.asm` - Apenas para referência (não funciona sozinho)
- `check_*.asm` - Módulos individuais (não funcionam sozinhos)
- `display_strength.asm` - Módulo individual (não funciona sozinho)

**Todos esses arquivos estão consolidados em `verificador_senha_completo.asm`**

### Opção 2: SPIM

1. Abra o SPIM
2. File → Load → Selecione `verificador_senha_completo.asm`
3. Execute o programa

## Exemplo de Execução

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

## Critérios de Verificação

1. **Maiúscula**: Pelo menos um caractere A-Z
2. **Minúscula**: Pelo menos um caractere a-z
3. **Caractere Especial**: Pelo menos um caractere especial (!@#$%^&*()_+-=[]{}|;:,.<>?/~`)
4. **Comprimento**: Mínimo de 8 caracteres
5. **Repetição**: Nenhum caractere se repete mais de 2 vezes

## Níveis de Força

- **0-1 critérios**: MUITO FRACA (0-20%)
- **2 critérios**: FRACA (21-40%)
- **3 critérios**: MÉDIA (41-60%)
- **4 critérios**: FORTE (61-80%)
- **5 critérios**: MUITO FORTE (81-100%)

## Características Técnicas

- ✅ Uso correto de sub-rotinas
- ✅ Gerenciamento adequado da pilha
- ✅ Convenção de chamada MIPS ($a0-$a3, $v0-$v1, $s0-$s7)
- ✅ Modularização em múltiplos arquivos
- ✅ Tratamento de erros (senha vazia)
- ✅ Código documentado e comentado

## Notas Importantes

- O programa remove automaticamente o newline (`\n`) do final da entrada
- A verificação de repetição é case-sensitive (A ≠ a)
- Caracteres especiais são verificados através de intervalos ASCII
- O programa suporta senhas de até 256 caracteres


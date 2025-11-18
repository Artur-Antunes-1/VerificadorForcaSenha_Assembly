# Programa Completo - Verificador de Força de Senha
# Versão consolidada para simuladores que não suportam includes
# Autor: Sistema de Verificação de Senha
# Descrição: Programa modular que verifica a força de uma senha

.data
    prompt:         .asciiz "Digite sua senha: "
    newline:        .asciiz "\n"
    password:       .space 256
    strength_msg:   .asciiz "\n=== FORÇA DA SENHA ===\n"
    criteria_msg:   .asciiz "\nCritérios verificados:\n"
    separator:      .asciiz "----------------------------------------\n"
    
    # Mensagens de critérios
    msg_uppercase:  .asciiz "[ ] Maiúscula\n"
    msg_lowercase:  .asciiz "[ ] Minúscula\n"
    msg_special:    .asciiz "[ ] Caractere Especial\n"
    msg_length:     .asciiz "[ ] Mínimo 8 caracteres\n"
    msg_repetition: .asciiz "[ ] Sem repetição excessiva\n"
    
    # Mensagens de força
    msg_very_weak:  .asciiz "\nFORÇA: MUITO FRACA [█░░░░░░░░] 0-20%\n"
    msg_weak:       .asciiz "\nFORÇA: FRACA [██░░░░░░░] 21-40%\n"
    msg_medium:     .asciiz "\nFORÇA: MÉDIA [████░░░░░] 41-60%\n"
    msg_strong:     .asciiz "\nFORÇA: FORTE [██████░░░] 61-80%\n"
    msg_very_strong:.asciiz "\nFORÇA: MUITO FORTE [█████████░] 81-100%\n"
    
    error_msg:      .asciiz "Erro: Entrada inválida ou senha vazia!\n"

.text
.globl main

main:
    # Salvar registradores na pilha
    addi $sp, $sp, -36
    sw $ra, 32($sp)
    sw $s0, 28($sp)
    sw $s1, 24($sp)
    sw $s2, 20($sp)
    sw $s3, 16($sp)
    sw $s4, 12($sp)
    sw $s5, 8($sp)
    sw $s6, 4($sp)
    
    # Solicitar entrada do usuário
    li $v0, 4
    la $a0, prompt
    syscall
    
    # Ler senha
    li $v0, 8
    la $a0, password
    li $a1, 256
    syscall
    
    # Remover newline do final da string
    la $a0, password
    jal remove_newline
    
    # Verificar se a senha não está vazia
    la $a0, password
    jal strlen
    move $s0, $v0  # $s0 = comprimento da senha
    
    beq $s0, $zero, error_empty
    
    # Inicializar contador de critérios atendidos
    li $s1, 0  # $s1 = contador de critérios
    
    # Verificar cada critério
    la $a0, password
    jal check_uppercase
    move $s2, $v0  # $s2 = tem maiúscula
    
    la $a0, password
    jal check_lowercase
    move $s3, $v0  # $s3 = tem minúscula
    
    la $a0, password
    jal check_special
    move $s4, $v0  # $s4 = tem especial
    
    la $a0, password
    jal check_length
    move $s5, $v0  # $s5 = tem comprimento adequado
    
    la $a0, password
    jal check_repetition
    move $s6, $v0  # $s6 = sem repetição excessiva
    
    # Calcular força usando sistema de pontuação ponderada
    # Passar todos os critérios para a função de cálculo
    move $a0, $s2  # maiúscula
    move $a1, $s3  # minúscula
    move $a2, $s4  # especial
    move $a3, $s5  # comprimento
    addi $sp, $sp, -8
    sw $s6, 4($sp)  # repetição
    sw $s0, 0($sp)  # comprimento real da senha
    jal calculate_strength
    addi $sp, $sp, 8  # limpar argumentos da pilha
    move $s1, $v0  # $s1 = pontuação de força (0-100)
    
    # Exibir resultados (passar valores como argumentos)
    move $a0, $s2  # maiúscula
    move $a1, $s3  # minúscula
    move $a2, $s4  # especial
    move $a3, $s5  # comprimento
    addi $sp, $sp, -4
    sw $s6, 0($sp)  # repetição (5º argumento na pilha)
    jal display_results
    addi $sp, $sp, 4  # limpar argumento da pilha
    
    # Exibir força visual
    move $a0, $s1  # Pontuação de força (0-100)
    jal display_strength
    
    j end_main

error_empty:
    li $v0, 4
    la $a0, error_msg
    syscall
    j end_main

end_main:
    # Restaurar registradores da pilha
    lw $ra, 32($sp)
    lw $s0, 28($sp)
    lw $s1, 24($sp)
    lw $s2, 20($sp)
    lw $s3, 16($sp)
    lw $s4, 12($sp)
    lw $s5, 8($sp)
    lw $s6, 4($sp)
    addi $sp, $sp, 36
    
    # Encerrar programa
    li $v0, 10
    syscall

# ============================================================================
# MÓDULO: Utilitários
# ============================================================================

# Sub-rotina para remover newline do final da string
remove_newline:
    move $t0, $a0
remove_loop:
    lb $t1, 0($t0)
    beq $t1, '\n', remove_found
    beq $t1, '\r', remove_found
    beq $t1, $zero, remove_done
    addi $t0, $t0, 1
    j remove_loop
remove_found:
    sb $zero, 0($t0)
remove_done:
    jr $ra

# Sub-rotina para calcular comprimento da string
strlen:
    li $v0, 0
    move $t0, $a0
strlen_loop:
    lb $t1, 0($t0)
    beq $t1, $zero, strlen_done
    beq $t1, '\n', strlen_done
    beq $t1, '\r', strlen_done
    addi $v0, $v0, 1
    addi $t0, $t0, 1
    j strlen_loop
strlen_done:
    jr $ra

# ============================================================================
# MÓDULO: Verificação de Maiúsculas
# ============================================================================

check_uppercase:
    # Entrada: $a0 = endereço da string da senha
    # Saída: $v0 = 1 se tem maiúscula, 0 caso contrário
    
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    
    move $s0, $a0  # Salvar endereço da string
    li $s1, 0      # Flag: 0 = não encontrou, 1 = encontrou
    
check_upper_loop:
    lb $t0, 0($s0)           # Carregar caractere atual
    beq $t0, $zero, check_upper_done  # Se chegou ao fim da string
    
    # Verificar se é maiúscula (A-Z: ASCII 65-90)
    li $t1, 65   # 'A'
    li $t2, 90   # 'Z'
    
    blt $t0, $t1, check_upper_next
    bgt $t0, $t2, check_upper_next
    
    # É maiúscula!
    li $s1, 1
    j check_upper_done
    
check_upper_next:
    addi $s0, $s0, 1
    j check_upper_loop
    
check_upper_done:
    move $v0, $s1
    
    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addi $sp, $sp, 12
    jr $ra

# ============================================================================
# MÓDULO: Verificação de Minúsculas
# ============================================================================

check_lowercase:
    # Entrada: $a0 = endereço da string da senha
    # Saída: $v0 = 1 se tem minúscula, 0 caso contrário
    
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    
    move $s0, $a0  # Salvar endereço da string
    li $s1, 0      # Flag: 0 = não encontrou, 1 = encontrou
    
check_lower_loop:
    lb $t0, 0($s0)           # Carregar caractere atual
    beq $t0, $zero, check_lower_done  # Se chegou ao fim da string
    
    # Verificar se é minúscula (a-z: ASCII 97-122)
    li $t1, 97   # 'a'
    li $t2, 122  # 'z'
    
    blt $t0, $t1, check_lower_next
    bgt $t0, $t2, check_lower_next
    
    # É minúscula!
    li $s1, 1
    j check_lower_done
    
check_lower_next:
    addi $s0, $s0, 1
    j check_lower_loop
    
check_lower_done:
    move $v0, $s1
    
    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addi $sp, $sp, 12
    jr $ra

# ============================================================================
# MÓDULO: Verificação de Caracteres Especiais
# ============================================================================

check_special:
    # Entrada: $a0 = endereço da string da senha
    # Saída: $v0 = 1 se tem caractere especial, 0 caso contrário
    
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    
    move $s0, $a0  # Salvar endereço da string
    li $s1, 0      # Flag: 0 = não encontrou, 1 = encontrou
    
check_special_loop:
    lb $t0, 0($s0)           # Carregar caractere atual
    beq $t0, $zero, check_special_done  # Se chegou ao fim da string
    
    # Verificar se é caractere especial
    # Caracteres especiais comuns: !@#$%^&*()_+-=[]{}|;:,.<>?/~`
    # ASCII: 33-47, 58-64, 91-96, 123-126
    
    # Verificar intervalo 33-47 (! até /)
    li $t1, 33
    li $t2, 47
    bge $t0, $t1, check_range1_start
    j check_range2
check_range1_start:
    ble $t0, $t2, found_special
    
check_range2:
    # Verificar intervalo 58-64 (: até @)
    li $t1, 58
    li $t2, 64
    bge $t0, $t1, check_range2_start
    j check_range3
check_range2_start:
    ble $t0, $t2, found_special
    
check_range3:
    # Verificar intervalo 91-96 ([ até `)
    li $t1, 91
    li $t2, 96
    bge $t0, $t1, check_range3_start
    j check_range4
check_range3_start:
    ble $t0, $t2, found_special
    
check_range4:
    # Verificar intervalo 123-126 ({ até ~)
    li $t1, 123
    li $t2, 126
    bge $t0, $t1, check_range4_start
    j check_special_next
check_range4_start:
    ble $t0, $t2, found_special
    j check_special_next
    
found_special:
    # É caractere especial!
    li $s1, 1
    j check_special_done
    
check_special_next:
    addi $s0, $s0, 1
    j check_special_loop
    
check_special_done:
    move $v0, $s1
    
    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addi $sp, $sp, 12
    jr $ra

# ============================================================================
# MÓDULO: Verificação de Comprimento
# ============================================================================

check_length:
    # Entrada: $a0 = endereço da string da senha
    # Saída: $v0 = 1 se tem pelo menos 8 caracteres, 0 caso contrário
    
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    
    move $s0, $a0  # Salvar endereço da string
    li $s1, 0      # Contador de caracteres
    
check_length_loop:
    lb $t0, 0($s0)           # Carregar caractere atual
    beq $t0, $zero, check_length_done  # Se chegou ao fim da string
    
    addi $s1, $s1, 1
    addi $s0, $s0, 1
    j check_length_loop
    
check_length_done:
    # Verificar se tem pelo menos 8 caracteres
    li $t0, 8
    bge $s1, $t0, length_ok
    li $v0, 0
    j length_end
    
length_ok:
    li $v0, 1
    
length_end:
    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addi $sp, $sp, 12
    jr $ra

# ============================================================================
# MÓDULO: Verificação de Repetição de Caracteres
# ============================================================================

check_repetition:
    # Entrada: $a0 = endereço da string da senha
    # Saída: $v0 = 1 se não há repetição excessiva, 0 caso contrário
    
    addi $sp, $sp, -32
    sw $ra, 28($sp)
    sw $s0, 24($sp)
    sw $s1, 20($sp)
    sw $s2, 16($sp)
    sw $s3, 12($sp)
    sw $s4, 8($sp)
    sw $s5, 4($sp)
    sw $s6, 0($sp)
    
    move $s0, $a0  # Salvar endereço da string
    li $s1, 0      # Índice do caractere atual
    li $v0, 1      # Assumir que não há repetição excessiva (retorno padrão)
    
    # Primeiro, calcular o comprimento da string
    move $a0, $s0
    jal strlen_aux
    move $s2, $v0  # $s2 = comprimento da string
    
    # Se a string tem menos de 3 caracteres, não pode ter repetição excessiva
    li $t0, 3
    blt $s2, $t0, repetition_done
    
check_repetition_outer:
    # Para cada caractere na string
    bge $s1, $s2, repetition_done  # Se percorreu toda a string
    
    # Obter caractere atual
    add $t0, $s0, $s1
    lb $s3, 0($t0)  # $s3 = caractere atual
    beq $s3, $zero, repetition_done
    
    # Contar quantas vezes este caractere aparece
    li $s4, 0      # Contador de ocorrências
    li $s5, 0      # Índice para percorrer a string
    
count_occurrences:
    bge $s5, $s2, check_count  # Se percorreu toda a string
    
    add $t0, $s0, $s5
    lb $t1, 0($t0)
    beq $t1, $zero, check_count
    
    # Comparar com o caractere atual
    bne $t1, $s3, count_next
    addi $s4, $s4, 1  # Incrementar contador
    
count_next:
    addi $s5, $s5, 1
    j count_occurrences
    
check_count:
    # Se o caractere aparece mais de 2 vezes, senha inválida
    li $t0, 2
    bgt $s4, $t0, repetition_found
    
    addi $s1, $s1, 1
    j check_repetition_outer
    
repetition_found:
    li $v0, 0  # Repetição excessiva encontrada
    
repetition_done:
    lw $ra, 28($sp)
    lw $s0, 24($sp)
    lw $s1, 20($sp)
    lw $s2, 16($sp)
    lw $s3, 12($sp)
    lw $s4, 8($sp)
    lw $s5, 4($sp)
    lw $s6, 0($sp)
    addi $sp, $sp, 32
    jr $ra

# Sub-rotina auxiliar para calcular comprimento (usada por check_repetition)
strlen_aux:
    li $v0, 0
    move $t0, $a0
strlen_aux_loop:
    lb $t1, 0($t0)
    beq $t1, $zero, strlen_aux_done
    addi $v0, $v0, 1
    addi $t0, $t0, 1
    j strlen_aux_loop
strlen_aux_done:
    jr $ra

# ============================================================================
# MÓDULO: Exibição de Resultados
# ============================================================================

# Sub-rotina para exibir resultados dos critérios
# Argumentos: $a0 = maiúscula, $a1 = minúscula, $a2 = especial, $a3 = comprimento, 0($sp) = repetição
display_results:
    addi $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)
    sw $s4, 0($sp)
    
    # Salvar argumentos em registradores salvos
    move $s0, $a0  # maiúscula
    move $s1, $a1  # minúscula
    move $s2, $a2  # especial
    move $s3, $a3  # comprimento
    lw $s4, 28($sp)  # repetição (está na pilha acima do frame atual: 24 bytes do frame + 4 bytes do argumento)
    
    # Exibir cabeçalho
    li $v0, 4
    la $a0, strength_msg
    syscall
    
    la $a0, criteria_msg
    syscall
    
    la $a0, separator
    syscall
    
    # Exibir cada critério
    # Maiúscula
    la $a0, msg_uppercase
    move $a1, $s0
    jal print_criterion
    
    # Minúscula
    la $a0, msg_lowercase
    move $a1, $s1
    jal print_criterion
    
    # Especial
    la $a0, msg_special
    move $a1, $s2
    jal print_criterion
    
    # Comprimento
    la $a0, msg_length
    move $a1, $s3
    jal print_criterion
    
    # Repetição
    la $a0, msg_repetition
    move $a1, $s4
    jal print_criterion
    
    la $a0, separator
    syscall
    
    lw $ra, 20($sp)
    lw $s0, 16($sp)
    lw $s1, 12($sp)
    lw $s2, 8($sp)
    lw $s3, 4($sp)
    lw $s4, 0($sp)
    addi $sp, $sp, 24
    jr $ra

# Sub-rotina para imprimir um critério (marca [X] ou [ ])
print_criterion:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Imprimir até o '['
    move $t0, $a0
print_until_bracket:
    lb $t1, 0($t0)
    beq $t1, '[', found_bracket
    li $v0, 11
    move $a0, $t1
    syscall
    addi $t0, $t0, 1
    j print_until_bracket
    
found_bracket:
    # Imprimir '['
    li $v0, 11
    li $a0, '['
    syscall
    
    # Imprimir 'X' ou ' '
    beq $a1, $zero, print_space
    li $a0, 'X'
    j print_mark
print_space:
    li $a0, ' '
print_mark:
    syscall
    
    # Imprimir ']'
    li $a0, ']'
    syscall
    
    # Imprimir o resto da string
    addi $t0, $t0, 2  # Pular ']' e espaço
    move $a0, $t0
    li $v0, 4
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# ============================================================================
# MÓDULO: Cálculo de Força da Senha
# ============================================================================

# Função para calcular a força da senha usando sistema de pontuação ponderada
# Argumentos: $a0 = maiúscula, $a1 = minúscula, $a2 = especial, $a3 = comprimento
#             0($sp) = comprimento real, 4($sp) = repetição
# Retorno: $v0 = pontuação de força (0-100)
calculate_strength:
    addi $sp, $sp, -32
    sw $ra, 28($sp)
    sw $s0, 24($sp)
    sw $s1, 20($sp)
    sw $s2, 16($sp)
    sw $s3, 12($sp)
    sw $s4, 8($sp)
    sw $s5, 4($sp)
    sw $s6, 0($sp)
    
    # Salvar argumentos
    move $s0, $a0  # maiúscula
    move $s1, $a1  # minúscula
    move $s2, $a2  # especial
    move $s3, $a3  # comprimento (>=8)
    lw $s4, 32($sp)  # comprimento real
    lw $s5, 36($sp)  # repetição
    
    li $s6, 0  # Pontuação total (iniciar em 0)
    
    # 1. Comprimento (peso: 30 pontos)
    # Se tem pelo menos 8 caracteres: 30 pontos
    # Se tem 6-7 caracteres: 15 pontos
    # Se tem 4-5 caracteres: 5 pontos
    # Se tem menos de 4: 0 pontos
    beq $s3, 1, score_length_8_plus
    li $t0, 6
    bge $s4, $t0, score_length_6_7
    li $t0, 4
    bge $s4, $t0, score_length_4_5
    j score_length_done
score_length_8_plus:
    addi $s6, $s6, 30
    j score_length_done
score_length_6_7:
    addi $s6, $s6, 15
    j score_length_done
score_length_4_5:
    addi $s6, $s6, 5
score_length_done:
    
    # 2. Maiúscula (peso: 15 pontos)
    beq $s0, $zero, score_uppercase_done
    addi $s6, $s6, 15
score_uppercase_done:
    
    # 3. Minúscula (peso: 15 pontos)
    beq $s1, $zero, score_lowercase_done
    addi $s6, $s6, 15
score_lowercase_done:
    
    # 4. Caractere Especial (peso: 20 pontos)
    beq $s2, $zero, score_special_done
    addi $s6, $s6, 20
score_special_done:
    
    # 5. Repetição (peso: 20 pontos)
    beq $s5, $zero, repetition_score_done
    addi $s6, $s6, 20
repetition_score_done:
    
    # 6. Bônus por diversidade de tipos de caracteres
    # Contar quantos tipos diferentes temos
    li $t0, 0  # Contador de tipos
    add $t0, $t0, $s0  # maiúscula
    add $t0, $t0, $s1  # minúscula
    add $t0, $t0, $s2  # especial
    
    # Se tem apenas 1 tipo: penalizar (reduzir 10 pontos)
    li $t1, 1
    bne $t0, $t1, check_2_types
    # Penalizar se tem apenas um tipo
    li $t2, 10
    sub $s6, $s6, $t2
    # Garantir que não fique negativo
    bge $s6, $zero, check_2_types
    li $s6, 0
check_2_types:
    
    # 7. Penalidade adicional se não tem comprimento mínimo E pouca diversidade
    beq $s3, 1, no_length_penalty
    li $t1, 2
    blt $t0, $t1, apply_length_penalty
    j no_length_penalty
apply_length_penalty:
    # Reduzir mais 10 pontos se não tem comprimento E pouca diversidade
    li $t2, 10
    sub $s6, $s6, $t2
    bge $s6, $zero, no_length_penalty
    li $s6, 0
no_length_penalty:
    
    # Garantir que a pontuação está entre 0 e 100
    li $t0, 100
    ble $s6, $t0, score_ok
    li $s6, 100
score_ok:
    bge $s6, $zero, score_positive
    li $s6, 0
score_positive:
    
    move $v0, $s6
    
    lw $ra, 28($sp)
    lw $s0, 24($sp)
    lw $s1, 20($sp)
    lw $s2, 16($sp)
    lw $s3, 12($sp)
    lw $s4, 8($sp)
    lw $s5, 4($sp)
    lw $s6, 0($sp)
    addi $sp, $sp, 32
    jr $ra

# ============================================================================
# MÓDULO: Exibição Visual da Força
# ============================================================================

display_strength:
    # Entrada: $a0 = pontuação de força (0-100)
    # Saída: Exibe mensagem de força na tela
    
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)
    
    move $s0, $a0  # Salvar pontuação
    
    # Determinar força baseada na pontuação
    # 0-20: MUITO FRACA
    # 21-40: FRACA
    # 41-60: MÉDIA
    # 61-80: FORTE
    # 81-100: MUITO FORTE
    
    li $t0, 20
    ble $s0, $t0, very_weak
    
    li $t0, 40
    ble $s0, $t0, weak
    
    li $t0, 60
    ble $s0, $t0, medium
    
    li $t0, 80
    ble $s0, $t0, strong
    
    j very_strong
    
very_weak:
    li $v0, 4
    la $a0, msg_very_weak
    syscall
    j display_done
    
weak:
    li $v0, 4
    la $a0, msg_weak
    syscall
    j display_done
    
medium:
    li $v0, 4
    la $a0, msg_medium
    syscall
    j display_done
    
strong:
    li $v0, 4
    la $a0, msg_strong
    syscall
    j display_done
    
very_strong:
    li $v0, 4
    la $a0, msg_very_strong
    syscall
    
display_done:
    lw $ra, 4($sp)
    lw $s0, 0($sp)
    addi $sp, $sp, 8
    jr $ra


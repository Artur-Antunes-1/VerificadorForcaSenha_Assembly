# Programa Principal - Verificador de Força de Senha
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
.globl main, calculate_strength, display_strength

main:
    # Salvar registradores na pilha
    addi $sp, $sp, -36
    sw $ra, 28($sp)
    sw $s0, 24($sp)
    sw $s1, 20($sp)
    sw $s2, 16($sp)
    sw $s3, 12($sp)
    sw $s4, 8($sp)
    sw $s5, 4($sp)
    sw $s6, 0($sp)
    
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
    lw $ra, 28($sp)
    lw $s0, 24($sp)
    lw $s1, 20($sp)
    lw $s2, 16($sp)
    lw $s3, 12($sp)
    lw $s4, 8($sp)
    lw $s5, 4($sp)
    lw $s6, 0($sp)
    addi $sp, $sp, 36
    
    # Encerrar programa
    li $v0, 10
    syscall

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
    addi $v0, $v0, 1
    addi $t0, $t0, 1
    j strlen_loop
strlen_done:
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
    beq $s3, 1, length_8_plus
    li $t0, 6
    bge $s4, $t0, length_6_7
    li $t0, 4
    bge $s4, $t0, length_4_5
    j length_done
length_8_plus:
    addi $s6, $s6, 30
    j length_done
length_6_7:
    addi $s6, $s6, 15
    j length_done
length_4_5:
    addi $s6, $s6, 5
length_done:
    
    # 2. Maiúscula (peso: 15 pontos)
    beq $s0, $zero, uppercase_done
    addi $s6, $s6, 15
uppercase_done:
    
    # 3. Minúscula (peso: 15 pontos)
    beq $s1, $zero, lowercase_done
    addi $s6, $s6, 15
lowercase_done:
    
    # 4. Caractere Especial (peso: 20 pontos)
    beq $s2, $zero, special_done
    addi $s6, $s6, 20
special_done:
    
    # 5. Repetição (peso: 20 pontos)
    beq $s5, $zero, repetition_done
    addi $s6, $s6, 20
repetition_done:
    
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


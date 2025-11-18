# Módulo: Exibição Visual da Força da Senha
# Descrição: Exibe uma representação visual da força da senha baseada nos critérios atendidos

.data
    msg_very_weak:  .asciiz "\nFORÇA: MUITO FRACA [█░░░░░░░░] 0-20%\n"
    msg_weak:       .asciiz "\nFORÇA: FRACA [██░░░░░░░] 21-40%\n"
    msg_medium:     .asciiz "\nFORÇA: MÉDIA [████░░░░░] 41-60%\n"
    msg_strong:     .asciiz "\nFORÇA: FORTE [██████░░░] 61-80%\n"
    msg_very_strong:.asciiz "\nFORÇA: MUITO FORTE [█████████░] 81-100%\n"

.text
.globl display_strength

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


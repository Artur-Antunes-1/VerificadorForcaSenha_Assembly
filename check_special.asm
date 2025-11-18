# Módulo: Verificação de Caracteres Especiais
# Descrição: Verifica se a senha contém pelo menos um caractere especial

.text
.globl check_special

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


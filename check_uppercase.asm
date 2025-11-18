# Módulo: Verificação de Caracteres Maiúsculos
# Descrição: Verifica se a senha contém pelo menos um caractere maiúsculo (A-Z)

.text
.globl check_uppercase

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


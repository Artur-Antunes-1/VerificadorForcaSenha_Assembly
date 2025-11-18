# Módulo: Verificação de Caracteres Minúsculos
# Descrição: Verifica se a senha contém pelo menos um caractere minúsculo (a-z)

.text
.globl check_lowercase

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


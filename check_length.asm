# Módulo: Verificação de Comprimento
# Descrição: Verifica se a senha tem pelo menos 8 caracteres

.text
.globl check_length

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


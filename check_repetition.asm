# Módulo: Verificação de Repetição de Caracteres
# Descrição: Verifica se nenhum caractere se repete mais de duas vezes

.text
.globl check_repetition

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
    jal strlen
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

# Sub-rotina auxiliar para calcular comprimento (reutilizada)
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


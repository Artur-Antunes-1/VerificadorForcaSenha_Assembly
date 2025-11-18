# Módulo: Utilitários
# Descrição: Funções auxiliares reutilizáveis

.text
.globl strlen, remove_newline

# Sub-rotina para calcular comprimento da string
# Entrada: $a0 = endereço da string
# Saída: $v0 = comprimento da string
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

# Sub-rotina para remover newline do final da string
# Entrada: $a0 = endereço da string
# Saída: String modificada (sem newline no final)
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


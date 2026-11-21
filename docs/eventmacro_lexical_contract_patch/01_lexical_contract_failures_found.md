# 01 Lexical Contract Failures Found

## Falhas encontradas na curadoria anterior
- Uso implícito de `parser_mode` como se fechasse separador/aridade/forma para geração.
- Conditions com parser composto tratadas como geráveis sem contrato lexical completo.
- Falta de campos explícitos de separadores aceitos/proibidos por condition.
- Falta de accepted/rejected forms em nível lexical para reduzir ambiguidade de vírgula vs espaço.

## Impacto operacional
- Risco de gerar sintaxe com separador incorreto.
- Risco de assumir forma composta não comprovada.
- Risco de macro pronta com contrato apenas parcial.

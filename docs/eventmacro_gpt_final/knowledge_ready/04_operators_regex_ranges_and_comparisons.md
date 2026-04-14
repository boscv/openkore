# 04 Operators, Regex, Ranges and Comparisons

## Objetivo
Resumo operacional dos operadores e formatos de comparação usados em conditions do `eventMacro`.

## Comparações numéricas
- Operadores suportados em parsers numéricos: `>`, `<`, `>=`, `<=`, `==`, `!=`. **PROVADO**.
- Formato base: `<condição> <op> <valor>`. **PROVADO**.
- Em condições compostas, comparação numérica pode coexistir com parte regex/evento conforme o módulo de condição. **PROVADO**.

## Regex
- Literais regex com delimitadores `/.../` são suportados por várias condições (`RegexCheck` e variações por parser). **PROVADO**.
- Case-sensitivity e grupos dependem do regex Perl padrão no ponto de uso. **INFERIDO**.
- Não assumir suporte universal a flags customizadas em todas as conditions; validar no módulo da condition. **PROVADO** (princípio de segurança da curadoria).

## Ranges/listas
- Há condições com parser de lista CSV (`csv_list`) para argumentos múltiplos. **PROVADO**.
- Há condições com parser composto (`composite_regex_numeric`) que aceitam combinação de componentes regex + numérico no mesmo statement. **PROVADO**.

## Operadores lógicos e fluxo
- O gating de automacro usa semântica AND entre parâmetros/conditions necessárias para disparo da `call`. **PROVADO**.
- Estruturas de fluxo de macro (`if/elsif/else`, `while`, `switch/case/else`) são do runtime de macro, não operadores de condition em si. **PROVADO**.

## Restrições para evitar alucinação
- Não generalizar sintaxe entre plugins (`macro` antigo vs `eventMacro`). **PROVADO**.
- Não inventar operadores não documentados na condition específica. **PROVADO**.
- Em caso de dúvida de parser por condition, classificar como **NÃO COMPROVADO** até confirmar no módulo fonte.

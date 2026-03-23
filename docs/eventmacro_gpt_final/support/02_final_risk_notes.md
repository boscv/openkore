# 02 Final Risk Notes

## Riscos remanescentes
1. Algumas interpretações de regex/flags dependem do contexto de execução Perl e do módulo de condition.
2. Generalizações entre conditions continuam sendo risco de alucinação se o GPT ignorar o catálogo.
3. Documentação histórica externa ao repositório pode divergir do comportamento atual do código.

## Mitigações incorporadas
- Classificação explícita PROVADO/INFERIDO/NÃO COMPROVADO no conteúdo técnico.
- Instruções finais do GPT com política de incerteza e anti-invenção.
- Catálogo JSON mantido para consulta estruturada.
- Catálogo de negativos e inválidos mantido para reduzir falsos positivos em revisão.

## Avaliação
- Risco residual: **moderado-baixo**, condicionado ao GPT respeitar o manifesto e as instruções finais.


## Mitigações adicionais implementadas
- Gate automatizado `validate_final_package.py` para bloquear upload com `knowledge_ready > 20`, ausência de arquivos núcleo, divergência de contagem no manifesto ou JSON inválido.
- Manifesto final mantém núcleo mínimo e opcionais para evitar remoções perigosas durante compressão.
- Política de revisão exige marcar incerteza como **INFERIDO**/**NÃO COMPROVADO** quando faltar evidência.

## Procedimento recomendado antes de upload
1. Rodar `python3 docs/eventmacro_gpt_final/support/validate_final_package.py`.
2. Confirmar leitura de `16_gpt_system_instructions_final.md` como instrução principal do GPT.
3. Validar que o pacote enviado contém exatamente os arquivos listados no manifesto.

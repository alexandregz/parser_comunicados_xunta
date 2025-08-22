# Parseador comunicados Xunta lumes

Parsea os comunicados da Xunta en relación á vaga de lumes de 2025, ante o oscurantismo do goberno e a discrepancia dos datos da Xunta cos do EFFIS (Sistema Europeo de Información sobre Incendios Forestais), devolvendo o total de hectáreas queimado por lume.

## Uso

Dous métodos de uso


### Uso individual

```bash
$  Uso: perl parsear_lumes_comunicados.pl URL
```

Crea ficheiro .csv:
```
lume1,concello,estado_lume1,hectareas_lume1
lume2,concello,estado_lume2,hectareas_lume2
lume_n,concello,estado_lume_n,hectareas_lume_n
```


### Uso multiple

```bash
$ Uso: perl parsear_lumes_comunicados_dias.pl ficheiro_urls [conservar_lumes=1]
```

Crea ficheiro .csv:
```
lume,concello,estado,dd1/mm/yyyy,dd2/mm/yyyy,dd_n/mm/yyyy
lume1,concello,estado,hectareas_dia1,hectareas_dia2,hectareas_dia_n
lume2,concello,estado,hectareas_dia1,hectareas_dia2,hectareas_dia_n
lume_n,concello,estado,hectareas_dia1,hectareas_dia2,hectareas_dia_n
```

Con `conservar_lumes=1` mantén o último resultado aínda que o lume sexa declarado como `Estabilizado, Extinguido ou Controlado`. Dá unha idea xeral do global do verán.


### ToDo

Parsear directamente as novas en lugar de ter que revisalas e anotalas en ficheiro para `parsear_lumes_comunicados_dias.pl`
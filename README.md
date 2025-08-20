# Parseador comunicados Xunta lumes

Parsea os comunicados da Xunta en relación á vaga de lumes de 2025, ante o oscurantismo do goberno e a discrepancia dos datos da Xunta cos do EFFIS (Sistema Europeo de Información sobre Incendios Forestais), devolvendo o total de hectáreas queimado por lume.

## Uso

Dous métodos de uso


### Uso individual

```bash
$  Uso: perl $0 URL
```

Crea ficheiro .csv:
```
lume1,concello,estado_lume1,hectareas_lume1
lume2,concello,estado_lume2,hectareas_lume2
lume_n,concello,estado_lume_n,hectareas_lume_n
```


###### ToDo

Crea ficheiro .csv:
```
lume1,concello,hectareas_dia1,hectareas_dia2,hectareas_dia_n
lume2,concello,hectareas_dia1,hectareas_dia2,hectareas_dia_n
lumen,concello,hectareas_dia1,hectareas_dia2,hectareas_dia_n
```


### Uso multiple

```bash
$ Uso: perl $0 ficheiro_urls desglose=true
```

Crea múltiples ficheiros .csv, un por lume
```
lume,concello,dia1,hectareas_dia1,estado_dia1
lume,concello,dia1,hectareas_dia2,estado_dia2
lume,concello,dia1,hectareas_dia_n,estado_dia_n
```
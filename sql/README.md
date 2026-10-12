# Scripts SQL - Backup de la base de datos

Estos scripts son el **respaldo completo** de la base de datos de Supabase.

## Orden de ejecución

Si necesitas recrear la base de datos desde cero:

```
1. 01-tablas.sql      → Tipos ENUM, tablas, índices, llaves foráneas
2. 02-funciones.sql   → Funciones (validar_carnet, calcular_tabla, etc)
3. 03-triggers.sql    → Triggers automáticos
4. 04-vistas.sql      → Vistas de consulta
5. 05-rls.sql         → Row Level Security y políticas
6. 06-seed.sql        → Datos iniciales (reglas, multas, etapas)
```

## Cómo ejecutar

1. Abrir el SQL Editor de Supabase
2. Pegar el contenido de cada archivo en orden
3. Ejecutar con "Run" (o Ctrl+Enter)

## Contenido

| Archivo | Qué contiene |
|---|---|
| `01-tablas.sql` | 23 tablas + tipos ENUM + índices |
| `02-funciones.sql` | 12 funciones PL/pgSQL |
| `03-triggers.sql` | 6 triggers de automatización |
| `04-vistas.sql` | 6 vistas de consulta |
| `05-rls.sql` | Políticas RLS por rol |
| `06-seed.sql` | Reglas, multas, etapas iniciales |

## Última actualización

Octubre 2026
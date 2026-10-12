# Base de datos

## Ubicación

- **Proveedor:** Supabase
- **Proyecto:** App-liga-Izurieta
- **Región:** São Paulo (SA-EAST-1)
- **URL:** https://gylnajxmlalnyueanhll.supabase.co
- **Dashboard:** https://supabase.com/dashboard/project/gylnajxmlalnyueanhll

## Estructura

### Tablas (23)

1. `usuarios` - Admin, secretaria, delegados, árbitros, capitanes
2. `equipos` - Clubes por disciplina y categoría
3. `jugadores` - Datos de los jugadores
4. `jugador_equipo` - Inscripciones (N:M)
5. `etapas` - Etapas del campeonato
6. `configuracion_multas` - Montos configurables
7. `reglas_disciplina` - Reglas por disciplina/categoría
8. `sanciones_jugador` - Tarjetas y suspensiones
9. `sanciones_equipo` - Sanciones al club
10. `amarillas_acumuladas` - Contador de amarillas
11. `deudas_equipo` - Inscripción, mensualidad
12. `deudas_jugador` - Multas individuales
13. `fechas` - Jornadas
14. `partidos` - Partidos por fecha
15. `goles` - Goles por partido
16. `arbitros` - Árbitros externos
17. `actas` - Actas de cada partido
18. `firmas_acta` - Firmas digitales
19. `carnets` - Auditoría de validaciones
20. `pagos_carnet` - Pagos del carnet digital
21. `pases_jugador` - Pases entre clubes
22. `periodos_inscripcion` - Períodos de inscripción
23. `historial_clubes_jugador` - Historial deportivo

### Funciones (12)

- `validar_carnet()` - Valida si un jugador está habilitado
- `calcular_tabla_posiciones()` - Calcula posiciones
- `calcular_tabla_goleadores()` - Ranking de goleadores
- `calcular_tabla_sancionados()` - Sancionados activos
- `registrar_pago_carnet()` - Registra pago
- `es_admin_o_secretaria()` - Helper de RLS
- `obtener_rol_usuario()` - Helper de RLS
- `periodo_inscripcion_activo()` - Helper
- `actualizar_sanciones_por_partido()` - Trigger function
- `generar_deuda_por_sancion()` - Trigger function
- `manejar_amarillas()` - Trigger function
- `verificar_cierre_acta()` - Trigger function
- `calcular_es_menor()` - Trigger function
- `generar_codigo_interno()` - Trigger function

### Triggers (6)

- `trg_actualizar_sanciones` - Incrementa fechas cumplidas
- `trg_generar_deuda_por_sancion` - Crea deuda automática
- `trg_manejar_amarillas` - Acumulación de amarillas
- `trg_verificar_cierre_acta` - Cierra acta al firmar
- `trg_calcular_es_menor` - Marca menores
- `trg_generar_codigo_interno` - Genera JUG-XXXXX

### Vistas (6)

- `vista_tabla_posiciones`
- `vista_goleadores`
- `vista_sancionados`
- `vista_carnet_jugador`
- `vista_deudas_pendientes`
- `vista_fair_play`

## Tipos ENUM

- **rol_usuario:** admin, secretaria, vocal, arbitro, delegado, jugador
- **disciplina:** futsala, futbol, ecuavoly
- **categoria:** hombres, mujeres, sub12, master40
- **tipo_sancion:** amarilla, roja, doble_amarilla, suspension_admin
- **tipo_sancion_equipo:** economica, deportiva, administrativa
- **tipo_gol:** normal, penal, autogol
- **estado_acta:** abierta, firmando, cerrada
- **tipo_firmante:** arbitro, vocal, capitan_local, capitan_visitante

## Seguridad

- **Row Level Security (RLS)** habilitado en todas las tablas
- **Políticas por rol** (admin, secretaria, delegado, vocal, árbitro, capitán)
- **Cumplimiento LOPDP** (consentimiento, tutores para menores)

## Roles del sistema

| Rol | Descripción | Módulos |
|---|---|---|
| `admin` | Control total | Todos |
| `secretaria` | Administración | Jugadores, Equipos, Pagos, Calendario, Sanciones, Actas, Reportes |
| `delegado` | Presidente de club | Mis Jugadores, Mi Club, Mis Pases, Mi Nómina |
| `capitan` | Capitán del equipo | Cerrar Acta |
| `vocal` | Vocal semanal | Planilla, Partido en Curso, Validar Carnets, Novedades |
| `arbitro` | Árbitro externo | Partido en Curso, Tarjetas, Goles, Novedades |

## Categorías

- hombres
- mujeres
- sub12
- master40 (solo hombres, desde 37 años)

## Disciplinas

- futbol
- futsala
- ecuavoly

## Reglas de negocio

### Validación del carnet

Un jugador está **BLOQUEADO** si tiene al menos uno de:

1. Carnet digital no pagado del año actual
2. No firmó consentimiento LOPDP
3. No tiene foto actualizada
4. No cumple edad reglamentaria
5. Pase deportivo no aprobado
6. Sanción activa pendiente
7. Deuda pendiente del jugador
8. Deuda pendiente del equipo

### Tarjetas

- **Amarilla:** acumula, multa $1
- **4 amarillas:** 1 fecha suspensión + multa $1 + reinicio contador
- **Doble amarilla:** 1 fecha suspensión + multa $2 + resta 2 amarillas
- **Roja directa:** 2 fechas suspensión + multa $2
- **Fin de etapa:** se borran todas las amarillas

### Carnet digital

- **Costo:** $1 por jugador
- **Periodicidad:** anual
- **Obligatorio:** todos los jugadores

## Cómo recrear la BD desde cero

1. Crear proyecto nuevo en Supabase (región São Paulo)
2. Ejecutar en el SQL Editor en este orden:
   - `sql/01-tablas.sql`
   - `sql/02-funciones.sql`
   - `sql/03-triggers.sql`
   - `sql/04-vistas.sql`
   - `sql/05-rls.sql`
   - `sql/06-seed.sql`
3. Configurar las credenciales en los archivos `.env.local` de los proyectos

## Fechas de las temporadas 2026-2027

- **Futsala:** 20 de noviembre 2026 - junio 2027
- **Fútbol Senior:** enero 2027 - agosto 2027
-- ============================================================
-- SCRIPT 04: VISTAS
-- Liga Deportiva Barrial José Ignacio Izurieta
-- ============================================================
-- Las vistas son consultas pre-armadas que simplifican
-- el acceso a datos complejos desde la app.
-- ============================================================

-- ============================================================
-- VISTA 1: vista_tabla_posiciones
-- Tabla de posiciones por disciplina y categoría
-- ============================================================
CREATE OR REPLACE VIEW vista_tabla_posiciones AS
SELECT 
  e.disciplina,
  e.categoria,
  tp.equipo_id,
  tp.equipo,
  tp.pj,
  tp.pg,
  tp.pe,
  tp.pp,
  tp.gf,
  tp.gc,
  tp.dg,
  tp.pts,
  tp.amarillas,
  tp.rojas,
  tp.fair_play
FROM equipos e
CROSS JOIN LATERAL calcular_tabla_posiciones(e.disciplina, e.categoria) tp(
  equipo_id, equipo, pj, pg, pe, pp, gf, gc, dg, pts, 
  amarillas, rojas, fair_play
)
WHERE e.id = tp.equipo_id
GROUP BY 
  e.disciplina, e.categoria, tp.equipo_id, tp.equipo, 
  tp.pj, tp.pg, tp.pe, tp.pp, tp.gf, tp.gc, tp.dg, 
  tp.pts, tp.amarillas, tp.rojas, tp.fair_play;

-- ============================================================
-- VISTA 2: vista_goleadores
-- Ranking de goleadores por disciplina y categoría
-- ============================================================
CREATE OR REPLACE VIEW vista_goleadores AS
SELECT 
  e.disciplina,
  e.categoria,
  g.id_jugador,
  g.jugador,
  g.equipo,
  g.goles
FROM equipos e
CROSS JOIN LATERAL calcular_tabla_goleadores(e.disciplina, e.categoria) g(
  id_jugador, jugador, equipo, goles
)
WHERE EXISTS (
  SELECT 1
  FROM jugador_equipo je
  WHERE je.jugador_id = g.id_jugador 
    AND je.equipo_id = e.id
)
GROUP BY 
  e.disciplina, e.categoria, g.id_jugador, g.jugador, g.equipo, g.goles;

-- ============================================================
-- VISTA 3: vista_sancionados
-- Jugadores con sanciones activas
-- ============================================================
CREATE OR REPLACE VIEW vista_sancionados AS
SELECT 
  e.disciplina,
  e.categoria,
  s.jugador_id,
  s.jugador,
  s.equipo,
  s.tipo,
  s.motivo,
  s.fechas_sancion,
  s.fechas_cumplidas,
  s.fecha_inicio
FROM equipos e
CROSS JOIN LATERAL calcular_tabla_sancionados(e.disciplina, e.categoria) s(
  jugador_id, jugador, equipo, tipo, motivo, 
  fechas_sancion, fechas_cumplidas, fecha_inicio
)
WHERE EXISTS (
  SELECT 1
  FROM jugador_equipo je
  WHERE je.jugador_id = s.jugador_id 
    AND je.equipo_id = e.id
)
GROUP BY 
  e.disciplina, e.categoria, s.jugador_id, s.jugador, s.equipo, 
  s.tipo, s.motivo, s.fechas_sancion, s.fechas_cumplidas, s.fecha_inicio;

-- ============================================================
-- VISTA 4: vista_carnet_jugador
-- Datos completos del carnet de un jugador (con estado)
-- ============================================================
CREATE OR REPLACE VIEW vista_carnet_jugador AS
SELECT 
  j.id AS jugador_id,
  j.codigo_interno,
  j.nombres,
  j.apellidos,
  j.cedula,
  j.fecha_nacimiento,
  j.foto_url,
  j.token_carnet,
  j.es_menor,
  je.dorsal,
  je.posicion,
  e.id AS equipo_id,
  e.nombre AS equipo,
  e.disciplina,
  e.categoria,
  e.escudo_url,
  vc.estado AS estado_carnet,
  vc.motivos AS motivos_bloqueo
FROM jugadores j
JOIN jugador_equipo je ON je.jugador_id = j.id AND je.activo = TRUE
JOIN equipos e ON e.id = je.equipo_id AND e.activo = TRUE
CROSS JOIN LATERAL validar_carnet(j.id, e.id) vc(estado, motivos)
WHERE j.activo = TRUE;

-- ============================================================
-- VISTA 5: vista_deudas_pendientes
-- Deudas pendientes de equipos y jugadores
-- ============================================================
CREATE OR REPLACE VIEW vista_deudas_pendientes AS

-- Deudas de equipos
SELECT 
  'equipo'::TEXT AS tipo,
  e.id AS entidad_id,
  e.nombre AS entidad,
  e.disciplina,
  e.categoria,
  de.concepto,
  de.monto,
  de.monto_pagado,
  (de.monto - de.monto_pagado) AS saldo,
  de.fecha_vencimiento
FROM deudas_equipo de
JOIN equipos e ON e.id = de.equipo_id
WHERE de.monto_pagado < de.monto

UNION ALL

-- Deudas de jugadores
SELECT 
  'jugador'::TEXT AS tipo,
  j.id AS entidad_id,
  (j.apellidos || ' ' || j.nombres) AS entidad,
  e.disciplina,
  e.categoria,
  dj.concepto,
  dj.monto,
  dj.monto_pagado,
  (dj.monto - dj.monto_pagado) AS saldo,
  dj.fecha_vencimiento
FROM deudas_jugador dj
JOIN jugadores j ON j.id = dj.jugador_id
JOIN equipos e ON e.id = dj.equipo_id
WHERE dj.monto_pagado < dj.monto;

-- ============================================================
-- VISTA 6: vista_fair_play
-- Puntos de fair play por equipo (amarillas × 1 + rojas × 5)
-- ============================================================
CREATE OR REPLACE VIEW vista_fair_play AS
SELECT 
  e.disciplina,
  e.categoria,
  e.id AS equipo_id,
  e.nombre AS equipo,
  COUNT(CASE WHEN s.tipo = 'amarilla' THEN 1 END) AS amarillas,
  COUNT(CASE WHEN s.tipo IN ('roja', 'doble_amarilla') THEN 1 END) AS rojas,
  (
    COUNT(CASE WHEN s.tipo = 'amarilla' THEN 1 END) * 1 +
    COUNT(CASE WHEN s.tipo IN ('roja', 'doble_amarilla') THEN 1 END) * 5
  ) AS puntos_fair_play
FROM equipos e
LEFT JOIN sanciones_jugador s ON s.equipo_id = e.id
WHERE e.activo = TRUE
GROUP BY e.disciplina, e.categoria, e.id, e.nombre
ORDER BY puntos_fair_play ASC;

-- ============================================================
-- VERIFICAR QUE SE CREARON
-- ============================================================
SELECT 
  table_name AS vista
FROM information_schema.views
WHERE table_schema = 'public'
  AND table_name LIKE 'vista_%'
ORDER BY table_name;

-- ============================================================
-- FIN DEL SCRIPT 04
-- ============================================================
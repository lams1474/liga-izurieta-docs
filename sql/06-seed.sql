-- ============================================================
-- SCRIPT 06: DATOS INICIALES (SEED)
-- Liga Deportiva Barrial José Ignacio Izurieta
-- ============================================================
-- Carga los datos básicos para que el sistema arranque:
--   - Reglas por disciplina y categoría
--   - Configuración de multas
--   - Etapas iniciales
-- ============================================================

-- ============================================================
-- REGLAS POR DISCIPLINA Y CATEGORÍA
-- ============================================================
INSERT INTO reglas_disciplina (
  disciplina, categoria, min_jugadores, max_acta, 
  sustituciones, juvenil_obligatorio, 
  puntos_victoria, puntos_empate, puntos_derrota
) VALUES
  -- FÚTBOL
  ('futbol', 'hombres', 7, 19, 8, TRUE,  3, 1, 0),
  ('futbol', 'mujeres', 7, 19, 8, FALSE, 3, 1, 0),
  ('futbol', 'sub12',   7, 19, 8, FALSE, 3, 1, 0),
  ('futbol', 'master40',7, 19, 8, FALSE, 3, 1, 0),
  -- FUTSALA
  ('futsala', 'hombres', 4, 12, NULL, FALSE, 3, 1, 0),
  ('futsala', 'mujeres', 4, 12, NULL, FALSE, 3, 1, 0),
  ('futsala', 'sub12',   4, 12, NULL, FALSE, 3, 1, 0),
  ('futsala', 'master40',4, 12, NULL, FALSE, 3, 1, 0),
  -- ECUAVOLY
  ('ecuavoly', 'hombres', 3, 7, 4, FALSE, 3, 1, 0),
  ('ecuavoly', 'mujeres', 3, 7, 4, FALSE, 3, 1, 0),
  ('ecuavoly', 'sub12',   3, 7, 4, FALSE, 3, 1, 0),
  ('ecuavoly', 'master40',3, 7, 4, FALSE, 3, 1, 0);

-- ============================================================
-- CONFIGURACIÓN DE MULTAS POR DEFECTO
-- ============================================================
INSERT INTO configuracion_multas (
  disciplina, tipo_sancion, monto, fechas_sancion
) VALUES
  -- Globales (aplican a todas las disciplinas)
  (NULL, 'amarilla',        1.00, 0),
  (NULL, 'roja',            2.00, 2),
  (NULL, 'doble_amarilla',  2.00, 1),
  (NULL, 'suspension_admin', 0.00, 1);

-- ============================================================
-- ETAPAS INICIALES 2026-2027
-- ============================================================
INSERT INTO etapas (nombre, disciplina, categoria, fecha_inicio, activa) VALUES
  -- FÚTBOL
  ('Primera Etapa 2026', 'futbol',   'hombres',  '2026-01-01', TRUE),
  ('Primera Etapa 2026', 'futbol',   'mujeres',  '2026-01-01', TRUE),
  ('Primera Etapa 2026', 'futbol',   'sub12',    '2026-01-01', TRUE),
  ('Primera Etapa 2026', 'futbol',   'master40', '2026-01-01', TRUE),
  -- FUTSALA
  ('Primera Etapa 2026', 'futsala',  'hombres',  '2026-01-01', TRUE),
  ('Primera Etapa 2026', 'futsala',  'mujeres',  '2026-01-01', TRUE),
  ('Primera Etapa 2026', 'futsala',  'sub12',    '2026-01-01', TRUE),
  ('Primera Etapa 2026', 'futsala',  'master40', '2026-01-01', TRUE),
  -- ECUAVOLY
  ('Primera Etapa 2026', 'ecuavoly', 'hombres',  '2026-01-01', TRUE),
  ('Primera Etapa 2026', 'ecuavoly', 'mujeres',  '2026-01-01', TRUE),
  ('Primera Etapa 2026', 'ecuavoly', 'sub12',    '2026-01-01', TRUE),
  ('Primera Etapa 2026', 'ecuavoly', 'master40', '2026-01-01', TRUE);

-- ============================================================
-- VERIFICAR DATOS CARGADOS
-- ============================================================
SELECT 
  'Reglas de disciplina' AS concepto,
  COUNT(*)::TEXT AS total
FROM reglas_disciplina

UNION ALL

SELECT 
  'Configuración de multas',
  COUNT(*)::TEXT
FROM configuracion_multas

UNION ALL

SELECT 
  'Etapas',
  COUNT(*)::TEXT
FROM etapas;

-- ============================================================
-- NOTA IMPORTANTE
-- ============================================================
-- Los siguientes datos NO se cargan con este script porque
-- dependen de la liga específica y se cargan manualmente:
--
--   - Usuarios (admin, secretaria, delegados, árbitros)
--   - Equipos (12 clubes de la liga)
--   - Jugadores (se importan desde Excel)
--   - Árbitros (los 10 de la asociación)
-- ============================================================

-- ============================================================
-- FIN DEL SCRIPT 06
-- ============================================================
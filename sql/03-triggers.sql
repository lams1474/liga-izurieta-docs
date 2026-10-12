-- ============================================================
-- SCRIPT 03: TRIGGERS
-- Liga Deportiva Barrial José Ignacio Izurieta
-- ============================================================
-- Los triggers se activan automáticamente ante eventos
-- (INSERT, UPDATE, DELETE) en las tablas.
-- ============================================================

-- ============================================================
-- TRIGGER 1: trg_calcular_es_menor
-- Marca automáticamente si un jugador es menor de edad
-- Se ejecuta ANTES de INSERT o UPDATE en jugadores
-- ============================================================
DROP TRIGGER IF EXISTS trg_calcular_es_menor ON jugadores;
CREATE TRIGGER trg_calcular_es_menor
  BEFORE INSERT OR UPDATE ON jugadores
  FOR EACH ROW
  EXECUTE FUNCTION calcular_es_menor();

-- ============================================================
-- TRIGGER 2: trg_generar_codigo_interno
-- Genera el código JUG-XXXXX automáticamente
-- Se ejecuta ANTES de INSERT en jugadores
-- ============================================================
DROP TRIGGER IF EXISTS trg_generar_codigo_interno ON jugadores;
CREATE TRIGGER trg_generar_codigo_interno
  BEFORE INSERT ON jugadores
  FOR EACH ROW
  EXECUTE FUNCTION generar_codigo_interno();

-- ============================================================
-- TRIGGER 3: trg_generar_deuda_por_sancion
-- Crea una deuda automática cuando se registra una roja
-- o doble amarilla
-- Se ejecuta DESPUÉS de INSERT en sanciones_jugador
-- ============================================================
DROP TRIGGER IF EXISTS trg_generar_deuda_por_sancion ON sanciones_jugador;
CREATE TRIGGER trg_generar_deuda_por_sancion
  AFTER INSERT ON sanciones_jugador
  FOR EACH ROW
  WHEN (NEW.tipo IN ('roja', 'doble_amarilla'))
  EXECUTE FUNCTION generar_deuda_por_sancion();

-- ============================================================
-- TRIGGER 4: trg_manejar_amarillas
-- Maneja la acumulación de amarillas (4 = 1 fecha sanción)
-- y la resta de 2 al registrar doble amarilla
-- Se ejecuta DESPUÉS de INSERT en sanciones_jugador
-- ============================================================
DROP TRIGGER IF EXISTS trg_manejar_amarillas ON sanciones_jugador;
CREATE TRIGGER trg_manejar_amarillas
  AFTER INSERT ON sanciones_jugador
  FOR EACH ROW
  WHEN (NEW.tipo IN ('amarilla', 'doble_amarilla'))
  EXECUTE FUNCTION manejar_amarillas();

-- ============================================================
-- TRIGGER 5: trg_actualizar_sanciones
-- Incrementa las fechas cumplidas de las sanciones activas
-- cuando se marca un partido como jugado
-- Se ejecuta DESPUÉS de UPDATE en partidos
-- ============================================================
DROP TRIGGER IF EXISTS trg_actualizar_sanciones ON partidos;
CREATE TRIGGER trg_actualizar_sanciones
  AFTER UPDATE ON partidos
  FOR EACH ROW
  EXECUTE FUNCTION actualizar_sanciones_por_partido();

-- ============================================================
-- TRIGGER 6: trg_verificar_cierre_acta
-- Cierra el acta automáticamente cuando firman
-- árbitro y vocal
-- Se ejecuta DESPUÉS de INSERT en firmas_acta
-- ============================================================
DROP TRIGGER IF EXISTS trg_verificar_cierre_acta ON firmas_acta;
CREATE TRIGGER trg_verificar_cierre_acta
  AFTER INSERT ON firmas_acta
  FOR EACH ROW
  EXECUTE FUNCTION verificar_cierre_acta();

-- ============================================================
-- VERIFICAR QUE SE CREARON
-- ============================================================
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_timing
FROM information_schema.triggers
WHERE trigger_schema = 'public'
  AND trigger_name LIKE 'trg_%'
ORDER BY trigger_name;

-- ============================================================
-- FIN DEL SCRIPT 03
-- ============================================================
-- ============================================================
-- SCRIPT 05: ROW LEVEL SECURITY (RLS) Y POLÍTICAS
-- Liga Deportiva Barrial José Ignacio Izurieta
-- ============================================================
-- RLS controla qué filas puede ver/modificar cada usuario
-- según su rol (admin, secretaria, delegado, vocal, etc.)
-- ============================================================

-- ============================================================
-- HABILITAR RLS EN TODAS LAS TABLAS
-- ============================================================
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE equipos ENABLE ROW LEVEL SECURITY;
ALTER TABLE jugadores ENABLE ROW LEVEL SECURITY;
ALTER TABLE jugador_equipo ENABLE ROW LEVEL SECURITY;
ALTER TABLE etapas ENABLE ROW LEVEL SECURITY;
ALTER TABLE reglas_disciplina ENABLE ROW LEVEL SECURITY;
ALTER TABLE configuracion_multas ENABLE ROW LEVEL SECURITY;
ALTER TABLE arbitros ENABLE ROW LEVEL SECURITY;
ALTER TABLE fechas ENABLE ROW LEVEL SECURITY;
ALTER TABLE partidos ENABLE ROW LEVEL SECURITY;
ALTER TABLE goles ENABLE ROW LEVEL SECURITY;
ALTER TABLE sanciones_jugador ENABLE ROW LEVEL SECURITY;
ALTER TABLE amarillas_acumuladas ENABLE ROW LEVEL SECURITY;
ALTER TABLE sanciones_equipo ENABLE ROW LEVEL SECURITY;
ALTER TABLE deudas_equipo ENABLE ROW LEVEL SECURITY;
ALTER TABLE deudas_jugador ENABLE ROW LEVEL SECURITY;
ALTER TABLE actas ENABLE ROW LEVEL SECURITY;
ALTER TABLE firmas_acta ENABLE ROW LEVEL SECURITY;
ALTER TABLE carnets ENABLE ROW LEVEL SECURITY;
ALTER TABLE pagos_carnet ENABLE ROW LEVEL SECURITY;
ALTER TABLE pases_jugador ENABLE ROW LEVEL SECURITY;
ALTER TABLE periodos_inscripcion ENABLE ROW LEVEL SECURITY;
ALTER TABLE historial_clubes_jugador ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- POLÍTICAS: usuarios
-- ============================================================
DROP POLICY IF EXISTS usuarios_ver_propio ON usuarios;
CREATE POLICY usuarios_ver_propio ON usuarios
  FOR SELECT USING (
    auth.uid() = id OR es_admin_o_secretaria()
  );

DROP POLICY IF EXISTS usuarios_admin_todo ON usuarios;
CREATE POLICY usuarios_admin_todo ON usuarios
  FOR ALL USING (es_admin_o_secretaria());

-- ============================================================
-- POLÍTICAS: equipos
-- ============================================================
DROP POLICY IF EXISTS equipos_lectura_publica ON equipos;
CREATE POLICY equipos_lectura_publica ON equipos
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS equipos_admin_todo ON equipos;
CREATE POLICY equipos_admin_todo ON equipos
  FOR ALL USING (es_admin_o_secretaria());

-- ============================================================
-- POLÍTICAS: jugadores
-- ============================================================
DROP POLICY IF EXISTS jugadores_lectura_publica ON jugadores;
CREATE POLICY jugadores_lectura_publica ON jugadores
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS jugadores_admin_todo ON jugadores;
CREATE POLICY jugadores_admin_todo ON jugadores
  FOR ALL USING (es_admin_o_secretaria());

DROP POLICY IF EXISTS jugadores_editar_propio ON jugadores;
CREATE POLICY jugadores_editar_propio ON jugadores
  FOR UPDATE USING (auth.uid() = id);

-- ============================================================
-- POLÍTICAS: jugador_equipo
-- ============================================================
DROP POLICY IF EXISTS jugador_equipo_lectura ON jugador_equipo;
CREATE POLICY jugador_equipo_lectura ON jugador_equipo
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS jugador_equipo_admin ON jugador_equipo;
CREATE POLICY jugador_equipo_admin ON jugador_equipo
  FOR ALL USING (es_admin_o_secretaria());

-- ============================================================
-- POLÍTICAS: etapas
-- ============================================================
DROP POLICY IF EXISTS etapas_lectura ON etapas;
CREATE POLICY etapas_lectura ON etapas
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS etapas_admin ON etapas;
CREATE POLICY etapas_admin ON etapas
  FOR ALL USING (es_admin_o_secretaria());

-- ============================================================
-- POLÍTICAS: reglas_disciplina
-- ============================================================
DROP POLICY IF EXISTS reglas_lectura ON reglas_disciplina;
CREATE POLICY reglas_lectura ON reglas_disciplina
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS reglas_admin ON reglas_disciplina;
CREATE POLICY reglas_admin ON reglas_disciplina
  FOR ALL USING (es_admin_o_secretaria());

-- ============================================================
-- POLÍTICAS: configuracion_multas
-- ============================================================
DROP POLICY IF EXISTS config_multas_lectura ON configuracion_multas;
CREATE POLICY config_multas_lectura ON configuracion_multas
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS config_multas_admin ON configuracion_multas;
CREATE POLICY config_multas_admin ON configuracion_multas
  FOR ALL USING (es_admin_o_secretaria());

-- ============================================================
-- POLÍTICAS: arbitros
-- ============================================================
DROP POLICY IF EXISTS arbitros_lectura ON arbitros;
CREATE POLICY arbitros_lectura ON arbitros
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS arbitros_admin ON arbitros;
CREATE POLICY arbitros_admin ON arbitros
  FOR ALL USING (es_admin_o_secretaria());

-- ============================================================
-- POLÍTICAS: fechas
-- ============================================================
DROP POLICY IF EXISTS fechas_lectura ON fechas;
CREATE POLICY fechas_lectura ON fechas
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS fechas_admin ON fechas;
CREATE POLICY fechas_admin ON fechas
  FOR ALL USING (es_admin_o_secretaria());

-- ============================================================
-- POLÍTICAS: partidos
-- ============================================================
DROP POLICY IF EXISTS partidos_lectura ON partidos;
CREATE POLICY partidos_lectura ON partidos
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS partidos_admin ON partidos;
CREATE POLICY partidos_admin ON partidos
  FOR ALL USING (es_admin_o_secretaria());

DROP POLICY IF EXISTS partidos_vocal_arbitro ON partidos;
CREATE POLICY partidos_vocal_arbitro ON partidos
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol IN ('vocal', 'arbitro')
    )
  );

-- ============================================================
-- POLÍTICAS: goles
-- ============================================================
DROP POLICY IF EXISTS goles_lectura ON goles;
CREATE POLICY goles_lectura ON goles
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS goles_admin ON goles;
CREATE POLICY goles_admin ON goles
  FOR ALL USING (es_admin_o_secretaria());

DROP POLICY IF EXISTS goles_vocal_arbitro ON goles;
CREATE POLICY goles_vocal_arbitro ON goles
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol IN ('vocal', 'arbitro')
    )
  );

-- ============================================================
-- POLÍTICAS: sanciones_jugador
-- ============================================================
DROP POLICY IF EXISTS sanciones_jugador_lectura ON sanciones_jugador;
CREATE POLICY sanciones_jugador_lectura ON sanciones_jugador
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS sanciones_jugador_admin ON sanciones_jugador;
CREATE POLICY sanciones_jugador_admin ON sanciones_jugador
  FOR ALL USING (es_admin_o_secretaria());

DROP POLICY IF EXISTS sanciones_jugador_vocal_arbitro ON sanciones_jugador;
CREATE POLICY sanciones_jugador_vocal_arbitro ON sanciones_jugador
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol IN ('vocal', 'arbitro')
    )
  );

-- ============================================================
-- POLÍTICAS: amarillas_acumuladas
-- ============================================================
DROP POLICY IF EXISTS amarillas_lectura ON amarillas_acumuladas;
CREATE POLICY amarillas_lectura ON amarillas_acumuladas
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS amarillas_admin ON amarillas_acumuladas;
CREATE POLICY amarillas_admin ON amarillas_acumuladas
  FOR ALL USING (es_admin_o_secretaria());

-- ============================================================
-- POLÍTICAS: sanciones_equipo
-- ============================================================
DROP POLICY IF EXISTS sanciones_equipo_lectura ON sanciones_equipo;
CREATE POLICY sanciones_equipo_lectura ON sanciones_equipo
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS sanciones_equipo_admin ON sanciones_equipo;
CREATE POLICY sanciones_equipo_admin ON sanciones_equipo
  FOR ALL USING (es_admin_o_secretaria());

-- ============================================================
-- POLÍTICAS: deudas_equipo
-- ============================================================
DROP POLICY IF EXISTS deudas_equipo_lectura ON deudas_equipo;
CREATE POLICY deudas_equipo_lectura ON deudas_equipo
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS deudas_equipo_admin ON deudas_equipo;
CREATE POLICY deudas_equipo_admin ON deudas_equipo
  FOR ALL USING (es_admin_o_secretaria());

-- ============================================================
-- POLÍTICAS: deudas_jugador
-- ============================================================
DROP POLICY IF EXISTS deudas_jugador_lectura ON deudas_jugador;
CREATE POLICY deudas_jugador_lectura ON deudas_jugador
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS deudas_jugador_admin ON deudas_jugador;
CREATE POLICY deudas_jugador_admin ON deudas_jugador
  FOR ALL USING (es_admin_o_secretaria());

-- ============================================================
-- POLÍTICAS: actas
-- ============================================================
DROP POLICY IF EXISTS actas_lectura ON actas;
CREATE POLICY actas_lectura ON actas
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS actas_admin ON actas;
CREATE POLICY actas_admin ON actas
  FOR ALL USING (es_admin_o_secretaria());

DROP POLICY IF EXISTS actas_vocal_arbitro ON actas;
CREATE POLICY actas_vocal_arbitro ON actas
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol IN ('vocal', 'arbitro')
    )
  );

-- ============================================================
-- POLÍTICAS: firmas_acta
-- ============================================================
DROP POLICY IF EXISTS firmas_lectura ON firmas_acta;
CREATE POLICY firmas_lectura ON firmas_acta
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS firmas_insert ON firmas_acta;
CREATE POLICY firmas_insert ON firmas_acta
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol IN ('vocal', 'arbitro', 'admin', 'secretaria', 'capitan')
    )
  );

-- ============================================================
-- POLÍTICAS: carnets
-- ============================================================
DROP POLICY IF EXISTS carnets_lectura ON carnets;
CREATE POLICY carnets_lectura ON carnets
  FOR SELECT USING (es_admin_o_secretaria());

DROP POLICY IF EXISTS carnets_insert ON carnets;
CREATE POLICY carnets_insert ON carnets
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol IN ('vocal', 'arbitro', 'admin', 'secretaria')
    )
  );

-- ============================================================
-- POLÍTICAS: pagos_carnet
-- ============================================================
DROP POLICY IF EXISTS pagos_carnet_lectura_admin ON pagos_carnet;
CREATE POLICY pagos_carnet_lectura_admin ON pagos_carnet
  FOR SELECT USING (es_admin_o_secretaria());

DROP POLICY IF EXISTS pagos_carnet_insert_admin ON pagos_carnet;
CREATE POLICY pagos_carnet_insert_admin ON pagos_carnet
  FOR INSERT WITH CHECK (es_admin_o_secretaria());

-- ============================================================
-- POLÍTICAS: pases_jugador
-- ============================================================
DROP POLICY IF EXISTS pases_lectura_admin_secretaria ON pases_jugador;
CREATE POLICY pases_lectura_admin_secretaria ON pases_jugador
  FOR SELECT USING (es_admin_o_secretaria());

DROP POLICY IF EXISTS pases_lectura_propios ON pases_jugador;
CREATE POLICY pases_lectura_propios ON pases_jugador
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM jugador_equipo je
      JOIN usuarios u ON u.club_id = je.equipo_id
      WHERE je.jugador_id = pases_jugador.jugador_id
        AND u.id = auth.uid()
    )
  );

DROP POLICY IF EXISTS pases_insert_admin_secretaria ON pases_jugador;
CREATE POLICY pases_insert_admin_secretaria ON pases_jugador
  FOR INSERT WITH CHECK (es_admin_o_secretaria());

DROP POLICY IF EXISTS pases_update_admin_secretaria ON pases_jugador;
CREATE POLICY pases_update_admin_secretaria ON pases_jugador
  FOR UPDATE USING (es_admin_o_secretaria());

DROP POLICY IF EXISTS pases_insert_presidente ON pases_jugador;
CREATE POLICY pases_insert_presidente ON pases_jugador
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol = 'delegado'
        AND club_id IS NOT NULL
    )
  );

-- ============================================================
-- POLÍTICAS: periodos_inscripcion
-- ============================================================
DROP POLICY IF EXISTS periodos_lectura_publica ON periodos_inscripcion;
CREATE POLICY periodos_lectura_publica ON periodos_inscripcion
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS periodos_admin_todo ON periodos_inscripcion;
CREATE POLICY periodos_admin_todo ON periodos_inscripcion
  FOR ALL USING (es_admin_o_secretaria());

-- ============================================================
-- POLÍTICAS: historial_clubes_jugador
-- ============================================================
DROP POLICY IF EXISTS historial_lectura ON historial_clubes_jugador;
CREATE POLICY historial_lectura ON historial_clubes_jugador
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS historial_admin ON historial_clubes_jugador;
CREATE POLICY historial_admin ON historial_clubes_jugador
  FOR ALL USING (es_admin_o_secretaria());

-- ============================================================
-- VERIFICAR POLÍTICAS CREADAS
-- ============================================================
SELECT 
  polrelid::regclass::text AS tabla,
  polname AS politica,
  CASE polcmd
    WHEN 'r' THEN 'SELECT'
    WHEN 'a' THEN 'INSERT'
    WHEN 'w' THEN 'UPDATE'
    WHEN 'd' THEN 'DELETE'
    WHEN '*' THEN 'ALL'
  END AS comando
FROM pg_policy
WHERE polrelid::regclass::text NOT LIKE 'pg_%'
ORDER BY polrelid::regclass::text, polname;

-- ============================================================
-- FIN DEL SCRIPT 05
-- ============================================================
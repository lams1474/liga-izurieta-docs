-- ============================================================
-- SCRIPT 02: FUNCIONES
-- Liga Deportiva Barrial José Ignacio Izurieta
-- ============================================================

-- ============================================================
-- FUNCIÓN: obtener_rol_usuario
-- Devuelve el rol del usuario autenticado
-- ============================================================
CREATE OR REPLACE FUNCTION obtener_rol_usuario()
RETURNS rol_usuario
LANGUAGE sql
STABLE SECURITY DEFINER
AS $$
  SELECT rol FROM usuarios WHERE id = auth.uid();
$$;

-- ============================================================
-- FUNCIÓN: es_admin_o_secretaria
-- Verifica si el usuario tiene rol admin o secretaria
-- ============================================================
CREATE OR REPLACE FUNCTION es_admin_o_secretaria()
RETURNS boolean
LANGUAGE sql
STABLE SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1 FROM usuarios 
    WHERE id = auth.uid() 
      AND rol IN ('admin', 'secretaria')
  );
$$;

-- ============================================================
-- FUNCIÓN: periodo_inscripcion_activo
-- Verifica si hay un período de inscripción activo
-- ============================================================
CREATE OR REPLACE FUNCTION periodo_inscripcion_activo()
RETURNS boolean
LANGUAGE sql
STABLE SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1 FROM periodos_inscripcion
    WHERE activo = TRUE
      AND NOW() BETWEEN fecha_inicio AND fecha_fin
  );
$$;

-- ============================================================
-- FUNCIÓN: validar_carnet
-- Devuelve estado + motivos de bloqueo del carnet
-- ============================================================
CREATE OR REPLACE FUNCTION validar_carnet(
  p_jugador_id UUID,
  p_equipo_id UUID
)
RETURNS TABLE (
  estado TEXT,
  motivos TEXT[]
)
LANGUAGE plpgsql
STABLE SECURITY DEFINER
AS $$
DECLARE
  v_motivos TEXT[] := ARRAY[]::TEXT[];
  v_carnet_pagado BOOLEAN;
  v_carnet_ano INTEGER;
  v_consentimiento BOOLEAN;
  v_foto_actualizada BOOLEAN;
  v_edad_valida BOOLEAN;
  v_estado_pase TEXT;
  v_sanciones INTEGER;
  v_deudas_jugador NUMERIC;
  v_deudas_equipo NUMERIC;
BEGIN
  -- Obtener datos del jugador
  SELECT 
    carnet_pagado, carnet_ano, consentimiento_firmado, 
    foto_actualizada, edad_valida, estado_pase
  INTO 
    v_carnet_pagado, v_carnet_ano, v_consentimiento,
    v_foto_actualizada, v_edad_valida, v_estado_pase
  FROM jugadores 
  WHERE id = p_jugador_id;

  -- 1. Verificar carnet pagado
  IF NOT COALESCE(v_carnet_pagado, FALSE) 
     OR v_carnet_ano IS NULL 
     OR v_carnet_ano != EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER THEN
    v_motivos := array_append(v_motivos, 'No ha pagado el carnet digital del año');
  END IF;

  -- 2. Verificar consentimiento LOPDP
  IF NOT COALESCE(v_consentimiento, FALSE) THEN
    v_motivos := array_append(v_motivos, 'No ha firmado el consentimiento de datos');
  END IF;

  -- 3. Verificar foto actualizada
  IF NOT COALESCE(v_foto_actualizada, FALSE) THEN
    v_motivos := array_append(v_motivos, 'No tiene foto actualizada');
  END IF;

  -- 4. Verificar edad válida
  IF NOT COALESCE(v_edad_valida, TRUE) THEN
    v_motivos := array_append(v_motivos, 'No cumple con la edad reglamentaria');
  END IF;

  -- 5. Verificar pase aprobado
  IF v_estado_pase IS NULL OR v_estado_pase != 'aprobado' THEN
    v_motivos := array_append(v_motivos, 
      'Pase deportivo no aprobado (estado: ' || COALESCE(v_estado_pase, 'sin registrar') || ')');
  END IF;

  -- 6. Contar sanciones activas
  SELECT COUNT(*) INTO v_sanciones
  FROM sanciones_jugador
  WHERE jugador_id = p_jugador_id
    AND activa = TRUE
    AND fechas_cumplidas < fechas_sancion;

  IF v_sanciones > 0 THEN
    v_motivos := array_append(v_motivos, 
      v_sanciones || ' sanción(es) activa(s) pendiente(s) de cumplir');
  END IF;

  -- 7. Sumar deudas del jugador
  SELECT COALESCE(SUM(monto - monto_pagado), 0) INTO v_deudas_jugador
  FROM deudas_jugador
  WHERE jugador_id = p_jugador_id
    AND monto_pagado < monto;

  IF v_deudas_jugador > 0 THEN
    v_motivos := array_append(v_motivos, 
      'Deuda pendiente de $' || v_deudas_jugador::TEXT);
  END IF;

  -- 8. Sumar deudas del equipo
  SELECT COALESCE(SUM(monto - monto_pagado), 0) INTO v_deudas_equipo
  FROM deudas_equipo
  WHERE equipo_id = p_equipo_id
    AND monto_pagado < monto;

  IF v_deudas_equipo > 0 THEN
    v_motivos := array_append(v_motivos, 
      'El equipo tiene deuda pendiente de $' || v_deudas_equipo::TEXT);
  END IF;

  -- Determinar estado final
  IF array_length(v_motivos, 1) IS NULL OR array_length(v_motivos, 1) = 0 THEN
    RETURN QUERY SELECT 'HABILITADO'::TEXT, ARRAY[]::TEXT[];
  ELSE
    RETURN QUERY SELECT 'BLOQUEADO'::TEXT, v_motivos;
  END IF;
END;
$$;

-- ============================================================
-- FUNCIÓN: calcular_tabla_posiciones
-- ============================================================
CREATE OR REPLACE FUNCTION calcular_tabla_posiciones(
  p_disciplina disciplina,
  p_categoria categoria
)
RETURNS TABLE(
  equipo_id uuid, equipo text, pj bigint, pg bigint, pe bigint, 
  pp bigint, gf bigint, gc bigint, dg bigint, pts bigint, 
  amarillas bigint, rojas bigint, fair_play bigint
)
LANGUAGE plpgsql
STABLE SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  WITH partidos_jugados AS (
    SELECT 
      e.id AS equipo_id,
      e.nombre AS equipo,
      p.id AS partido_id,
      p.goles_local,
      p.goles_visitante,
      p.equipo_local_id,
      p.equipo_visitante_id
    FROM equipos e
    LEFT JOIN partidos p ON (
      (p.equipo_local_id = e.id OR p.equipo_visitante_id = e.id)
      AND p.jugado = TRUE
    )
    WHERE e.disciplina = p_disciplina 
      AND e.categoria = p_categoria
      AND e.activo = TRUE
  ),
  estadisticas AS (
    SELECT 
      pj.equipo_id,
      pj.equipo,
      COUNT(pj.partido_id) AS pj,
      COUNT(CASE 
        WHEN (pj.equipo_local_id = pj.equipo_id AND pj.goles_local > pj.goles_visitante)
          OR (pj.equipo_visitante_id = pj.equipo_id AND pj.goles_visitante > pj.goles_local)
        THEN 1 END) AS pg,
      COUNT(CASE 
        WHEN pj.goles_local = pj.goles_visitante AND pj.partido_id IS NOT NULL
        THEN 1 END) AS pe,
      COUNT(CASE 
        WHEN (pj.equipo_local_id = pj.equipo_id AND pj.goles_local < pj.goles_visitante)
          OR (pj.equipo_visitante_id = pj.equipo_id AND pj.goles_visitante < pj.goles_local)
        THEN 1 END) AS pp,
      COALESCE(SUM(CASE 
        WHEN pj.equipo_local_id = pj.equipo_id THEN pj.goles_local
        WHEN pj.equipo_visitante_id = pj.equipo_id THEN pj.goles_visitante
      END), 0) AS gf,
      COALESCE(SUM(CASE 
        WHEN pj.equipo_local_id = pj.equipo_id THEN pj.goles_visitante
        WHEN pj.equipo_visitante_id = pj.equipo_id THEN pj.goles_local
      END), 0) AS gc
    FROM partidos_jugados pj
    GROUP BY pj.equipo_id, pj.equipo
  ),
  tarjetas AS (
    SELECT 
      s.equipo_id,
      COUNT(CASE WHEN s.tipo = 'amarilla' THEN 1 END) AS amarillas,
      COUNT(CASE WHEN s.tipo IN ('roja', 'doble_amarilla') THEN 1 END) AS rojas
    FROM sanciones_jugador s
    JOIN equipos e ON e.id = s.equipo_id
    WHERE e.disciplina = p_disciplina 
      AND e.categoria = p_categoria
    GROUP BY s.equipo_id
  )
  SELECT 
    est.equipo_id,
    est.equipo,
    est.pj,
    est.pg,
    est.pe,
    est.pp,
    est.gf,
    est.gc,
    (est.gf - est.gc) AS dg,
    (est.pg * 3 + est.pe * 1) AS pts,
    COALESCE(t.amarillas, 0) AS amarillas,
    COALESCE(t.rojas, 0) AS rojas,
    COALESCE(t.amarillas, 0) * 1 + COALESCE(t.rojas, 0) * 5 AS fair_play
  FROM estadisticas est
  LEFT JOIN tarjetas t ON t.equipo_id = est.equipo_id
  ORDER BY 
    pts DESC,
    dg DESC,
    gf DESC,
    est.equipo ASC;
END;
$$;

-- ============================================================
-- FUNCIÓN: calcular_tabla_goleadores
-- ============================================================
CREATE OR REPLACE FUNCTION calcular_tabla_goleadores(
  p_disciplina disciplina,
  p_categoria categoria
)
RETURNS TABLE(
  id_jugador uuid, jugador text, equipo text, goles bigint
)
LANGUAGE plpgsql
STABLE SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    j.id AS id_jugador,
    (j.apellidos || ' ' || j.nombres)::TEXT AS jugador,
    e.nombre::TEXT AS equipo,
    COUNT(g.id) AS goles
  FROM goles g
  JOIN jugadores j ON j.id = g.jugador_id
  JOIN partidos p ON p.id = g.partido_id
  JOIN equipos e ON e.id = (
    CASE 
      WHEN p.equipo_local_id IN (
        SELECT je.equipo_id FROM jugador_equipo je WHERE je.jugador_id = j.id
      )
      THEN p.equipo_local_id
      ELSE p.equipo_visitante_id
    END
  )
  WHERE e.disciplina = p_disciplina
    AND e.categoria = p_categoria
    AND g.tipo != 'autogol'
  GROUP BY j.id, j.apellidos, j.nombres, e.nombre
  ORDER BY goles DESC, j.apellidos ASC;
END;
$$;

-- ============================================================
-- FUNCIÓN: calcular_tabla_sancionados
-- ============================================================
CREATE OR REPLACE FUNCTION calcular_tabla_sancionados(
  p_disciplina disciplina,
  p_categoria categoria
)
RETURNS TABLE(
  jugador_id uuid, jugador text, equipo text, tipo tipo_sancion, 
  motivo text, fechas_sancion integer, fechas_cumplidas integer, 
  fecha_inicio date
)
LANGUAGE plpgsql
STABLE SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    j.id AS jugador_id,
    (j.apellidos || ' ' || j.nombres)::TEXT AS jugador,
    e.nombre::TEXT AS equipo,
    s.tipo,
    s.motivo,
    s.fechas_sancion,
    s.fechas_cumplidas,
    s.fecha_inicio
  FROM sanciones_jugador s
  JOIN jugadores j ON j.id = s.jugador_id
  JOIN equipos e ON e.id = s.equipo_id
  WHERE e.disciplina = p_disciplina
    AND e.categoria = p_categoria
    AND s.activa = TRUE
    AND s.fechas_cumplidas < s.fechas_sancion
  ORDER BY s.fecha_inicio DESC;
END;
$$;

-- ============================================================
-- FUNCIÓN: registrar_pago_carnet
-- ============================================================
CREATE OR REPLACE FUNCTION registrar_pago_carnet(
  p_jugador_id uuid, 
  p_monto numeric, 
  p_forma_pago text, 
  p_referencia text, 
  p_registrado_por uuid, 
  p_observaciones text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_pago_id UUID;
  v_ano INTEGER;
BEGIN
  v_ano := EXTRACT(YEAR FROM CURRENT_DATE);

  INSERT INTO pagos_carnet (
    jugador_id, monto, forma_pago, referencia, 
    registrado_por, observaciones
  ) VALUES (
    p_jugador_id, p_monto, p_forma_pago, p_referencia,
    p_registrado_por, p_observaciones
  )
  RETURNING id INTO v_pago_id;

  UPDATE jugadores
  SET 
    carnet_pagado = TRUE,
    carnet_pagado_en = NOW(),
    carnet_ano = v_ano,
    carnet_monto = p_monto
  WHERE id = p_jugador_id;

  RETURN v_pago_id;
END;
$$;

-- ============================================================
-- FUNCIONES DE TRIGGERS
-- ============================================================

-- Función: actualizar_sanciones_por_partido
CREATE OR REPLACE FUNCTION actualizar_sanciones_por_partido()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.jugado = TRUE AND (OLD.jugado = FALSE OR OLD.jugado IS NULL) THEN
    UPDATE sanciones_jugador
    SET fechas_cumplidas = fechas_cumplidas + 1,
        activa = CASE 
          WHEN fechas_cumplidas + 1 >= fechas_sancion THEN FALSE
          ELSE activa
        END
    WHERE equipo_id IN (NEW.equipo_local_id, NEW.equipo_visitante_id)
      AND activa = TRUE
      AND fechas_cumplidas < fechas_sancion;
  END IF;
  RETURN NEW;
END;
$$;

-- Función: calcular_es_menor
CREATE OR REPLACE FUNCTION calcular_es_menor()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.es_menor := (EXTRACT(YEAR FROM AGE(NEW.fecha_nacimiento)) < 18);
  RETURN NEW;
END;
$$;

-- Función: generar_codigo_interno
CREATE OR REPLACE FUNCTION generar_codigo_interno()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  v_numero INTEGER;
BEGIN
  IF NEW.codigo_interno IS NULL THEN
    SELECT COALESCE(
      MAX(CAST(SUBSTRING(codigo_interno FROM 5) AS INTEGER)), 
      0
    ) + 1
    INTO v_numero
    FROM jugadores
    WHERE codigo_interno LIKE 'JUG-%';
    
    NEW.codigo_interno := 'JUG-' || LPAD(v_numero::TEXT, 5, '0');
  END IF;
  RETURN NEW;
END;
$$;

-- Función: generar_deuda_por_sancion
CREATE OR REPLACE FUNCTION generar_deuda_por_sancion()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  v_monto NUMERIC(10,2);
  v_concepto TEXT;
BEGIN
  SELECT monto INTO v_monto
  FROM configuracion_multas
  WHERE (disciplina IS NULL OR disciplina = (
    SELECT disciplina FROM equipos WHERE id = NEW.equipo_id
  ))
    AND tipo_sancion = NEW.tipo
    AND activo = TRUE
  ORDER BY disciplina NULLS LAST
  LIMIT 1;

  v_monto := COALESCE(v_monto, 
    CASE NEW.tipo
      WHEN 'amarilla' THEN 1.00
      WHEN 'roja' THEN 2.00
      WHEN 'doble_amarilla' THEN 2.00
      ELSE 0
    END
  );

  v_concepto := 'Multa por ' || NEW.tipo::TEXT;

  INSERT INTO deudas_jugador (
    jugador_id, equipo_id, sancion_id, concepto, monto
  ) VALUES (
    NEW.jugador_id, NEW.equipo_id, NEW.id, v_concepto, v_monto
  );

  RETURN NEW;
END;
$$;

-- Función: manejar_amarillas
CREATE OR REPLACE FUNCTION manejar_amarillas()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  v_etapa_id UUID;
  v_total INTEGER;
BEGIN
  SELECT etapa_id INTO v_etapa_id
  FROM fechas
  WHERE id = (
    SELECT fecha_id FROM partidos WHERE id = NEW.partido_id
  );

  IF v_etapa_id IS NULL THEN
    SELECT e.id INTO v_etapa_id
    FROM etapas e
    JOIN equipos eq ON eq.disciplina = e.disciplina AND eq.categoria = e.categoria
    WHERE eq.id = NEW.equipo_id AND e.activa = TRUE
    ORDER BY e.fecha_inicio DESC
    LIMIT 1;
  END IF;

  IF NEW.tipo = 'amarilla' THEN
    INSERT INTO amarillas_acumuladas (jugador_id, equipo_id, etapa_id, total_amarillas)
    VALUES (NEW.jugador_id, NEW.equipo_id, v_etapa_id, 1)
    ON CONFLICT (jugador_id, equipo_id, etapa_id)
    DO UPDATE SET 
      total_amarillas = amarillas_acumuladas.total_amarillas + 1,
      actualizado_en = NOW()
    RETURNING total_amarillas INTO v_total;

    IF v_total >= 4 THEN
      INSERT INTO sanciones_jugador (
        jugador_id, equipo_id, partido_id, etapa_id,
        tipo, motivo, fechas_sancion, fecha_inicio, registrado_por
      ) VALUES (
        NEW.jugador_id, NEW.equipo_id, NEW.partido_id, v_etapa_id,
        'suspension_admin', 'Acumulación de 4 amarillas', 1, CURRENT_DATE, NEW.registrado_por
      );

      UPDATE amarillas_acumuladas
      SET total_amarillas = 0, actualizado_en = NOW()
      WHERE jugador_id = NEW.jugador_id 
        AND equipo_id = NEW.equipo_id 
        AND etapa_id = v_etapa_id;
    END IF;
  END IF;

  IF NEW.tipo = 'doble_amarilla' THEN
    UPDATE amarillas_acumuladas
    SET total_amarillas = GREATEST(total_amarillas - 2, 0),
        actualizado_en = NOW()
    WHERE jugador_id = NEW.jugador_id 
      AND equipo_id = NEW.equipo_id 
      AND etapa_id = v_etapa_id;
  END IF;

  RETURN NEW;
END;
$$;

-- Función: verificar_cierre_acta
CREATE OR REPLACE FUNCTION verificar_cierre_acta()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  v_firmas INTEGER;
BEGIN
  SELECT COUNT(DISTINCT firmante_tipo) INTO v_firmas
  FROM firmas_acta
  WHERE acta_id = NEW.acta_id
    AND firmante_tipo IN ('arbitro', 'vocal');

  IF v_firmas >= 2 THEN
    UPDATE actas
    SET estado = 'cerrada',
        cerrada_en = NOW()
    WHERE id = NEW.acta_id
      AND estado != 'cerrada';
  END IF;

  RETURN NEW;
END;
$$;

-- ============================================================
-- FIN DEL SCRIPT 02
-- ============================================================
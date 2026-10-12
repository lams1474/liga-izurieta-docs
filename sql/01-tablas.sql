-- ============================================================
-- SCRIPT 01: TIPOS ENUM, TABLAS E ÍNDICES
-- Liga Deportiva Barrial José Ignacio Izurieta
-- Base de datos: PostgreSQL (Supabase)
-- ============================================================

-- ============================================================
-- EXTENSIONES
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- TIPOS ENUM
-- ============================================================
CREATE TYPE rol_usuario AS ENUM ('admin', 'secretaria', 'vocal', 'arbitro', 'delegado', 'jugador');
CREATE TYPE disciplina AS ENUM ('futsala', 'futbol', 'ecuavoly');
CREATE TYPE categoria AS ENUM ('hombres', 'mujeres', 'sub12', 'master40');
CREATE TYPE tipo_sancion AS ENUM ('amarilla', 'roja', 'doble_amarilla', 'suspension_admin');
CREATE TYPE tipo_sancion_equipo AS ENUM ('economica', 'deportiva', 'administrativa');
CREATE TYPE tipo_gol AS ENUM ('normal', 'penal', 'autogol');
CREATE TYPE estado_acta AS ENUM ('abierta', 'firmando', 'cerrada');
CREATE TYPE tipo_firmante AS ENUM ('arbitro', 'vocal', 'capitan_local', 'capitan_visitante');

-- ============================================================
-- TABLA: usuarios
-- ============================================================
CREATE TABLE usuarios (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombres TEXT NOT NULL,
  apellidos TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT,
  rol rol_usuario NOT NULL,
  equipo_id UUID,
  club_id UUID,
  telefono TEXT,
  activo BOOLEAN DEFAULT TRUE,
  creado_en TIMESTAMPTZ DEFAULT NOW(),
  actualizado_en TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: equipos
-- ============================================================
CREATE TABLE equipos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre TEXT NOT NULL,
  disciplina disciplina NOT NULL,
  categoria categoria NOT NULL,
  escudo_url TEXT,
  colores TEXT,
  delegado_id UUID REFERENCES usuarios(id),
  activo BOOLEAN DEFAULT TRUE,
  creado_en TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (nombre, disciplina, categoria)
);

ALTER TABLE usuarios 
  ADD CONSTRAINT fk_usuarios_equipo 
  FOREIGN KEY (equipo_id) REFERENCES equipos(id);

-- ============================================================
-- TABLA: jugadores
-- ============================================================
CREATE TABLE jugadores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombres TEXT NOT NULL,
  apellidos TEXT NOT NULL,
  cedula TEXT UNIQUE NOT NULL,
  fecha_nacimiento DATE NOT NULL,
  foto_url TEXT,
  telefono TEXT,
  es_menor BOOLEAN DEFAULT FALSE,
  tutor_nombre TEXT,
  tutor_cedula TEXT,
  tutor_telefono TEXT,
  consentimiento_datos BOOLEAN DEFAULT FALSE,
  consentimiento_fecha TIMESTAMPTZ,
  token_carnet TEXT UNIQUE NOT NULL DEFAULT uuid_generate_v4()::TEXT,
  activo BOOLEAN DEFAULT TRUE,
  creado_en TIMESTAMPTZ DEFAULT NOW(),
  carnet_pagado BOOLEAN DEFAULT FALSE,
  carnet_pagado_en TIMESTAMPTZ,
  carnet_ano INTEGER,
  carnet_monto NUMERIC(10,2) DEFAULT 1.00,
  club_anterior TEXT,
  tipo_pase TEXT,
  estado_pase TEXT DEFAULT 'pendiente',
  pase_aprobado_en DATE,
  pase_documento_url TEXT,
  calificado BOOLEAN DEFAULT FALSE,
  consentimiento_firmado BOOLEAN DEFAULT FALSE,
  foto_actualizada BOOLEAN DEFAULT FALSE,
  edad_valida BOOLEAN DEFAULT TRUE,
  codigo_interno TEXT UNIQUE
);

-- ============================================================
-- TABLA: jugador_equipo
-- ============================================================
CREATE TABLE jugador_equipo (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  jugador_id UUID NOT NULL REFERENCES jugadores(id) ON DELETE CASCADE,
  equipo_id UUID NOT NULL REFERENCES equipos(id) ON DELETE CASCADE,
  dorsal INTEGER,
  posicion TEXT,
  fecha_inscripcion DATE DEFAULT CURRENT_DATE,
  activo BOOLEAN DEFAULT TRUE,
  creado_en TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (jugador_id, equipo_id)
);

-- ============================================================
-- TABLA: etapas
-- ============================================================
CREATE TABLE etapas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre TEXT NOT NULL,
  disciplina disciplina NOT NULL,
  categoria categoria NOT NULL,
  fecha_inicio DATE,
  fecha_fin DATE,
  activa BOOLEAN DEFAULT TRUE,
  creado_en TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: reglas_disciplina
-- ============================================================
CREATE TABLE reglas_disciplina (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  disciplina disciplina NOT NULL,
  categoria categoria NOT NULL,
  min_jugadores INTEGER NOT NULL,
  max_acta INTEGER NOT NULL,
  sustituciones INTEGER,
  juvenil_obligatorio BOOLEAN DEFAULT FALSE,
  puntos_victoria INTEGER DEFAULT 3,
  puntos_empate INTEGER DEFAULT 1,
  puntos_derrota INTEGER DEFAULT 0,
  UNIQUE (disciplina, categoria)
);

-- ============================================================
-- TABLA: configuracion_multas
-- ============================================================
CREATE TABLE configuracion_multas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  disciplina disciplina,
  tipo_sancion tipo_sancion NOT NULL,
  monto NUMERIC(10,2) NOT NULL DEFAULT 0,
  fechas_sancion INTEGER NOT NULL DEFAULT 0,
  activo BOOLEAN DEFAULT TRUE,
  actualizado_por UUID REFERENCES usuarios(id),
  actualizado_en TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: arbitros
-- ============================================================
CREATE TABLE arbitros (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombres TEXT NOT NULL,
  apellidos TEXT NOT NULL,
  cedula TEXT UNIQUE,
  telefono TEXT,
  asociacion TEXT,
  activo BOOLEAN DEFAULT TRUE,
  creado_en TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: fechas
-- ============================================================
CREATE TABLE fechas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  etapa_id UUID NOT NULL REFERENCES etapas(id) ON DELETE CASCADE,
  numero INTEGER NOT NULL,
  fecha_inicio DATE,
  fecha_fin DATE,
  activa BOOLEAN DEFAULT TRUE,
  creado_en TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: partidos
-- ============================================================
CREATE TABLE partidos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  fecha_id UUID NOT NULL REFERENCES fechas(id) ON DELETE CASCADE,
  hora TIME,
  cancha TEXT,
  equipo_local_id UUID NOT NULL REFERENCES equipos(id),
  equipo_visitante_id UUID NOT NULL REFERENCES equipos(id),
  arbitro_id UUID REFERENCES arbitros(id),
  goles_local INTEGER DEFAULT 0,
  goles_visitante INTEGER DEFAULT 0,
  jugado BOOLEAN DEFAULT FALSE,
  observaciones TEXT,
  registrado_por UUID REFERENCES usuarios(id),
  creado_en TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: goles
-- ============================================================
CREATE TABLE goles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  partido_id UUID NOT NULL REFERENCES partidos(id) ON DELETE CASCADE,
  jugador_id UUID NOT NULL REFERENCES jugadores(id),
  minuto INTEGER,
  tipo tipo_gol DEFAULT 'normal',
  creado_en TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: sanciones_jugador
-- ============================================================
CREATE TABLE sanciones_jugador (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  jugador_id UUID NOT NULL REFERENCES jugadores(id) ON DELETE CASCADE,
  equipo_id UUID NOT NULL REFERENCES equipos(id),
  partido_id UUID REFERENCES partidos(id),
  etapa_id UUID REFERENCES etapas(id),
  tipo tipo_sancion NOT NULL,
  motivo TEXT,
  fechas_sancion INTEGER DEFAULT 0,
  fechas_cumplidas INTEGER DEFAULT 0,
  fecha_inicio DATE,
  activa BOOLEAN DEFAULT TRUE,
  registrado_por UUID REFERENCES usuarios(id),
  creado_en TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: amarillas_acumuladas
-- ============================================================
CREATE TABLE amarillas_acumuladas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  jugador_id UUID NOT NULL REFERENCES jugadores(id) ON DELETE CASCADE,
  equipo_id UUID NOT NULL REFERENCES equipos(id) ON DELETE CASCADE,
  etapa_id UUID NOT NULL REFERENCES etapas(id) ON DELETE CASCADE,
  total_amarillas INTEGER DEFAULT 0,
  actualizado_en TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (jugador_id, equipo_id, etapa_id)
);

-- ============================================================
-- TABLA: sanciones_equipo
-- ============================================================
CREATE TABLE sanciones_equipo (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  equipo_id UUID NOT NULL REFERENCES equipos(id) ON DELETE CASCADE,
  motivo TEXT NOT NULL,
  tipo tipo_sancion_equipo NOT NULL,
  descripcion TEXT,
  monto NUMERIC(10,2) DEFAULT 0,
  fechas_sancion INTEGER DEFAULT 0,
  activa BOOLEAN DEFAULT TRUE,
  registrado_por UUID REFERENCES usuarios(id),
  creado_en TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: deudas_equipo
-- ============================================================
CREATE TABLE deudas_equipo (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  equipo_id UUID NOT NULL REFERENCES equipos(id) ON DELETE CASCADE,
  concepto TEXT NOT NULL,
  monto NUMERIC(10,2) NOT NULL,
  monto_pagado NUMERIC(10,2) DEFAULT 0,
  fecha_emision DATE DEFAULT CURRENT_DATE,
  fecha_vencimiento DATE,
  registrado_por UUID REFERENCES usuarios(id),
  creado_en TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: deudas_jugador
-- ============================================================
CREATE TABLE deudas_jugador (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  jugador_id UUID NOT NULL REFERENCES jugadores(id) ON DELETE CASCADE,
  equipo_id UUID NOT NULL REFERENCES equipos(id),
  sancion_id UUID REFERENCES sanciones_jugador(id),
  concepto TEXT NOT NULL,
  monto NUMERIC(10,2) NOT NULL,
  monto_pagado NUMERIC(10,2) DEFAULT 0,
  fecha_emision DATE DEFAULT CURRENT_DATE,
  fecha_vencimiento DATE,
  registrado_por UUID REFERENCES usuarios(id),
  creado_en TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: actas
-- ============================================================
CREATE TABLE actas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  partido_id UUID UNIQUE NOT NULL REFERENCES partidos(id) ON DELETE CASCADE,
  estado estado_acta DEFAULT 'abierta',
  observaciones TEXT,
  cerrada_en TIMESTAMPTZ,
  pdf_url TEXT,
  hash_documento TEXT,
  creado_en TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: firmas_acta
-- ============================================================
CREATE TABLE firmas_acta (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  acta_id UUID NOT NULL REFERENCES actas(id) ON DELETE CASCADE,
  firmante_tipo tipo_firmante NOT NULL,
  firmante_id UUID,
  firma_digital TEXT,
  firmado_en TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: carnets
-- ============================================================
CREATE TABLE carnets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  jugador_id UUID NOT NULL REFERENCES jugadores(id) ON DELETE CASCADE,
  equipo_id UUID NOT NULL REFERENCES equipos(id),
  partido_id UUID REFERENCES partidos(id),
  valido BOOLEAN NOT NULL,
  motivo_bloqueo TEXT,
  escaneado_por UUID REFERENCES usuarios(id),
  fecha_hora TIMESTAMPTZ DEFAULT NOW(),
  sincronizado BOOLEAN DEFAULT TRUE
);

-- ============================================================
-- TABLA: pagos_carnet
-- ============================================================
CREATE TABLE pagos_carnet (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  jugador_id UUID NOT NULL REFERENCES jugadores(id) ON DELETE CASCADE,
  monto NUMERIC(10,2) NOT NULL DEFAULT 1.00,
  forma_pago TEXT DEFAULT 'efectivo',
  referencia TEXT,
  registrado_por UUID REFERENCES usuarios(id),
  fecha_pago TIMESTAMPTZ DEFAULT NOW(),
  comprobante_url TEXT,
  observaciones TEXT,
  creado_en TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: pases_jugador
-- ============================================================
CREATE TABLE pases_jugador (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  jugador_id UUID NOT NULL REFERENCES jugadores(id) ON DELETE CASCADE,
  club_origen TEXT,
  club_destino TEXT,
  tipo_pase TEXT NOT NULL,
  estado TEXT NOT NULL DEFAULT 'pendiente',
  observaciones TEXT,
  documento_url TEXT,
  solicitado_por UUID REFERENCES usuarios(id),
  aprobado_por UUID REFERENCES usuarios(id),
  fecha_solicitud DATE DEFAULT CURRENT_DATE,
  fecha_aprobacion DATE,
  motivo_rechazo TEXT,
  creado_en TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: periodos_inscripcion
-- ============================================================
CREATE TABLE periodos_inscripcion (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre TEXT NOT NULL,
  disciplina disciplina,
  categoria categoria,
  fecha_inicio TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  fecha_fin TIMESTAMPTZ NOT NULL,
  activo BOOLEAN DEFAULT TRUE,
  creado_por UUID REFERENCES usuarios(id),
  creado_en TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: historial_clubes_jugador
-- ============================================================
CREATE TABLE historial_clubes_jugador (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  jugador_id UUID NOT NULL REFERENCES jugadores(id) ON DELETE CASCADE,
  equipo_id UUID NOT NULL REFERENCES equipos(id),
  disciplina disciplina NOT NULL,
  categoria categoria NOT NULL,
  temporada TEXT NOT NULL,
  fecha_desde DATE NOT NULL,
  fecha_hasta DATE,
  tipo_movimiento TEXT,
  observaciones TEXT,
  registrado_por UUID REFERENCES usuarios(id),
  creado_en TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ÍNDICES
-- ============================================================
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_rol ON usuarios(rol);
CREATE INDEX idx_usuarios_club ON usuarios(club_id);
CREATE INDEX idx_equipos_disciplina ON equipos(disciplina, categoria);
CREATE INDEX idx_jugadores_cedula ON jugadores(cedula);
CREATE INDEX idx_jugadores_token ON jugadores(token_carnet);
CREATE INDEX idx_jugadores_pase ON jugadores(estado_pase);
CREATE INDEX idx_jugadores_calificado ON jugadores(calificado);
CREATE INDEX idx_jugadores_carnet ON jugadores(carnet_pagado, carnet_ano);
CREATE INDEX idx_jugador_equipo_jugador ON jugador_equipo(jugador_id);
CREATE INDEX idx_jugador_equipo_equipo ON jugador_equipo(equipo_id);
CREATE INDEX idx_partidos_fecha ON partidos(fecha_id);
CREATE INDEX idx_partidos_equipos ON partidos(equipo_local_id, equipo_visitante_id);
CREATE INDEX idx_goles_partido ON goles(partido_id);
CREATE INDEX idx_goles_jugador ON goles(jugador_id);
CREATE INDEX idx_sanciones_jugador ON sanciones_jugador(jugador_id, activa);
CREATE INDEX idx_deudas_equipo ON deudas_equipo(equipo_id);
CREATE INDEX idx_deudas_jugador ON deudas_jugador(jugador_id);
CREATE INDEX idx_carnets_jugador ON carnets(jugador_id);
CREATE INDEX idx_actas_partido ON actas(partido_id);
CREATE INDEX idx_pagos_carnet_jugador ON pagos_carnet(jugador_id);
CREATE INDEX idx_pagos_carnet_fecha ON pagos_carnet(fecha_pago);
CREATE INDEX idx_pases_jugador ON pases_jugador(jugador_id);
CREATE INDEX idx_pases_estado ON pases_jugador(estado);
CREATE INDEX idx_pases_tipo ON pases_jugador(tipo_pase);
CREATE INDEX idx_periodos_activo ON periodos_inscripcion(activo, fecha_fin);
CREATE INDEX idx_historial_jugador ON historial_clubes_jugador(jugador_id, fecha_desde DESC);
CREATE INDEX idx_historial_equipo ON historial_clubes_jugador(equipo_id, fecha_hasta);
CREATE INDEX idx_historial_temporada ON historial_clubes_jugador(temporada);

-- ============================================================
-- FIN DEL SCRIPT 01
-- ============================================================
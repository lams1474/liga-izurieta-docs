# Panel administrativo

## Información

- **Repositorio:** [liga-izurieta-admin](https://github.com/lams1474/liga-izurieta-admin)
- **Producción:** (pendiente deploy en Vercel)
- **Descripción:** Panel con login obligatorio para gestionar todo el sistema.
- **Framework:** React + Vite
- **Estilos:** Tailwind CSS
- **Backend:** Supabase (Auth + DB)

## Roles y accesos

| Rol | Módulos disponibles |
|---|---|
| `admin` | Todos |
| `secretaria` | Jugadores, Equipos, Pagos, Calendario, Sanciones, Actas, Reportes |
| `delegado` | Mis Jugadores, Mi Club, Mis Pases, Mi Nómina |
| `capitan` | Cerrar Acta |
| `vocal` | Planilla, Partido en Curso, Validar Carnets, Novedades |
| `arbitro` | Partido en Curso, Tarjetas, Goles, Novedades |

## Estado de los módulos

| # | Módulo | Estado |
|---|---|---|
| 1 | Login y autenticación | ✅ |
| 2 | Header + Sidebar por rol | ✅ |
| 3 | Jugadores (CRUD) | ✅ |
| 4 | Importar Excel | ✅ |
| 5 | Usuarios | ⏳ |
| 6 | Equipos | ⏳ |
| 7 | Pagos | ⏳ |
| 8 | Calendario | ⏳ |
| 9 | Sanciones | ⏳ |
| 10 | Actas | ⏳ |
| 11 | Reportes | ⏳ |
| 12 | Módulo Presidente (subir jugadores) | ⏳ |
| 13 | Módulo Vocal | ⏳ |
| 14 | Módulo Árbitro | ⏳ |
| 15 | Módulo Capitán | ⏳ |
| 16 | Deploy en Vercel | ⏳ |

## Módulos implementados

### Login
- Email + contraseña
- Detección automática de rol
- Redirección según rol
- Sesión persistente

### Header + Sidebar
- Header azul con logo de la liga
- Nombre del usuario y rol
- Botón "Salir"
- Sidebar con menús según rol
- Responsive (menú hamburguesa en móvil)

### Jugadores
- **Lista:** búsqueda, filtros por disciplina/categoría/equipo/estado
- **Formulario:** crear/editar con validaciones
- **Detalle:** información completa + sanciones + deudas + historial
- **Baja lógica:** mantiene historial, no borra
- **Cambio de equipo:** registra pase automáticamente
- **Pago de carnet:** desde el detalle
- **Importar Excel:** carga masiva con detección de duplicados

## Variables de entorno

```env
VITE_SUPABASE_URL=https://gylnajxmlalnyueanhll.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...
```

## Instalación local

```bash
git clone https://github.com/lams1474/liga-izurieta-admin.git
cd liga-izurieta-admin
npm install
# crear .env.local con las credenciales
npm run dev
```

La app estará en `http://localhost:5173` (o 5174 si está ocupado).

## Credenciales de prueba

| Rol | Email | Contraseña |
|---|---|---|
| admin | ligajoseizurieta@gmail.com | lams1474 |
| secretaria | secretaria@ligajoseizurieta.com | secretaria2026 (pendiente crear) |
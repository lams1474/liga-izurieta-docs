# Web pública

## Información

- **Repositorio:** [web-liga-izurieta](https://github.com/lams1474/web-liga-izurieta)
- **Producción:** https://web-liga-izurieta.vercel.app
- **Descripción:** Sitio público sin login. Cualquiera puede consultar.
- **Framework:** React + Vite
- **Estilos:** Tailwind CSS
- **Deploy:** Vercel (automático desde GitHub)

## Páginas

### 1. Inicio
Página de bienvenida con información general de la liga.

### 2. Tabla de posiciones
- Selector de disciplina (fútbol, futsala, ecuavoly)
- Selector de categoría (hombres, mujeres, sub12, master40)
- Columnas: #, Equipo, PJ, PG, PE, PP, GF, GC, DG, PTS
- Líder destacado con etiqueta "LÍDER"

### 3. Goleadores
- Selector de disciplina y categoría
- Podio con las 3 primeras posiciones 🥇🥈🥉
- Tabla completa con todos los goleadores

### 4. Sancionados
- Selector de disciplina y categoría
- Tarjetas por sanción con color según tipo (amarilla, roja, doble, admin)
- Muestra fechas pendientes

### 5. Calendario
- Pestañas "Próximos" y "Resultados"
- Tarjetas por partido con hora, cancha, equipos
- Marcador cuando el partido está jugado

### 6. Verificar Carnet
- Buscador por cédula
- Muestra estado del jugador: HABILITADO o BLOQUEADO
- Si está bloqueado, lista TODOS los motivos

## URLs

| Página | URL local | URL producción |
|---|---|---|
| Inicio | http://localhost:5173/ | https://web-liga-izurieta.vercel.app/ |
| Tabla | http://localhost:5173/tabla | https://web-liga-izurieta.vercel.app/tabla |
| Goleadores | http://localhost:5173/goleadores | .../goleadores |
| Sancionados | http://localhost:5173/sancionados | .../sancionados |
| Calendario | http://localhost:5173/calendario | .../calendario |
| Verificar | http://localhost:5173/verificar | .../verificar |

## Variables de entorno

```env
VITE_SUPABASE_URL=https://gylnajxmlalnyueanhll.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...
```

## Instalación local

```bash
git clone https://github.com/lams1474/web-liga-izurieta.git
cd web-liga-izurieta
npm install
# crear .env.local con las credenciales
npm run dev
```

## Cómo se actualiza

Cada vez que se hace `git push` a la rama `main`, Vercel redespliega automáticamente en 1-2 minutos.
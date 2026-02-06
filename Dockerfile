FROM node:20-alpine AS base

# Instalar dependencias solo cuando sea necesario
FROM base AS deps
# Revisar https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine para entender por qué puede ser necesario libc6-compat.
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Instalar dependencias basándose en el archivo de bloqueo
COPY package.json package-lock.json* ./
RUN npm ci

# Reconstruir el código fuente solo cuando sea necesario
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Next.js recolecta datos de telemetría anónimos sobre el uso general.
# Aprende más aquí: https://nextjs.org/telemetry
# Descomenta la siguiente línea si quieres deshabilitar la telemetría durante la construcción.
# ENV NEXT_TELEMETRY_DISABLED=1

RUN npm run build

# Nueva etapa de pruebas para el pipeline de CI
FROM base AS tester
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
# Ejecutamos los tests. Si fallan, la construcción de la imagen se detendrá.
RUN npm test

# Imagen de producción, copiar todos los archivos y ejecutar next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
# Descomenta la siguiente línea si quieres deshabilitar la telemetría durante la ejecución.
# ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public

# Establecer permisos correctos para la caché de prerenderizado
RUN mkdir .next
RUN chown nextjs:nodejs .next

# Aprovechar automáticamente las trazas de salida para reducir el tamaño de la imagen
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT=3000

# server.js es creado por next build desde la salida standalone
# https://nextjs.org/docs/pages/api-reference/next-config-js/output
CMD ["node", "server.js"]


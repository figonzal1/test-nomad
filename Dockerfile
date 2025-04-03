# ETAPA 1: Etapa de construcción
FROM node:20-alpine AS build-stage

WORKDIR /app

# Copiar solo los archivos necesarios para la instalación
COPY package*.json ./

# Instalar dependencias de desarrollo y el CLI de NestJS
RUN npm ci && npm install -g @nestjs/cli

# Copiar solo los archivos necesarios para la compilación
COPY . .

# Ejecutar la construcción de la aplicación
RUN npm run build

# ETAPA 2: Etapa de ejecución
FROM node:20-alpine AS production-stage

WORKDIR /app

# Copiar solo los archivos necesarios desde la etapa de construcción
COPY --from=build-stage /app/package*.json ./
COPY --from=build-stage /app/dist ./dist

# Instalar solo las dependencias de producción
RUN npm ci --only=production && npm cache clean --force

# Exponer el puerto
EXPOSE 3007

# Comando para ejecutar la aplicación
CMD ["node", "dist/main.js"]
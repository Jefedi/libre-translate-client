FROM node:20-alpine

WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer les dépendances
RUN npm ci --only=production

# Copier le code source
COPY . .

# Créer le dossier data
RUN mkdir -p /app/data

# Exposer le port
EXPOSE 3000

# Démarrer l'application
CMD ["npm", "start"]

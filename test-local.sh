#!/bin/bash

# Script de test local pour valider les microservices
echo " Test des microservices locaux..."

# Construire les images localement
echo " Construction des images Docker..."
docker build -t snsitso/cast-service:test ./cast-service
docker build -t snsitso/movie-service:test ./movie-service

echo "Images construites avec succès!"

# Démarrer les services avec docker-compose
echo " Démarrage des services..."
docker-compose up -d

echo " Attente du démarrage des services (30 secondes)..."
sleep 30

# Tester les endpoints
echo " Test des endpoints..."

echo " Test Cast Service:"
curl -f http://localhost:8002/api/v1/casts/ || echo "❌ Cast service non disponible"

echo " Test Movie Service:"
curl -f http://localhost:8001/api/v1/movies/ || echo "❌ Movie service non disponible"

echo " Test Nginx Reverse Proxy:"
curl -f http://localhost:8080/api/v1/casts/ || echo "❌ Nginx proxy non disponible"
curl -f http://localhost:8080/api/v1/movies/ || echo "❌ Nginx proxy non disponible"

echo ""
echo " URLs de test disponibles:"
echo "   - Cast Service: http://localhost:8002/api/v1/casts/docs"
echo "   - Movie Service: http://localhost:8001/api/v1/movies/docs"
echo "   - API Gateway: http://localhost:8080/api/v1/casts/"
echo "   - API Gateway: http://localhost:8080/api/v1/movies/"

echo ""
echo " Pour arrêter les services:"
echo "   docker-compose down"
#!/bin/bash

# Script pour créer les namespaces Kubernetes pour les 4 environnements
# Exécutez ce script avant de déployer avec Jenkins

echo " Création des namespaces Kubernetes..."

# Créer les namespaces
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace qa --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace staging --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -

echo " Namespaces créés avec succès!"

# Vérifier les namespaces
echo " Liste des namespaces disponibles:"
kubectl get namespaces | grep -E "(dev|qa|staging|prod)"

echo ""
echo " Environnements configurés pour le déploiement:"
echo "   - dev: Déploiement automatique sur toutes les branches"
echo "   - qa: Déploiement automatique sur master/develop"  
echo "   - staging: Déploiement automatique sur master"
echo "   - prod: Déploiement manuel sur master uniquement"

echo ""
echo " Pour déployer manuellement:"
echo "   helm install microservices-dev ./charts --namespace dev"
echo "   helm install microservices-qa ./charts --namespace qa"
echo "   helm install microservices-staging ./charts --namespace staging"
echo "   helm install microservices-prod ./charts --namespace prod"
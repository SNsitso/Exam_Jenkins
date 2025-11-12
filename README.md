# DATASCIENTEST JENKINS EXAM
# Python Microservices with FastAPI - DevOps Pipeline

##  Vue d'ensemble

Ce projet implémente une architecture microservices complète avec :
- **2 microservices Python** : Cast Service & Movie Service
- **Pipeline CI/CD Jenkins** complet
- **Déploiement Kubernetes** avec Helm
- **4 environnements** : dev, QA, staging, prod
- **Tests automatisés** et monitoring

##  Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Movie Service │    │   Cast Service  │
│   (Port 8001)   │    │   (Port 8002)   │
└─────────────────┘    └─────────────────┘
         │                       │
         └──────┬─────────────────┘
                │
        ┌───────▼───────┐
        │ Nginx Gateway │
        │  (Port 8080)  │
        └───────────────┘
```

## 🚀 Démarrage rapide

### Pré-requis
- Docker & Docker Compose
- Kubernetes (minikube/k3s)
- Helm 3.x
- Jenkins avec plugins: Docker, Kubernetes, Git

### Test local
```bash
# Tester les services localement
./test-local.sh

# Ou manuellement
docker-compose up -d
```

### Configuration Kubernetes
```bash
# Créer les namespaces
./setup-namespaces.sh

# Déployer manuellement
helm install microservices-dev ./charts --namespace dev
```

##  Pipeline CI/CD

### Étapes du pipeline Jenkins :

1. **Clone Repository** - Récupération du code depuis GitHub
2. **Build Services** - Construction des images Docker
   - `snsitso/cast-service:${BUILD_NUMBER}`
   - `snsitso/movie-service:${BUILD_NUMBER}`
3. **Run Tests** - Tests de smoke des services
4. **Push to DockerHub** - Publication des images
5. **Deploy to Dev** - Déploiement automatique (toutes branches)
6. **Deploy to QA** - Déploiement automatique (master/develop)
7. **Deploy to Staging** - Déploiement automatique (master only)
8. **Deploy to Production** - Déploiement manuel (master only)

### Déclenchement des déploiements :

| Environnement | Branche | Déclenchement |
|---------------|---------|---------------|
| Development   | Toutes  | Automatique   |
| QA           | master/develop | Automatique |
| Staging      | master  | Automatique   |
| Production   | master  | Manuel        |

### Déploiement Production
Pour déployer en production, cochez le paramètre `DEPLOY_TO_PROD` lors du lancement du pipeline.

##  Services

### Cast Service
- **Port** : 8002
- **API** : `/api/v1/casts/`
- **Docs** : `http://localhost:8002/api/v1/casts/docs`
- **Database** : PostgreSQL (cast_db_dev)

### Movie Service  
- **Port** : 8001
- **API** : `/api/v1/movies/`
- **Docs** : `http://localhost:8001/api/v1/movies/docs`
- **Database** : PostgreSQL (movie_db_dev)

### API Gateway (Nginx)
- **Port** : 8080
- **Routes** :
  - `http://localhost:8080/api/v1/casts/` → Cast Service
  - `http://localhost:8080/api/v1/movies/` → Movie Service

##  Configuration

### Variables d'environnement Jenkins

```groovy
environment {
    DOCKER_REGISTRY = 'snsitso'
    BUILD_NUMBER_TAG = "${env.BUILD_NUMBER}"
    GIT_BRANCH_NAME = "${env.BRANCH_NAME}"
}
```

### Credentials Jenkins requis
- `dockerhub` : Username/Password pour DockerHub
- `github` : Token d'accès GitHub (optionnel)

### Helm Values par environnement

```yaml
# Development
castService:
  replicaCount: 1
movieService:
  replicaCount: 1

# Production  
castService:
  replicaCount: 3
movieService:
  replicaCount: 3
```

##  Images Docker

### Images créées
- `snsitso/cast-service:latest`
- `snsitso/cast-service:${BUILD_NUMBER}`
- `snsitso/movie-service:latest`
- `snsitso/movie-service:${BUILD_NUMBER}`

### Tagging strategy
- `latest` : Dernière version stable
- `${BUILD_NUMBER}` : Version spécifique du build Jenkins

##  Tests

### Tests automatiques
- **Smoke tests** : Vérification démarrage des containers
- **Health checks** : Tests des endpoints API
- **Integration tests** : Communication entre services

### Tests manuels
```bash
# Test du Cast Service
curl http://localhost:8002/api/v1/casts/

# Test du Movie Service  
curl http://localhost:8001/api/v1/movies/

# Test via Gateway
curl http://localhost:8080/api/v1/casts/
curl http://localhost:8080/api/v1/movies/
```

## 📊 Monitoring

### Métriques disponibles
- **Build status** : Success/Failure rate
- **Deployment times** : Performance du pipeline
- **Service health** : Uptime des microservices

### Logs
- **Jenkins logs** : Pipeline execution
- **Container logs** : `docker logs <container_name>`
- **Kubernetes logs** : `kubectl logs <pod_name> -n <namespace>`

##  Sécurité

### Bonnes pratiques implémentées
- **Credentials management** : Jenkins credentials store
- **Image scanning** : Sécurité des images Docker
- **Network policies** : Isolation des environnements
- **RBAC** : Contrôle d'accès Kubernetes

##  Documentation

### Liens utiles
- **GitHub Repository** : https://github.com/SNsitso/Exam_Jenkins
- **DockerHub** : https://hub.docker.com/repositories/snsitso
- **Helm Charts** : `./charts/`

### Structure du projet
```
├── cast-service/           # Microservice Cast
│   ├── app/               # Code Python FastAPI
│   ├── Dockerfile         # Image Docker
│   └── requirements.txt   # Dépendances Python
├── movie-service/         # Microservice Movie  
│   ├── app/               # Code Python FastAPI
│   ├── Dockerfile         # Image Docker
│   └── requirements.txt   # Dépendances Python
├── charts/                # Helm Charts Kubernetes
│   ├── templates/         # Templates K8s
│   ├── values.yaml        # Configuration
│   └── Chart.yaml         # Métadonnées Helm
├── Jenkinsfile           # Pipeline CI/CD
├── docker-compose.yml    # Orchestration locale
├── nginx_config.conf     # Configuration Nginx
├── setup-namespaces.sh  # Script setup K8s
└── test-local.sh         # Script de test local
```

##  Objectifs DevOps atteints

 **Architecture microservices** définie et implémentée  
 **Tests automatisés** intégrés au pipeline  
 **Intégration et déploiement** automatisés  
 **Adoption** facilitée avec documentation complète  
 **Formations** via scripts et documentation  
**Bon fonctionnement** garanti avec monitoring  
 **Qualité** assurée à chaque étape du cycle  

---

##  Équipe

**Ingénieur DevOps** : Serge Nyuiadzi (SNsitso)  
**Projet** : Examen DevOps - DataScientest  
**Date** : Novembre 2025

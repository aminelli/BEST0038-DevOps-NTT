# 🚀 Kubernetes Deployment - Corso NTT 38

Configurazione completa per il deployment dell'applicazione Spring Boot su cluster Kubernetes.

## 📋 Indice

- [Architettura](#architettura)
- [Prerequisiti](#prerequisiti)
- [File di Configurazione](#file-di-configurazione)
- [Deploy Rapido](#deploy-rapido)
- [Deploy Dettagliato](#deploy-dettagliato)
- [Accesso all'Applicazione](#accesso-allapplicazione)
- [Scaling e Autoscaling](#scaling-e-autoscaling)
- [Monitoring e Logging](#monitoring-e-logging)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)

---

## 🏗️ Architettura

```
┌─────────────────────────────────────────────────────────────┐
│                     Kubernetes Cluster                       │
│                                                               │
│  ┌────────────────────────────────────────────────────┐     │
│  │          Namespace: corso-ntt-38                   │     │
│  │                                                     │     │
│  │  ┌──────────────────────────────────────────┐     │     │
│  │  │         Ingress Controller               │     │     │
│  │  │      (nginx / traefik / istio)           │     │     │
│  │  └─────────────┬────────────────────────────┘     │     │
│  │                │                                    │     │
│  │       ┌────────▼────────┐                          │     │
│  │       │  Service (8080)  │                         │     │
│  │       │   + NodePort     │                         │     │
│  │       └────────┬─────────┘                         │     │
│  │                │                                    │     │
│  │    ┌──────────┴──────────┬──────────┐             │     │
│  │    │                     │          │             │     │
│  │  ┌─▼──┐              ┌──▼─┐      ┌─▼──┐          │     │
│  │  │Pod1│              │Pod2│      │Pod3│          │     │
│  │  │8080│              │8080│      │8080│          │     │
│  │  └────┘              └────┘      └────┘          │     │
│  │    │                   │           │              │     │
│  │    └───────────────────┴───────────┘              │     │
│  │                       │                            │     │
│  │              ┌────────▼────────┐                   │     │
│  │              │   ConfigMap     │                   │     │
│  │              │   + Secrets     │                   │     │
│  │              └─────────────────┘                   │     │
│  │                                                     │     │
│  │  HPA: Auto-scaling 3-10 pods (CPU/Memory)          │     │
│  │  PDB: Min 2 pods sempre disponibili                │     │
│  │  NetworkPolicy: Controllo traffico                 │     │
│  └─────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

### Componenti

| Componente | Descrizione | File |
|------------|-------------|------|
| **Namespace** | Isolamento logico delle risorse | `namespace.yaml` |
| **Deployment** | Gestisce 3 repliche dei pod | `deployment.yaml` |
| **Service** | Espone l'applicazione (ClusterIP + NodePort) | `service.yaml` |
| **ConfigMap** | Configurazione applicativa | `configmap.yaml` |
| **Secret** | Credenziali e dati sensibili | `secret.yaml` |
| **Ingress** | Routing HTTP/HTTPS | `ingress.yaml` |
| **HPA** | Autoscaling basato su metriche | `hpa.yaml` |
| **PDB** | Garantisce disponibilità minima | `pdb.yaml` |
| **NetworkPolicy** | Controllo traffico di rete | `networkpolicy.yaml` |

---

## 🔧 Prerequisiti

### Software Richiesto

- ✅ **kubectl** - Client Kubernetes
- ✅ **Cluster Kubernetes** (Minikube, K3s, AKS, EKS, GKE)
- ✅ **Docker** - Per build immagini
- ✅ **Helm** (opzionale) - Package manager K8s

### Verifica Prerequisiti

```bash
# Verifica kubectl
kubectl version --client

# Verifica connessione al cluster
kubectl cluster-info

# Verifica nodi disponibili
kubectl get nodes

# Verifica Docker
docker version
```

---

## 📁 File di Configurazione

```
Infra/
├── namespace.yaml          # Namespace dedicato
├── deployment.yaml         # Deployment con 3 repliche
├── service.yaml           # Service (ClusterIP + NodePort)
├── configmap.yaml         # Configurazione applicativa
├── secret.yaml            # Credenziali (base64)
├── ingress.yaml           # Routing HTTP/HTTPS
├── hpa.yaml               # Horizontal Pod Autoscaler
├── pdb.yaml               # Pod Disruption Budget
├── networkpolicy.yaml     # Network policies
├── kustomization.yaml     # Kustomize configuration
└── README.md              # Questa guida
```

---

## 🚀 Deploy Rapido

### Opzione 1: Deploy con kubectl

```bash
# 1. Naviga nella cartella Infra
cd Infra

# 2. Crea namespace
kubectl apply -f namespace.yaml

# 3. Deploy di tutte le risorse
kubectl apply -f .

# 4. Verifica deployment
kubectl get all -n corso-ntt-38
```

### Opzione 2: Deploy con Kustomize

```bash
# Deploy con Kustomize (più pulito)
kubectl apply -k Infra/

# Oppure
cd Infra
kustomize build . | kubectl apply -f -
```

### Verifica Status

```bash
# Verifica pod
kubectl get pods -n corso-ntt-38 -w

# Verifica service
kubectl get svc -n corso-ntt-38

# Verifica ingress
kubectl get ingress -n corso-ntt-38

# Descrizione deployment
kubectl describe deployment corso-ntt-38-app -n corso-ntt-38
```

---

## 📝 Deploy Dettagliato

### Step 1: Preparazione Immagine Docker

```bash
# Build immagine Docker
cd ..
docker build -t corso-ntt-38:latest .

# Per cluster remoto, push su registry
# docker tag corso-ntt-38:latest myregistry.azurecr.io/corso-ntt-38:latest
# docker push myregistry.azurecr.io/corso-ntt-38:latest
```

### Step 2: Configurazione (opzionale)

```bash
# Modifica ConfigMap se necessario
kubectl edit configmap corso-ntt-38-config -n corso-ntt-38

# Modifica Secret (usa base64 encoding)
echo -n "nuova-password" | base64
# Poi modifica secret.yaml e applica
kubectl apply -f secret.yaml
```

### Step 3: Deploy Namespace

```bash
kubectl apply -f namespace.yaml

# Verifica
kubectl get namespace corso-ntt-38
```

### Step 4: Deploy ConfigMap e Secret

```bash
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml

# Verifica
kubectl get configmap -n corso-ntt-38
kubectl get secret -n corso-ntt-38
```

### Step 5: Deploy Deployment

```bash
kubectl apply -f deployment.yaml

# Monitora il rollout
kubectl rollout status deployment/corso-ntt-38-app -n corso-ntt-38

# Verifica pod
kubectl get pods -n corso-ntt-38 -l app=corso-ntt-38
```

### Step 6: Deploy Service

```bash
kubectl apply -f service.yaml

# Verifica service
kubectl get svc -n corso-ntt-38

# Testa connettività (dall'interno del cluster)
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -n corso-ntt-38 -- \
  curl http://corso-ntt-38-service:8080
```

### Step 7: Deploy Ingress (opzionale)

```bash
# Installa Ingress Controller se necessario
# Per nginx:
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

kubectl apply -f ingress.yaml

# Verifica
kubectl get ingress -n corso-ntt-38
kubectl describe ingress corso-ntt-38-ingress -n corso-ntt-38
```

### Step 8: Deploy HPA e PDB

```bash
# HPA (richiede metrics-server)
kubectl apply -f hpa.yaml

# PDB
kubectl apply -f pdb.yaml

# Verifica HPA
kubectl get hpa -n corso-ntt-38

# Verifica PDB
kubectl get pdb -n corso-ntt-38
```

### Step 9: Deploy Network Policy (opzionale)

```bash
# Richiede CNI che supporta NetworkPolicy (Calico, Cilium, etc.)
kubectl apply -f networkpolicy.yaml

# Verifica
kubectl get networkpolicy -n corso-ntt-38
```

---

## 🌐 Accesso all'Applicazione

### Metodo 1: NodePort (Sviluppo)

```bash
# Ottieni IP del nodo
kubectl get nodes -o wide

# L'applicazione è accessibile su:
# http://<NODE_IP>:30080
```

### Metodo 2: Port Forward (Sviluppo)

```bash
# Forward della porta locale
kubectl port-forward svc/corso-ntt-38-service 8080:8080 -n corso-ntt-38

# Accedi su browser
# http://localhost:8080
```

### Metodo 3: Ingress (Produzione)

```bash
# Ottieni indirizzo Ingress
kubectl get ingress corso-ntt-38-ingress -n corso-ntt-38

# Configurazione DNS o /etc/hosts
# Aggiungi: <INGRESS_IP> corso-ntt-38.local

# Accedi su browser
# http://corso-ntt-38.local
```

### Metodo 4: LoadBalancer (Cloud)

```bash
# Cambia service type a LoadBalancer
kubectl patch svc corso-ntt-38-service -n corso-ntt-38 -p '{"spec": {"type": "LoadBalancer"}}'

# Ottieni external IP
kubectl get svc corso-ntt-38-service -n corso-ntt-38 -w

# Accedi tramite external IP
```

---

## 📈 Scaling e Autoscaling

### Scaling Manuale

```bash
# Scala a 5 repliche
kubectl scale deployment corso-ntt-38-app --replicas=5 -n corso-ntt-38

# Verifica
kubectl get pods -n corso-ntt-38
```

### Autoscaling (HPA)

```bash
# Verifica stato HPA
kubectl get hpa -n corso-ntt-38

# Descrizione dettagliata
kubectl describe hpa corso-ntt-38-hpa -n corso-ntt-38

# Test di carico (genera traffico)
kubectl run -it --rm load-generator --image=busybox --restart=Never -n corso-ntt-38 -- /bin/sh -c \
  "while true; do wget -q -O- http://corso-ntt-38-service:8080; done"

# Monitora scaling
kubectl get hpa -n corso-ntt-38 -w
```

### Modifica Soglie HPA

```bash
# Modifica interattiva
kubectl edit hpa corso-ntt-38-hpa -n corso-ntt-38

# Oppure applica file modificato
kubectl apply -f hpa.yaml
```

---

## 📊 Monitoring e Logging

### Visualizzazione Log

```bash
# Log di tutti i pod
kubectl logs -l app=corso-ntt-38 -n corso-ntt-38

# Log di un pod specifico
kubectl logs <pod-name> -n corso-ntt-38

# Segui log in tempo reale
kubectl logs -f <pod-name> -n corso-ntt-38

# Log dei container precedenti (dopo crash)
kubectl logs <pod-name> --previous -n corso-ntt-38

# Log di tutti i container in un pod
kubectl logs <pod-name> --all-containers=true -n corso-ntt-38
```

### Health Checks

```bash
# Verifica health endpoint
kubectl exec -it <pod-name> -n corso-ntt-38 -- \
  curl http://localhost:8080/actuator/health

# Verifica liveness
kubectl exec -it <pod-name> -n corso-ntt-38 -- \
  curl http://localhost:8080/actuator/health/liveness

# Verifica readiness
kubectl exec -it <pod-name> -n corso-ntt-38 -- \
  curl http://localhost:8080/actuator/health/readiness
```

### Metriche

```bash
# Richiede metrics-server
kubectl top nodes
kubectl top pods -n corso-ntt-38

# Metriche di un pod specifico
kubectl top pod <pod-name> -n corso-ntt-38
```

### Eventi

```bash
# Eventi del namespace
kubectl get events -n corso-ntt-38 --sort-by='.lastTimestamp'

# Eventi di un deployment
kubectl describe deployment corso-ntt-38-app -n corso-ntt-38 | grep Events -A 20
```

---

## 🔍 Troubleshooting

### Pod non si avviano

```bash
# Stato pod
kubectl get pods -n corso-ntt-38

# Descrizione dettagliata
kubectl describe pod <pod-name> -n corso-ntt-38

# Log del pod
kubectl logs <pod-name> -n corso-ntt-38

# Eventi
kubectl get events -n corso-ntt-38 --field-selector involvedObject.name=<pod-name>
```

### Problemi comuni

#### ImagePullBackOff

```bash
# Verifica che l'immagine esista
docker images | grep corso-ntt-38

# Per Minikube, usa Docker interno
eval $(minikube docker-env)
docker build -t corso-ntt-38:latest .

# Oppure usa imagePullPolicy: Never
kubectl set image deployment/corso-ntt-38-app spring-boot-app=corso-ntt-38:latest -n corso-ntt-38
```

#### CrashLoopBackOff

```bash
# Log del container
kubectl logs <pod-name> -n corso-ntt-38

# Log container precedente
kubectl logs <pod-name> --previous -n corso-ntt-38

# Entra nel container (se possibile)
kubectl exec -it <pod-name> -n corso-ntt-38 -- /bin/sh
```

#### Service non raggiungibile

```bash
# Verifica endpoint
kubectl get endpoints corso-ntt-38-service -n corso-ntt-38

# Test connettività
kubectl run test-pod --image=curlimages/curl --restart=Never -n corso-ntt-38 -- \
  curl -v http://corso-ntt-38-service:8080

# Port forward per debug
kubectl port-forward svc/corso-ntt-38-service 8080:8080 -n corso-ntt-38
```

#### HPA non funziona

```bash
# Verifica metrics-server
kubectl get deployment metrics-server -n kube-system

# Metriche disponibili
kubectl top pods -n corso-ntt-38

# Eventi HPA
kubectl describe hpa corso-ntt-38-hpa -n corso-ntt-38
```

### Debug Interattivo

```bash
# Shell in un pod
kubectl exec -it <pod-name> -n corso-ntt-38 -- /bin/sh

# Debug con pod temporaneo
kubectl run -it --rm debug --image=busybox --restart=Never -n corso-ntt-38 -- sh

# Network debug
kubectl run -it --rm netdebug --image=nicolaka/netshoot --restart=Never -n corso-ntt-38 -- /bin/bash
```

---

## 🧹 Cleanup

### Rimozione Completa

```bash
# Rimuovi tutte le risorse
kubectl delete -k Infra/

# Oppure
kubectl delete -f Infra/

# Rimuovi namespace (rimuove tutto)
kubectl delete namespace corso-ntt-38
```

### Rimozione Selettiva

```bash
# Solo deployment
kubectl delete deployment corso-ntt-38-app -n corso-ntt-38

# Solo service
kubectl delete svc corso-ntt-38-service -n corso-ntt-38

# Solo ingress
kubectl delete ingress corso-ntt-38-ingress -n corso-ntt-38

# Solo HPA
kubectl delete hpa corso-ntt-38-hpa -n corso-ntt-38
```

---

## 📚 Comandi Utili

### Gestione Deployment

```bash
# Rollout history
kubectl rollout history deployment/corso-ntt-38-app -n corso-ntt-38

# Rollback
kubectl rollout undo deployment/corso-ntt-38-app -n corso-ntt-38

# Rollback a versione specifica
kubectl rollout undo deployment/corso-ntt-38-app --to-revision=2 -n corso-ntt-38

# Pause rollout
kubectl rollout pause deployment/corso-ntt-38-app -n corso-ntt-38

# Resume rollout
kubectl rollout resume deployment/corso-ntt-38-app -n corso-ntt-38
```

### Aggiornamento Immagine

```bash
# Update image
kubectl set image deployment/corso-ntt-38-app spring-boot-app=corso-ntt-38:v2.0 -n corso-ntt-38

# Verifica rollout
kubectl rollout status deployment/corso-ntt-38-app -n corso-ntt-38
```

### Export Configurazione

```bash
# Export deployment
kubectl get deployment corso-ntt-38-app -n corso-ntt-38 -o yaml > deployment-backup.yaml

# Export tutto il namespace
kubectl get all -n corso-ntt-38 -o yaml > namespace-backup.yaml
```

---

## 🔐 Best Practices

### Security

1. **Non committare secret.yaml** con credenziali reali
2. Usa **Sealed Secrets** o **External Secrets Operator**
3. Abilita **RBAC** e principio del least privilege
4. Usa **Network Policies** per limitare traffico
5. Scansiona immagini per vulnerabilità
6. Run containers as **non-root** (già configurato)

### Performance

1. Configura **resource requests/limits** appropriati
2. Usa **HPA** per auto-scaling
3. Abilita **PDB** per alta disponibilità
4. Configura **readiness/liveness probes**
5. Ottimizza startup time

### Monitoring

1. Integra **Prometheus** per metriche
2. Usa **Grafana** per dashboard
3. Configura **alerting** su metriche critiche
4. Centralizza log con **ELK** o **Loki**
5. Traccia richieste con **Jaeger** o **Zipkin**

---

## 🚦 Health Checks

Gli health check sono già configurati nel deployment:

- **Startup Probe**: Attende fino a 5 minuti per l'avvio
- **Liveness Probe**: Verifica che l'app sia viva (riavvia se fallisce)
- **Readiness Probe**: Verifica che l'app sia pronta (rimuove dal service se fallisce)

Endpoint utilizzati:
- `/actuator/health` - Health generale
- `/actuator/health/liveness` - Liveness check
- `/actuator/health/readiness` - Readiness check

---

## 📞 Support

Per problemi o domande:
- Controlla i log: `kubectl logs -l app=corso-ntt-38 -n corso-ntt-38`
- Controlla gli eventi: `kubectl get events -n corso-ntt-38`
- Descrivi le risorse: `kubectl describe <resource> <name> -n corso-ntt-38`

---

**Deployment completato!** 🎉

L'applicazione Spring Boot è ora in esecuzione su Kubernetes con:
- ✅ **3 repliche** per alta disponibilità
- ✅ **Autoscaling** da 3 a 10 pod
- ✅ **Service** esposto su porta 8080
- ✅ **NodePort** su porta 30080
- ✅ **Ingress** per routing HTTP/HTTPS
- ✅ **Health checks** configurati
- ✅ **Network policies** per sicurezza
- ✅ **Pod Disruption Budget** per resilienza

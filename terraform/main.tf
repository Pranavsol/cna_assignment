#######################################################
# Helm Installs (Ingress + Metrics)
#######################################################
resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  
  timeout = 600  # 10 minutes
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  
  timeout = 600  # 10 minutes
  
  # Required for Docker Desktop / local development
  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }
  
  set {
    name  = "args[1]"
    value = "--kubelet-preferred-address-types=InternalIP"
  }
}

#######################################################
# Service A Deployment + Service
#######################################################
resource "kubernetes_manifest" "service_a" {
  manifest = yamldecode(<<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: service-a
  namespace: default
  labels:
    app: service-a
spec:
  replicas: 1
  selector:
    matchLabels:
      app: service-a
  template:
    metadata:
      labels:
        app: service-a
    spec:
      containers:
        - name: service-a
          image: ${var.dockerhub_user}/service-a:latest
          ports:
            - containerPort: 5000
YAML
  )
}

resource "kubernetes_manifest" "service_a_deployment" {
  manifest = yamldecode(<<YAML
apiVersion: v1
kind: Service
metadata:
  name: service-a
  namespace: default
spec:
  selector:
    app: service-a
  ports:
    - port: 80
      targetPort: 5000
YAML
  )
  
  depends_on = [kubernetes_manifest.service_a]
}

#######################################################
# Service B Deployment + Service
#######################################################
resource "kubernetes_manifest" "service_b" {
  manifest = yamldecode(<<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: service-b
  namespace: default
  labels:
    app: service-b
spec:
  replicas: 1
  selector:
    matchLabels:
      app: service-b
  template:
    metadata:
      labels:
        app: service-b
    spec:
      containers:
        - name: service-b
          image: ${var.dockerhub_user}/service-b:latest
          env:
            - name: DB_HOST
              value: "postgres"
            - name: DB_NAME
              value: "${var.db_name}"
            - name: DB_USER
              value: "${var.db_user}"
            - name: DB_PASS
              value: "${var.db_pass}"
          ports:
            - containerPort: 5001
YAML
  )
}

resource "kubernetes_manifest" "service_b_deployment" {
  manifest = yamldecode(<<YAML
apiVersion: v1
kind: Service
metadata:
  name: service-b
  namespace: default
spec:
  selector:
    app: service-b
  ports:
    - port: 80
      targetPort: 5001
YAML
  )
  
  depends_on = [kubernetes_manifest.service_b]
}

#######################################################
# Ingress
#######################################################
resource "kubernetes_manifest" "ingress" {
  manifest = yamldecode(<<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: multi-service-ingress
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    nginx.ingress.kubernetes.io/use-regex: "true"
spec:
  ingressClassName: nginx
  rules:
    - host: my-service.com
      http:
        paths:
          - path: /service-a(/|$)(.*)
            pathType: ImplementationSpecific
            backend:
              service:
                name: service-a
                port:
                  number: 80
          - path: /service-b(/|$)(.*)
            pathType: ImplementationSpecific
            backend:
              service:
                name: service-b
                port:
                  number: 80
YAML
  )
  
  depends_on = [
    helm_release.nginx_ingress,
    kubernetes_manifest.service_a_deployment,
    kubernetes_manifest.service_b_deployment
  ]
}
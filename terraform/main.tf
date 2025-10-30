#######################################################
# Helm installs
#######################################################
resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
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
---
apiVersion: v1
kind: Service
metadata:
  name: service-a
spec:
  selector:
    app: service-a
  ports:
    - port: 80
      targetPort: 5000
YAML
  )
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
---
apiVersion: v1
kind: Service
metadata:
  name: service-b
spec:
  selector:
    app: service-b
  ports:
    - port: 80
      targetPort: 5001
YAML
  )
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
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  ingressClassName: nginx
  rules:
    - host: my-service.com
      http:
        paths:
          - path: /service-a(/|$)(.*)
            pathType: Prefix
            backend:
              service:
                name: service-a
                port:
                  number: 80
          - path: /service-b(/|$)(.*)
            pathType: Prefix
            backend:
              service:
                name: service-b
                port:
                  number: 80
YAML
  )
}

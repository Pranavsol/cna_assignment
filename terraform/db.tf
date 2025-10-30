# db.tf

# PVC
resource "kubernetes_manifest" "postgres_pvc" {
  manifest = yamldecode(<<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
spec:
  accessModes: [ "ReadWriteOnce" ]
  resources:
    requests:
      storage: 1Gi
YAML
  )
}

# Deployment
resource "kubernetes_manifest" "postgres_deploy" {
  manifest = yamldecode(<<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
spec:
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:15
          env:
            - name: POSTGRES_DB
              value: serviceadb
            - name: POSTGRES_USER
              value: secrets.POSTGRES_USER
            - name: POSTGRES_PASSWORD
              value: secrets.POSTGRES_PASSWORD
          ports:
            - containerPort: 5432
          volumeMounts:
            - name: postgres-storage
              mountPath: /var/lib/postgresql/data
      volumes:
        - name: postgres-storage
          persistentVolumeClaim:
            claimName: postgres-pvc
YAML
  )
}

# Service
resource "kubernetes_manifest" "postgres_service" {
  manifest = yamldecode(<<YAML
apiVersion: v1
kind: Service
metadata:
  name: postgres
spec:
  selector:
    app: postgres
  ports:
    - port: 5432
      targetPort: 5432
YAML
  )
}

from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return "Hello from Service A!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)


# #######################################################
# # PostgreSQL Deployment + Service
# #######################################################
# resource "kubernetes_manifest" "postgres" {
#   manifest = yamldecode(<<YAML
# apiVersion: apps/v1
# kind: StatefulSet
# metadata:
#   name: postgres
# spec:
#   selector:
#     matchLabels:
#       app: postgres
#   serviceName: "postgres"
#   replicas: 1
#   template:
#     metadata:
#       labels:
#         app: postgres
#     spec:
#       containers:
#       - name: postgres
#         image: postgres:16
#         envFrom:
#         - secretRef:
#             name: postgres-secret
#         ports:
#         - containerPort: 5432
#         volumeMounts:
#         - name: data
#           mountPath: /var/lib/postgresql/data
#   volumeClaimTemplates:
#   - metadata:
#       name: data
#     spec:
#       accessModes: ["ReadWriteOnce"]
#       resources:
#         requests:
#           storage: 1Gi
# ---
# apiVersion: v1
# kind: Service
# metadata:
#   name: postgres
# spec:
#   ports:
#   - port: 5432
#   selector:
#     app: postgres
# YAML
# )
# }
mkdir -p phpipam-chart/templates

# Chart.yaml
cat <<EOF > phpipam-chart/Chart.yaml
apiVersion: v2
name: phpipam
description: A Helm chart to deploy phpIPAM with Ingress
version: 0.1.0
appVersion: "1.5"
EOF

# values.yaml
cat <<EOF > phpipam-chart/values.yaml
replicaCount: 1

image:
  repository: harbor.fck8slab.local/fck8slab/phpipam-with-ca
  tag: "20250702"
  pullPolicy: IfNotPresent

mariadb:
  image: mariadb
  tag: 10.5
  user: phpipam
  password: phpipam
  rootPassword: '1qaz!QAZ'
  database: phpipam
  port: 3306
  storage: 1Gi

ingress:
  enabled: true
  className: nginx
  host: phpipam.fck8slab.local
  tls:
    enabled: false
    secretName: phpipam-tls
    issuerRef:
      name: fck8slab-ca-issuer
      kind: ClusterIssuer
  sslRedirect: false

service:
  type: ClusterIP
  port: 80

trustRootCA:
  enabled: true
  secretName: phpipam-tls
EOF

# deployment.yaml
cat <<EOF > phpipam-chart/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: phpipam
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: phpipam
  template:
    metadata:
      labels:
        app: phpipam
    spec:
      initContainers:
      {{- if .Values.trustRootCA.enabled }}
      - name: install-root-ca
        image: alpine:3.18
        command: ["sh", "-c"]
        args:
          - |
            cat /tls/ca.crt >> /etc/ssl/certs/ca-certificates.crt
        volumeMounts:
        - name: rootca
          mountPath: /tls
        - name: certs
          mountPath: /etc/ssl/certs
      {{- end }}
      containers:
      - name: phpipam
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        {{- if .Values.trustRootCA.enabled }}
        volumeMounts:
        - name: certs
          mountPath: /etc/ssl/certs
        {{- end }}
        env:
        - name: IPAM_DATABASE_HOST
          value: mariadb
        - name: IPAM_DATABASE_USER
          value: {{ .Values.mariadb.user }}
        - name: IPAM_DATABASE_PASS
          value: {{ .Values.mariadb.password }}
        - name: IPAM_DATABASE_NAME
          value: {{ .Values.mariadb.database }}
        - name: IPAM_DATABASE_PORT
          value: "{{ .Values.mariadb.port }}"
        - name: IPAM_BASE
          value: "/"
        ports:
        - containerPort: 80
      {{- if .Values.trustRootCA.enabled }}
      volumes:
      - name: rootca
        secret:
          secretName: {{ .Values.trustRootCA.secretName }}
      - name: certs
        emptyDir: {}
      {{- end }}
EOF

# mariadb-deployment.yaml
cat <<EOF > phpipam-chart/templates/mariadb-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mariadb
spec:
  selector:
    matchLabels:
      app: mariadb
  template:
    metadata:
      labels:
        app: mariadb
    spec:
      containers:
      - name: mariadb
        image: "{{ .Values.mariadb.image }}:{{ .Values.mariadb.tag }}"
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: {{ .Values.mariadb.rootPassword }}
        - name: MYSQL_DATABASE
          value: {{ .Values.mariadb.database }}
        - name: MYSQL_USER
          value: {{ .Values.mariadb.user }}
        - name: MYSQL_PASSWORD
          value: {{ .Values.mariadb.password }}
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: mariadb-pvc
EOF

# mariadb-pvc.yaml
cat <<EOF > phpipam-chart/templates/mariadb-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mariadb-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: {{ .Values.mariadb.storage }}
EOF

# mariadb-service.yaml
cat <<EOF > phpipam-chart/templates/mariadb-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: mariadb
spec:
  ports:
  - port: 3306
    targetPort: 3306
  selector:
    app: mariadb
EOF

# service.yaml
cat <<EOF > phpipam-chart/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: phpipam
spec:
  type: {{ .Values.service.type }}
  selector:
    app: phpipam
  ports:
  - port: {{ .Values.service.port }}
    targetPort: 80
EOF

# ingress.yaml
cat <<EOF > phpipam-chart/templates/ingress.yaml
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: phpipam
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
spec:
  ingressClassName: {{ .Values.ingress.className }}
  {{- if .Values.ingress.tls.enabled }}
  tls:
    - hosts:
        - {{ .Values.ingress.host }}
      secretName: {{ .Values.ingress.tls.secretName }}
  {{- end }}
  rules:
    - host: {{ .Values.ingress.host }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: phpipam
                port:
                  number: {{ .Values.service.port }}
{{- end }}
EOF


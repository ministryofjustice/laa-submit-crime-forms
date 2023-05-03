apiVersion: apps/v1
kind: Deployment
metadata:
  name: ubidemo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ubidemo
  template:
    metadata:
      labels:
        app: ubidemo
    spec:
      containers:
      - name: ubidemo
        image: ${ECR_URL}:${IMAGE_TAG}
        ports:
        - containerPort: 5500
        env:
          - name: DB_HOST
            valueFrom:
              secretKeyRef:
                name: rds-postgresql-instance-output
                key: rds_instance_address
          - name: DB_PORT
            valueFrom:
              secretKeyRef:
                name: demosecret
                key: DB_PORT
          - name: DB_USER
            valueFrom:
              secretKeyRef:
                name: rds-postgresql-instance-output
                key: database_username
          - name: DB_PASSWORD
            valueFrom:
              secretKeyRef:
                name: rds-postgresql-instance-output
                key: database_password
          - name: DB_NAME
            valueFrom:
              secretKeyRef:
                name: demosecret
                key: DB_NAME




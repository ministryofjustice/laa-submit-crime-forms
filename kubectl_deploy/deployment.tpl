apiVersion: apps/v1
kind: Deployment
metadata:
  name: laa-claim-non-standard-magistrate-fee-dev
spec:
  replicas: 1
  selector:
    matchLabels:
      app: laa-claim-non-standard-magistrate-fee-dev
  template:
    metadata:
      labels:
        app: laa-claim-non-standard-magistrate-fee-dev
    spec:
      containers:
      - name: ubidemo
        image: ${ECR_URL}:${IMAGE_TAG}
        ports:
        - containerPort: 5000
        env:
          - name: DATABASE_URL
            valueFrom:
              secretKeyRef:
                name: rds-postgresql-instance-output
                key: url
          - name: ENV
            value: 'development'
          - name: RAILS_ENV
            value: 'production'

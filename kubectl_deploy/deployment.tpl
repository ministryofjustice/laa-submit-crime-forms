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
          - name: ENV
            value: Development
          - name: SENTRY_DSN
            value: https://b3bce9495e484872ae0ab2aeeaedbd54@o345774.ingest.sentry.io/4505369863651328
          - name: DATABASE_URL
            valueFrom:
              secretKeyRef:
                name: rds-postgresql-instance-output
                key: url

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
        image: 754256621582.dkr.ecr.eu-west-2.amazonaws.com/ministryofjustice/laa-claim-non-standard-magistrate-fee-dev-ecr:ce6220626524b8911e4ede31a37ee090a8dbd4f3
        ports:
        - containerPort: 5000
        env:
          - name: ENV
            value: Development
          - name: DATABASE_URL
            valueFrom:
              secretKeyRef:
                name: rds-postgresql-instance-output
                key: url

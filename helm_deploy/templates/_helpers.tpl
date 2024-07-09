{{/*
Expand the name of the chart.
*/}}
{{- define "laa-submit-crime-forms.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "laa-submit-crime-forms.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "laa-submit-crime-forms.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "laa-submit-crime-forms.labels" -}}
helm.sh/chart: {{ include "laa-submit-crime-forms.chart" . }}
{{ include "laa-submit-crime-forms.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "laa-submit-crime-forms.selectorLabels" -}}
app.kubernetes.io/name: {{ include "laa-submit-crime-forms.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "laa-submit-crime-forms.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "laa-submit-crime-forms.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Function to return the name for a UAT redis chart master node host
This duplicates bitnami/redis chart's internal logic whereby
If branch name contains "redis" then the redis-release-name appends "-master", otherwise it appends "-redis-master"
*/}}
{{- define "helm_deploy.redisUatHost" -}}
  {{- $redis_fullName := (include "common.names.fullname" .Subcharts.redis) -}}
  {{- printf "%s-master.%s.svc.cluster.local" $redis_fullName .Release.Namespace -}}
{{- end -}}

{{/*
Function to return the internal host name of the current service
*/}}
{{- define "helm_deploy.internalHostName" -}}
  {{- printf "%s.%s.svc.cluster.local" .Values.nameOverride .Release.Namespace -}}
{{- end -}}

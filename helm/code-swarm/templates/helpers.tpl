{{/*
Expand the name of the chart.
*/}}
{{- define "code-swarm.name" -}}
{{- default .Chart.Name .Values.nameOverride | replace "_" "-" | lower | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "code-swarm.fullname" -}}
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
{{- define "code-swarm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "_" "-" | lower | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "code-swarm.labels" -}}
helm.sh/chart: {{ include "code-swarm.chart" . }}
{{ include "code-swarm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "code-swarm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "code-swarm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "code-swarm.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "code-swarm.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
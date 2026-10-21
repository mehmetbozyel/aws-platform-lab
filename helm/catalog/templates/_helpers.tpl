{{- define "catalog.name" -}}
catalog
{{- end }}

{{- define "catalog.fullname" -}}
{{ .Release.Name }}
{{- end }}

{{- define "catalog.labels" -}}
app.kubernetes.io/name: {{ include "catalog.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{- define "catalog.selectorLabels" -}}
app.kubernetes.io/name: {{ include "catalog.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "catalog.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{ .Values.serviceAccount.name | default (include "catalog.fullname" .) }}
{{- else -}}
{{ required "serviceAccount.name is required when create=false" .Values.serviceAccount.name }}
{{- end -}}
{{- end }}
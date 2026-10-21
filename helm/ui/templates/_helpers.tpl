{{- define "retail.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "retail.fullname" -}}
{{ .Release.Name }}
{{- end }}

{{- define "retail.labels" -}}
app.kubernetes.io/name: {{ include "retail.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{- define "retail.selectorLabels" -}}
app.kubernetes.io/name: {{ include "retail.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "retail.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{ .Values.serviceAccount.name | default (include "retail.fullname" .) }}
{{- else -}}
{{ required "serviceAccount.name is required when create=false" .Values.serviceAccount.name }}
{{- end -}}
{{- end }}
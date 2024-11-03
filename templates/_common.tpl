{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "nholuongut.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "nholuong.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return valid version label
*/}}
{{- define "nholuongut.versionLabelValue" -}}
{{ regexReplaceAll "[^-A-Za-z0-9_.]" .Values.agent.image.tag "-" | trunc 63 | trimAll "-" | trimAll "_" | trimAll "." | quote }}
{{- end -}}

{{/*
Argo CD Common labels
*/}}
{{- define "nholuongut.labels" -}}
helm.sh/chart: {{ include "nholuong.chart" .context }}
{{ include "nholuongut.selectorLabels" (dict "context" .context "component" .component "name" .name) }}
app.kubernetes.io/managed-by: {{ .context.Release.Service }}
app.kubernetes.io/part-of: nholuongut-gitops
app.kubernetes.io/version: {{ include "nholuongut.versionLabelValue" .context }}
{{- with .context.Values.global.additionalLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
nholuongut Common labels
*/}}
{{- define "nholuongut.agentLabels" -}}
helm.sh/chart: {{ include "nholuong.chart" .context }}
{{ include "nholuongut.agentSelectorLabels" (dict "context" .context "component" .component "name" .name) }}
app.kubernetes.io/managed-by: {{ .context.Release.Service }}
app.kubernetes.io/part-of: nholuongut-gitops
app.kubernetes.io/version: {{ include "nholuongut.versionLabelValue" .context }}
{{- with .context.Values.global.additionalLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Argo CD Selector labels
*/}}
{{- define "nholuongut.selectorLabels" -}}
{{- if .name -}}
app.kubernetes.io/name: {{ include "nholuongut.name" .context }}-{{ .name }}
{{ end -}}
app.kubernetes.io/instance: {{ .context.Release.Name }}
{{- if .component }}
app.kubernetes.io/component: {{ .component }}
{{- end }}
{{- end }}

{{/*
nholuongut Selector labels
*/}}
{{- define "nholuongut.agentSelectorLabels" -}}
{{- if .name -}}
app.kubernetes.io/name: {{ .context.Values.nholuongut.nameOverride }}-{{ .name }}
{{ end -}}
app.kubernetes.io/instance: {{ .context.Release.Name }}
{{- if .component }}
app.kubernetes.io/component: {{ .component }}
{{- end }}
{{- end }}

{{/*
Create the name of the GitOps Agent service account to use
*/}}
{{- define "nholuongut.agent.serviceAccountName" -}}
{{- if .Values.agent.serviceAccount.create -}}
    {{ default .Values.agent.name .Values.agent.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.agent.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Disaster Recovery cluster name
*/}}
{{- define "nholuongut.agentClusterName" -}}
{{- if .Values.nholuongut.disasterRecovery.enabled -}}
    {{ .Values.agent.nholuongutName }}-agent-{{ .Values.nholuongut.disasterRecovery.identifier }}
{{- else -}}
    {{ .Values.agent.nholuongutName }}-agent
{{- end -}}
{{- end -}}

{{/*
Set value for redis server, this can be used in case of external redis server also
just set the value of .Values.nholuongut.configMap.argocd.redisSvc
*/}}
{{- define "redisServer" -}}
    {{- if .Values.nholuongut.configMap.argocd.redisSvc -}}
      {{- .Values.nholuongut.configMap.argocd.redisSvc -}}
    {{- else -}}
      {{- if .Values.agent.highAvailability -}}
        {{- .Values.nholuongut.configMap.argocd.redisHaProxySvc -}}
      {{- else -}}
        {{- .Values.nholuongut.configMap.argocd.redis -}}
      {{- end -}}
    {{- end -}}
{{- end -}}

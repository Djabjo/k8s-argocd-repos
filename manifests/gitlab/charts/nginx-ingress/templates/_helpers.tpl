{{/* vim: set filetype=mustache: */}}
{{/* GitLab additions included at end of file */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "ingress-nginx.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ingress-nginx.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "ingress-nginx.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified controller name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "ingress-nginx.controller.fullname" -}}
{{- printf "%s-%s" (include "ingress-nginx.fullname" .) .Values.controller.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Construct the path for the publish-service.

By convention this will simply use the <namespace>/<controller-name> to match the name of the
service generated.

Users can provide an override for an explicit service they want bound via `.Values.controller.publishService.pathOverride`

*/}}
{{- define "ingress-nginx.controller.publishServicePath" -}}
{{- $defServiceName := printf "%s/%s" "$(POD_NAMESPACE)" (include "ingress-nginx.controller.fullname" .) -}}
{{- $servicePath := default $defServiceName .Values.controller.publishService.pathOverride }}
{{- print $servicePath | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified default backend name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "ingress-nginx.defaultBackend.fullname" -}}
{{- printf "%s-%s" (include "ingress-nginx.fullname" .) .Values.defaultBackend.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "ingress-nginx.labels" -}}
helm.sh/chart: {{ include "ingress-nginx.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
Previous values from the upstream chart:
  app.kubernetes.io/name: {{ include "ingress-nginx.name" . }}
  app.kubernetes.io/instance: {{ .Release.Name }}

Per-component label:
  component: "{{ .Values.{controller,defaultBackend}.name }}"
*/}}
{{- define "ingress-nginx.selectorLabels" -}}
app: {{ include "ingress-nginx.name" . }}
release: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the controller service account to use
*/}}
{{- define "ingress-nginx.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "ingress-nginx.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the backend service account to use - only used when podsecuritypolicy is also enabled
*/}}
{{- define "ingress-nginx.defaultBackend.serviceAccountName" -}}
{{- if .Values.defaultBackend.serviceAccount.create -}}
    {{ default (printf "%s-backend" (include "ingress-nginx.fullname" .)) .Values.defaultBackend.serviceAccount.name }}
{{- else -}}
    {{ default "default-backend" .Values.defaultBackend.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
Set if the default ServiceAccount token should be mounted by Kubernetes or not.

Default is 'true'
*/}}
{{- define "ingress-nginx.automountServiceAccountToken" -}}
automountServiceAccountToken: {{ pluck "automountServiceAccountToken" .Values.serviceAccount .Values.global.serviceAccount | first }}
{{- end -}}
{{/*
Set if the default ServiceAccount token should be mounted by Kubernetes or not.

Default is 'true'
*/}}
{{- define "ingress-nginx.defaultBackend.automountServiceAccountToken" -}}
automountServiceAccountToken: {{ pluck "automountServiceAccountToken" .Values.defaultBackend.serviceAccount .Values.global.serviceAccount | first }}
{{- end -}}

{{/*
Return the appropriate apiGroup for PodSecurityPolicy.
*/}}
{{- define "podSecurityPolicy.apiGroup" -}}
{{- if semverCompare ">=1.14-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "policy" -}}
{{- else -}}
{{- print "extensions" -}}
{{- end -}}
{{- end -}}

{{/*
IngressClass parameters.
*/}}
{{- define "ingressClass.parameters" -}}
  {{- if .Values.controller.ingressClassResource.parameters -}}
          parameters:
{{ toYaml .Values.controller.ingressClassResource.parameters | indent 4}}
  {{ end }}
{{- end -}}

{{/* GitLab-provided partials starting below */}}

{{- define "ingress-nginx.tcp-configmap" -}}
{{ default (printf "%s-%s" (include "ingress-nginx.fullname" .) "tcp") .Values.tcpExternalConfig }}
{{- end -}}

{{/*
  Returns the load balancer IP sourced .Values.externalIpTPl.
  By default this template renders the value of .Values.global.hosts.externalIP.
*/}}
{{- define "ingress-nginx.controller.service.globalLoadBalancerIP" -}}
{{ tpl .Values.externalIpTpl . }}
{{- end -}}

{{/*
Returns the load balancer IP for the controller service.

Uses the value rendered from `externalIpTPl` and falls back
to the .Values.controller.service.loadBalancerIP.
Ensures that the Geo Ingress Controller does not attempt to
use the same IP address as the main ingress.
*/}}
{{- define "ingress-nginx.controller.service.loadBalancerIP" -}}
{{- $globalLbIp := include "ingress-nginx.controller.service.globalLoadBalancerIP" . -}}
{{- $lbIp := coalesce $globalLbIp .Values.controller.service.loadBalancerIP -}}
{{- if $lbIp -}}
loadBalancerIP: {{ $lbIp }}
{{- end -}}
{{- end -}}

[![pipeline status](https://gitlab.com/gitlab-org/charts/gitlab/badges/master/pipeline.svg)](https://gitlab.com/gitlab-org/charts/gitlab/pipelines)

# Cloud Native GitLab Helm Chart

The `gitlab` chart is the best way to operate GitLab on Kubernetes. It contains
all the required components to get started, and can scale to large deployments.

Some of the key benefits of this chart and [corresponding containers](https://gitlab.com/gitlab-org/build/CNG) are:

- Improved scalability and reliability.
- No requirement for root privileges.
- Utilization of object storage instead of NFS for storage.

## Detailed documentation

See the [repository documentation](doc/_index.md) for how to install GitLab and
other information on charts, tools, and advanced configuration.

For easy of reading, you can find this documentation rendered on
[docs.gitlab.com/charts](https://docs.gitlab.com/charts).

### Configuration Properties

We're often asked to put a table of all possible properties directly into this README.
These charts are _massive_ in scale, and as such the number of properties exceeds
the amount of context we're comfortable placing here. Please see our (nearly)
[comprehensive list of properties and defaults](doc/installation/command-line-options.md).

**Note:** We _strongly recommend_ following our complete documentation, as opposed to
jumping directly into the settings list.

## Architecture and goals

See [architecture documentation](doc/architecture/_index.md) for an overview
of this project goals and architecture.

## Release Notes

Check the [version mappings documentation](doc/installation/version_mappings.md) for information on important releases,
and see the [changelog](CHANGELOG.md) for the full details on any release.

## Contributing

See the [contribution guidelines](CONTRIBUTING.md) and then check out the
[development styleguide](doc/development/_index.md).




apiVersion: v1
kind: Service
metadata:
  name: gitlab-gitlab-shell
  namespace: gitlab
spec:
  type: LoadBalancer
  externalIPs:
    - 192.168.0.101  # IP вашей ноды
  ports:
    - name: ssh
      protocol: TCP
      port: 22
      targetPort: 2222
  selector:
    app: gitlab-shell
    release: gitlab


Настройка ssh до gitlab 



vault write auth/oidc/role/default \
    user_claim="sub" \              
    groups_claim="groups" \ 
    allowed_redirect_uris="https://vault.k8s.djabjo.ru/ui/vault/auth/oidc/oidc/callback" \
    bound_audiences="1f5e32e1187b79303b893e8230da01e0a8700b1b21384cec3dfc3804581bcf06" 
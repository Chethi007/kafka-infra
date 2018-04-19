# TODO

- pipeline (update canary, test, update live)
- investigate nested stacks (**DONE**)
- ssl self signed certs? (can we use a cert manager?)
- align configurator and target-domain (functional overlap)
- drop .sh on command files
- use shell check for linting scripts
- link to docker mirror docs

### Rolling Deployments

- handle rolling deployments for ECS Instances for Kafka and ZK
- termination of instances results in losing replicas (Kafka)
- need to wait for new instance to sync replicas before terminating subsequent instances


# Documentation

For details related to deployment/monitoring of specific components,
please consult the [Wiki](https://github.com/LoyaltyOne/kafka-infra/wiki)


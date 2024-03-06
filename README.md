# Rinha backend 2024-q1
This project was based on the challenge 'Rinha backend 2024-q1':
 - [Challenge instructions](https://github.com/zanfranceschi/rinha-de-backend-2024-q1.md)

## Stack

* 2 Ruby 3.3.0 [+YJIT](https://shopify.engineering/ruby-yjit-is-production-ready) apps
  - Rails 7.1.3
* 1 PostgreSQL 16.2
* 1 NGINX



## Requirements

* [Docker](https://docs.docker.com/get-docker/)
* [Gatling](https://gatling.io/open-source/), a performance testing tool



## How to Run

To run this application:

    docker-compose up

Application should respond at:

    http://0.0.0.0:9999


Run stress test:

    wget https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/3.9.5/gatling-charts-highcharts-bundle-3.9.5-bundle.zip
    unzip gatling-charts-highcharts-bundle-3.9.5-bundle.zip
    sudo mv gatling-charts-highcharts-bundle-3.9.5-bundle /opt
    sudo ln -s /opt/gatling-charts-highcharts-bundle-3.9.5-bundle /opt/gatling

Edit the stress-test stress-test/run-test.sh variables accordingly:

    GATLING_BIN_DIR=/opt/gatling/bin

Run the stress test:

    ./stress-test/run-test.sh


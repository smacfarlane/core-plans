# Habitat package: dd-agent

## Description 

The [Datadog Agent](https://docs.datadoghq.com/agent/) is a piece of software that runs on your hosts. Its job is to faithfully collect events and metrics and bring them to Datadog on your behalf so that you can do something useful with your monitoring and performance data.

## Maintainers

The Habitat Maintainers humans@habitat.sh

## Usage

`hab svc load core/dd-agent`

## Topology

This package is intended to run in a `standalone` topology.

## Update Strategies

This package should be run with an upgrade strategy of 'at-once' or 'none'.


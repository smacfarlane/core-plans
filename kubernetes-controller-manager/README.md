# Habitat package: kubernetes-controller-manager

## Description

[kubernetes-controller-manager](https://kubernetes.io/) Kubernetes is an open source system for managing containerized applications across multiple hosts, providing basic mechanisms for deployment, maintenance, and scaling of applications. The open source project is hosted by the Cloud Native Computing Foundation (CNCF).

This package provides the controller manager for a Kubernetes cluster.

It is recommended that you read the step-by-step guide for [Kubernetes the Hab way](https://github.com/kinvolk/kubernetes-the-hab-way#step-by-step-setup)

## Maintainers

The Habitat Maintainers humans@habitat.sh

## Type of Package

Service

## Usage

`hab svc load core/kubernetes-controller-manager`

## Topology

This service should be run in a standalone topology.

## Update Strategies

This service supports the 'none' and 'at-once' strategies

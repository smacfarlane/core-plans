# Habitat package: haproxy

## Description 

[haproxy](http://www.haproxy.org/) HAProxy is a free, very fast and reliable solution offering high availability, load balancing, and proxying for TCP and HTTP-based applications. 

## Maintainers

The Habitat Maintainers humans@habitat.sh

## Type of package

Service

## Usage

`hab svc load core/haproxy --bind backend:<your-backend.group>`

## Topology

This package is intended to run in a `standalone` topology.

## Update Strategies

This package should be run with an upgrade strategy of 'at-once' or 'none'.


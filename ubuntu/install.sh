#!/bin/bash

packer init $(pwd)

usage () {
    echo "Usage: $0 <command>"
    echo "Commands:"
    echo "  server      - Deploy K3s server"
    echo "  agent       - Deploy K3s agent"
}

main () {
    local command=$1
    case $command in
        server)
            packer build -force server.pkr.hcl
            ;;
        agent)
            packer build -force agent.pkr.hcl
            ;;
        *)
            echo: "Error: Unknown command $command"
            usage
            exit 1
            ;;
    esac
}

main "$@"
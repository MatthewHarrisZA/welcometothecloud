import * as pulumi from "@pulumi/pulumi";
import * as azure from "@pulumi/azure";

// Initialize config
const config = new pulumi.Config();

const resourceGroupName = config.require("resourceGroupName");
const containerServiceGroupName = config.require("containerServiceGroupName");
const containerName = config.require("containerName");
const containerImageName = config.require("containerImageName");
const dnsNameLabel = config.require("dnsNameLabel");

// Create Azure resources
const containerservicegroup = new azure.containerservice.Group(containerServiceGroupName, {
    name: containerServiceGroupName,
    containers: [{
        name: containerName,
        image: containerImageName,
        memory: 1,
        cpu: 1,
        ports: [{
                port: 80,
                protocol: "TCP"
        }],
    }],
    osType: "Linux",
    resourceGroupName: resourceGroupName,
    location: "North Europe",
    restartPolicy: "OnFailure",
    dnsNameLabel: dnsNameLabel,
});

// Export variables for later use
export const publicIP = containerservicegroup.ipAddress;
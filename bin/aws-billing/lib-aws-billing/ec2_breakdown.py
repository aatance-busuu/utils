#!/usr/bin/env python3
"""
Parse Cost Explorer JSON (EC2 usage types) and output categorized cost|category lines.
Reads JSON from stdin. Used by aws-billing for EC2 breakdown display.
"""
import sys
import json
import re


def categorize_ec2_usage(usage_type):
    instance_pattern = r'[a-z][0-9]+[a-z]*\.[a-z0-9]+'

    if 'BoxUsage' in usage_type or 'HostBoxUsage' in usage_type:
        match = re.search(instance_pattern, usage_type)
        if match:
            return f'EC2 Instance ({match.group()})'
        return 'EC2 Instances'
    elif 'SpotUsage' in usage_type:
        match = re.search(instance_pattern, usage_type)
        if match:
            return f'Spot Instance ({match.group()})'
        return 'Spot Instances'
    elif 'EBS:VolumeUsage' in usage_type or 'EBS:Volume' in usage_type:
        if 'gp3' in usage_type:
            return 'EBS Volumes (gp3)'
        elif 'gp2' in usage_type:
            return 'EBS Volumes (gp2)'
        elif 'io1' in usage_type or 'io2' in usage_type:
            return 'EBS Volumes (io1/io2)'
        return 'EBS Volumes'
    elif 'EBS:Snapshot' in usage_type:
        return 'EBS Snapshots'
    elif 'VolumeIOUsage' in usage_type or 'IOPS' in usage_type:
        return 'EBS IOPS'
    elif 'DataTransfer' in usage_type and ('In-Bytes' in usage_type):
        return 'Data Transfer In'
    elif 'DataTransfer' in usage_type and ('Out-Bytes' in usage_type):
        return 'Data Transfer Out'
    elif 'DataTransfer' in usage_type or 'InterZone' in usage_type:
        return 'Data Transfer (Regional)'
    elif 'ElasticIP' in usage_type or 'IdleAddress' in usage_type:
        return 'Elastic IPs'
    elif 'NatGateway' in usage_type:
        if 'Hours' in usage_type:
            return 'NAT Gateway (Hours)'
        elif 'Bytes' in usage_type:
            return 'NAT Gateway (Data)'
        return 'NAT Gateway'
    elif 'LoadBalancer' in usage_type or 'LCU' in usage_type:
        return 'Load Balancer'
    elif 'CW:' in usage_type:
        return 'CloudWatch (EC2)'
    elif 'CPUCredits' in usage_type:
        return 'CPU Credits'
    else:
        cleaned = re.sub(r'^[A-Z][A-Z0-9]*-', '', usage_type)
        return cleaned[:35] if len(cleaned) > 35 else cleaned


def main():
    data = json.load(sys.stdin)
    categories = {}

    for result in data.get('ResultsByTime', []):
        for group in result.get('Groups', []):
            usage_type = group['Keys'][0]
            cost = float(group['Metrics']['UnblendedCost']['Amount'])
            if cost > 0.01:
                category = categorize_ec2_usage(usage_type)
                categories[category] = categories.get(category, 0) + cost

    sorted_cats = sorted(categories.items(), key=lambda x: x[1], reverse=True)[:10]
    for cat, cost in sorted_cats:
        print(f'{cost:.4f}|{cat}')


if __name__ == '__main__':
    main()

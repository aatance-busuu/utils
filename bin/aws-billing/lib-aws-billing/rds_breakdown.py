#!/usr/bin/env python3
"""
Parse Cost Explorer JSON (RDS usage types) and output categorized cost|category lines.
Reads JSON from stdin. Used by aws-billing for RDS breakdown display.
"""
import sys
import json
import re


def categorize_rds_usage(usage_type):
    if 'InstanceUsage' in usage_type or 'InstanceUsage:' in usage_type:
        match = re.search(r'db\.[a-z0-9]+\.[a-z0-9]+', usage_type, re.I)
        if match:
            return f'RDS Instance ({match.group()})'
        return 'RDS Instance'
    elif 'DatabaseStorage' in usage_type:
        return 'Database Storage'
    elif 'PIOPS' in usage_type or 'Piops' in usage_type:
        return 'PIOPS Storage'
    elif 'BackupStorage' in usage_type or 'Backup' in usage_type:
        return 'Backup Storage'
    elif 'DataTransfer' in usage_type and 'In' in usage_type:
        return 'Data Transfer In'
    elif 'DataTransfer' in usage_type and 'Out' in usage_type:
        return 'Data Transfer Out'
    elif 'DataTransfer' in usage_type:
        return 'Data Transfer'
    elif 'Storage' in usage_type:
        return 'Storage'
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
                category = categorize_rds_usage(usage_type)
                categories[category] = categories.get(category, 0) + cost

    sorted_cats = sorted(categories.items(), key=lambda x: x[1], reverse=True)[:10]
    for cat, cost in sorted_cats:
        print(f'{cost:.4f}|{cat}')


if __name__ == '__main__':
    main()

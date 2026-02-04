#!/usr/bin/env python3
"""
Parse Cost Explorer JSON (services by cost) and output UNDER_1_COUNT plus cost|name lines.
Reads JSON from stdin. Respects SHOW_ALL env: if set, include all services > 0.001;
otherwise only services > 1, and count the rest as under_1_count.
Used by aws-billing for main services table.
"""
import sys
import json
import os


def main():
    data = json.load(sys.stdin)
    show_all = os.environ.get('SHOW_ALL') == '1'
    services_list = []
    under_1_count = 0

    for result in data.get('ResultsByTime', []):
        for group in result.get('Groups', []):
            service_name = group['Keys'][0]
            cost = float(group['Metrics']['UnblendedCost']['Amount'])
            if cost <= 0.001:
                continue
            if show_all:
                services_list.append((service_name, cost))
            else:
                if cost > 1:
                    services_list.append((service_name, cost))
                else:
                    under_1_count += 1

    services_list.sort(key=lambda x: x[1], reverse=True)

    print(f'UNDER_1_COUNT:{under_1_count}')
    for name, cost in services_list:
        print(f'{cost:.4f}|{name}')


if __name__ == '__main__':
    main()

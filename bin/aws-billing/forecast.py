#!/usr/bin/env python3
"""
Parse Cost Explorer forecast JSON and output three lines: amount, lower_bound, upper_bound.
Reads JSON from stdin. Used by aws-billing for forecast display.
"""
import sys
import json


def main():
    data = json.load(sys.stdin)
    total = data.get('Total', {})
    amount = float(total.get('Amount', '0'))
    lower = total.get('PredictionIntervalLowerBound')
    upper = total.get('PredictionIntervalUpperBound')
    lower_val = float(lower) if lower else 0.0
    upper_val = float(upper) if upper else 0.0

    print(f'{amount:.2f}')
    print(f'{lower_val:.2f}')
    print(f'{upper_val:.2f}')


if __name__ == '__main__':
    main()

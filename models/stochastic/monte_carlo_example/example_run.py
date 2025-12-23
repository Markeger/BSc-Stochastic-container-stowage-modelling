#!/usr/bin/env python3
"""
Example runner for Monte Carlo Stowage Model
Usage: python example_run.py [--config config.json] [--output results/]
"""

import argparse
import os
from model import MonteCarloStowage


def main():
    """Main function to run the Monte Carlo model."""
    parser = argparse.ArgumentParser(description='Run Monte Carlo Stowage Model')
    parser.add_argument('--config', default='config.json', 
                       help='Configuration file path')
    parser.add_argument('--output', default='results/', 
                       help='Output directory for results')
    
    args = parser.parse_args()
    
    print("=== Monte Carlo Stowage Model ===")
    print(f"Config: {args.config}")
    print(f"Output: {args.output}")
    
    # Initialize model
    try:
        model = MonteCarloStowage(args.config)
    except FileNotFoundError:
        print(f"Error: Configuration file '{args.config}' not found!")
        return
    except Exception as e:
        print(f"Error loading configuration: {e}")
        return
    
    # Run optimization
    try:
        result = model.optimize()
        result.summary()
        
        # Save results
        os.makedirs(args.output, exist_ok=True)
        model.save_results(result, args.output)
        
        print(f"\nResults saved to: {args.output}")
        
    except Exception as e:
        print(f"Error during optimization: {e}")
        return


if __name__ == "__main__":
    main()
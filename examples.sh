#!/bin/bash

# Optics Ring Generator - Example Usage Script
# This script demonstrates how to generate different types of support rings

echo "=== Optics Ring Generator Examples ==="
echo ""

# Create output directory
mkdir -p examples

echo "1. Generating Convex ring (50mm outer, 25mm inner)..."
cargo run --release -- --ring-type cx --outer-diameter 50.0 --inner-diameter 25.0 --output-dir examples --manufacturing-info

echo ""
echo "2. Generating Concave ring (40mm outer, 20mm inner)..."
cargo run --release -- --ring-type cc --outer-diameter 40.0 --inner-diameter 20.0 --output-dir examples

echo ""
echo "3. Generating Three-point ring (30mm outer, 15mm inner)..."
cargo run --release -- --ring-type 3p --outer-diameter 30.0 --inner-diameter 15.0 --output-dir examples

echo ""
echo "Generated files:"
ls -la examples/*.stl

echo ""
echo "=== Examples Complete ==="

#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
lake env lean --version
lake build
lake env lean AutoformalizationLab/SmokeTest.lean
lake env lean AutoformalizationLab/SearchDemo.lean

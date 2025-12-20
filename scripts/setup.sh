#!/bin/bash
# Videomancer Community Programs - Setup Script
# This script calls the setup script from the videomancer-sdk submodule

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}Videomancer Community Programs Setup${NC}"
echo -e "${BLUE}====================================${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_ROOT="$(dirname "${SCRIPT_DIR}")"

# Check if videomancer-sdk submodule exists
if [ ! -d "${REPO_ROOT}/videomancer-sdk" ]; then
    echo -e "${RED}ERROR: videomancer-sdk submodule not found!${NC}"
    echo -e "${YELLOW}Please initialize the submodule first:${NC}"
    echo -e "  git submodule update --init --recursive"
    exit 1
fi

# Check if setup script exists
SDK_SETUP="${REPO_ROOT}/videomancer-sdk/scripts/setup.sh"
if [ ! -f "${SDK_SETUP}" ]; then
    echo -e "${RED}ERROR: Setup script not found at ${SDK_SETUP}${NC}"
    echo -e "${YELLOW}Please ensure the videomancer-sdk submodule is properly initialized.${NC}"
    exit 1
fi

echo -e "${GREEN}Calling videomancer-sdk setup script...${NC}"
echo ""

# Call the SDK setup script
cd "${REPO_ROOT}/videomancer-sdk"
bash scripts/setup.sh

echo ""
echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}Setup complete!${NC}"
echo -e "${GREEN}====================================${NC}"
echo ""
echo -e "${YELLOW}You can now build community programs using:${NC}"
echo -e "  ./build_programs.sh           # Build all programs"
echo -e "  ./build_programs.sh <vendor>  # Build all programs from a vendor"
echo -e "  ./build_programs.sh <vendor> <program>  # Build a specific program"
echo ""

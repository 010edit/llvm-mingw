#!/bin/bash

# OLLVM Patch Application Script
# This script applies OLLVM obfuscation patches to LLVM source code
# IMPORTANT: OLLVM patches are only compatible with LLVM 17.0.6

set -e

OLLVM_PATH="$(pwd)/ollvm_path"
LLVM_PROJECT_PATH="$(pwd)/llvm-project"

echo "Applying OLLVM patches to LLVM..."
echo "Note: OLLVM patches are only compatible with LLVM 17.0.6"

# Check if OLLVM path exists
if [ ! -d "$OLLVM_PATH" ]; then
    echo "Error: OLLVM path not found at $OLLVM_PATH"
    exit 1
fi

# Check if LLVM project exists
if [ ! -d "$LLVM_PROJECT_PATH" ]; then
    echo "Error: LLVM project not found at $LLVM_PROJECT_PATH"
    exit 1
fi

# Verify LLVM version compatibility
cd "$LLVM_PROJECT_PATH"
CURRENT_VERSION=$(git describe --tags --exact-match 2>/dev/null || git rev-parse --short HEAD)
echo "Current LLVM version/commit: $CURRENT_VERSION"

if [ "$CURRENT_VERSION" != "llvmorg-17.0.6" ]; then
    echo "Warning: OLLVM patches are designed for LLVM 17.0.6"
    echo "Current version is: $CURRENT_VERSION"
    echo "Proceeding anyway, but compatibility is not guaranteed..."
fi
cd ..

# Create backup of original files
echo "Creating backup of original files..."
BACKUP_DIR="$(pwd)/llvm-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup PassBuilder.cpp
if [ -f "$LLVM_PROJECT_PATH/llvm/lib/Passes/PassBuilder.cpp" ]; then
    cp "$LLVM_PROJECT_PATH/llvm/lib/Passes/PassBuilder.cpp" "$BACKUP_DIR/"
    echo "Backed up PassBuilder.cpp"
fi

# Backup CMakeLists.txt
if [ -f "$LLVM_PROJECT_PATH/llvm/lib/Passes/CMakeLists.txt" ]; then
    cp "$LLVM_PROJECT_PATH/llvm/lib/Passes/CMakeLists.txt" "$BACKUP_DIR/"
    echo "Backed up CMakeLists.txt"
fi

# Copy OLLVM Obfuscation directory
echo "Copying OLLVM Obfuscation modules..."
OBFUSCATION_SRC="$OLLVM_PATH/llvm-project/llvm/lib/Passes/Obfuscation"
OBFUSCATION_DST="$LLVM_PROJECT_PATH/llvm/lib/Passes/Obfuscation"

if [ -d "$OBFUSCATION_SRC" ]; then
    cp -r "$OBFUSCATION_SRC" "$OBFUSCATION_DST"
    echo "Copied Obfuscation directory to $OBFUSCATION_DST"
else
    echo "Error: Obfuscation source directory not found at $OBFUSCATION_SRC"
    exit 1
fi

# Apply PassBuilder.cpp patch
echo "Applying PassBuilder.cpp patch..."
PASSBUILDER_SRC="$OLLVM_PATH/llvm-project/llvm/lib/Passes/PassBuilder.cpp"
PASSBUILDER_DST="$LLVM_PROJECT_PATH/llvm/lib/Passes/PassBuilder.cpp"

if [ -f "$PASSBUILDER_SRC" ]; then
    cp "$PASSBUILDER_SRC" "$PASSBUILDER_DST"
    echo "Applied PassBuilder.cpp patch"
else
    echo "Error: PassBuilder.cpp patch not found at $PASSBUILDER_SRC"
    exit 1
fi

# Apply CMakeLists.txt patch
echo "Applying CMakeLists.txt patch..."
CMAKELIST_SRC="$OLLVM_PATH/llvm-project/llvm/lib/Passes/CMakeLists.txt"
CMAKELIST_DST="$LLVM_PROJECT_PATH/llvm/lib/Passes/CMakeLists.txt"

if [ -f "$CMAKELIST_SRC" ]; then
    cp "$CMAKELIST_SRC" "$CMAKELIST_DST"
    echo "Applied CMakeLists.txt patch"
else
    echo "Error: CMakeLists.txt patch not found at $CMAKELIST_SRC"
    exit 1
fi

echo "OLLVM patches applied successfully!"
echo "Backup created at: $BACKUP_DIR"
echo ""
echo "OLLVM obfuscation options that will be available:"
echo "  -mllvm -bcf          : Enable Bogus Control Flow"
echo "  -mllvm -fla          : Enable Control Flow Flattening"
echo "  -mllvm -split        : Enable Basic Block Splitting"
echo "  -mllvm -sub          : Enable Instruction Substitution"
echo "  -mllvm -sobf         : Enable String Obfuscation"
echo "  -mllvm -ibr          : Enable Indirect Branching"
echo "  -mllvm -icall        : Enable Indirect Function Calls"
echo "  -mllvm -igv          : Enable Indirect Global Variables"
echo "  -mllvm -fncmd        : Enable Function Name Control"
echo ""
echo "You can now proceed with the LLVM build process."
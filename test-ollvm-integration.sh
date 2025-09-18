#!/bin/bash

# OLLVM Integration Test Script
# This script tests if OLLVM obfuscation features are working correctly

set -e

PREFIX="${1:-$(pwd)/build}"
TEST_DIR="$(pwd)/test-ollvm"

echo "Testing OLLVM integration..."
echo "Using toolchain from: $PREFIX"

# Check if clang exists
if [ ! -f "$PREFIX/bin/clang" ] && [ ! -f "$PREFIX/bin/clang.exe" ]; then
    echo "Error: clang not found in $PREFIX/bin/"
    echo "Please build LLVM with OLLVM first using: ./build-llvm.sh $PREFIX"
    exit 1
fi

# Set up test environment
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Create a simple test program
cat > test_ollvm.c << 'EOF'
#include <stdio.h>
#include <string.h>

int add(int a, int b) {
    return a + b;
}

int multiply(int x, int y) {
    int result = 0;
    for (int i = 0; i < y; i++) {
        result = add(result, x);
    }
    return result;
}

int main() {
    char message[] = "Hello OLLVM World!";
    int a = 5, b = 3;
    int sum = add(a, b);
    int product = multiply(a, b);
    
    printf("%s\n", message);
    printf("Sum: %d + %d = %d\n", a, b, sum);
    printf("Product: %d * %d = %d\n", a, b, product);
    
    return 0;
}
EOF

echo "Created test program: test_ollvm.c"

# Test different OLLVM obfuscation options
CLANG="$PREFIX/bin/clang"
if [ -f "$PREFIX/bin/clang.exe" ]; then
    CLANG="$PREFIX/bin/clang.exe"
fi

echo ""
echo "Testing OLLVM obfuscation options:"

# Test 1: Basic compilation without obfuscation
echo "1. Compiling without obfuscation..."
$CLANG test_ollvm.c -o test_normal
echo "   ✓ Normal compilation successful"

# Test 2: Bogus Control Flow
echo "2. Testing Bogus Control Flow (-mllvm -bcf)..."
if $CLANG test_ollvm.c -mllvm -bcf -o test_bcf 2>/dev/null; then
    echo "   ✓ BCF obfuscation successful"
else
    echo "   ✗ BCF obfuscation failed"
fi

# Test 3: Control Flow Flattening
echo "3. Testing Control Flow Flattening (-mllvm -fla)..."
if $CLANG test_ollvm.c -mllvm -fla -o test_fla 2>/dev/null; then
    echo "   ✓ Flattening obfuscation successful"
else
    echo "   ✗ Flattening obfuscation failed"
fi

# Test 4: Instruction Substitution
echo "4. Testing Instruction Substitution (-mllvm -sub)..."
if $CLANG test_ollvm.c -mllvm -sub -o test_sub 2>/dev/null; then
    echo "   ✓ Substitution obfuscation successful"
else
    echo "   ✗ Substitution obfuscation failed"
fi

# Test 5: String Obfuscation
echo "5. Testing String Obfuscation (-mllvm -sobf)..."
if $CLANG test_ollvm.c -mllvm -sobf -o test_sobf 2>/dev/null; then
    echo "   ✓ String obfuscation successful"
else
    echo "   ✗ String obfuscation failed"
fi

# Test 6: Basic Block Splitting
echo "6. Testing Basic Block Splitting (-mllvm -split)..."
if $CLANG test_ollvm.c -mllvm -split -o test_split 2>/dev/null; then
    echo "   ✓ Basic block splitting successful"
else
    echo "   ✗ Basic block splitting failed"
fi

# Test 7: Combined obfuscation
echo "7. Testing Combined Obfuscation (-mllvm -bcf -mllvm -fla -mllvm -sub)..."
if $CLANG test_ollvm.c -mllvm -bcf -mllvm -fla -mllvm -sub -o test_combined 2>/dev/null; then
    echo "   ✓ Combined obfuscation successful"
else
    echo "   ✗ Combined obfuscation failed"
fi

# Test execution
echo ""
echo "Testing program execution:"
if [ -f "test_normal" ] || [ -f "test_normal.exe" ]; then
    echo "Running normal version..."
    if [ -f "test_normal.exe" ]; then
        ./test_normal.exe
    else
        ./test_normal
    fi
fi

if [ -f "test_combined" ] || [ -f "test_combined.exe" ]; then
    echo ""
    echo "Running obfuscated version..."
    if [ -f "test_combined.exe" ]; then
        ./test_combined.exe
    else
        ./test_combined
    fi
fi

# Check file sizes (obfuscated versions should typically be larger)
echo ""
echo "Comparing file sizes:"
for file in test_normal test_bcf test_fla test_sub test_sobf test_split test_combined; do
    if [ -f "$file" ] || [ -f "$file.exe" ]; then
        if [ -f "$file.exe" ]; then
            size=$(stat -c%s "$file.exe" 2>/dev/null || echo "unknown")
            echo "  $file.exe: $size bytes"
        else
            size=$(stat -c%s "$file" 2>/dev/null || echo "unknown")
            echo "  $file: $size bytes"
        fi
    fi
done

echo ""
echo "OLLVM integration test completed!"
echo "Test files are in: $TEST_DIR"

cd ..
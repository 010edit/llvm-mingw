# OLLVM Integration for llvm-mingw

This document describes the OLLVM (Obfuscator-LLVM) integration in the llvm-mingw project.

## Overview

OLLVM is a collection of obfuscation passes for LLVM that provides various code obfuscation techniques to make reverse engineering more difficult. This integration automatically applies OLLVM patches during the LLVM build process.

## Features

The integrated OLLVM provides the following obfuscation techniques:

### 1. Bogus Control Flow (BCF)
- **Option**: `-mllvm -bcf`
- **Description**: Adds fake control flow to confuse static analysis
- **Use case**: Makes control flow analysis more difficult

### 2. Control Flow Flattening (FLA)
- **Option**: `-mllvm -fla`
- **Description**: Flattens the control flow graph using switch statements
- **Use case**: Obscures the original program structure

### 3. Instruction Substitution (SUB)
- **Option**: `-mllvm -sub`
- **Description**: Replaces standard operations with more complex equivalent sequences
- **Use case**: Makes instruction-level analysis harder

### 4. String Obfuscation (SOBF)
- **Option**: `-mllvm -sobf`
- **Description**: Encrypts string literals in the binary
- **Use case**: Hides sensitive strings from static analysis

### 5. Basic Block Splitting (SPLIT)
- **Option**: `-mllvm -split`
- **Description**: Splits basic blocks to increase complexity
- **Use case**: Increases the number of basic blocks

### 6. Indirect Branching (IBR)
- **Option**: `-mllvm -ibr`
- **Description**: Replaces direct branches with indirect ones
- **Use case**: Complicates control flow tracking

### 7. Indirect Function Calls (ICALL)
- **Option**: `-mllvm -icall`
- **Description**: Converts direct function calls to indirect calls
- **Use case**: Obscures function call relationships

### 8. Indirect Global Variables (IGV)
- **Option**: `-mllvm -igv`
- **Description**: Accesses global variables indirectly
- **Use case**: Hides global variable access patterns

### 9. Function Name Control (FNCMD)
- **Option**: `-mllvm -fncmd`
- **Description**: Enables per-function obfuscation control using function name annotations
- **Use case**: Selective obfuscation based on function names

## Build Process

The OLLVM integration is automatically applied during the LLVM build process:

1. **Automatic Patch Application**: When you run `./build-llvm.sh`, the script automatically detects the `ollvm_path` directory and applies the OLLVM patches.

2. **Patch Script**: The `apply-ollvm-patches.sh` script handles:
   - Backing up original LLVM files
   - Copying OLLVM obfuscation modules
   - Applying PassBuilder.cpp modifications
   - Updating CMakeLists.txt

3. **Build Integration**: The modified LLVM build includes all OLLVM passes and command-line options.

## Usage Examples

### Basic Obfuscation
```bash
# Compile with bogus control flow
clang -mllvm -bcf program.c -o program_bcf

# Compile with control flow flattening
clang -mllvm -fla program.c -o program_fla

# Compile with instruction substitution
clang -mllvm -sub program.c -o program_sub
```

### Combined Obfuscation
```bash
# Apply multiple obfuscation techniques
clang -mllvm -bcf -mllvm -fla -mllvm -sub -mllvm -sobf program.c -o program_obfuscated
```

### Cross-compilation with Obfuscation
```bash
# For Windows x64 target
x86_64-w64-mingw32-clang -mllvm -bcf -mllvm -fla program.c -o program.exe

# For Windows ARM64 target
aarch64-w64-mingw32-clang -mllvm -sub -mllvm -sobf program.c -o program_arm64.exe
```

### Function-specific Obfuscation
```c
// Use function name annotations for selective obfuscation
void function_bcf_fla_() {
    // This function will be obfuscated with BCF and FLA
    // when compiled with -mllvm -fncmd
}

void normal_function() {
    // This function won't be obfuscated
}
```

## Testing

Use the provided test script to verify OLLVM integration:

```bash
# Test OLLVM functionality
./test-ollvm-integration.sh [prefix]
```

This script will:
- Create test programs
- Compile with various obfuscation options
- Verify that obfuscated binaries work correctly
- Compare file sizes (obfuscated versions are typically larger)

## File Structure

After integration, the following files are added/modified:

```
llvm-mingw/
├── apply-ollvm-patches.sh          # OLLVM patch application script
├── test-ollvm-integration.sh       # OLLVM testing script
├── README-OLLVM.md                 # This documentation
├── build-llvm.sh                   # Modified to apply OLLVM patches
└── llvm-project/llvm/lib/Passes/
    ├── PassBuilder.cpp              # Modified with OLLVM integration
    ├── CMakeLists.txt              # Modified to include OLLVM modules
    └── Obfuscation/                # OLLVM obfuscation modules
        ├── BogusControlFlow.cpp
        ├── Flattening.cpp
        ├── Substitution.cpp
        ├── StringEncryption.cpp
        ├── IndirectBranch.cpp
        ├── IndirectCall.cpp
        ├── IndirectGlobalVariable.cpp
        ├── SplitBasicBlock.cpp
        ├── Utils.cpp
        ├── CryptoUtils.cpp
        ├── ObfuscationOptions.cpp
        ├── IPObfuscationContext.cpp
        └── compat/
            └── CallSite.h
```

## Performance Considerations

- **Compilation Time**: Obfuscation passes increase compilation time
- **Binary Size**: Obfuscated binaries are typically larger
- **Runtime Performance**: Some obfuscation techniques may impact runtime performance
- **Memory Usage**: Obfuscated code may use more memory

## Troubleshooting

### Common Issues

1. **Obfuscation options not recognized**
   - Ensure LLVM was built with OLLVM patches applied
   - Check that the build completed successfully

2. **Compilation errors with obfuscation**
   - Some complex C++ code may not work with all obfuscation passes
   - Try using individual passes instead of combining them

3. **Runtime crashes in obfuscated code**
   - Test with individual obfuscation passes to identify problematic ones
   - Some passes may not be compatible with certain code patterns

### Debug Information

When debugging obfuscated code:
- Use `-g` flag to include debug information
- Some obfuscation passes may interfere with debugging
- Consider using less aggressive obfuscation for debug builds

## Credits

- Original OLLVM project: https://github.com/obfuscator-llvm/obfuscator
- OLLVM patches adapted from various community contributions
- Integration developed for llvm-mingw project
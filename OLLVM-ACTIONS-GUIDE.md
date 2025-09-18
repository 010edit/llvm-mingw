# OLLVM GitHub Actions 构建指南

## 概述

本项目已集成OLLVM混淆功能，并修改了GitHub Actions工作流以支持OLLVM构建。由于OLLVM补丁仅兼容LLVM 17.0.6版本，所有构建流程已强制使用该版本。

## 修改内容

### 1. 版本限制
- **build-llvm.sh**: 默认LLVM版本设置为 `llvmorg-17.0.6`
- **GitHub Actions**: 强制使用LLVM 17.0.6，不再动态获取最新版本

### 2. 构建流程修改
所有主要构建作业都已添加OLLVM patch应用步骤：
- `linux` - Linux交叉编译器构建
- `linux-asserts` - 带断言的Linux构建
- `macos` - macOS交叉编译器构建  
- `msys2` - Windows MSYS2环境构建

### 3. 专用OLLVM工作流
创建了 `ollvm-build.yml` 专门用于OLLVM构建：
- 独立的OLLVM构建流程
- 包含OLLVM功能测试
- 支持手动触发和工件上传

## 使用方法

### 自动构建
现有的 `build.yml` 工作流会自动应用OLLVM patches：
```bash
# 在每个构建作业中自动执行
if [ -f apply-ollvm-patches.sh ]; then
  echo "Applying OLLVM patches..."
  bash apply-ollvm-patches.sh
else
  echo "OLLVM patch script not found, skipping..."
fi
```

### 手动OLLVM构建
使用专用的OLLVM工作流：
1. 进入GitHub仓库的Actions页面
2. 选择 "Build OLLVM-enabled toolchains"
3. 点击 "Run workflow"
4. 可选择上传构建产物到Release

### 本地测试
```bash
# 测试OLLVM集成
bash test-ollvm-integration.sh /path/to/toolchain

# 手动应用patches
bash apply-ollvm-patches.sh
```

## 构建产物

### 标准构建
- 包含OLLVM功能的常规工具链
- 文件名格式：`llvm-mingw-{TAG}-ucrt-{PLATFORM}.tar.xz`

### OLLVM专用构建  
- 专门的OLLVM构建，包含功能测试
- 文件名格式：`llvm-mingw-{TAG}-ucrt-{PLATFORM}-ollvm.tar.xz`
- 包含详细的OLLVM功能说明

## 混淆选项

构建的工具链支持以下OLLVM混淆选项：

| 选项 | 说明 | 使用方法 |
|------|------|----------|
| `fla` | 控制流平坦化 | `-mllvm -fla` |
| `bcf` | 虚假控制流 | `-mllvm -bcf` |
| `sub` | 指令替换 | `-mllvm -sub` |
| `fco` | 函数注解 | `-mllvm -fco` |
| `split` | 基本块分割 | `-mllvm -split` |

### 使用示例
```bash
# 单个混淆选项
clang -mllvm -fla hello.c -o hello.exe

# 多个混淆选项组合
clang -mllvm -fla -mllvm -bcf -mllvm -sub hello.c -o hello.exe

# 带优化的混淆
clang -O2 -mllvm -fla -mllvm -bcf hello.c -o hello.exe
```

## 注意事项

1. **版本兼容性**: 必须使用LLVM 17.0.6，其他版本可能导致patch失败
2. **构建时间**: OLLVM混淆会增加编译时间
3. **二进制大小**: 混淆后的二进制文件通常会增大
4. **调试**: 混淆会影响调试体验，建议在Release构建中使用

## 故障排除

### Patch应用失败
```bash
# 检查LLVM版本
git describe --tags

# 手动应用patch
cd llvm-project
git apply ../ollvm_path/patches/*.patch
```

### 构建失败
1. 确认LLVM版本为17.0.6
2. 检查patch文件完整性
3. 查看构建日志中的错误信息

### 混淆不生效
1. 确认使用了正确的编译器路径
2. 检查混淆选项语法
3. 验证工具链是否包含OLLVM功能

## 相关文件

- `build-llvm.sh` - 主构建脚本
- `apply-ollvm-patches.sh` - OLLVM patch应用脚本
- `test-ollvm-integration.sh` - OLLVM功能测试脚本
- `.github/workflows/build.yml` - 主构建工作流
- `.github/workflows/ollvm-build.yml` - OLLVM专用工作流
- `README-OLLVM.md` - OLLVM功能详细说明
// RUN: not llvm-mc -triple=r600 %s 2>&1 | FileCheck --check-prefix=R600 %s

// R600: :[[@LINE+1]]:{{[0-9]+}}: error: .amd_amdgpu_isa directive is not available on non-amdgcn architectures
.amd_amdgpu_isa "r600"

// R600: :[[@LINE+1]]:{{[0-9]+}}: error: .amd_amdgpu_hsa_metadata directive is not available on non-amdhsa OSes
.amd_amdgpu_hsa_metadata

// R600: :[[@LINE+1]]:{{[0-9]+}}: error: .amd_amdgpu_pal_metadata directive is not available on non-amdpal OSes
.amd_amdgpu_pal_metadata

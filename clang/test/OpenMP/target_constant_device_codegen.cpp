// Test host codegen.
// RUN: %clang_cc1 -verify -Wno-vla -fopenmp -x c++ -triple powerpc64le-unknown-unknown -fopenmp-targets=powerpc64le-ibm-linux-gnu -emit-llvm %s -o - | FileCheck %s --check-prefix CHECK --check-prefix CHECK-64
// RUN: %clang_cc1 -fopenmp -x c++ -std=c++11 -triple powerpc64le-unknown-unknown -fopenmp-targets=powerpc64le-ibm-linux-gnu -emit-pch -o %t %s
// RUN: %clang_cc1 -fopenmp -x c++ -triple powerpc64le-unknown-unknown -fopenmp-targets=powerpc64le-ibm-linux-gnu -std=c++11 -include-pch %t -verify -Wno-vla %s -emit-llvm -o - | FileCheck %s --check-prefix CHECK --check-prefix CHECK-64

// expected-no-diagnostics
#ifndef HEADER
#define HEADER

int global;
extern int global;

// CHECK: define {{.*}}[[FOO:@.+]](
int foo(int n) {
  int a = 0;
  float b[10];
  double cn[5][n];

  #pragma omp target nowait depend(in: global) depend(out: a, b, cn[4])
  {
  }

  // CHECK: call ptr @__kmpc_omp_target_task_alloc({{.*}}, i64 -1)

  #pragma omp target device(1) nowait depend(in: global) depend(out: a, b, cn[4])
  {
  }

  // CHECK: call ptr @__kmpc_omp_target_task_alloc({{.*}}, i64 1)

  return a;
}

#endif

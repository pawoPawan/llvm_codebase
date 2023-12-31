// RUN: %clang_cc1 %s -emit-llvm -o - -triple=x86_64-unknown-unknown | FileCheck -check-prefix GLOBAL-LP64 %s
// RUN: %clang_cc1 %s -emit-llvm -o - -triple=armv7-unknown-unknown | FileCheck -check-prefix GLOBAL-LP32 %s

struct A;
typedef int A::*param_t;
struct {
  const char *name;
  param_t par;
} ptr;
void test_ptr() { (void) ptr; } // forced use

// GLOBAL-LP64: type { ptr, i64 }
// GLOBAL-LP32: type { ptr, i32 }

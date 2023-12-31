// This is the ASAN test of the same name ported to HWAsan.

// RUN: %clangxx_hwasan -std=c++11 -O1 %s -o %t && \
// RUN:     not %run %t 2>&1 | FileCheck %s

// REQUIRES: aarch64-target-arch || riscv64-target-arch

struct IntHolder {
  int val;
};

const IntHolder *saved;

__attribute__((noinline)) void save(const IntHolder &holder) {
  saved = &holder;
}

int main(int argc, char *argv[]) {
  save({argc});
  int x = saved->val; // BOOM
  // CHECK: ERROR: HWAddressSanitizer: tag-mismatch
  // CHECK:  #0 0x{{.*}} in main {{.*}}use-after-scope-temp.cpp:[[@LINE-2]]
  // CHECK: Cause: stack tag-mismatch
  return x;
}

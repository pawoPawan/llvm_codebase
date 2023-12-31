//===-- Implementation header for pthread_join function ---------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIBC_SRC_PTHREAD_PTHREAD_JOIN_H
#define LLVM_LIBC_SRC_PTHREAD_PTHREAD_JOIN_H

#include <pthread.h>

namespace LIBC_NAMESPACE {

int pthread_join(pthread_t thread, void **retval);

} // namespace LIBC_NAMESPACE

#endif // LLVM_LIBC_SRC_PTHREAD_PTHREAD_JOIN_H

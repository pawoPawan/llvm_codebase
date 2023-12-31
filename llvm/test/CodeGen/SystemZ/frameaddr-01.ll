; RUN: llc < %s -mtriple=s390x-linux-gnu | FileCheck %s

; The current function's frame address is the address of
; the optional back chain slot.
define ptr @fp0() nounwind {
entry:
; CHECK-LABEL: fp0:
; CHECK: la   %r2, 0(%r15)
; CHECK: br   %r14
  %0 = tail call ptr @llvm.frameaddress(i32 0)
  ret ptr %0
}

; Check that the frame address is correct in a presence
; of a stack frame.
define ptr @fp0f() nounwind {
entry:
; CHECK-LABEL: fp0f:
; CHECK: aghi %r15, -168
; CHECK: la   %r2, 168(%r15)
; CHECK: aghi %r15, 168
; CHECK: br   %r14
  %0 = alloca i64, align 8
  %1 = tail call ptr @llvm.frameaddress(i32 0)
  ret ptr %1
}

; Check the caller's frame address.
define ptr @fpcaller() nounwind "backchain" {
entry:
; CHECK-LABEL: fpcaller:
; CHECK: lg   %r2, 0(%r15)
; CHECK: br   %r14
  %0 = tail call ptr @llvm.frameaddress(i32 1)
  ret ptr %0
}

; Check the caller's frame address.
define ptr @fpcallercaller() nounwind "backchain" {
entry:
; CHECK-LABEL: fpcallercaller:
; CHECK: lg   %r1, 0(%r15)
; CHECK: lg   %r2, 0(%r1)
; CHECK: br   %r14
  %0 = tail call ptr @llvm.frameaddress(i32 2)
  ret ptr %0
}

declare ptr @llvm.frameaddress(i32) nounwind readnone

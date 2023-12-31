; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt %s -passes=instsimplify -S | FileCheck %s

declare { i4, i1 } @llvm.umul.with.overflow.i4(i4, i4) #1

define i1 @t0_umul(i4 %size, i4 %nmemb) {
; CHECK-LABEL: @t0_umul(
; CHECK-NEXT:    [[UMUL:%.*]] = tail call { i4, i1 } @llvm.umul.with.overflow.i4(i4 [[SIZE:%.*]], i4 [[NMEMB:%.*]])
; CHECK-NEXT:    [[UMUL_OV:%.*]] = extractvalue { i4, i1 } [[UMUL]], 1
; CHECK-NEXT:    ret i1 [[UMUL_OV]]
;
  %cmp = icmp ne i4 %size, 0
  %umul = tail call { i4, i1 } @llvm.umul.with.overflow.i4(i4 %size, i4 %nmemb)
  %umul.ov = extractvalue { i4, i1 } %umul, 1
  %and = and i1 %umul.ov, %cmp
  ret i1 %and
}

define i1 @t1_commutative(i4 %size, i4 %nmemb) {
; CHECK-LABEL: @t1_commutative(
; CHECK-NEXT:    [[UMUL:%.*]] = tail call { i4, i1 } @llvm.umul.with.overflow.i4(i4 [[SIZE:%.*]], i4 [[NMEMB:%.*]])
; CHECK-NEXT:    [[UMUL_OV:%.*]] = extractvalue { i4, i1 } [[UMUL]], 1
; CHECK-NEXT:    ret i1 [[UMUL_OV]]
;
  %cmp = icmp ne i4 %size, 0
  %umul = tail call { i4, i1 } @llvm.umul.with.overflow.i4(i4 %size, i4 %nmemb)
  %umul.ov = extractvalue { i4, i1 } %umul, 1
  %and = and i1 %cmp, %umul.ov ; swapped
  ret i1 %and
}

define i1 @n2_wrong_size(i4 %size0, i4 %size1, i4 %nmemb) {
; CHECK-LABEL: @n2_wrong_size(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne i4 [[SIZE1:%.*]], 0
; CHECK-NEXT:    [[UMUL:%.*]] = tail call { i4, i1 } @llvm.umul.with.overflow.i4(i4 [[SIZE0:%.*]], i4 [[NMEMB:%.*]])
; CHECK-NEXT:    [[UMUL_OV:%.*]] = extractvalue { i4, i1 } [[UMUL]], 1
; CHECK-NEXT:    [[AND:%.*]] = and i1 [[UMUL_OV]], [[CMP]]
; CHECK-NEXT:    ret i1 [[AND]]
;
  %cmp = icmp ne i4 %size1, 0 ; not %size0
  %umul = tail call { i4, i1 } @llvm.umul.with.overflow.i4(i4 %size0, i4 %nmemb)
  %umul.ov = extractvalue { i4, i1 } %umul, 1
  %and = and i1 %umul.ov, %cmp
  ret i1 %and
}

define i1 @n3_wrong_pred(i4 %size, i4 %nmemb) {
; CHECK-LABEL: @n3_wrong_pred(
; CHECK-NEXT:    ret i1 false
;
  %cmp = icmp eq i4 %size, 0 ; not 'ne'
  %umul = tail call { i4, i1 } @llvm.umul.with.overflow.i4(i4 %size, i4 %nmemb)
  %umul.ov = extractvalue { i4, i1 } %umul, 1
  %and = and i1 %umul.ov, %cmp
  ret i1 %and
}

define i1 @n4_not_and(i4 %size, i4 %nmemb) {
; CHECK-LABEL: @n4_not_and(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne i4 [[SIZE:%.*]], 0
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %cmp = icmp ne i4 %size, 0
  %umul = tail call { i4, i1 } @llvm.umul.with.overflow.i4(i4 %size, i4 %nmemb)
  %umul.ov = extractvalue { i4, i1 } %umul, 1
  %and = or i1 %umul.ov, %cmp ; not 'and'
  ret i1 %and
}

define i1 @n5_not_zero(i4 %size, i4 %nmemb) {
; CHECK-LABEL: @n5_not_zero(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne i4 [[SIZE:%.*]], 1
; CHECK-NEXT:    [[UMUL:%.*]] = tail call { i4, i1 } @llvm.umul.with.overflow.i4(i4 [[SIZE]], i4 [[NMEMB:%.*]])
; CHECK-NEXT:    [[UMUL_OV:%.*]] = extractvalue { i4, i1 } [[UMUL]], 1
; CHECK-NEXT:    [[AND:%.*]] = and i1 [[UMUL_OV]], [[CMP]]
; CHECK-NEXT:    ret i1 [[AND]]
;
  %cmp = icmp ne i4 %size, 1 ; should be '0'
  %umul = tail call { i4, i1 } @llvm.umul.with.overflow.i4(i4 %size, i4 %nmemb)
  %umul.ov = extractvalue { i4, i1 } %umul, 1
  %and = and i1 %umul.ov, %cmp
  ret i1 %and
}

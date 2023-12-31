; NOTE: Assertions have been autogenerated by utils/update_analyze_test_checks.py
; RUN: opt -S -disable-output "-passes=print<scalar-evolution>" < %s 2>&1 | FileCheck %s

; The obvious case.
define i32 @mul(i32 %val) nounwind {
; CHECK-LABEL: 'mul'
; CHECK-NEXT:  Classifying expressions for: @mul
; CHECK-NEXT:    %tmp1 = mul i32 %val, 16
; CHECK-NEXT:    --> (16 * %val) U: [0,-15) S: [-2147483648,2147483633)
; CHECK-NEXT:    %tmp2 = udiv i32 %tmp1, 16
; CHECK-NEXT:    --> ((16 * %val) /u 16) U: [0,268435456) S: [0,268435456)
; CHECK-NEXT:  Determining loop execution counts for: @mul
;
  %tmp1 = mul i32 %val, 16
  %tmp2 = udiv i32 %tmp1, 16
  ret i32 %tmp2
}

; Or, it could be any number of equivalent patterns with mask:
;   a) x &  (1 << nbits) - 1
;   b) x & ~(-1 << nbits)
;   c) x &  (-1 >> (32 - y))
;   d) x << (32 - y) >> (32 - y)

define i32 @mask_abc(i32 %val) nounwind {
; CHECK-LABEL: 'mask_abc'
; CHECK-NEXT:  Classifying expressions for: @mask_abc
; CHECK-NEXT:    %masked = and i32 %val, 15
; CHECK-NEXT:    --> (zext i4 (trunc i32 %val to i4) to i32) U: [0,16) S: [0,16)
; CHECK-NEXT:  Determining loop execution counts for: @mask_abc
;
  %masked = and i32 %val, 15
  ret i32 %masked
}

define i32 @mask_d(i32 %val) nounwind {
; CHECK-LABEL: 'mask_d'
; CHECK-NEXT:  Classifying expressions for: @mask_d
; CHECK-NEXT:    %highbitscleared = shl i32 %val, 4
; CHECK-NEXT:    --> (16 * %val) U: [0,-15) S: [-2147483648,2147483633)
; CHECK-NEXT:    %masked = lshr i32 %highbitscleared, 4
; CHECK-NEXT:    --> ((16 * %val) /u 16) U: [0,268435456) S: [0,268435456)
; CHECK-NEXT:  Determining loop execution counts for: @mask_d
;
  %highbitscleared = shl i32 %val, 4
  %masked = lshr i32 %highbitscleared, 4
  ret i32 %masked
}

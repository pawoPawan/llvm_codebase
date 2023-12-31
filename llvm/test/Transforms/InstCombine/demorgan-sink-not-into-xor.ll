; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --prefix-filecheck-ir-name V
; RUN: opt < %s -passes=instcombine -S | FileCheck %s

; https://bugs.llvm.org/show_bug.cgi?id=38446

; Pattern:
;   ~(x ^ y)
; Should be transformed into:
;   (~x) ^ y
; or into
;   x ^ (~y)

; While -passes=reassociate does handle this simple pattern, it does not handle
; the more complicated motivating pattern.

; ============================================================================ ;
; Basic positive tests
; ============================================================================ ;

; If the operand is easily-invertible, fold into it.
declare i1 @gen1()

define i1 @positive_easyinvert(i16 %x, i8 %y) {
; CHECK-LABEL: @positive_easyinvert(
; CHECK-NEXT:    [[VTMP2:%.*]] = icmp slt i8 [[Y:%.*]], 0
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt i16 [[X:%.*]], -1
; CHECK-NEXT:    [[VTMP4:%.*]] = xor i1 [[VTMP2]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[VTMP4]]
;
  %tmp1 = icmp slt i16 %x, 0
  %tmp2 = icmp slt i8 %y, 0
  %tmp3 = xor i1 %tmp2, %tmp1
  %tmp4 = xor i1 %tmp3, true
  ret i1 %tmp4
}

define i1 @positive_easyinvert0(i8 %y) {
; CHECK-LABEL: @positive_easyinvert0(
; CHECK-NEXT:    [[VTMP1:%.*]] = call i1 @gen1()
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt i8 [[Y:%.*]], -1
; CHECK-NEXT:    [[VTMP4:%.*]] = xor i1 [[TMP1]], [[VTMP1]]
; CHECK-NEXT:    ret i1 [[VTMP4]]
;
  %tmp1 = call i1 @gen1()
  %cond = icmp slt i8 %y, 0
  %tmp3 = xor i1 %cond, %tmp1
  %tmp4 = xor i1 %tmp3, true
  ret i1 %tmp4
}

define i1 @positive_easyinvert1(i8 %y) {
; CHECK-LABEL: @positive_easyinvert1(
; CHECK-NEXT:    [[VTMP1:%.*]] = call i1 @gen1()
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt i8 [[Y:%.*]], -1
; CHECK-NEXT:    [[VTMP4:%.*]] = xor i1 [[VTMP1]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[VTMP4]]
;
  %tmp1 = call i1 @gen1()
  %tmp2 = icmp slt i8 %y, 0
  %tmp3 = xor i1 %tmp1, %tmp2
  %tmp4 = xor i1 %tmp3, true
  ret i1 %tmp4
}

; ============================================================================ ;
; One-use tests with easily-invertible operand.
; ============================================================================ ;

declare void @use1(i1)

define i1 @oneuse_easyinvert_0(i8 %y) {
; CHECK-LABEL: @oneuse_easyinvert_0(
; CHECK-NEXT:    [[VTMP1:%.*]] = call i1 @gen1()
; CHECK-NEXT:    [[VTMP2:%.*]] = icmp slt i8 [[Y:%.*]], 0
; CHECK-NEXT:    call void @use1(i1 [[VTMP2]])
; CHECK-NEXT:    [[VTMP3:%.*]] = xor i1 [[VTMP1]], [[VTMP2]]
; CHECK-NEXT:    [[VTMP4:%.*]] = xor i1 [[VTMP3]], true
; CHECK-NEXT:    ret i1 [[VTMP4]]
;
  %tmp1 = call i1 @gen1()
  %tmp2 = icmp slt i8 %y, 0
  call void @use1(i1 %tmp2)
  %tmp3 = xor i1 %tmp1, %tmp2
  %tmp4 = xor i1 %tmp3, true
  ret i1 %tmp4
}

define i1 @oneuse_easyinvert_1(i8 %y) {
; CHECK-LABEL: @oneuse_easyinvert_1(
; CHECK-NEXT:    [[VTMP1:%.*]] = call i1 @gen1()
; CHECK-NEXT:    [[VTMP2:%.*]] = icmp slt i8 [[Y:%.*]], 0
; CHECK-NEXT:    [[VTMP3:%.*]] = xor i1 [[VTMP1]], [[VTMP2]]
; CHECK-NEXT:    call void @use1(i1 [[VTMP3]])
; CHECK-NEXT:    [[VTMP4:%.*]] = xor i1 [[VTMP3]], true
; CHECK-NEXT:    ret i1 [[VTMP4]]
;
  %tmp1 = call i1 @gen1()
  %tmp2 = icmp slt i8 %y, 0
  %tmp3 = xor i1 %tmp1, %tmp2
  call void @use1(i1 %tmp3)
  %tmp4 = xor i1 %tmp3, true
  ret i1 %tmp4
}

define i1 @oneuse_easyinvert_2(i8 %y) {
; CHECK-LABEL: @oneuse_easyinvert_2(
; CHECK-NEXT:    [[VTMP1:%.*]] = call i1 @gen1()
; CHECK-NEXT:    [[VTMP2:%.*]] = icmp slt i8 [[Y:%.*]], 0
; CHECK-NEXT:    call void @use1(i1 [[VTMP2]])
; CHECK-NEXT:    [[VTMP3:%.*]] = xor i1 [[VTMP1]], [[VTMP2]]
; CHECK-NEXT:    call void @use1(i1 [[VTMP3]])
; CHECK-NEXT:    [[VTMP4:%.*]] = xor i1 [[VTMP3]], true
; CHECK-NEXT:    ret i1 [[VTMP4]]
;
  %tmp1 = call i1 @gen1()
  %tmp2 = icmp slt i8 %y, 0
  call void @use1(i1 %tmp2)
  %tmp3 = xor i1 %tmp1, %tmp2
  call void @use1(i1 %tmp3)
  %tmp4 = xor i1 %tmp3, true
  ret i1 %tmp4
}

; ============================================================================ ;
; Negative tests
; ============================================================================ ;

; Not easily invertible.
define i32 @negative(i32 %x, i32 %y) {
; CHECK-LABEL: @negative(
; CHECK-NEXT:    [[VTMP1:%.*]] = xor i32 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[VTMP2:%.*]] = xor i32 [[VTMP1]], -1
; CHECK-NEXT:    ret i32 [[VTMP2]]
;
  %tmp1 = xor i32 %x, %y
  %tmp2 = xor i32 %tmp1, -1
  ret i32 %tmp2
}

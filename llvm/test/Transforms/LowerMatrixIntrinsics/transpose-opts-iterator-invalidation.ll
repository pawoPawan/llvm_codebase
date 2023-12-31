; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes=lower-matrix-intrinsics -S %s | FileCheck %s

define <2 x double> @test(<4 x double> %a, <2 x double> %b, i1 %c) {
; CHECK-LABEL: @test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[C:%.*]], label [[EXIT_1:%.*]], label [[EXIT_2:%.*]]
; CHECK:       exit.1:
; CHECK-NEXT:    [[SPLIT:%.*]] = shufflevector <4 x double> [[A:%.*]], <4 x double> poison, <2 x i32> <i32 0, i32 1>
; CHECK-NEXT:    [[SPLIT1:%.*]] = shufflevector <4 x double> [[A]], <4 x double> poison, <2 x i32> <i32 2, i32 3>
; CHECK-NEXT:    [[SPLIT2:%.*]] = shufflevector <2 x double> [[B:%.*]], <2 x double> poison, <2 x i32> <i32 0, i32 1>
; CHECK-NEXT:    [[BLOCK:%.*]] = shufflevector <2 x double> [[SPLIT]], <2 x double> poison, <1 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP0:%.*]] = extractelement <2 x double> [[SPLIT2]], i64 0
; CHECK-NEXT:    [[SPLAT_SPLATINSERT:%.*]] = insertelement <1 x double> poison, double [[TMP0]], i64 0
; CHECK-NEXT:    [[SPLAT_SPLAT:%.*]] = shufflevector <1 x double> [[SPLAT_SPLATINSERT]], <1 x double> poison, <1 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP1:%.*]] = fmul <1 x double> [[BLOCK]], [[SPLAT_SPLAT]]
; CHECK-NEXT:    [[BLOCK3:%.*]] = shufflevector <2 x double> [[SPLIT1]], <2 x double> poison, <1 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP2:%.*]] = extractelement <2 x double> [[SPLIT2]], i64 1
; CHECK-NEXT:    [[SPLAT_SPLATINSERT4:%.*]] = insertelement <1 x double> poison, double [[TMP2]], i64 0
; CHECK-NEXT:    [[SPLAT_SPLAT5:%.*]] = shufflevector <1 x double> [[SPLAT_SPLATINSERT4]], <1 x double> poison, <1 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP3:%.*]] = fmul <1 x double> [[BLOCK3]], [[SPLAT_SPLAT5]]
; CHECK-NEXT:    [[TMP4:%.*]] = fadd <1 x double> [[TMP1]], [[TMP3]]
; CHECK-NEXT:    [[TMP5:%.*]] = shufflevector <1 x double> [[TMP4]], <1 x double> poison, <2 x i32> <i32 0, i32 poison>
; CHECK-NEXT:    [[TMP6:%.*]] = shufflevector <2 x double> poison, <2 x double> [[TMP5]], <2 x i32> <i32 2, i32 1>
; CHECK-NEXT:    [[BLOCK6:%.*]] = shufflevector <2 x double> [[SPLIT]], <2 x double> poison, <1 x i32> <i32 1>
; CHECK-NEXT:    [[TMP7:%.*]] = extractelement <2 x double> [[SPLIT2]], i64 0
; CHECK-NEXT:    [[SPLAT_SPLATINSERT7:%.*]] = insertelement <1 x double> poison, double [[TMP7]], i64 0
; CHECK-NEXT:    [[SPLAT_SPLAT8:%.*]] = shufflevector <1 x double> [[SPLAT_SPLATINSERT7]], <1 x double> poison, <1 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP8:%.*]] = fmul <1 x double> [[BLOCK6]], [[SPLAT_SPLAT8]]
; CHECK-NEXT:    [[BLOCK9:%.*]] = shufflevector <2 x double> [[SPLIT1]], <2 x double> poison, <1 x i32> <i32 1>
; CHECK-NEXT:    [[TMP9:%.*]] = extractelement <2 x double> [[SPLIT2]], i64 1
; CHECK-NEXT:    [[SPLAT_SPLATINSERT10:%.*]] = insertelement <1 x double> poison, double [[TMP9]], i64 0
; CHECK-NEXT:    [[SPLAT_SPLAT11:%.*]] = shufflevector <1 x double> [[SPLAT_SPLATINSERT10]], <1 x double> poison, <1 x i32> zeroinitializer
; CHECK-NEXT:    [[TMP10:%.*]] = fmul <1 x double> [[BLOCK9]], [[SPLAT_SPLAT11]]
; CHECK-NEXT:    [[TMP11:%.*]] = fadd <1 x double> [[TMP8]], [[TMP10]]
; CHECK-NEXT:    [[TMP12:%.*]] = shufflevector <1 x double> [[TMP11]], <1 x double> poison, <2 x i32> <i32 0, i32 poison>
; CHECK-NEXT:    [[TMP13:%.*]] = shufflevector <2 x double> [[TMP6]], <2 x double> [[TMP12]], <2 x i32> <i32 0, i32 2>
; CHECK-NEXT:    [[TMP14:%.*]] = extractelement <2 x double> [[TMP13]], i64 0
; CHECK-NEXT:    [[TMP15:%.*]] = insertelement <1 x double> poison, double [[TMP14]], i64 0
; CHECK-NEXT:    [[TMP16:%.*]] = extractelement <2 x double> [[TMP13]], i64 1
; CHECK-NEXT:    [[TMP17:%.*]] = insertelement <1 x double> poison, double [[TMP16]], i64 0
; CHECK-NEXT:    [[TMP18:%.*]] = shufflevector <1 x double> [[TMP15]], <1 x double> [[TMP17]], <2 x i32> <i32 0, i32 1>
; CHECK-NEXT:    ret <2 x double> [[TMP18]]
; CHECK:       exit.2:
; CHECK-NEXT:    ret <2 x double> zeroinitializer
;
entry:
  %mult = call <2 x double> @llvm.matrix.multiply.v2f64.v4f64.v2f64(<4 x double> %a, <2 x double> %b, i32 2, i32 2, i32 1)
  br i1 %c, label %exit.1, label %exit.2

exit.1:
  %trans = call <2 x double> @llvm.matrix.transpose.v2f64(<2 x double> %mult, i32 2, i32 1)
  ret <2 x double> %trans

exit.2:
  ret <2 x double> zeroinitializer
}

declare <2 x double> @llvm.matrix.transpose.v2f64(<2 x double>, i32 immarg, i32 immarg)

declare <2 x double> @llvm.matrix.multiply.v2f64.v4f64.v2f64(<4 x double>, <2 x double>, i32 immarg, i32 immarg, i32 immarg)

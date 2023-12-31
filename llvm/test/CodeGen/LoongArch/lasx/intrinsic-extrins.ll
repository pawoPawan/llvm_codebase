; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc --mtriple=loongarch64 --mattr=+lasx < %s | FileCheck %s

declare <32 x i8> @llvm.loongarch.lasx.xvextrins.b(<32 x i8>, <32 x i8>, i32)

define <32 x i8> @lasx_xvextrins_b(<32 x i8> %va, <32 x i8> %vb) nounwind {
; CHECK-LABEL: lasx_xvextrins_b:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xvextrins.b $xr0, $xr1, 1
; CHECK-NEXT:    ret
entry:
  %res = call <32 x i8> @llvm.loongarch.lasx.xvextrins.b(<32 x i8> %va, <32 x i8> %vb, i32 1)
  ret <32 x i8> %res
}

declare <16 x i16> @llvm.loongarch.lasx.xvextrins.h(<16 x i16>, <16 x i16>, i32)

define <16 x i16> @lasx_xvextrins_h(<16 x i16> %va, <16 x i16> %vb) nounwind {
; CHECK-LABEL: lasx_xvextrins_h:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xvextrins.h $xr0, $xr1, 1
; CHECK-NEXT:    ret
entry:
  %res = call <16 x i16> @llvm.loongarch.lasx.xvextrins.h(<16 x i16> %va, <16 x i16> %vb, i32 1)
  ret <16 x i16> %res
}

declare <8 x i32> @llvm.loongarch.lasx.xvextrins.w(<8 x i32>, <8 x i32>, i32)

define <8 x i32> @lasx_xvextrins_w(<8 x i32> %va, <8 x i32> %vb) nounwind {
; CHECK-LABEL: lasx_xvextrins_w:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xvextrins.w $xr0, $xr1, 1
; CHECK-NEXT:    ret
entry:
  %res = call <8 x i32> @llvm.loongarch.lasx.xvextrins.w(<8 x i32> %va, <8 x i32> %vb, i32 1)
  ret <8 x i32> %res
}

declare <4 x i64> @llvm.loongarch.lasx.xvextrins.d(<4 x i64>, <4 x i64>, i32)

define <4 x i64> @lasx_xvextrins_d(<4 x i64> %va, <4 x i64> %vb) nounwind {
; CHECK-LABEL: lasx_xvextrins_d:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xvextrins.d $xr0, $xr1, 1
; CHECK-NEXT:    ret
entry:
  %res = call <4 x i64> @llvm.loongarch.lasx.xvextrins.d(<4 x i64> %va, <4 x i64> %vb, i32 1)
  ret <4 x i64> %res
}

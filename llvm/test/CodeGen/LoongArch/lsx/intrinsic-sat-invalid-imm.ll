; RUN: not llc --mtriple=loongarch64 --mattr=+lsx < %s 2>&1 | FileCheck %s

declare <16 x i8> @llvm.loongarch.lsx.vsat.b(<16 x i8>, i32)

define <16 x i8> @lsx_vsat_b_lo(<16 x i8> %va) nounwind {
; CHECK: llvm.loongarch.lsx.vsat.b: argument out of range
entry:
  %res = call <16 x i8> @llvm.loongarch.lsx.vsat.b(<16 x i8> %va, i32 -1)
  ret <16 x i8> %res
}

define <16 x i8> @lsx_vsat_b_hi(<16 x i8> %va) nounwind {
; CHECK: llvm.loongarch.lsx.vsat.b: argument out of range
entry:
  %res = call <16 x i8> @llvm.loongarch.lsx.vsat.b(<16 x i8> %va, i32 8)
  ret <16 x i8> %res
}

declare <8 x i16> @llvm.loongarch.lsx.vsat.h(<8 x i16>, i32)

define <8 x i16> @lsx_vsat_h_lo(<8 x i16> %va) nounwind {
; CHECK: llvm.loongarch.lsx.vsat.h: argument out of range
entry:
  %res = call <8 x i16> @llvm.loongarch.lsx.vsat.h(<8 x i16> %va, i32 -1)
  ret <8 x i16> %res
}

define <8 x i16> @lsx_vsat_h_hi(<8 x i16> %va) nounwind {
; CHECK: llvm.loongarch.lsx.vsat.h: argument out of range
entry:
  %res = call <8 x i16> @llvm.loongarch.lsx.vsat.h(<8 x i16> %va, i32 16)
  ret <8 x i16> %res
}

declare <4 x i32> @llvm.loongarch.lsx.vsat.w(<4 x i32>, i32)

define <4 x i32> @lsx_vsat_w_lo(<4 x i32> %va) nounwind {
; CHECK: llvm.loongarch.lsx.vsat.w: argument out of range
entry:
  %res = call <4 x i32> @llvm.loongarch.lsx.vsat.w(<4 x i32> %va, i32 -1)
  ret <4 x i32> %res
}

define <4 x i32> @lsx_vsat_w_hi(<4 x i32> %va) nounwind {
; CHECK: llvm.loongarch.lsx.vsat.w: argument out of range
entry:
  %res = call <4 x i32> @llvm.loongarch.lsx.vsat.w(<4 x i32> %va, i32 32)
  ret <4 x i32> %res
}

declare <2 x i64> @llvm.loongarch.lsx.vsat.d(<2 x i64>, i32)

define <2 x i64> @lsx_vsat_d_lo(<2 x i64> %va) nounwind {
; CHECK: llvm.loongarch.lsx.vsat.d: argument out of range
entry:
  %res = call <2 x i64> @llvm.loongarch.lsx.vsat.d(<2 x i64> %va, i32 -1)
  ret <2 x i64> %res
}

define <2 x i64> @lsx_vsat_d_hi(<2 x i64> %va) nounwind {
; CHECK: llvm.loongarch.lsx.vsat.d: argument out of range
entry:
  %res = call <2 x i64> @llvm.loongarch.lsx.vsat.d(<2 x i64> %va, i32 64)
  ret <2 x i64> %res
}

declare <16 x i8> @llvm.loongarch.lsx.vsat.bu(<16 x i8>, i32)

define <16 x i8> @lsx_vsat_bu_lo(<16 x i8> %va) nounwind {
; CHECK: llvm.loongarch.lsx.vsat.bu: argument out of range
entry:
  %res = call <16 x i8> @llvm.loongarch.lsx.vsat.bu(<16 x i8> %va, i32 -1)
  ret <16 x i8> %res
}

define <16 x i8> @lsx_vsat_bu_hi(<16 x i8> %va) nounwind {
; CHECK: llvm.loongarch.lsx.vsat.bu: argument out of range
entry:
  %res = call <16 x i8> @llvm.loongarch.lsx.vsat.bu(<16 x i8> %va, i32 8)
  ret <16 x i8> %res
}

declare <8 x i16> @llvm.loongarch.lsx.vsat.hu(<8 x i16>, i32)

define <8 x i16> @lsx_vsat_hu_lo(<8 x i16> %va) nounwind {
; CHECK: llvm.loongarch.lsx.vsat.hu: argument out of range
entry:
  %res = call <8 x i16> @llvm.loongarch.lsx.vsat.hu(<8 x i16> %va, i32 -1)
  ret <8 x i16> %res
}

define <8 x i16> @lsx_vsat_hu_hi(<8 x i16> %va) nounwind {
; CHECK: llvm.loongarch.lsx.vsat.hu: argument out of range
entry:
  %res = call <8 x i16> @llvm.loongarch.lsx.vsat.hu(<8 x i16> %va, i32 16)
  ret <8 x i16> %res
}

declare <4 x i32> @llvm.loongarch.lsx.vsat.wu(<4 x i32>, i32)

define <4 x i32> @lsx_vsat_wu_lo(<4 x i32> %va) nounwind {
; CHECK: llvm.loongarch.lsx.vsat.wu: argument out of range
entry:
  %res = call <4 x i32> @llvm.loongarch.lsx.vsat.wu(<4 x i32> %va, i32 -1)
  ret <4 x i32> %res
}

define <4 x i32> @lsx_vsat_wu_hi(<4 x i32> %va) nounwind {
; CHECK: llvm.loongarch.lsx.vsat.wu: argument out of range
entry:
  %res = call <4 x i32> @llvm.loongarch.lsx.vsat.wu(<4 x i32> %va, i32 32)
  ret <4 x i32> %res
}

declare <2 x i64> @llvm.loongarch.lsx.vsat.du(<2 x i64>, i32)

define <2 x i64> @lsx_vsat_du_lo(<2 x i64> %va) nounwind {
; CHECK: llvm.loongarch.lsx.vsat.du: argument out of range
entry:
  %res = call <2 x i64> @llvm.loongarch.lsx.vsat.du(<2 x i64> %va, i32 -1)
  ret <2 x i64> %res
}

define <2 x i64> @lsx_vsat_du_hi(<2 x i64> %va) nounwind {
; CHECK: llvm.loongarch.lsx.vsat.du: argument out of range
entry:
  %res = call <2 x i64> @llvm.loongarch.lsx.vsat.du(<2 x i64> %va, i32 64)
  ret <2 x i64> %res
}

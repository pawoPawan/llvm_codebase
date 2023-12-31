; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mattr=+simd128 | FileCheck %s

;; Test that SIMD extending operations can be successfully selected

target triple = "wasm32-unknown-unknown"

define <8 x i16> @extend_low_i8x16_s(<16 x i8> %v) {
; CHECK-LABEL: extend_low_i8x16_s:
; CHECK:         .functype extend_low_i8x16_s (v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    local.get 0
; CHECK-NEXT:    i16x8.extend_low_i8x16_s
; CHECK-NEXT:    # fallthrough-return
  %low = shufflevector <16 x i8> %v, <16 x i8> undef,
           <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %extended = sext <8 x i8> %low to <8 x i16>
  ret <8 x i16> %extended
}

define <8 x i16> @extend_low_i8x16_u(<16 x i8> %v) {
; CHECK-LABEL: extend_low_i8x16_u:
; CHECK:         .functype extend_low_i8x16_u (v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    local.get 0
; CHECK-NEXT:    i16x8.extend_low_i8x16_u
; CHECK-NEXT:    # fallthrough-return
  %low = shufflevector <16 x i8> %v, <16 x i8> undef,
           <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %extended = zext <8 x i8> %low to <8 x i16>
  ret <8 x i16> %extended
}

define <8 x i16> @extend_high_i8x16_s(<16 x i8> %v) {
; CHECK-LABEL: extend_high_i8x16_s:
; CHECK:         .functype extend_high_i8x16_s (v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    local.get 0
; CHECK-NEXT:    i16x8.extend_high_i8x16_s
; CHECK-NEXT:    # fallthrough-return
  %low = shufflevector <16 x i8> %v, <16 x i8> undef,
           <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %extended = sext <8 x i8> %low to <8 x i16>
  ret <8 x i16> %extended
}

define <8 x i16> @extend_high_i8x16_u(<16 x i8> %v) {
; CHECK-LABEL: extend_high_i8x16_u:
; CHECK:         .functype extend_high_i8x16_u (v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    local.get 0
; CHECK-NEXT:    i16x8.extend_high_i8x16_u
; CHECK-NEXT:    # fallthrough-return
  %low = shufflevector <16 x i8> %v, <16 x i8> undef,
           <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %extended = zext <8 x i8> %low to <8 x i16>
  ret <8 x i16> %extended
}

define <4 x i32> @extend_low_i16x8_s(<8 x i16> %v) {
; CHECK-LABEL: extend_low_i16x8_s:
; CHECK:         .functype extend_low_i16x8_s (v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    local.get 0
; CHECK-NEXT:    i32x4.extend_low_i16x8_s
; CHECK-NEXT:    # fallthrough-return
  %low = shufflevector <8 x i16> %v, <8 x i16> undef,
           <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %extended = sext <4 x i16> %low to <4 x i32>
  ret <4 x i32> %extended
}

define <4 x i32> @extend_low_i16x8_u(<8 x i16> %v) {
; CHECK-LABEL: extend_low_i16x8_u:
; CHECK:         .functype extend_low_i16x8_u (v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    local.get 0
; CHECK-NEXT:    i32x4.extend_low_i16x8_u
; CHECK-NEXT:    # fallthrough-return
  %low = shufflevector <8 x i16> %v, <8 x i16> undef,
           <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %extended = zext <4 x i16> %low to <4 x i32>
  ret <4 x i32> %extended
}

define <4 x i32> @extend_high_i16x8_s(<8 x i16> %v) {
; CHECK-LABEL: extend_high_i16x8_s:
; CHECK:         .functype extend_high_i16x8_s (v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    local.get 0
; CHECK-NEXT:    i32x4.extend_high_i16x8_s
; CHECK-NEXT:    # fallthrough-return
  %low = shufflevector <8 x i16> %v, <8 x i16> undef,
           <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %extended = sext <4 x i16> %low to <4 x i32>
  ret <4 x i32> %extended
}

define <4 x i32> @extend_high_i16x8_u(<8 x i16> %v) {
; CHECK-LABEL: extend_high_i16x8_u:
; CHECK:         .functype extend_high_i16x8_u (v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    local.get 0
; CHECK-NEXT:    i32x4.extend_high_i16x8_u
; CHECK-NEXT:    # fallthrough-return
  %low = shufflevector <8 x i16> %v, <8 x i16> undef,
           <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %extended = zext <4 x i16> %low to <4 x i32>
  ret <4 x i32> %extended
}

define <2 x i64> @extend_low_i32x4_s(<4 x i32> %v) {
; CHECK-LABEL: extend_low_i32x4_s:
; CHECK:         .functype extend_low_i32x4_s (v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    local.get 0
; CHECK-NEXT:    i64x2.extend_low_i32x4_s
; CHECK-NEXT:    # fallthrough-return
  %low = shufflevector <4 x i32> %v, <4 x i32> undef,
           <2 x i32> <i32 0, i32 1>
  %extended = sext <2 x i32> %low to <2 x i64>
  ret <2 x i64> %extended
}

define <2 x i64> @extend_low_i32x4_u(<4 x i32> %v) {
; CHECK-LABEL: extend_low_i32x4_u:
; CHECK:         .functype extend_low_i32x4_u (v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    local.get 0
; CHECK-NEXT:    i64x2.extend_low_i32x4_u
; CHECK-NEXT:    # fallthrough-return
  %low = shufflevector <4 x i32> %v, <4 x i32> undef,
           <2 x i32> <i32 0, i32 1>
  %extended = zext <2 x i32> %low to <2 x i64>
  ret <2 x i64> %extended
}

define <2 x i64> @extend_high_i32x4_s(<4 x i32> %v) {
; CHECK-LABEL: extend_high_i32x4_s:
; CHECK:         .functype extend_high_i32x4_s (v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    local.get 0
; CHECK-NEXT:    i64x2.extend_high_i32x4_s
; CHECK-NEXT:    # fallthrough-return
  %low = shufflevector <4 x i32> %v, <4 x i32> undef,
           <2 x i32> <i32 2, i32 3>
  %extended = sext <2 x i32> %low to <2 x i64>
  ret <2 x i64> %extended
}

define <2 x i64> @extend_high_i32x4_u(<4 x i32> %v) {
; CHECK-LABEL: extend_high_i32x4_u:
; CHECK:         .functype extend_high_i32x4_u (v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    local.get 0
; CHECK-NEXT:    i64x2.extend_high_i32x4_u
; CHECK-NEXT:    # fallthrough-return
  %low = shufflevector <4 x i32> %v, <4 x i32> undef,
           <2 x i32> <i32 2, i32 3>
  %extended = zext <2 x i32> %low to <2 x i64>
  ret <2 x i64> %extended
}

;; Also test that similar patterns with offsets not corresponding to
;; the low or high half are correctly expanded.

define <8 x i16> @extend_lowish_i8x16_s(<16 x i8> %v) {
; CHECK-LABEL: extend_lowish_i8x16_s:
; CHECK:         .functype extend_lowish_i8x16_s (v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    local.get 0
; CHECK-NEXT:    local.get 0
; CHECK-NEXT:    i8x16.shuffle 1, 2, 3, 4, 5, 6, 7, 8, 0, 0, 0, 0, 0, 0, 0, 0
; CHECK-NEXT:    i16x8.extend_low_i8x16_s
; CHECK-NEXT:    # fallthrough-return
  %lowish = shufflevector <16 x i8> %v, <16 x i8> undef,
           <8 x i32> <i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8>
  %extended = sext <8 x i8> %lowish to <8 x i16>
  ret <8 x i16> %extended
}

define <4 x i32> @extend_lowish_i16x8_s(<8 x i16> %v) {
; CHECK-LABEL: extend_lowish_i16x8_s:
; CHECK:         .functype extend_lowish_i16x8_s (v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    local.get 0
; CHECK-NEXT:    local.get 0
; CHECK-NEXT:    i8x16.shuffle 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 0, 1, 0, 1, 0, 1
; CHECK-NEXT:    i32x4.extend_low_i16x8_s
; CHECK-NEXT:    # fallthrough-return
  %lowish = shufflevector <8 x i16> %v, <8 x i16> undef,
           <4 x i32> <i32 1, i32 2, i32 3, i32 4>
  %extended = sext <4 x i16> %lowish to <4 x i32>
  ret <4 x i32> %extended
}

;; Also test vectors that aren't full 128 bits, or might require
;; multiple extensions

define <16 x i8> @extend_i1x16_i8(<16 x i1> %v) {
; CHECK-LABEL: extend_i1x16_i8:
; CHECK:         .functype extend_i1x16_i8 (v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    local.get 0
; CHECK-NEXT:    i32.const 7
; CHECK-NEXT:    i8x16.shl
; CHECK-NEXT:    i32.const 7
; CHECK-NEXT:    i8x16.shr_s
; CHECK-NEXT:    # fallthrough-return
    %extended = sext <16 x i1> %v to <16 x i8>
    ret <16 x i8> %extended
}

define <8 x i8> @extend_i1x8_i8(<8 x i1> %v) {
; CHECK-LABEL: extend_i1x8_i8:
; CHECK:         .functype extend_i1x8_i8 (v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    local.get 0
; CHECK-NEXT:    local.get 0
; CHECK-NEXT:    i8x16.shuffle 0, 2, 4, 6, 8, 10, 12, 14, 0, 0, 0, 0, 0, 0, 0, 0
; CHECK-NEXT:    i32.const 7
; CHECK-NEXT:    i8x16.shl
; CHECK-NEXT:    i32.const 7
; CHECK-NEXT:    i8x16.shr_s
; CHECK-NEXT:    # fallthrough-return
    %extended = sext <8 x i1> %v to <8 x i8>
    ret <8 x i8> %extended
}

define <8 x i16> @extend_i1x8_i16(<8 x i1> %v) {
; CHECK-LABEL: extend_i1x8_i16:
; CHECK:         .functype extend_i1x8_i16 (v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    local.get 0
; CHECK-NEXT:    v128.const 1, 1, 1, 1, 1, 1, 1, 1
; CHECK-NEXT:    v128.and
; CHECK-NEXT:    # fallthrough-return
    %extended = zext <8 x i1> %v to <8 x i16>
    ret <8 x i16> %extended
}

define <4 x i32> @extend_i8x4_i32(<4 x i8> %v) {
; CHECK-LABEL: extend_i8x4_i32:
; CHECK:         .functype extend_i8x4_i32 (v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    local.get 0
; CHECK-NEXT:    i16x8.extend_low_i8x16_u
; CHECK-NEXT:    i32x4.extend_low_i16x8_u
; CHECK-NEXT:    # fallthrough-return
    %extended = zext <4 x i8> %v to <4 x i32>
    ret <4 x i32> %extended
}

define <2 x i64> @extend_i8x2_i64(<2 x i8> %v) {
; CHECK-LABEL: extend_i8x2_i64:
; CHECK:         .functype extend_i8x2_i64 (v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    local.get 0
; CHECK-NEXT:    i16x8.extend_low_i8x16_s
; CHECK-NEXT:    i32x4.extend_low_i16x8_s
; CHECK-NEXT:    i64x2.extend_low_i32x4_s
; CHECK-NEXT:    # fallthrough-return
    %extended = sext <2 x i8> %v to <2 x i64>
    ret <2 x i64> %extended
}

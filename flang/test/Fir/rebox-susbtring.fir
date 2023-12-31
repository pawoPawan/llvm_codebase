// Test translation to llvm IR of fir.rebox with substring array sections.

// RUN: fir-opt -o - -cg-rewrite --fir-to-llvm-ir -cse %s | FileCheck %s
// RUN: tco -o - -cg-rewrite --fir-to-llvm-ir -cse %s | FileCheck %s

// Test a fir.rebox with a substring on a character array with constant
// length (like c(:)(2:*) where c is a fir.box array with constant length).

// CHECK-LABEL: llvm.func @char_section(
// CHECK-SAME:                          %[[VAL_0:.*]]: !llvm.ptr) {
func.func @char_section(%arg0: !fir.box<!fir.array<?x!fir.char<1,20>>>) {
  %c7_i64 = arith.constant 7 : i64
  %c1_i64 = arith.constant 1 : i64
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %0:3 = fir.box_dims %arg0, %c0 : (!fir.box<!fir.array<?x!fir.char<1,20>>>, index) -> (index, index, index)
  %1 = fir.slice %c1, %0#1, %c1_i64 substr %c1_i64, %c7_i64 : (index, index, i64, i64, i64) -> !fir.slice<1>

// Only test the computation of the base address offset computation accounting for the substring

// CHECK:         %[[VAL_4:.*]] = llvm.mlir.constant(1 : i64) : i64

// CHECK:         %[[VAL_37:.*]] = llvm.getelementptr %[[VAL_0]]{{\[}}0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<{{.*}}>
// CHECK:         %[[VAL_38:.*]] = llvm.load %[[VAL_37]] : !llvm.ptr -> !llvm.ptr
// CHECK:         %[[VAL_30:.*]] = llvm.mlir.constant(0 : i64) : i64
// CHECK:         %[[VAL_40:.*]] = llvm.getelementptr %[[VAL_38]]{{\[}}%[[VAL_30]], %[[VAL_4]]] : (!llvm.ptr, i64, i64) -> !llvm.ptr, !llvm.array<20 x i8>

// More offset computation with descriptor strides and triplets that is not character specific ...

  %2 = fir.rebox %arg0 [%1] : (!fir.box<!fir.array<?x!fir.char<1,20>>>, !fir.slice<1>) -> !fir.box<!fir.array<?x!fir.char<1,?>>>
  fir.call @bar(%2) : (!fir.box<!fir.array<?x!fir.char<1,?>>>) -> ()
  return
}

// Test a rebox of an array section like x(3:60:9)%c(2:8) with both a triplet, a component and a substring where x is a fir.box.

// CHECK-LABEL: llvm.func @foo(
// CHECK-SAME:                 %[[VAL_0:.*]]: !llvm.ptr) {
func.func private @bar(!fir.box<!fir.array<?x!fir.char<1,?>>>)
func.func @foo(%arg0: !fir.box<!fir.array<?x!fir.type<t{i:i32,c:!fir.char<1,10>}>>>) {
  %c7_i64 = arith.constant 7 : i64
  %c1_i64 = arith.constant 1 : i64
  %c9_i64 = arith.constant 9 : i64
  %c60_i64 = arith.constant 60 : i64
  %c3_i64 = arith.constant 3 : i64
  %0 = fir.field_index c, !fir.type<t{i:i32,c:!fir.char<1,10>}>
  %1 = fir.slice %c3_i64, %c60_i64, %c9_i64 path %0 substr %c1_i64, %c7_i64 : (i64, i64, i64, !fir.field, i64, i64) -> !fir.slice<1>

// Only test the computation of the base address offset computation accounting for the substring of the component

// CHECK:         %[[VAL_1:.*]] = llvm.mlir.constant(1 : i32) : i32

// CHECK:         %[[VAL_30:.*]] = llvm.getelementptr %[[VAL_0]]{{\[}}0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<{{.*}}>
// CHECK:         %[[VAL_31:.*]] = llvm.load %[[VAL_30]] : !llvm.ptr -> !llvm.ptr
// CHECK:         %[[VAL_21:.*]] = llvm.mlir.constant(0 : i64) : i64
// CHECK:         %[[VAL_33:.*]] = llvm.getelementptr %[[VAL_31]]{{\[}}%[[VAL_21]], 1, %[[VAL_4]]] : (!llvm.ptr, i64, i64) -> !llvm.ptr, !llvm.struct<{{.*}}>

// More offset computation with descriptor strides and triplets that is not character specific ...

  %2 = fir.rebox %arg0 [%1] : (!fir.box<!fir.array<?x!fir.type<t{i:i32,c:!fir.char<1,10>}>>>, !fir.slice<1>) -> !fir.box<!fir.array<?x!fir.char<1,?>>>
  fir.call @bar(%2) : (!fir.box<!fir.array<?x!fir.char<1,?>>>) -> ()
  return
}

// Test that a rebox with `index` substring parameter is converted
// to legal IR. It used to produce:
//   %63 = "llvm.mul"(%62, <<NULL VALUE>>) : (i64, <<NULL TYPE>>) -> i64
// because the substr was not accessed via the adaptor's operands.

// CHECK-LABEL: llvm.func @index_substr(
// CHECK-NOT: NULL_VALUE
// CHECK-NOT: NULL_TYPE
func.func @index_substr(%arg0: !fir.box<!fir.array<?x!fir.char<1,20>>>) {
  %c7_index = arith.constant 7 : index
  %c1_i64 = arith.constant 1 : i64
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %0:3 = fir.box_dims %arg0, %c0 : (!fir.box<!fir.array<?x!fir.char<1,20>>>, index) -> (index, index, index)
  %1 = fir.slice %c1, %0#1, %c1_i64 substr %c1_i64, %c7_index : (index, index, i64, i64, index) -> !fir.slice<1>
  %2 = fir.rebox %arg0 [%1] : (!fir.box<!fir.array<?x!fir.char<1,20>>>, !fir.slice<1>) -> !fir.box<!fir.array<?x!fir.char<1,?>>>
  fir.call @bar(%2) : (!fir.box<!fir.array<?x!fir.char<1,?>>>) -> ()
  return
}

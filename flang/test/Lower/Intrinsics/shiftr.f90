! RUN: bbc -emit-fir -hlfir=false %s -o - | FileCheck %s
! RUN: %flang_fc1 -emit-fir -flang-deprecated-no-hlfir %s -o - | FileCheck %s

! CHECK-LABEL: shiftr1_test
! CHECK-SAME: %[[A:.*]]: !fir.ref<i8>{{.*}}, %[[B:.*]]: !fir.ref<i32>{{.*}}, %[[C:.*]]: !fir.ref<i8>{{.*}}
subroutine shiftr1_test(a, b, c)
  integer(kind=1) :: a
  integer :: b
  integer(kind=1) :: c

  ! CHECK: %[[A_VAL:.*]] = fir.load %[[A]] : !fir.ref<i8>
  ! CHECK: %[[B_VAL:.*]] = fir.load %[[B]] : !fir.ref<i32>
  c = shiftr(a, b)
  ! CHECK: %[[C_BITS:.*]] = arith.constant 8 : i8
  ! CHECK: %[[C_0:.*]] = arith.constant 0 : i8
  ! CHECK: %[[B_CONV:.*]] = fir.convert %[[B_VAL]] : (i32) -> i8
  ! CHECK: %[[UNDER:.*]] = arith.cmpi slt, %[[B_CONV]], %[[C_0]] : i8
  ! CHECK: %[[OVER:.*]] = arith.cmpi sge, %[[B_CONV]], %[[C_BITS]] : i8
  ! CHECK: %[[INVALID:.*]] = arith.ori %[[UNDER]], %[[OVER]] : i1
  ! CHECK: %[[SHIFT:.*]] = arith.shrui %[[A_VAL]], %[[B_CONV]] : i8
  ! CHECK: %[[RES:.*]] = arith.select %[[INVALID]], %[[C_0]], %[[SHIFT]] : i8
end subroutine shiftr1_test

! CHECK-LABEL: shiftr2_test
! CHECK-SAME: %[[A:.*]]: !fir.ref<i16>{{.*}}, %[[B:.*]]: !fir.ref<i32>{{.*}}, %[[C:.*]]: !fir.ref<i16>{{.*}}
subroutine shiftr2_test(a, b, c)
  integer(kind=2) :: a
  integer :: b
  integer(kind=2) :: c

  ! CHECK: %[[A_VAL:.*]] = fir.load %[[A]] : !fir.ref<i16>
  ! CHECK: %[[B_VAL:.*]] = fir.load %[[B]] : !fir.ref<i32>
  c = shiftr(a, b)
  ! CHECK: %[[C_BITS:.*]] = arith.constant 16 : i16
  ! CHECK: %[[C_0:.*]] = arith.constant 0 : i16
  ! CHECK: %[[B_CONV:.*]] = fir.convert %[[B_VAL]] : (i32) -> i16
  ! CHECK: %[[UNDER:.*]] = arith.cmpi slt, %[[B_CONV]], %[[C_0]] : i16
  ! CHECK: %[[OVER:.*]] = arith.cmpi sge, %[[B_CONV]], %[[C_BITS]] : i16
  ! CHECK: %[[INVALID:.*]] = arith.ori %[[UNDER]], %[[OVER]] : i1
  ! CHECK: %[[SHIFT:.*]] = arith.shrui %[[A_VAL]], %[[B_CONV]] : i16
  ! CHECK: %[[RES:.*]] = arith.select %[[INVALID]], %[[C_0]], %[[SHIFT]] : i16
end subroutine shiftr2_test

! CHECK-LABEL: shiftr4_test
! CHECK-SAME: %[[A:.*]]: !fir.ref<i32>{{.*}}, %[[B:.*]]: !fir.ref<i32>{{.*}}, %[[C:.*]]: !fir.ref<i32>{{.*}}
subroutine shiftr4_test(a, b, c)
  integer(kind=4) :: a
  integer :: b
  integer(kind=4) :: c

  ! CHECK: %[[A_VAL:.*]] = fir.load %[[A]] : !fir.ref<i32>
  ! CHECK: %[[B_VAL:.*]] = fir.load %[[B]] : !fir.ref<i32>
  c = shiftr(a, b)
  ! CHECK: %[[C_BITS:.*]] = arith.constant 32 : i32
  ! CHECK: %[[C_0:.*]] = arith.constant 0 : i32
  ! CHECK: %[[UNDER:.*]] = arith.cmpi slt, %[[B_VAL]], %[[C_0]] : i32
  ! CHECK: %[[OVER:.*]] = arith.cmpi sge, %[[B_VAL]], %[[C_BITS]] : i32
  ! CHECK: %[[INVALID:.*]] = arith.ori %[[UNDER]], %[[OVER]] : i1
  ! CHECK: %[[SHIFT:.*]] = arith.shrui %[[A_VAL]], %[[B_VAL]] : i32
  ! CHECK: %[[RES:.*]] = arith.select %[[INVALID]], %[[C_0]], %[[SHIFT]] : i32
end subroutine shiftr4_test

! CHECK-LABEL: shiftr8_test
! CHECK-SAME: %[[A:.*]]: !fir.ref<i64>{{.*}}, %[[B:.*]]: !fir.ref<i32>{{.*}}, %[[C:.*]]: !fir.ref<i64>{{.*}}
subroutine shiftr8_test(a, b, c)
  integer(kind=8) :: a
  integer :: b
  integer(kind=8) :: c

  ! CHECK: %[[A_VAL:.*]] = fir.load %[[A]] : !fir.ref<i64>
  ! CHECK: %[[B_VAL:.*]] = fir.load %[[B]] : !fir.ref<i32>
  c = shiftr(a, b)
  ! CHECK: %[[C_BITS:.*]] = arith.constant 64 : i64
  ! CHECK: %[[C_0:.*]] = arith.constant 0 : i64
  ! CHECK: %[[B_CONV:.*]] = fir.convert %[[B_VAL]] : (i32) -> i64
  ! CHECK: %[[UNDER:.*]] = arith.cmpi slt, %[[B_CONV]], %[[C_0]] : i64
  ! CHECK: %[[OVER:.*]] = arith.cmpi sge, %[[B_CONV]], %[[C_BITS]] : i64
  ! CHECK: %[[INVALID:.*]] = arith.ori %[[UNDER]], %[[OVER]] : i1
  ! CHECK: %[[SHIFT:.*]] = arith.shrui %[[A_VAL]], %[[B_CONV]] : i64
  ! CHECK: %[[RES:.*]] = arith.select %[[INVALID]], %[[C_0]], %[[SHIFT]] : i64
end subroutine shiftr8_test

! CHECK-LABEL: shiftr16_test
! CHECK-SAME: %[[A:.*]]: !fir.ref<i128>{{.*}}, %[[B:.*]]: !fir.ref<i32>{{.*}}, %[[C:.*]]: !fir.ref<i128>{{.*}}
subroutine shiftr16_test(a, b, c)
  integer(kind=16) :: a
  integer :: b
  integer(kind=16) :: c

  ! CHECK: %[[A_VAL:.*]] = fir.load %[[A]] : !fir.ref<i128>
  ! CHECK: %[[B_VAL:.*]] = fir.load %[[B]] : !fir.ref<i32>
  c = shiftr(a, b)
  ! CHECK: %[[C_BITS:.*]] = arith.constant 128 : i128
  ! CHECK: %[[C_0:.*]] = arith.constant 0 : i128
  ! CHECK: %[[B_CONV:.*]] = fir.convert %[[B_VAL]] : (i32) -> i128
  ! CHECK: %[[UNDER:.*]] = arith.cmpi slt, %[[B_CONV]], %[[C_0]] : i128
  ! CHECK: %[[OVER:.*]] = arith.cmpi sge, %[[B_CONV]], %[[C_BITS]] : i128
  ! CHECK: %[[INVALID:.*]] = arith.ori %[[UNDER]], %[[OVER]] : i1
  ! CHECK: %[[SHIFT:.*]] = arith.shrui %[[A_VAL]], %[[B_CONV]] : i128
  ! CHECK: %[[RES:.*]] = arith.select %[[INVALID]], %[[C_0]], %[[SHIFT]] : i128
end subroutine shiftr16_test

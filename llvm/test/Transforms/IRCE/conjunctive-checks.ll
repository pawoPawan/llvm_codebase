; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -verify-loop-info -passes=irce < %s | FileCheck %s
; RUN: opt -S -verify-loop-info -passes='require<branch-prob>,irce' < %s | FileCheck %s

define void @f_0(ptr %arr, ptr %a_len_ptr, i32 %n, ptr %cond_buf) {
; CHECK-LABEL: @f_0(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LEN:%.*]] = load i32, ptr [[A_LEN_PTR:%.*]], align 4, !range [[RNG0:![0-9]+]]
; CHECK-NEXT:    [[FIRST_ITR_CHECK:%.*]] = icmp sgt i32 [[N:%.*]], 0
; CHECK-NEXT:    br i1 [[FIRST_ITR_CHECK]], label [[LOOP_PREHEADER:%.*]], label [[EXIT:%.*]]
; CHECK:       loop.preheader:
; CHECK-NEXT:    [[TMP0:%.*]] = add nsw i32 [[LEN]], -4
; CHECK-NEXT:    [[SMIN:%.*]] = call i32 @llvm.smin.i32(i32 [[N]], i32 [[TMP0]])
; CHECK-NEXT:    [[EXIT_MAINLOOP_AT:%.*]] = call i32 @llvm.smax.i32(i32 [[SMIN]], i32 0)
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i32 0, [[EXIT_MAINLOOP_AT]]
; CHECK-NEXT:    br i1 [[TMP1]], label [[LOOP_PREHEADER1:%.*]], label [[MAIN_PSEUDO_EXIT:%.*]]
; CHECK:       loop.preheader1:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IDX:%.*]] = phi i32 [ [[IDX_NEXT:%.*]], [[IN_BOUNDS:%.*]] ], [ 0, [[LOOP_PREHEADER1]] ]
; CHECK-NEXT:    [[IDX_NEXT]] = add nsw i32 [[IDX]], 1
; CHECK-NEXT:    [[IDX_FOR_ABC:%.*]] = add i32 [[IDX]], 4
; CHECK-NEXT:    [[ABC_ACTUAL:%.*]] = icmp slt i32 [[IDX_FOR_ABC]], [[LEN]]
; CHECK-NEXT:    [[COND:%.*]] = load volatile i1, ptr [[COND_BUF:%.*]], align 1
; CHECK-NEXT:    [[ABC:%.*]] = and i1 [[COND]], true
; CHECK-NEXT:    br i1 [[ABC]], label [[IN_BOUNDS]], label [[OUT_OF_BOUNDS_LOOPEXIT2:%.*]], !prof [[PROF1:![0-9]+]]
; CHECK:       in.bounds:
; CHECK-NEXT:    [[ADDR:%.*]] = getelementptr i32, ptr [[ARR:%.*]], i32 [[IDX_FOR_ABC]]
; CHECK-NEXT:    store i32 0, ptr [[ADDR]], align 4
; CHECK-NEXT:    [[NEXT:%.*]] = icmp slt i32 [[IDX_NEXT]], [[N]]
; CHECK-NEXT:    [[TMP2:%.*]] = icmp slt i32 [[IDX_NEXT]], [[EXIT_MAINLOOP_AT]]
; CHECK-NEXT:    br i1 [[TMP2]], label [[LOOP]], label [[MAIN_EXIT_SELECTOR:%.*]]
; CHECK:       main.exit.selector:
; CHECK-NEXT:    [[IDX_NEXT_LCSSA:%.*]] = phi i32 [ [[IDX_NEXT]], [[IN_BOUNDS]] ]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp slt i32 [[IDX_NEXT_LCSSA]], [[N]]
; CHECK-NEXT:    br i1 [[TMP3]], label [[MAIN_PSEUDO_EXIT]], label [[EXIT_LOOPEXIT:%.*]]
; CHECK:       main.pseudo.exit:
; CHECK-NEXT:    [[IDX_COPY:%.*]] = phi i32 [ 0, [[LOOP_PREHEADER]] ], [ [[IDX_NEXT_LCSSA]], [[MAIN_EXIT_SELECTOR]] ]
; CHECK-NEXT:    [[INDVAR_END:%.*]] = phi i32 [ 0, [[LOOP_PREHEADER]] ], [ [[IDX_NEXT_LCSSA]], [[MAIN_EXIT_SELECTOR]] ]
; CHECK-NEXT:    br label [[POSTLOOP:%.*]]
; CHECK:       out.of.bounds.loopexit:
; CHECK-NEXT:    br label [[OUT_OF_BOUNDS:%.*]]
; CHECK:       out.of.bounds.loopexit2:
; CHECK-NEXT:    br label [[OUT_OF_BOUNDS]]
; CHECK:       out.of.bounds:
; CHECK-NEXT:    ret void
; CHECK:       exit.loopexit.loopexit:
; CHECK-NEXT:    br label [[EXIT_LOOPEXIT]]
; CHECK:       exit.loopexit:
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
; CHECK:       postloop:
; CHECK-NEXT:    br label [[LOOP_POSTLOOP:%.*]]
; CHECK:       loop.postloop:
; CHECK-NEXT:    [[IDX_POSTLOOP:%.*]] = phi i32 [ [[IDX_NEXT_POSTLOOP:%.*]], [[IN_BOUNDS_POSTLOOP:%.*]] ], [ [[IDX_COPY]], [[POSTLOOP]] ]
; CHECK-NEXT:    [[IDX_NEXT_POSTLOOP]] = add i32 [[IDX_POSTLOOP]], 1
; CHECK-NEXT:    [[IDX_FOR_ABC_POSTLOOP:%.*]] = add i32 [[IDX_POSTLOOP]], 4
; CHECK-NEXT:    [[ABC_ACTUAL_POSTLOOP:%.*]] = icmp slt i32 [[IDX_FOR_ABC_POSTLOOP]], [[LEN]]
; CHECK-NEXT:    [[COND_POSTLOOP:%.*]] = load volatile i1, ptr [[COND_BUF]], align 1
; CHECK-NEXT:    [[ABC_POSTLOOP:%.*]] = and i1 [[COND_POSTLOOP]], [[ABC_ACTUAL_POSTLOOP]]
; CHECK-NEXT:    br i1 [[ABC_POSTLOOP]], label [[IN_BOUNDS_POSTLOOP]], label [[OUT_OF_BOUNDS_LOOPEXIT:%.*]], !prof [[PROF1]]
; CHECK:       in.bounds.postloop:
; CHECK-NEXT:    [[ADDR_POSTLOOP:%.*]] = getelementptr i32, ptr [[ARR]], i32 [[IDX_FOR_ABC_POSTLOOP]]
; CHECK-NEXT:    store i32 0, ptr [[ADDR_POSTLOOP]], align 4
; CHECK-NEXT:    [[NEXT_POSTLOOP:%.*]] = icmp slt i32 [[IDX_NEXT_POSTLOOP]], [[N]]
; CHECK-NEXT:    br i1 [[NEXT_POSTLOOP]], label [[LOOP_POSTLOOP]], label [[EXIT_LOOPEXIT_LOOPEXIT:%.*]], !llvm.loop [[LOOP2:![0-9]+]], !loop_constrainer.loop.clone [[META7:![0-9]+]]
;
entry:
  %len = load i32, ptr %a_len_ptr, !range !0
  %first.itr.check = icmp sgt i32 %n, 0
  br i1 %first.itr.check, label %loop, label %exit

loop:
  %idx = phi i32 [ 0, %entry ] , [ %idx.next, %in.bounds ]
  %idx.next = add i32 %idx, 1
  %idx.for.abc = add i32 %idx, 4
  %abc.actual = icmp slt i32 %idx.for.abc, %len
  %cond = load volatile i1, ptr %cond_buf
  %abc = and i1 %cond, %abc.actual
  br i1 %abc, label %in.bounds, label %out.of.bounds, !prof !1

in.bounds:
  %addr = getelementptr i32, ptr %arr, i32 %idx.for.abc
  store i32 0, ptr %addr
  %next = icmp slt i32 %idx.next, %n
  br i1 %next, label %loop, label %exit

out.of.bounds:
  ret void

exit:
  ret void
}

define void @f_1(
; CHECK-LABEL: @f_1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LEN_A:%.*]] = load i32, ptr [[A_LEN_PTR:%.*]], align 4, !range [[RNG0]]
; CHECK-NEXT:    [[LEN_B:%.*]] = load i32, ptr [[B_LEN_PTR:%.*]], align 4, !range [[RNG0]]
; CHECK-NEXT:    [[FIRST_ITR_CHECK:%.*]] = icmp sgt i32 [[N:%.*]], 0
; CHECK-NEXT:    br i1 [[FIRST_ITR_CHECK]], label [[LOOP_PREHEADER:%.*]], label [[EXIT:%.*]]
; CHECK:       loop.preheader:
; CHECK-NEXT:    [[SMIN:%.*]] = call i32 @llvm.smin.i32(i32 [[LEN_B]], i32 [[LEN_A]])
; CHECK-NEXT:    [[SMIN1:%.*]] = call i32 @llvm.smin.i32(i32 [[SMIN]], i32 [[N]])
; CHECK-NEXT:    [[EXIT_MAINLOOP_AT:%.*]] = call i32 @llvm.smax.i32(i32 [[SMIN1]], i32 0)
; CHECK-NEXT:    [[TMP0:%.*]] = icmp slt i32 0, [[EXIT_MAINLOOP_AT]]
; CHECK-NEXT:    br i1 [[TMP0]], label [[LOOP_PREHEADER2:%.*]], label [[MAIN_PSEUDO_EXIT:%.*]]
; CHECK:       loop.preheader2:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IDX:%.*]] = phi i32 [ [[IDX_NEXT:%.*]], [[IN_BOUNDS:%.*]] ], [ 0, [[LOOP_PREHEADER2]] ]
; CHECK-NEXT:    [[IDX_NEXT]] = add nsw i32 [[IDX]], 1
; CHECK-NEXT:    [[ABC_A:%.*]] = icmp slt i32 [[IDX]], [[LEN_A]]
; CHECK-NEXT:    [[ABC_B:%.*]] = icmp slt i32 [[IDX]], [[LEN_B]]
; CHECK-NEXT:    [[ABC:%.*]] = and i1 true, true
; CHECK-NEXT:    br i1 [[ABC]], label [[IN_BOUNDS]], label [[OUT_OF_BOUNDS_LOOPEXIT3:%.*]], !prof [[PROF1]]
; CHECK:       in.bounds:
; CHECK-NEXT:    [[ADDR_A:%.*]] = getelementptr i32, ptr [[ARR_A:%.*]], i32 [[IDX]]
; CHECK-NEXT:    store i32 0, ptr [[ADDR_A]], align 4
; CHECK-NEXT:    [[ADDR_B:%.*]] = getelementptr i32, ptr [[ARR_B:%.*]], i32 [[IDX]]
; CHECK-NEXT:    store i32 -1, ptr [[ADDR_B]], align 4
; CHECK-NEXT:    [[NEXT:%.*]] = icmp slt i32 [[IDX_NEXT]], [[N]]
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i32 [[IDX_NEXT]], [[EXIT_MAINLOOP_AT]]
; CHECK-NEXT:    br i1 [[TMP1]], label [[LOOP]], label [[MAIN_EXIT_SELECTOR:%.*]]
; CHECK:       main.exit.selector:
; CHECK-NEXT:    [[IDX_NEXT_LCSSA:%.*]] = phi i32 [ [[IDX_NEXT]], [[IN_BOUNDS]] ]
; CHECK-NEXT:    [[TMP2:%.*]] = icmp slt i32 [[IDX_NEXT_LCSSA]], [[N]]
; CHECK-NEXT:    br i1 [[TMP2]], label [[MAIN_PSEUDO_EXIT]], label [[EXIT_LOOPEXIT:%.*]]
; CHECK:       main.pseudo.exit:
; CHECK-NEXT:    [[IDX_COPY:%.*]] = phi i32 [ 0, [[LOOP_PREHEADER]] ], [ [[IDX_NEXT_LCSSA]], [[MAIN_EXIT_SELECTOR]] ]
; CHECK-NEXT:    [[INDVAR_END:%.*]] = phi i32 [ 0, [[LOOP_PREHEADER]] ], [ [[IDX_NEXT_LCSSA]], [[MAIN_EXIT_SELECTOR]] ]
; CHECK-NEXT:    br label [[POSTLOOP:%.*]]
; CHECK:       out.of.bounds.loopexit:
; CHECK-NEXT:    br label [[OUT_OF_BOUNDS:%.*]]
; CHECK:       out.of.bounds.loopexit3:
; CHECK-NEXT:    br label [[OUT_OF_BOUNDS]]
; CHECK:       out.of.bounds:
; CHECK-NEXT:    ret void
; CHECK:       exit.loopexit.loopexit:
; CHECK-NEXT:    br label [[EXIT_LOOPEXIT]]
; CHECK:       exit.loopexit:
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
; CHECK:       postloop:
; CHECK-NEXT:    br label [[LOOP_POSTLOOP:%.*]]
; CHECK:       loop.postloop:
; CHECK-NEXT:    [[IDX_POSTLOOP:%.*]] = phi i32 [ [[IDX_NEXT_POSTLOOP:%.*]], [[IN_BOUNDS_POSTLOOP:%.*]] ], [ [[IDX_COPY]], [[POSTLOOP]] ]
; CHECK-NEXT:    [[IDX_NEXT_POSTLOOP]] = add i32 [[IDX_POSTLOOP]], 1
; CHECK-NEXT:    [[ABC_A_POSTLOOP:%.*]] = icmp slt i32 [[IDX_POSTLOOP]], [[LEN_A]]
; CHECK-NEXT:    [[ABC_B_POSTLOOP:%.*]] = icmp slt i32 [[IDX_POSTLOOP]], [[LEN_B]]
; CHECK-NEXT:    [[ABC_POSTLOOP:%.*]] = and i1 [[ABC_A_POSTLOOP]], [[ABC_B_POSTLOOP]]
; CHECK-NEXT:    br i1 [[ABC_POSTLOOP]], label [[IN_BOUNDS_POSTLOOP]], label [[OUT_OF_BOUNDS_LOOPEXIT:%.*]], !prof [[PROF1]]
; CHECK:       in.bounds.postloop:
; CHECK-NEXT:    [[ADDR_A_POSTLOOP:%.*]] = getelementptr i32, ptr [[ARR_A]], i32 [[IDX_POSTLOOP]]
; CHECK-NEXT:    store i32 0, ptr [[ADDR_A_POSTLOOP]], align 4
; CHECK-NEXT:    [[ADDR_B_POSTLOOP:%.*]] = getelementptr i32, ptr [[ARR_B]], i32 [[IDX_POSTLOOP]]
; CHECK-NEXT:    store i32 -1, ptr [[ADDR_B_POSTLOOP]], align 4
; CHECK-NEXT:    [[NEXT_POSTLOOP:%.*]] = icmp slt i32 [[IDX_NEXT_POSTLOOP]], [[N]]
; CHECK-NEXT:    br i1 [[NEXT_POSTLOOP]], label [[LOOP_POSTLOOP]], label [[EXIT_LOOPEXIT_LOOPEXIT:%.*]], !llvm.loop [[LOOP8:![0-9]+]], !loop_constrainer.loop.clone [[META7]]
;
  ptr %arr_a, ptr %a_len_ptr, ptr %arr_b, ptr %b_len_ptr, i32 %n) {


entry:
  %len.a = load i32, ptr %a_len_ptr, !range !0
  %len.b = load i32, ptr %b_len_ptr, !range !0
  %first.itr.check = icmp sgt i32 %n, 0
  br i1 %first.itr.check, label %loop, label %exit

loop:
  %idx = phi i32 [ 0, %entry ] , [ %idx.next, %in.bounds ]
  %idx.next = add i32 %idx, 1
  %abc.a = icmp slt i32 %idx, %len.a
  %abc.b = icmp slt i32 %idx, %len.b
  %abc = and i1 %abc.a, %abc.b
  br i1 %abc, label %in.bounds, label %out.of.bounds, !prof !1

in.bounds:
  %addr.a = getelementptr i32, ptr %arr_a, i32 %idx
  store i32 0, ptr %addr.a
  %addr.b = getelementptr i32, ptr %arr_b, i32 %idx
  store i32 -1, ptr %addr.b
  %next = icmp slt i32 %idx.next, %n
  br i1 %next, label %loop, label %exit

out.of.bounds:
  ret void

exit:
  ret void
}

!0 = !{i32 0, i32 2147483647}
!1 = !{!"branch_weights", i32 64, i32 4}

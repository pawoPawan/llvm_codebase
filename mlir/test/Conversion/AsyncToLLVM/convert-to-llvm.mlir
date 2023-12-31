// RUN: mlir-opt %s -split-input-file -async-to-async-runtime -convert-async-to-llvm | FileCheck %s

// CHECK-LABEL: reference_counting
func.func @reference_counting(%arg0: !async.token) {
  // CHECK: %[[C2:.*]] = arith.constant 2 : i64
  // CHECK: call @mlirAsyncRuntimeAddRef(%arg0, %[[C2]])
  async.runtime.add_ref %arg0 {count = 2 : i64} : !async.token

  // CHECK: %[[C1:.*]] = arith.constant 1 : i64
  // CHECK: call @mlirAsyncRuntimeDropRef(%arg0, %[[C1]])
  async.runtime.drop_ref %arg0 {count = 1 : i64} : !async.token

  return
}

// -----

// CHECK-LABEL: execute_no_async_args
func.func @execute_no_async_args(%arg0: f32, %arg1: memref<1xf32>) {
  // CHECK: %[[TOKEN:.*]] = call @async_execute_fn(%arg0, %arg1)
  %token = async.execute {
    %c0 = arith.constant 0 : index
    memref.store %arg0, %arg1[%c0] : memref<1xf32>
    async.yield
  }
  // CHECK: call @mlirAsyncRuntimeAwaitToken(%[[TOKEN]])
  // CHECK: %[[IS_ERROR:.*]] = call @mlirAsyncRuntimeIsTokenError(%[[TOKEN]])
  // CHECK: %[[TRUE:.*]] = arith.constant true
  // CHECK: %[[NOT_ERROR:.*]] = arith.xori %[[IS_ERROR]], %[[TRUE]] : i1
  // CHECK: cf.assert %[[NOT_ERROR]]
  // CHECK-NEXT: return
  async.await %token : !async.token
  return
}

// Function outlined from the async.execute operation.
// CHECK-LABEL: func private @async_execute_fn(%arg0: f32, %arg1: memref<1xf32>)
// CHECK-SAME: -> !llvm.ptr

// Create token for return op, and mark a function as a coroutine.
// CHECK: %[[RET:.*]] = call @mlirAsyncRuntimeCreateToken()
// CHECK: %[[HDL:.*]] = llvm.intr.coro.begin

// Pass a suspended coroutine to the async runtime.
// CHECK: %[[STATE:.*]] = llvm.intr.coro.save
// CHECK: %[[RESUME:.*]] = llvm.mlir.addressof @__resume
// CHECK: call @mlirAsyncRuntimeExecute(%[[HDL]], %[[RESUME]])
// CHECK: %[[SUSPENDED:.*]] = llvm.intr.coro.suspend %[[STATE]]

// Decide the next block based on the code returned from suspend.
// CHECK: %[[SEXT:.*]] = llvm.sext %[[SUSPENDED]] : i8 to i32
// CHECK: llvm.switch %[[SEXT]] : i32, ^[[SUSPEND:[b0-9]+]]
// CHECK-NEXT: 0: ^[[RESUME:[b0-9]+]]
// CHECK-NEXT: 1: ^[[CLEANUP:[b0-9]+]]

// Resume coroutine after suspension.
// CHECK: ^[[RESUME]]:
// CHECK: memref.store %arg0, %arg1[%c0] : memref<1xf32>
// CHECK: call @mlirAsyncRuntimeEmplaceToken(%[[RET]])

// Delete coroutine.
// CHECK: ^[[CLEANUP]]:
// CHECK: %[[MEM:.*]] = llvm.intr.coro.free
// CHECK: llvm.call @free(%[[MEM]])

// Suspend coroutine, and also a return statement for ramp function.
// CHECK: ^[[SUSPEND]]:
// CHECK: llvm.intr.coro.end
// CHECK: return %[[RET]]

// -----

// CHECK-LABEL: nested_async_execute
func.func @nested_async_execute(%arg0: f32, %arg1: f32, %arg2: memref<1xf32>) {
  // CHECK: %[[TOKEN:.*]] = call @async_execute_fn_0(%arg0, %arg2, %arg1)
  %token0 = async.execute {
    %c0 = arith.constant 0 : index

    %token1 = async.execute {
      %c1 = arith.constant 1: index
      memref.store %arg0, %arg2[%c0] : memref<1xf32>
      async.yield
    }
    async.await %token1 : !async.token

    memref.store %arg1, %arg2[%c0] : memref<1xf32>
    async.yield
  }
  // CHECK: call @mlirAsyncRuntimeAwaitToken(%[[TOKEN]])
  // CHECK: %[[IS_ERROR:.*]] = call @mlirAsyncRuntimeIsTokenError(%[[TOKEN]])
  // CHECK: %[[TRUE:.*]] = arith.constant true
  // CHECK: %[[NOT_ERROR:.*]] = arith.xori %[[IS_ERROR]], %[[TRUE]] : i1
  // CHECK: cf.assert %[[NOT_ERROR]]
  async.await %token0 : !async.token
  return
}

// Function outlined from the inner async.execute operation.
// CHECK-LABEL: func private @async_execute_fn(%arg0: f32, %arg1: memref<1xf32>)
// CHECK-SAME: -> !llvm.ptr
// CHECK: %[[RET_0:.*]] = call @mlirAsyncRuntimeCreateToken()
// CHECK: %[[HDL_0:.*]] = llvm.intr.coro.begin
// CHECK: call @mlirAsyncRuntimeExecute
// CHECK: llvm.intr.coro.suspend
// CHECK: %[[C0:.*]] = arith.constant 0 : index
// CHECK: memref.store %arg0, %arg1[%[[C0]]] : memref<1xf32>
// CHECK: call @mlirAsyncRuntimeEmplaceToken(%[[RET_0]])

// Function outlined from the outer async.execute operation.
// CHECK-LABEL: func private @async_execute_fn_0(%arg0: f32, %arg1: memref<1xf32>, %arg2: f32)
// CHECK-SAME: -> !llvm.ptr
// CHECK: %[[RET_1:.*]] = call @mlirAsyncRuntimeCreateToken()
// CHECK: %[[HDL_1:.*]] = llvm.intr.coro.begin

// Suspend coroutine in the beginning.
// CHECK: call @mlirAsyncRuntimeExecute
// CHECK: llvm.intr.coro.suspend

// Suspend coroutine second time waiting for the completion of inner execute op.
// CHECK: %[[TOKEN_1:.*]] = call @async_execute_fn
// CHECK: llvm.intr.coro.save
// CHECK: call @mlirAsyncRuntimeAwaitTokenAndExecute(%[[TOKEN_1]], %[[HDL_1]]
// CHECK: llvm.intr.coro.suspend

// Emplace result token after second resumption.
// CHECK: memref.store %arg2, %arg1[%c0] : memref<1xf32>
// CHECK: call @mlirAsyncRuntimeEmplaceToken(%[[RET_1]])

// -----

// CHECK-LABEL: async_execute_token_dependency
func.func @async_execute_token_dependency(%arg0: f32, %arg1: memref<1xf32>) {
  // CHECK: %0 = call @async_execute_fn(%arg0, %arg1)
  %token = async.execute {
    %c0 = arith.constant 0 : index
    memref.store %arg0, %arg1[%c0] : memref<1xf32>
    async.yield
  }
  // CHECK: %1 = call @async_execute_fn_0(%0, %arg0, %arg1)
  %token_0 = async.execute [%token] {
    %c0 = arith.constant 0 : index
    memref.store %arg0, %arg1[%c0] : memref<1xf32>
    async.yield
  }
  return
}

// Function outlined from the first async.execute operation.
// CHECK-LABEL: func private @async_execute_fn(%arg0: f32, %arg1: memref<1xf32>)
// CHECK-SAME: -> !llvm.ptr
// CHECK: %[[RET_0:.*]] = call @mlirAsyncRuntimeCreateToken()
// CHECK: %[[HDL_0:.*]] = llvm.intr.coro.begin
// CHECK: call @mlirAsyncRuntimeExecute
// CHECK: llvm.intr.coro.suspend
// CHECK: memref.store %arg0, %arg1[%c0] : memref<1xf32>
// CHECK: call @mlirAsyncRuntimeEmplaceToken(%[[RET_0]])

// Function outlined from the second async.execute operation with dependency.
// CHECK-LABEL: func private @async_execute_fn_0(%arg0: !llvm.ptr, %arg1: f32, %arg2: memref<1xf32>)
// CHECK-SAME: -> !llvm.ptr
// CHECK: %[[RET_1:.*]] = call @mlirAsyncRuntimeCreateToken()
// CHECK: %[[HDL_1:.*]] = llvm.intr.coro.begin

// Suspend coroutine in the beginning.
// CHECK: call @mlirAsyncRuntimeExecute(%[[HDL_1]],
// CHECK: llvm.intr.coro.suspend

// Suspend coroutine second time waiting for the completion of token dependency.
// CHECK: llvm.intr.coro.save
// CHECK: call @mlirAsyncRuntimeAwaitTokenAndExecute(%arg0, %[[HDL_1]],
// CHECK: llvm.intr.coro.suspend

// Emplace result token after second resumption.
// CHECK: memref.store %arg1, %arg2[%c0] : memref<1xf32>
// CHECK: call @mlirAsyncRuntimeEmplaceToken(%[[RET_1]])

// -----

// CHECK-LABEL: async_group_await_all
func.func @async_group_await_all(%arg0: f32, %arg1: memref<1xf32>) {
  %c = arith.constant 1 : index
  // CHECK: %[[GROUP:.*]] = call @mlirAsyncRuntimeCreateGroup
  %0 = async.create_group %c : !async.group

  // CHECK: %[[TOKEN:.*]] = call @async_execute_fn
  %token = async.execute { async.yield }
  // CHECK: call @mlirAsyncRuntimeAddTokenToGroup(%[[TOKEN]], %[[GROUP]])
  async.add_to_group %token, %0 : !async.token

  // CHECK: call @async_execute_fn_0
  async.execute {
    async.await_all %0
    async.yield
  }

  // CHECK: call @mlirAsyncRuntimeAwaitAllInGroup(%[[GROUP]])
  async.await_all %0

  return
}

// Function outlined from the async.execute operation.
// CHECK: func private @async_execute_fn_0(%arg0: !llvm.ptr)
// CHECK: %[[RET_1:.*]] = call @mlirAsyncRuntimeCreateToken()
// CHECK: %[[HDL_1:.*]] = llvm.intr.coro.begin

// Suspend coroutine in the beginning.
// CHECK: call @mlirAsyncRuntimeExecute(%[[HDL_1]],
// CHECK: llvm.intr.coro.suspend

// Suspend coroutine second time waiting for the group.
// CHECK: llvm.intr.coro.save
// CHECK: call @mlirAsyncRuntimeAwaitAllInGroupAndExecute(%arg0, %[[HDL_1]],
// CHECK: llvm.intr.coro.suspend

// Emplace result token.
// CHECK: call @mlirAsyncRuntimeEmplaceToken(%[[RET_1]])

// -----

// CHECK-LABEL: execute_and_return_f32
func.func @execute_and_return_f32() -> f32 {
 // CHECK: %[[RET:.*]]:2 = call @async_execute_fn
  %token, %result = async.execute -> !async.value<f32> {
    %c0 = arith.constant 123.0 : f32
    async.yield %c0 : f32
  }

  // CHECK: %[[STORAGE:.*]] = call @mlirAsyncRuntimeGetValueStorage(%[[RET]]#1)
  // CHECK: %[[LOADED:.*]] = llvm.load %[[STORAGE]] : !llvm.ptr -> f32
  %0 = async.await %result : !async.value<f32>

  return %0 : f32
}

// Function outlined from the async.execute operation.
// CHECK-LABEL: func private @async_execute_fn()
// CHECK: %[[TOKEN:.*]] = call @mlirAsyncRuntimeCreateToken()
// CHECK: %[[VALUE:.*]] = call @mlirAsyncRuntimeCreateValue
// CHECK: %[[HDL:.*]] = llvm.intr.coro.begin

// Suspend coroutine in the beginning.
// CHECK: call @mlirAsyncRuntimeExecute(%[[HDL]],
// CHECK: llvm.intr.coro.suspend

// Emplace result value.
// CHECK: %[[CST:.*]] = arith.constant 1.230000e+02 : f32
// CHECK: %[[STORAGE:.*]] = call @mlirAsyncRuntimeGetValueStorage(%[[VALUE]])
// CHECK: llvm.store %[[CST]], %[[STORAGE]] : f32, !llvm.ptr
// CHECK: call @mlirAsyncRuntimeEmplaceValue(%[[VALUE]])

// Emplace result token.
// CHECK: call @mlirAsyncRuntimeEmplaceToken(%[[TOKEN]])

// -----

// CHECK-LABEL: @async_value_operands
func.func @async_value_operands() {
  // CHECK: %[[RET:.*]]:2 = call @async_execute_fn
  %token, %result = async.execute -> !async.value<f32> {
    %c0 = arith.constant 123.0 : f32
    async.yield %c0 : f32
  }

  // CHECK: %[[TOKEN:.*]] = call @async_execute_fn_0(%[[RET]]#1)
  %token0 = async.execute(%result as %value: !async.value<f32>) {
    %0 = arith.addf %value, %value : f32
    async.yield
  }

  // CHECK: call @mlirAsyncRuntimeAwaitToken(%[[TOKEN]])
  async.await %token0 : !async.token

  return
}

// Function outlined from the first async.execute operation.
// CHECK-LABEL: func private @async_execute_fn()

// Function outlined from the second async.execute operation.
// CHECK-LABEL: func private @async_execute_fn_0(%arg0: !llvm.ptr)
// CHECK: %[[TOKEN:.*]] = call @mlirAsyncRuntimeCreateToken()
// CHECK: %[[HDL:.*]] = llvm.intr.coro.begin

// Suspend coroutine in the beginning.
// CHECK: call @mlirAsyncRuntimeExecute(%[[HDL]],
// CHECK: llvm.intr.coro.suspend

// Suspend coroutine second time waiting for the async operand.
// CHECK: llvm.intr.coro.save
// CHECK: call @mlirAsyncRuntimeAwaitValueAndExecute(%arg0, %[[HDL]],
// CHECK: llvm.intr.coro.suspend

// Get the operand value storage, cast to f32 and add the value.
// CHECK: %[[STORAGE:.*]] = call @mlirAsyncRuntimeGetValueStorage(%arg0)
// CHECK: %[[LOADED:.*]] = llvm.load %[[STORAGE]] : !llvm.ptr -> f32
// CHECK: arith.addf %[[LOADED]], %[[LOADED]] : f32

// Emplace result token.
// CHECK: call @mlirAsyncRuntimeEmplaceToken(%[[TOKEN]])



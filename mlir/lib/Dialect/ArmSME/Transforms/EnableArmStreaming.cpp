//===- EnableArmStreaming.cpp - Enable Armv9 Streaming SVE mode -----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This pass enables the Armv9 Scalable Matrix Extension (SME) Streaming SVE
// (SSVE) mode [1][2] by adding either of the following attributes to
// 'func.func' ops:
//
//   * 'arm_streaming' (default)
//   * 'arm_locally_streaming'
//
// It can also optionally enable the ZA storage array.
//
// Streaming-mode is part of the interface (ABI) for functions with the
// first attribute and it's the responsibility of the caller to manage
// PSTATE.SM on entry/exit to functions with this attribute [3]. The LLVM
// backend will emit 'smstart sm' / 'smstop sm' [4] around calls to
// streaming functions.
//
// In locally streaming functions PSTATE.SM is kept internal and managed by
// the callee on entry/exit. The LLVM backend will emit 'smstart sm' /
// 'smstop sm' in the prologue / epilogue for functions with this
// attribute.
//
// [1] https://developer.arm.com/documentation/ddi0616/aa
// [2] https://llvm.org/docs/AArch64SME.html
// [3] https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst#671pstatesm-interfaces
// [4] https://developer.arm.com/documentation/ddi0602/2023-03/Base-Instructions/SMSTART--Enables-access-to-Streaming-SVE-mode-and-SME-architectural-state--an-alias-of-MSR--immediate--
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/ArmSME/Transforms/Passes.h"
#include "mlir/Dialect/ArmSME/Transforms/PassesEnums.cpp.inc"

#include "mlir/Dialect/Func/IR/FuncOps.h"

#define DEBUG_TYPE "enable-arm-streaming"

namespace mlir {
namespace arm_sme {
#define GEN_PASS_DEF_ENABLEARMSTREAMING
#include "mlir/Dialect/ArmSME/Transforms/Passes.h.inc"
} // namespace arm_sme
} // namespace mlir

using namespace mlir;
using namespace mlir::arm_sme;
namespace {

constexpr StringLiteral
    kEnableArmStreamingIgnoreAttr("enable_arm_streaming_ignore");

struct EnableArmStreamingPass
    : public arm_sme::impl::EnableArmStreamingBase<EnableArmStreamingPass> {
  EnableArmStreamingPass(ArmStreamingMode streamingMode, ArmZaMode zaMode) {
    this->streamingMode = streamingMode;
    this->zaMode = zaMode;
  }
  void runOnOperation() override {
    auto op = getOperation();
    if (op->getAttr(kEnableArmStreamingIgnoreAttr) ||
        streamingMode == ArmStreamingMode::Disabled)
      return;

    auto unitAttr = UnitAttr::get(&getContext());

    op->setAttr(stringifyArmStreamingMode(streamingMode), unitAttr);

    // The pass currently only supports enabling ZA when in streaming-mode, but
    // ZA can be accessed by the SME LDR, STR and ZERO instructions when not in
    // streaming-mode (see section B1.1.1, IDGNQM of spec [1]). It may be worth
    // supporting this later.
    if (zaMode != ArmZaMode::Disabled)
      op->setAttr(stringifyArmZaMode(zaMode), unitAttr);
  }
};
} // namespace

std::unique_ptr<Pass> mlir::arm_sme::createEnableArmStreamingPass(
    const ArmStreamingMode streamingMode, const ArmZaMode zaMode) {
  return std::make_unique<EnableArmStreamingPass>(streamingMode, zaMode);
}

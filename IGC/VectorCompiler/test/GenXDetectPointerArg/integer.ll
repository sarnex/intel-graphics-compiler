;=========================== begin_copyright_notice ============================
;
; Copyright (C) 2024 Intel Corporation
;
; SPDX-License-Identifier: MIT
;
;============================ end_copyright_notice =============================
;
; RUN: %opt %use_old_pass_manager% -GenXDetectPointerArg -march=genx64 -mtriple=spir64-unknown-unknown -mcpu=XeHPC -S < %s | FileCheck %s

@data = internal global <8 x i64> undef, align 64, !spirv.Decorations !0 #0

declare void @llvm.genx.vstore.v8i64.p0v8i64(<8 x i64>, <8 x i64>*) #1

define dllexport spir_kernel void @kernel(i64 %0, i64 %impl.arg.private.base) local_unnamed_addr #2 {
  %2 = tail call <8 x i64> @llvm.vc.internal.lsc.load.ugm.v8i64.i1.v2i8.i64(i1 true, i8 3, i8 4, i8 5, <2 x i8> zeroinitializer, i64 0, i64 %0, i16 1, i32 0, <8 x i64> undef)
  tail call void @llvm.genx.vstore.v8i64.p0v8i64(<8 x i64> %2, <8 x i64>* nonnull @data)
  ret void
}

declare <8 x i64> @llvm.vc.internal.lsc.load.ugm.v8i64.i1.v2i8.i64(i1, i8, i8, i8, <2 x i8>, i64, i64, i16, i32, <8 x i64>) #3

attributes #0 = { "VCByteOffset"="0" "VCGlobalVariable" "VCVolatile" "genx_byte_offset"="0" "genx_volatile" }
attributes #1 = { nounwind "target-cpu"="XeHPC" }
attributes #2 = { noinline nounwind "CMGenxMain" "VC.Stack.Amount"="0" "oclrt"="1" "target-cpu"="XeHPC" }
attributes #3 = { nofree nounwind readonly "target-cpu"="XeHPC" }

!spirv.MemoryModel = !{!5}
!opencl.enable.FP_CONTRACT = !{}
!spirv.Source = !{!6}
!opencl.spir.version = !{!7, !8, !8, !8, !8, !8, !8, !8, !8, !8, !8, !8, !8, !8, !8, !8, !8, !8}
!opencl.ocl.version = !{!6, !8, !8, !8, !8, !8, !8, !8, !8, !8, !8, !8, !8, !8, !8, !8, !8, !8}
!opencl.used.extensions = !{!9}
!opencl.used.optional.core.features = !{!9}
!spirv.Generator = !{!10}
!genx.kernels = !{!11}
!genx.kernel.internal = !{!16}
!llvm.ident = !{!19, !19, !19, !19, !19, !19, !19, !19, !19, !19, !19, !19, !19, !19, !19, !19, !19}
!llvm.module.flags = !{!20}

; CHECK: !genx.kernels = !{![[KERNEL:[0-9]+]]}
; CHECK: ![[KERNEL]] = !{void (i64, i64)* @kernel, !"kernel", !{{[0-9]+}}, i32 0, !{{[0-9]+}}, !{{[0-9]+}}, ![[NODE:[0-9]+]], i32 0}
; CHECK: ![[NODE]] = !{!"svmptr_t", !""}

!0 = !{!1, !2, !3, !4}
!1 = !{i32 21}
!2 = !{i32 44, i32 64}
!3 = !{i32 5624}
!4 = !{i32 5628, i32 0}
!5 = !{i32 2, i32 2}
!6 = !{i32 0, i32 0}
!7 = !{i32 1, i32 2}
!8 = !{i32 2, i32 0}
!9 = !{}
!10 = !{i16 6, i16 14}
!11 = !{void (i64, i64)* @kernel, !"kernel", !12, i32 0, !13, !14, !15, i32 0}
!12 = !{i32 0, i32 96}
!13 = !{i32 136, i32 128}
!14 = !{i32 0}
!15 = !{!""}
!16 = !{void (i64, i64)* @kernel, !6, !17, !9, !18}
!17 = !{i32 0, i32 1}
!18 = !{i32 -1, i32 255}
!19 = !{!"clang version 14.0.5"}
!20 = !{i32 1, !"wchar_size", i32 4}
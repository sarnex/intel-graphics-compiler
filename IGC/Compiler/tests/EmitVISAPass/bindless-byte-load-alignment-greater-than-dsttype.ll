;=========================== begin_copyright_notice ============================
;
; Copyright (C) 2024 Intel Corporation
;
; SPDX-License-Identifier: MIT
;
;============================ end_copyright_notice =============================

; REQUIRES: regkeys, dg2-supported

; RUN: igc_opt -platformdg2 -igc-emit-visa -simd-mode 32 %s -regkey DumpVISAASMToConsole | FileCheck %s

; This test verifies whether uniform bindless byte loads and stores with alignment greater than 1
; can properly be handled by EmitVISAPass. They should simply be treated as memory operations
; with alignment 1.

; The tested module has been generated from the following OpenCL C code:
; kernel void test(global char* in, global char* out)
; {
;     out[1] = in[1];
; }

; However, one small manual modification has been applied on beforeUnification while generating below
; LLVM module. An alignment for load and store instruction has manually been modified from 1 to 2.
; Byte memory instructions with alignment 2 are legal, but we cannot generate them directly from OpenCL C.
; However, SYCL FE Compiler can generate them, so IGC needs to be able to handle such cases properly.

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v16:16:16-v24:32:32-v32:32:32-v48:64:64-v64:64:64-v96:128:128-v128:128:128-v192:256:256-v256:256:256-v512:512:512-v1024:1024:1024-n8:16:32"
target triple = "spir64-unknown-unknown"

; Function Attrs: convergent nounwind
define spir_kernel void @test(i8 addrspace(1)* %in, i8 addrspace(1)* %out, <8 x i32> %r0, <8 x i32> %payloadHeader, i32 %bufferOffset, i32 %bufferOffset1, i32 %bindlessOffset, i32 %bindlessOffset2) #0 {
entry:
  %0 = add i32 %bufferOffset, 1
  %1 = inttoptr i32 %bindlessOffset to i8 addrspace(2490368)*
; CHECK: movs (M1_NM, 1) %bss(0) bindlessOffset(0,0)<0;1,0>
; CHECK: gather_scaled.1 (M1_NM, 1) %bss 0x0:ud {{.*}} {{.*}}
  %2 = call i8 @llvm.genx.GenISA.ldraw.indexed.i8.p2490368i8(i8 addrspace(2490368)* %1, i32 %0, i32 2, i1 false)
  %3 = add i32 %bufferOffset1, 1
  %4 = inttoptr i32 %bindlessOffset2 to i8 addrspace(2490368)*
; CHECK: movs (M1_NM, 1) %bss(0) bindlessOffset_0(0,0)<0;1,0>
; CHECK: scatter_scaled.1 (M1, 16) %bss 0x0:ud {{.*}} {{.*}}
; CHECK: movs (M1_NM, 1) %bss(0) bindlessOffset_0(0,0)<0;1,0>
; CHECK: scatter_scaled.1 (M5, 16) %bss 0x0:ud {{.*}} {{.*}}
  call void @llvm.genx.GenISA.storeraw.indexed.p2490368i8.i8(i8 addrspace(2490368)* %4, i32 %3, i8 %2, i32 2, i1 false)
  ret void
}

declare i8 @llvm.genx.GenISA.ldraw.indexed.i8.p2490368i8(i8 addrspace(2490368)*, i32, i32, i1) #1
declare void @llvm.genx.GenISA.storeraw.indexed.p2490368i8.i8(i8 addrspace(2490368)*, i32, i8, i32, i1) #2

attributes #0 = { convergent nounwind "less-precise-fpmad"="true" }
attributes #1 = { argmemonly nounwind readonly }
attributes #2 = { argmemonly nounwind writeonly }

!spirv.MemoryModel = !{!0}
!spirv.Source = !{!1}
!spirv.Generator = !{!2}
!igc.functions = !{!3}
!IGCMetadata = !{!15}
!opencl.ocl.version = !{!331, !331, !331, !331, !331}
!opencl.spir.version = !{!331, !331, !331, !331, !331}
!llvm.ident = !{!332, !332, !332, !332, !332}
!llvm.module.flags = !{!333}
!printf.strings = !{}

!0 = !{i32 2, i32 2}
!1 = !{i32 3, i32 102000}
!2 = !{i16 6, i16 14}
!3 = !{void (i8 addrspace(1)*, i8 addrspace(1)*, <8 x i32>, <8 x i32>, i32, i32, i32, i32)* @test, !4}
!4 = !{!5, !6}
!5 = !{!"function_type", i32 0}
!6 = !{!"implicit_arg_desc", !7, !8, !9, !11, !13, !14}
!7 = !{i32 0}
!8 = !{i32 1}
!9 = !{i32 14, !10}
!10 = !{!"explicit_arg_num", i32 0}
!11 = !{i32 14, !12}
!12 = !{!"explicit_arg_num", i32 1}
!13 = !{i32 57, !10}
!14 = !{i32 57, !12}
!15 = !{!"ModuleMD", !16, !17, !92, !182, !213, !229, !250, !260, !262, !263, !276, !277, !278, !279, !283, !284, !291, !292, !293, !294, !295, !296, !297, !298, !299, !300, !301, !303, !307, !308, !309, !310, !311, !312, !313, !314, !315, !316, !317, !151, !318, !321, !322, !324, !327, !328, !329}
!16 = !{!"isPrecise", i1 false}
!17 = !{!"compOpt", !18, !19, !20, !21, !22, !23, !24, !25, !26, !27, !28, !29, !30, !31, !32, !33, !34, !35, !36, !37, !38, !39, !40, !41, !42, !43, !44, !45, !46, !47, !48, !49, !50, !51, !52, !53, !54, !55, !56, !57, !58, !59, !60, !61, !62, !63, !64, !65, !66, !67, !68, !69, !70, !71, !72, !73, !74, !75, !76, !77, !78, !79, !80, !81, !82, !83, !84, !85, !86, !87, !88, !89, !90, !91}
!18 = !{!"DenormsAreZero", i1 false}
!19 = !{!"BFTFDenormsAreZero", i1 false}
!20 = !{!"CorrectlyRoundedDivSqrt", i1 false}
!21 = !{!"OptDisable", i1 false}
!22 = !{!"MadEnable", i1 true}
!23 = !{!"NoSignedZeros", i1 false}
!24 = !{!"NoNaNs", i1 false}
!25 = !{!"FloatRoundingMode", i32 0}
!26 = !{!"FloatCvtIntRoundingMode", i32 3}
!27 = !{!"LoadCacheDefault", i32 4}
!28 = !{!"StoreCacheDefault", i32 7}
!29 = !{!"VISAPreSchedRPThreshold", i32 0}
!30 = !{!"SetLoopUnrollThreshold", i32 0}
!31 = !{!"UnsafeMathOptimizations", i1 false}
!32 = !{!"disableCustomUnsafeOpts", i1 false}
!33 = !{!"disableReducePow", i1 false}
!34 = !{!"disableSqrtOpt", i1 false}
!35 = !{!"FiniteMathOnly", i1 false}
!36 = !{!"FastRelaxedMath", i1 false}
!37 = !{!"DashGSpecified", i1 false}
!38 = !{!"FastCompilation", i1 false}
!39 = !{!"UseScratchSpacePrivateMemory", i1 false}
!40 = !{!"RelaxedBuiltins", i1 false}
!41 = !{!"SubgroupIndependentForwardProgressRequired", i1 true}
!42 = !{!"GreaterThan2GBBufferRequired", i1 true}
!43 = !{!"GreaterThan4GBBufferRequired", i1 false}
!44 = !{!"DisableA64WA", i1 false}
!45 = !{!"ForceEnableA64WA", i1 false}
!46 = !{!"PushConstantsEnable", i1 true}
!47 = !{!"HasPositivePointerOffset", i1 false}
!48 = !{!"HasBufferOffsetArg", i1 true}
!49 = !{!"BufferOffsetArgOptional", i1 true}
!50 = !{!"replaceGlobalOffsetsByZero", i1 false}
!51 = !{!"forcePixelShaderSIMDMode", i32 0}
!52 = !{!"pixelShaderDoNotAbortOnSpill", i1 false}
!53 = !{!"UniformWGS", i1 false}
!54 = !{!"disableVertexComponentPacking", i1 false}
!55 = !{!"disablePartialVertexComponentPacking", i1 false}
!56 = !{!"PreferBindlessImages", i1 true}
!57 = !{!"UseBindlessMode", i1 true}
!58 = !{!"UseLegacyBindlessMode", i1 false}
!59 = !{!"disableMathRefactoring", i1 false}
!60 = !{!"atomicBranch", i1 false}
!61 = !{!"spillCompression", i1 false}
!62 = !{!"ForceInt32DivRemEmu", i1 false}
!63 = !{!"ForceInt32DivRemEmuSP", i1 false}
!64 = !{!"DisableFastestSingleCSSIMD", i1 false}
!65 = !{!"DisableFastestLinearScan", i1 false}
!66 = !{!"UseStatelessforPrivateMemory", i1 false}
!67 = !{!"EnableTakeGlobalAddress", i1 false}
!68 = !{!"IsLibraryCompilation", i1 false}
!69 = !{!"LibraryCompileSIMDSize", i32 0}
!70 = !{!"FastVISACompile", i1 false}
!71 = !{!"MatchSinCosPi", i1 false}
!72 = !{!"ExcludeIRFromZEBinary", i1 false}
!73 = !{!"EmitZeBinVISASections", i1 false}
!74 = !{!"FP64GenEmulationEnabled", i1 false}
!75 = !{!"allowDisableRematforCS", i1 false}
!76 = !{!"DisableIncSpillCostAllAddrTaken", i1 false}
!77 = !{!"DisableCPSOmaskWA", i1 false}
!78 = !{!"DisableFastestGopt", i1 false}
!79 = !{!"WaForceHalfPromotionComputeShader", i1 false}
!80 = !{!"WaForceHalfPromotionPixelVertexShader", i1 false}
!81 = !{!"DisableConstantCoalescing", i1 false}
!82 = !{!"EnableUndefAlphaOutputAsRed", i1 true}
!83 = !{!"WaEnableALTModeVisaWA", i1 false}
!84 = !{!"NewSpillCostFunction", i1 false}
!85 = !{!"ForceLargeGRFNum4RQ", i1 false}
!86 = !{!"DisableEUFusion", i1 false}
!87 = !{!"DisableFDivToFMulInvOpt", i1 false}
!88 = !{!"initializePhiSampleSourceWA", i1 false}
!89 = !{!"WaDisableSubspanUseNoMaskForCB", i1 false}
!90 = !{!"DisableLoosenSimd32Occu", i1 false}
!91 = !{!"FastestS1Options", i32 0}
!92 = !{!"FuncMD", !93, !94}
!93 = !{!"FuncMDMap[0]", void (i8 addrspace(1)*, i8 addrspace(1)*, <8 x i32>, <8 x i32>, i32, i32, i32, i32)* @test}
!94 = !{!"FuncMDValue[0]", !95, !96, !100, !101, !102, !123, !143, !144, !145, !146, !147, !148, !149, !150, !151, !152, !153, !154, !155, !156, !157, !158, !159, !162, !165, !168, !171, !174, !177, !178}
!95 = !{!"localOffsets"}
!96 = !{!"workGroupWalkOrder", !97, !98, !99}
!97 = !{!"dim0", i32 0}
!98 = !{!"dim1", i32 1}
!99 = !{!"dim2", i32 2}
!100 = !{!"funcArgs"}
!101 = !{!"functionType", !"KernelFunction"}
!102 = !{!"rtInfo", !103, !104, !105, !106, !107, !108, !109, !110, !111, !112, !113, !114, !115, !116, !117, !118, !122}
!103 = !{!"callableShaderType", !"NumberOfCallableShaderTypes"}
!104 = !{!"isContinuation", i1 false}
!105 = !{!"hasTraceRayPayload", i1 false}
!106 = !{!"hasHitAttributes", i1 false}
!107 = !{!"hasCallableData", i1 false}
!108 = !{!"ShaderStackSize", i32 0}
!109 = !{!"ShaderHash", i64 0}
!110 = !{!"ShaderName", !""}
!111 = !{!"ParentName", !""}
!112 = !{!"SlotNum", i1* null}
!113 = !{!"NOSSize", i32 0}
!114 = !{!"globalRootSignatureSize", i32 0}
!115 = !{!"Entries"}
!116 = !{!"SpillUnions"}
!117 = !{!"CustomHitAttrSizeInBytes", i32 0}
!118 = !{!"Types", !119, !120, !121}
!119 = !{!"FrameStartTys"}
!120 = !{!"ArgumentTys"}
!121 = !{!"FullFrameTys"}
!122 = !{!"Aliases"}
!123 = !{!"resAllocMD", !124, !125, !126, !127, !142}
!124 = !{!"uavsNumType", i32 6}
!125 = !{!"srvsNumType", i32 0}
!126 = !{!"samplersNumType", i32 0}
!127 = !{!"argAllocMDList", !128, !132, !134, !137, !138, !139, !140, !141}
!128 = !{!"argAllocMDListVec[0]", !129, !130, !131}
!129 = !{!"type", i32 1}
!130 = !{!"extensionType", i32 -1}
!131 = !{!"indexType", i32 2}
!132 = !{!"argAllocMDListVec[1]", !129, !130, !133}
!133 = !{!"indexType", i32 3}
!134 = !{!"argAllocMDListVec[2]", !135, !130, !136}
!135 = !{!"type", i32 0}
!136 = !{!"indexType", i32 -1}
!137 = !{!"argAllocMDListVec[3]", !135, !130, !136}
!138 = !{!"argAllocMDListVec[4]", !135, !130, !136}
!139 = !{!"argAllocMDListVec[5]", !135, !130, !136}
!140 = !{!"argAllocMDListVec[6]", !135, !130, !136}
!141 = !{!"argAllocMDListVec[7]", !135, !130, !136}
!142 = !{!"inlineSamplersMD"}
!143 = !{!"maxByteOffsets"}
!144 = !{!"IsInitializer", i1 false}
!145 = !{!"IsFinalizer", i1 false}
!146 = !{!"CompiledSubGroupsNumber", i32 0}
!147 = !{!"hasInlineVmeSamplers", i1 false}
!148 = !{!"localSize", i32 0}
!149 = !{!"localIDPresent", i1 false}
!150 = !{!"groupIDPresent", i1 false}
!151 = !{!"privateMemoryPerWI", i32 0}
!152 = !{!"prevFPOffset", i32 0}
!153 = !{!"globalIDPresent", i1 false}
!154 = !{!"hasSyncRTCalls", i1 false}
!155 = !{!"hasNonKernelArgLoad", i1 false}
!156 = !{!"hasNonKernelArgStore", i1 false}
!157 = !{!"hasNonKernelArgAtomic", i1 false}
!158 = !{!"UserAnnotations"}
!159 = !{!"m_OpenCLArgAddressSpaces", !160, !161}
!160 = !{!"m_OpenCLArgAddressSpacesVec[0]", i32 1}
!161 = !{!"m_OpenCLArgAddressSpacesVec[1]", i32 1}
!162 = !{!"m_OpenCLArgAccessQualifiers", !163, !164}
!163 = !{!"m_OpenCLArgAccessQualifiersVec[0]", !"none"}
!164 = !{!"m_OpenCLArgAccessQualifiersVec[1]", !"none"}
!165 = !{!"m_OpenCLArgTypes", !166, !167}
!166 = !{!"m_OpenCLArgTypesVec[0]", !"char*"}
!167 = !{!"m_OpenCLArgTypesVec[1]", !"char*"}
!168 = !{!"m_OpenCLArgBaseTypes", !169, !170}
!169 = !{!"m_OpenCLArgBaseTypesVec[0]", !"char*"}
!170 = !{!"m_OpenCLArgBaseTypesVec[1]", !"char*"}
!171 = !{!"m_OpenCLArgTypeQualifiers", !172, !173}
!172 = !{!"m_OpenCLArgTypeQualifiersVec[0]", !""}
!173 = !{!"m_OpenCLArgTypeQualifiersVec[1]", !""}
!174 = !{!"m_OpenCLArgNames", !175, !176}
!175 = !{!"m_OpenCLArgNamesVec[0]", !"in"}
!176 = !{!"m_OpenCLArgNamesVec[1]", !"out"}
!177 = !{!"m_OpenCLArgScalarAsPointers"}
!178 = !{!"m_OptsToDisablePerFunc", !179, !180, !181}
!179 = !{!"m_OptsToDisablePerFuncSet[0]", !"IGC-AddressArithmeticSinking"}
!180 = !{!"m_OptsToDisablePerFuncSet[1]", !"IGC-AllowSimd32Slicing"}
!181 = !{!"m_OptsToDisablePerFuncSet[2]", !"IGC-SinkLoadOpt"}
!182 = !{!"pushInfo", !183, !184, !185, !189, !190, !191, !192, !193, !194, !195, !196, !209, !210, !211, !212}
!183 = !{!"pushableAddresses"}
!184 = !{!"bindlessPushInfo"}
!185 = !{!"dynamicBufferInfo", !186, !187, !188}
!186 = !{!"firstIndex", i32 0}
!187 = !{!"numOffsets", i32 0}
!188 = !{!"forceDisabled", i1 false}
!189 = !{!"MaxNumberOfPushedBuffers", i32 0}
!190 = !{!"inlineConstantBufferSlot", i32 -1}
!191 = !{!"inlineConstantBufferOffset", i32 -1}
!192 = !{!"inlineConstantBufferGRFOffset", i32 -1}
!193 = !{!"constants"}
!194 = !{!"inputs"}
!195 = !{!"constantReg"}
!196 = !{!"simplePushInfoArr", !197, !206, !207, !208}
!197 = !{!"simplePushInfoArrVec[0]", !198, !199, !200, !201, !202, !203, !204, !205}
!198 = !{!"cbIdx", i32 0}
!199 = !{!"pushableAddressGrfOffset", i32 -1}
!200 = !{!"pushableOffsetGrfOffset", i32 -1}
!201 = !{!"offset", i32 0}
!202 = !{!"size", i32 0}
!203 = !{!"isStateless", i1 false}
!204 = !{!"isBindless", i1 false}
!205 = !{!"simplePushLoads"}
!206 = !{!"simplePushInfoArrVec[1]", !198, !199, !200, !201, !202, !203, !204, !205}
!207 = !{!"simplePushInfoArrVec[2]", !198, !199, !200, !201, !202, !203, !204, !205}
!208 = !{!"simplePushInfoArrVec[3]", !198, !199, !200, !201, !202, !203, !204, !205}
!209 = !{!"simplePushBufferUsed", i32 0}
!210 = !{!"pushAnalysisWIInfos"}
!211 = !{!"inlineRTGlobalPtrOffset", i32 0}
!212 = !{!"rtSyncSurfPtrOffset", i32 0}
!213 = !{!"psInfo", !214, !215, !216, !217, !218, !219, !220, !221, !222, !223, !224, !225, !226, !227, !228}
!214 = !{!"BlendStateDisabledMask", i8 0}
!215 = !{!"SkipSrc0Alpha", i1 false}
!216 = !{!"DualSourceBlendingDisabled", i1 false}
!217 = !{!"ForceEnableSimd32", i1 false}
!218 = !{!"outputDepth", i1 false}
!219 = !{!"outputStencil", i1 false}
!220 = !{!"outputMask", i1 false}
!221 = !{!"blendToFillEnabled", i1 false}
!222 = !{!"forceEarlyZ", i1 false}
!223 = !{!"hasVersionedLoop", i1 false}
!224 = !{!"forceSingleSourceRTWAfterDualSourceRTW", i1 false}
!225 = !{!"NumSamples", i8 0}
!226 = !{!"blendOptimizationMode"}
!227 = !{!"colorOutputMask"}
!228 = !{!"WaDisableVRS", i1 false}
!229 = !{!"csInfo", !230, !231, !232, !233, !234, !29, !30, !235, !236, !237, !238, !239, !240, !241, !242, !243, !244, !245, !246, !60, !61, !247, !248, !249}
!230 = !{!"maxWorkGroupSize", i32 0}
!231 = !{!"waveSize", i32 0}
!232 = !{!"ComputeShaderSecondCompile"}
!233 = !{!"forcedSIMDSize", i8 0}
!234 = !{!"forceTotalGRFNum", i32 0}
!235 = !{!"forceSpillCompression", i1 false}
!236 = !{!"allowLowerSimd", i1 false}
!237 = !{!"disableSimd32Slicing", i1 false}
!238 = !{!"disableSplitOnSpill", i1 false}
!239 = !{!"enableNewSpillCostFunction", i1 false}
!240 = !{!"forcedVISAPreRAScheduler", i1 false}
!241 = !{!"forceUniformBuffer", i1 false}
!242 = !{!"forceUniformSurfaceSampler", i1 false}
!243 = !{!"disableLocalIdOrderOptimizations", i1 false}
!244 = !{!"disableDispatchAlongY", i1 false}
!245 = !{!"neededThreadIdLayout", i1* null}
!246 = !{!"forceTileYWalk", i1 false}
!247 = !{!"walkOrderEnabled", i1 false}
!248 = !{!"walkOrderOverride", i32 0}
!249 = !{!"ResForHfPacking"}
!250 = !{!"msInfo", !251, !252, !253, !254, !255, !256, !257, !258, !259}
!251 = !{!"PrimitiveTopology", i32 3}
!252 = !{!"MaxNumOfPrimitives", i32 0}
!253 = !{!"MaxNumOfVertices", i32 0}
!254 = !{!"MaxNumOfPerPrimitiveOutputs", i32 0}
!255 = !{!"MaxNumOfPerVertexOutputs", i32 0}
!256 = !{!"WorkGroupSize", i32 0}
!257 = !{!"WorkGroupMemorySizeInBytes", i32 0}
!258 = !{!"IndexFormat", i32 6}
!259 = !{!"SubgroupSize", i32 0}
!260 = !{!"taskInfo", !261, !256, !257, !259}
!261 = !{!"MaxNumOfOutputs", i32 0}
!262 = !{!"NBarrierCnt", i32 0}
!263 = !{!"rtInfo", !264, !265, !266, !267, !268, !269, !270, !271, !272, !273, !274, !275}
!264 = !{!"RayQueryAllocSizeInBytes", i32 0}
!265 = !{!"NumContinuations", i32 0}
!266 = !{!"RTAsyncStackAddrspace", i32 -1}
!267 = !{!"RTAsyncStackSurfaceStateOffset", i1* null}
!268 = !{!"SWHotZoneAddrspace", i32 -1}
!269 = !{!"SWHotZoneSurfaceStateOffset", i1* null}
!270 = !{!"SWStackAddrspace", i32 -1}
!271 = !{!"SWStackSurfaceStateOffset", i1* null}
!272 = !{!"RTSyncStackAddrspace", i32 -1}
!273 = !{!"RTSyncStackSurfaceStateOffset", i1* null}
!274 = !{!"doSyncDispatchRays", i1 false}
!275 = !{!"MemStyle", !"Xe"}
!276 = !{!"CurUniqueIndirectIdx", i32 0}
!277 = !{!"inlineDynTextures"}
!278 = !{!"inlineResInfoData"}
!279 = !{!"immConstant", !280, !281, !282}
!280 = !{!"data"}
!281 = !{!"sizes"}
!282 = !{!"zeroIdxs"}
!283 = !{!"stringConstants"}
!284 = !{!"inlineBuffers", !285, !289, !290}
!285 = !{!"inlineBuffersVec[0]", !286, !287, !288}
!286 = !{!"alignment", i32 0}
!287 = !{!"allocSize", i64 0}
!288 = !{!"Buffer"}
!289 = !{!"inlineBuffersVec[1]", !286, !287, !288}
!290 = !{!"inlineBuffersVec[2]", !286, !287, !288}
!291 = !{!"GlobalPointerProgramBinaryInfos"}
!292 = !{!"ConstantPointerProgramBinaryInfos"}
!293 = !{!"GlobalBufferAddressRelocInfo"}
!294 = !{!"ConstantBufferAddressRelocInfo"}
!295 = !{!"forceLscCacheList"}
!296 = !{!"SrvMap"}
!297 = !{!"RasterizerOrderedByteAddressBuffer"}
!298 = !{!"RasterizerOrderedViews"}
!299 = !{!"MinNOSPushConstantSize", i32 2}
!300 = !{!"inlineProgramScopeOffsets"}
!301 = !{!"shaderData", !302}
!302 = !{!"numReplicas", i32 0}
!303 = !{!"URBInfo", !304, !305, !306}
!304 = !{!"has64BVertexHeaderInput", i1 false}
!305 = !{!"has64BVertexHeaderOutput", i1 false}
!306 = !{!"hasVertexHeader", i1 true}
!307 = !{!"UseBindlessImage", i1 true}
!308 = !{!"enableRangeReduce", i1 false}
!309 = !{!"allowMatchMadOptimizationforVS", i1 false}
!310 = !{!"disableMatchMadOptimizationForCS", i1 false}
!311 = !{!"disableMemOptforNegativeOffsetLoads", i1 false}
!312 = !{!"enableThreeWayLoadSpiltOpt", i1 false}
!313 = !{!"statefulResourcesNotAliased", i1 false}
!314 = !{!"disableMixMode", i1 false}
!315 = !{!"genericAccessesResolved", i1 false}
!316 = !{!"disableSeparateSpillPvtScratchSpace", i1 false}
!317 = !{!"disableSeparateScratchWA", i1 false}
!318 = !{!"PrivateMemoryPerFG", !319, !320}
!319 = !{!"PrivateMemoryPerFGMap[0]", void (i8 addrspace(1)*, i8 addrspace(1)*, <8 x i32>, <8 x i32>, i32, i32, i32, i32)* @test}
!320 = !{!"PrivateMemoryPerFGValue[0]", i32 0}
!321 = !{!"m_OptsToDisable"}
!322 = !{!"capabilities", !323}
!323 = !{!"globalVariableDecorationsINTEL", i1 false}
!324 = !{!"m_ShaderResourceViewMcsMask", !325, !326}
!325 = !{!"m_ShaderResourceViewMcsMaskVec[0]", i64 0}
!326 = !{!"m_ShaderResourceViewMcsMaskVec[1]", i64 0}
!327 = !{!"computedDepthMode", i32 0}
!328 = !{!"isHDCFastClearShader", i1 false}
!329 = !{!"argRegisterReservations", !330}
!330 = !{!"argRegisterReservationsVec[0]", i32 0}
!331 = !{i32 2, i32 0}
!332 = !{!"clang version 14.0.5"}
!333 = !{i32 1, !"wchar_size", i32 4}
!334 = !{!"80"}
!335 = !{!"-3"}
# LTX-2.5 MSR no-cuts debugging handoff

Date: 2026-08-23

## Scope

This handoff covers the missing scene cuts in the custom workflow only:

`user/default/workflows/LTX2.5-MSR-sample-workflow.json`

The user’s current test constraints are:

- first pass only; do not run the second pass
- target test size: 576x320, 12 seconds, 24 fps
- preserve unrelated changes in the ComfyUI worktree
- do not change other custom-node projects unless explicitly required

## Current git state

The MSR workflow is clean at commit `04affebae` (`Use BF16 MSR workflow at 576x320`).
Relevant workflow history:

- `4df663f0e` — Test BF16 MSR sample workflow
- `ab0f40f58` — Test BF16 LTX transformer
- `a0fa562b5` — Revert BF16 LTX transformer
- `d3556741c` — Use official MSR cut prompt
- `04affebae` — Use BF16 MSR workflow at 576x320

The following pre-existing worktree changes are unrelated and must remain untouched:

`comfy_extras/nodes_textgen.py`, `start-comfy-rocm101.sh`, `.SynologyWorkingDirectory/`, `.claude/`, `.codex-backups/`, `.gitnexusignore`, `AGENTS.local.md`, `CLAUDE.md`, `Stable-Video-Infinity/`, `comfy/text_encoders/t5_config_xxl.json.bak`, `monitor-gpu.sh`, `start-comfy.sh`, and `test-and-fix-gpu-speed.sh`.

## Workflow configuration

The current workflow uses:

- BF16 LTX-2.5 transformer and Gemma encoder
- `LTX/LTX-2.5-Licon-MSR-V1.safetensors`
- references `input/01.png`, `input/02.png`, and `input/03.png`
- MSR guide order `pic1`, `pic2`, `background`
- `reference_frames=33`, guide strength `1`
- native ComfyUI LTX nodes, not the custom LTXVideo embedding path
- separate stage-1 and stage-2 branches; stage-1 output is available through the existing first-pass save branch

The three input images are byte-identical to the Example 06 validation images downloaded from the LiconStudio Hugging Face repository.

## Tests and results

### Original high-resolution run

`output/LTX25_MSR_Distilled8_00005_.mp4`

- 1280x704, 12.041667 seconds, 24 fps, 289 frames
- this file is the stage-1 save output, not the second-stage output; its embedded workflow uses the `LTX25_MSR_Distilled8` first-pass save node
- current V1 MSR LoRA and INT8 transformer/text encoder
- no hard cuts

This rules out the hypothesis that cuts only fail at 576x320 or only after stage-2 refinement.

### Current public V1 MSR workflow at 576x320

Several first-pass video-only tests were run with the BF16 transformer and current V1 MSR LoRA. They completed successfully but remained continuous shots:

- `output/video/LTX25_MSR_FirstPass_BF16VideoOnly_576x320_actual_00001_.mp4`
- `output/video/LTX25_MSR_FirstPass_BF16VideoOnly_576x320_FigureLabels_00001_.mp4`
- `output/video/LTX25_MSR_FirstPass_BF16VideoOnly_576x320_ReadmeOneCut_00001_.mp4`

The last test used `PromptRelaySmartEncode` with two README-style blocks and an explicit midpoint hard cut. The log confirmed:

`[PromptRelay] Latent: 37 frames ... segments: [19, 18]`

The output still behaved as one continuous camera shot. The three MSR references and learned slot embeddings were applied successfully, with offsets `-3`, `-2`, and `-1`.

### PromptRelay finding

The original workflow’s local prompt contains `[Shot 1]` through `[Shot 4]`, but it has no `|` separators and the standard `PromptRelayEncode` log reports one segment:

`segments: [37]`

Those markers are ordinary prompt text, not PromptRelay timeline syntax. A real Smart-node two-segment test was also run and still produced no hard cut, so fixing the formatting alone is not sufficient.

### BF16 timing

For comparable 576x320, 12-second, 8-step first-pass runs on this machine:

- INT8: approximately 2:05–2:40 total, with sampling around 2:04–2:18
- BF16: approximately 5:44–5:49 total, with sampling around 5:10–5:14

BF16 may improve detail or reduce quantization artifacts, but it did not improve cut behavior in these tests.

## Official Example 06 discrepancy

The embedded workflows in the official `MSR-cut.mp4` and `MSR-no-cut.mp4` files use the same prompt structure, reference images, and 1280x704 stage-1 setup, but they reference:

`LTX-2.3\\S3V2_04400.safetensors`

They also use older node IDs (`LTX25MSRICLoRALoader` and `LTX25MSRMultiReferenceGuide`) rather than the current public node IDs (`ComfyUILTX25MSRICLoRALoader` and `ComfyUILTX25MSRMultiReferenceGuide`).

The exact `S3V2_04400` binary was not found locally, in the current LiconStudio model repository, or in the official Lightricks LTX-2.3 repository. The current public LiconStudio release contains `LTX-2.5-Licon-MSR-V1.safetensors`, not that older adapter.

This is currently the strongest explanation for why the official validation clip cannot be reproduced: the clip used an older adapter/node lineage, while the public workflow uses the newer V1 MSR implementation.

## Recommended next step

Do not make further prompt or resolution changes yet. The decisive test is to obtain the exact `S3V2_04400` adapter, or the archived implementation of the old MSR nodes, and run only the stage-1 branch with the official prompt and references.

If the old adapter is unavailable, the remaining options are:

1. audit the current public MSR guide against the old implementation and add a narrowly scoped compatibility mode;
2. generate individual shots and concatenate them when editorially exact cuts are required.

No Smart-node prompt change from the temporary test has been applied to the tracked sample workflow.

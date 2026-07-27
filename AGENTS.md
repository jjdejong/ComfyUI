# ComfyUI development guidance

- Keep changes small, direct, and consistent with the surrounding code.
- Preserve public APIs, node names, workflow compatibility, model-loading
  behavior, and file layout unless the task explicitly requires a change.
- Reuse existing ComfyUI interfaces, model classes, nodes, operations, and
  helpers before introducing new abstractions or dependencies.
- Treat dtype, device placement, VRAM use, offloading, and checkpoint loading
  as correctness concerns. Verify the relevant supported backends when changing
  shared model or execution code.
- Keep model, execution, API, persistence, telemetry, and UI responsibilities
  in their existing owner layers.
- Do not add outbound requests, telemetry, tracking, update checks, or remote
  configuration to core ComfyUI. User-initiated model downloads are allowed
  only when the task explicitly requires them.
- Keep warnings, documentation, tests, commits, and pull requests concise and
  focused on the changed behavior.
- Inspect the current source and runtime before relying on dated implementation
  notes or environment assumptions.

@RTK.md

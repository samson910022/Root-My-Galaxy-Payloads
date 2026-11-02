# SM-S9210 / S9210ZHU6EZIF porting record — S0 skeleton

> Stage: S0 (adaptation skeleton only). No firmware downloaded, no kernel
> extracted, no offsets derived, no target headers created, no feed touched,
> no binaries built. Every firmware-dependent value below that is not yet
> measured is marked `TODO(...)` and MUST NOT be filled with guesses, DZG1
> copies, or placeholders presented as fact.

Reference structure: [`SM-S9210-S9210ZHS6DZG1.md`](SM-S9210-S9210ZHS6DZG1.md).
Procedure: [`PORTING.md`](PORTING.md).
Feed rules: [`../README.md`](../README.md) + [`../support/README.md`](../support/README.md).

## 1. Firmware identity (S0 declared, S1 to prove)

| Field | Value (S0) |
| --- | --- |
| Model | `SM-S9210` (China, e1q) |
| Device codename | `e1q` |
| Product name (expected) | `TODO(provenance): confirm from fota.zip / build.prop (DZG1 was \`e1qzhx\`)` |
| AP / PDA | `S9210ZHU6EZIF` |
| CSC | `S9210OZS6EZIF` (OZS multi-CSC; this branch covers `TGY` + `BRI`. `CHC` belongs to a separate branch) |
| CP / baseband | `S9210ZCU6EZIF` |
| Four-part version (expected) | `S9210ZHU6EZIF/S9210OZS6EZIF/S9210ZCU6EZIF/S9210ZHU6EZIF` — `TODO(provenance): confirm via samloader \`check-update --model SM-S9210 --region TGY/BRI\`` |
| Android version | `17` |
| One UI version | `9` |
| Build date | `2026-09-20` |
| Release date | `2026-10-21` |
| Security patch level | `2026-09-05` |
| Binary (bootloader) | `6` |
| Regions in scope | `TGY` + `BRI` (OZS). `CHC` explicitly out of scope for this branch |
| Kernel release | `TODO(kernel): read from \`uname -r\` / boot image (DZG1 was \`6.1.145-android14-11-33419968-abS9210ZHS6DZG1\`; do NOT reuse)` |
| Build fingerprint | `TODO(provenance): read from \`meta-data/fota.zip\` (do NOT fabricate)` |
| Build ID / changelist | `TODO(provenance): read from fota.zip build.prop` |
| boot.img size / SHA-256 | `TODO(kernel): measure after S1 extract` |
| kernel size / SHA-256 | `TODO(kernel): measure after S1 extract (boot header offset 0x08 size, slice at 0x1000)` |
| vendor_boot.img size / SHA-256 | `TODO(kernel): measure after S1 extract` |
| ARM64 Image text_offset / image_size / flags | `TODO(kernel): read from Image header` |
| SELinux (device-measured) | `TODO(validation): record from device (\`getenforce\`, expected \`Enforcing\`)` |
| tracefs event ID | `TODO(offsets): derive per PORTING.md §5 (DZG1 was 106; do NOT copy)` |

Provenance gate (S1): `samloader-rs check-update --model SM-S9210 --region TGY`
and `--region BRI` must both resolve to the four-part version above before any
download. Download command, ZIP name, AP/BL/CSC file names, and byte sizes go
in the S1 record. No download is performed in S0.

## 2. Differences vs DZG1 (`S9210ZHS6DZG1`, device-tested baseline)

DZG1 reference: [`SM-S9210-S9210ZHS6DZG1.md`](SM-S9210-S9210ZHS6DZG1.md)
(`BP4A.251205.006`, Android 16, kernel `6.1.145-android14-11-33419968`,
`12` audited offsets + BTF layouts + P0 table + v3.2.5 feed pair).

| Axis | DZG1 (baseline, proven) | EZIF (this port, S0) | S0 verdict |
| --- | --- | --- | --- |
| PDA / CSC / CP | `S9210ZHS6DZG1` / `S9210OZS6DZG1` / `S9210ZCS6DZG1` | `S9210ZHU6EZIF` / `S9210OZS6EZIF` / `S9210ZCU6EZIF` | Declared, S1 to prove |
| Android / One UI | 16 / 8.x (`BP4A.251205.006`, build 2026-07-10) | 17 / 9, build 2026-09-20, release 2026-10-21, patch 2026-09-05 | Declared; kernel/GKI generation may differ — never assume same offsets |
| Binary | 6 (`ZHS6`) | 6 (`ZHU6`) | Same binary digit, still a different build — full re-audit required |
| Regions | BRI sales, OZS multi-CSC | TGY + BRI OZS in this branch; CHC separate branch | Scope narrower than "all OZS"; feed `models` must reflect this in S6 |
| Kernel image / SHA | `38005248` bytes, SHA-256 `c34386a0…` recorded | `TODO(kernel)` — MUST re-extract and re-hash | No reuse |
| Kernel release / vermagic | `6.1.145-android14-11-33419968-abS9210ZHS6DZG1` | `TODO(kernel)` / `TODO(KSU)` — MUST re-read | No reuse; KSU `vermagic` must match exactly |
| Audited offsets (`KMALLOC_CACHES`, `SLIDE_NFULNL_LOGGER_NAME`, `CALL_USERMODEHELPER_EXEC_WORK`, `SYSTEM_UNBOUND_WQ`, `INIT_TASK`, `ROOT_TASK_GROUP`, `SELINUX_ENFORCING`, `ASHMEM_*`, `ANON_PIPE_BUF_OPS`, logger objects, boot-id pointers, misc fops, tracefs caller) | All recorded in DZG1 doc + `src/targets/e1q-S9210ZHS6DZG1/target.h` | `TODO(offsets)` — every entry to be re-derived from EZIF `vmlinux.elf` + BTF per `PORTING.md` §3 | Copying `target.h` and renaming is FORBIDDEN (would boot-panic / mis-slide) |
| BTF struct layouts (file_operations, page, task, rt_mutex_waiter, configfs, workqueue, selinux_state) | Match S9280 profile | `TODO(offsets)` — re-dump `bpftool btf dump ... format raw` + `format c` | No reuse without byte-level proof |
| P0 table (`p0_fingerprint.h`, `P0_ORACLE_PROBE_OFFSET`, `P0_PHYS_OFFSET`, `P0_KERNEL_PHYS_LOAD`) | `0x1f0000` probe, `0x80000000` / `0x80080000`, 42 address words differ from S9280 | `TODO(offsets)` — regenerate all 32 slides × 8 qwords from EZIF raw kernel, 256-qword readback | Reuse across firmware is explicitly unsafe (cf. DZG1 §P0) |
| Slide params (`SLIDE_TRACEFS_EVENT_ID`, `WORKER_CALLER_OFF`, `PSELECT_WORD_SHIFT`, bank geometry, `SKB_DATA_DELTA`, `TASK_STRIDE`, `LOCK_OFF`) | `106` / `0xdb1a0` / `3`, e1s-style geometry, `-0xe80`, `0x1c0`/`0x5200`, default 15 slabs | `TODO(offsets)` — recompute event ID, caller, fdset shift, geometry from EZIF ELF | DZG1 values are hints for bring-up order only, never defaults |
| KernelSU pair | v3.2.5 feed pair + v3.3.0 Phase-D candidate (one 2026-10-03 success) | `TODO(KSU)` — rebuild + `check_symbol` + `modinfo` + static audit + hardware runs | Do NOT copy DZG1 `.ko`/`ksud` |
| Hardware validation | Device-tested 2026-09-11 (v3.2.5), candidate 2026-10-03 (v3.3.0) | `TODO(validation)` — no runs yet | S0 performs zero runs |

## 3. Stage plan S0–S6 and acceptance checklists

Numbering follows `PORTING.md` §1–§9. S0 is this file only.

- [ ] **S0 — skeleton (this stage). ACCEPT:** this md exists; identity table
  present with `TODO(...)` on every unmeasured field; DZG1 diff table present;
  S0–S6 plan + anti-panic list present; NO `src/targets/e1q-S9210ZHU6EZIF/`
  directory, NO `support/targets-v*.json` edit, NO binaries (`.so`/`.ko`/`zip`/`img`),
  NO fabricated SHA/offsets/vermagic. `git status` shows exactly one new file.
- [ ] **S1 — provenance + extraction (PORTING.md §1–§2). ACCEPT:** samloader
  four-part version transcript (TGY + BRI); download command + ZIP/AP/BL names;
  `boot.img`/`kernel`/`vendor_boot.img` sizes + SHA-256; Image header fields;
  fota.zip identity (fingerprint, model, SDK, page size); cleanup of multi-GB
  ZIP/AP/BL/ELF/tmp per §9, raw `kernel` + provenance note retained.
- [ ] **S2 — symbols + BTF + offsets (PORTING.md §3). ACCEPT:** `vmlinux-to-elf`
  + `llvm-nm` transcript; exactly-one raw BTF blob interval with header/section
  validation; `format raw` + `format c` dumps kept during work; every macro-use
  offset table filled from EZIF ELF (no DZG1 carry-over); `ashmem_misc+fops`
  derivation shown; logger vs registry vs boot-id roles kept distinct;
  `sizeof`/member offsets from raw BTF with byte-alignment checks.
- [ ] **S3 — physical load + slide params (PORTING.md §4–§5). ACCEPT:** sboot
  `text_offset+0x80000000` derivation with file offset + disassembly (no S25U
  copy); `P0_PHYS_OFFSET` / `P0_KERNEL_PHYS_LOAD` proven; tracefs event ID from
  device `id` file or `(__event - __start)/8 + __TRACE_LAST_TYPE` math;
  `worker_thread` post-`bl schedule` caller derivation; per-boot caller-minus-offset
  64-KiB-alignment + P0-range verification; `SLIDE_PSELECT_WORD_SHIFT` from
  `pselect6`/`do_pselect` disassembly + BTF waiter layout (0 is a finding, not a default).
- [ ] **S4 — target headers + P0 table (PORTING.md §5–§6). ACCEPT:** new
  `src/targets/e1q-S9210ZHU6EZIF/target.h` + `p0_fingerprint.h` authored from
  EZIF data only; all 32 slides × 8 qwords generated with 256-qword readback;
  `TARGET=e1q-S9210ZHU6EZIF release` builds fixed-size `.so`; artifact copied to
  `artifacts/e1q-S9210ZHU6EZIF/` with size + SHA-256 recorded.
- [ ] **S5 — KernelSU module (PORTING.md §7). ACCEPT:** Samsung patch applies
  cleanly to the pinned KSU version; `check_symbol` vs EZIF `vmlinux.elf`;
  `CONFIG_MODULE_FORCE_LOAD` / `CONFIG_MODVERSIONS` inspected; `modinfo`
  reports exact EZIF `vermagic`; debug sections stripped; KO embedded as exact
  KMI asset; `ksud` rebuilt; both files named with kernel/KMI version; sizes +
  SHA-256 recorded; static audit (undefined symbols, `__versions`, `UND
  stop_machine`) clean.
- [ ] **S6 — feed + hardware validation (PORTING.md §8). ACCEPT:** entry added
  once to `support/targets-v3.json` (schema: `payloadId`, `displayName`,
  `models`, `kernelVersions`, exploit + KSU `url`/`size`; suffixes/fingerprints
  stay out of the manifest); JSON validated + app-parse confirmed;
  `targets-v2.json` untouched; hardware chain (tracefs slide → fops → cfi →
  phys → root umh → pipe → KernelSU late-load → granted `su`) logged on a
  physical SM-S9210 EZIF device; `models` reflects TGY+BRI scope (CHC excluded);
  volatility / reboot / repeatability notes recorded.

Feed rule reminder (from `support/README.md` + `README.md`): one entry per
shared payload; runtime match is exact `Build.MODEL` + leading three-part
`uname -r` only; no per-artifact SHA-256 or manifest signatures in schema v3;
app resolves the payload repo commit first, then fetches from that immutable
commit.

## 4. Anti-panic checklist (non-omittable guards; verify each before any run)

Derived from the current tree; macro names/offsets below are DZG1 examples of
*where the guard lives*, NOT values to reuse on EZIF. Every item must be
re-verified against the EZIF target before S6 hardware runs.

### `src/slide_app.c` — KASLR slide + P0 oracle
- `APP_TRACEFS_SLIDE` route only when target-proven writable (shell group
  `readtracefs`); otherwise P0 oracle fallback is flaky by design.
- Caller-minus-`SLIDE_TRACEFS_WORKER_CALLER_OFF` must be 64-KiB aligned and
  inside the target P0 slide range on every attempt; unanimous per-boot
  agreement required before accepting the caller offset.
- `SLIDE_TRACEFS_MIN_VOTES` quorum (DZG1/FZG1: 2) — do not accept single-vote slides.
- Tracefs state restore is mandatory: `tracing_on`, `trace`, `enable`, per-CPU
  `trace_pipe_raw`, and event `id` handling must restore (`restore_needed` /
  `restore_ok` path); a failed restore aborts the run, it is not a warning.
- P0 oracle pages must be gate/probe/restored as pairs
  (`slide_restore_physical_oracle`: `gate_restored` + `probe_restored` both 1);
  verify via `verify_p0_probe_pairs` / `verify_p0_pipe_oracle_gate` contract.
- `SLIDE_PSELECT_WORD_SHIFT` is a qword count in read/write/exception fd_set
  order, derived from EZIF `pselect6` disassembly + BTF waiter layout — never
  copy DZG1's `3`.
- Bank/slab geometry (`SKB_DATA_DELTA`, `TASK_STRIDE`/`SLIDE_BANK_TASK_STRIDE`,
  `LOCK_OFF`/`SLIDE_BANK_LOCK_OFF`, pipe slab count) is target-specific:
  DZG1 needed e1s-style (`-0xe80`, legacy bank `0x1c0`/`0x5200`, 15 slabs);
  S928-geometry on e1q lands on zero pages (`cfi read=0 errno=25 ENOTTY`) and
  buddy pages (gate fail). Re-derive for EZIF.
- `P0_KERNEL_PHYS_LOAD` must be linear-map self-consistent through the full chain.

### `src/fops.c` — configfs/CFI + boot-id oracle
- `restore_p0_oracle_pages` must succeed before CFI restore is trusted.
- CFI write return must equal `sizeof(original_fops)`; `cfi_restore_ret` is
  checked twice (trigger path and final path) — any short write aborts.
- `restore_slide_boot_id` must restore BOTH the `.data` pointer slot
  (`SLIDE_RANDOM_TABLE_BOOT_ID_DATA_PTR`) and the rb parent/type, with
  `slide_bootid_restore_ret == sizeof(...)` and `type_restore_ret` checks;
  leaving the boot-id pointer redirected panics or corrupts later reads.
- One full trigger shot per supervisor run (first fops route config locks the
  run); re-invoke for more shots, no reboot needed unless panic/hang.

### `src/pipe.c` — page reclaim + phys read/write
- `pipe_reclaim_cache_gate` / `pipe_cache_gate_ok` is a hard gate: candidate
  pages must match the EZIF pipe slab cache (`pipe_cache_matches`: 1K/2K/cgroup
  vs pipe cache); proceeding on `pipe_cache_gate_ok == 0` reclaims buddy pages
  and fails downstream.
- `p0_gate_holders` / `close_p0_gate_holders` lifetime must be exact — leaked or
  double-closed gate pipes corrupt the oracle.
- Slab patch protocol: save → patch `user_pipe_buffer` → read/write → restore
  → `memcmp` readback (`restored_ok`); a failed restore is a hard error, not
  best-effort.
- Zero-page read (`len` 0 / `ENOTTY`) means wrong geometry, not "retry harder":
  stop and re-derive bank/slab values.

### `src/root.c` + `src/su_daemon.c` — UMH root + KernelSU late-load
- Scratch spans (`fake_work`, `umh_data`) must each fit in one page and must
  not overlap; non-zero scratch aborts before any write.
- `selinux_state.enforcing` old value must read back sane; bad values abort
  (never assume Enforcing/Permissive without reading).
- Workqueue chain validation is mandatory: `system_unbound_wq` slot → `wq` →
  `pwq` → `pool` with busy/color/refcnt/inflight/active sanity checks; any
  `bad workqueue/pwq/pool/counters` finding aborts the UMH write.
- UMH completion requires `wake=1 complete=1 retval=0 socket=1`; partial
  completion is failure.
- Staged `ksud` MUST be at hardcoded `KSU_LOADER_PATH`
  (`/data/local/tmp/ksud-s25u-kdp`); running directly from `/data` as uid 0
  trips a DEFEX safeplace kill — the bind-mount disguise is load-bearing.
- `--late-load --ephemeral` fallback: v3.2.5-era ksuds reject `--ephemeral`;
  the helper retries plain `late-load` only when the module is not live after
  the ephemeral attempt (verify-gated). Keep until the CLI contract is fixed.

## 5. TODO index (S0 exit criteria: all remain TODO)

- `TODO(provenance)`: samloader TGY/BRI transcripts, four-part version proof,
  fota.zip fingerprint/build-ID/changelist, product name.
- `TODO(kernel)`: boot/vendor_boot sizes + SHA-256, kernel slice size + SHA-256,
  Image header, kernel release string, BTF interval, sboot phys-load proof.
- `TODO(offsets)`: every `*_OFF` macro, BTF layouts, event ID, caller offset,
  pselect shift, bank/slab geometry, full P0 table + readback.
- `TODO(KSU)`: pinned KSU version, Samsung patch record, `check_symbol`,
  `modinfo` vermagic, KO + ksud sizes + SHA-256, static audit.
- `TODO(validation)`: device-measured SELinux, full-chain hardware transcript,
  KernelSU control-channel + manager evidence, repeatability/reboot/resetprop
  matrix, thermal/peak notes.

## 6. S0 non-goals (explicitly NOT done)

- No `samloader` query/download; no `lz4`/`tar` extraction; no
  `vmlinux-to-elf`/`llvm-nm`/`bpftool` runs (cf. `PORTING.md` §1–§3).
- No `src/targets/e1q-S9210ZHU6EZIF/` files (creating `target.h` by copying
  DZG1 is forbidden — it would mis-slide and panic).
- No `support/targets-v*.json` edits (S6 only, after hardware proof).
- No `.so` / `.ko` / `ksud` / `zip` / `img` artifacts committed.
- No kernel SHA, offsets, `vermagic`, P0 rows, or KSU hashes invented to "fill
  the table". This file intentionally leaves them as `TODO(...)`.

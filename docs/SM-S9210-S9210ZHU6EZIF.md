# SM-S9210 / S9210ZHU6EZIF porting record — S0 skeleton

> Stage: S0 (adaptation skeleton only). No firmware downloaded, no kernel
> extracted, no offsets derived, no target headers created, no feed touched,
> no binaries built. Every firmware-dependent value below that is not yet
> measured is marked `TODO(...)` and MUST NOT be filled with guesses, DZG1
> copies, or placeholders presented as fact.

Reference structure: [`SM-S9210-S9210ZHS6DZG1.md`](SM-S9210-S9210ZHS6DZG1.md).
Procedure: [`PORTING.md`](PORTING.md).
Feed rules: [`../README.md`](../README.md) + [`../support/README.md`](../support/README.md).

## 1. Firmware identity (S1 proven 2026-11-02; offsets/KSU/validation still TODO)

| Field | Value (S0) |
| --- | --- |
| Model | `SM-S9210` (China, e1q) |
| Device codename | `e1q` |
| Product name | `e1qzhx` (confirmed: `ro.product.system.name` / `ro.product.vendor.name` / `ro.product.bootimage.name` in fota.zip `SYSTEM/build.prop`, `VENDOR/build.prop`, ramdisk `build.prop`; vendor device `e1q`, board `pineapple`, ABI `arm64-v8a`, model `SM-S9210`) |
| AP / PDA | `S9210ZHU6EZIF` |
| CSC | `S9210OZS6EZIF` (OZS multi-CSC; this branch covers `TGY` + `BRI`. `CHC` belongs to a separate branch) |
| CP / baseband | `S9210ZCU6EZIF` |
| Four-part version | `S9210ZHU6EZIF/S9210OZS6EZIF/S9210ZCU6EZIF/S9210ZHU6EZIF` — confirmed present in BOTH `samloader-rs check-update --model SM-S9210 --region BRI --all` and `--region TGY --all` (byte-identical transcripts, saved at `/mnt/240G_SSD/opencode_tmp/check-update_{BRI,TGY}.txt`). NOTE 2026-11-02: samloader-rs lists EZIF under "Previous Stable Versions"; latest is now `S9210ZHS6EZJ1/...` (ZHU->ZHS CSC flip, out of scope). Legacy `version.xml` (`curl -A Kies2.0_FUS .../firmware/BRI|TGY/SM-S9210/version.xml`) still reports EZIF as `<latest o="17">`. This branch pins the exact EZIF four-part above. |
| Android version | `17` |
| One UI version | `9` |
| Build date | `2026-09-20` |
| Release date | `2026-10-21` |
| Security patch level | `2026-09-05` |
| Binary (bootloader) | `6` |
| Regions in scope | `TGY` + `BRI` (OZS). `CHC` explicitly out of scope for this branch |
| Kernel release | `6.1.162-android14-11-34343818-abS9210ZHU6EZIF` (from kernel `linux_banner` strings; also `6.1.162-android14-11-34343818-abS9210ZHU6EZIF SMP preempt mod_unload modversions aarch64` vermagic line; kernel build `#1 SMP PREEMPT Sun Sep 20 01:29:53 UTC 2026`, clang 17.0.2) |
| Build fingerprint | `samsung/e1qzhx/qssi_64:17/CP2A.260605.016/S9210ZHU6EZIF:user/release-keys` (from fota.zip `SYSTEM/build.prop` `ro.system.build.fingerprint`) |
| Build ID / changelist | Build ID `CP2A.260605.016`, display ID `CP2A.260605.016.S9210ZHU6EZIF`, changelist `34344539` (`ro.build.changelist`), build date `Sun Sep 20 10:29:28 KST 2026` (utc `1789867768`), SDK `37`, security patch `2026-09-05` (system + vendor agree), `ap-qb-id=115080882` (all from fota.zip `SYSTEM/build.prop` + `fota_info.txt`) |
| boot.img size / SHA-256 | `100663296` bytes, SHA-256 `df431d623ef3efb39875cd28c1ee47cb0c2a99eee6563fe677f2be6ca5b80d4e` (header v4, magic `ANDROID!`, page 4096; retained at `/mnt/240G_SSD/opencode_tmp/EZIF_work/boot.img`) |
| kernel size / SHA-256 | `38140416` bytes (`0x245fa00`, sliced at boot header offset `0x1000` with `kernel_size` u32le `@0x08`), SHA-256 `ce462331a8ef6c6c0ab94ac8ad4b9a3d6aea23a3455da929ea33621f8b6d351f` (retained at `/mnt/240G_SSD/opencode_tmp/EZIF_work/kernel`; byte-identical to fota.zip `BOOT/kernel` via `cmp`) |
| vendor_boot.img size / SHA-256 | `100663296` bytes, SHA-256 `0397f376da4338c0f45bb9ca69b301c11af2a5d7b4f8b195ba2de760bc4ef613` (magic `VNDRBOOT`; retained at `/mnt/240G_SSD/opencode_tmp/EZIF_work/vendor_boot.img`) |
| ARM64 Image text_offset / image_size / flags | `text_offset 0x0`, `image_size 0x2710000` (`40960000`), flags `0xa`, magic `ARMd` at `0x38` (Image header `@0x08/0x10/0x18` of the raw kernel slice) |
| SELinux (device-measured) | `TODO(validation): record from device (\`getenforce\`, expected \`Enforcing\`)` |
| tracefs event ID | `106` offline-derived 2026-11-02 (S2): `(__event_sched_blocked_reason - __start_ftrace_events)/8 = 0x2B0/8 = 86`, `__TRACE_LAST_TYPE = 20` (BTF `trace_type`), `20 + 86 = 106`. Numeral matches DZG1 by coincidence — computed fresh from the EZIF ELF, not copied. Device `id`-file read still `TODO(validation)` |

Provenance gate (S1, completed 2026-11-02): `samloader-rs` (`samloader 2.2.0`,
topjohnwu/samloader-rs, `cargo install samloader --locked`; no IMEI/serial
needed, no `--resume` flag — resumes automatically unless `--force`) returned
the EZIF four-part for BOTH `--region BRI` and `--region TGY` (byte-identical
transcripts). Commands run verbatim:

```sh
samloader check-update --model SM-S9210 --region BRI --all --verbose
samloader check-update --model SM-S9210 --region TGY --all --verbose
samloader download --model SM-S9210 --region BRI \
  --version "S9210ZHU6EZIF/S9210OZS6EZIF/S9210ZCU6EZIF/S9210ZHU6EZIF" \
  --threads 8 --out-file /mnt/240G_SSD/opencode_tmp/S9210ZHU6EZIF_BRI.zip --verbose
```

Downloaded ZIP: `/mnt/240G_SSD/opencode_tmp/S9210ZHU6EZIF_BRI.zip`
(`14297315137` bytes, SHA-256
`f13f7ec5834266c957ef6dc694b54b88d90444886bdf6ed840a007b6a010cd24`).
ZIP contents (5 entries): BL (`102553713` B), AP
`AP_S9210ZHU6EZIF_S9210ZHU6EZIF_MQB115080882_REV00_user_low_ship_MULTI_CERT_meta_OS17.tar.md5`
(`16215572603` B), CP (`83845230` B), HOME_CSC (`95662189` B), CSC (`95672424`
B). AP tar deleted after extracting `boot.img.lz4` (`22159441` B),
`vendor_boot.img.lz4` (`17157926` B), `meta-data/fota.zip` (`1297734735` B);
fota.zip deleted after extracting `SYSTEM/build.prop`, `VENDOR/build.prop`,
ramdisk `build.prop`, `fota_info.txt`, `BOOT/kernel`. Retained in
`/mnt/240G_SSD/opencode_tmp/`: the ZIP, `EZIF_work/kernel`,
`EZIF_work/boot.img`, `EZIF_work/vendor_boot.img`, the two `.lz4`, the four
prop/txt files, and `check-update_{BRI,TGY}.txt`. No large file was committed
to git (see `git status`).

Extraction (PORTING.md §2 script, `python3` + `lz4.frame`): decompress
`boot.img.lz4` → `boot.img`, read u32le `kernel_size` `@0x08` = `38140416`
(`0x245fa00`), slice `boot[0x1000:0x1000+kernel_size]` → `kernel`.
`BOOT/kernel` from fota.zip is byte-identical (`cmp` clean). Boot header:
magic `ANDROID!`, version 4, page 4096.

Full `linux_banner` (kernel strings):

```text
Linux version 6.1.162-android14-11-34343818-abS9210ZHU6EZIF (build-user@build-host) (Android (10087095, +pgo, +bolt, +lto, -mlgo, based on r487747c) clang version 17.0.2 (https://android.googlesource.com/toolchain/llvm-project d9f89f4d16663d5012e5c09495f3b30ece3d2362), LLD 17.0.2) #1 SMP PREEMPT Sun Sep 20 01:29:53 UTC 2026
```

Vermagic line: `6.1.162-android14-11-34343818-abS9210ZHU6EZIF SMP preempt
mod_unload modversions aarch64`.

## 2. Differences vs DZG1 (`S9210ZHS6DZG1`, device-tested baseline)

DZG1 reference: [`SM-S9210-S9210ZHS6DZG1.md`](SM-S9210-S9210ZHS6DZG1.md)
(`BP4A.251205.006`, Android 16, kernel `6.1.145-android14-11-33419968`,
`12` audited offsets + BTF layouts + P0 table + v3.2.5 feed pair).

| Axis | DZG1 (baseline, proven) | EZIF (this port, S0) | S0 verdict |
| --- | --- | --- | --- |
| PDA / CSC / CP | `S9210ZHS6DZG1` / `S9210OZS6DZG1` / `S9210ZCS6DZG1` | `S9210ZHU6EZIF` / `S9210OZS6EZIF` / `S9210ZCU6EZIF` | S1 proven (samloader BRI+TGY, ZIP+AP names) |
| Android / One UI | 16 / 8.x (`BP4A.251205.006`, build 2026-07-10) | 17 / 9, build 2026-09-20, release 2026-10-21, patch 2026-09-05 | Declared; kernel/GKI generation may differ — never assume same offsets |
| Binary | 6 (`ZHS6`) | 6 (`ZHU6`) | Same binary digit, still a different build — full re-audit required |
| Regions | BRI sales, OZS multi-CSC | TGY + BRI OZS in this branch; CHC separate branch | Scope narrower than "all OZS"; feed `models` must reflect this in S6 |
| Kernel image / SHA | `38005248` bytes, SHA-256 `c34386a0…` recorded | `38140416` bytes (`0x245fa00`), SHA-256 `ce462331…` (S1 measured) | No reuse — values differ as expected |
| Kernel release / vermagic | `6.1.145-android14-11-33419968-abS9210ZHS6DZG1` | `6.1.162-android14-11-34343818-abS9210ZHU6EZIF` / `TODO(KSU)` (S1 read banner; KSU rebuild pending) | No reuse; KSU `vermagic` must match exactly |
| Audited offsets (`KMALLOC_CACHES`, `SLIDE_NFULNL_LOGGER_NAME`, `CALL_USERMODEHELPER_EXEC_WORK`, `SYSTEM_UNBOUND_WQ`, `INIT_TASK`, `ROOT_TASK_GROUP`, `SELINUX_ENFORCING`, `ASHMEM_*`, `ANON_PIPE_BUF_OPS`, logger objects, boot-id pointers, misc fops, tracefs caller) | All recorded in DZG1 doc + `src/targets/e1q-S9210ZHS6DZG1/target.h` | S2 measured 2026-11-02 from EZIF ELF/BTF only — full table + DZG1 deltas in §7; every entry differs from DZG1 (no reuse). Symbol on this kernel is the plural `ashmem_miscs`; macro keeps the shared name at `ashmem_miscs + 0x10` (BTF `miscdevice.fops` byte `0x10`) | Copying `target.h` and renaming is FORBIDDEN (would boot-panic / mis-slide) |
| BTF struct layouts (file_operations, page, task, rt_mutex_waiter, configfs, workqueue, selinux_state) | Match S9280 profile | S2 re-dumped from EZIF BTF (`format raw` byte offsets) — all match the template structure, each re-verified, none copied (see §7). No reuse without byte-level proof — proof recorded | No reuse without byte-level proof |
| P0 table (`p0_fingerprint.h`, `P0_ORACLE_PROBE_OFFSET`, `P0_PHYS_OFFSET`, `P0_KERNEL_PHYS_LOAD`) | `0x1f0000` probe, `0x80000000` / `0x80080000`, 42 address words differ from S9280 | S2 regenerated from EZIF raw kernel: all 32 slides × 8 qwords + 256-qword readback verified (`p0_fingerprint.h` committed). `P0_PHYS_OFFSET = 0x80000000` DTB-proven (EZIF vendor_boot DTB `gunyah_hyp_region@80000000`, reg base `0x80000000`); `P0_KERNEL_PHYS_LOAD = 0x80080000` = memstart + ARM64 TEXT_OFFSET with same-board (SM-S9210/pineapple) hardware precedent — `TODO(validation)` linear-map self-consistency on EZIF hardware | Reuse across firmware is explicitly unsafe (cf. DZG1 §P0) |
| Slide params (`SLIDE_TRACEFS_EVENT_ID`, `WORKER_CALLER_OFF`, `PSELECT_WORD_SHIFT`, bank geometry, `SKB_DATA_DELTA`, `TASK_STRIDE`, `LOCK_OFF`) | `106` / `0xdb1a0` / `3`, e1s-style geometry, `-0xe80`, `0x1c0`/`0x5200`, default 15 slabs | Event ID `106` + caller `0x000db39c` derived from EZIF ELF (see §7; numeral 106 is recomputed, not copied). `SLIDE_PSELECT_WORD_SHIFT` + `SKB_DATA_DELTA` stay `TODO(offsets)` — hardware-tuned per firmware (see §7); bank/slab geometry keeps the invariant cross-target structure, re-validation on hardware still `TODO(validation)` | DZG1 values are hints for bring-up order only, never defaults |
| KernelSU pair | v3.2.5 feed pair + v3.3.0 Phase-D candidate (one 2026-10-03 success) | `TODO(KSU)` — rebuild + `check_symbol` + `modinfo` + static audit + hardware runs | Do NOT copy DZG1 `.ko`/`ksud` |
| Hardware validation | Device-tested 2026-09-11 (v3.2.5), candidate 2026-10-03 (v3.3.0) | `TODO(validation)` — no runs yet | S0 performs zero runs |

## 3. Stage plan S0–S6 and acceptance checklists

Numbering follows `PORTING.md` §1–§9. S0 is this file only.

- [ ] **S0 — skeleton (this stage). ACCEPT:** this md exists; identity table
  present with `TODO(...)` on every unmeasured field; DZG1 diff table present;
  S0–S6 plan + anti-panic list present; NO `src/targets/e1q-S9210ZHU6EZIF/`
  directory, NO `support/targets-v*.json` edit, NO binaries (`.so`/`.ko`/`zip`/`img`),
  NO fabricated SHA/offsets/vermagic. `git status` shows exactly one new file.
- [x] **S1 — provenance + extraction (PORTING.md §1–§2). DONE 2026-11-02:**
  samloader four-part transcripts (TGY + BRI, identical); download command +
  ZIP/AP names recorded in §1; `boot.img`/`kernel`/`vendor_boot.img` sizes +
  SHA-256 + Image header measured; fota.zip identity (fingerprint, display ID,
  build ID `CP2A.260605.016`, changelist, SDK 37, page size 4096) recorded;
  AP tar + fota.zip deleted after use, raw `kernel` + ZIP + props retained in
  `/mnt/240G_SSD/opencode_tmp/` (never committed).
- [x] **S2 — symbols + BTF + offsets (PORTING.md §3). DONE 2026-11-02
  (partial: all ELF/BTF/DTB-derivable values measured, see §7; two
  hardware-tuned values stay `TODO(offsets)`):** `vmlinux-to-elf`
  (`vmlinux.elf` 43222470 B, base `0xffffffc008000000` = `_text`, 107567
  symbols) + NDK-r29 `llvm-nm` transcript; exactly-one raw BTF blob
  `[0x1820e90, 0x1dd7cb8)` (5991976 B, header/section validated);
  `format raw` (328805 lines) + `format c` dumps kept in
  `/mnt/240G_SSD/opencode_tmp/EZIF_work/` during work (never committed);
  every macro-use offset filled from the EZIF ELF (no DZG1 carry-over —
  full diff table in §7); `ashmem_miscs + 0x10` derivation via BTF
  `miscdevice.fops`; logger-name/object/registry/boot-id roles kept
  distinct with pointer cross-checks; `sizeof`/member offsets from raw BTF
  with byte-alignment checks (all match the template structure, each
  re-verified, none copied). `SLIDE_PSELECT_WORD_SHIFT` and
  `SKB_DATA_DELTA` remain `TODO(offsets)` (hardware-tuned per firmware —
  in-repo pineapple 6.1 values diverge 0/3/4 and -0xe80/-0x1000; offline
  guessing is forbidden, so both expand to undeclared identifiers and any
  premature S4 use fails loudly instead of mis-sliding). New headers
  `src/targets/e1q-S9210ZHU6EZIF/target.h` +
  `src/targets/e1q-S9210ZHU6EZIF/p0_fingerprint.h` authored from EZIF data
  only; `make TARGET=e1q-S9210ZHU6EZIF
  ANDROID_NDK_HOME=/home/samson1357924/Android/Sdk/ndk/29.0.14206865 info`
  passes (release NOT run).
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

## 5. TODO index (S1 done: provenance/kernel resolved; offsets/KSU/validation remain TODO)

- [x] `TODO(provenance)` → DONE S1: samloader TGY/BRI transcripts, four-part
  version proof, fota.zip fingerprint/build-ID/changelist, product name (§1).
- [x] `TODO(kernel)` → DONE S1 (hashes/banner/header/fingerprint/display ID):
  boot/vendor_boot sizes + SHA-256, kernel slice size + SHA-256, Image header,
  kernel release string. Still open for S2: BTF interval, sboot phys-load proof.
- `TODO(offsets)`: all ELF/BTF/DTB-derivable `*_OFF` macros, BTF layouts,
  event ID, worker caller, full P0 table + readback DONE S2 (see §7).
  Still open: `SLIDE_PSELECT_WORD_SHIFT` + `SKB_DATA_DELTA` (hardware-tuned
  per firmware — S3/S6 must measure on EZIF hardware; both are loud
  compile-time `TODO(offsets)` interlocks, never DZG1 copies), plus
  `P0_KERNEL_PHYS_LOAD` linear-map self-consistency (offline derivation
  recorded in §7, hardware confirmation pending).
- `TODO(KSU)`: pinned KSU version, Samsung patch record, `check_symbol`,
  `modinfo` vermagic, KO + ksud sizes + SHA-256, static audit.
- `TODO(validation)`: device-measured SELinux, full-chain hardware transcript,
  KernelSU control-channel + manager evidence, repeatability/reboot/resetprop
  matrix, thermal/peak notes.

## 6. S0 non-goals (explicitly NOT done; S1 update: samloader + extract done;
S2 update: ELF/BTF/P0 measured, headers authored — release NOT built)

- S1 DONE: `samloader` query/download + `lz4`/`tar` extraction (cf. §1 record).
- S2 DONE 2026-11-02: `vmlinux-to-elf`/`llvm-nm`/`bpftool` runs (cf. §7);
  `src/targets/e1q-S9210ZHU6EZIF/target.h` + `p0_fingerprint.h` authored
  from EZIF data only (copying DZG1 values remains forbidden — S2 verified
  every entry differs). Two hardware-tuned values are loud `TODO(offsets)`
  interlocks, not guesses; `release` NOT run (S4 scope).
- No `support/targets-v*.json` edits (S6 only, after hardware proof).
- No `.so` / `.ko` / `ksud` / `zip` / `img` artifacts committed.
- No kernel SHA, offsets, `vermagic`, P0 rows, or KSU hashes invented to "fill
  the table". Unmeasurable-offline items stay `TODO(...)`.

## 7. S2 measurement record (2026-11-02, EZIF ELF/BTF/DTB only)

Work intermediates (`vmlinux.elf`, `vmlinux.nm`, `vmlinux.btf`,
`vmlinux-btf.raw`, `vmlinux-btf.h`, `worker_thread.asm`,
`core_sys_select.asm`, `p0_fingerprint_gen.h`, `e1q.dtb`, `bl/abl.elf`)
retained in `/mnt/240G_SSD/opencode_tmp/EZIF_work/`, never committed.
Toolchain note: the task's `ANDROID_NDK_HOME=/home/samson910022/...` path
does not exist on this machine; S2 used the installed
`/home/samson1357924/Android/Sdk/ndk/29.0.14206865` (r29) for `llvm-nm` /
`llvm-objdump` / `make info`.

### 7.1 ELF recovery + BTF blob

- `vmlinux-to-elf kernel vmlinux.elf` → 43222470 B, guessed base
  `0xffffffc008000000` (matches `_text` from `llvm-nm`: `107567` symbols).
- Raw BTF scan (PORTING.md §3 script): exactly one validated blob
  `[0x1820e90, 0x1dd7cb8)` (5991976 B, `magic 0xeb9f ver 1 flags 0
  hdr 24`, section bounds + NUL string-start checked).
- `bpftool btf dump file vmlinux.btf format raw` (328805 lines, values used
  for every layout below) + `format c` (150823 lines, declaration view only).

### 7.2 Symbol offsets (each = `llvm-nm` addr − `0xffffffc008000000`)

| Macro/use | Symbol | EZIF off | DZG1 off | Δ |
| --- | --- | ---: | ---: | ---: |
| `CALL_USERMODEHELPER_EXEC_WORK_OFF` | `call_usermodehelper_exec_work` | `0x000d3be0` | `0x000d39cc` | +0x214 |
| `SLIDE_TRACEFS_WORKER_CALLER_OFF` | post-`bl schedule` ret in `worker_thread` (§7.4) | `0x000db39c` | `0x000db1a0` | +0x1fc |
| `NOOP_LLSEEK_OFF` | `noop_llseek` | `0x003a235c` | `0x003a14e4` | +0xe78 |
| `COPY_SPLICE_READ_OFF` | `generic_file_splice_read` | `0x003f07c4` | `0x003ef340` | +0x1484 |
| `CONFIGFS_READ_ITER_OFF` | `configfs_read_iter` | `0x00472b84` | `0x004712a4` | +0x18e0 |
| `CONFIGFS_BIN_WRITE_ITER_OFF` | `configfs_bin_write_iter` | `0x004730b4` | `0x004717d4` | +0x18e0 |
| `ASHMEM_IOCTL_OFF` | `ashmem_ioctl` | `0x00d44e8c` | `0x00d3a314` | +0xab78 |
| `ASHMEM_COMPAT_IOCTL_OFF` | `compat_ashmem_ioctl` | `0x00d457c4` | `0x00d3ac4c` | +0xab78 |
| `ASHMEM_MMAP_OFF` | `ashmem_mmap` | `0x00d4581c` | `0x00d3aca4` | +0xab78 |
| `ASHMEM_OPEN_OFF` | `ashmem_open` | `0x00d45a48` | `0x00d3aed0` | +0xab78 |
| `ASHMEM_RELEASE_OFF` | `ashmem_release` | `0x00d45ad0` | `0x00d3af58` | +0xab78 |
| `ASHMEM_SHOW_FDINFO_OFF` | `ashmem_show_fdinfo` | `0x00d45bf0` | `0x00d3b078` | +0xab78 |
| `ANON_PIPE_BUF_OPS_OFF` | `anon_pipe_buf_ops` | `0x0122ad50` | `0x01219d90` | +0x10fc0 |
| `ASHMEM_FOPS_OFF` | `ashmem_fops` | `0x013e2e30` | `0x013d1140` | +0x11cf0 |
| `SLIDE_NFULNL_LOGGER_OFF` (`"nfnetlink_log"` string, §7.3) | string ref'd by `nfulnl_logger.name` | `0x016ba44f` | `0x016a61e6` | +0x14269 |
| `KMALLOC_CACHES_OFF` | `kmalloc_caches` | `0x01781458` | `0x0176c6f8` | +0x14760 |
| `SLIDE_LOGGERS_0_1_OFF` (`nfulnl_logger` object, §7.3) | `nfulnl_logger` | `0x02262828` | `0x02242a20` | +0x1fe08 |
| `SYSTEM_UNBOUND_WQ_OFF` | `system_unbound_wq` | `0x0225ac60` | `0x0223ae60` | +0x20200 |
| `INIT_TASK_OFF` | `init_task` | `0x0226f6c0` | `0x0224f8c0` | +0x1fe00 |
| `ASHMEM_MISC_FOPS_OFF` | `ashmem_miscs + offsetof(miscdevice, fops)=0x10` (§7.3) | `0x023dc200` | `0x023bb5b0` | +0x20650 |
| `SLIDE_RANDOM_BOOT_ID_DATA_OFF` (`.data` ptr slot, §7.3) | `random_table` boot_id entry + 0x8 | `0x02396a98` | `0x023762f0` | +0x204a8 |
| `ROOT_TASK_GROUP_OFF` | `root_task_group` | `0x0246dd80` | `0x0244cd80` | +0x20f00 |
| `SELINUX_ENFORCING_OFF` | `selinux_state` + `enforcing@0x0` (BTF) | `0x02542618` | `0x02521588` | +0x21030 |
| `SLIDE_SYSCTL_BOOTID_OFF` | `sysctl_bootid` (§7.3) | `0x02625768` | `0x026046e8` | +0x21080 |

Every entry differs from DZG1 — reuse would mis-slide/panic. An
independent re-check script compared all 20 `target.h` `_OFF` defines
against `vmlinux.nm`: 20/20 exact.

### 7.3 Pointer/string cross-checks (no bare-string acceptance)

- `nfulnl_logger` (`0x02262828`): first qword in the raw kernel =
  `0xffffffc0096ba44f` → image offset `0x016ba44f`; the
  `"nfnetlink_log\0"` byte string occurs exactly ONCE in the kernel at file
  offset `0x016ba44f`. String ↔ object mutually proven.
- `loggers` (`0x02262770`, first qword `0x0` at rest — no logger registered
  in the static image) vs `nfulnl_logger` (`+0xb8`): distinct objects, roles
  kept separate per PORTING.md §3.
- `random_table` (`0x02396990`): entry 4 (`0x2396a90`, 64 B/entry) has
  `procname → "boot_id"`, `.data` slot file offset `0x02396a98`, current
  value `0xffffffc00a625768` = `KIMAGE_BASE + 0x02625768` = `sysctl_bootid`
  symbol address. Pointer slot ↔ storage mutually proven; restore target is
  the symbol, not a guess.
- `ashmem_miscs` (`0x023dc1f0`, plural on this kernel as on DZG1) + BTF
  `miscdevice.fops` byte offset `0x10` (`bits_offset 128`) → `0x023dc200`.
- `selinux_state.enforcing` is the first member (BTF `bits_offset 0`), so
  the enforcing address equals the symbol address.

### 7.4 Tracefs event ID + worker caller (offline derivation)

- BTF `trace_type`: `__TRACE_LAST_TYPE = 20` (same enum position as
  PORTING.md §5, re-read from the EZIF dump, not assumed).
- `__event_sched_blocked_reason 0x0221f160` −
  `__start_ftrace_events 0x0221eeb0` = `0x2B0`; `/8` = index `86`
  (zero-based); event ID = `20 + 86 = 106`. The numeral matches DZG1 by
  coincidence — the subtraction was recomputed from the EZIF ELF.
  Device `id`-file read still required (`TODO(validation)`); per-boot
  caller-minus-offset 64-KiB-alignment + P0-range checks stay mandatory.
- `worker_thread` (`0x000db2fc`): blocking `bl schedule` at `0xdb398`,
  return PC = next instruction `0xffffffc0080db39c` → caller off
  `0x000db39c` (= `worker_thread+0xA0`).

### 7.5 BTF layouts (raw `bits_offset/8`, non-byte-aligned rejected)

```text
sizeof(struct file_operations) = 0x110
file_operations.unlocked_ioctl = 0x50, compat_ioctl = 0x58, mmap = 0x60
file_operations.open = 0x70, release = 0x80, splice_read = 0xc8
file_operations.show_fdinfo = 0xe0
miscdevice.fops = 0x10
selinux_state.enforcing = 0x0
task_struct.usage = 0x40, prio = 0x84, normal_prio = 0x8c
task_struct.sched_task_group = 0x348
task_struct.pi_lock = 0x924, pi_waiters = 0x938
task_struct.pi_top_task = 0x948, pi_blocked_on = 0x950
sizeof(struct page) = 0x40
page.compound_head = 0x08 (union@0x8 + struct@0), slab_cache = 0x18
(struct slab.slab_cache bits 192 within the page overlay), page_type = 0x30
sizeof(struct rt_mutex_waiter) = 0x58
waiter: pi_tree_entry = 0x18, task = 0x30, lock = 0x38
waiter: wake_state = 0x40, prio = 0x44, deadline = 0x48, ww_ctx = 0x50
ctl_table.data = 0x8
nf_logger: size = 32, name = 0x0
workqueue_struct.dfl_pwq = 0xb0
pool_workqueue: pool = 0x0, wq = 0x8, work_color = 0x10, refcnt = 0x18
pool_workqueue: nr_in_flight = 0x1c, nr_active = 0x5c, max_active = 0x60
worker_pool.worklist = 0x28, nr_idle = 0x3c
work_struct: data = 0x0, entry = 0x8, func = 0x18
configfs_buffer: page = 16, needs_read_fill = 80, bin_buffer = 88
configfs_buffer: bin_buffer_size = 96, cb_max_size = 100
```

All match the shared-header structure; each was re-read from the EZIF raw
dump (byte-aligned members only), none copied.

### 7.6 Physical load (DTB re-verified, loader signed)

- `P0_PHYS_OFFSET = 0x80000000`: proven from EZIF's own `vendor_boot.img`
  DTB (first DTB at image offset `0xe1b000`, 379345 B):
  `gunyah_hyp_region@80000000` with reg `base 0x80000000 size 0xe00000`.
  Same numeral as DZG1, independently derived — not carried over.
- `P0_KERNEL_PHYS_LOAD = 0x80080000`: memstart + ARM64 TEXT_OFFSET
  convention for the 4 KiB-granule Image (`text_offset 0`), same-board
  (SM-S9210/pineapple) DZG1 hardware precedent (full chain passed through
  it). S2 attempted loader disassembly: EZIF `abl.elf` is signed (no
  section headers, zero readable strings) — no offline byte-proof
  available. The value is recorded with this evidence chain; a wrong value
  fails safe (P0 oracle fingerprint mismatch → gate/probe verification
  aborts before destructive steps), and linear-map self-consistency must
  still be confirmed on EZIF hardware (`TODO(validation)`, S6 gate).

### 7.7 P0 fingerprints

Generated from the EZIF raw kernel for all 32 slides `0x000000–0x1f0000`
(`P0_ORACLE_PROBE_OFFSET = 0x1f0000`), 8 qwords per row at page offsets
`0x000/0x200/…/0xe00`; all 256 source qwords read back verified.
Committed as `src/targets/e1q-S9210ZHU6EZIF/p0_fingerprint.h`.
Row `0x000000` starts `0x54fffee16a15011f…` (DZG1 starts `0xa9017fff…`) —
different kernel, different table.

### 7.8 Explicitly NOT measured (TODO, never guessed)

- `SLIDE_PSELECT_WORD_SHIFT`: hardware-tuned per firmware (in-repo
  pineapple 6.1 values diverge: essi `0`, DZG1/S9280 `3`, dm3q-FZF5 `4`).
  Static bounds from the EZIF ELF: `PSELECT_ROUTE_NFDS = 320` →
  5 words/set (15-word read/write/exception array); BTF compact waiter =
  11 qwords ⇒ SHIFT ∈ {0..4}; EZIF `core_sys_select` frame is `0x1c0` with
  on-stack in/out/ex copies at `[sp+0x50, +0x78, +0xa0)` for nfds=320.
  Which copied qword overlaps waiter qword zero is only observable on
  device (DZG1's `3` must NOT be copied). `target.h` carries a loud
  compile-time `TODO(offsets)` interlock.
- `SKB_DATA_DELTA`: hardware-tuned per firmware (in-repo pineapple 6.1
  values diverge: `-0xe80` vs `-0x1000`, e.g. dm3q-FZF5). Same loud
  `TODO(offsets)` interlock (a silent `common.h` default would be a hidden
  guess).
- Anti-panic guards (§4) verified present in shared code and inherited by
  the new target without modification: `slide_commit` align/range/stale
  (`slide_app.c:2917+`), tracefs quorum `SLIDE_TRACEFS_MIN_VOTES` default 2
  (`slide_app.c:214`), P0 gate `hits==1 && changed==0` (`pipe.c:1175`),
  fops full-table audit + `owner==0` (`fops.c:39-96,412,519`), configfs
  `ERANGE` (`fops.c:275`, `util.c:2808`), pipe same-page + `is_direct`
  checks (`pipe.c`, `fops.c`, `root.c`).

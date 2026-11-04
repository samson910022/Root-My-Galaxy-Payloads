# SM-S9210 / S9210ZHU6EZIF porting record — S0 skeleton

> Stage: S0 (adaptation skeleton only). No firmware downloaded, no kernel
> extracted, no offsets derived, no target headers created, no feed touched,
> no binaries built. Every firmware-dependent value below that is not yet
> measured is marked `TODO(...)` and MUST NOT be filled with guesses, DZG1
> copies, or placeholders presented as fact.

Reference structure: [`SM-S9210-S9210ZHS6DZG1.md`](SM-S9210-S9210ZHS6DZG1.md).
Procedure: [`PORTING.md`](PORTING.md).
Feed rules: [`../README.md`](../README.md) + [`../support/README.md`](../support/README.md).

## 1. Firmware identity (S1 proven 2026-11-02; offsets static-done §7–§8.6, KSU static-done/HW-partial §9, validation partial 2/7 §9.16)

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
| Kernel release / vermagic | `6.1.145-android14-11-33419968-abS9210ZHS6DZG1` | `6.1.162-android14-11-34343818-abS9210ZHU6EZIF` (S1 banner read; KSU `vermagic` exact-match proven §9, see §9.2) | No reuse; KSU `vermagic` must match exactly |
| Audited offsets (`KMALLOC_CACHES`, `SLIDE_NFULNL_LOGGER_NAME`, `CALL_USERMODEHELPER_EXEC_WORK`, `SYSTEM_UNBOUND_WQ`, `INIT_TASK`, `ROOT_TASK_GROUP`, `SELINUX_ENFORCING`, `ASHMEM_*`, `ANON_PIPE_BUF_OPS`, logger objects, boot-id pointers, misc fops, tracefs caller) | All recorded in DZG1 doc + `src/targets/e1q-S9210ZHS6DZG1/target.h` | S2 measured 2026-11-02 from EZIF ELF/BTF only — full table + DZG1 deltas in §7; every entry differs from DZG1 (no reuse). Symbol on this kernel is the plural `ashmem_miscs`; macro keeps the shared name at `ashmem_miscs + 0x10` (BTF `miscdevice.fops` byte `0x10`) | Copying `target.h` and renaming is FORBIDDEN (would boot-panic / mis-slide) |
| BTF struct layouts (file_operations, page, task, rt_mutex_waiter, configfs, workqueue, selinux_state) | Match S9280 profile | S2 re-dumped from EZIF BTF (`format raw` byte offsets) — all match the template structure, each re-verified, none copied (see §7). No reuse without byte-level proof — proof recorded | No reuse without byte-level proof |
| P0 table (`p0_fingerprint.h`, `P0_ORACLE_PROBE_OFFSET`, `P0_PHYS_OFFSET`, `P0_KERNEL_PHYS_LOAD`) | `0x1f0000` probe, `0x80000000` / `0x80080000`, 42 address words differ from S9280 | S2 regenerated from EZIF raw kernel: all 32 slides × 8 qwords + 256-qword readback verified (`p0_fingerprint.h` committed). `P0_PHYS_OFFSET = 0x80000000` DTB-proven (EZIF vendor_boot DTB `gunyah_hyp_region@80000000`, reg base `0x80000000`); `P0_KERNEL_PHYS_LOAD = 0x80080000` = memstart + ARM64 TEXT_OFFSET with same-board (SM-S9210/pineapple) hardware precedent — `TODO(validation)` linear-map self-consistency on EZIF hardware | Reuse across firmware is explicitly unsafe (cf. DZG1 §P0) |
| Slide params (`SLIDE_TRACEFS_EVENT_ID`, `WORKER_CALLER_OFF`, `PSELECT_WORD_SHIFT`, bank geometry, `SKB_DATA_DELTA`, `TASK_STRIDE`, `LOCK_OFF`) | `106` / `0xdb1a0` / `3`, e1s-style geometry, `-0xe80`, `0x1c0`/`0x5200`, default 15 slabs | Event ID `106` + caller `0x000db39c` derived from EZIF ELF (see §7; numeral 106 is recomputed, not copied). `SLIDE_PSELECT_WORD_SHIFT` + `SKB_DATA_DELTA` stay `TODO(offsets)` — hardware-tuned per firmware (see §7); bank/slab geometry keeps the invariant cross-target structure, re-validation on hardware still `TODO(validation)` | DZG1 values are hints for bring-up order only, never defaults |
| KernelSU pair | v3.2.5 feed pair + v3.3.0 Phase-D candidate (one 2026-10-03 success) | v3.3.1 primary + v3.3.0 fallback — static build + audit DONE §9 (vermagic exact, 0 missing/0 CRC); hardware pairing PARTIAL (§9.16) | Do NOT copy DZG1 `.ko`/`ksud` |
| Hardware validation | Device-tested 2026-09-11 (v3.2.5), candidate 2026-10-03 (v3.3.0) | hardware rounds recorded §9.6–§9.16 (combined 2/7); full matrix still `TODO(validation)` | S0 performs zero runs |

## 3. Stage plan S0–S6 and acceptance checklists

Numbering follows `PORTING.md` §1–§9. S0 is this file only.

- [ ] **S0 — skeleton (this stage). ACCEPT (HISTORICAL snapshot, superseded by S1–S5 + §9.16):** this md exists; identity table
  present with `TODO(...)` on every unmeasured field; DZG1 diff table present;
  S0–S6 plan + anti-panic list present; NO `src/targets/e1q-S9210ZHU6EZIF/`
  directory, NO `support/targets-v*.json` edit, NO binaries (`.so`/`.ko`/`zip`/`img`),
  NO fabricated SHA/offsets/vermagic. `git status` at S0 showed exactly one new file.
  (Current branch: 9 files incl. candidate artifacts per §6/§9.4/§9.15 — `support/` feed still untouched by design.)
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
- [x] **S3 — physical load + slide params (PORTING.md §4–§5). STATIC DONE + ON-DEVICE TUNED (§8.6: SHIFT=3/DELTA=-0xe80 HIT; MM 0x400 slabinfo-observed):** sboot
  `text_offset+0x80000000` derivation with file offset + disassembly (no S25U
  copy); `P0_PHYS_OFFSET` / `P0_KERNEL_PHYS_LOAD`: tracefs/canonical full chain has on-device root success (§9.6/§9.16); Physical-P0 fallback / `0x80080000` independent cross-validation still open; tracefs event ID from
  device `id` file or `(__event - __start)/8 + __TRACE_LAST_TYPE` math;
  `worker_thread` post-`bl schedule` caller derivation; per-boot caller-minus-offset
  64-KiB-alignment + P0-range verification; `SLIDE_PSELECT_WORD_SHIFT` from
  `pselect6`/`do_pselect` disassembly + BTF waiter layout (0 is a finding, not a default).
- [x] **S4 — target headers + P0 table (PORTING.md §5–§6). DONE (headers authored from EZIF data only; release 104128 B + SHA recorded §9.15; artifact published in `58a6772`):** new
  `src/targets/e1q-S9210ZHU6EZIF/target.h` + `p0_fingerprint.h` authored from
  EZIF data only; all 32 slides × 8 qwords generated with 256-qword readback;
  `TARGET=e1q-S9210ZHU6EZIF release` builds fixed-size `.so`; artifact copied to
  `artifacts/e1q-S9210ZHU6EZIF/` with size + SHA-256 recorded.
- [x] **S5 — KernelSU module (PORTING.md §7). STATIC DONE §9 (dual v3.3.1+v3.3.0, vermagic exact, audit 0 missing/0 CRC; HW pairing PARTIAL §9.16):** Samsung patch applies
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

## 5. TODO index (S1–S5 static done; S6 validation partial — see §9.16)

- [x] `TODO(provenance)` → DONE S1: samloader TGY/BRI transcripts, four-part
  version proof, fota.zip fingerprint/build-ID/changelist, product name (§1).
- [x] `TODO(kernel)` → DONE S1 (hashes/banner/header/fingerprint/display ID):
  boot/vendor_boot sizes + SHA-256, kernel slice size + SHA-256, Image header,
  kernel release string. Still open for S2: BTF interval, sboot phys-load proof.
- `TODO(offsets)`: all ELF/BTF/DTB-derivable `*_OFF` macros, BTF layouts,
  event ID, worker caller, full P0 table + readback DONE S2 (see §7).
  Hardware-tuned `SLIDE_PSELECT_WORD_SHIFT=3` + `SKB_DATA_DELTA=-0xe80`
  CLOSED on-device §8.6 (was loud `TODO(offsets)` interlock, never DZG1 copy).
  Still open: `P0_KERNEL_PHYS_LOAD` linear-map self-consistency (offline derivation
  recorded in §7, hardware confirmation pending).
- [x] `TODO(KSU)` → STATIC DONE §9: pinned KSU versions (v3.3.1+v3.3.0), Samsung patch record, `check_symbol`,
  `modinfo` vermagic exact, KO + ksud sizes + SHA-256, static audit (0 missing/0 CRC).
  HW pairing PARTIAL §9.16 (su/selinux/driver-version CLOSED; Manager UI + control-channel + resetprop + repeatability TODO).
- `TODO(validation)`: device-measured SELinux, full-chain hardware transcript,
  KernelSU control-channel + manager evidence, repeatability/reboot/resetprop
  matrix, thermal/peak notes.

## 6. S0 non-goals (explicitly NOT done at S0; updates: S1 samloader+extract done;
S2 ELF/BTF/P0 measured + headers authored; S4 release built; S5 KSU static done;
candidate artifacts published in `58a6772` — `support/` feed still untouched by design)

- S1 DONE: `samloader` query/download + `lz4`/`tar` extraction (cf. §1 record).
- S2 DONE 2026-11-02: `vmlinux-to-elf`/`llvm-nm`/`bpftool` runs (cf. §7);
  `src/targets/e1q-S9210ZHU6EZIF/target.h` + `p0_fingerprint.h` authored
  from EZIF data only (copying DZG1 values remains forbidden — S2 verified
  every entry differs). Two hardware-tuned values are loud `TODO(offsets)`
  interlocks, not guesses; `release` NOT run (S4 scope).
- No `support/targets-v*.json` edits (S6 only, after hardware proof — still untouched in this PR by design).
- Candidate `.so` / `.ko` / `ksud` artifacts published in `58a6772` (see §9.4/§9.15 for sizes+SHA); at S0 time none existed.
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
  (`slide_app.c`, see `SLIDE_TRACEFS_MIN_VOTES`), P0 gate `verify_p0_pipe_oracle_gate`
  (`pipe.c`, gate/probe pair contract),
  fops full-table audit + `owner==0` (`fops.c:39-96,412,519`), configfs
  `ERANGE` (`fops.c:275`, `util.c:2808`), pipe same-page + `is_direct`
  checks (`pipe.c`, `fops.c`, `root.c`).

## 8. S3 build-attempt record + static re-convergence (2026-11-02, no device)

S3 ran exactly the two commands below. No `target.h` value was changed,
no feed/KSU file touched at S3 time (candidate artifacts were published later in `58a6772`, `support/` still untouched).

### 8.1 `make info` — PASS

```sh
make TARGET=e1q-S9210ZHU6EZIF \
  ANDROID_NDK_HOME=/home/samson1357924/Android/Sdk/ndk/29.0.14206865 info
```

Output (exit 0):

```text
TARGET=e1q-S9210ZHU6EZIF
APP_TARGET_CFLAGS=
TARGET_CC=/home/samson1357924/Android/Sdk/ndk/29.0.14206865/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android35-clang
PRELOAD=build/e1q-S9210ZHU6EZIF/cve-2026-43499
APP_PRELOAD=build/e1q-S9210ZHU6EZIF/cve-2026-43499-app.so
APP_RELEASE=build/e1q-S9210ZHU6EZIF/cve-2026-43499-app.release.so
APP_STABLE=build/e1q-S9210ZHU6EZIF/cve-2026-43499-app.stable.so
ROOT_HELPER=build/e1q-S9210ZHU6EZIF/cve-2026-43499-root
```

`info` only prints paths — it never compiles `target.h`, so the two
`TODO(offsets)` interlocks are (correctly) silent here.

### 8.2 `make release` — FAIL (fail-closed, both interlocks fire)

```sh
make TARGET=e1q-S9210ZHU6EZIF \
  ANDROID_NDK_HOME=/home/samson1357924/Android/Sdk/ndk/29.0.14206865 release
```

Result: exit 2, no `.so` emitted. The full compiler errors (verbatim):

```text
src/util.c:1807:28: error: use of undeclared identifier 'TODO_offsets_SKB_DATA_DELTA_UNMEASURED'
 1807 |   intptr_t payload_delta = SKB_DATA_DELTA;
       |                            ^
src/targets/e1q-S9210ZHU6EZIF/target.h:55:25: note: expanded from macro 'SKB_DATA_DELTA'
   55 | #define SKB_DATA_DELTA (TODO_offsets_SKB_DATA_DELTA_UNMEASURED)
      |                         ^
1 error generated.
src/slide_app.c:894:10: error: use of undeclared identifier 'TODO_offsets_PSELECT_WORD_SHIFT_UNMEASURED'
  894 |   return SLIDE_PSELECT_WORD_SHIFT + waiter_word;
       |          ^
src/targets/e1q-S9210ZHU6EZIF/target.h:77:34: note: expanded from macro 'SLIDE_PSELECT_WORD_SHIFT'
   77 | #define SLIDE_PSELECT_WORD_SHIFT TODO_offsets_PSELECT_WORD_SHIFT_UNMEASURED
      |                                  ^
1 error generated.
make: *** [Makefile:299: build/e1q-S9210ZHU6EZIF/cve-2026-43499-app.release.so] Error 1
```

Interlock trigger evidence:

- `SKB_DATA_DELTA` blows up in `src/util.c:1807`
  (`prepare_skb_payload`, `payload_delta = SKB_DATA_DELTA`).
- `SLIDE_PSELECT_WORD_SHIFT` blows up in `src/slide_app.c:894`
  (`slide_pselect_global_word`, `return SLIDE_PSELECT_WORD_SHIFT +
  waiter_word`).
- Two independent translation units refuse to compile → fail-closed
  proven: there is NO code path that can silently ship a guessed value.
  (`common.h:59-60` has a `-0xe80` fallback, but the explicit
  `target.h:55` definition shadows it, so the fallback can never mask
  the interlock.)

### 8.3 Static re-convergence (no guessing; bounds only)

Re-disassembled from the retained EZIF ELF
(`/mnt/240G_SSD/opencode_tmp/EZIF_work/`, NDK-r29 `llvm-objdump`).
Symbols: `core_sys_select @0x3c3d64`, `do_select @0x3c4160` (static;
there is NO `do_pselect` symbol on this 6.1 kernel — the pselect path
is `__arm64_sys_pselect6 @0x3c4b2c` → `core_sys_select` →
`do_select`).

`SLIDE_PSELECT_WORD_SHIFT`:

- `PSELECT_ROUTE_NFDS = 320` (`common.h:157`) → 320/64 = 5 words/set,
  15-word in/out/ex array (`slide_app.c:888-918`,
  `slide_pselect_words_per_set`, `slide_pselect_put_global_word`).
- EZIF `core_sys_select` frame is `0x1c0`
  (`sub sp, sp, #0x1c0`); on-stack copies land at `[sp+0x50, +0x78,
  +0xa0)` for nfds=320 (`add x23, sp, #0x50` stack-buffer path,
  `get_fd_set`/`set_fd_set` triplets, 6 `memset`s + `bl do_select`).
- Compact waiter (`COMPACT_RT_MUTEX_WAITER=1`, `target.h:65`) is 11
  qwords (words 0–10: tree_pc/right/left, pi_pc/right/left, task, lock,
  wake_state+prio, deadline, ww_ctx; `slide_app.c:1000-1051`).
- `slide_pselect_global_word = SHIFT + waiter_word` (`slide_app.c:893`);
  waiter word 10 must still land inside the 15-word array ⇒ SHIFT ∈
  {0..4}. Same bound as S2 §7.8 — re-verified, not narrowed further.
- Which copied qword overlaps waiter qword zero depends on the
  runtime stack/register contents at `pselect` entry and is only
  observable on device. In-repo pineapple 6.1 evidence shows all of
  {0, 3, 4} occur (essi-family `0`, DZG1/S9280 `3`, dm3q-FZG1 `4`),
  so no value can be inferred.
- Missing experiment that fixes it: on an SM-S9210 EZIF device, run a
  `SLIDE_ONLY` dry-run sweeping SHIFT over {0..4} (nothing else
  changed) and score the `slide-kaslr-ok` rate per value; accept only
  the value with unanimous per-boot agreement that also passes the
  64-KiB-alignment + P0-range checks (`slide_app.c` commit path).
  Until then the interlock stays.

`SKB_DATA_DELTA`:

- Meaning: `payload_base = skb base + SKB_DATA_DELTA`
  (`util.c:1807-1813`); it anchors every derived address
  (`fake_lock = payload_base + LOCK_OFF`, `fake_task`, `fake_fops`,
  bank slots; `util.c:1876-1912`) and `slide_bank_payload_base`.
- In-repo pineapple 6.1 values diverge: `-0xe80` (DZG1, essi-family,
  most e1x) vs `-0x1000` (dm3q-FZF5, e1s-FZE1/FZF3-family, e2s, r12s).
  `-0xe80` = fragment-biased data start (`P0_ORACLE_GATE_PAGE_OFF =
  0x0e80`, `SKB_FRAG_BIAS = 0`); `-0x1000` = full-page interpretation
  (cf. `util.c:2073` FOPS mirror comment). Which one the EZIF allocator
  path yields is a runtime reclaim property, not in the ELF/BTF.
- Missing experiment that fixes it: on device, reclaim with each
  candidate and check `pipe_cache_gate_ok` +
  `pipe_reclaim_cache_gate`, then `cfi read` length/`ENOTTY` and the
  slab `memcmp(readback)` `restored_ok` (`util.c`, `pipe.c`). A
  zero-length read (`len 0` / `ENOTTY`) means wrong geometry, not
  "retry harder" (§4). Accept only the delta whose reclaim lands on
  the EZIF pipe slab cache with clean restore.

### 8.4 Pending on-device measurement list (all BLOCKING for release)

- [ ] SHIFT sweep {0..4} → `slide-kaslr-ok` rate + unanimous per-boot
  agreement + align/range checks (§8.3).
- [ ] DELTA A/B (`-0xe80` vs `-0x1000`) → pipe reclaim gate + cfi
  read/restore matrix (§8.3).
- [ ] Tracefs `id`-file read (offline math says 106; device file
  authoritative), per-boot caller-minus-offset 64-KiB alignment +
  P0-range verification.
- [ ] `P0_KERNEL_PHYS_LOAD` linear-map self-consistency through the
  full chain (S2 §7.6 evidence recorded, hardware confirmation open).
- [ ] Full hardware chain (tracefs slide → fops → cfi → phys → root
  umh → pipe → KernelSU late-load → granted `su`) + repeatability /
  reboot matrix (S6 scope).

### 8.5 Verdict

Without a physical SM-S9210 EZIF device, S3 CANNOT produce a final
release. That is the designed outcome, not a failure: the two
compile-time interlocks exist precisely so that no `.so` can be built
with a guessed SHIFT/DELTA (a wrong value mis-slides or panics the
target). Status = **BLOCKING on EZIF hardware**. S4/S5/S6 remain gated
until §8.4 is measured on device.

### 8.6 S3 completion — both interlocks cleared on EZIF hardware (2026-11-02)

On-device runs on the live SM-S9210 EZIF unit (boot `8ae3860a` alive)
fixed both hardware-tuned values; `target.h` now carries measured
values, not guesses:

- `SKB_DATA_DELTA = (-0xe80LL)` — on-device HIT confirmed.
- `SLIDE_PSELECT_WORD_SHIFT = 3` — gate HIT + DZG1 same-platform
  (SM-S9210/pineapple) prior. The retry7 MISS is characterized as a
  dying-boot pipeline fault, not a SHIFT finding.
- `MM_STRUCT_SZ = 0x400` unchanged (unconditional, slabinfo-observed on EZIF:
  `mm_struct 1024 objs, 32 objperslab, 8 pagesperslab` → 32768 = ORDER3 exact;
  set in `2d124f6`, untouched here; raw slabinfo capture path to be archived).

Verification (no `probe_mm.sh` exists in this repo — equivalent checks):

- `grep -rn TODO_offsets_ src/targets/e1q-S9210ZHU6EZIF/` → zero
  hits (both poison macros gone; only historical `TODO(offsets)`
  prose remains in comments/docs).
- `make TARGET=e1q-S9210ZHU6EZIF
  ANDROID_NDK_HOME=/home/samson1357924/Android/Sdk/ndk/29.0.14206865
  release` → exit 0 (full output: single clang link line, no
  warnings/errors beyond flags).
- Artifact `build/e1q-S9210ZHU6EZIF/cve-2026-43499-app.release.so`:
  **104128 bytes** (Makefile fixed-size padding satisfied, no
  over-limit error), SHA-256
  `9c6cf160b7b24eaa021d163c514c342ca4a4f850faa32ca30a61fb5a33593a51`
  (HISTORICAL §8.6 build — RETIRED by §9.15 `74496f5b…` (review-fix; predecessor `7b68f38d…`);
  `artifacts/` now holds HEAD `efc8b49c…` (commit `a687ea9`, retry disabled by default — see §9.17)),
  `ELF 64-bit LSB shared object, ARM aarch64, for Android 35, NDK
  r29, stripped`.

Remaining gates (unchanged): tracefs `id`-file read vs offline 106,
per-boot caller alignment + P0-range checks, `P0_KERNEL_PHYS_LOAD`
linear-map self-consistency, full hardware chain + KSU validation
(§8.4/§9.5). At §8.6 time nothing was committed (working tree only);
candidate artifacts were published later in `58a6772`.

## 9. S5 static dual-build record (2026-11-02, no device; KSU-only)

Scope: build + statically audit the KernelSU LKM + ksud pair for EZIF
TWICE — v3.3.1 (primary) and v3.3.0 (fallback) — with everything else held
constant (same DDK, same Kconfig, same target vermagic; only the KSU
base differs). No feed touched. At §9 time no repo binaries were added
(workdir only); candidate artifacts were published later in `58a6772`
(see §9.4/§9.15). Workdir:
`/mnt/240G_SSD/opencode_tmp/EZIF_ksu/`.

### 9.1 Build matrix

| Axis | v3.3.1 (primary) | v3.3.0 (fallback) |
| --- | --- | --- |
| Upstream commit | `0c0fdb960178fa12d80d6cbcfdcb6ad8be6a865d` (tag `v3.3.1`, 2026-10-12) | `932014ab5b2c9b74a3d11e2ec4d17dd10fc944e2e` (tag `v3.3.0`, 2026-08-28) |
| `rev-list --count` / KSU version | 2680 / **32680** | 2601 / **32601** |
| Samsung patch | `KernelSU-v3.3.1-samsung-kdp-rkp-defex.patch` (rebased, §9.2; 1260 lines) | `kernelsu/patches/KernelSU-v3.3.0-samsung-kdp-rkp-defex.patch` (in-repo, applied strictly clean) |
| DDK | `ghcr.io/ylarod/ddk-min:android14-6.1-20260313` (`sha256:1dd6ac…3d5d3`) | identical |
| Release override (`utsrelease.h` + `kernel.release`) | `6.1.162-android14-11-34343818-abS9210ZHU6EZIF` | identical |
| Kconfig | `CONFIG_KSU=m` + `KDP=y` + `RKP=y` + `DEFEX=y` + `NO_PATCH_TEXT=y`, `CC=clang` | identical |
| `modinfo` vermagic | `6.1.162-android14-11-34343818-abS9210ZHU6EZIF SMP preempt mod_unload modversions aarch64` — exact target match | identical string |
| Baked `KSU_VERSION` (disasm immediate) | `mov w11, #0x7fa8 // =32680` (supercall dispatch) | `mov x9, #0x7f59 // =32601` (supercall dispatch) |

In-container `git` is unavailable, so both builds took the patch's
`KSU_VERSION ?=` fallback (observed in build logs: `fallback version:
32680` / `32601`) — consistent with the `rev-list` counts above.
`compat/samsung_kdp.o` + `compat/samsung_defex.o` compiled in both
logs; each build's own `check_symbol` vs the DDK vmlinux ran (exit 0
via `set -e`). `make clean` needed `touch check_symbol` first (the
`clean` target's bare `rm check_symbol` fails on a fresh tree) —
logged in `build-330.log` / `build-331.log`.

### 9.2 Samsung patch rebase v3.3.0 → v3.3.1 (no silent skips)

`git apply --check` of the v3.3.0 patch on pristine v3.3.1 failed on 4
files (`Kbuild`, `core/init.c`, `syscall_hook_manager.c`,
`late_load.rs`); the rest applied. A fuzz pass (`patch --fuzz=3`)
landed 2 hunks in SEMANTICALLY WRONG positions — both caught on
review and repaired by hand (no KDP/RKP/DEFEX/NO_PATCH_TEXT semantic
dropped):

- `core/init.c`: fuzz put the patch's `int ret;` (meant for
  `kernelsu_init()`) at file scope inside `#ifdef MODULE`. Moved to
  the function body; KDP/DEFEX init + exit order kept identical to
  v3.3.0 relative to shared anchors (`prepare_creds`,
  `ksu_syscall_hook_init`, `put_cred` → `ksu_put_cred` + exits).
- `syscall_hook_manager.c`: fuzz placed the `#include
  "policy/allowlist.h"` + `syscall_hook_manager_initialized` + the
  whole RKP/kretprobe/sucompat-kprobe block INSIDE the pre-existing
  `#if defined(__riscv)` guard (would compile out on arm64 — a
  silent RKP skip). Moved to after the riscv `#endif`; the
  dispatcher-unavailable → Samsung-kprobe-fallback + early-return
  logic is preserved against v3.3.1's restructured init/exit
  (v3.3.1 removed the old `ksu_dispatcher_nr < 0` early return; the
  samsung hunk re-adds it with the RKP fallback inside).
- `Kbuild`: fallback `KSU_VERSION ?= 32601` → `32680`; samsung obj
  lines re-anchored after `core/init.o`; ccflags inside the
  `KBUILD_EXTMOD` guard (external-module build sets it, so flags are
  active — same as v3.3.0).
- `userspace/ksud/src/late_load.rs`: all 4 hunks rejected (file
  restructured upstream: `ScriptWait`, `BOOT_STAGE_TIMEOUT`,
  `init_forced_features`). Reconciled by hand, all 5 semantics kept:
  drop `process::Command` import, `_package_name`, REMOVE the
  `utils::daemonize(false)?;` first line (as the v3.3.0 patch does —
  the staged binary runs in the right context already),
  `stage_daemon_from("/data/local/tmp/.ksud-stage")` after the start
  dump, `finish_install` instead of `install`, delete the `am
  force-stop/start` Manager-restart tail.
- New files (`compat/samsung_kdp.c`, `compat/samsung_defex.c/.h`,
  `include/ksu_samsung_kdp.h`) carried over byte-identical;
  `void→int ksu_syscall_table_hook` + call-site `-1` handling,
  `NO_PATCH_TEXT` stub (`-EOPNOTSUPP`, zero `stop_machine` imports),
  `put_cred` → `ksu_put_cred`, `commit_creds` → KDP commit +
  `defex_sync`, sucompat `__exit` drop all applied to v3.3.1 cleanly.

Verification: the generated v3.3.1 patch passes strict `git apply
--check` (no fuzz) on a pristine v3.3.1 worktree.

### 9.3 Static audit (both versions; unstripped AND post-strip)

Target ELF: `/mnt/240G_SSD/opencode_tmp/EZIF_work/vmlinux.elf`;
symvers `Module.symvers.ezif` (8346 entries, regenerated from the
EZIF ELF). `check_symbol` built from each own tree (host `gcc -O2`).

| Check | v3.3.1 | v3.3.0 |
| --- | --- | --- |
| `check_symbol <ko> vmlinux.elf` | exit 0 (pre- and post-strip) | exit 0 (pre- and post-strip) |
| `audit_module_against_target.py --manual-relocation` | 221 undefined / 0 version entries / **0 missing / 81 kallsyms / 0 CRC mismatches** | 202 undefined / 0 version entries / **0 missing / 70 kallsyms / 0 CRC mismatches** (identical fingerprint to the DZG1 v3.2.5/v3.3.0 reference 202/0/70) |
| `UND stop_machine` imports | 0 | 0 |
| `__versions` section size | 0 | 0 |
| `.symtab`/`.strtab` retained post-strip | yes (`llvm-strip -d`, NDK r29) | yes |

Audit-shape delta (221/81 vs 202/70) is expected: v3.3.1 adds
`module_blacklist`, `shell_su_adb_only`, riscv paths etc. The
gates — 0 missing, 0 CRC — hold on both. No Kconfig downgrade was
used to force a pass.

### 9.4 Artifacts (sizes + SHA-256; published in `58a6772` — filenames below are the repo paths)

Stripped with NDK r29 `llvm-strip -d`; ksud via
`cargo build --locked --release --target aarch64-linux-android -p
ksud` (NDK r29, `aarch64-linux-android35-clang`,
`CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER` + `LIBCLANG_PATH=…/lib`;
a bare host-`cc` link fails on `-llog/-lunwind`, so the linker env
is load-bearing). Both ksuds: aarch64 PIE, `linker64`, `for Android
35, built by NDK r29`.

| File (repo path) | Bytes | SHA-256 |
| --- | --- | --- |
| `kernelsu/android14-6.1_kernelsu-e1q-S9210ZHU6EZIF-kdp.ko` (v3.3.1 primary, stripped) | 432656 | `af640cdae6a9414dfe7b2eebe60e0d3e428b8f26862c14c7348f88e7a3863e4a` |
| `kernelsu/android14-6.1_kernelsu-e1q-S9210ZHU6EZIF-v3.3.0-kdp.ko` (v3.3.0 fallback, stripped) | 406160 | `3f3e558ba808eb67566fd97fa5a70aaed50f4739fc5c75d124d5447b011872bc` |
| `e1q-v3.3.1-unstripped.ko` (workdir only, BTF/debug retained) | 6210312 | `9fe7a72faf06e33d288259898f8f6d23d7a2d5c93a049f03def201e785f7d551` |
| `e1q-v3.3.0-unstripped.ko` (workdir only, BTF/debug retained) | 5851848 | `829ee8bef7ed39e3af0ad54f8e3dc59433c4a7743f6dc2fdfad9713f5c823110` |
| `kernelsu/ksud-e1q-S9210ZHU6EZIF-kdp` (v3.3.1 primary) | 5065680 | `fde99b5a129e5714fe6f598cf8276c76d2cbaf1a7f4e6ce9ae69d5ebca0abe61` |
| `kernelsu/ksud-e1q-S9210ZHU6EZIF-v3.3.0-kdp` (v3.3.0 fallback) | 4993656 | `bc7399a38f4e78471f32f7bded3c9788f26132b22768051c5a783ef7501903e8` |

(Primary pair carries no `-v3.3.1` suffix by repo naming convention — version is tracked in §9.1/§9.2 + `kernelsu/REBUILD-e1q-v3.3.0.md`.
Full hashes: `SHA256SUMS.txt` in the workdir. Naming rule for S6 feed: `url` MUST use the exact repo paths above.)

Asset-pipeline proof (v3.3.0 tree): swapping the embedded
`android14-6.1_kernelsu.ko` asset to the v3.3.1 module and
rebuilding changes ksud 4993656 → 5003896 B; restoring the asset and
rebuilding returns to 4993656 B with only 2 bytes differing inside
the compressed-asset region (multithreaded-compression
nondeterminism, same input). rust-embed uses compression, so module
bytes are not greppable — the size response is the proof, same
method as the DZG1 record. Ground truth remains hardware late-load.

### 9.5 Pending on-device validation (all BLOCKING for any S6/publish)

- Manager pairing: v3.3.1 ksud ↔ Manager reporting **32680**, v3.3.0
  ksud ↔ **32601**; capture `Working <LKM>` UI state with NO
  version-mismatch banner for the chosen pair.
- Full hardware chain on SM-S9210 EZIF (tracefs slide → fops → cfi →
  phys → root umh → pipe → KernelSU late-load → granted `su`) for
  the chosen pair; the other pair stays a cold spare.
- resetprop regression (`set/get/delete/wait`, `ro.*` ≥93B long
  values, `-f load_props`, `-c/--force rebuild`, magica adb_root
  toggle, `sys.boot_completed` wait, `su`), repeatability +
  reboot-persistence matrix (same gates as DZG1 §PhaseD).
- S3 interlocks (§8.4) still block the `.so` release path — the KSU
  pair above is validated statically only and MUST NOT be published
  to `kernelsu/` or the feed until hardware proof exists.
- Reproducibility gap (inherited from DZG1): `ksu_props` is pinned
  (`KernelSU2/ksu_props@ddb6ee7` for v3.3.0; v3.3.1's lockfile
  already points at KernelSU2 sources) and this machine's
  `~/.cargo/git` cache covered the remaining git crates — a clean
  machine still needs the same treatment. DDK-side (`make clean`
  quirk, fallback-version path) is fully logged and replayable.

  Update 2026-11-03 (App route, boot `de00aae0` — see §9.16): of the
  §9.7 verification items, (a) `su -c id`, (c) post-root SELinux, and
  (d) live-driver version are now CLOSED (device-measured, with a
  shell-side Enforcing control, `ksud 3.3.1 (uapi: 5)`); (b) Manager pairing is PARTIALLY
  closed (package `me.weishu.kernelsu` v3.3.1/32680 proven via
  dumpsys, `Working <LKM>` UI still needs a user screenshot).
  Still TODO after this update: resetprop regression matrix,
  repeatability/reboot matrix, Manager UI screenshot, and any repo
  release/feed publish (the App run used the App's built-in assets —
  it changes nothing about the repo `.so`/KSU release gating).

### 9.6 Full-chain hardware record (2026-11-02, boot `8ae3860a`)

Single-round `LD_PRELOAD` run of the §8.6 release `.so`
(`9c6cf160…`, 104128 B) + `cve-2026-43499-root` (27264 B, NDK r29
rebuild `22:47`), staged as `/data/local/tmp/ezif_app.release.so` /
`/data/local/tmp/ezif_root` (both `7f 45 4c 46`, sizes match).
Invocation mirrors the DZG1 manual route (no `SLIDE_ONLY`):

`EXPLOIT_ATTEMPTS=24 EXPLOIT_ATTEMPT_TIMEOUT_SEC=300
P0_ATTEMPT_TIMEOUT_SEC=180 LD_PRELOAD=…ezif_app.release.so
/system/bin/id`

Run 1 (same boot, attempt **1/24** — attempt index within this single round, NOT a success rate — full chain, transcript
`run1_ezif_clean.log` retained in workdir scratch):

```text
[+] slide-kaslr-ok source=tracefs pid=26261 base=ffffffc008090000 slide=0000000000090000 data_mode=canonical
[*] p0 physical write status=0 ok=1
[*] cfi write ret=35 errno=0 / cfi read ret=35 errno=0 (misc_fops target=ffffffc00a46c200)
[*] phys step probed read done ok=1 / write done ok=1 / read64 done ok=1 value=306365737562656e
[*] root umh result wake=1 complete=1 retval=0 socket=1
[+] pipe physrw pid=26261 done=1 root=1 kaslr=1 read_ok=1 write_ok=1 rw64=1/1 uid=2000->0
[+] exploit completed attempt=1/24
```

- Tracefs quorum unanimous (`best=00090000 hits=6 second=0`), caller
  `ffffffc00816b39c` dominant; per-boot slide agreement holds.
- Temp root verified via helper:
  `uid=0(root) gid=0(root) context=u:r:kernel:s0`, `Permissive`.
- KSU **v3.3.1** late-load (`ezif_ksud-331`, 5065680 B, SHA-256
  `fde99b5a…`, staged to hardcoded `KSU_LOADER_PATH`
  `/data/local/tmp/ksud-s25u-kdp`, SHA re-verified on device):
  `--ephemeral` rejected as usage error (v3.3.1 `late-load --help`
  has no such flag — same fallback DZG1 saw on v3.2.5, wrapper
  retried plain `late-load` as designed). v3.3.1
  `stage_daemon_from("/data/local/tmp/.ksud-stage")` renames a
  caller-provided stage file (source-confirmed in
  `userspace/ksud/src/late_load.rs:44` + `utils.rs:259`) — nothing
  creates it, so the first plain attempt failed with
  `Failed to rename /data/local/tmp/.ksud-stage to /data/adb/ksud`.
  Fix: `cp ezif_ksud-331 /data/local/tmp/.ksud-stage` (shell-writable)
  before invoking `--late-load`; the rename then consumed it and the
  module load proceeded. (Side note: `/data/adb` pre-existed from
  October with a prior KSU setup — `ksud` 4892712 B, `ksu/`,
  `modules/`, `lspd/`, `zygisksu/` — so the `ensure_dir_exists`
  branch was a no-op; our run replaced `/data/adb/ksud` with v3.3.1.)
- Result: `kernelsu ... Live` in `/proc/modules`, SELinux back to
  `Enforcing`. **Module load proven on EZIF hardware for v3.3.1.**
- BLOCKER found at late-load: the temp-root client channel died —
  `/data/local/tmp/temp_su.sock` became un-statable as shell
  (`s?????????`, `connect daemon: Permission denied`) although the
  root daemon stayed alive; DAC would have allowed it, so this is a
  post-`Enforcing`-restore MAC denial on the bootstrap socket.
  Consequence: `ksud debug` / control-channel check (`KernelSU
  control verified`), `su` grant, and Manager install/UI were **NOT
  verified** — `/data/adb` is `drwx------ root` (shell cannot reach
  `ksud`), and no other root channel exists post-late-load. Manager
  apk install was skipped per protocol (needs user interaction).

Run 2 (same boot, KSU live, re-invoke for a fresh root window):
**kernel panic → reboot**. Do not re-run on a KSU-live boot.

- Panic signature (`dumpstate_lastkmsg_130_…_225441_KP`, KTIME
  1665.76, retained in workdir scratch):
  `Internal error: Oops: 96000004`, DABT current EL, level-0
  translation fault on garbage VA `000c631330080006`
  (`[000c631330080006] address between user and kernel address
  ranges`), task `id:27079` (run-2 supervisor host),
  `pc: try_module_get+0x2c` ← `misc_open+0x6c` ← `chrdev_open` ←
  `do_dentry_open` ← `__arm64_sys_openat`. `x19=x0` = garbage
  `struct module *`; `x24=ffffffc00a46c208` sits +8 of the known CFI
  `misc_fops` target `ffffffc00a46c200`. `Modules linked in:
  kernelsu(O)` first.
- Run-2 log reached `fops-page-held` (slide re-agreed `0x90000`)
  before the crash: re-running the CFI/fops stage with the KSU
  module live corrupted (or raced) the misc registration; the next
  misc open dereferenced the garbage owner pointer.
- Device rebooted on its own; new boot `92b4814c`
  (`ro.boot.bootreason=reboot`), no `kernelsu` in `/proc/modules`
  (volatile, as expected). Per panic protocol: stopped, pulled
  lastkmsg, no rapid re-fire.

Boot comparison:

| Field | Before (exploit boot) | After |
| --- | --- | --- |
| boot_id | `8ae3860a` | `92b4814c` |
| uptime at session | ~20 min, load ~2.2, free ~160 MB, `boot_completed=1` | ~2 min, load 7.76 (settling), `boot_completed=1` |
| kernelsu module | absent → **Live** (run 1) | absent (volatile) |
| SELinux | Enforcing → Permissive (root) → Enforcing (KSU) | Enforcing |

Status vs §9.5: chain root=1 proven (fresh-boot single shot);
v3.3.1 module load proven; control-channel/`su`/Manager/resetprop/
repeatability matrix **still TODO**. New rule for EZIF: **one full
trigger per boot once KSU is late-loaded — same-boot re-invoke
panics**; post-late-load verification needs a root channel that
survives the Enforcing restore (temp-root socket currently does
not), otherwise verify via reboot + fresh run ordering.

Update 2026-11-03 (App route, boot `de00aae0` — see §9.16):
`su` + driver-version + SELinux items are now CLOSED by an
independent second root (S24 App 0.3.4-s24.1 built-in assets, not a
repo `.so` re-run). Manager pairing stays PARTIAL (package version
proven, `Working <LKM>` UI still needs a user screenshot).
Control-channel `ksud debug`, resetprop matrix, and
repeatability/reboot matrix remain TODO.

### 9.7 Single-round re-run on boot `92b4814c` (2026-11-02) — PANIC pre-root, NO ROOT

Single boot, single round, no second exploit (per protocol). Previous
boot `92b4814c` (post-run2 clean reboot) was settled first, then one
full chain was fired once. It panicked during fops — no root, no
late-load, so verification items (a)–(d) could not run.

- Idle gate (same boot, before push): `boot_id 92b4814c-…`,
  `uptime 882s` (>600 ✓), `load 2.12` (<3 ✓), `boot_completed=1`,
  `getenforce Enforcing`, no `kernelsu` in `/proc/modules`.
- Push + preset (SHA-256 re-verified on device): `ezif_app.release.so`
  `9c6cf160b7b24eaa…` (104128 B), `ezif_root` `c49a655708be…`
  (27264 B), `ezif_ksud-331` + `ksud-s25u-kdp` both
  `fde99b5a129e5714…` (5065680 B); `.ksud-stage` preset via `cp`
  (5065680 B, same hash). Stale `temp_su.sock` from the prior boot
  could not be removed as shell (`Permission denied`, MAC —
  consistent with the §9.6 blocker); the fresh daemon was left to
  `unlink` it as root.
- Run (ONE invocation, `ATTEMPTS=24`, `EXPLOIT_ATTEMPT_TIMEOUT_SEC=300`,
  `P0_ATTEMPT_TIMEOUT_SEC=180` via `--run-payload` →
  `/data/local/tmp/ezif_s3verify.log`): attempt **1/24**,
  `slide-kaslr-ok source=tracefs base=ffffffc008140000
  slide=0x140000` (quorum `best=00140000 hits=14 second=0`, unanimous;
  per-boot slide differs from run 1's `0x90000` as expected),
  `fops-page-held` checkpoint, then the device rebooted mid-fops
  (live transport reached `writer-enter`; the file ends at
  `fops-page-held` — post-checkpoint lines were lost with the crash).
  No `exploit completed`, no pipe physrw, no root umh, no late-load.
- Result: **NO ROOT**. Items (a) `su -c id`, (b) Manager
  `Working<LKM>/32680`, (c) post-root SELinux, (d) live-driver
  version could NOT run — there was no root session. Shell-side facts
  only: pre-run `Enforcing`, post-reboot `Enforcing`, no `kernelsu`
  module; `ezif_ksud-331 --version` as shell = `ksud 3.3.1 (uapi: 5)`,
  `debug info` as shell = `version: 0` (driver not live, as expected
  with no load). Manager: only `manager-base.apk` v3.3.0 (32601) is
  on hand (`/mnt/240G_SSD/opencode_tmp/s24-logs/`); it version-mismatches
  the v3.3.1 ksud and needs UI grant steps, so install/UI was skipped
  per protocol (v3.3.1 apk not fetched — no second round to use it).
- Panic handling (per protocol: stop, pull, no re-fire): device left
  `adb` briefly, then returned on new boot `294e33d3`
  (`ro.boot.bootreason=reboot`, `boot_completed=1`, no `kernelsu`,
  `Enforcing`). Pulled `/data/local/tmp/ezif_s3verify.log` (4251 B)
  + on-device `dumpstate_lastkmsg_131_20261102_231004_KP.log.gz`
  (#131, 625428 B). Signature differs from run 2: `CPU: 1 PID: 26141
  Comm: cve43499-run`, `refcount_warn_saturate` ←
  `rt_mutex_adjust_prio_chain` ← `rt_mutex_adjust_pi` ←
  `__sched_setscheduler` ← `__arm64_sys_sched_setattr`, then `Oops:
  96000005` NULL deref at `0x18` (KTIME 818.59, `Modules linked in:`
  with NO `kernelsu` — panic pre-load, unlike run 2's
  `try_module_get/misc_open` post-load panic). Retained under
  `/mnt/240G_SSD/opencode_tmp/EZIF_panic/` (`ezif_s3verify_boot92b4814c.log`
  + `#131` zip + `dumpstate_latest_after_s3verify.log.gz`).

Boot comparison (this round):

| Field | Before (exploit boot) | After |
| --- | --- | --- |
| boot_id | `92b4814c` | `294e33d3` |
| uptime/load at session | 882 s, load 2.12, `boot_completed=1` | ~212–324 s, load 4–13 (settling), `boot_completed=1` |
| kernelsu module | absent (never loaded this boot) | absent (volatile) |
| SELinux | Enforcing (never left Enforcing — no root) | Enforcing |
| `.ksud-stage` | preset, unconsumed (no late-load) | still present (no load consumed it) |

Status vs §9.5/§9.6: chain root NOT reproduced this boot; v3.3.1
module-live stays proven ONLY from boot `8ae3860a` run 1;
control-channel/`su`/Manager/resetprop/repeatability still TODO.
New observation: fops-stage panic can strike a fresh boot pre-root
(this boot, slide `0x140000`), not only same-boot re-invoke post-load
(run 2, slide `0x90000`) — volatility note for the repeatability matrix.

### 9.8 Single-round retry on boot `294e33d3` (2026-11-02) — PANIC pre-root, NO ROOT

Single boot, single round, no second exploit (per protocol). Previous boot
(`294e33d3`, post-#131 clean reboot) was settled first (uptime 852→879→1192 s,
load1 2.34→2.27→1.55, `boot_completed=1`, no `kernelsu`, `Enforcing`), then one
full chain was fired once. It panicked in the fops/PI stage — no root, no
late-load, so verification items (a)–(e) could not run. Full record:
`/mnt/240G_SSD/opencode_tmp/s3_retry_verify2/verdict.md`.

- Push + preset (SHA-256 re-verified on device pre-fire): `ezif_retry2_app.release.so`
  `9c6cf160b7b24eaa…` (104128 B, `7f 45 4c 46`), `ezif_retry2_root`
  `c49a655708bed646…` (27264 B), `ezif_retry2_ksud-331` `fde99b5a129e5714…`
  (5065680 B); `.ksud-stage` + `ksud-s25u-kdp` preset, same hash. Local `build/`
  re-hashed identical — no rebuild, `target.h`/offsets untouched.
- Run (ONE invocation, `ATTEMPTS=24`, `EXPLOIT_ATTEMPT_TIMEOUT_SEC=300`,
  `P0_ATTEMPT_TIMEOUT_SEC=180` via `--run-payload` → `ezif_retry2.log`, 4626 B):
  attempt **1/24**, `slide-kaslr-ok source=tracefs base=ffffffc008050000
  slide=0x50000` (quorum `best=00050000 hits=16 second=0`, unanimous; third
  distinct per-boot slide after `0x90000`/`0x140000`), `fops-page-held` →
  pi stages → live transport reached `writer-enter`, then transport died
  (durable log ends at `fops-page-held` — post-checkpoint lines lost, same as §9.7).
  No `exploit completed`, no root umh, no late-load.
- Panic handling (per protocol: stop, pull, no re-fire): device left `adb`
  immediately, back after ~9 min on new boot `0aec734f`
  (`ro.boot.bootreason=reboot`, `boot_completed=1`, no `kernelsu`, `Enforcing`).
  Pulled `ezif_retry2.log` + on-device
  `dumpstate_lastkmsg_132_20261102_233032_KP.log.gz` (#132, 608160 B).
  Signature = same family as #131: `refcount_warn_saturate` ←
  `rt_mutex_adjust_prio_chain+0x5a0` ← `rt_mutex_adjust_pi` ←
  `__sched_setscheduler`, then `Oops: 96000005` NULL deref at `0x18`
  (KTIME 1206.23, ~14 s into run, task `cve43499-run:28487`, CPU 1,
  `Modules linked in:` with NO `kernelsu` → pre-load fops/PI panic).
- Verification: (a) `su -c id`, (b) post-root SELinux, (c) driver-live `debug`,
  (d) late-load — all unrunnable without a root session (re-running exploit for
  a shell forbidden this round). Shell-side only: `Enforcing` throughout,
  `ezif_ksud-331 --version` = `ksud 3.3.1 (uapi: 5)`, driver absent.
  (e) Manager skipped per protocol (only v3.3.0 `manager-base.apk` on hand,
  version-mismatch + UI steps; v3.3.1 apk not fetched).
- Storage finding (new rule): the three files pushed this round (~1–2 min before
  the panic) now read back **fully zero-filled** on storage (sizes intact, new
  hashes `.so`→`e577d377…` etc.); previous-round files still hash correctly.
  Pre-fire sha256 + correct in-memory execution (slide quorum, fops route)
  prove the run used good bytes from page cache — the panic hit before f2fs
  writeback. Rule: **after ANY panic-reboot, re-push + re-verify before the next
  round**; retry2 on-device copies are garbage and must not be reused unpushed.

Boot comparison (this round):

| Field | Before (exploit boot) | After |
| --- | --- | --- |
| boot_id | `294e33d3` | `0aec734f` |
| uptime/load at session | 852–1192 s, load 2.34→1.55, `boot_completed=1` | 538–581 s, load 28.96→19.24 settling, `boot_completed=1` |
| kernelsu module | absent (never loaded this boot) | absent (volatile) |
| SELinux | Enforcing (never left Enforcing — no root) | Enforcing |
| `.ksud-stage` | preset, unconsumed, hash-ok (old file survived) | still present, hash-ok |

Status vs §9.5/§9.6: chain root still proven ONLY from boot `8ae3860a` run 1;
now THREE fops-stage panics vs one root (run 2 post-load re-invoke, s3verify +
retry2 fresh-boot pre-root) — fops/PI window is the hot spot, probabilistic
exploit confirmed. Control-channel/`su`/Manager/resetprop/repeatability still TODO.

### 9.9 NanoTurtle-v3.5.4-tuned single round on boot `0aec734f` (2026-11-03) — PANIC pre-root, NEW CFI signature

Timing-only `target.h` retune (geometry/offsets/SHIFT/DELTA/MM untouched),
single round, no second exploit. Full record:
`/mnt/240G_SSD/opencode_tmp/s3_tuned125x5/verdict.md`.

- Knobs: `+ #define APP_FOPS_FRESH_PAGE_ATTEMPTS 5` (`main.c:599` hook);
  `SLIDE_PSELECT_TIMEOUT_NSEC` 100000000L → 500000000L (125ms writer delay
  needs timeout >100ms; coupled warning in comments).
- NDK r29 `release` → exit 0; `.so` still **104128 B**, new SHA-256
  `efc8b49caa9129539645689479eaa55b7aa0059e621997beee375a8a1a86a538`
  (old `9c6cf160…` retired). Root runner unchanged (27264 B, `c49a6557…`).
- Idle gate on unchanged boot `0aec734f`: up 30–32 min, load 3.34→1.71,
  `boot_completed=1`, no `kernelsu`, `Enforcing`.
- Push + preset verified on device pre-fire (size/ELF/SHA-256/md5 all match);
  `.ksud-stage` + `ksud-s25u-kdp` preset, stale `temp_su.sock` still MAC-denied.
- Run (ONE invocation, `ATTEMPTS=24`, `EXPLOIT_ATTEMPT_TIMEOUT_SEC=300`,
  `P0_ATTEMPT_TIMEOUT_SEC=180`, `STACK_WRITER_DELAY_USEC=125000`): attempt
  **1/24**, slide `0x180000` (quorum `best=00180000 hits=13`, unanimous; 4th
  distinct per-boot slide), `configured_delay=125000 consume_delay=125000`
  confirmed, `fops-page-held` → pi stages → `writer-enter` → transport died.
  No root, no late-load.
- Panic `#133` (`dumpstate_lastkmsg_133_20261103_000337_KP.log.gz`, 652059 B):
  **NEW signature** — `CFI failure at __arm64_sys_ioctl+0xa0/0xe4 (target:
  0xfffffffe239bdd40; expected type: 0xe01408cd)` → `Oops - CFI` → panic,
  KTIME 1679.98, no `kernelsu` (pre-load, pre-root). First three panics were
  PI/futex-path (`refcount_warn_saturate ← rt_mutex_adjust_prio_chain`) or
  post-load misc; tuned125 got PAST the PI window and died one stage later at
  the ioctl call through the overwritten fops — but still no root.
- Verification (a)–(e) unrunnable without a root session; no second round.
  Shell-side only: `Enforcing` throughout, driver absent.
- Storage rule hardened: the five files pushed 1–3 min pre-panic are now
  ENTIRELY ABSENT (retry2's were zero-filled) — panic before f2fs writeback
  has two faces. **After ANY panic-reboot, re-push + re-verify.**

Boot comparison:

| Field | Before (exploit boot) | After |
| --- | --- | --- |
| boot_id | `0aec734f` | `55936f1a` |
| uptime/load at session | 30–32 min, load 3.34→1.71, `boot_completed=1` | ~14 min, load 9.58 settling, `boot_completed=1` |
| kernelsu module | absent (never loaded this boot) | absent (volatile) |
| SELinux | Enforcing (never left Enforcing — no root) | Enforcing |

Status vs §9.5/§9.6: chain root proven ONLY from boot `8ae3860a` run 1; now
FOUR fops-stage panics vs one root. Control-channel/`su`/Manager/resetprop/
repeatability still TODO.

### 9.10 Pre-flip gate (S6 forensic fix; static only, no device run)

Forensic verdict (§2, parent session): flip aiming is correct, source page is
wrong — blind spray with zero readback; `×5` (`APP_FOPS_FRESH_PAGE_ATTEMPTS`,
`main.c:599` hook) is dead code in this build because e1q does NOT define
`APP_REQUIRE_FRESH_P0_SESSION`, so the fresh retry loop (`main.c:594-683`)
is compiled out and production walks the `#else` single-shot path
(`main.c:684-700`). Fix: verify the planted table is resident BEFORE the
flip; enter `slide_trigger_physical_state` only on a hit, else release +
fresh prepare (max 5); 5 misses -> clean `return 1` (never flips a blind
table, never enters the writer).

- Gate read: `configfs_read_once(fake_fops + FOPS_IOCTL_OFF, ...)` through a
  freshly opened pre-flip ashmem fd (genuine `f_op`, name-blob path safe),
  require `== text_addr(ASHMEM_IOCTL)`.
- Expectation provenance (read, not guessed): spray plants
  `FOPS_IOCTL_OFF = text_addr(ASHMEM_IOCTL)` (`put_fake_fops_table`,
  `src/util.c:936`); `FOPS_LLSEEK_OFF` is planted as `fake_w0+0x18`
  (`src/util.c:930-931`) and deliberately NOT gated, because
  `repair_fake_fops_llseek` (`src/fops.c:269`, post-flip inside
  `try_cfi_stage`) rewrites that slot to `NOOP_LLSEEK` — only the ioctl
  slot is stable across re-prepares.
- Retry mirrors the fresh-session loop: miss -> `prepare_good_kernel_page`
  (`PAGE_PAYLOAD_FOPS`) again, no `reset_pipe_attempt` (that helper zeroes
  `pipebuf_page_base` without rebuilding it, which would poison the bank
  entries planted from `pipebuf_page_base` and the later pipe physrw).
- `pr_warning` (not `pr_error`) on the 5-miss path: `pr_error` calls
  `exit(-1)` (`src/kernelsnitch/utils.h`), which would skip the
  `pipe_prepare_child` cleanup and violate the `return 1` contract.
- Scope (historical §9.10 design; gate has since been REVERTED in `19418fc` — see §9.12-§9.13):
  `src/main.c` `#else` single-shot region only +
  one macro `#define APP_FOPS_PREFLIP_GATE 1` in
  `src/targets/e1q-S9210ZHU6EZIF/target.h` (macro REMOVED from `target.h` in the
  retry-lottery fix; no consumer remains). No offsets/SHIFT/DELTA/MM/
  PHYS_LOAD change; `src/fops.c` production logic untouched (repair order
  verified by source reading — no adjustment needed).

Isolation proof (other 29 targets byte-identical behavior):

- Gate code was wrapped in `#if defined(APP_FOPS_PREFLIP_GATE) &&
  APP_FOPS_PREFLIP_GATE`; only e1q defined it (HISTORICAL — gate reverted in
  `19418fc`, macro removed). The `#else` leg is the
  original single-shot loop verbatim.
- `make TARGET=e1q-S9210ZHU6EZIF release` → exit 0, 104128 B; gate strings
  present in the `.so` (`pre-flip gate` ×5).
- `make TARGET=e3q-S9280ZCS6DZF2 release` (unmodified macro) → exit 0,
  104128 B; `pre-flip gate` strings absent (0); preprocessed
  (`-DAPP_PAYLOAD=1 -E`) `run_exploit` tail still expands to
  `start_p0_ref_keeper(); for (int attempt = 1; attempt <= 1; ...)`,
  zero `gate_attempt` references. `-Wall -Wextra` clean on both.
- No exploit run, no feed/KSU touched at §9.10 time (working tree only;
  retry-lottery §9.15 + candidate artifacts `58a6772` came later).

### 9.11 Pre-flip gate build — first hardware run on boot `55936f1a` (2026-11-03): 0 HIT, 24/24 clean exit, NO panic

Single boot, single full-chain invocation, no second exploit. Gate build
(`071425fa…`, 104128 B) fired once (`ATTEMPTS=24`, TIMEOUT 300/180,
`STACK_WRITER_DELAY_USEC=125000`). Full record:
`/mnt/240G_SSD/opencode_tmp/s3_gatebuild/verdict.md` + durable
`ezif_gate_boot55936f1a.log` (181103 B, SHA-256 `e2fd3c61…`).

- Push + preset verified pre-fire (size/ELF/md5 all match local):
  `/data/local/tmp/ezif_gate.so` `c12acc3d…`, `ezif_gate_root`
  `bed76c86…`, `ezif_gate_ksud-331` `5a01d50e…` (5065680 B, v3.3.1
  `fde99b5a…`); `.ksud-stage` + `ksud-s25u-kdp` preset, same hash.
- Idle gate: boot `55936f1a`, up ~97 min, load ~2.2, `boot_completed=1`,
  no `kernelsu`, `Enforcing`.
- Run: all 24 attempts `slide-kaslr-ok` unanimous `slide=0x170000`
  (5th distinct per-boot slide, stable within boot) → `fops-page-held` →
  gate 5/5 MISS every attempt (120 misses, read always `0x0` vs want
  `ffffffc008eb4e8c`) → `production skipped, no flip performed` →
  `failed status=1`; final `exploit failed after 24 independent attempts`.
  **0 HIT, 0 `writer-enter`, 0 flips.**
- Post-run: SAME boot `55936f1a` (no reboot, no panic), load ~1.9,
  `Enforcing`, driver absent, all pushed hashes identical,
  `.ksud-stage` unconsumed. Leftover nanosleep orphans killed (0 remain).
- Verification (a)–(e) unrunnable (never entered writer); Manager skipped
  per protocol (UI needed).

Status vs §9.5/§9.6: fail-closed leg hardware-proven (24/24 no-flip
survival vs four blind-flip panics on the ungated build); fail-open leg
(HIT → writer) still unobserved. Chain root still ONLY from boot
`8ae3860a` run 1. Read side deterministically zero (120/120) — gate
withheld the flip correctly, but why-zero (wrong source page vs wrong
read offset/len) is a parent-session decision.

### 9.12 Whole-table pre-flip gate (gate v2) on boot `55936f1a` (2026-11-03): 0 HIT, 120/120 zero-byte reads — pre-trigger primitive dead

Follow-up to §9.11, same boot `55936f1a` (no reboot in between), single round,
no second exploit. Mother-session hypothesis: the post-flip audit
(`fops.c:48`, full-table ~232 B read) succeeds, so a whole-table pre-trigger
read might behave differently from the 8 B single-slot read under the blob
primitive (window/pos computation). Gate v2 tests exactly that, zero risk
(still pre-trigger, still EZIF-gated). Full record:
`/mnt/240G_SSD/opencode_tmp/s3_gatev2/verdict.md` + durable
`ezif_gatev2_boot55936f1a.log` (190886 B, SHA-256 `39e1add5…`).

- Gate change (`src/main.c`, uncommitted): `configfs_read_once(fd, fake_fops,
  gate_table, 232)` where `232 = FOPS_SHOW_FDINFO_OFF (0xe0) + 8` — the exact
  span enum from the `fops.c:40` audit (29 qwords; `FOPS_IOCTL_OFF/8` = index
  10, in range; length derived from source, not guessed). In-memory compare at
  index 10 vs `text_addr(ASHMEM_IOCTL)`; 5 retries + fresh prepare + clean
  exit unchanged; miss logs now carry `ret=` byte counts.
- NDK r29 `release` → exit 0; `.so` still **104128 B**, new SHA-256
  `e25561fc85b1021bffecbe424da2168976cd8c47814fcf3867f80760ddf5d720`
  (md5 `e1ef3582…`, `pre-flip gate` strings ×5; old `071425fa…` retired).
  e3q control rebuild → exit 0, 104128 B, `pre-flip gate` strings ×0
  (isolation maintained). Root runner unchanged (27264 B, `c49a6557…`).
- Idle gate on unchanged boot: up ~8270 s, load settling 6.24→3.34→3.10,
  `boot_completed=1`, no `kernelsu`, `Enforcing`. Push verified pre-fire
  (device md5 = local, ELF magic ok).
- Run (ONE invocation, `ATTEMPTS=24`, TIMEOUT 300/180,
  `STACK_WRITER_DELAY_USEC=125000`): all 24 attempts `slide-kaslr-ok`
  unanimous `slide=0x170000` (same per-boot value as §9.11) →
  `fops-page-held` → gate 5/5 MISS every attempt → `production skipped, no
  flip performed` → `failed status=1`; final `exploit failed after 24
  independent attempts` (runner EXIT=255). **0 HIT, 0 `writer-enter`,
  0 flips.**
- Read detail (the key signal): `pre-flip gate read failed … ret=0 want=232
  errno=0` ×**118**, `ret=-1 want=232 errno=34` (ERANGE) ×**2**,
  `ret=232` ×**0**. Every miss `read=0000000000000000
  want=ffffffc008eb4e8c` (want tracks the live slide — addressing is fine).
- Post-run: SAME boot `55936f1a` (no reboot, no panic), `Enforcing`, driver
  absent, pushed hashes identical. 24 reparented nanosleep orphans killed
  (0 remain, same client-timeout phenomenon as §9.11).

Status: **whole-table reads still 0 bytes — pre-trigger primitive dead** (whole-table
pre-trigger reads EOF exactly like single-slot reads; blob window/pos is not
length-sensitive here). No further length variants per protocol. Fail-closed
leg re-proven (two consecutive gated runs, zero panics, vs four blind-flip
panics ungated); fail-open leg (HIT → writer) still unobserved. Chain root
still ONLY from boot `8ae3860a` run 1. Verification items (a)–(e) unrunnable
(never entered writer); Manager skipped per protocol.

### 9.13 Post-trigger gate relocation — BLOCKING (worker verdict, static only, no device run)

Parent task: move the gate from pre-trigger to post-trigger pre-flip —
after `app_trigger_fops_slide_route()` returns, before the misc_fops global
write (flip), with the flip write point asserted to be inside
`try_cfi_stage` (`src/fops.c`). Verdict: **the asserted flip write point
does not exist; clean insertion is structurally impossible. At §9.13 time no code was
changed (retry-lottery §9.15 came later).**

Flip-point hunt (exhaustive, `APP_PHYS_P0_ORACLE=1` build = EZIF release):

- The ONLY `fake_fops → ASHMEM_MISC_FOPS` write is performed by the kernel
  itself during the PI-requeue race INSIDE the trigger:
  `app_trigger_fops_slide_route` (`src/slide_app.c:2442`, EZIF takes the
  non-`APP_REQUIRE_FRESH_P0_SESSION` leg) → `slide_trigger_physical_state_report`
  (`src/slide_app.c:2256`, forks a child) → `slide_child_trigger_write`
  (`src/slide_app.c:2168`, waiter pselect race). Trigger returning 1 means
  the flip was already ATTEMPTED (write window opened in-kernel).
- `try_cfi_stage` (`src/fops.c:344-641`) contains ZERO flip writes. All
  `misc_fops` writes found by full-tree grep: `src/fops.c:486-487` writes
  back `original_fops = canon_addr(ASHMEM_FOPS)` (production restore) and
  `src/fops.c:627-628` writes back `data_addr(ASHMEM_FOPS)` (fail-path
  restore). No userspace write of `fake_fops` into `misc_fops` exists
  anywhere in `src/`.
- Consequence: a gate "after trigger returns, before the flip" cannot be
  built — by trigger-return the flip has happened (or panicked). Gating
  inside `try_cfi_stage` before `fops.c:486` would gate the RESTORE, not
  the flip. The 3× PI panics in history occurred inside the trigger race
  itself and are unreachable by any post-trigger gate.

Bonus finding (source-verified, no guessing): the wanted post-trigger 232 B
verification ALREADY exists — `audit_fake_fops_table` (`src/fops.c:39-88`,
same `FOPS_SHOW_FDINFO_OFF + 8 = 232` span, all-slot compare incl.
`FOPS_IOCTL_OFF`) runs as `try_cfi_stage`'s second check
(`src/fops.c:412`), right after the `misc_fops == fake_fops` readback
(`src/fops.c:361-363`, the post-trigger read the evidence cites as
working). What EZIF actually lacks is only the fresh-page RETRY loop: it
does not define `APP_REQUIRE_FRESH_P0_SESSION`, so `src/main.c:594-683`
is compiled out and production walks the gated pre-trigger block
(`src/main.c:686-780`).

Proposed alternative (NOT implemented — needs parent auth because it
reverses the safety contract): reorder the EZIF block to
trigger → post-trigger 232 B table gate-read → `try_cfi_stage`, else
userspace RESTORE of `misc_fops` (mirror `fops.c:622-628`, mandatory —
trigger=1 may have already flipped) + fresh `prepare_good_kernel_page`
retry ×5, 5 misses → clean `return 1`. Caveats: "no flip on miss" becomes
"restore on miss" (flip precedes gate), and trigger-first re-exposes the
PI-panic leg (current gated builds: 0 flips / 0 panics across 48 attempts;
ungated history: 4 blind-flip panics). Do NOT implement without explicit
authorization.

Baseline rebuild (no source change; NDK r29
`/home/samson1357924/Android/Sdk/ndk/29.0.14206865`, `make release`
exit 0 both): e1q `104128 B`, SHA-256
`e25561fc85b1021bffecbe424da2168976cd8c47814fcf3867f80760ddf5d720`
(= §9.12 gate-v2 artifact, `pre-flip gate` strings ×5); e3q-S9280ZCS6DZF2 control
`104128 B`, SHA-256
`e9baa068843b372cf5d1a7131902f58af25931327957df7b39df3b655e89c9bc`
(measured 2026-11-04 from `artifacts/e3q-S9280ZCS6DZF2/cve-2026-43499-app.so`;
the previously recorded `955d79d7…` matches no on-disk artifact — see correction note below),
`pre-flip gate` strings ×0 (isolation intact, 29 targets untouched).

Correction note (2026-11-04, docs-only fix — no source/artifact change):
the `955d79d7…` value previously recorded here and in §9.15 matches NONE
of the three committed e3q artifacts (all `104128 B`, git-clean since
September). Measured `sha256sum artifacts/e3q-*/cve-2026-43499-app.so`:
`e3q-S9280ZCS6DZF2` =
`e9baa068843b372cf5d1a7131902f58af25931327957df7b39df3b655e89c9bc`;
`e3q-S928BXXS6DZF2` =
`a49b378d654c7e637697a701c3c4c5fd02d22b9b30a7069c03e64ec5844af206`;
`e3q-S928USQS6DZF2` =
`b2931d8980f969b5a0cb05bd67f6804f445ad4a4c867a7b4c4081c2ffac5b36a`.
`955d79d7…` is retired as a stale record; the per-variant values above are authoritative.

Lessons converged (for any future gate work): (1) S2 structural diffs must
be followed by a probe proving the new macro actually takes effect in the
compiled path (preprocessed `-E` check like §9.10, not just `#define`
presence); (2) ×5 dead-code lesson — retry budgets must live on the path
the target actually walks (`#else` single-shot hardcodes `<= 1`,
`src/main.c:782`), name the loop bound from the macro or comment why not;
(3) reboot → repush → reverify hashes pre-fire; (4) single boot single
round; (5) raw log archived with SHA (per §9.11/§9.12 precedent).

### 9.14 Ungated tuned build (`efc8b49c`) full-chain on boot `55936f1a` (2026-11-03) — PANIC at attempt 1/24 (attempt index, NOT a rate), NEW CFI lseek signature #134

Same boot `55936f1a` as §9.11/§9.12 (no reboot in between), single round,
no second exploit. This round fired the §9.9 NanoTurtle-tuned build WITHOUT
any gate (`efc8b49c…`, 104128 B) — device copy carries 0 `pre-flip gate`
strings (read-only `strings` check, binary never executed by this worker).
Full local record: `/mnt/240G_SSD/opencode_tmp/s3_lottery2/`
(`lotto2_boot55936f1a.log` + `dumpstate_lastkmsg_134_…_KP.log.gz` +
`dumpstate_latest_after_lotto2.log.gz` + `lastkmsg134/` extract).

- Build identity (pre-fire, hashes match local `build/` exactly — no
  rebuild, `target.h` untouched): `lotto2_app.release.so` SHA-256
  `efc8b49caa912953…a86a538` (= §9.9 tuned125 artifact); `lotto2_root`
  `c49a655708be…` (27264 B, §9.6 runner); `lotto2_ksud-331`
  `fde99b5a…` (5065680 B, staged but never consumed).
- Run (ONE invocation, `ATTEMPTS=24`, TIMEOUT 300/180): attempt **1/24**,
  pid 16226, `slide-kaslr-ok source=tracefs base=ffffffc008170000
  slide=0x170000` (quorum `best=00170000 hits=17 second=0`, unanimous;
  same per-boot slide as the two gated runs) → `fops-page-held`
  checkpoint → transport died. No `exploit completed`, no root umh, no
  late-load. Durable log `lotto2.log` 4760 B, SHA-256
  `63cd2904097a…` — pulled read-only from `/data/local/tmp` AFTER the
  reboot; byte-identical to the pre-reboot local copy (reboot did NOT
  wipe `/data/local/tmp` this round: `.so`/root/ksud/log all present).
- Panic `#134` (`dumpstate_lastkmsg_134_20261103_030839_KP.log.gz`,
  642053 B): **NEW signature** —
  `CFI failure at __arm64_sys_lseek+0xb4/0xcc (target:
  ashmem_miscs+0x10/0x140; expected type: 0xe61887de)` → `Oops - CFI`
  fatal, KTIME 10762.32, CPU 0, task `cve43499-run:16226`. `Modules
  linked in:` carries NO `kernelsu` LKM (the sole `kernelsu` string in
  the dump is an unrelated userspace `weishu.kernelsu` task line) →
  **pre-load, pre-root panic**. Device rebooted on its own to
  `c40722eb` (`ro.boot.bootreason=reboot`); this worker ran NOTHING
  (boot-storm protocol: pull only, zero executions).
- Verification items (a)–(e) unrunnable (no root session); Manager
  skipped per protocol.

Boot comparison (this round):

| Field | Before (exploit boot) | After |
| --- | --- | --- |
| boot_id | `55936f1a` | `c40722eb` |
| kernelsu module | absent (never loaded this boot) | absent (volatile) |
| SELinux | Enforcing (never left Enforcing — no root) | Enforcing |
| `/data/local/tmp` round files | pushed pre-fire, hash-verified | all present, hashes intact |

llseek-slot note (source-verified, cf. §9.10): spray plants
`FOPS_LLSEEK_OFF` as `fake_w0 + FAKE_WAITER_PI_TREE_ENTRY_OFF`
(`= fake_w0+0x18`; `put_fake_fops_table`, `src/util.c:930-931`), and
`repair_fake_fops_llseek` (`src/fops.c:269`, called at `src/fops.c:453`
inside `try_cfi_stage`) rewrites that slot to `NOOP_LLSEEK` post-flip.
The gate (§9.10–§9.12) deliberately never gates this slot — only the
ioctl slot (`text_addr(ASHMEM_IOCTL)`) is stable across re-prepares.
#134 is the consequence: an `lseek` issued through the overwritten
`misc_fops` hit the llseek slot while it still held the non-llseek-typed
planted value (repair runs only post-flip inside `try_cfi_stage`), so CFI
killed it (`expected type 0xe61887de` vs planted gadget). The llseek slot
is flip-racy by construction — planted gadget first, repaired later —
and any trigger path that issues `lseek` between flip and repair dies
exactly this way. Parent-session decision how to close it; at §9.14 time no source
was changed (retry-lottery §9.15 came later).

Scoreboard (adb manual route, FROZEN at §9.14 — superseded by combined 2/7 in §9.16): **1/6** — one full-chain
root + KSU v3.3.1 live (boot `8ae3860a` run 1, §9.6); five panics: run-2
`misc_open`/`try_module_get` (post-load, same-boot re-invoke, §9.6),
#131 + #132 PI `refcount_warn_saturate ← rt_mutex_adjust_prio_chain`
(pre-root, §9.7/§9.8), #133 CFI `__arm64_sys_ioctl` (post-PI, pre-root,
§9.9), #134 CFI `__arm64_sys_lseek` (pre-root, this section).

#### 9.14.1 Addendum — same round, key extra signals (merged to avoid duplication; run detail above is authoritative)

Single boot, single round, no second exploit (same round as §9.14 — setup not repeated here).
Extra signals beyond the run record above:
- Panic `#134` (`dumpstate_lastkmsg_134_20261103_030839_KP.log.gz`, 642053 B,
  + same-bytes latest, SHA-256 `109b485d…`): `Oops - CFI` at
  `__arm64_sys_lseek+0xb4/0xcc`, task `cve43499-run:16226`, KTIME 10762.32,
  no `kernelsu` (pre-load). `x8 = ffffffc00a54c200` = the planted fake_fops
  address — the flip LANDED (ungated blind flip) and the first fops dispatch
  died at `llseek` CFI. Same CFI family as #133 (ioctl), one stage later,
  different syscall slot; PI-race window was passed.
- Device self-rebooted to `c40722eb` (`bootreason=reboot`, `Enforcing`,
  driver absent). Pushed files survived with hashes intact this time.
- Verification (a)–(e) unrunnable without a root session; no second round.
  Shell-side only: `Enforcing` throughout, driver absent. Manager skipped
  per protocol (only v3.3.0 apk on hand, version-mismatch + UI needed).

Status: chain root at §9.14 time still ONLY from boot `8ae3860a` run 1 — **1 root vs
5 fops-stage panics** (run-2 post-load misc, #131/#132 PI, #133 ioctl-CFI,
#134 lseek-CFI). Control-channel/`su`/Manager/resetprop/repeatability
still TODO at that point (see §9.16 for what §9.16 closed).

### 9.15 Single-shot-path retry lottery (static only, no device run)

Gate reverted (`19418fc`: pre-trigger primitive confirmed dead, §9.12), so
production is a pure lottery again — and the lottery was single-ticket:
`APP_FOPS_FRESH_PAGE_ATTEMPTS=5` is dead code on this target because EZIF
does not define `APP_REQUIRE_FRESH_P0_SESSION`, so the fresh retry loop
(`src/main.c:594-683`) is compiled out and production walks the `#else`
single-shot path (`attempt<=1`). NanoTurtle's same-core measurement says a
real ×5 is worth 67%. This section puts the ×5 budget on the path EZIF
actually walks. At §9.15 time no exploit run was performed (static only).

- Scope (hard constraint): `src/main.c` `#else` region only + one macro
  `#define APP_FOPS_SINGLE_PATH_RETRY 1` (`1` is the §9.15-time value;
  HEAD default is `0` since commit `a687ea9` — see §9.17) in
  `src/targets/e1q-S9210ZHU6EZIF/target.h`. No offsets/SHIFT/DELTA/MM/
  PHYS_LOAD change; `src/fops.c`/`src/slide_app.c`/`src/pipe.c` untouched.
  (`APP_FOPS_PREFLIP_GATE` was retired with the reverted gate and is NOT
  defined anymore — see `target.h` historical note.)
- Design: the `#else` block is now `#if
  defined(APP_FOPS_SINGLE_PATH_RETRY) && APP_FOPS_SINGLE_PATH_RETRY` /
  retry loop / `#else` verbatim single shot / `#endif`. Loop bound reuses
  `APP_FOPS_FRESH_PAGE_ATTEMPTS` (`#ifdef`, else 1 — other targets'
  default behavior unchanged by construction). Retry body mirrors the
  fresh-session loop: `attempt != 1` → `prepare_good_kernel_page
  (PAGE_PAYLOAD_FOPS)` (unavailable → warning + `continue`) → trigger →
  `verified = triggered && try_cfi_stage()` → `verified || cfi_dirty_seen`
  breaks immediately (dirty state is never retried — same fail-closed
  semantics as the fresh loop) → else clean-miss log. No
  `reset_pipe_attempt` between attempts (that helper zeroes
  `pipebuf_page_base` without rebuilding it, cf. §9.10).
- Structural transplant check (why this was NOT BLOCKING): the EZIF
  trigger (`src/slide_app.c:2442` leg) re-arms per call (cycling static
  `delay_index`, fresh fork per call); `prepare_good_kernel_page` is the
  designed fresh-page primitive (fresh loop + `src/fops.c:189` precedent);
  `try_cfi_stage`'s clean-miss path only closes its fd (`dirty=0` → the
  `fail:` restore is a no-op); `start_p0_ref_keeper` is idempotent.
- Build proof (NDK r29
  `/home/samson1357924/Android/Sdk/ndk/29.0.14206865`, `make release`
  exit 0 both, `-Wall -Wextra` clean both):
  e1q **104128 B**, SHA-256
  `74496f5ba4d49e79106fe4c1fe1c9778ff96b50ccbf647ae1c0d3226e2f93a8b`
  (retires §9.12 gate-v2 `e25561fc…`; supersedes review-fix predecessor
  `7b68f38d…` — only change is the §9.15→review log-wording fix
  `releasing reclaim state` → `retrying with fresh FOPS page` + removal of
  the dead `APP_FOPS_PREFLIP_GATE` define, no logic change; itself superseded
  by the §9.17 HEAD build `efc8b49c…` — retry now disabled by default); e3q-S9280ZCS6DZF2 control
  **104128 B**, SHA-256
  `e9baa068843b372cf5d1a7131902f58af25931327957df7b39df3b655e89c9bc`
  (measured value — the `955d79d7…` recorded at §9.15 time matches no on-disk
  artifact, see correction note in §9.13; **behavior unchanged vs the §9.13 baseline**).
  `strings`: e1q `clean miss` ×1 / `fresh page unavailable` ×1 /
  `attempt=%d/%d`; e3q `clean miss` ×0 / `attempt=%d/1`. Preprocessed
  (`-DAPP_PAYLOAD=1 -E`): e1q expands to `const int
  fops_single_attempts = 5; for (attempt <= fops_single_attempts)` with
  fresh prepare + dirty-break; e3q still expands to verbatim
  `for (int attempt = 1; attempt <= 1; …)`, zero retry references. Only
  `src/main.c` + the EZIF `target.h` reference the new macro (29 targets
  untouched).

Dead-code lesson (extends §9.13 lesson 2): a retry budget is only real if
it is live on the path the target walks — `#define` presence proves
nothing. `APP_FOPS_FRESH_PAGE_ATTEMPTS=5` sat defined since the
NanoTurtle tune while the only loop consuming it was compiled out for two
whole rounds (§9.9/§9.14 burned single tickets without knowing it). Port
checklist addition: after any macro/budget change, `-E`-expand the
target's actual config and grep the production path for the bound before
claiming the budget exists.

### 9.16 App end-to-end root success (S24 0.3.4-s24.1, boot `de00aae0`)

Second independent EZIF root, via a different route on a different
machine: the user ran the S24 App (v0.3.4-s24.1 / versionCode 18, with
built-in exploit + ksud assets) over `ssh` + `adb` from host
`ubuntu-13g1` and reached granted root. This worker performed
forensics ONLY (38 logs + `SHA256SUMS.txt` + `verdict.md`, all under
`/mnt/240G_SSD/opencode_tmp/ezif_approot_20261103/`, `sha256sum -c`
clean): no exploit run, no reboot, no repo change, no commit. Per the
build record the App's built-in assets correspond to source commit
`58a6772` (= pre-review-fix HEAD; repo `.so` has since moved `74496f5b…`
(§9.15, log-wording-only review fix) → HEAD `efc8b49c…` (commit `a687ea9`,
retry disabled by default — see §9.17); exploit logic unchanged); the APK payload bytes were
device-pull verified 2026-11-04 (base.apk `53775826` B,
`1f6f990bfb521387bf31bed84fb794b95d9ced14d8d839c2285da48be4562bc8`,
adb-pull and scp-landed copies byte-identical — see table).

Key values (all device-measured 2026-11-02T21:45–21:46Z; device local
2026-11-03 05:45–05:46, UTC+8):

| Item | Value | Evidence file (SHA-256 in `SHA256SUMS.txt`) |
| --- | --- | --- |
| boot_id | `de00aae0-f7cd-4789-8a79-274b1d8ad9a4` (identical in `a01` and `h02`) | `a01_boot_id.log` (`47616568…`), `h02_boot_completed_extra.log` (`49ac6cbd…`) |
| PDA / display / incremental | `S9210ZHU6EZIF` / `CP2A.260605.016.S9210ZHU6EZIF` / `S9210ZHU6EZIF` | `a04_pda_version.log` (`b6ddc25d…`) |
| Fingerprint | `samsung/e1qzhx/qssi_64:17/…` (system) + `samsung/e1qzhx/e1q:17/…` (build) | `a04`, `a07_fingerprint_all.log` (`042a0813…`) |
| Android / SDK / patch / model | release `17`, sdk `37`, patch `2026-09-05`, `SM-S9210`, `e1q` | `a05_android_release.log` (`c282e26a…`) |
| Kernel | `6.1.162-android14-11-34343818-abS9210ZHU6EZIF … #1 SMP PREEMPT Sun Sep 20 01:29:53 UTC 2026`, `aarch64 Toybox` | `a06_kernel_version.log` (`07889a15…`) |
| Boot state | `boot_completed=1`, bootreason `reboot`, uptime `6039.00 s` (~100 min) | `a02_uptime.log` (`e228ed67…`), `a03_boot_completed.log` (`e63fce49…`) |
| `su -c id` | `uid=0(root) gid=0(root) groups=0(root) context=u:r:ksu:s0` (×3: `b01`, `b02`, `h01`) | `b01_su_id.log` (`f358f3ea…`), `b02_su_id_getenforce.log` (`14b79739…`) |
| SELinux | `su -c getenforce` = `Enforcing`; shell `getenforce` = `Enforcing` (control) | `b02` (`14b79739…`), `b03_shell_getenforce.log` (`24252365…`) |
| `whoami` / `/data/adb` | `root`; `drwx------ 10 root root … /data/adb` | `b04_su_whoami_lsdatadb.log` (`fc38901a…`) |
| `/proc/modules` head | `kernelsu 237568 4 - Live 0x… (O)` (full 200+ lines archived) | `c01_proc_modules.log` (`55efae05…`); `c02_lsmod.log` (`9a0ebdb9…`) agrees |
| `su -c dmesg` | `KernelSU: handle_setresuid …`, `su->ksud`, Samsung KDP task-scoped credential install (132 lines + 100-line tail) | `c03b_dmesg_su_kernelsu.log` (`c6d5f57c…`), `c03c_dmesg_su_tail.log` (`658dacce…`) |
| ksud version | `ksud 3.3.1 (uapi: 5)` via `su -c 'ksud --version'` | `c04_ksud_version.log` (`70f1bc37…`) |
| ksud path | `which ksud` = `/data/adb/ksu/bin/ksud` (symlink → `/data/adb/ksud`) | `c05_ksud_which_help.log` (`230ac038…`) |
| KernelSU Manager | `me.weishu.kernelsu`, `versionName=v3.3.1`, `versionCode=32680`, `lastUpdateTime=2026-11-02 23:02:39` | `d03_dumpsys_kernelsu.log` (`d48b1c6c…`) |
| S24Root App | `dev.samson.s24root`, `versionName=0.3.4-s24.1`, `versionCode=18`, `lastUpdateTime=2026-11-03 03:43:47` | `e01_dumpsys_s24root.log` (`f0b88ef0…`) |

Notes and caveats (recorded honestly, not smoothed over):

- On-device `/data/adb/ksud` is `4990848 B` (2026-11-03 05:39) —
  NOT byte-identical to the repo-built v3.3.1 ksud `5065680 B`
  (`fde99b5a…`, §9.4). The version string still reports `3.3.1
  (uapi: 5)`, so the version finding stands while the size delta
  (App built-in asset now proven == repo, so the delta arose at/after
  install — recorded as an install-time processing product, no specific
  cause asserted) is noted
  for the record (`c06_data_adb_list.log`, `8962a5be…`).

  KSU ksud three-way correspondence (2026-11-04 docs cross-check — no new device run):

  | ksud source | Size | SHA-256 / digest | Provenance |
  | --- | --- | --- | --- |
  | App built-in (S24 0.3.4-s24.1 asset) | 5065680 B | `fde99b5a129e5714fe6f598cf8276c76d2cbaf1a7f4e6ce9ae69d5ebca0abe61` — **MATCH repo** (size + SHA double MATCH) | device-pull verified 2026-11-04: base.apk 53775826 B `1f6f990bfb521387bf31bed84fb794b95d9ced14d8d839c2285da48be4562bc8` adb-pull/scp two-end identical (t03/t04), asset via `unzip -p` pipe + `unzip -l` size cross-check (t05/t06) |
  | On-device `/data/adb/ksud` (boot `de00aae0`) | 4990848 B | `4f7d5fd65631915ea579ff406bd9cbe58217f2c91dac6527f5b2f28ad4508171` — **MISMATCH vs repo** (−74832 B, SHA differs) | device-measured 2026-11-03 05:39 (`c06_data_adb_list.log`, `8962a5be…`); SHA re-verified 2026-11-04 via root `sha256sum` (t01) |
  | Repo release `kernelsu/ksud-e1q-S9210ZHU6EZIF-kdp` | 5065680 B | `fde99b5a129e5714fe6f598cf8276c76d2cbaf1a7f4e6ce9ae69d5ebca0abe61` (measured 2026-11-04, matches §9.4) | built §9.1–§9.4, published in `58a6772` |

  Conclusion: App built-in == repo proven (5065680 B + SHA-256 double
  MATCH). On-device `/data/adb/ksud` differs from repo (4990848 B,
  different SHA; version string `ksud 3.3.1 (uapi: 5)` agrees but equal
  version ≠ same binary — no exact-pair; may be an install-time
  processing product, no specific cause asserted).
- `lastkmsg` slots 132–136 exist (latest
  `136_20261103_040451_KP.log.gz`, 700214 B); NOT pulled, timestamps
  only (`f02_dumpstate_lastkmsg.log`, `2e2ec42a…`). This boot started
  ~04:04–04:05 local (uptime 6039 s at 05:45), which coincides with the
  #136 timestamp — recorded as timing coincidence, with NO claim about
  panic vs normal reboot.
- `logcat -d -s S24Root:*` is empty (0 lines, rc=0); the wider grep
  shows only system-side mentions (freeze/unfreeze, `libksud.so`,
  AppsFilter) — no App custom lines, logcat never cleared
  (`g01`/`g02`/`g03`).
- Expected non-root artifacts, all archived as-is: `c03` non-root
  dmesg `Permission denied` (superseded by `c03b`/`c03c` under su);
  `c05` tail `ksud: inaccessible or not found` (non-su PATH, `su`
  context has the ksud PATH); `c06` rc=1 solely from three absent
  `*version*` files; `d01`/`d02` `SecurityException: … user 150`
  header with complete listings.

Relation to run 1 and scoreboard (one defined scoring definition):

- Run 1 (§9.6, boot `8ae3860a`) = adb full chain with a manually
  pushed repo `.so` (`9c6cf160…` at that time) + staged ksud: first independent
  root. This App run (boot `de00aae0`) = full chain with the App's
  built-in assets (`7b68f38d…` 104128 B exploit — pre-review-fix equivalent
  of `74496f5b…` (§9.15; HEAD is now `efc8b49c…`, retry disabled by default —
  see §9.17), log-wording only — + `fde99b5a…` ksud,
  source commit `58a6772`): second independent root.
- Scoreboard definition (frozen): the denominator counts EZIF hardware rounds
  with a decisive outcome (granted root OR panic); fail-closed clean
  aborts (§9.11/§9.12, 0 flips / 0 panics) do not score. adb manual
  route stays **1/6** (1 root + 5 panics: run-2 post-load misc,
  #131/#132 PI, #133 ioctl-CFI, #134 lseek-CFI). App route opens at
  **1/1**. Combined EZIF scoreboard: **1/6 → 2/7** (denominator +1 for
  this App round, numerator +1 for its success).
- Blocker impact: §9.5/§9.6 items (a) `su -c id`, (c) post-root
  SELinux, (d) live-driver version → CLOSED; Manager pairing → PARTIAL
  (package version proven, `Working <LKM>` UI still needs a user
  screenshot). Still TODO: `ksud debug` control-channel check,
  resetprop matrix, repeatability/reboot matrix, repo release/feed.

### 9.17 Retry disabled by default + HEAD rebuild (commit `a687ea9`, static only, no device run)

Stage-1 review follow-up (PR #10 P1/P3). No exploit run, no feed/KSU
change at §9.17 time.

- `APP_FOPS_SINGLE_PATH_RETRY 1→0`
  (`src/targets/e1q-S9210ZHU6EZIF/target.h:120`, commit `a687ea9`):
  production walks the verbatim single-shot `#else` path again until
  clean-miss retry has fail-closed evidence. A clean miss (`verified=0`,
  no dirty) is NOT proof the kernel is clean: the flip may already have
  happened inside the trigger (§9.13), and `cfi_dirty_seen` is only the
  CFI-scratch sticky flag (`src/fops.c:451`), not fops-recovery evidence —
  so replaying with a fresh FOPS page is not fail-closed. The retry loop
  in `src/main.c` is retained but compiled out by the `0`.
- P3 log-precision fix (same commit, inside the compiled-out retry block):
  the `retrying` log is guarded by `attempt<max` (final miss logs
  distinctly), per-iteration `cfi_last_step`/`cfi_last_errno` 0/0 reset,
  and an explicit `CFI not run` log when the trigger failed. No
  production-path behavior change.
- Rebuild (NDK r29
  `/home/samson1357924/Android/Sdk/ndk/29.0.14206865`, `make release`
  exit 0): `artifacts/e1q-S9210ZHU6EZIF/cve-2026-43499-app.so` **104128 B**
  (fixed-size padding satisfied), SHA-256
  `efc8b49caa9129539645689479eaa55b7aa0059e621997beee375a8a1a86a538`
  (measured 2026-11-04 from the committed artifact; HEAD blob matches the
  worktree file). The SHA equals the §9.9 tuned build by construction, not
  by staleness: with RETRY=0 the compiler takes the same verbatim `#else`
  single-shot leg as §9.9 (every `a687ea9` source delta sits in the
  compiled-out `#if` block or in comments), and `git show --stat a687ea9`
  confirms the artifact blob changed (`74496f5b…` → `efc8b49c…`).
  Read-only `strings` check on the HEAD `.so`: retry-block strings
  (`clean miss`, `retrying with fresh FOPS page`, `pre-flip gate`) ×0,
  `attempt=%d/1` ×1 — production is single-shot.
- e3q artifacts untouched: `git status` clean for `artifacts/e3q-*/`
  (September bytes, all `104128 B`; per-variant SHAs corrected in §9.13,
  `955d79d7…` retired).
- Status declaration: the HEAD retry branch is **UNVERIFIED and DISABLED by
  default**. Both counted roots predate it — run 1 (§9.6) used the
  then-current `9c6cf160…` repo `.so`, and the App run (§9.16) used
  `7b68f38d…`-era built-in assets (device-pull verified in §9.16:
  base.apk 53775826 B two-end identical, asset `7b68f38d…` 104128 B). Run 1 did not trigger the retry loop — its §9.6
  transcript shows first-try success (`exploit completed attempt=1/24`).
  The App run's built-in `.so` is RETRY=1 compiled in (the `58a6772` blob
  measures retry present, `clean miss` ×1) but has no attempt-level
  transcript, so whether retry fired is unknown. Neither run therefore
  validates HEAD (`a687ea9` / `efc8b49c…`, retry disabled by default). Scoreboard
  stays **2/7** (frozen definition, §9.16 — no new success claimed here).
- HEAD binding verification: **TESTED in §9.18** (was PENDING at §9.17
  time; now closed as a 0/1 fail-closed data point, not a success — see
  §9.18). Exact SHA `efc8b49c…` + HEAD `a687ea9` (+ docs-only successors
  `d62aefd`/`2c624b2`, artifact bytes unchanged) + on-device test on boot
  `608f9edb` + post-failure state review. Do NOT infer HEAD rootability
  from the §9.6/§9.16 runs; §9.18 neither proves nor disproves it
  (single ticket + PI panic first).

#### 9.17.1 Reboot-persistence check (boot `de00aae0` → `2f39dbe6`, 2026-11-04, read-only, no success claimed)

| Item | Value |
| --- | --- |
| New boot_id | `2f39dbe6-446b-4928-a9af-79cd4895174d` (prior boot `de00aae0`, the App-root success boot, §9.16) |
| Uptime | ~263 s |
| PDA | `S9210ZHU6EZIF` |
| Kernel | `6.1.162-android14-11-34343818-abS9210ZHU6EZIF` (unchanged) |
| Boot state | `boot_completed=1`, `bootreason=reboot,shell` |
| `su` | absent (`/system/bin/sh: su: inaccessible or not found`) |
| `getenforce` | `Enforcing` |
| `/proc/modules` | no `kernelsu` (grep count 0) → root gone |
| `dumpstate_lastkmsg_*` | still only #132–#136 (latest `136_040451`), no new entry → clean reboot |

Evidence: `/mnt/240G_SSD/opencode_tmp/reboot_nopersist_20261104/reboot_persist_check.log`
(SHA `80fd18e2…`). Conclusion: root is **non-persistent across reboot as
expected** (LKM RAM-only); persistence-matrix cell CLOSED; scoreboard stays
**2/7** (no new success claimed); device alive — current boot is usable for a
follow-up HEAD-bound run, which still requires explicit authorization.

### 9.18 HEAD-bound single-shot run on boot `608f9edb` (2026-11-04) — PANIC #138 pre-root, HEAD 0/1

Single boot, single round, no second exploit (panic protocol: stop, pull,
no re-fire). First and only on-device firing of the HEAD-bound artifact
(`efc8b49c…`, RETRY=0 single-shot). **NO ROOT — no new success claimed.**
Full worker record (take precedence on detail):
`/mnt/240G_SSD/opencode_tmp/headv_608f9edb/verdict.md`
(SHA-256 `2620db26749c…`).

- Idle gate (same boot, pre-fire, `prefire_gate.log`): boot
  `608f9edb-4c8d-497a-ad91-5f32da5185a3`, uptime `724 s` (>600 ✓), load
  `1.98` (<3 ✓), `boot_completed=1`, `getenforce Enforcing`, no
  `kernelsu` (`/proc/modules` count 0, dmesg count 0), `which su` empty.
- HEAD binding (device-side pre-fire re-verified, all match —
  `local_sha.txt` vs `ondevice_verify.log`, ELF magic `7f 45 4c 46`):

  | File (`/data/local/tmp/headv_*`) | Bytes | SHA-256 (device = local) |
  | --- | --- | --- |
  | `headv_app.release.so` ← `artifacts/e1q-S9210ZHU6EZIF/cve-2026-43499-app.so` (HEAD `2c624b2`; bytes from `a687ea9`, unchanged) | 104128 | `efc8b49caa9129539645689479eaa55b7aa0059e621997beee375a8a1a86a538` ✓ |
  | `headv_root` ← `build/e1q-S9210ZHU6EZIF/cve-2026-43499-root` | 27264 | `c49a655708bed646441f6a7d848c5a400e6fb444f7fcf05fcb0704e547ddcd55` ✓ |
  | `headv_ksud-331` ← `kernelsu/ksud-e1q-S9210ZHU6EZIF-kdp` (staged, never consumed) | 5065680 | `fde99b5a129e5714fe6f598cf8276c76d2cbaf1a7f4e6ce9ae69d5ebca0abe61` ✓ |
  | `.ksud-stage` + `ksud-s25u-kdp` (`cp` preset, same hash) | 5065680 | `fde99b5a…` ✓ |

  Shell-side: `headv_ksud-331 --version` = `ksud 3.3.1 (uapi: 5)` (driver
  not live, version string only).
- Run (ONE invocation, `ATTEMPTS=24`,
  `EXPLOIT_ATTEMPT_TIMEOUT_SEC=300`, `P0_ATTEMPT_TIMEOUT_SEC=180`,
  `STACK_WRITER_DELAY_USEC=125000`, fired 2026-11-04T10:33:37Z via
  `headv_root --run-payload`): attempt **1/24** (attempt index within this
  single round, NOT a rate), pid 19009, `slide-kaslr-ok source=tracefs
  base=ffffffc008170000 slide=0x170000` (quorum `best=00170000 hits=14
  second=0`, unanimous; 5th distinct per-boot unanimous slide after
  `0x90000`/`0x140000`/`0x50000`/`0x180000`, volatility as expected).
  PI stages all passed
  (`owner-target-locked` → `deadlock-accepted` → `wait-timeout-accepted` →
  `writer-enter`, `configured_delay=125000 consume_delay=125000`
  confirmed), then live transport died at `writer-enter`. Durable
  `headv.log` (4325 B, SHA `f0ac96f4…`, pulled post-reboot as
  `headv_from_device.log`, byte-consistent with the live prefix
  `headv_live.log` 5363 B) stops at `fops-page-held` — same log-gap
  pattern as §9.7/§9.8/§9.9. No `exploit completed`, no root umh, no
  late-load.
- Panic **#138** (`lastkmsg138_KP.log.gz`, 637823 B, SHA-256
  `3f63d81dc9cc…`; `lastkmsg_latest.log.gz` same bytes; unpacked
  `lastkmsg138.txt` 2097731 B): **pre-load, pre-root PI `refcount`
  family — same family as #131/#132 (§9.7/§9.8)**:
  `WARNING: CPU: 1 PID: 28852 at lib/refcount.c:25
  refcount_warn_saturate` ← `rt_mutex_adjust_prio_chain` ←
  `rt_mutex_adjust_pi` ← `__sched_setscheduler` ←
  `__arm64_sys_sched_setattr` → `Internal error: Oops: 96000005` NULL
  deref at `0x18`, task `cve43499-run:28852`, CPU 1, KTIME **753.63**
  (≈ fire-boot uptime 724 s + ~30 s run, self-consistent). Full dump
  `kernelsu` string count **0** → KSU never loaded. Device self-rebooted
  to `6e1b4735-25bf-4d5e-8afc-91f7fda0fe45`
  (`ro.boot.bootreason=reboot`, `boot_completed=1`, `Enforcing`, driver
  absent, volatile as expected).
- Slot hygiene: `#137_20261104_182139` timestamps to the fire boot's own
  start (~18:21 local), i.e. a prior-boot leftover — NOT pulled, NOT
  attributed here. Only the post-fire #138 pair was pulled.
- Verification items (a)–(e) unrunnable without a root session (same
  disposition as §9.7–§9.9/§9.14): `su -c id`, root-side getenforce,
  `ksud --version`/late-load/`/proc/modules` Live line/su-context dmesg,
  Manager package/dumpsys — none executable. Shell-side facts only:
  Enforcing throughout, driver absent.
- Storage face: the three pushed round files are **all absent**
  post-panic (`No such file`) — the §9.9 tuned125 face, NOT the §9.8
  retry2 zero-fill face. The fsync'd durable `headv.log` survived. Rule
  unchanged: **after ANY panic-reboot, re-push + re-verify before any
  reuse**.
- HEAD binding conclusion: HEAD (`efc8b49c…` + `a687ea9` source,
  artifact bytes unchanged through `2c624b2`) is now **on-device tested:
  0/1** (single-shot, attempt-1 pre-root PI panic). This neither proves
  HEAD rootable nor disproves it (single lottery ticket + panic arrived
  first). §9.17 PENDING is hereby closed as tested (see §9.17 bullet).

Scoreboard (definition unchanged from §9.16, extended by one counted
round): the denominator counts EZIF hardware rounds with a decisive
outcome (granted root OR panic); fail-closed clean aborts (§9.11/§9.12,
0 flips / 0 panics) do NOT score. Combined **2/8** = adb manual **1/6**
(FROZEN: 1 root on boot `8ae3860a` run 1, §9.6 + 5 panics: run-2
post-load misc §9.6, #131 §9.7, #132 §9.8, #133 §9.9, #134 §9.14) +
App **1/1** (boot `de00aae0`, §9.16) + HEAD **0/1** (boot `608f9edb`
panic #138, this section). Fail-closed §9.11/§9.12 rounds remain
outside the denominator.

User-reported note (user-reported, NO transcript — NOT counted):
the user states the last App success took seven rounds ("七輪" verbatim)
before succeeding. Round/attempt semantics are unclear (App attempts vs
user-visible rounds), so NO claim is made about which attempt succeeded.
Recorded only as compatible with the App built-in RETRY=1 (retry did
fire); it changes nothing above and adds nothing to the denominator.

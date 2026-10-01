# REBUILD e1q-S9210ZHS6DZG1 for KernelSU v3.3.0

Target: Galaxy S24 China `SM-S9210`, firmware `S9210ZHS6DZG1`
(`e1q`/`e1qzhx`, Snapdragon pineapple).

- Kernel release (exact): `6.1.145-android14-11-33419968-abS9210ZHS6DZG1`
- KernelSU base: `v3.3.0` (`932014ab5b2c9b74a3d11e2ec4d17dd10fc9442e`),
  `KSU_VERSION 32601`
- Samsung patch: `kernelsu/patches/KernelSU-v3.3.0-samsung-kdp-rkp-defex.patch`
  (reconciled Stage 1; no 5.15 companion needed on `android14-6.1`)
- Kconfig: `CONFIG_KSU=m`, `CONFIG_KSU_SAMSUNG_KDP=y`,
  `CONFIG_KSU_SAMSUNG_RKP=y`, `CONFIG_KSU_SAMSUNG_DEFEX=y`,
  `CONFIG_KSU_SAMSUNG_NO_PATCH_TEXT=y`
- DDK: `ghcr.io/ylarod/ddk-min:android14-6.1-20260313`
  (`sha256:1dd6ac340b627a90a4031d6d0df6b129d8cc949b139fb56032c898f023d3d5d3`)

## PhaseA — materials + precheck

Materials (all verified 2026-10-01):

- `vmlinux.elf`: `/mnt/240G_SSD/s9210-dzg1/analysis/vmlinux.elf`
  (43,070,883 bytes, AArch64, recovered from the DZG1 AP firmware;
  provenance in `/mnt/240G_SSD/s9210-dzg1/PROVENANCE.md`).
- `Module.symvers`: generated from the above ELF with
  `kernelsu/tools/extract_target_symvers.py` — 8283 entries.
  (Not committed; regenerated per build. Requires `pyelftools`.)
- `check_symbol`: `kernel/tools/check_symbol.c` is C source in the v3.3.0
  KernelSU tree (no longer a script); built with host `gcc -O2`.
- KernelSU source: clean `v3.3.0` (`932014ab`) checkout (shallow clone;
  `KSU_VERSION 32601` comes from the reconciled patch fallback, verified in
  the applied tree at `kernel/Kbuild`).
- Build workdir (outside the repo):
  `/mnt/240G_SSD/e1q-v3.3.0-build/` holds the KernelSU checkout,
  `Module.symvers`, `check_symbol`, and reference artifacts.

Precheck against the published v3.2.5 reference module
(`android14-6.1_kernelsu-e1q-S9210ZHS6DZG1-kdp.ko`, 398336 bytes):

- `check_symbol e1q-v3.2.5-ref.ko vmlinux.elf` → exit 0.
- `modinfo` vermagic:
  `6.1.145-android14-11-33419968-abS9210ZHS6DZG1 SMP preempt mod_unload
  modversions aarch64`.
- `audit_module_against_target.py --manual-relocation` → 202 undefined
  symbols, 0 missing from target, 0 target CRC mismatches, 70 resolved via
  kallsyms, empty `__versions`. This is the fingerprint the v3.3.0 build
  must reproduce (same undefined-import shape, zero missing/CRC).
- `readelf`: zero `UND stop_machine` imports.

Kconfig decision: `NO_PATCH_TEXT=y`. The reference module carries no
`stop_machine` import and ships the `patch_text disabled for this Samsung
target` stub; e1q follows the no-patch-text Samsung path (same as the
S928B/E2S/A56 precedent builds).
If the v3.3.0 module unexpectedly imports `stop_machine`, stop and re-audit
before touching hardware.

## PhaseB — DDK module build

Done 2026-10-01. Container
`ghcr.io/ylarod/ddk-min:android14-6.1-20260313`, single run:

- `sed 6.1.166-dirty → 6.1.145-android14-11-33419968-abS9210ZHS6DZG1`
  in `$KDIR/include/generated/utsrelease.h` +
  `$KDIR/include/config/kernel.release` (same container invocation as the
  build; the DDK image is immutable across runs).
- Mount note: mount the KernelSU root at `/workspace` with
  `-w /workspace/kernel` (mounting at `/workspace/kernel` breaks the
  kernel-subdir `Makefile` lookup).
- `make clean`; then `CONFIG_KSU=m CONFIG_KSU_SAMSUNG_KDP=y
  CONFIG_KSU_SAMSUNG_RKP=y CONFIG_KSU_SAMSUNG_DEFEX=y
  CONFIG_KSU_SAMSUNG_NO_PATCH_TEXT=y CC=clang make -j$(nproc)` → exit 0
  (`LD [M]`, `BTF [M]`; the build's own `check_symbol` against the DDK
  vmlinux also ran).
- `modinfo ./kernelsu.ko` vermagic:
  `6.1.145-android14-11-33419968-abS9210ZHS6DZG1 SMP preempt mod_unload
  modversions aarch64` — exact target match.
- Unstripped output preserved at
  `/mnt/240G_SSD/e1q-v3.3.0-build/e1q-v3.3.0-unstripped.ko`
  (5,851,848 bytes, BTF/debug included; stripping is PhaseC).

## PhaseC — static audit

Done 2026-10-01, on the unstripped PhaseB module:

- `check_symbol e1q-v3.3.0-unstripped.ko vmlinux.elf` → exit 0.
- `audit_module_against_target.py --manual-relocation` (with the PhaseA
  `Module.symvers`):
  `undefined symbols: 202 / module version entries: 0 /
  missing from target symbol table: 0 / resolved from kallsyms: 70 /
  target CRC mismatches: 0` — identical fingerprint to the v3.2.5 reference
  module (202/0/0/70/empty `__versions`).
- `readelf -SW`: `__versions` size 0; `.symtab`/`.strtab` present;
  zero `UND stop_machine` imports.
- `llvm-strip -d` (NDK r29) → published module
  `android14-6.1_kernelsu-e1q-S9210ZHS6DZG1-kdp.ko`, 406160 bytes
  (v3.2.5 reference: 398336 bytes; growth consistent with the added
  execveat fallback), SHA-256
  `d64647a118b91833ad0580076d06c946f1b5e4f34a52ae8a13aeeeebeb646687`.
- Post-strip re-verified: exact `vermagic`, `__versions` size 0,
  `.symtab`/`.strtab` retained, zero `UND stop_machine`.

## PhaseD — ksud embedding + repo publication

(Pending.)

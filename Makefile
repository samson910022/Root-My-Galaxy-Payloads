API ?= 35
TARGET ?= pa3q-S938NKSUACZF1

# Regression tests (run before merge; none must create its /tmp marker):
#   make help 'UNAME_S=$(shell touch /tmp/pwn-u)'
#   make help 'PRELOAD_SRCS=$(shell touch /tmp/pwn-s)'
#   make help 'TARGET=$(shell touch /tmp/pwn-t)'
#   make help 'OUTDIR=$(shell touch /tmp/pwn-o)'
#   make help 'ANDROID_NDK_HOME=$(shell touch /tmp/pwn-n)'
#   make help 'TARGET_CC=$(shell touch /tmp/pwn-c)'
# Sanitize & freeze (must precede ANY $(VAR) expansion):
# command-line/env vars are recursive by default, so $(shell ...) would run
# during parsing before any check sees it. Inspect raw values first.
TARGET_RAW := $(value TARGET)
API_RAW := $(value API)
ifneq ($(findstring $,$(TARGET_RAW)),)
$(error Invalid TARGET: must not contain $$)
endif
ifneq ($(findstring $,$(API_RAW)),)
$(error Invalid API: must not contain $$)
endif
TARGET := $(TARGET_RAW)
API := $(API_RAW)
override TARGET := $(TARGET)
override API := $(API)
# OUTDIR default is derived from the now-frozen TARGET (simply-expanded,
# safe). Only CLI/env-provided OUTDIR is treated as untrusted raw.
ifeq ($(origin OUTDIR),undefined)
OUTDIR := build/$(TARGET)
else
ifneq ($(findstring $,$(value OUTDIR)),)
$(error Refusing OUTDIR: must not contain $$)
endif
override OUTDIR := $(value OUTDIR)
endif
# Pre-check NDK/TCC raws before ANY $(shell) runs (else export expands them).
ifneq ($(findstring $,$(value ANDROID_NDK_HOME)),)
$(error Invalid ANDROID_NDK_HOME: must not contain $$)
endif
ifneq ($(findstring $,$(value TARGET_CC)),)
$(error Invalid TARGET_CC: must not contain $$)
endif
# Same for CLI-overridable flag/src lists: normal -D/-O/-W flags never need $.
# Scope: this blocks parsing-time $(shell) RCE via flags. Recipe-time shell
# metachars (;,`,|,…) in flags remain the caller's responsibility — flags are
# trusted build inputs (a caller who can pass arbitrary flags can already run
# arbitrary commands without make).
ifneq ($(findstring $,$(value TARGET_CFLAGS)),)
$(error Invalid TARGET_CFLAGS: must not contain $$)
endif
ifneq ($(findstring $,$(value APP_TARGET_CFLAGS)),)
$(error Invalid APP_TARGET_CFLAGS: must not contain $$)
endif
ifneq ($(findstring $,$(value COMMON_CFLAGS)),)
$(error Invalid COMMON_CFLAGS: must not contain $$)
endif
# Intended user inputs (CLI/env): TARGET, API, OUTDIR, ANDROID_NDK_HOME,
# TARGET_CC, TARGET_CFLAGS, APP_TARGET_CFLAGS, COMMON_CFLAGS.
# Everything else assigned in this file is internal and must not be
# overridable from the command line (GNU make CLI vars take precedence
# over ordinary assignments, so internal lists/paths like PRELOAD_SRCS or
# TARGET_HEADER could otherwise inject parse-time $(shell ...) via
# prerequisite expansion).
# Legacy/internal names that must never expand from CLI/env: UNAME_S was
# previously computed via $(shell uname -s) (now removed; toolchain is
# selected by existence check). Unexport it so a CLI-provided recursive
# value is never expanded during recipe-shell export.
unexport UNAME_S
# Internal vars: reject make functions early with a clear error, then force
# file values with `override` below so CLI definitions are never consumed.
ifneq ($(findstring $,$(value TARGET_HEADER)),)
$(error Invalid TARGET_HEADER override: must not contain $$)
endif
ifneq ($(findstring $,$(value TARGET_INCLUDE)),)
$(error Invalid TARGET_INCLUDE override: must not contain $$)
endif
ifneq ($(findstring $,$(value PRELOAD)),)
$(error Invalid PRELOAD override: must not contain $$)
endif
ifneq ($(findstring $,$(value APP_PRELOAD)),)
$(error Invalid APP_PRELOAD override: must not contain $$)
endif
ifneq ($(findstring $,$(value APP_RELEASE)),)
$(error Invalid APP_RELEASE override: must not contain $$)
endif
ifneq ($(findstring $,$(value APP_STABLE)),)
$(error Invalid APP_STABLE override: must not contain $$)
endif
ifneq ($(findstring $,$(value ROOT_HELPER)),)
$(error Invalid ROOT_HELPER override: must not contain $$)
endif
ifneq ($(findstring $,$(value PRELOAD_SRCS)),)
$(error Invalid PRELOAD_SRCS override: must not contain $$)
endif
ifneq ($(findstring $,$(value APP_PRELOAD_SRCS)),)
$(error Invalid APP_PRELOAD_SRCS override: must not contain $$)
endif
ifneq ($(findstring $,$(value APP_RELEASE_OPT)),)
$(error Invalid APP_RELEASE_OPT override: must not contain $$)
endif
ifneq ($(findstring $,$(value APP_RELEASE_LINK_FLAGS)),)
$(error Invalid APP_RELEASE_LINK_FLAGS override: must not contain $$)
endif
# NOTE: no freeze here; these are (re)defined below. Freeze happens after
# their file definitions so CLI values stay simply-expanded without
# clobbering defaults (see below).

# Validate TARGET with pure-make checks (no shell: avoids echo injection).
# Allowed: single word matching ^[A-Za-z0-9._-]+$.
SQ := '
HASH := \#
LP := (
RP := )
EMPTY :=
SPACE := $(EMPTY) $(EMPTY)
ifeq ($(words $(TARGET)),1)
else
$(error Invalid TARGET "$(TARGET)": must be a single word)
endif
ifneq ($(strip $(TARGET)),)
else
$(error Invalid TARGET: must not be empty)
endif
ifneq ($(firstword $(filter -%,$(TARGET))),)
$(error Invalid TARGET "$(TARGET)": must not start with -)
endif
TARGET_BAD := $(findstring /,$(TARGET))$(findstring \,$(TARGET))$(findstring $,$(TARGET))$(findstring `,$(TARGET))$(findstring ",$(TARGET))$(findstring $(SQ),$(TARGET))$(findstring ;,$(TARGET))$(findstring &,$(TARGET))$(findstring |,$(TARGET))$(findstring $(LP),$(TARGET))$(findstring $(RP),$(TARGET))$(findstring <,$(TARGET))$(findstring >,$(TARGET))$(findstring *,$(TARGET))$(findstring ?,$(TARGET))$(findstring [,$(TARGET))$(findstring ],$(TARGET))$(findstring {,$(TARGET))$(findstring },$(TARGET))$(findstring ~,$(TARGET))$(findstring !,$(TARGET))$(findstring $(HASH),$(TARGET))$(findstring %,$(TARGET))$(findstring :,$(TARGET))$(findstring =,$(TARGET))$(findstring +,$(TARGET))$(findstring @,$(TARGET))$(findstring ^,$(TARGET))$(findstring $(SPACE),$(TARGET))
# NOTE: comma is shell-harmless and would only produce a nonexistent
# src/targets/... path; space is already rejected by the words check above.
ifneq ($(TARGET_BAD),)
$(error Invalid TARGET "$(TARGET)": must match ^[A-Za-z0-9._-]+$$)
endif

# API must be a plain integer (used in compiler path and echoed to shell).
ifeq ($(strip $(API)),)
$(error Invalid API: must not be empty)
endif
# Reject anything that is not all digits.
ifneq ($(words $(API)),1)
$(error Invalid API "$(API)": must be a single word)
endif
API_DIGITS := $(subst 0,,$(subst 1,,$(subst 2,,$(subst 3,,$(subst 4,,$(subst 5,,$(subst 6,,$(subst 7,,$(subst 8,,$(subst 9,,$(API)))))))))))
ifneq ($(API_DIGITS),)
$(error Invalid API "$(API)": must contain only digits 0-9)
endif

# Guard against destructive OUTDIR with pure-make checks.
# Allowed chars: [A-Za-z0-9._-/]; absolute paths permitted.
ifeq ($(strip $(OUTDIR)),)
$(error Refusing to use empty OUTDIR)
endif
ifeq ($(OUTDIR),/)
$(error Refusing to use OUTDIR "/")
endif
ifneq ($(findstring ..,$(OUTDIR)),)
$(error Refusing to use OUTDIR "$(OUTDIR)" containing ..)
endif
ifneq ($(firstword $(filter -%,$(OUTDIR))),)
$(error Refusing to use OUTDIR "$(OUTDIR)" starting with -)
endif
OUTDIR_BAD := $(findstring \,$(OUTDIR))$(findstring $,$(OUTDIR))$(findstring `,$(OUTDIR))$(findstring ",$(OUTDIR))$(findstring $(SQ),$(OUTDIR))$(findstring ;,$(OUTDIR))$(findstring &,$(OUTDIR))$(findstring |,$(OUTDIR))$(findstring $(LP),$(OUTDIR))$(findstring $(RP),$(OUTDIR))$(findstring <,$(OUTDIR))$(findstring >,$(OUTDIR))$(findstring *,$(OUTDIR))$(findstring ?,$(OUTDIR))$(findstring [,$(OUTDIR))$(findstring ],$(OUTDIR))$(findstring {,$(OUTDIR))$(findstring },$(OUTDIR))$(findstring ~,$(OUTDIR))$(findstring !,$(OUTDIR))$(findstring $(HASH),$(OUTDIR))$(findstring %,$(OUTDIR))$(findstring :,$(OUTDIR))$(findstring =,$(OUTDIR))$(findstring +,$(OUTDIR))$(findstring @,$(OUTDIR))$(findstring ^,$(OUTDIR))$(findstring $(SPACE),$(OUTDIR))
ifneq ($(OUTDIR_BAD),)
$(error Refusing to use OUTDIR "$(OUTDIR)": must match ^[A-Za-z0-9._/-]+$$)
endif

override SLIDE_STACK_WRITER_TARGETS := dm2q-S916BXXSAFZG1 dm3q-S918BXXSAFZF5 dm3q-S9180ZHS8FZG1 gts9u-X916BXXS6EZG3 dm1q-S911U1UES6DYI3 gts9-X710XXS6EZF1
ifneq ($(filter $(TARGET),$(SLIDE_STACK_WRITER_TARGETS)),)
APP_TARGET_CFLAGS := -DSLIDE_STACK_WRITER=1
else
APP_TARGET_CFLAGS :=
endif
ifeq ($(TARGET),a53x-A536EXXSNGZG3)
API := 31
endif

override TARGET_HEADER := src/targets/$(TARGET)/target.h
override TARGET_INCLUDE := targets/$(TARGET)/target.h
# ANDROID_NDK_HOME may arrive from CLI/env as a recursive variable;
# reject make expansion before it is ever expanded, then freeze.
NDK_RAW := $(value ANDROID_NDK_HOME)
ifneq ($(findstring $,$(NDK_RAW)),)
$(error Invalid ANDROID_NDK_HOME: must not contain $$)
endif
override ANDROID_NDK_HOME := $(NDK_RAW)
# No parse-time $(shell ...) in this file (a parse-time shell would expand
# arbitrary CLI recursive vars during export). Select the NDK toolchain by
# existence instead of `uname -s`: prefer the darwin prebuilt when present,
# otherwise linux (also the default when no NDK is installed, for help/info).
override _DARWIN_CC := $(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android$(API)-clang
override _LINUX_CC := $(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android$(API)-clang
ifeq ($(origin TARGET_CC),undefined)
ifneq ($(wildcard $(_DARWIN_CC)),)
override TARGET_CC := $(_DARWIN_CC)
else
override TARGET_CC := $(_LINUX_CC)
endif
else
# CLI-provided TARGET_CC: already $-checked above; freeze it.
override TARGET_CC := $(value TARGET_CC)
endif

# Bare `make` defaults to `all` (needs toolchain); only the listed
# inspection/cleanup goals skip the check.
ifeq ($(strip $(MAKECMDGOALS)),)
override NEEDS_TC := all
else
override NEEDS_TC := $(filter-out help info clean distclean,$(MAKECMDGOALS))
endif
ifeq ($(NEEDS_TC),)
# info/help/clean-only invocation: skip toolchain check.
else
ifeq ($(wildcard $(TARGET_CC)),)
$(error set ANDROID_NDK_HOME to an Android NDK containing aarch64-linux-android$(API)-clang)
endif
endif

override PRELOAD := $(OUTDIR)/cve-2026-43499
override APP_PRELOAD := $(OUTDIR)/cve-2026-43499-app.so
override APP_RELEASE := $(OUTDIR)/cve-2026-43499-app.release.so
override APP_STABLE := $(OUTDIR)/cve-2026-43499-app.stable.so
override APP_RELEASE_SIZE := 104128
override ROOT_HELPER := $(OUTDIR)/cve-2026-43499-root
TARGET_CFLAGS :=
override APP_RELEASE_OPT := -Oz
override APP_RELEASE_LINK_FLAGS := -Wl,--gc-sections -Wl,--icf=all -s

override PRELOAD_SRCS := \
  src/main.c \
  src/util.c \
  src/slide.c \
  src/fops.c \
  src/pipe.c \
  src/root.c \
  src/preload.c

override APP_PRELOAD_SRCS := \
  src/main.c \
  src/util.c \
  src/slide_app.c \
  src/fops.c \
  src/pipe.c \
  src/root.c \
  src/preload.c

ifeq ($(TARGET),a53x-A536EXXSNGZG3)
override APP_PRELOAD_SRCS := \
  src/targets/a53x-A536EXXSNGZG3/payload.c \
  src/targets/a53x-A536EXXSNGZG3/chain.c \
  src/targets/a53x-A536EXXSNGZG3/ghostlock.c \
  src/targets/a53x-A536EXXSNGZG3/page.c
override PRELOAD_SRCS := $(APP_PRELOAD_SRCS)
override APP_RELEASE_OPT := -O2
override APP_RELEASE_LINK_FLAGS := -Wl,--gc-sections -Wl,--icf=all -s
endif

COMMON_CFLAGS := \
  -O2 -g0 -Wall -Wextra \
  -Wno-unused-parameter -Wno-sign-compare \
  -Isrc -DTARGET_HEADER='"$(TARGET_INCLUDE)"' \
  $(TARGET_CFLAGS)
# Freeze CLI-overridable flags (already $--checked above) so later uses
# cannot re-expand them.
override TARGET_CFLAGS := $(value TARGET_CFLAGS)
override APP_TARGET_CFLAGS := $(value APP_TARGET_CFLAGS)
override COMMON_CFLAGS := $(value COMMON_CFLAGS)

.DEFAULT_GOAL := all

.PHONY: all clean distclean info release stable help

# Portable file size check (works on GNU + BSD/macOS): wc -c instead of stat -c %s.
# Truncate may be GNU-only; fall back to python3 to pad with zeros.

all: $(PRELOAD) $(APP_PRELOAD) $(ROOT_HELPER)

release: $(APP_RELEASE)

stable: $(APP_STABLE)

$(OUTDIR):
	mkdir -p -- "$@"

$(PRELOAD): $(PRELOAD_SRCS) $(TARGET_HEADER) src/offset.h src/common.h src/kernelsnitch/*.h | $(OUTDIR)
	"$(TARGET_CC)" -fPIC $(COMMON_CFLAGS) $(PRELOAD_SRCS) \
	  -shared -pthread -o "$@"

$(ROOT_HELPER): src/su_daemon.c | $(OUTDIR)
	"$(TARGET_CC)" -fPIE -pie -O2 -g0 -Wall -Wextra "$<" -ldl -o "$@"

$(APP_PRELOAD): $(APP_PRELOAD_SRCS) $(TARGET_HEADER) src/offset.h src/common.h src/kernelsnitch/*.h | $(OUTDIR)
	"$(TARGET_CC)" -DAPP_PAYLOAD=1 $(APP_TARGET_CFLAGS) -fPIC $(COMMON_CFLAGS) $(APP_PRELOAD_SRCS) \
	  -shared -pthread -o "$@"

$(APP_RELEASE): $(APP_PRELOAD_SRCS) $(TARGET_HEADER) src/offset.h src/common.h src/kernelsnitch/*.h | $(OUTDIR)
	"$(TARGET_CC)" -DAPP_PAYLOAD=1 $(APP_TARGET_CFLAGS) -fPIC $(APP_RELEASE_OPT) -g0 \
	  -fno-unwind-tables -fno-asynchronous-unwind-tables \
	  -ffunction-sections -fdata-sections \
	  -Wall -Wextra -Wno-unused-parameter -Wno-sign-compare \
	  -Isrc -DTARGET_HEADER='"$(TARGET_INCLUDE)"' \
	  $(TARGET_CFLAGS) \
	  $(APP_PRELOAD_SRCS) -shared -pthread \
	  $(APP_RELEASE_LINK_FLAGS) -o "$@"
	@test $$(wc -c < "$@") -le $(APP_RELEASE_SIZE) || { echo "error: $@ exceeds $(APP_RELEASE_SIZE) bytes" >&2; exit 1; }
	@python3 -c "import sys; p=sys.argv[1]; n=int(sys.argv[2]); d=open(p,'rb').read(); open(p,'ab').write(b'\0'*(n-len(d)) if len(d)<n else b'')" "$@" $(APP_RELEASE_SIZE)

$(APP_STABLE): $(APP_PRELOAD_SRCS) $(TARGET_HEADER) src/offset.h src/common.h src/kernelsnitch/*.h | $(OUTDIR)
	"$(TARGET_CC)" -DAPP_PAYLOAD=1 -DAPP_S928_STABLE_RACE=1 $(APP_TARGET_CFLAGS) \
	  -fPIC -Oz -g0 -fvisibility=hidden -fno-semantic-interposition \
	  -fstack-protector-strong \
	  -fno-unwind-tables -fno-asynchronous-unwind-tables \
	  -ffunction-sections -fdata-sections \
	  -Wall -Wextra -Wno-unused-parameter -Wno-sign-compare \
	  -Isrc -DTARGET_HEADER='"$(TARGET_INCLUDE)"' \
	  $(APP_PRELOAD_SRCS) -shared -pthread \
	  -Wl,--gc-sections -Wl,--icf=all -s -o "$@"
	@test $$(wc -c < "$@") -le $(APP_RELEASE_SIZE) || { echo "error: $@ exceeds $(APP_RELEASE_SIZE) bytes" >&2; exit 1; }
	@python3 -c "import sys; p=sys.argv[1]; n=int(sys.argv[2]); d=open(p,'rb').read(); open(p,'ab').write(b'\0'*(n-len(d)) if len(d)<n else b'')" "$@" $(APP_RELEASE_SIZE)

info:
	@echo "TARGET=$(TARGET)"
	@echo "APP_TARGET_CFLAGS=$(APP_TARGET_CFLAGS)"
	@echo "TARGET_CC=$(TARGET_CC)"
	@echo "PRELOAD=$(PRELOAD)"
	@echo "APP_PRELOAD=$(APP_PRELOAD)"
	@echo "APP_RELEASE=$(APP_RELEASE)"
	@echo "APP_STABLE=$(APP_STABLE)"
	@echo "ROOT_HELPER=$(ROOT_HELPER)"

clean:
	rm -rf -- "$(OUTDIR)"

distclean:
	rm -rf -- build

help:
	@echo "Targets: all release stable clean distclean info help"
	@echo "  TARGET=<profile> (default: $(TARGET))  API=<level> (default: $(API))"
	@echo "  OUTDIR=<dir> (default: build/\$$(TARGET))"

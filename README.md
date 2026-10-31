# bc250-acpi-fix

ACPI table overrides for the ASRock AMD BC-250 on BIOS P3.00. They restore CPU P-states and C-states on Linux.

Forked from [bc250-collective/bc250-acpi-fix](https://github.com/bc250-collective/bc250-acpi-fix).

## Problems

The DSDT declares the CPUs as `\_PR.P000` to `\_PR.P00B`.

* **No P-states.** The firmware has no usable `_PSS`, so `acpi-cpufreq` has no frequency table.
* **No deep C-states.** The firmware "AMD CPU" SSDT puts `_CST` and `_CSD` on `\_PR.C000` to `\_PR.C00B`, which do not exist.
  The table fails to load with 12 `AE_NOT_FOUND` errors at boot. Without `_CST`, cpuidle has no driver and cores never enter CC6.

## Tables

| File | Signature / OEM ID / table ID | Effect |
|---|---|---|
| `SSDT-PST.dsl` | `SSDT` / `HACK` / `PSTATES` | Adds `_PCT`, `_PSS` and `_PSD` with 8 P-states (3200 to 800 MHz) to `P000` to `P00B`. |
| `SSDT-CST.dsl` | `SSDT` / `AMD` / `AMD CPU`, OEM revision 2 | Replaces the broken firmware table with the same `_CST` and `_CSD`, scoped to `P000` to `P00B`. |

`SSDT-PST` is added as a new table. Its `_PSS` frequencies match the P-state MSRs `0xC0010064` to `0xC001006B` on the board.

`SSDT-CST` replaces the firmware table. The kernel substitutes an initrd table with the same signature, OEM ID and OEM table ID if its OEM revision is higher.
The values are copied unchanged from the firmware table:

* C1: FFH MWAIT, 1 µs latency.
* C2: I/O read of port `0x414`, 400 µs latency. `CStateAddr` (MSR `0xC0010073`) is `0x413`, so this port enters CC6.

The upstream `SSDT-CST` added a second table with `\_PR.C00x` aliases. The firmware table loads before any initrd table, so the aliases did not fix the errors.
Its extra C3 on port `0x415` entered the same CC6 as C2: `CStateConfig` (MSR `0xC0010296`) is `0x484848`, so all three C-state control registers are identical.

## Build

```bash
iasl -p SSDT-PST SSDT-PST.dsl
iasl -p SSDT-CST SSDT-CST.dsl
```

The committed `.aml` files are built from these sources.

## Install

Pack both tables into an uncompressed cpio and load it before the main initrd:

```bash
mkdir -p kernel/firmware/acpi
cp SSDT-PST.aml SSDT-CST.aml kernel/firmware/acpi/
find kernel | cpio -H newc --create > acpi_override.cpio
```

On NixOS, add the cpio to `boot.initrd.prepend`.
On other distributions, copy it to `/boot` and list it before the main initrd in the boot loader entry.

Use `acpi-cpufreq`: add `amd_pstate=disable` to the kernel command line. The firmware has no `_CPC`.

## Check

```bash
sudo dmesg | grep -E "Table Upgrade|AE_NOT_FOUND"
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver               # acpi-cpufreq
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
cat /sys/devices/system/cpu/cpuidle/current_driver                    # acpi_idle
grep . /sys/devices/system/cpu/cpu0/cpuidle/state*/{name,desc,usage}
```

`dmesg` should show `override [SSDT- AMD- AMD CPU]` and `install [SSDT- HACK- PSTATES]`, with no `AE_NOT_FOUND` errors.

If CC6 causes instability, add `processor.max_cstate=1` to the kernel command line to keep C1 only.

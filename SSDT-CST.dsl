/*
 * Replacement for the BC-250 P3.00 firmware "AMD CPU" SSDT.
 *
 * The firmware table puts _CST/_CSD on \_PR.C000..C00B, but the DSDT names
 * the processors \_PR.P000..P00B, so the whole table fails to load
 * (AE_NOT_FOUND) and the kernel gets no C-states beyond MWAIT C1.
 *
 * Same signature, OEM ID and OEM table ID as the firmware table, so the
 * kernel's initrd table upgrade replaces it instead of adding a second copy.
 * C-state values are copied unchanged from the firmware table:
 *   C1: FFH MWAIT, 1 us
 *   C2: I/O read of 0x414 (CStateAddr MSR 0xC0010073 = 0x413, +1 = CC6), 400 us
 * _CSD groups SMT siblings by core (domain = core index).
 */
DefinitionBlock ("", "SSDT", 1, "AMD", "AMD CPU", 0x00000002)
{
    External (\_PR.P000, ProcessorObj)
    External (\_PR.P001, ProcessorObj)
    External (\_PR.P002, ProcessorObj)
    External (\_PR.P003, ProcessorObj)
    External (\_PR.P004, ProcessorObj)
    External (\_PR.P005, ProcessorObj)
    External (\_PR.P006, ProcessorObj)
    External (\_PR.P007, ProcessorObj)
    External (\_PR.P008, ProcessorObj)
    External (\_PR.P009, ProcessorObj)
    External (\_PR.P00A, ProcessorObj)
    External (\_PR.P00B, ProcessorObj)

    Scope (\_PR)
    {
        Name (CSTP, Package (0x03)
        {
            0x02,
            Package (0x04)
            {
                ResourceTemplate ()
                {
                    Register (FFixedHW, 0x02, 0x02, 0x0000000000000000, ,)
                },
                0x01,
                0x0001,
                0x00000000
            },
            Package (0x04)
            {
                ResourceTemplate ()
                {
                    Register (SystemIO, 0x08, 0x00, 0x0000000000000414, 0x01, )
                },
                0x02,
                0x0190,
                0x00000000
            }
        })
    }

    Scope (\_PR.P000) { Method (_CST) { Return (\_PR.CSTP) } Name (_CSD, Package () { Package () { 0x06, 0x00, 0x00, 0xFE, 0x02, 0x00 } }) }
    Scope (\_PR.P001) { Method (_CST) { Return (\_PR.CSTP) } Name (_CSD, Package () { Package () { 0x06, 0x00, 0x00, 0xFE, 0x02, 0x00 } }) }
    Scope (\_PR.P002) { Method (_CST) { Return (\_PR.CSTP) } Name (_CSD, Package () { Package () { 0x06, 0x00, 0x01, 0xFE, 0x02, 0x00 } }) }
    Scope (\_PR.P003) { Method (_CST) { Return (\_PR.CSTP) } Name (_CSD, Package () { Package () { 0x06, 0x00, 0x01, 0xFE, 0x02, 0x00 } }) }
    Scope (\_PR.P004) { Method (_CST) { Return (\_PR.CSTP) } Name (_CSD, Package () { Package () { 0x06, 0x00, 0x02, 0xFE, 0x02, 0x00 } }) }
    Scope (\_PR.P005) { Method (_CST) { Return (\_PR.CSTP) } Name (_CSD, Package () { Package () { 0x06, 0x00, 0x02, 0xFE, 0x02, 0x00 } }) }
    Scope (\_PR.P006) { Method (_CST) { Return (\_PR.CSTP) } Name (_CSD, Package () { Package () { 0x06, 0x00, 0x03, 0xFE, 0x02, 0x00 } }) }
    Scope (\_PR.P007) { Method (_CST) { Return (\_PR.CSTP) } Name (_CSD, Package () { Package () { 0x06, 0x00, 0x03, 0xFE, 0x02, 0x00 } }) }
    Scope (\_PR.P008) { Method (_CST) { Return (\_PR.CSTP) } Name (_CSD, Package () { Package () { 0x06, 0x00, 0x04, 0xFE, 0x02, 0x00 } }) }
    Scope (\_PR.P009) { Method (_CST) { Return (\_PR.CSTP) } Name (_CSD, Package () { Package () { 0x06, 0x00, 0x04, 0xFE, 0x02, 0x00 } }) }
    Scope (\_PR.P00A) { Method (_CST) { Return (\_PR.CSTP) } Name (_CSD, Package () { Package () { 0x06, 0x00, 0x05, 0xFE, 0x02, 0x00 } }) }
    Scope (\_PR.P00B) { Method (_CST) { Return (\_PR.CSTP) } Name (_CSD, Package () { Package () { 0x06, 0x00, 0x05, 0xFE, 0x02, 0x00 } }) }
}

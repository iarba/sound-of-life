.global mailbox_read
.global mailbox_write

@ ------------------------------------------------------------------------------
@ Mailbox Base Address
@ ------------------------------------------------------------------------------

.equ MAILBOX_BASE,        0x2000B880

@ ------------------------------------------------------------------------------
@ Reads a value from the mailbox
@
@ Arguments:
@   r0 - channel
@ Returns:
@   r0 
@ Clobbers:
@   none
@ ------------------------------------------------------------------------------

mailbox_read:
        stmfd      sp!, {r1 - r3}

        cmp        r0, #15
        movhi      pc, lr

        channel    .req r0
        mailbox    .req r1
 
	ldr        r1, =MAILBOX_BASE
	
wait1: 
        status     .req r2
        ldr        status, [mailbox, #0x18]

        tst        status, #0x40000000
        .unreq     status
        bne        wait1
        
        mail       .req r2
        ldr        mail, [mailbox, #0]

	curr       .req r3
        and        curr, mail, #0b1111
        teq        curr, channel
        .unreq     curr

        bne        wait1
        .unreq     mailbox
        .unreq     channel

        and        r0, mail, #0xfffffff0
        .unreq     mail

        ldmfd      sp!, {r1 - r3}

        mov        pc, lr
@ ------------------------------------------------------------------------------
@ Writes a value to the mailbox
@
@ Arguments:
@   r0 - data
@   r1 - channel
@ Returns:
@   none
@ Clobbers:
@   none
@ ------------------------------------------------------------------------------
    
mailbox_write:
        stmfd      sp!, {r2 - r3}

	tst        r0, #0b1111
        movne      pc, lr

        cmp        r1, #15
        movhi      pc, lr
    
        value      .req r0
        channel    .req r1
        mailbox    .req r2

	ldr        mailbox, =MAILBOX_BASE
        
wait2: 
        status     .req r3
        ldr        status, [mailbox, #0x18]
        tst        status, #0x80000000
        .unreq     status
        bne        wait2

        add        value, channel
        .unreq     channel

	str        value, [mailbox, #0x20]
        .unreq     value
        .unreq     mailbox

        ldmfd      sp!, {r2 - r3}

	mov        pc, lr

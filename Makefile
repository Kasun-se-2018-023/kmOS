    OBJECTS = loader.o kmain.o src/drivers/io/io.o src/drivers/frame_buffer/frame_buffer.o src/drivers/serial_port/serial_port.o src/memory/segmentation/gdt.o src/memory/segmentation/gdt_asm.o src/utils/common/helpers.o src/drivers/interrupts/idt.o src/drivers/interrupts/idt_asm.o src/drivers/interrupts/isr.o src/drivers/interrupts/isr_asm.o src/utils/logger/logger.o src/drivers/timer/timer.o src/drivers/interrupts/keyboard.o src/memory/heap/kheap.o src/memory/paging/paging.o src/memory/paging_enable.o src/utils/array/ordered_array.o src/memory/sched/sched.o src/memory/sched/sched_asm.o
    CC = gcc
    CFLAGS = -m32 -nostdlib -nostdinc -fno-builtin -fno-stack-protector \
             -nostartfiles -nodefaultlibs -Wall -Wextra -Werror -c
    LDFLAGS = -T link.ld -melf_i386
    AS = nasm
    ASFLAGS = -f elf

    all: kernel.elf

    kernel.elf: $(OBJECTS)
	ld $(LDFLAGS) $(OBJECTS) -o kernel.elf

    kmOS.iso: kernel.elf
	cp kernel.elf iso/boot/kernel.elf
	genisoimage -R                              \
                    -b boot/grub/stage2_eltorito    \
                    -no-emul-boot                   \
                    -boot-load-size 4               \
                    -A os                           \
                    -input-charset utf8             \
                    -quiet                          \
                    -boot-info-table                \
                    -o kmOS.iso                       \
                    iso

    run: kmOS.iso
	bochs -f bochsrc.txt -q

    %.o: %.c
	$(CC) $(CFLAGS)  $< -o $@

    %.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

    clean:
	rm -rf *.o kernel.elf kmOS.iso

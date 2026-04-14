/*
 * usb-reset.c — Reset a USB device via USBDEVFS_RESET ioctl.
 *
 * Usage:  usb-reset /dev/bus/usb/BUS/DEV
 *
 * Performs a USB port reset on the specified device, forcing the controller
 * to re-enumerate it.  This clears any stale hardware state left by a
 * previous driver (e.g. dvb_usb_rtl28xxu) or an unclean process exit.
 *
 * Typical use:  after sysfs-unbinding an RTL-SDR from the DVB kernel
 * driver, run  usb-reset  on each Realtek 2832U device so that librtlsdr
 * can open a chip whose demodulator registers are in a known-good state.
 */

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <linux/usbdevice_fs.h>

int main(int argc, char **argv)
{
    if (argc != 2) {
        fprintf(stderr, "Usage: %s /dev/bus/usb/BUS/DEV\n", argv[0]);
        return 1;
    }

    int fd = open(argv[1], O_WRONLY);
    if (fd < 0) {
        fprintf(stderr, "usb-reset: cannot open %s: %s\n",
                argv[1], strerror(errno));
        return 1;
    }

    if (ioctl(fd, USBDEVFS_RESET, 0) < 0) {
        fprintf(stderr, "usb-reset: USBDEVFS_RESET failed on %s: %s\n",
                argv[1], strerror(errno));
        close(fd);
        return 1;
    }

    close(fd);
    return 0;
}

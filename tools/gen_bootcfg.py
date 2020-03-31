#!/usr/bin/env python

import argparse
import os
import sys
from binascii import unhexlify


def long_to_bytes(val, endianness='big'):
    """
    Use :ref:`string formatting` and :func:`~binascii.unhexlify` to
    convert ``val``, a :func:`long`, to a byte :func:`str`.

    :param long val: The value to pack

    :param str endianness: The endianness of the result. ``'big'`` for
      big-endian, ``'little'`` for little-endian.

    """

    # fixed width (always 4 bytes)
    width = 8

    # format width specifier: four (4) bits per hex digit
    fmt = '%%0%dx' % (width)

    # prepend zero (0) to the width, to zero-pad the output
    s = unhexlify(fmt % val)

    if endianness == 'little':
        s = s[::-1]  # reverse bytes (using extended slice syntax)

    return s


def padpartion(args, size, partSize, zeros=False):
    """
    Pad give partition up to give size (default 0xFF)
    """

    while True:
        if size < partSize:
            if True == zeros:
                args.output.write(b'\x00')
            else:
                args.output.write(b'\xFF')
            size += 1
        else:
            break  # while loop

    return size

def gen_bootcfg_img(args):
    """
    Boot config partition must contain a header defined in the following structure:

    #define BOOTCFG_VERSION_LEN   128
    #define BOOTCFG_IMG_MAGIC     0x12345678

    typedef struct bootcfg_img_info {
        uint32_t count; /* image count - version */
        uint8_t version[BOOTCFG_VERSION_LEN]; /* image version */
        uint32_t badcount_thrld; /* badcount threshold */
        uint8_t skip; /* mark skip image, if badcount threshold reached */
        uint8_t ignore_skip; /* mark to ignore the skip image flag, even if it is set */
        uint8_t _res[114]; /* aligning structure to 256 bytes */
        uint32_t magic; /* magic */
    } __attribute__ ((packed)) bootcfg_img_info;

    """

    size = 0

    # count
    args.output.write(long_to_bytes(args.img_cnt, endianness='little'))
    size += 4

    # version
    args.output.write(args.version)
    padpartion(args, size, size+128-len(args.version), zeros=True)
    size += 128

    # badcount threshold
    args.output.write(long_to_bytes(args.badcnt_thrld, endianness='little'))
    size += 4

    # skip
    args.output.write(b'\xff')
    size += 1

    # ignore skip
    args.output.write(b'\xff')
    size += 1

    # reserved - 114 bytes
    for x in range(0, 114):
        args.output.write(b'\xff')
        size += 1  # 4 bytes

    # magic
    args.output.write(long_to_bytes(int('0x12345678', 16), endianness='little'))
    size += 4

    padpartion(args, size, 64*1024)

    return 0


USAGE = '''
    %(prog)s [options]
    options:
        --file/-f <path>            Destination bootcfg image
        --img_cnt/-c <num>          Image count to write into header
        --version/-v <string>       Version string to write into header
        --badcnt_thrld/-b <thrld>   Bad count threshold
      '''


def main():

    parser = argparse.ArgumentParser(usage=USAGE)

    parser.add_argument('--file', '-f',
        dest='file', action='store', required=True,
        help='Destination bootcfg image')
    parser.add_argument('--img_cnt', '-c', type=int,
        dest='img_cnt', action='store', required=True,
        help='Image count to write into header')
    parser.add_argument('--version', '-v',
        dest='version', action='store', required=True,
        help='Version string to write into header')
    parser.add_argument('--badcnt_thrld', '-b', type=int,
        dest='badcnt_thrld', action='store', required=True,
        help='Bad count threshold')

    args = parser.parse_args()

    args.output = open(args.file, "wb")
    gen_bootcfg_img(args)
    args.output.close()

    return 0


if __name__ == "__main__":
    main()

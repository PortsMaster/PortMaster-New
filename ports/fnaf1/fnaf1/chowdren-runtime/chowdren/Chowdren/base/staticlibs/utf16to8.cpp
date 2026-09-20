/*
 * Copyright 2001-2004 Unicode, Inc.
 *
 * Disclaimer
 *
 * This source code is provided as is by Unicode, Inc. No claims are
 * made as to fitness for any particular purpose. No warranties of any
 * kind are expressed or implied. The recipient agrees to determine
 * applicability of information provided. If this file has been
 * purchased on magnetic or optical media from Unicode, Inc., the
 * sole remedy for any claim will be exchange of defective media
 * within 90 days of receipt.
 *
 * Limitations on Rights to Redistribute This Code
 *
 * Unicode, Inc. hereby grants the right to freely use the information
 * supplied in this file in the creation of products supporting the
 * Unicode Standard, and to make copies of this file in any form
 * for internal or external distribution as long as this notice
 * remains attached.
 */

#include "utf16to8.h"

typedef unsigned long   UTF32;  /* at least 32 bits */
typedef unsigned short  UTF16;  /* at least 16 bits */
typedef unsigned char   UTF8;   /* typically 8 bits */

#define UNI_SUR_HIGH_START  (UTF32)0xD800
#define UNI_SUR_HIGH_END    (UTF32)0xDBFF
#define UNI_SUR_LOW_START   (UTF32)0xDC00
#define UNI_SUR_LOW_END     (UTF32)0xDFFF
#define UNI_REPLACEMENT_CHAR (UTF32)0x0000FFFD

static const int halfShift  = 10; /* used for shifting by 10 bits */
static const UTF32 halfBase = 0x0010000UL;
static const UTF32 halfMask = 0x3FFUL;
static const UTF8 firstByteMark[7] = { 0x00, 0x00, 0xC0, 0xE0, 0xF0, 0xF8,
                                       0xFC };

typedef enum {
  conversionOK,           /* conversion successful */
  sourceExhausted,        /* partial character in source, but hit end */
  targetExhausted,        /* insuff. room in target for conversion */
  sourceIllegal           /* source sequence is illegal/malformed */
} ConversionResult;

void convert_utf16_to_utf8(const std::string & value, std::string & out)
{
    out.resize((value.size() / 2) * 4);

    const UTF16* source = (UTF16*)&value[0];
    if (value.size() >= 2 && (unsigned char)value[0] == 0xFF
        && (unsigned char)value[1] == 0xFE)
    {
        source++;
    }

    UTF16 * sourceEnd = (UTF16*)(&value[0] + value.size());
    UTF8* target = (UTF8*)&out[0];
    UTF8* targetEnd = (UTF8*)(&out[0] + out.size());

    ConversionResult result = conversionOK;
    while (source < sourceEnd) {
        UTF32 ch;
        unsigned short bytesToWrite = 0;
        const UTF32 byteMask = 0xBF;
        const UTF32 byteMark = 0x80;
        /* In case we have to back up because of target overflow. */
        const UTF16* oldSource = source;
        ch = *source++;
        /* If we have a surrogate pair, convert to UTF32 first. */
        if (ch >= UNI_SUR_HIGH_START && ch <= UNI_SUR_HIGH_END) {
            /* If the 16 bits following the high surrogate are in the source
               buffer... */
            if (source < sourceEnd) {
                UTF32 ch2 = *source;
                /* If it's a low surrogate, convert to UTF32. */
                if (ch2 >= UNI_SUR_LOW_START && ch2 <= UNI_SUR_LOW_END) {
                    ch = ((ch - UNI_SUR_HIGH_START) << halfShift)
                        + (ch2 - UNI_SUR_LOW_START) + halfBase;
                    ++source;
                }
            } else { /* We don't have the 16 bits following the high
                        surrogate. */
                --source; /* return to the high surrogate */
                result = sourceExhausted;
                break;
            }
        }
        /* Figure out how many bytes the result will require */
        if (ch < (UTF32)0x80) {      bytesToWrite = 1;
        } else if (ch < (UTF32)0x800) {     bytesToWrite = 2;
        } else if (ch < (UTF32)0x10000) {   bytesToWrite = 3;
        } else if (ch < (UTF32)0x110000) {  bytesToWrite = 4;
        } else {                bytesToWrite = 3;
                                            ch = UNI_REPLACEMENT_CHAR;
        }

        target += bytesToWrite;
        if (target > targetEnd) {
            source = oldSource; /* Back up source pointer! */
            target -= bytesToWrite; result = targetExhausted; break;
        }
        switch (bytesToWrite) { /* note: everything falls through. */
            case 4: *--target = (UTF8)((ch | byteMark) & byteMask); ch >>= 6;
            case 3: *--target = (UTF8)((ch | byteMark) & byteMask); ch >>= 6;
            case 2: *--target = (UTF8)((ch | byteMark) & byteMask); ch >>= 6;
            case 1: *--target =  (UTF8)(ch | firstByteMark[bytesToWrite]);
        }
        target += bytesToWrite;
    }
    out.resize(size_t(targetEnd - target));
    // return result;
}

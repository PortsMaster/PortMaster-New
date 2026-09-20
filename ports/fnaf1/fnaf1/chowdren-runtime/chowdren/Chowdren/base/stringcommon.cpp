#include <limits>
#include <string>
#include <stdio.h>

#define AT_END() (p >= end)
#define INCREMENT_PTR() if (++p >= end) goto parse_end
#define IS_WHITESPACE(c) (((c) == ' ' || (c) == '\t'))
#define IS_DIGIT(c) ((c) >= '0' && (c) <= '9')

double fast_atof(const char * p, const char * end)
{
    if (AT_END())
        return 0.0;

    int frac = 0;
    double sign = 1.0;
    double value = 0.0;
    double scale = 1.0;

    // Skip leading white space, if any.

    while (IS_WHITESPACE(*p)) {
        INCREMENT_PTR();
    }

    // Get sign, if any.
    if (*p == '-') {
        sign = -1.0;
        INCREMENT_PTR();
    } else if (*p == '+') {
        INCREMENT_PTR();
    }

    // Get digits before decimal point or exponent, if any.

    while (IS_DIGIT(*p)) {
        value = value * 10.0 + (*p - '0');
        INCREMENT_PTR();
    }

    // Get digits after decimal point, if any.

    if (*p == '.') {
        double pow10 = 10.0;
        p += 1;
        while (IS_DIGIT(*p)) {
            value += (*p - '0') / pow10;
            pow10 *= 10.0;
            INCREMENT_PTR();
        }
    }

    // Handle exponent, if any.
    if ((*p == 'e') || (*p == 'E')) {
        unsigned int expon = 0;

        // Get sign of exponent, if any.

        INCREMENT_PTR();
        if (*p == '-') {
            frac = 1;
            INCREMENT_PTR();
        } else if (*p == '+') {
            INCREMENT_PTR();
        }

        // Get digits of exponent, if any.

        while (IS_DIGIT(*p)) {
            expon = expon * 10 + (*p - '0');
            p++;
            if (AT_END())
                break;
        }
        if (expon > 308) expon = 308;

        // Calculate scaling factor.
        while (expon >= 50) { scale *= 1E50; expon -= 50; }
        while (expon >=  8) { scale *= 1E8;  expon -=  8; }
        while (expon >   0) { scale *= 10.0; expon -=  1; }
    }

    // Return signed and scaled floating point result.

parse_end:
    return sign * (frac ? (value / scale) : (value * scale));
}

const char DIGITS[] =
    "0001020304050607080910111213141516171819"
    "2021222324252627282930313233343536373839"
    "4041424344454647484950515253545556575859"
    "6061626364656667686970717273747576777879"
    "8081828384858687888990919293949596979899";

std::string fast_itoa(int value)
{
    enum {BUFFER_SIZE = 16};
    char buffer[BUFFER_SIZE];
    char *str;

    unsigned int abs_value = static_cast<unsigned int>(value);
    bool negative = value < 0;
    if (negative)
      abs_value = 0 - abs_value;

    char *buffer_end = buffer + BUFFER_SIZE - 1;
    while (abs_value >= 100) {
        // Integer division is slow so do it for a group of two digits instead
        // of for every digit. The idea comes from the talk by Alexandrescu
        // "Three Optimization Tips for C++". See speed-test for a comparison.
        unsigned index = (abs_value % 100) * 2;
        abs_value /= 100;
        *--buffer_end = DIGITS[index + 1];
        *--buffer_end = DIGITS[index];
    }
    if (abs_value < 10) {
      *--buffer_end = static_cast<char>('0' + abs_value);
    } else {
        unsigned index = static_cast<unsigned>(abs_value * 2);
        *--buffer_end = DIGITS[index + 1];
        *--buffer_end = DIGITS[index];
    }

    str = buffer_end;

    if (negative)
      *--buffer_end = '-';

    return std::string(buffer_end, buffer - buffer_end + BUFFER_SIZE - 1);
}

std::string fast_lltoa(long long value)
{
    enum {BUFFER_SIZE = 24};
    char buffer[BUFFER_SIZE];
    char *str;

    unsigned long long abs_value = static_cast<unsigned long long>(value);
    bool negative = value < 0;
    if (negative)
      abs_value = 0 - abs_value;

    char *buffer_end = buffer + BUFFER_SIZE - 1;
    while (abs_value >= 100) {
        // Integer division is slow so do it for a group of two digits instead
        // of for every digit. The idea comes from the talk by Alexandrescu
        // "Three Optimization Tips for C++". See speed-test for a comparison.
        unsigned index = (abs_value % 100) * 2;
        abs_value /= 100;
        *--buffer_end = DIGITS[index + 1];
        *--buffer_end = DIGITS[index];
    }
    if (abs_value < 10) {
      *--buffer_end = static_cast<char>('0' + abs_value);
    } else {
        unsigned index = static_cast<unsigned>(abs_value * 2);
        *--buffer_end = DIGITS[index + 1];
        *--buffer_end = DIGITS[index];
    }

    str = buffer_end;

    if (negative)
      *--buffer_end = '-';

    return std::string(buffer_end, buffer - buffer_end + BUFFER_SIZE - 1);
}

std::string fast_dtoa(double value)
{
    char buffer[16];

    /* if input is larger than thres_max, revert to exponential */
    const double thres_max = (double)(0x7FFFFFFF);

    /* we'll work in positive values and deal with the
       negative sign issue later */
    int neg = 0;
    if (value < 0) {
        neg = 1;
        value = -value;
    }

    /* for very large numbers switch back to native sprintf for exponentials.
       anyone want to write code to replace this? */
    /*
      normal printf behavior is to print EVERY whole number digit
      which can be 100s of characters overflowing your buffers == bad
    */
    if (value > thres_max) {
        sprintf(&buffer[0], "%e", neg ? -value : value);
        return std::string(buffer);
    }

    char* wstr = &buffer[15];
    int whole = (int) value;
    double tmp = (value - whole) * 100000;
    unsigned int frac = (unsigned int)(tmp);
    double diff = tmp - frac;

    if (diff > 0.5) {
        ++frac;
        /* handle rollover, e.g.  case 0.99 with prec 1 is 1.0  */
        if (frac >= 100000) {
            frac = 0;
            ++whole;
        }
    } else if (diff == 0.5 && ((frac == 0) || (frac & 1))) {
        /* if halfway, round up if odd, OR
           if last digit is 0.  That last part is strange */
        ++frac;
    }

    int count = 5;
    /* now do fractional part, as an unsigned number */
    bool write = false;
    do {
        --count;
        char c = frac % 10;
        if (!write) {
            if (c == 0)
                continue;
            write = true;
        }
        *wstr-- = c + 48;
    } while (frac /= 10);

    if (write) {
        /* add extra 0s */
        while (count-- > 0)
            *wstr-- = '0';
        /* add decimal */
        *wstr-- = '.';
    }

    /* do whole part
     * Take care of sign
     * Conversion. Number is reversed.
     */
    do
        *wstr-- = (char)(48 + (whole % 10));
    while (whole /= 10);
    if (neg) {
        *wstr-- = '-';
    }
    return std::string(wstr + 1, &buffer[15] - wstr);
}

int fast_atoi(const std::string & src)
{
    if (src.empty())
        return 0;
    const char * p = &src[0];
    const char * end = p + src.size();
    int value = 0;
    int sign = 1;

    while (IS_WHITESPACE(*p) || *p == '0') {
        INCREMENT_PTR();
    }

    switch (*p) {
        case '-':
            sign = -1;
            INCREMENT_PTR();
            break;
        case '+':
            INCREMENT_PTR();
            break;
        default:
            break;
    }

    while (IS_DIGIT(*p)) {
        value = value * 10 + (*p - '0');
        INCREMENT_PTR();
    }

parse_end:
    return value * sign;
}

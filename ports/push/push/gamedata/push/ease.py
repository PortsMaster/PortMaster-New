import math

# Linear
def linear(t):
    return t

# Sine
def sine_i(t):
    return 1.0 - math.cos((t * math.pi) / 2.0)

def sine_o(t):
    return math.sin((t * math.pi) / 2.0)

def sine_io(t):
    return -(math.cos(math.pi * t) - 1.0) / 2.0

# Quad
def quad_i(t):
    return t * t

def quad_o(t):
    return 1.0 - (1.0 - t) * (1.0 - t)

def quad_io(t):
    return 2.0 * t * t if t < 0.5 else 1.0 - math.pow(-2.0 * t + 2.0, 2.0) / 2.0

# Cubic
def cubic_i(t):
    return t * t * t

def cubic_o(t):
    return 1.0 - math.pow(1.0 - t, 3.0)

def cubic_io(t):
    return 4.0 * t * t * t if t < 0.5 else 1 - math.pow(-2.0 * t + 2.0, 3.0) / 2.0


# Quart
def quart_i(t):
    return t * t * t * t

def quart_o(t):
    return 1.0 - math.pow(1.0 - t, 4.0)

def quart_io(t):
    return 8.0 * t * t * t * t if t < 0.5 else 1.0 - math.pow(-2.0 * t + 2.0, 4.0) / 2.0


# Quint
def quint_i(t):
    return t * t * t * t * t

def quint_o(t):
    return 1.0 - math.pow(1.0 - t, 5.0)

def quint_io(t):
    return 16.0 * t * t * t * t * t if t < 0.5 else 1.0 - math.pow(-2.0 * t + 2.0, 5) / 2.0


# Expo
def expo_i(t):
    return 0 if t == 0 else math.pow(2.0, 10.0 * t - 10.0)

def expo_o(t):
    return 1.0 if t == 1.0 else 1.0 - math.pow(2.0, -10.0 * t)

def expo_io(t):
    if t == 0:
        return 0
    elif t == 1.0:
        return 1.0
    elif t < 0.5:
        return math.pow(2.0, -20.0 * t + 10.0) / 2.0
    else:
        return (2.0 - math.pow(2.0, -20.0 * t + 10.0)) / 2.0


# Circ
def circ_i(t):
    return 1.0 - math.sqrt(1.0 - math.pow(t, 2.0))

def circ_o(t):
    return math.sqrt(1.0 - math.pow(t - 1.0, 2.0))

def circ_io(t):
    return (1.0 - math.sqrt(1.0 - math.pow(2.0 * t, 2.0))) / 2.0 if t < 0.5 else math.sqrt(1.0 - math.pow(-2.0 * t + 2.0, 2.0) + 1.0) / 2.0


# Back
def back_i(t):
    c1 = 1.70158
    c3 = c1 + 1.0
    return c3 * t * t * t - c1 * t * t

def back_o(t):
    c1 = 1.70158
    c3 = c1 + 1.0
    return 1.0 + c3 * math.pow(t - 1.0, 3.0) + c1 * math.pow(t - 1.0, 2.0)

def back_io(t):
    c1 = 1.79158
    c2 = c1 * 1.525
    return (math.pow(2.0 * t, 2.0) * ((c2 + 1.0) * 2.0 * t - c2)) / 2.0 if t < 0.5 else (math.pow(2.0 * t - 2.0, 2.0) * ((c2 + 1.0) * (t * 2.0 - 2.0) + c2) + 2.0) / 2.0


# Elastic
def elastic_i(t):
    amplitude = 1.0  # 振幅
    period = 0.3     # 周期
    if t == 0 or t == 1:
        return t
    s = period / (2 * math.pi) * math.asin(1 / amplitude)
    return -(amplitude * math.pow(2, 10 * (t - 1)) * math.sin((t - 1 - s) * (2 * math.pi) / period))

def elastic_o(t):
    amplitude = 1.0  # 振幅
    period = 0.3     # 周期
    if t == 0 or t == 1:
        return t
    s = period / (2 * math.pi) * math.asin(1 / amplitude)
    return amplitude * math.pow(2, -10 * t) * math.sin((t - s) * (2 * math.pi) / period) + 1

def elastic_io(t):
    amplitude = 1.0  # 振幅
    period = 0.45    # 周期
    if t == 0 or t == 1:
        return t
    s = period / (2 * math.pi) * math.asin(1 / amplitude)
    t *= 2
    if t < 1:
        return -0.5 * (amplitude * math.pow(2, 10 * (t - 1)) * math.sin((t - 1 - s) * (2 * math.pi) / period))
    else:
        t -= 1
        return 0.5 * (amplitude * math.pow(2, -10 * t) * math.sin((t - s) * (2 * math.pi) / period)) + 1


# Bounce
def bounce_i(t):
    return 1.0 - bounce_o(1.0 - t)

def bounce_o(t):
    n1 = 7.5625
    d1 = 2.75

    if t < 1.0 / d1:
        return n1 * t * t
    elif t < 2.0 / d1:
        t -= 1.5 / d1
        return n1 * t * t + 0.75
    elif t < 2.5 / d1:
        t -= 2.25 / d1
        return n1 * t * t + 0.9375
    else:
        t -= 2.625 / d1
        return n1 * t * t + 0.984375

def bounce_io(t):
    return (1.0 - bounce_o(1.0 - 2.0 * t)) / 2.0 if t < 0.5 else (1.0 + bounce_o(2.0 * t - 1)) / 2.0
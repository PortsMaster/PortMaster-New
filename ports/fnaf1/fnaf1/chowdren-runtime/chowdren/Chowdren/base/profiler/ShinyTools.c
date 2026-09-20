/*
The MIT License

Copyright (c) 2007-2010 Aidin Abedi http://code.google.com/p/shinyprofiler/

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#include "ShinyTools.h"


/*---------------------------------------------------------------------------*/

const ShinyTimeUnit* ShinyGetTimeUnit(float ticks) {
	static ShinyTimeUnit units[4] = { {0} };

	if (units[0].tickFreq == 0) { /* auto initialize first time */
		units[0].tickFreq = ShinyGetTickFreq() / 1.0f;
		units[0].invTickFreq = ShinyGetTickInvFreq() * 1.0f;
		units[0].suffix = "s";

		units[1].tickFreq = ShinyGetTickFreq() / 1000.0f;
		units[1].invTickFreq = ShinyGetTickInvFreq() * 1000.0f;
		units[1].suffix = "ms";

		units[2].tickFreq = ShinyGetTickFreq() / 1000000.0f;
		units[2].invTickFreq = ShinyGetTickInvFreq() * 1000000.0f;
		units[2].suffix = "us";

		units[3].tickFreq = ShinyGetTickFreq() / 1000000000.0f;
		units[3].invTickFreq = ShinyGetTickInvFreq() * 1000000000.0f;
		units[3].suffix = "ns";
	}

	// if (units[0].tickFreq < ticks) return &units[0];
	if (units[1].tickFreq < ticks)
		return &units[1];
	else if (units[2].tickFreq < ticks)
		return &units[2];
	else
		return &units[3];
}


/*---------------------------------------------------------------------------*/

#include "platform.h"

void ShinyGetTicks(shinytick_t * p)
{
	*p = platform_get_time();
}

shinytick_t ShinyGetTickFreq(void)
{
	return 1;
}

float ShinyGetTickInvFreq(void)
{
	return 1.0f;
}

#ifndef CHOWDREN_UTILITY_H
#define CHOWDREN_UTILITY_H

#include <stdlib.h>
#include "crossrand.h"
#include "platform.h"

namespace Utility
{

    inline bool Compare(float First, float Second, int ComparisonType)
    {
        switch(ComparisonType) {
            case 0:
                return First == Second;

            case 1:
                return First != Second;

            case 2:
                return First > Second;

            case 3:
                return First < Second;

            case 4:
                return First >= Second;

            case 5:
                return First <= Second;

            default:
                return false;
        };
    }


    inline void SetRandomSeed(int Seed)
    {
        cross_srand(Seed);
    }

    inline void SetRandomSeedToTimer()
    {
        cross_srand((unsigned int)platform_get_global_time());
    }

    // Useful Functions
    inline int Round(float Value)
    {
        return (Value > 0) ? (int)floor(Value + 0.5f) : (int)ceil(Value - 0.5f);
    }

    // Float Expressions
    inline float GenerateRandom(float Minimum, float Maximum)
    {
        return ((Maximum-Minimum)*((float)cross_rand()/CROSS_RAND_MAX))+Minimum;
    }
    inline float Limit(float Value, float Minimum, float Maximum)
    {
        if (Minimum < Maximum)
            return (Value < Minimum) ? (Minimum) : (Value > Maximum ? Maximum : Value);
            return (Value < Maximum) ? (Maximum) : (Value > Minimum ? Minimum : Value);
    }


    inline float Nearest(float Value, float Minimum, float Maximum)
    {
        return ((Minimum > Value) ? (Minimum - Value) : (Value - Minimum)) >
            ((Maximum > Value) ? (Maximum - Value) : (Value - Maximum)) ?
            Maximum : Minimum;
    }

    inline float Normalise(float Value, float Minimum, float Maximum, int LimitRange)
    {
        Value = (Value - Minimum) / (Maximum - Minimum);

        if (LimitRange != 0)
            return Limit(Value,0,1);
        return Value;
    }

    inline float ModifyRange(float Value, float Minimum, float Maximum, float NewMinimum, float NewMaximum, int LimitRange)
    {
        Value = NewMinimum + (Value - Minimum) * (NewMaximum - NewMinimum) / (Maximum - Minimum);

        if(LimitRange != 0) return Limit(Value,NewMinimum,NewMaximum);
        return Value;
    }

    inline float EuclideanMod(float Dividend, float Divisor)
    {
        return fmod((fmod(Dividend,Divisor)+Divisor),Divisor);
    }

    inline float UberMod(float Dividend, float Lower, float Upper)
    {
        return ModifyRange(EuclideanMod(Normalise(Dividend,Lower,Upper,0),1),0,1,Lower,Upper,0);
    }

    inline float Interpolate(float Value, float From, float To, int LimitRange)
    {
        Value = From+Value*(To-From);

        if(LimitRange != 0) return Limit(Value,From,To);
        return Value;
    }

    inline float Mirror(float Value, float From, float To)
    {
        if (From < To) {
            return From+fabs(EuclideanMod(Value-To,(To-From)*2)-(To-From));
        } else {
            return To+fabs(EuclideanMod(Value-From,(From-To)*2)-(From-To));
        }
    }

    inline float Wave(int Waveform, float Value, float CycleStart, float CycleEnd, float Minimum, float Maximum)
    {
        switch(Waveform)
        {
            case 0:
            {
                // Sine
                return ModifyRange(sin(ModifyRange(Value,CycleStart,CycleEnd,0,6.283185307179586476925286766559f,0)),-1,1,Minimum,Maximum,0);
            }

            case 1:
            {
                // Cosine
                return ModifyRange(cos(ModifyRange(Value,CycleStart,CycleEnd,0,6.283185307179586476925286766559f,0)),-1,1,Minimum,Maximum,0);
            }

            case 2:
            {
                // Saw
                return UberMod(ModifyRange(Value, CycleStart, CycleEnd, Minimum, Maximum, 0), Minimum, Maximum);
            }

            case 3:
            {
                // Inverted Saw
                return UberMod(ModifyRange(Value, CycleStart, CycleEnd, Maximum, Minimum, 0), Minimum, Maximum);
            }

            case 4:
            {
                // Triangle
                return Mirror(ModifyRange(Value, CycleStart, CycleStart+(CycleEnd-CycleStart)/2, Minimum, Maximum, 0), Minimum, Maximum);
            }

            case 5:
            {
                // Square
                if (UberMod(Value, CycleStart, CycleEnd) < CycleStart+(CycleEnd-CycleStart)/2) return Minimum; else return Maximum;
            }

            default:
            {
                // Non-existing waveform
                return 0;
            }
        };
    }

    inline float ExpressionCompare(float First, float Second, int ComparisonType, float ReturnIfTrue, float ReturnIfFalse)
    {
        if (Compare(First,Second,ComparisonType)) return ReturnIfTrue; else return ReturnIfFalse;
    }

    inline float Approach(float Value, float Amount, float Target)
    {
        return (Value<Target) ? std::min<float>(Value + Amount, Target) : std::max<float>(Value - Amount, Target);
    }

    // Integer versions of the float expressions
    inline int IntGenerateRandom(float Minimum, float Maximum)
    {
        return Round(GenerateRandom(Minimum,Maximum));
    }


    inline int IntLimit(float Value, float Minimum, float Maximum)
    {
        return Round(Limit(Value,Minimum,Maximum));
    }
    inline int IntNearest(float Value, float Minimum, float Maximum)
    {
        return Round(Nearest(Value,Minimum,Maximum));
    }
    inline int IntNormalise(float Value, float Minimum, float Maximum, int LimitRange)
    {
        return Round(Normalise(Value,Minimum,Maximum,LimitRange));
    }

    inline int IntModifyRange(float Value, float Minimum, float Maximum, float NewMinimum, float NewMaximum, int LimitRange)
    {
        return Round(ModifyRange(Value,Minimum,Maximum,NewMinimum,NewMaximum,LimitRange));
    }

    inline int IntWave(int Waveform, float Value, float CycleStart, float CycleEnd, float Minimum, float Maximum)
    {
        return Round(Wave(Waveform,Value,CycleStart,CycleEnd,Minimum,Maximum));
    }
    inline int IntEuclideanMod(float Dividend, float Divisor)
    {
        return Round(EuclideanMod(Dividend,Divisor));
    }
    inline int IntUberMod(float Dividend, float Lower, float Upper)
    {
        return Round(UberMod(Dividend,Lower,Upper));
    }

    inline int IntInterpolate(float Value, float From, float To, int LimitRange)
    {
        return Round(Interpolate(Value,From,To,LimitRange));
    }
    inline int IntMirror(float Value, float From, float To)
    {
        return Round(Mirror(Value,From,To));
    }

    inline int IntExpressionCompare(float First, float Second, int ComparisonType, float ReturnIfTrue, float ReturnIfFalse)
    {
        return Round(ExpressionCompare(First, Second, ComparisonType, ReturnIfTrue, ReturnIfFalse));
    }

    inline int IntApproach(float Value, float Amount, float Target)
    {
        return Round(Approach(Value, Amount, Target));
    }

    // String expressions
    inline std::string Substr(const std::string & String, int Start, int Length)
    {
        if(Start < 0)
            Start = String.size() + Start;

        if(Length < 0)
            Length = String.size();

        return String.substr(Start, Length);
    }

    inline const std::string & StrExpressionCompare(float First, float Second,
        int ComparisonType, const std::string & ReturnIfTrue,
        const std::string & ReturnIfFalse)
    {
        if (Compare(First, Second, ComparisonType))
            return ReturnIfTrue;
        else
            return ReturnIfFalse;
    }
}

#endif // CHOWDREN_UTILITY_H

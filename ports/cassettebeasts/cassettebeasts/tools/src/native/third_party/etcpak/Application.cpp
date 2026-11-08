#include <stdio.h>
#include <math.h>
#include <memory>
#include <string.h>
#include <tracy/Tracy.hpp>

#ifdef _MSC_VER
#  include "getopt/getopt.h"
#else
#  include <unistd.h>
#  include <getopt.h>
#endif

#include "bc7enc.h"
#include "Bitmap.hpp"
#include "BlockData.hpp"
#include "DataProvider.hpp"
#include "Debug.hpp"
#include "Error.hpp"
#include "System.hpp"
#include "TaskDispatch.hpp"
#include "Timing.hpp"
#include "TextureHeader.hpp"

struct DebugCallback_t : public DebugLog::Callback
{
    void OnDebugMessage( const char* msg ) override
    {
        fprintf( stderr, "%s\n", msg );
    }
} DebugCallback;

void Usage()
{
    fprintf( stderr, "Usage: etcpak [options] input.png {output.pvr}\n" );
    fprintf( stderr, "  Options:\n" );
    fprintf( stderr, "  -v                     view mode (loads pvr/ktx file, decodes it and saves to png)\n" );
    fprintf( stderr, "  -s                     display image quality measurements\n" );
    fprintf( stderr, "  -b                     benchmark mode\n" );
    fprintf( stderr, "  -M                     switch benchmark to multi-threaded mode\n" );
    fprintf( stderr, "  -m                     generate mipmaps\n" );
    fprintf( stderr, "  -d                     enable dithering\n" );
    fprintf( stderr, "  -c codec               use specified codec (defaults to etc2_rgb)\n" );
    fprintf( stderr, "                         [etc1, etc2_r, etc2_rg, etc2_rgb, etc2_rgba, bc1, bc3, bc4, bc5, bc7]\n" );
    fprintf( stderr, "  -h header              use specified header for output file (defaults to pvr)\n" );
    fprintf( stderr, "                         [pvr, dds]\n" );
    fprintf( stderr, "  --disable-heuristics   disable heuristic selector of compression mode\n" );
    fprintf( stderr, "  --linear               input data is in linear space (disable sRGB conversion for mips)\n\n" );
    fprintf( stderr, "Output file name may be unneeded for some modes.\n" );
}

int main( int argc, char** argv )
{
    TracyNoop;

    DebugLog::AddCallback( &DebugCallback );

    bool viewMode = false;
    bool stats = false;
    bool benchmark = false;
    bool benchMt = false;
    bool mipmap = false;
    bool dither = false;
    bool linearize = true;
    bool useHeuristics = true;
    auto codec = CodecType::Etc2_RGB;
    auto header = BlockData::Format::Pvr;
    unsigned int cpus = System::CPUCores();

    if( argc < 3 )
    {
        Usage();
        return 1;
    }

    enum Options
    {
        OptLinear,
        OptNoHeuristics
    };

    struct option longopts[] = {
        { "linear", no_argument, nullptr, OptLinear },
        { "disable-heuristics", no_argument, nullptr, OptNoHeuristics },
        {}
    };

    int c;
    while( ( c = getopt_long( argc, argv, "vsbMmdc:h:", longopts, nullptr ) ) != -1 )
    {
        switch( c )
        {
        case '?':
            Usage();
            return 1;
        case 'v':
            viewMode = true;
            break;
        case 's':
            stats = true;
            break;
        case 'b':
            benchmark = true;
            break;
        case 'M':
            benchMt = true;
            break;
        case 'm':
            mipmap = true;
            break;
        case 'd':
            dither = true;
            break;
        case 'c':
            if( strcmp( optarg, "etc1" ) == 0 ) codec = CodecType::Etc1;
            else if( strcmp( optarg, "etc2_r" ) == 0 ) codec = CodecType::Etc2_R11;
            else if( strcmp( optarg, "etc2_rg" ) == 0 ) codec = CodecType::Etc2_RG11;
            else if( strcmp( optarg, "etc2_rgb" ) == 0 ) codec = CodecType::Etc2_RGB;
            else if( strcmp( optarg, "etc2_rgba" ) == 0 ) codec = CodecType::Etc2_RGBA;
            else if( strcmp( optarg, "bc1" ) == 0 ) codec = CodecType::Bc1;
            else if( strcmp( optarg, "bc3" ) == 0 ) codec = CodecType::Bc3;
            else if( strcmp( optarg, "bc4" ) == 0 ) codec = CodecType::Bc4;
            else if( strcmp( optarg, "bc5" ) == 0 ) codec = CodecType::Bc5;
            else if( strcmp( optarg, "bc7" ) == 0 ) codec = CodecType::Bc7;
            else
            {
                fprintf( stderr, "Unknown codec: %s\n", optarg );
                return 1;
            }
            break;
        case 'h':
            if( strcmp( optarg, "pvr" ) == 0 ) header = BlockData::Pvr;
            else if( strcmp( optarg, "dds" ) == 0 ) header = BlockData::Dds;
            else
            {
                fprintf( stderr, "Unknown header: %s\n", optarg );
                return 1;
            }
            break;
        case OptLinear:
            linearize = false;
            break;
        case OptNoHeuristics:
            useHeuristics = false;
            break;
        default:
            break;
        }
    }

    const char* input = nullptr;
    const char* output = nullptr;
    if( benchmark )
    {
        if( argc - optind < 1 )
        {
            Usage();
            return 1;
        }

        input = argv[optind];
    }
    else
    {
        if( argc - optind < 2 )
        {
            Usage();
            return 1;
        }

        input = argv[optind];
        output = argv[optind+1];
    }

    const bool bgr = !( codec == CodecType::Bc1 || codec == CodecType::Bc3 || codec == CodecType::Bc4 || codec == CodecType::Bc5 || codec == CodecType::Bc7 );
    const bool rgba = ( codec == CodecType::Etc2_RGBA || codec == CodecType::Bc3 || codec == CodecType::Bc7 );

    bc7enc_compress_block_params bc7params;
    if( codec == CodecType::Bc7 )
    {
        bc7enc_compress_block_init();
        bc7enc_compress_block_params_init( &bc7params );
    }

    if( benchmark )
    {
        if( viewMode )
        {
            auto bd = std::make_shared<BlockData>( input );

            constexpr int NumTasks = 9;
            uint64_t timeData[NumTasks];
            for( int i=0; i<NumTasks; i++ )
            {
                const auto start = GetTime();
                auto res = bd->Decode();
                const auto end = GetTime();
                timeData[i] = end - start;
            }
            std::sort( timeData, timeData+NumTasks );
            const auto median = timeData[NumTasks/2] / 1000.f;
            printf( "Median decode time for %i runs: %0.3f ms (%0.3f Mpx/s)\n", NumTasks, median, bd->Size().x * bd->Size().y / ( median * 1000 ) );
        }
        else
        {
            auto start = GetTime();
            auto bmp = std::make_shared<Bitmap>( input, std::numeric_limits<unsigned int>::max(), bgr );
            bmp->Data();
            auto end = GetTime();
            printf( "Image load time: %0.3f ms\n", ( end - start ) / 1000.f );

            constexpr int NumTasks = 9;
            uint64_t timeData[NumTasks];
            if( benchMt )
            {
                TaskDispatch taskDispatch( cpus );
                const unsigned int parts = ( ( bmp->Size().y / 4 ) + 32 - 1 ) / 32;

                for( int i=0; i<NumTasks; i++ )
                {
                    auto bd = std::make_shared<BlockData>( bmp->Size(), false, codec );
                    auto ptr = bmp->Data();
                    const auto width = bmp->Size().x;
                    const auto localStart = GetTime();
                    auto linesLeft = bmp->Size().y / 4;
                    size_t offset = 0;
                    if( rgba )
                    {
                        for( int j=0; j<parts; j++ )
                        {
                            const auto lines = std::min( 32, linesLeft );
                            taskDispatch.Queue( [bd, ptr, width, lines, offset, useHeuristics, &bc7params] {
                                bd->ProcessRGBA( ptr, width * lines / 4, offset, width, useHeuristics, &bc7params );
                            } );
                            linesLeft -= lines;
                            ptr += width * lines;
                            offset += width * lines / 4;
                        }
                    }
                    else
                    {
                        for( int j=0; j<parts; j++ )
                        {
                            const auto lines = std::min( 32, linesLeft );
                            taskDispatch.Queue( [bd, ptr, width, lines, offset, dither, useHeuristics] {
                                bd->Process( ptr, width * lines / 4, offset, width, dither, useHeuristics );
                            } );
                            linesLeft -= lines;
                            ptr += width * lines;
                            offset += width * lines / 4;
                        }
                    }
                    taskDispatch.Sync();
                    const auto localEnd = GetTime();
                    timeData[i] = localEnd - localStart;
                }
            }
            else
            {
                for( int i=0; i<NumTasks; i++ )
                {
                    auto bd = std::make_shared<BlockData>( bmp->Size(), false, codec );
                    const auto localStart = GetTime();
                    if( rgba )
                    {
                        bd->ProcessRGBA( bmp->Data(), bmp->Size().x * bmp->Size().y / 16, 0, bmp->Size().x, useHeuristics, &bc7params );
                    }
                    else
                    {
                        bd->Process( bmp->Data(), bmp->Size().x * bmp->Size().y / 16, 0, bmp->Size().x, dither, useHeuristics );
                    }
                    const auto localEnd = GetTime();
                    timeData[i] = localEnd - localStart;
                }
            }
            std::sort( timeData, timeData+NumTasks );
            const auto median = timeData[NumTasks/2] / 1000.f;
            printf( "Median compression time for %i runs: %0.3f ms (%0.3f Mpx/s)", NumTasks, median, bmp->Size().x * bmp->Size().y / ( median * 1000 ) );
            if( benchMt )
            {
                printf( " multi threaded (%i cores)\n", cpus );
            }
            else
            {
                printf( " single threaded\n" );
            }
        }
    }
    else if( viewMode )
    {
        auto bd = std::make_shared<BlockData>( input );
        auto out = bd->Decode();
        out->Write( output );
    }
    else
    {
        DataProvider dp( input, mipmap, bgr, linearize );
        auto num = dp.NumberOfParts();

        TaskDispatch taskDispatch( cpus );

        auto bd = std::make_shared<BlockData>( output, dp.Size(), mipmap, codec, header );
        for( int i=0; i<num; i++ )
        {
            auto part = dp.NextPart();

            if( rgba )
            {
                TaskDispatch::Queue( [part, &bd, useHeuristics, &bc7params]()
                {
                    bd->ProcessRGBA( part.src, part.width / 4 * part.lines, part.offset, part.width, useHeuristics, &bc7params );
                } );
            }
            else
            {
                TaskDispatch::Queue( [part, &bd, &dither, useHeuristics]()
                {
                    bd->Process( part.src, part.width / 4 * part.lines, part.offset, part.width, dither, useHeuristics );
                } );
            }
        }

        TaskDispatch::Sync();

        if( stats )
        {
            auto out = bd->Decode();
            float mse = CalcMSE3( dp.ImageData(), *out );
            printf( "RGB data\n" );
            printf( "  RMSE: %f\n", sqrt( mse ) );
            printf( "  PSNR: %f\n", 20 * log10( 255 ) - 10 * log10( mse ) );
        }
    }

    return 0;
}

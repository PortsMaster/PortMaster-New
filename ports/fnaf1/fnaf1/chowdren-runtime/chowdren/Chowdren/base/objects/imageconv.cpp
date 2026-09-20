#include "objects/imageconv.h"
#include <iostream>

void ImageManipulator::load(const std::string & filename)
{
    std::cout << "Load imageconv image: " << filename << std::endl;
}

void ImageManipulator::save(const std::string & filename)
{
    std::cout << "Save imageconv image: " << filename << std::endl;
}

void ImageManipulator::apply_gauss_blur()
{

}

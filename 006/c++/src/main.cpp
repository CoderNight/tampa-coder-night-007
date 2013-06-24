//
//  main.cpp
//  BlueHawaii
//
//  Created by Jason L Perry on 06/11/13.
//  Copyright (c) 2013 Jason L Perry. All rights reserved.
//

#include <iostream>
#include "blue_hawaii.hpp"

int main(int argc, const char * argv[])
{
  if (argc != 3)
  {
    std::cout << "Usage: blue-hawaii PATH_TO_INPUT_TXT PATH_TO_RENTALS_JSON" << std::endl;
  }
  else
  {
    const BlueHawaii app (argv[1], argv[2]);
  }
  return 0;
}

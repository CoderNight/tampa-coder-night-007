//
//  blue_hawaii.hpp
//  BlueHawaii
//
//  Created by Jason L Perry on 06/20/2013.
//  Copyright (c) 2013 Jason L Perry. All rights reserved.
//

#include <fstream>
#include <iostream>
#include <string>

#include "JsonBox.h"

class BlueHawaii
{
  public:
    BlueHawaii (
      const char * reservation_file,
      const char * rentals_file
    );
};


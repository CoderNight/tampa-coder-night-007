//
//  blue_hawaii.cpp
//  BlueHawaii
//
//  Created by Jason L Perry on 06/20/2013.
//  Copyright (c) 2013 Jason L Perry. All rights reserved.
//

#include "blue_hawaii.hpp"

BlueHawaii::BlueHawaii (
  const char * reservation_file,
  const char * rentals_file
)
{
  // Load reservation dates from file
  std::string reservation_string;
  std::ifstream file;
  file.open (reservation_file);
  std::getline (file, reservation_string);

  file.close();

  // Load JSON data from rentals file
  JsonBox::Value data;
  data.loadFromFile (rentals_file);
  data.writeToStream (std::cout, true, true);
}

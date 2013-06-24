To build:

    git submodule update --init

    mkdir build
    cd build

Now generate the project for your compiler. Default for the platform like:

    cmake ..

Or, specify a specific project type:

    cmake .. -G Xcode

Now you can run `make`, open the IDE project, or use cmake to build:

    `cmake --build .`

Running it:

    ./bin/blue-hawaii ../puzzle/input.txt ../puzzle/vacation_rentals.json

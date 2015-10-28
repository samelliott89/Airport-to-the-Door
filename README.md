# PhoneGap AirportTTDoor

This is the AirportTTDoor as a (mostly) cross-platform PhoneGap app, using OnsenUI for UI niceness.

## Getting started

First up, you'll need to make sure you have the PhoneGap/Cordova utilities installed, as well as the project dependencies:

    npm install -g gulp ios-sim cordova
    npm install

And set up project

    ./build setup

For quick development, you can use Gulp to run the app in your web browser. By default, you can access this at http://localhost:5014

    gulp

Recommend using 'gulp --watch' for on going development

    gulp --watch

## Configs

Build configs are stored in `configs/`. Default config is in `configs/default.cson`, and values are overrode by default from `configs/local.cson`. For gulp builds, you can use `gulp build --config=prod` to use another config file (instead of `local`).

## Running on emulator or device

For Cordova builds, use the `./build` script:

* `./build emulate`: Cleans, builds and launches the emulator
* `./build run`: Cleans, builds and runs the app on a connected iOS device
* `./build appStore`: Cleans, builds and makes a package for App Store submission

Once again the `local.cson` config is used by default. To use another build, just pass the name in like './build run prod'
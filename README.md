# lua-ios
Lua library for ios

Lua library (5.3.2) for iOS like Xcode project 
For building library execute in terminal build.sh script, after building you can find buided universal binary (device and simulator) with bitcode support(Xcode 7 and higher needed) in output/Universal directory (same folder in which the script is).

##### Additional params:
- If you want library without bitcode support run build script with -b/--bitcode=NO|YES flag:
    ```sh
    sh build.sh -b=NO
    ```

- If you want library only for specefied platform run build script with -p/--platform=all|device|simulator flag:
    ```sh
    sh build.sh -p=device
    ```

- For cleaning buid directory run script with -c/--clean flag:
    ```sh
    sh build.sh -c
    ```

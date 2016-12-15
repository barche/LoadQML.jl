# LoadQML

Very simple QML file loader, intended to debug Qt installations for QML.jl. Not for actual work, no interaction between QML and Julia.

Installation and run (needs cmake in path, C++ compiler and Qt5-development packages):

```julia
Pkg.clone("https://github.com/barche/LoadQML.jl.git")
Pkg.build("LoadQML")
Pkg.test("LoadQML")
```

## Gallium-based OpenGL griver (swrast)
The Gallium driver as used in e.g. virtualbox uses LLVM to compile shaders. This causes a crash when loading QML from within Julia, which also uses LLVM. As a workaround, set the environment variable:

```
GALLIUM_DRIVER="softpipe"
```

This disables the use of LLVM in Gallium.

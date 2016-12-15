using BinDeps

@BinDeps.setup

QT_ROOT = get(ENV, "QT_ROOT", "")

loadqml = library_dependency("loadqml", aliases=["libloadqml"])

used_homebrew = false
if QT_ROOT == ""
  if is_apple()
    std_hb_root = "/usr/local/opt/qt5"
    if(!isdir(std_hb_root))
      if Pkg.installed("Homebrew") === nothing
        error("Homebrew package not installed, please run Pkg.add(\"Homebrew\")")
      end
      using Homebrew
      if !Homebrew.installed("qt5")
        Homebrew.add("qt5")
      end
      if !Homebrew.installed("cmake")
        Homebrew.add("cmake")
      end
      used_homebrew = true
      QT_ROOT = joinpath(Homebrew.prefix(), "opt", "qt5")
    else
      QT_ROOT = std_hb_root
    end
  end

  if is_linux()
    try
      run(pipeline(`cmake --version`, stdout=DevNull, stderr=DevNull))
      try
        run(pipeline(`qmake-qt5 --version`, stdout=DevNull, stderr=DevNull))
      catch
        run(pipeline(`qmake --version`, stdout=DevNull, stderr=DevNull))
      end
      run(pipeline(`qmlscene $(joinpath(dirname(@__FILE__), "imports.qml"))`, stdout=DevNull, stderr=DevNull))
    catch
      println("Installing Qt and cmake...")

      function printrun(cmd)
        println("Running install command, if this fails please run manually:\n$cmd")
        run(cmd)
      end

      if BinDeps.can_use(AptGet)
        printrun(`sudo apt-get install cmake cmake-data qtdeclarative5-dev qtdeclarative5-qtquick2-plugin qtdeclarative5-dialogs-plugin qtdeclarative5-controls-plugin qtdeclarative5-quicklayouts-plugin qtdeclarative5-window-plugin qmlscene qt5-default`)
      elseif BinDeps.can_use(Pacman)
        printrun(`sudo pacman -S --needed qt5-quickcontrols2`)
      elseif BinDeps.can_use(Yum)
        printrun(`sudo yum install cmake qt5-qtbase-devel qt5-qtquickcontrols qt5-qtquickcontrols2-devel`)
      end
    end
  end
end

cmake_prefix = QT_ROOT

prefix=joinpath(BinDeps.depsdir(loadqml),"usr")
loadqml_srcdir = joinpath(BinDeps.depsdir(loadqml),"src","loadqml")
loadqml_builddir = joinpath(BinDeps.depsdir(loadqml),"builds","loadqml")
lib_prefix = @static is_windows() ? "" : "lib"
lib_suffix = @static is_windows() ? "dll" : (@static is_apple() ? "dylib" : "so")

makeopts = ["--", "-j", "$(Sys.CPU_CORES+2)"]

println("Using Qt from $cmake_prefix")

qml_steps = @build_steps begin
	`cmake -DCMAKE_INSTALL_PREFIX="$prefix" -DCMAKE_BUILD_TYPE="Debug" -DCMAKE_PREFIX_PATH="$cmake_prefix" $loadqml_srcdir`
	`cmake --build . --config Debug --target install $makeopts`
end

# If built, always run cmake, in case the code changed
if isdir(loadqml_builddir)
  BinDeps.run(@build_steps begin
    ChangeDirectory(loadqml_builddir)
    qml_steps
  end)
end

provides(BuildProcess,
  (@build_steps begin
    CreateDirectory(loadqml_builddir)
    @build_steps begin
      ChangeDirectory(loadqml_builddir)
      FileRule(joinpath(prefix,"lib", "$(lib_prefix)loadqml.$lib_suffix"),qml_steps)
    end
  end),loadqml)

@BinDeps.install Dict([(:loadqml, :_l_loadqml)])

if used_homebrew
  # Not sure why this is needed on homebrew Qt, but here goes:
  envfile_path = joinpath(dirname(@__FILE__), "env.jl")
  plugins_path = joinpath(QT_ROOT, "plugins")
  qml_path = joinpath(QT_ROOT, "qml")
  open(envfile_path, "w") do envfile
    println(envfile, "ENV[\"QT_PLUGIN_PATH\"] = \"$plugins_path\"")
    println(envfile, "ENV[\"QML2_IMPORT_PATH\"] = \"$qml_path\"")
  end
end

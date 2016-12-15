module LoadQML

export load_qml_app

const depsfile = joinpath(dirname(dirname(@__FILE__)), "deps", "deps.jl")
if !isfile(depsfile)
  error("$depsfile not found, package QML did not build properly")
end
include(depsfile)

load_qml_app(filename::AbstractString) = ccall((:load_qml_app, _l_loadqml), Void, (Cstring,), filename)

end # module

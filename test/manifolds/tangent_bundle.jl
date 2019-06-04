using FunManifolds
using Test

include("../utils.jl")

@testset "Tangent bundle" begin
    s2 = Sphere(2)
    p_sphere = project_point_wrapped([0., 1., 0.], s2)
    sphere_ts_pt = ambient2point([1.0, 0.0, 0.0], s2)

    generic_manifold_tests(TangentBundleSpace(s2),
        [TangentBundlePt(project_tv([0.5, 0., 0.], p_sphere)),
        TangentBundlePt(project_tv([0., 0., 0.5], p_sphere)),
        TangentBundlePt(project_tv([0.0, 0.5, 0.5], sphere_ts_pt))],
        "Tangent bundle over a 2-sphere",
        0.0)
end
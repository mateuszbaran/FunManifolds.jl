using FunManifolds
using Test
using StaticArrays

include("../utils.jl")

@testset "Tangent manifolds" begin
    s2 = Sphere(2)
    p_sphere = project_point_wrapped([0., 1., 0.], s2)
    r2 = EuclideanSpace(2)
    p_euclidean = ambient2point([1.0, -1.0], r2)
    p_euclidean_static = ambient2point((@SVector [1.0, -1.0]), r2)

    generic_manifold_tests(TSpaceManifold(p_euclidean),
        [TSpaceManifoldPt(EuclideanTV(p_euclidean, [0.5, 0.])),
        TSpaceManifoldPt(EuclideanTV(p_euclidean, [0., 0.5])),
        TSpaceManifoldPt(EuclideanTV(p_euclidean, [0.5, 0.5]))],
        "Tangent space manifold (euclidean)",
        0.0)

    generic_manifold_tests(TSpaceManifold(p_sphere),
        [TSpaceManifoldPt(project_tv([0.5, 0., 0.], p_sphere)),
        TSpaceManifoldPt(project_tv([0., 0., 0.5], p_sphere)),
        TSpaceManifoldPt(project_tv([0.5, 0., 0.5], p_sphere))],
        "Tangent space manifold (sphere)",
        0.0)

    generic_manifold_tests(TSpaceManifold(p_euclidean_static),
        [TSpaceManifoldPt(EuclideanTV(p_euclidean_static, @MVector [0.5, 0.])),
        TSpaceManifoldPt(EuclideanTV(p_euclidean_static, @MVector [0., 0.5])),
        TSpaceManifoldPt(EuclideanTV(p_euclidean_static, @MVector [0.5, 0.5]))],
        "Tangent space manifold (euclidean) (static)",
        0.0)

    @testset "Other tests" begin
        p = project_point_wrapped([0., 1., 0.], Sphere(2))
        tv = SphereTV(p, [0.5, 0., 0.])
        y = expmap(tv)
        tvp = TSpaceManifoldPt(tv)
        @test dim(gettype(tvp)) == 2
        ztv = zero_tv(tvp)
        ttvp = TSpaceManifoldPt(ztv)
        @test dim(gettype(ttvp)) == 2
    end
end

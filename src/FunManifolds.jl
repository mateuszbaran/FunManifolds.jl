__precompile__()

"""
Main module for `FunManifolds.jl` -- a Julia package for
differential geometry (also functional).
"""
module FunManifolds

const global DEBUG = false

mutable struct GeneralParams
    quad_rel_tol::Union{Real,Nothing}
    quad_abs_tol::Union{Real,Nothing}
end

const global PARAMS = GeneralParams(nothing, nothing)

export PARAMS

import Base: isapprox, +, -, *, ∘, rtoldefault, deepcopy, copyto!, convert, exp, size, getindex, ==, zero, show

using LinearAlgebra
import LinearAlgebra.norm
using Statistics
import Statistics: mean
using Markdown
using Interpolations
using ForwardDiff
using QuadGK
using StaticArrays
using UnsafeArrays
using MacroTools
import LineSearches

export Manifold, Point, TangentVector
export dim, dim_ambient, ambient_shape, gettype
export zero_tv, zero_tv!, at_point, expmap, expmap!, retract, retract!, logmap, logmap!, innerproduct, geodesic, geodesic_at
export norm, parallel_transport_geodesic, parallel_transport_geodesic!, geodesic_distance
export innerproduct_amb, ambient_distance, riemannian_distortion
#be careful with these!
export ambient2point, project_point, project_point!, project_point_wrapped, point2ambient, ambient2tangent, project_tv, project_tv!, tangent2ambient

export add_vec, add_vec!, sub_vec, sub_vec!, mul_vec, mul_vec!

export TSpaceManifold, TSpaceManifoldPt, TSpaceManifoldTV

export TangentBundleSpace, TangentBundlePt, TangentBundleTV

export EuclideanSpace, EuclideanPt, EuclideanTV

export Sphere, SpherePt, SphereTV

export PowerSpace, PowerPt, PowerTV

export ProductSpace, ProductPt, ProductTV

export AbstractCurveSpace, AbstractCurvePt
export values_in, paramgrid
export velocity, curve_length

export CurveSpace, CurvePt, CurveTV
export uniform_sample

export RealValuedFunction

export SpecialOrthogonalSpace, SpecialOrthogonalPt, SpecialOrthogonalTV
export rotation2d, rotation2d_s, rotation3d_from_yaw_pitch_roll, rotation3d_from_yaw_pitch_roll_s

export optimize

export mean_karcher, mean_extrinsic

include("utils.jl")
include("manifolds.jl")
include("tangent_manifold.jl")
include("tangent_bundle.jl")
include("euclidean.jl")
include("sphere.jl")
include("power_space.jl")
include("product_space.jl")
include("curve.jl")
include("special_orthogonal.jl")
include("functional_transformations.jl")

include("optimization.jl")
include("mean_like_functions.jl")

end #module
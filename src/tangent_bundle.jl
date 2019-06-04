
"""
    TangentBundleSpace(m)

Tangent Bundle manifold over manifold `m`.
"""
struct TangentBundleSpace{M <: Manifold} <: Manifold
    bundle_over::M
end

"""
    TangentBundlePt(x)

Point in the Tangent Bundle manifold over a given manifold represented
by a tangent vector `x`.
"""
struct TangentBundlePt{TV <: TangentVector} <: Point
    x::TV
end

function copyto!(x_to::TangentBundlePt, x_from::TangentBundlePt)
    copyto!(x_to.x, x_from.x)
    return x_to
end

function deepcopy(x::TangentBundlePt)
    return TangentBundlePt(deepcopy(x.x))
end

function gettype(x::TangentBundlePt)
    return TangentBundleSpace(gettype(at_point(x.x)))
end

function ambient_shape(m::TangentBundleSpace)
    d = ambient_shape(m.bundle_over)
    if isa(d, Int)
        return 2*d
    else
        return (2*d[1], d[2:end]...)
    end
end

function dim(m::TangentBundleSpace)
    return dim(m.bundle_over) * 2
end

function isapprox(v1::TangentBundlePt{TV}, v2::TangentBundlePt{TV}; atol = atoldefault(v1, v2), rtol = rtoldefault(v1, v2)) where TV <: TangentVector
    return isapprox(v1.x, v2.x, atol = atol, rtol = rtol)
end

function +(v1::TangentBundlePt, v2::TangentBundlePt)
    return TangentBundlePt(v1.x + v2.x)
end

function -(v1::TangentBundlePt, v2::TangentBundlePt)
    return TangentBundlePt(v1.x - v2.x)
end

function *(α::Real, v::TangentBundlePt)
    return TangentBundlePt(α * v.x)
end

"""
    TangentBundleTV(x, v_m, v_ts)

Tangent vector from tangent space at point `x` to the tangent bundle
represented by a tangent vector `v_m` (movement along the manifold)
and a tangent vector to the tangent space manifold (movement in the tangent
manifold space).
"""
struct TangentBundleTV{TV1<:TangentVector, TVM<:TangentVector, TVTS<:TangentVector} <: TangentVector
    at_pt:: TangentBundlePt{TV1}
    v_m::TVM
    v_ts::TSpaceManifoldTV{TVTS}
end

function copyto!(v_to::TangentBundleTV, v_from::TangentBundleTV)
    copyto!(v_to.at_pt, v_from.at_pt)
    copyto!(v_to.v_m, v_from.v_m)
    copyto!(v_to.v_ts, v_from.v_ts)
    return v_to
end

function deepcopy(v::TangentBundleTV)
    return TangentBundleTV(deepcopy(v.at_pt), deepcopy(v.v_m), deepcopy(v.v_ts))
end

function +(v1::TangentBundleTV, v2::TangentBundleTV)
    DEBUG && if !(at_point(v1) ≈ at_point(v2))
        error("Given vectors are attached at different points $(at_point(v1)) and $(at_point(v2)).")
    end
    return TangentBundleTV(v1.at_pt, v1.v_m + v2.v_m, v1.v_ts + v2.v_ts)
end

function add_vec!(v1::TangentBundleTV, v2::TangentBundleTV)
    DEBUG && if !(at_point(v1) ≈ at_point(v2))
        error("Given vectors are attached at different points $(at_point(v1)) and $(at_point(v2)).")
    end
    add_vec!(v1.v_m, v2.v_m)
    add_vec!(v1.v_ts, v2.v_ts)
    return v1
end

@inline function add_vec!(v1::TV, v2::AbstractArray, at_pt::AbstractArray, m::TangentBundleSpace) where TV<:BNBArray
    @condbc TV (v1 .+= v2) (v2,)
end

function -(v1::TangentBundleTV, v2::TangentBundleTV)
    DEBUG && if !(at_point(v1) ≈ at_point(v2))
        error("Given vectors are attached at different points $(at_point(v1)) and $(at_point(v2)).")
    end
    return TangentBundleTV(v1.at_pt, v1.v_m - v2.v_m, v1.v_ts - v2.v_ts)
end

function sub_vec!(v1::TangentBundleTV, v2::TangentBundleTV)
    DEBUG && if !(at_point(v1) ≈ at_point(v2))
        error("Given vectors are attached at different points $(at_point(v1)) and $(at_point(v2)).")
    end
    sub_vec!(v1.v_m, v2.v_m)
    sub_vec!(v1.v_ts, v2.v_ts)
    return v1
end

@inline function sub_vec!(v1::TV, v2::AbstractArray, at_pt::AbstractArray, m::TangentBundleSpace) where TV<:BNBArray
    @condbc TV (v1 .-= v2) (v2,)
end

function *(α::Real, v::TangentBundleTV)
    return TangentBundleTV(v.at_pt, α * v.v_m, α * v.v_ts)
end

function mul_vec!(v::TangentBundleTV, α::Real)
    DEBUG && if !(at_point(v1) ≈ at_point(v2))
        error("Given vectors are attached at different points $(at_point(v1)) and $(at_point(v2)).")
    end
    mul_vec!(v.v_m, α)
    mul_vec!(v.v_ts, α)
    return v
end

@inline function mul_vec!(v::TV, α::Real, at_pt::AbstractArray, m::TangentBundleSpace) where TV<:BNBArray
    @condbc TV (v .*= α)
end

function isapprox(v1::TangentBundleTV, v2::TangentBundleTV; atol = atoldefault(v1, v2), rtol = rtoldefault(v1, v2))
    if !(isapprox(v1.at_pt, v2.at_pt, atol = atol, rtol = rtol))
        return false
    end
    return isapprox(v1.v_m, v2.v_m, atol = atol, rtol = rtol) && isapprox(v1.v_ts, v2.v_ts, atol = atol, rtol = rtol)
end

function innerproduct(v1::TangentBundleTV, v2::TangentBundleTV)
    DEBUG && if !(at_point(v1) ≈ at_point(v2))
        error("Given vectors are attached at different points $(at_point(v1)) and $(at_point(v2)).")
    end
    return innerproduct(v1.v_m, v2.v_m) + innerproduct(v1.v_ts, v2.v_ts)
end

function innerproduct(v1::AbstractArray, v2::AbstractArray, p::AbstractArray, m::TangentBundleSpace)
    dotM = innerproduct(v1[1], v2[1], p[1], m.bundle_over)
    dotTS = innerproduct(v1[2], v2[2], p[1], TSpaceManifold(ambient2point(p[1], m.bundle_over)))
    return dotM + dotTS
end

function canonicalFlip(v::TangentBundleTV)
    return TangentBundleTV(v.v_m, v.at_pt.x, v.v_ts)
end

function point2ambient(p::TangentBundlePt)
    return TupleArray((point2ambient(at_point(p.x)), tangent2ambient(p.x)))
end

function ambient2point(amb::AbstractArray, m::TangentBundleSpace)
    amb_pt = amb[1]
    amb_tv = amb[2]
    pt = ambient2point(amb_pt, m.bundle_over)
    return TangentBundlePt(ambient2tangent(amb_tv, pt))
end

function project_point!(amb::TV, m::TangentBundleSpace) where TV<:BNBArray
    if TV<:NoBroadcastArray
        amb[] = project_point(amb[], m)
    else
        project_point!(amb[1], m.bundle_over)
        project_tv!(amb[2], amb[1], m.bundle_over)
    end
    return amb
end

function project_point(amb::AbstractArray, m::TangentBundleSpace)
    amb_pt = amb[1]
    amb_tv = amb[2]
    pt = project_point(amb_pt, m.bundle_over)
    tv = tangent2ambient(project_tv(amb_tv, ambient2point(pt, m.bundle_over)))
    return TupleArray((pt, tv))
end

function ambient2tangent(v::AbstractArray, p::TangentBundlePt)
    ambv_m = v[1]
    ambv_ts = v[2]
    v_m = ambient2tangent(ambv_m, at_point(p.x))
    v_ts = ambient2tangent(ambv_ts, TSpaceManifoldPt(p.x))
    return TangentBundleTV(p, v_m, v_ts)
end

function project_tv(v::AbstractArray, p::TangentBundlePt)
    ambv_m = v[1]
    ambv_ts = v[2]
    v_m = project_tv(ambv_m, at_point(p.x))
    v_ts = project_tv(ambv_ts, TSpaceManifoldPt(p.x))
    return TangentBundleTV(p, v_m, v_ts)
end

function project_tv!(v::TV, p::AbstractArray, m::TangentBundleSpace) where TV<:BNBArray
    project_tv!(v[1], p[1], m.bundle_over)
    #TODO: use project_tv! from TSpaceManifold
    project_tv!(v[2], p[1], m.bundle_over)
    return v
end

function tangent2ambient(v::TangentBundleTV)
    return TupleArray((tangent2ambient(v.v_m), tangent2ambient(v.v_ts)))
end

function zero_tv(pt::TangentBundlePt)
    return TangentBundleTV(pt, zero_tv(at_point(pt.x)), zero_tv(TSpaceManifoldPt(pt.x)))
end

function zero_tv!(v::BNBArray, at_pt::AbstractArray, m::TangentBundleSpace)
    zero_tv!(v[1], at_pt[1], m.bundle_over)
    zero_tv!(v[2], at_pt[2], TSpaceManifold(ambient2point(at_pt[1], m.bundle_over)))
    return v
end

function geodesic(x1::TangentBundlePt, x2::TangentBundlePt)
    geodMan = geodesic(at_point(x1.x), at_point(x2.x))
    return CurvePt(gettype(x1)) do t
        geodAtt = geodMan(t)
        return TangentBundlePt((1-t) * parallel_transport_geodesic(x1.x, geodAtt) + t*parallel_transport_geodesic(x2.x, geodAtt))
    end
end

function geodesic_at(t::Number, x1::AbstractArray, x2::AbstractArray, m::TangentBundleSpace)
    geodAtt = geodesic_at(t, x1[1], x2[1], m.bundle_over)
    x1ptg = parallel_transport_geodesic(x1[2], x1[1], geodAtt, m.bundle_over)
    x2ptg = parallel_transport_geodesic(x2[2], x2[1], geodAtt, m.bundle_over)
    return TupleArray((geodAtt, (1-t) .* x1ptg .+ t .* x2ptg))
end

function innerproduct_amb(x1::TangentBundlePt, x2::TangentBundlePt)
    return innerproduct(x1.x, x2.x)
end

function geodesic_distance(x1::TangentBundlePt, x2::TangentBundlePt)
    distOnManifold = geodesic_distance(at_point(x1.x), at_point(x2.x))
    distTangent = norm(parallel_transport_geodesic(x1.x, at_point(x2.x)) - x2.x)
    return sqrt(distOnManifold^2 + distTangent^2)
end

function geodesic_distance(x1::AbstractArray, x2::AbstractArray, m::TangentBundleSpace)
    distOnManifold = geodesic_distance(x1[1], x2[1], m.bundle_over)
    v1transported = parallel_transport_geodesic(x1[2], x1[1], x2[1], m.bundle_over)
    #TODO: use geodesic_distance from TSpaceManifold?
    distTangent = norm(v1transported - x2[2])
    return sqrt(distOnManifold^2 + distTangent^2)
end

function expmap(v::TangentBundleTV)
    return TangentBundlePt(parallel_transport_geodesic(expmap(v.v_ts).x, expmap(v.v_m)))
end

function expmap!(p::BNBArray, v::AbstractArray, at_pt::AbstractArray, m::TangentBundleSpace)
    expmap!(p[1], v[1], at_pt[1], m.bundle_over)
    tvm = TSpaceManifold(ambient2point(at_pt[1], m.bundle_over))
    to_pt = v[2] .+ at_pt[2]
    parallel_transport_geodesic!(p[2], to_pt, at_pt[2], p[1], tvm)
    return p
end

function logmap(x::TangentBundlePt, y::TangentBundlePt)
    return TangentBundleTV(x, logmap(at_point(x.x), at_point(y.x)), TSpaceManifoldTV(TSpaceManifoldPt(x.x), parallel_transport_geodesic(y.x, at_point(x.x)) - x.x))
end

function logmap!(tv::TV, x::AbstractArray, y::AbstractArray, m::TangentBundleSpace) where TV<:BNBArray
    logmap!(tv[1], x[1], y[1], m.bundle_over)
    @condbc TV (tv[2] .= parallel_transport_geodesic(y[2], y[1], x[1], m.bundle_over) - x[2])
    return tv
end

function parallel_transport_geodesic(v::TangentBundleTV, to_pt::TangentBundlePt)
    return TangentBundleTV(to_pt, parallel_transport_geodesic(v.v_m, at_point(to_pt.x)), parallel_transport_geodesic(v.v_ts, TSpaceManifoldPt(to_pt.x)))
end

function parallel_transport_geodesic!(vout::BNBArray, vin::AbstractArray, at_pt::AbstractArray, to_pt::AbstractArray, m::TangentBundleSpace)
    parallel_transport_geodesic!(vout[1], vin[1], at_pt[1], to_pt[1], m.bundle_over)
    parallel_transport_geodesic!(vout[2], vin[2], at_pt[2], to_pt[2], TSpaceManifold(ambient2point(to_pt[1], m.bundle_over)))
    return vout
end
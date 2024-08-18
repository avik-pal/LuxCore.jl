module LuxCoreFunctorsExt

using LuxCore: LuxCore
using Functors: Functors

LuxCore.Internal.is_extension_loaded(::Val{:Functors}) = true

LuxCore.Internal.isleaf_impl(x) = Functors.isleaf(x)
LuxCore.Internal.fmap_impl(args...; kwargs...) = Functors.fmap(args...; kwargs...)
LuxCore.Internal.fleaves_impl(args...; kwargs...) = Functors.fleaves(args...; kwargs...)

function Functors.functor(::Type{<:LuxCore.AbstractLuxContainerLayer{layers}},
        x) where {layers}
    children = NamedTuple{layers}(getproperty.((x,), layers))
    layer_reconstructor = let x = x, layers = layers
        z -> reduce(LuxCore.Internal.setfield, zip(layers, z); init=x)
    end
    return children, layer_reconstructor
end

function Functors.functor(::Type{<:LuxCore.AbstractLuxWrapperLayer{layer}},
        x) where {layer}
    children = NamedTuple{(layer,)}((getproperty(x, layer),))
    layer_reconstructor = let x = x, layer = layer
        z -> LuxCore.Internal.setfield(x, layer, getproperty(z, layer))
    end
    return children, layer_reconstructor
end

end

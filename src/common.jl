#interprets
# [7,6,3,0] as x^7+x^6+x^3+1
function make_bitvector(v::Array{Int,1})
  lenv=length(v)
  @assert length(v)<=7
  @assert unique(v)==v
  @assert sort(v,rev=true)==v
  res=falses(8)
  for i=1:lenv
      res[v[i]+1]=true
  end
  return res
end

make_bitvector(x::T) where {T<:Integer} = monoic_polynomial(x)

#=
 @time make_bitvector([7,5,4,2,1])
=#
function monoic_polynomial(s::T) where {T<:Integer}
  res=falses(8)
  res[s+1]=true
  return res
end

# maps a bitvector x^7+x^6+x^3+1 to  [7,6,3,0]
function make_int_vector(v::BitVector)
  res=Int[]
  for i=length(v):-1:1
    if v[i]
      push!(res,i-1)
    end
  end
  return res
end

function make_uint8(v::BitVector)
  lenv=length(v)
  res=zero(UInt8)
  for i=1:lenv
    if v[i]
      i_minus1=i-1
      res+=0x01<<i_minus1
    end
  end
  return res
end

function make_bitvector(v::UInt8)
  b=bitstring(v)
  #lenb=length(b)
  #b=reverse(b)
  res=falses(8)
  for i=1:8
    if b[i]=='1'
      res[9-i]=true
    end
  end
  return res
end

function make_bitvector(v::UInt16)
  b=bitstring(v)
  #lenb=length(b)
  #b=reverse(b)
  res=falses(16)
  for i=1:16
    if b[i]=='1'
      res[17-i]=true
    end
  end
  return res
end

function Base.ndigits(x::BitVector)
  for l=length(x):-1:1
    if x[l]
      return l
    end
  end
  return 0
end

function mymod(s,plus)
  x=mod(s+plus,8)
  if x==0
    return 8
  else
    return x
  end
end

function show_as_square(x::Array{UInt8,1})
  xa=reshape(x,4,4)
  @show xa
  return xa
end

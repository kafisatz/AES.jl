#const UNIT8_IRREDUCIBLE_POLYNOMIAL=UInt8[1,0,0,0,1,1,0,1,1]

function xtime!(y::BitArray)
  lastdigit=y[end]
  right_bitpopfirst!(y)
  if lastdigit
    unsafe_add_same_size_arrays!(y,BITARRAY_IRREDUCIBLE_POLYNOMIAL_8BITS)
  end
  return nothing
end

#modifies x in place
function unsafe_add_same_size_arrays!(x::BitArray,y::BitArray)
  #x and y need to be of same size
  for i=1:length(x)
    @inbounds x[i]=xor(x[i],y[i])
  end
end

function right_bitpopfirst!(v::BitArray)
  pop!(v)
  pushfirst!(v,false)
  return nothing
end

function unsafe_multiply_same_size_arrays(x::BitArray,y::BitArray)
  #leny=length(y)
  degy=ndigits(y)
  local res
  if y[1]
    res=deepcopy(x)
  else
    res=falses(8)
  end
  tmp=deepcopy(x)
  @inbounds for i=2:degy
    xtime!(tmp)
    @inbounds if y[i]
      unsafe_add_same_size_arrays!(res::BitArray,tmp::BitArray)
    end
  end
  return res
end

#returns quotient and remainder q,r of BITARRAY_IRREDUCIBLE_POLYNOMIAL/y
function divide_irreducible_poly(y::BitArray)
  degx=ndigits(BITARRAY_IRREDUCIBLE_POLYNOMIAL)
  degy=ndigits(y)
  #if degx<degy
  #  return x
  #end
  expo = degx - degy
  mono=monoic_polynomial(expo)
  tmp=deepcopy(y)
  for i=1:expo
    #@show "before" make_int_vector(tmp)
    xtime!(tmp)
    #@show "after", make_int_vector(tmp)
  end
  return mono,tmp
end


#calculates x/y
#input is x,y
#output is quotient,remainder
function division_same_size_arrays(x::BitArray,y::BitArray)
degx=ndigits(x)
degy=ndigits(y)
#@show "start division"
#@show make_int_vector(x), make_int_vector(y)
if degx<degy
#  warn("this needs something else here! remainder? quotient!?")
#  @show "degx<degy"
#  @show  make_int_vector(BITARRAY_ZERO),make_int_vector(x)
  return deepcopy(BITARRAY_ZERO),x
end

expo = degx - degy
mono=monoic_polynomial(expo)
tmp=deepcopy(y)
#@show make_int_vector(tmp)
#@show make_int_vector(x)
for i=1:expo
  xtime!(tmp)
end
#@show make_int_vector(tmp)
#@show make_int_vector(mono)
unsafe_add_same_size_arrays!(tmp,x)
#@show make_int_vector(tmp)
#@show make_int_vector(y)
degtmp=ndigits(tmp)
#@show "remainder is:"
#@show make_int_vector(tmp)
  if tmp==BITARRAY_ONE
#    @show "tmp==BITARRAY_ONE"
#    @show  make_int_vector(mono),make_int_vector(tmp)
    return mono,tmp
  else
    if degtmp<degy
#      @show "degtmp<degy"
#      @show  make_int_vector(mono),make_int_vector(tmp)
      return mono,tmp
    else
      q,r=division_same_size_arrays(tmp,y)
      #@show make_int_vector(tmp),make_int_vector(y)

      #x=deepcopy(tmp)
      #y=deepcopy(y)
      #@show make_int_vector(q),make_int_vector(r)
#      warn("how did we get here?")
#      @show  make_int_vector(q),make_int_vector(r)
#      @show  make_int_vector(mono)
      unsafe_add_same_size_arrays!(mono,q)
      return mono,r
      #xor.(mono,division_same_size_arrays(tmp,y))
  end
  end
end

function modinv(v::BitArray)
  #init
  if v==BITARRAY_ONE
    return deepcopy(v)
  end
  if v==BITARRAY_ZERO #00 is mapped to itself
    return deepcopy(v)
  end
    r0=deepcopy(BITARRAY_IRREDUCIBLE_POLYNOMIAL)
    r1=deepcopy(v)
    a0=deepcopy(BITARRAY_ZERO)
    a1=deepcopy(BITARRAY_ONE)
#  @show make_int_vector(v)
  q2,r2=divide_irreducible_poly(v)
#  @show make_int_vector(r2),make_int_vector(q2)
#  @show make_int_vector(a1)
  a2=xor.(a0,unsafe_multiply_same_size_arrays(a1,q2))
  while r2!=BITARRAY_ONE
    #@show  make_int_vector(r1),make_int_vector(r2)
    a0=a1
    a1=a2
    r0=r1
    r1=r2
    #@show  make_int_vector(r0),make_int_vector(r1),make_int_vector(r2)
    q2,r2=division_same_size_arrays(r0,r1)
    #@show  make_int_vector(a0),make_int_vector(a1)
    #@show  make_int_vector(q2)
    #@show  make_int_vector(q2),make_int_vector(r2)
    a2=xor.(a0,unsafe_multiply_same_size_arrays(a1,q2))
    #@show  make_int_vector(a2)
    end
    return a2
end

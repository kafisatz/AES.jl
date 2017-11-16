function aes_encrypt(inarr::Array{UInt8,1},key::Array{UInt8,1})

  nk,nr=get_keylen_and_rounds(div(length(key)*16,2))

  #nb==4 for AES
  #word=32bits or 4 bytes

  #key generation
    expanded_key=keyExpansionEnc(key)
  #read input state
    state=deepcopy(inarr)
    addRoundKey!(state,view(expanded_key,1:16))

  for nround = 1:nr
    subBytes!(state)
    shiftRows!(state)
    if nround<nr #for the last round no mixColumns is performed
      mixColumns!(state)
    end
    nround16=nround*16
    addRoundKey!(state,view(expanded_key,nround16+1:nround16+16))
  end

    out = deepcopy(state)
  return out
end

function addRoundKey!(state,w)
  @assert size(state)==size(w)
  @inbounds for j=1:length(w)
    state[j]=xor(state[j],w[j])
  end
  return nothing
end

function subBytes!(state)
  #1. multiplicative inverse of state
  lens=length(state)
  @inbounds  for i=1:lens
        tmp=modinv(make_bitvector(state[i]))
        tmp2=subBytes_affine(tmp,SUBBYTESMATRIX)
        state[i]=make_uint8(tmp2)
  end
  return nothing
end

function unsafe_boolean_mult(m,b)
  #only works for m=8x8 bitArray and b=bitvector(8)
  res=falses(8)
  @inbounds for i=1:8
    tmp=false
    for j=1:8
      @inbounds tmp=xor(tmp,m[i,j]*b[j])
    end
    res[i]=tmp
  end
  return res
end

function subBytes_affine(b::BitVector,matrix::BitArray)
    tmp=unsafe_boolean_mult(matrix,b)
    xor.(tmp,BITARRAY_HEX63)
end

function shiftRows!(state)
  shift_secondrow!(state)
  shift_thirdrow!(state)
  shift_fourthrow!(state)
  return nothing
end

function shift_secondrow!(state)
  @inbounds tmp=state[2]
  @inbounds state[2]=state[6]
  @inbounds state[6]=state[10]
  @inbounds state[10]=state[14]
  @inbounds state[14]=tmp
  return nothing
end

function shift_thirdrow!(state)
  #can we swap two elements more efficiently?
  @inbounds tmp=state[3]
  @inbounds state[3]=state[11]
  @inbounds state[11]=tmp

  @inbounds tmp=state[7]
  @inbounds state[7]=state[15]
  @inbounds state[15]=tmp
  return nothing
end

function shift_fourthrow!(state)
  @inbounds tmp=state[4]
  @inbounds state[4]=state[16]
  @inbounds state[16]=state[12]
  @inbounds state[12]=state[8]
  @inbounds state[8]=tmp
  return nothing
end

function mixColumns!(state)
  for col=1:4
    coli=view(state,(1+4*(col-1)):(col*4))
    mixOneColumn!(coli)
  end
end

function mixOneColumn!(coli)
  @inbounds byte1=coli[1]
  @inbounds byte2=coli[2]
  @inbounds byte3=coli[3]
  @inbounds byte4=coli[4]
  bitvect1=make_bitvector(byte1)
  bitvect2=make_bitvector(byte2)
  bitvect3=make_bitvector(byte3)
  bitvect4=make_bitvector(byte4)

  @inbounds coli[1]=xor.(xor.(xor.(make_uint8(unsafe_multiply_same_size_arrays(BITARRAY_HEX02,bitvect1)),make_uint8(unsafe_multiply_same_size_arrays(BITARRAY_HEX03,bitvect2))),byte3),byte4)
  @inbounds coli[2]=xor.(xor.(xor.(byte1,make_uint8(unsafe_multiply_same_size_arrays(BITARRAY_HEX02,bitvect2))),make_uint8(unsafe_multiply_same_size_arrays(BITARRAY_HEX03,bitvect3))),byte4)
  @inbounds coli[3]=xor.(xor.(xor.(byte1,byte2),make_uint8(unsafe_multiply_same_size_arrays(BITARRAY_HEX02,bitvect3))),make_uint8(unsafe_multiply_same_size_arrays(BITARRAY_HEX03,bitvect4)))
  @inbounds coli[4]=xor.(xor.(xor.(make_uint8(unsafe_multiply_same_size_arrays(BITARRAY_HEX03,bitvect1)),byte2),byte3),make_uint8(unsafe_multiply_same_size_arrays(BITARRAY_HEX02,bitvect4)))

  return nothing
end

#returns nk,nr fo ra specified keylength in [128,192,256]
function get_keylen_and_rounds(len)
  if len==128
    return 4,10
  elseif len==192
    return 6,12
  elseif len==256
    return 8,14
  else
    error("Invalid keylength of $(len) specified.")
    return -1,-1
  end
end


#=
get_nrounds(cipher::AES128)=10
get_nrounds(cipher::AES192)=12
get_nrounds(cipher::AES256)=14
get_keylen(cipher::AES128)=4
get_keylen(cipher::AES192)=6
get_keylen(cipher::AES256)=8
=#

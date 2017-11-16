function aes_decrypt(inarr::Array{UInt8,1},key::Array{UInt8,1})

  nk,nr=get_keylen_and_rounds(div(length(key)*16,2))
  #nb==4 for AES
  #word=32bits or 4 bytes

  #key generation
    expanded_key=keyExpansionDec(key)
  #read input state
    state=deepcopy(inarr)
    #first round
    nround=nr
    nround16=nround*16
    addRoundKey!(state,view(expanded_key,nround16+1:nround16+16))
  for nround=nr-1:-1:0
    nround16=nround*16
    invsubBytes!(state)
    invshiftRows!(state)
    if nround>0
      invmixColumns!(state)
    end
    addRoundKey!(state,view(expanded_key,nround16+1:nround16+16))
  end

    out = deepcopy(state)
  return out
end


function invshiftRows!(state)
  invshift_secondrow!(state)
  shift_thirdrow!(state) # identical to invshift_thirdrow
  invshift_fourthrow!(state)
  return nothing
end

function invshift_secondrow!(state)
  tmp=state[2]
  state[2]=state[14]
  state[14]=state[10]
  state[10]=state[6]
  state[6]=tmp
  return nothing
end

function invshift_fourthrow!(state)
  tmp=state[4]
  state[4]=state[8]
  state[8]=state[12]
  state[12]=state[16]
  state[16]=tmp
  return nothing
end

function invsubBytes!(state)
  #1. multiplicative inverse of state
  lens=length(state)
  for i=1:lens
        tmp=invsubBytes_affine(make_bitvector(state[i]),SUBBYTESMATRIX_INVERSE)
        tmp2=modinv(tmp)
        state[i]=make_uint8(tmp2)
  end
  return nothing
end

function invsubBytes_affine(b::BitVector,matrix::BitArray)
  tmp=xor.(b,BITARRAY_HEX63)
  tmp=unsafe_boolean_mult(matrix,tmp)
end


function invmixColumns!(state::Array{UInt8,1})
  for col=1:4
    coli=view(state,(1+4*(col-1)):(col*4))
    invmixOneColumn!(coli)
  end
end

function invmixOneColumn!(coli)
  byte1=coli[1]
  byte2=coli[2]
  byte3=coli[3]
  byte4=coli[4]
  bitvect1=make_bitvector(byte1)
  bitvect2=make_bitvector(byte2)
  bitvect3=make_bitvector(byte3)
  bitvect4=make_bitvector(byte4)

  coli[1]=make_uint8(xor.(xor.(xor.(unsafe_multiply_same_size_arrays(BITARRAY_HEX0e,bitvect1),unsafe_multiply_same_size_arrays(BITARRAY_HEX0b,bitvect2)),unsafe_multiply_same_size_arrays(BITARRAY_HEX0d,bitvect3)),unsafe_multiply_same_size_arrays(BITARRAY_HEX09,bitvect4)))
  coli[2]=make_uint8(xor.(xor.(xor.(unsafe_multiply_same_size_arrays(BITARRAY_HEX09,bitvect1),unsafe_multiply_same_size_arrays(BITARRAY_HEX0e,bitvect2)),unsafe_multiply_same_size_arrays(BITARRAY_HEX0b,bitvect3)),unsafe_multiply_same_size_arrays(BITARRAY_HEX0d,bitvect4)))
  coli[3]=make_uint8(xor.(xor.(xor.(unsafe_multiply_same_size_arrays(BITARRAY_HEX0d,bitvect1),unsafe_multiply_same_size_arrays(BITARRAY_HEX09,bitvect2)),unsafe_multiply_same_size_arrays(BITARRAY_HEX0e,bitvect3)),unsafe_multiply_same_size_arrays(BITARRAY_HEX0b,bitvect4)))
  coli[4]=make_uint8(xor.(xor.(xor.(unsafe_multiply_same_size_arrays(BITARRAY_HEX0b,bitvect1),unsafe_multiply_same_size_arrays(BITARRAY_HEX0d,bitvect2)),unsafe_multiply_same_size_arrays(BITARRAY_HEX09,bitvect3)),unsafe_multiply_same_size_arrays(BITARRAY_HEX0e,bitvect4)))

  return nothing
end



#=
function subBytes_affine(b::BitVector,matrix::BitArray)
    tmp=unsafe_boolean_mult(matrix,b)
    xor.(tmp,BITARRAY_HEX63)
end
=#

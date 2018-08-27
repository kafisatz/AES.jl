function keyExpansionDec(key::Array{UInt8,1}) #,nk::Int,nr::Int)
  keylen=div(length(key)*16,2)
  nk,nr=get_keylen_and_rounds(keylen)

    dw=keyExpansionEnc(key)

    for nround = 1:nr-1
      rng=(1+nround*16):((nround+1)*16)
      tmp=deepcopy(dw[rng])
      invmixColumns!(tmp) ## note change of type
      dw[rng]=tmp
    end

   return dw
end

function keyExpansionEnc(key::Array{UInt8,1}) #nk::Int,nr::Int)
  keylen=div(length(key)*16,2)
  nk,nr=get_keylen_and_rounds(keylen)

  i = 1
  i_max=4*4*(nr+1)
  iword_max=div(i_max,4)
  w=zeros(UInt8,i_max) # NB=4  each word is 4 bytes
  while (i <= nk*4)
    w[i] = key[i]
    i = i+1
  end

  fourtimes_nk=4*nk
  three_zeros=zeros(UInt8,3)
  for word_index=nk+1:iword_max
     i = (word_index-1)*4+1
     temp = deepcopy(w[i-4:i-1]) #view(w,i-4:i-1)
     if mod(word_index-1,nk)==0
         rotWord!(temp)
         subWord!(temp)
         rcon_idx=div(word_index-1,nk)
         rconX=lookuprcon(rcon_idx) #rconX is a UInt8
         temp[1] = xor.(temp[1],rconX)
      elseif ((nk > 6) && (mod(word_index-1,nk)==4))
         subWord!(temp)
     end
     #write new key
     j=0
     w[i:i+3] = xor.(w[i - 4*nk:i - 4*nk + 3] , temp)
   end
   return w
end

function lookuprcon(i)
  if i==1
    return RCON1
  elseif i==2
    return RCON2
  elseif i==3
    return RCON3
  elseif i==4
    return RCON4
  elseif i==5
    return RCON5
  elseif i==6
    return RCON6
  elseif i==7
    return RCON7
  elseif i==8
    return RCON8
  elseif i==9
    return RCON9
  elseif i==10
    return RCON10
  else
    error("this should not be happening")
  return 0x0
  end
end

function rotWord!(w)
  @inbounds push!(w,w[1])
  popfirst!(w)
  return nothing
end

function subWord!(w)
  lenw=length(w)
  for i=1:lenw
    wi=w[i]
    tmp=modinv(make_bitvector(wi))
    tmp2=subBytes_affine(tmp,SUBBYTESMATRIX)
    w[i]=make_uint8(tmp2)
  end
  return nothing
end

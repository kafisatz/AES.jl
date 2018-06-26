using Base.Test

include("AES.jl")
using AES

import AES: modinv,make_bitvector,subBytes_affine,make_uint8,right_bitshift!,xtime!,unsafe_multiply_same_size_arrays,make_int_vector,AES128_NK,AES128_NR,keyExpansionEnc,aes_encrypt,AES128,AES192,AES256,SUBBYTESMATRIX,SUBBYTESMATRIX_INVERSE,aes_decrypt,get_keylen_and_rounds,keyExpansionDec

#example of 4.1  on page 10
@test xor.(hex2bytes("57"),hex2bytes("83"))==hex2bytes("d4")

statei=0x53
tmp=modinv(make_bitvector(statei))
tmp2=subBytes_affine(tmp,SUBBYTESMATRIX)
@test 0xed==make_uint8(tmp2)

#test xor on UInt8
for u1=one(UInt8):typemax(UInt8)
  for u2=one(UInt8):typemax(UInt8)
    #u1=0x09
    #u2=0xaf
    ux=xor(u1,u2)
    ux_test=make_uint8(xor.(make_bitvector(u1),make_bitvector(u2)))
    @test ux==ux_test
  end
end


#multiplication
#x=make_bitvector(hex2bytes("57")[1])
#y=make_bitvector(hex2bytes("83")[1])

for z=one(UInt8):typemax(UInt8)
  @test make_uint8(make_bitvector(z))==z
  myy=make_bitvector([7,5,4,2,1])
  z1=myy>>1
  right_bitshift!(myy)
  @test myy==z1
end


  @test xor.(hex2bytes("32"),hex2bytes("2b"))==hex2bytes("19")
  @test xor.(hex2bytes("43"),hex2bytes("7e"))==hex2bytes("3d")
  @test xor.(hex2bytes("f6"),hex2bytes("15"))==hex2bytes("e3")
  @test xor.(hex2bytes("a8"),hex2bytes("16"))==hex2bytes("be")
  @test xor.(hex2bytes("88"),hex2bytes("28"))==hex2bytes("a0")

  @test make_uint8(make_bitvector(hex2bytes("09")[1]))==0x09
  @test make_uint8(make_bitvector(hex2bytes("cf")[1]))==0xcf
  @test make_uint8(make_bitvector(hex2bytes("1b")[1]))==0x1b


myy=make_bitvector([7,5,4,2,1])
xtime!(myy)
@test myy==make_bitvector([6,5,4,2,1,0])
xtime!(myy)
@test myy==make_bitvector([7,6,5,3,2,1])
xtime!(myy)
@test myy==make_bitvector([7,6,2,1,0])
xtime!(myy)
@test myy==make_bitvector([7,4,2,0])
xtime!(myy)
@test myy==make_bitvector([5,4,0])

x0,y0=make_bitvector([7,5,4,2,1]),make_bitvector([6,4,1,0])
res=unsafe_multiply_same_size_arrays(x0,y0)
@test make_int_vector(res)==[5,4,2,1]

#test keyschedule
  test_key=[0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c]
  nk=deepcopy(AES128_NK)
  nr=deepcopy(AES128_NR)
  key=deepcopy(test_key)

  wtest=keyExpansionEnc([0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c])
  @test wtest[end-3:end]==[0xb6,0x63,0x0c,0xa6]

  #key testvectors from nist paper

  #192 key expansion
  k9="8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b"
  k10=hex2bytes(k9)
  wtest=keyExpansionEnc(k10)
  @test wtest[end-15:end]==hex2bytes("e98ba06f448c773c8ecc720401002202")
  #256 key expansion
  @test keyExpansionEnc(hex2bytes("603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4"))[end-15:end]==hex2bytes("fe4890d1e6188d0b046df344706c631e")



#test inverse function
#matrix is from here
#http://www.cs.utsa.edu/~wagner/laws/FFM.html

invmat0=[
"X 01 8d f6 cb 52 7b d1 e8 4f 29 c0 b0 e1 e5 c7",
"74 b4 aa 4b 99 2b 60 5f 58 3f fd cc ff 40 ee b2",
"3a 6e 5a f1 55 4d a8 c9 c1 0a 98 15 30 44 a2 c2",
"2c 45 92 6c f3 39 66 42 f2 35 20 6f 77 bb 59 19",
"1d fe 37 67 2d 31 f5 69 a7 64 ab 13 54 25 e9 09",
"ed 5c 05 ca 4c 24 87 bf 18 3e 22 f0 51 ec 61 17",
"16 5e af d3 49 a6 36 43 f4 47 91 df 33 93 21 3b",
"79 b7 97 85 10 b5 ba 3c b6 70 d0 06 a1 fa 81 82",
"83 7e 7f 80 96 73 be 56 9b 9e 95 d9 f7 02 b9 a4",
"de 6a 32 6d d8 8a 84 72 2a 14 9f 88 f9 dc 89 9a",
"fb 7c 2e c3 8f b8 65 48 26 c8 12 4a ce e7 d2 62",
"0c e0 1f ef 11 75 78 71 a5 8e 76 3d bd bc 86 57",
"0b 28 2f a3 da d4 e4 0f a9 27 53 04 1b fc ac e6",
"7a 07 ae 63 c5 db e2 ea 94 8b c4 d5 9d f8 90 6b",
"b1 0d d6 eb c6 0e cf ad 08 4e d7 e3 5d 50 1e b3",
"5b 23 38 34 68 46 03 8c dd 9c 7d a0 cd 1a 41 1c"]

function expected_inverse(ui::UInt8)
#ui=0x6b
  ui_digits=digits(UInt8,ui,0x10)
  d1=0x00
  d2=0x00
  if size(ui_digits,1)==1
    d1=ui_digits[1]
  else
    d1=ui_digits[1]
    d2=ui_digits[2]
  end
  column=d1
  row=d2
  tmp=invmat0[row+1]
  expected=tmp2=split(tmp)[column+1]
  expected2=hex2bytes(expected)[1]
  return expected2
end


for z=one(UInt8):typemax(UInt8)
  exp=expected_inverse(z)
  calc=make_uint8(modinv(make_bitvector(z)))
  @test exp==calc
end

test_input=[0x32, 0x43, 0xf6, 0xa8, 0x88, 0x5a, 0x30, 0x8d, 0x31, 0x31, 0x98, 0xa2, 0xe0, 0x37, 0x07, 0x34]
test_key=[0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c]

nk=AES128_NK
nr=AES128_NR
result=aes_encrypt(test_input,test_key)
#=
@time result=aes_encrypt(test_input,test_key)
=#
@test result==UInt8[0x39, 0x25, 0x84, 0x1d, 0x02, 0xdc, 0x09, 0xfb, 0xdc, 0x11, 0x85, 0x97, 0x19, 0x6a, 0x0b, 0x32]

chosen_len=128
plain="00112233445566778899aabbccddeeff"
kk="000102030405060708090a0b0c0d0e0f"
plain2=hex2bytes(plain)
kk2=hex2bytes(kk)
wtest=keyExpansionEnc(kk2)
@time aes_encrypt(plain2,kk2)
@test aes_encrypt(plain2,kk2)==hex2bytes("69c4e0d86a7b0430d8cdb78070b4c55a")
ciphertext= aes_encrypt(plain2,kk2)
hopefully_some_plaintext=aes_decrypt(ciphertext,kk2)
@test hopefully_some_plaintext==plain2

for i=1:40
  somekey=rand(UInt8,16)
  sometext=rand(UInt8,16)
  somekey192=rand(UInt8,24)
  somekey256=rand(UInt8,32)
  @test aes_decrypt(aes_encrypt(sometext,somekey),somekey)==sometext
  @test aes_decrypt(aes_encrypt(sometext,somekey192),somekey192)==sometext
  @test aes_decrypt(aes_encrypt(sometext,somekey256),somekey256)==sometext
end


@show "All tests are finished."

#AES

#KEY LENGTH
const AES128_NK=4
const AES192_NK=6
const AES256_NK=8

#NUMBER OF ROUNDS
const AES128_NR=10
const AES192_NR=12
const AES256_NR=14

const BITARRAY_ONE=convert(BitArray,pushfirst!(falses(7),true))
const BITARRAY_ZERO=convert(BitArray,(falses(8)))

const BITARRAY_IRREDUCIBLE_POLYNOMIAL=convert(BitArray,[true,true,false,true,true,false,false,false,true])
const BITARRAY_IRREDUCIBLE_POLYNOMIAL_8BITS=deepcopy(BITARRAY_IRREDUCIBLE_POLYNOMIAL[1:end-1])
const BITARRAY_HEX63=convert(BitArray,[true,true,false,false,false,true,true,false])
const BITARRAY_HEX02=make_bitvector(0x02)
const BITARRAY_HEX03=make_bitvector(0x03)

#for mix columns inverse
const BITARRAY_HEX0b=make_bitvector(0x0b)
const BITARRAY_HEX0d=make_bitvector(0x0d)
const BITARRAY_HEX0e=make_bitvector(0x0e)
const BITARRAY_HEX09=make_bitvector(0x09)

const RCON1=0x01
const RCON2=0x02
const RCON3=0x04
const RCON4=0x08
const RCON5=0x10
const RCON6=0x20
const RCON7=0x40
const RCON8=0x80
const RCON9=0x1b
const RCON10=0x36

const SUBBYTESMATRIX=convert(BitArray,[
1 0 0 0 1 1 1 1
1 1 0 0 0 1 1 1
1 1 1 0 0 0 1 1
1 1 1 1 0 0 0 1
1 1 1 1 1 0 0 0
0 1 1 1 1 1 0 0
0 0 1 1 1 1 1 0
0 0 0 1 1 1 1 1
])

const SUBBYTESMATRIX_INVERSE=convert(BitArray,[
0 0 1 0 0 1 0 1
1 0 0 1 0 0 1 0
0 1 0 0 1 0 0 1
1 0 1 0 0 1 0 0
0 1 0 1 0 0 1 0
0 0 1 0 1 0 0 1
1 0 0 1 0 1 0 0
0 1 0 0 1 0 1 0
])
#=
# const BITARRAY_IRREDUCIBLE_POLYNOMIAL=convert(BitArray,[true,true,false,false,false,true,true,false,true])
# const BITARRAY_IRREDUCIBLE_POLYNOMIAL_8BITS=deepcopy(BITARRAY_IRREDUCIBLE_POLYNOMIAL[1:end-1])
=#

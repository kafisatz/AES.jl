#this follows the NIST Papers on AES
#http://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.197.pdf (Nov 26,2001)
#Also, you may want to consider this paper on modes: http://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-38a.pdf
#NITS paper indices start at ZERO, Julia commonly starts at 1 (although there may be packages available to alter this)

#AES works on data blocks of 128 Bits
#Key lengths are 128, 192 or 256 bits


function my_aes_main(data::Array{UInt8,1})
  return "pony"
end

my_aes_main(str::AbstractString) = my_aes_main(convert(Array{UInt8,1}, str))

#=
function $f(data::Array{UInt8,1})
    ctx = $ctx()
    update!(ctx, data)
    return digest!(ctx)
end

# AbstractStrings are a pretty handy thing to be able to crunch through
$f(str::AbstractString) = $f(convert(Array{UInt8,1}, str))
=#

bytes2hex
hex2bytes
hex


lorem = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
lorem_ui=convert(Array{UInt8,1}, lorem)
context=lorem_ui

